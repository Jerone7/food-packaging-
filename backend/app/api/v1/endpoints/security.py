"""
Security Diagnostics & Audit Trail Endpoints (Module 19: Security & Validation).
Provides public security health status checks and admin-only security audit log retrieval.
"""

from typing import Any, Dict, List, Optional
from fastapi import APIRouter, Depends, Query, status

from app.core.config import settings
from app.core.rate_limiter import rate_limiter
from app.api.deps import get_current_admin_user
from app.models.user import User
from app.schemas.security import SecurityHealthResponse, SecurityAuditLogItem
from app.services.audit_service import AuditService

router = APIRouter()


@router.get(
    "/health",
    response_model=SecurityHealthResponse,
    summary="System Security Health Status",
    description="Returns active cryptographic parameters, rate limiting policy status, and security posture.",
)
async def get_security_health() -> SecurityHealthResponse:
    """Public security posture check."""
    return SecurityHealthResponse(
        status="SECURE",
        jwt_algorithm="HS256",
        password_hashing="PBKDF2-HMAC-SHA256",
        pbkdf2_iterations=100000,
        rate_limiting_active=rate_limiter.enabled,
        cors_origins_configured=len(settings.CORS_ORIGINS),
    )


@router.get(
    "/admin/audit-logs",
    summary="Get Security Audit Trail",
    description="Returns paginated security event audit logs. Requires administrator privileges.",
)
async def get_security_audit_logs(
    limit: int = Query(50, ge=1, le=200, description="Max entries to return"),
    offset: int = Query(0, ge=0, description="Entries offset"),
    action: Optional[str] = Query(None, description="Filter by action substring (e.g. AUTH, ADMIN)"),
    event_status: Optional[str] = Query(None, alias="status", description="Filter by event status: SUCCESS, WARNING, FAILURE"),
    current_admin: User = Depends(get_current_admin_user),
) -> Dict[str, Any]:
    """Admin-only security event audit log feed."""
    logs, total = AuditService.get_audit_logs(
        limit=limit,
        offset=offset,
        action_filter=action,
        status_filter=event_status,
    )
    return {
        "total": total,
        "items": [log.model_dump(mode="json") for log in logs],
        "limit": limit,
        "offset": offset,
    }
