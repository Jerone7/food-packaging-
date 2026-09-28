import logging
import secrets
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.core.config import settings
from app.core.rate_limiter import rate_limiter
from app.schemas.security import ApiErrorEnvelope, ApiErrorDetail
from app.api.v1.router import api_router
from app.db.session import engine, Base

# Import all models to ensure metadata registration
from app.models.packaging import PackagingRecommendation
from app.models.user import User, SavedAnalysis
from app.models.food_and_packaging import (
    Source,
    Food,
    RespirationData,
    PackagingMaterial,
    GasProperty,
    IFCTFoodComposition,
)

logger = logging.getLogger("smartpack.security")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize DB tables on startup
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        print("All PostgreSQL tables (packaging, foods, respiration, materials, IFCT 2017) verified.")
    except Exception as e:
        print(f"Notice: PostgreSQL connection on startup ({e}). Continuing with offline-ready mode.")
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan,
    description="SmartPack AI backend using FastAPI, PostgreSQL, and IFCT 2017 database.",
)

# 1. Rate Limiting Middleware
@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    throttled = await rate_limiter.check_rate_limit(request)
    if throttled:
        return throttled
    response = await call_next(request)
    return response

# 2. CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. Multi-Language (I18N) Middleware
from app.core.i18n import I18nMiddleware
app.add_middleware(I18nMiddleware)

# 3. Global Exception Handlers for Standardized Error Envelopes

from fastapi.encoders import jsonable_encoder

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Translates Pydantic schema validation failures into clean ApiErrorEnvelope."""
    field_errors = []
    messages = []
    for err in exc.errors():
        field_name = ".".join(str(loc) for loc in err.get("loc", []) if str(loc) != "body")
        msg = str(err.get("msg", "Invalid field value"))
        err_type = str(err.get("type", "value_error"))
        field_errors.append({"field": field_name or "body", "issue": msg, "type": err_type})
        messages.append(f"{field_name}: {msg}" if field_name else msg)

    detail_str = "; ".join(messages) if messages else "Invalid request payload."
    error_detail = ApiErrorDetail(
        code="VALIDATION_ERROR",
        message=f"Validation failed: {detail_str}",
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        timestamp=datetime.now(timezone.utc),
        details=field_errors,
    )
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "detail": jsonable_encoder(exc.errors()),
            "error": error_detail.model_dump(mode="json"),
        },
    )

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    """Wraps standard HTTP errors in the uniform ApiErrorEnvelope."""
    message = str(exc.detail) if exc.detail else "An HTTP error occurred."
    code = "HTTP_ERROR"
    if exc.status_code == 401:
        code = "UNAUTHORIZED"
    elif exc.status_code == 403:
        code = "FORBIDDEN"
    elif exc.status_code == 404:
        code = "NOT_FOUND"
    elif exc.status_code == 409:
        code = "CONFLICT"
    elif exc.status_code == 429:
        code = "RATE_LIMIT_EXCEEDED"

    error_detail = ApiErrorDetail(
        code=code,
        message=message,
        status_code=exc.status_code,
        timestamp=datetime.now(timezone.utc),
    )
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.detail,
            "error": error_detail.model_dump(mode="json"),
        },
    )

@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    """Sanitizes unexpected internal exceptions, preventing stack trace disclosure to clients."""
    request_id = f"err_{secrets.token_hex(6)}"
    logger.error(
        f"Unhandled server error [ID: {request_id}] on {request.method} {request.url.path}: {exc}",
        exc_info=True,
    )
    error_detail = ApiErrorDetail(
        code="INTERNAL_SERVER_ERROR",
        message=f"An unexpected internal error occurred. Please quote request ID: {request_id}",
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        timestamp=datetime.now(timezone.utc),
        request_id=request_id,
    )
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "detail": f"Internal Server Error. Request ID: {request_id}",
            "error": error_detail.model_dump(mode="json"),
        },
    )

# Include API Router
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/", tags=["Health Check"])
async def root():
    return {
        "status": "online",
        "service": settings.PROJECT_NAME,
        "docs_url": "/docs",
    }

