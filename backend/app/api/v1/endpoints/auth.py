"""
Authentication REST Endpoints (Module 14: User Account).
Handles user registration (signup), credential validation (login), and session termination (logout).
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Dict, Any

from app.db.session import get_db
from app.schemas.user import UserCreate, UserLogin, TokenResponse
from app.services.auth_service import AuthService
from app.api.deps import get_optional_current_user
from app.models.user import User

router = APIRouter()


@router.post(
    "/signup",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user account and receive JWT access token",
)
async def signup(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db),
):
    """
    Registers a new user with email, password, full name, optional organization,
    role, and engineering defaults. Issues an immediate 7-day JWT access token.
    """
    try:
        user = await AuthService.create_user(db, user_in)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )

    token_response = await AuthService.issue_token_response(db, user)
    return token_response


@router.post(
    "/login",
    response_model=TokenResponse,
    status_code=status.HTTP_200_OK,
    summary="Authenticate user credentials and obtain JWT access token",
)
async def login(
    credentials: UserLogin,
    db: AsyncSession = Depends(get_db),
):
    """
    Verifies user email and cryptographic password hash.
    Returns standard Bearer JWT with embedded user profile and activity stats.
    """
    user = await AuthService.authenticate_user(
        db, email=credentials.email, password=credentials.password
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password. Please check your credentials.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token_response = await AuthService.issue_token_response(db, user)
    return token_response


@router.post(
    "/logout",
    status_code=status.HTTP_200_OK,
    summary="Log out active session",
)
async def logout(
    current_user: User = Depends(get_optional_current_user),
):
    """
    Terminates the client session. In stateless JWT architecture, client clears
    persisted token; endpoint provides confirmation handshake.
    """
    return {
        "status": "success",
        "message": "Session terminated successfully.",
        "user_email": current_user.email if current_user else None,
    }
