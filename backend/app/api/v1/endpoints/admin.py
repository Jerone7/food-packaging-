"""
Admin Dashboard & Governance Endpoints (Module 15: Admin Dashboard).
Provides secure, RBAC-guarded endpoints for analytics KPIs, trend analysis,
commodity management, material specifications, scientific rules, ML model registry, and audits.
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.api.deps import get_current_admin_user
from app.models.user import User
from app.services.admin_service import AdminService
from app.schemas.admin import (
    AdminAnalyticsSummary,
    DailyUsageTrend,
    RuleThresholdConfig,
    RuleThresholdUpdate,
    ModelRegistryResponse,
    AdminRecommendationAuditResponse,
    AdminFoodCreate,
    AdminFoodUpdate,
    AdminScientificPropertiesUpdate,
    AdminFoodListItem,
    AdminFoodDetailResponse,
    AdminFoodListResponse,
    AdminMaterialCreate,
    AdminMaterialUpdate,
    AdminMaterialResponse,
    AdminMaterialListResponse,
)


router = APIRouter()


# ==========================================
# 1. System Analytics & Trend Endpoints
# ==========================================

@router.get(
    "/analytics/summary",
    response_model=AdminAnalyticsSummary,
    summary="Get System-Wide Analytics Summary & Leaderboards",
    description="Computes platform KPIs, top searched foods, top recommended materials, and usage trends.",
)
async def get_analytics_summary(
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminAnalyticsSummary:
    """Returns aggregated system KPIs, top commodities, and material statistics."""
    return await AdminService.get_analytics_summary(db=db)


@router.get(
    "/analytics/trends",
    response_model=List[DailyUsageTrend],
    summary="Get 30-Day Platform Usage & Eco Trends",
    description="Returns time-series daily analysis volume, eco adoption, and average cost/sustainability scores.",
)
async def get_analytics_trends(
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> List[DailyUsageTrend]:
    """Returns time-series daily trend records."""
    summary = await AdminService.get_analytics_summary(db=db)
    return summary.trends


# ==========================================
# 2. Food Management Endpoints
# ==========================================

@router.get(
    "/foods",
    response_model=AdminFoodListResponse,
    summary="List Food Commodities (Admin)",
    description="Lists all food commodities with pagination, search, and category filtering.",
)
async def list_admin_foods(
    search: Optional[str] = Query(None, description="Search term for commodity name"),
    category: Optional[str] = Query(None, description="Filter by category taxonomy"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminFoodListResponse:
    """Lists food commodities with search and filters."""
    return await AdminService.list_foods(db=db, search=search, category=category, limit=limit, offset=offset)


@router.post(
    "/foods",
    response_model=AdminFoodDetailResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add New Food Commodity (Admin)",
    description="Creates a new food commodity and attaches default scientific properties.",
)
async def create_admin_food(
    payload: AdminFoodCreate,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminFoodDetailResponse:
    """Creates a new food commodity record."""
    return await AdminService.create_food(db=db, payload=payload)


@router.get(
    "/foods/{food_id}",
    response_model=AdminFoodDetailResponse,
    summary="Get Single Food Commodity with Scientific Properties (Admin)",
    description="Retrieves a single food commodity and its complete 14-parameter postharvest profile.",
)
async def get_admin_food(
    food_id: int,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminFoodDetailResponse:
    """Retrieves a single food commodity."""
    food = await AdminService.get_food_by_id(db=db, food_id=food_id)
    if not food:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Food with ID {food_id} not found.")
    return food


@router.put(
    "/foods/{food_id}",
    response_model=AdminFoodDetailResponse,
    summary="Update Food Commodity Core Attributes (Admin)",
    description="Updates core attributes (name, category, moisture, pH, fat) of an existing commodity.",
)
async def update_admin_food(
    food_id: int,
    payload: AdminFoodUpdate,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminFoodDetailResponse:
    """Updates food commodity attributes."""
    updated = await AdminService.update_food(db=db, food_id=food_id, payload=payload)
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Food with ID {food_id} not found.")
    return updated


@router.delete(
    "/foods/{food_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete Food Commodity (Admin)",
    description="Deletes a food commodity and cascade deletes scientific properties.",
)
async def delete_admin_food(
    food_id: int,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """Deletes a food commodity."""
    success = await AdminService.delete_food(db=db, food_id=food_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Food with ID {food_id} not found.")
    return None


@router.put(
    "/foods/{food_id}/scientific-properties",
    response_model=AdminFoodDetailResponse,
    summary="Update 14 Scientific Properties (Admin)",
    description="Updates deep 14-parameter postharvest scientific profile for a food commodity.",
)
async def update_admin_food_scientific_properties(
    food_id: int,
    payload: AdminScientificPropertiesUpdate,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminFoodDetailResponse:
    """Updates 14-parameter scientific properties."""
    updated = await AdminService.update_food_scientific_properties(db=db, food_id=food_id, payload=payload)
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Food with ID {food_id} not found.")
    return updated


# ==========================================
# 3. Packaging Material Management Endpoints
# ==========================================

@router.get(
    "/materials",
    response_model=AdminMaterialListResponse,
    summary="List Packaging Materials (Admin)",
    description="Lists all packaging materials with barrier metrics, polymer family, and active status.",
)
async def list_admin_materials(
    search: Optional[str] = Query(None, description="Search term for substrate name or code"),
    category: Optional[str] = Query(None, description="Filter by category"),
    polymer_family: Optional[str] = Query(None, description="Filter by ML target polymer family"),
    active_only: Optional[bool] = Query(None, description="Filter active materials only"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminMaterialListResponse:
    """Lists packaging materials with filters."""
    return await AdminService.list_materials(
        db=db,
        search=search,
        category=category,
        polymer_family=polymer_family,
        active_only=active_only,
        limit=limit,
        offset=offset,
    )


@router.post(
    "/materials",
    response_model=AdminMaterialResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add New Packaging Material (Admin)",
    description="Creates a new packaging substrate specification.",
)
async def create_admin_material(
    payload: AdminMaterialCreate,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminMaterialResponse:
    """Creates a new packaging material record."""
    return await AdminService.create_material(db=db, payload=payload)


@router.get(
    "/materials/{mat_id}",
    response_model=AdminMaterialResponse,
    summary="Get Single Packaging Material (Admin)",
    description="Retrieves a single packaging substrate specification.",
)
async def get_admin_material(
    mat_id: int,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminMaterialResponse:
    """Retrieves single packaging material."""
    mat = await AdminService.get_material_by_id(db=db, mat_id=mat_id)
    if not mat:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Material with ID {mat_id} not found.")
    return mat


@router.put(
    "/materials/{mat_id}",
    response_model=AdminMaterialResponse,
    summary="Update Packaging Material Specifications (Admin)",
    description="Updates barrier metrics, mechanical strength, thermal properties, cost, and eco scores.",
)
async def update_admin_material(
    mat_id: int,
    payload: AdminMaterialUpdate,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminMaterialResponse:
    """Updates packaging material specifications."""
    updated = await AdminService.update_material(db=db, mat_id=mat_id, payload=payload)
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Material with ID {mat_id} not found.")
    return updated


@router.patch(
    "/materials/{mat_id}/toggle-status",
    response_model=AdminMaterialResponse,
    summary="Toggle Packaging Material Active Status (Admin)",
    description="1-Click toggle between active and archived status for recommendation inclusion.",
)
async def toggle_admin_material_status(
    mat_id: int,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminMaterialResponse:
    """Toggles active/archived material status."""
    toggled = await AdminService.toggle_material_status(db=db, mat_id=mat_id)
    if not toggled:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Material with ID {mat_id} not found.")
    return toggled


@router.delete(
    "/materials/{mat_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete Packaging Material (Admin)",
    description="Decommissions and deletes a packaging material from the database.",
)
async def delete_admin_material(
    mat_id: int,
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """Deletes a packaging material."""
    success = await AdminService.delete_material(db=db, mat_id=mat_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Material with ID {mat_id} not found.")
    return None


# ==========================================
# 4. Rules & Model Governance Endpoints
# ==========================================

@router.get(
    "/rules",
    response_model=RuleThresholdConfig,
    summary="Get Active Scientific Rule Thresholds (Admin)",
    description="Retrieves configurable rule thresholds for lipid oxidation, respiration, pH, and chilling buffers.",
)
async def get_admin_rules(
    current_admin: User = Depends(get_current_admin_user),
) -> RuleThresholdConfig:
    """Retrieves active scientific rule thresholds."""
    return AdminService.get_rule_thresholds()


@router.put(
    "/rules",
    response_model=RuleThresholdConfig,
    summary="Update Scientific Rule Thresholds (Admin)",
    description="Dynamically updates scientific thresholds without restarting backend servers.",
)
async def update_admin_rules(
    payload: RuleThresholdUpdate,
    current_admin: User = Depends(get_current_admin_user),
) -> RuleThresholdConfig:
    """Updates scientific rule thresholds."""
    return AdminService.update_rule_thresholds(update=payload)


@router.get(
    "/models/active",
    response_model=ModelRegistryResponse,
    summary="Get Active ML Model Registry Status (Admin)",
    description="Returns active classifier metadata, algorithm details, feature dimensions, and accuracy scores.",
)
async def get_admin_model_registry(
    current_admin: User = Depends(get_current_admin_user),
) -> ModelRegistryResponse:
    """Retrieves active machine learning model metadata."""
    return AdminService.get_model_registry_info()


@router.patch(
    "/models/toggle-ml",
    response_model=ModelRegistryResponse,
    summary="Toggle ML Classifier vs Heuristic Fallback (Admin)",
    description="Toggles runtime execution of machine learning classifier model.",
)
async def toggle_admin_ml_mode(
    current_admin: User = Depends(get_current_admin_user),
) -> ModelRegistryResponse:
    """Toggles ML classifier active status."""
    info = AdminService.get_model_registry_info()
    AdminService.set_ml_enabled(not info.is_ml_enabled)
    return AdminService.get_model_registry_info()


# ==========================================
# 5. Recommendations Audit Stream Endpoint
# ==========================================

@router.get(
    "/recommendations/audit",
    response_model=AdminRecommendationAuditResponse,
    summary="Get System-Wide Recommendations Audit Log (Admin)",
    description="Returns chronological audit stream of all packaging recommendations generated across users.",
)
async def get_admin_recommendations_audit(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
) -> AdminRecommendationAuditResponse:
    """Retrieves system-wide recommendation audit stream."""
    return await AdminService.get_recommendations_audit(db=db, limit=limit, offset=offset)



