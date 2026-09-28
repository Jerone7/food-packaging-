"""
Saved Analyses Vault REST Endpoints (Module 14: User Account).
Allows authenticated users to pin, organize, inspect, and delete saved packaging recommendation presets.
"""

from typing import List
from fastapi import APIRouter, Depends, HTTPException, Path, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.schemas.user import SavedAnalysisCreate, SavedAnalysisResponse
from app.services.auth_service import AuthService
from app.api.deps import get_current_user
from app.models.user import User

router = APIRouter()


@router.get(
    "",
    response_model=List[SavedAnalysisResponse],
    status_code=status.HTTP_200_OK,
    summary="Get all pinned/saved analyses for authenticated user",
)
async def list_saved_analyses(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Returns all bookmark presets created by the authenticated user,
    ordered by creation date descending.
    """
    saved_list = await AuthService.get_saved_analyses(db, user_id=current_user.id)
    return [AuthService.to_saved_analysis_response(s) for s in saved_list]


@router.post(
    "",
    response_model=SavedAnalysisResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Save a packaging recommendation configuration as a preset",
)
async def create_saved_analysis(
    saved_in: SavedAnalysisCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Pins an active analysis result with custom title, engineering notes,
    and the full input/output payload for instant reload into the analysis cockpit.
    """
    saved = await AuthService.create_saved_analysis(
        db, user_id=current_user.id, saved_create=saved_in
    )
    return AuthService.to_saved_analysis_response(saved)


@router.get(
    "/{analysis_id}",
    response_model=SavedAnalysisResponse,
    status_code=status.HTTP_200_OK,
    summary="Retrieve a specific saved analysis preset",
)
async def get_saved_analysis(
    analysis_id: int = Path(..., ge=1, description="Unique ID of the saved preset"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Retrieves the complete details of a saved analysis preset.
    Enforces user-level multi-tenant isolation.
    """
    saved = await AuthService.get_saved_analysis_by_id(
        db, user_id=current_user.id, analysis_id=analysis_id
    )
    if not saved:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Saved analysis preset #{analysis_id} not found or access denied.",
        )
    return AuthService.to_saved_analysis_response(saved)


@router.delete(
    "/{analysis_id}",
    status_code=status.HTTP_200_OK,
    summary="Delete a saved analysis preset",
)
async def delete_saved_analysis(
    analysis_id: int = Path(..., ge=1, description="Unique ID of the saved preset to delete"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Deletes the specified saved analysis preset with ownership validation.
    """
    success = await AuthService.delete_saved_analysis(
        db, user_id=current_user.id, analysis_id=analysis_id
    )
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Saved analysis preset #{analysis_id} not found or access denied.",
        )
    return {
        "status": "success",
        "message": f"Saved analysis preset #{analysis_id} deleted successfully.",
        "id": analysis_id,
    }
