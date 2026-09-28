"""
Sustainability Analysis & LCA REST API Endpoints (Module 11).
Provides HTTP endpoints for material sustainability profiling, dynamic parametric LCA evaluation,
multi-material trade-off comparisons, and verified empirical matrix inspection.
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, HTTPException, Query, status

from app.schemas.sustainability import (
    SustainabilityEvaluateRequest,
    SustainabilityProfileResponse,
    SustainabilityCompareRequest,
    SustainabilityCompareResponse,
)
from app.core.sustainability_matrix import (
    SustainabilityMatrixEntry,
    VERIFIED_SUSTAINABILITY_MATRIX,
    get_sustainability_matrix_entry,
)
from app.services.sustainability_service import SustainabilityService

router = APIRouter()


@router.get(
    "/materials/{material_id}",
    response_model=SustainabilityProfileResponse,
    summary="Fetch verified sustainability baseline for specific material",
)
async def get_material_sustainability_profile(
    material_id: str,
    package_type: str = Query("Stand-up Doypack (Bottom Gusset)", description="Packaging form factor"),
    batch_size: int = Query(10000, ge=100, le=10000000, description="Production batch volume"),
    pcr_percentage: float = Query(0.0, ge=0.0, le=100.0, description="PCR recycled content %"),
):
    """
    Retrieves the verified empirical sustainability profile and LCA baseline for a material.
    """
    try:
        profile = SustainabilityService.get_material_profile(
            material_id=material_id,
            package_type=package_type,
            batch_size_units=batch_size,
            pcr_percentage=pcr_percentage,
        )
        return profile
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve sustainability profile: {str(e)}",
        )


@router.post(
    "/evaluate",
    response_model=SustainabilityProfileResponse,
    summary="Parametric LCA and waste evaluation for given package specifications",
)
async def evaluate_sustainability(
    request: SustainabilityEvaluateRequest,
):
    """
    Dynamically computes empirical carbon footprint, freshwater consumption,
    PCR carbon abatement, packaging solid waste mass, and Material Circularity Index (MCI).
    """
    try:
        profile = SustainabilityService.evaluate_sustainability(request)
        return profile
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Sustainability calculation failed: {str(e)}",
        )


@router.post(
    "/compare",
    response_model=SustainabilityCompareResponse,
    summary="Side-by-side sustainability comparison across 2 to 4 materials",
)
async def compare_sustainability(
    request: SustainabilityCompareRequest,
):
    """
    Evaluates up to 4 packaging materials side-by-side, identifying best recyclability,
    lowest carbon footprint, and lowest solid waste generation with synthesized eco trade-offs.
    """
    try:
        comparison = SustainabilityService.compare_sustainability(request)
        return comparison
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Multi-material comparison failed: {str(e)}",
        )


@router.get(
    "/matrix",
    response_model=List[Dict[str, Any]] if False else Any,
    summary="Full library of verified empirical sustainability matrix entries",
)
async def get_sustainability_matrix():
    """
    Returns the complete verified empirical Life Cycle Inventory (LCI) dataset.
    """
    entries = SustainabilityService.get_matrix_entries()
    return [entry.to_dict() for entry in entries]
