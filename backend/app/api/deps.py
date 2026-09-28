"""
Authentication and Database Dependencies (Module 14: User Account).
Provides FastAPI dependencies for extracting, validating, and injecting authenticated users.
"""

from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.core.security import decode_access_token
from app.services.auth_service import AuthService
from app.services.audit_service import AuditService
from app.models.user import User

# HTTP Bearer authentication scheme with auto_error=False for flexible handling
oauth2_bearer = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(oauth2_bearer),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Validates the Bearer JWT token from the Authorization header and resolves the User.
    Raises 401 Unauthorized if the token is missing, expired, or invalid.
    """
    if not credentials or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token is required.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials
    payload = decode_access_token(token)
    if not payload or "sub" not in payload:
        AuditService.log_event(
            action="AUTH_FAILED_INVALID_TOKEN",
            status="WARNING",
            details={"reason": "Invalid or expired JWT token"},
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        user_id = int(payload["sub"])
    except (ValueError, TypeError):
        AuditService.log_event(
            action="AUTH_FAILED_MALFORMED_SUB",
            status="WARNING",
            details={"sub": str(payload.get("sub"))},
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Malformation in token payload subject.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user = await AuthService.get_user_by_id(db, user_id)
    if not user:
        AuditService.log_event(
            action="AUTH_FAILED_USER_NOT_FOUND",
            status="WARNING",
            user_id=user_id,
        )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authenticated user account does not exist.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        AuditService.log_event(
            action="AUTH_FAILED_INACTIVE_USER",
            status="WARNING",
            user_id=user.id,
            details={"email": user.email},
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account has been deactivated.",
        )

    return user


async def get_optional_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(oauth2_bearer),
    db: AsyncSession = Depends(get_db),
) -> Optional[User]:
    """
    Optionally validates a Bearer JWT token. Returns User if present & valid; otherwise None without error.
    Used for public or guest-accessible endpoints that enhance response if authenticated.
    """
    if not credentials or not credentials.credentials:
        return None

    token = credentials.credentials
    payload = decode_access_token(token)
    if not payload or "sub" not in payload:
        return None

    try:
        user_id = int(payload["sub"])
        user = await AuthService.get_user_by_id(db, user_id)
        if user and user.is_active:
            return user
    except Exception:
        return None

    return None


async def get_current_admin_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """
    Validates that the currently authenticated user possesses administrative privileges (is_admin == True).
    Raises 403 Forbidden if the user is not an administrator.
    """
    if not current_user.is_admin:
        AuditService.log_event(
            action="UNAUTHORIZED_ADMIN_ELEVATION_ATTEMPT",
            status="WARNING",
            user_id=current_user.id,
            details={"email": current_user.email, "role": getattr(current_user, "role", "user")},
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required.",
        )
    return current_user

