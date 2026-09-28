from fastapi import APIRouter
from app.api.v1.endpoints import (
    auth,
    users,
    saved_analyses,
    packaging,
    food_data,
    materials,
    sustainability,
    reports,
    admin,
    ai_models,
    analytics,
    security,
)

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["User Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["User Profile & Activity"])
api_router.include_router(saved_analyses.router, prefix="/saved-analyses", tags=["Saved Analyses Vault"])
api_router.include_router(packaging.router, prefix="/packaging", tags=["Packaging Recommender"])
api_router.include_router(food_data.router, prefix="/data", tags=["Food & Packaging Knowledge Base"])
api_router.include_router(food_data.router, prefix="/food-data", tags=["Food Data"])
api_router.include_router(materials.router, prefix="/materials", tags=["Packaging Material Database"])
api_router.include_router(sustainability.router, prefix="/sustainability", tags=["Sustainability Analysis"])
api_router.include_router(reports.router, prefix="/reports", tags=["Recommendation Reports"])
api_router.include_router(admin.router, prefix="/admin", tags=["Admin Governance & Analytics"])
api_router.include_router(ai_models.router, prefix="/admin/models", tags=["AI Model Management & MLOps"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["Analytics Dashboard"])
api_router.include_router(security.router, prefix="/security", tags=["Security & Diagnostics"])



