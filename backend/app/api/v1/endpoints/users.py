"""
User Profile & Activity Endpoints (Module 14: User Account).
Provides endpoints for retrieving user profile, updating engineering preferences,
and querying user-scoped recommendation history.
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.db.session import get_db
from app.schemas.user import UserUpdate, UserResponse
from app.schemas.packaging import PackagingHistoryItem, PackagingRecordResponse
from app.services.auth_service import AuthService
from app.services.packaging_service import PackagingHistoryService
from app.api.deps import get_current_user
from app.models.user import User
from app.models.packaging import PackagingRecommendation

router = APIRouter()


@router.get(
    "/me",
    response_model=UserResponse,
    status_code=status.HTTP_200_OK,
    summary="Get authenticated user profile and sustainability stats",
)
async def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Returns the active user's profile metadata, engineering preferences,
    and aggregate circularity / packaging metrics.
    """
    return await AuthService.to_user_response(db, current_user, include_stats=True)


@router.put(
    "/me",
    response_model=UserResponse,
    status_code=status.HTTP_200_OK,
    summary="Update user profile and engineering preferences",
)
async def update_my_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Updates user display details (full name, organization, role) and
    default engineering preferences (eco priority bias, currency, batch sizes).
    """
    updated_user = await AuthService.update_user_profile(
        db, user_id=current_user.id, user_update=user_update
    )
    if not updated_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found for update.",
        )
    return await AuthService.to_user_response(db, updated_user, include_stats=True)


@router.get(
    "/me/history",
    response_model=List[PackagingHistoryItem],
    status_code=status.HTTP_200_OK,
    summary="Get authenticated user's analysis history",
)
async def get_my_history(
    skip: int = Query(0, ge=0, description="Offset records count"),
    limit: int = Query(50, ge=1, le=100, description="Maximum records to return"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Retrieves recommendation history runs linked strictly to the authenticated user.
    """
    records = await PackagingHistoryService.get_user_history(
        db, user_id=current_user.id, limit=limit, offset=skip
    )
    return [PackagingHistoryService.to_history_item_schema(r) for r in records]


@router.delete(
    "/me/history",
    status_code=status.HTTP_200_OK,
    summary="Clear all analysis history for authenticated user",
)
async def clear_my_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Clears all recommendation history entries belonging to the authenticated user.
    """
    deleted_count = await PackagingHistoryService.clear_user_history(
        db, user_id=current_user.id
    )
    return {
        "success": True,
        "message": f"Successfully cleared {deleted_count} history records.",
        "deleted_count": deleted_count,
    }


