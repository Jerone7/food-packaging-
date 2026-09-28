"""
REST Endpoints for Packaging Material Database (Module 6).
Provides endpoints for catalog exploration, advanced filtering, custom material creation,
radar scoring, and multi-material side-by-side comparison.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.services.material_service import material_service
from app.schemas.packaging_material import (
    PackagingMaterialDetailResponse,
    MaterialFilterParams,
    CreatePackagingMaterialInput,
    MaterialComparisonRequest,
    MaterialComparisonResponse,
    MaterialCategorySummaryResponse,
)

router = APIRouter()


@router.get(
    "",
    response_model=List[PackagingMaterialDetailResponse],
    summary="Explore and filter packaging materials",
)
async def list_packaging_materials(
    search: Optional[str] = Query(None, description="Search keyword across name, structure, category"),
    category: Optional[str] = Query(None, description="Filter by domain category"),
    polymer_family: Optional[str] = Query(None, description="Filter by polymer family code"),
    max_otr: Optional[float] = Query(None, description="Upper bound for Oxygen Transmission Rate (cc/m²/day)"),
    max_wvtr: Optional[float] = Query(None, description="Upper bound for Water Vapor Transmission Rate (g/m²/day)"),
    min_sustainability: Optional[float] = Query(None, description="Lower bound for sustainability score (0-100)"),
    is_biodegradable: Optional[bool] = Query(None, description="Filter by biodegradability"),
    is_recyclable: Optional[bool] = Query(None, description="Filter by mechanical recyclability"),
    is_cryogenic: Optional[bool] = Query(None, description="Filter by sub-zero / cryogenic grade"),
    is_retort: Optional[bool] = Query(None, description="Filter by retort / autoclave grade"),
    cost_tier: Optional[str] = Query(None, description="Budget Economy, Commercial Standard, Premium Barrier, High-Tech"),
    sort_by: Optional[str] = Query("sustainability_score", description="Sort field (sustainability_score, otr, wvtr, cost, tensile, name)"),
    sort_order: Optional[str] = Query("desc", description="Sort direction: asc or desc"),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
):
    """
    Retrieves filtered packaging materials with normalized 6-axis radar scores,
    barrier ratings, thermal ratings, and environmental profiles.
    """
    filter_params = MaterialFilterParams(
        search=search,
        category=category,
        polymer_family=polymer_family,
        max_otr=max_otr,
        max_wvtr=max_wvtr,
        min_sustainability=min_sustainability,
        is_biodegradable=is_biodegradable,
        is_recyclable=is_recyclable,
        is_cryogenic=is_cryogenic,
        is_retort=is_retort,
        cost_tier=cost_tier,
        sort_by=sort_by,
        sort_order=sort_order,
    )
    return await material_service.get_materials(
        db=db,
        filters=filter_params,
        limit=limit,
        offset=offset,
    )


@router.get(
    "/categories",
    response_model=List[MaterialCategorySummaryResponse],
    summary="Get grouped category statistics",
)
async def get_material_categories(db: AsyncSession = Depends(get_db)):
    """Returns grouped category summaries with counts and average eco-scores."""
    return await material_service.get_categories_summary(db=db)


@router.post(
    "/compare",
    response_model=MaterialComparisonResponse,
    summary="Side-by-side 6-axis comparison for 2-4 materials",
)
async def compare_materials(
    request: MaterialComparisonRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Compares 2 to 4 packaging materials across Barrier, Mechanical, Thermal,
    Sustainability, Cost Efficiency, and Optical performance axes with automated trade-off insights.
    """
    return await material_service.compare_materials(request=request, db=db)


@router.get(
    "/{material_id}",
    response_model=PackagingMaterialDetailResponse,
    summary="Get detailed technical profile for a material",
)
async def get_material_detail(
    material_id: str,
    db: AsyncSession = Depends(get_db),
):
    """Returns complete 12-property vector profile and radar scores for a material."""
    material = await material_service.get_material_by_id(material_id, db=db)
    if not material:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Packaging material with ID '{material_id}' not found.",
        )
    return material


@router.post(
    "",
    response_model=PackagingMaterialDetailResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create custom packaging material entry",
)
async def create_custom_material(
    payload: CreatePackagingMaterialInput,
    db: AsyncSession = Depends(get_db),
):
    """Adds a new empirical packaging material entry into PostgreSQL and runtime memory catalog."""
    return await material_service.create_material(input_data=payload, db=db)


@router.put(
    "/{material_id}",
    response_model=PackagingMaterialDetailResponse,
    summary="Update packaging material specification",
)
async def update_packaging_material(
    material_id: str,
    payload: CreatePackagingMaterialInput,
    db: AsyncSession = Depends(get_db),
):
    """Updates technical parameters and recomputes radar scores for a material."""
    updated = await material_service.update_material(material_id, input_data=payload, db=db)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Cannot update: material '{material_id}' not found.",
        )
    return updated
