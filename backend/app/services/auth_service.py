"""
Authentication & User Data Service Logic (Module 14: User Account).
Handles user registration, authentication, profile updates, stats aggregation,
and saved analysis presets CRUD with async database sessions and in-memory fallback.
"""

from datetime import datetime, timezone
from typing import Dict, Any, List, Optional, Union
from sqlalchemy import select, delete, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_password_hash, verify_password, create_access_token
from app.models.user import User, SavedAnalysis
from app.models.packaging import PackagingRecommendation
from app.schemas.user import (
    UserCreate,
    UserUpdate,
    UserPreferences,
    UserStats,
    UserResponse,
    TokenResponse,
    SavedAnalysisCreate,
    SavedAnalysisResponse,
)


class AuthService:
    """Core domain service for user authentication, account management, and saved presets."""

    # In-memory stores for offline demo / test environments
    _memory_users: Dict[int, User] = {}
    _memory_users_by_email: Dict[str, User] = {}
    _memory_saved_analyses: Dict[int, SavedAnalysis] = {}
    _user_id_seq: int = 1
    _saved_id_seq: int = 1

    @classmethod
    def reset_memory_store(cls):
        """Resets the in-memory fallback store (useful for clean unit tests)."""
        cls._memory_users.clear()
        cls._memory_users_by_email.clear()
        cls._memory_saved_analyses.clear()
        cls._user_id_seq = 1
        cls._saved_id_seq = 1

    # --- User Lookup Methods ---

    @classmethod
    async def get_user_by_id(cls, db: Optional[AsyncSession], user_id: int) -> Optional[User]:
        """Retrieves a user by primary ID."""
        if db is not None:
            try:
                result = await db.execute(select(User).where(User.id == user_id))
                return result.scalar_one_or_none()
            except Exception:
                pass  # Fallback to memory
        return cls._memory_users.get(user_id)

    @classmethod
    async def get_user_by_email(cls, db: Optional[AsyncSession], email: str) -> Optional[User]:
        """Retrieves a user by email address (case-insensitive)."""
        clean_email = email.strip().lower()
        if db is not None:
            try:
                result = await db.execute(select(User).where(User.email == clean_email))
                return result.scalar_one_or_none()
            except Exception:
                pass  # Fallback to memory
        return cls._memory_users_by_email.get(clean_email)

    # --- Registration & Authentication ---

    @classmethod
    async def create_user(cls, db: Optional[AsyncSession], user_create: UserCreate) -> User:
        """
        Registers a new user account with hashed password and default preferences.
        Raises ValueError if email is already taken.
        """
        clean_email = user_create.email.strip().lower()
        existing = await cls.get_user_by_email(db, clean_email)
        if existing:
            raise ValueError(f"User with email '{clean_email}' already exists.")

        hashed = get_password_hash(user_create.password)
        now = datetime.now(timezone.utc)

        preferences_data = {
            "default_eco_priority": user_create.default_eco_priority,
            "default_currency": user_create.default_currency,
            "default_batch_size": 10000,
            "export_organization_header": user_create.organization,
        }

        user = User(
            email=clean_email,
            hashed_password=hashed,
            full_name=user_create.full_name.strip(),
            organization=user_create.organization.strip() if user_create.organization else None,
            role=user_create.role.strip() if user_create.role else "Packaging Engineer",
            is_active=True,
            is_admin=False,
            preferences_json=preferences_data,
            created_at=now,
            updated_at=now,
        )

        if db is not None:
            try:
                db.add(user)
                await db.commit()
                await db.refresh(user)
                # Keep memory cache in sync
                cls._memory_users[user.id] = user
                cls._memory_users_by_email[user.email] = user
                return user
            except Exception:
                await db.rollback()

        # Offline / in-memory fallback
        user.id = cls._user_id_seq
        cls._user_id_seq += 1
        cls._memory_users[user.id] = user
        cls._memory_users_by_email[user.email] = user
        return user

    @classmethod
    async def authenticate_user(
        cls, db: Optional[AsyncSession], email: str, password: str
    ) -> Optional[User]:
        """
        Authenticates user credentials. Returns User if valid & active, otherwise None.
        """
        user = await cls.get_user_by_email(db, email)
        if not user or not user.is_active:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user

    @classmethod
    async def issue_token_response(
        cls, db: Optional[AsyncSession], user: User, expires_in_seconds: int = 604800
    ) -> TokenResponse:
        """
        Issues an HS256 JWT access token and bundles it with the user's profile and stats.
        """
        token = create_access_token(
            subject=user.id,
            role="admin" if user.is_admin else "user",
            extra_claims={"email": user.email, "name": user.full_name},
        )
        user_response = await cls.to_user_response(db, user)
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            expires_in_seconds=expires_in_seconds,
            user=user_response,
        )

    # --- Profile & Preferences ---

    @classmethod
    async def update_user_profile(
        cls, db: Optional[AsyncSession], user_id: int, user_update: UserUpdate
    ) -> Optional[User]:
        """Updates user profile information and engineering preferences."""
        user = await cls.get_user_by_id(db, user_id)
        if not user:
            return None

        if user_update.full_name is not None:
            user.full_name = user_update.full_name.strip()
        if user_update.organization is not None:
            user.organization = user_update.organization.strip()
        if user_update.role is not None:
            user.role = user_update.role.strip()

        # Update preferences JSON
        prefs = dict(user.preferences_json or {})
        if user_update.default_eco_priority is not None:
            prefs["default_eco_priority"] = user_update.default_eco_priority
        if user_update.default_currency is not None:
            prefs["default_currency"] = user_update.default_currency
        if user_update.default_batch_size is not None:
            prefs["default_batch_size"] = user_update.default_batch_size
        if user_update.export_organization_header is not None:
            prefs["export_organization_header"] = user_update.export_organization_header

        user.preferences_json = prefs
        user.updated_at = datetime.now(timezone.utc)

        if db is not None:
            try:
                db.add(user)
                await db.commit()
                await db.refresh(user)
            except Exception:
                await db.rollback()

        return user

    @classmethod
    async def get_user_stats(cls, db: Optional[AsyncSession], user_id: int) -> UserStats:
        """Computes aggregate activity and circularity statistics for a user."""
        user = await cls.get_user_by_id(db, user_id)
        member_since = user.created_at if user else datetime.now(timezone.utc)

        total_analyses = 0
        eco_count = 0
        total_score = 0.0
        saved_count = 0

        # Query history
        if db is not None:
            try:
                hist_res = await db.execute(
                    select(PackagingRecommendation).where(PackagingRecommendation.user_id == user_id)
                )
                records = hist_res.scalars().all()
                total_analyses = len(records)
                eco_count = sum(1 for r in records if r.eco_friendly or r.sustainability_score >= 80)
                if total_analyses > 0:
                    total_score = sum(r.sustainability_score for r in records)

                saved_res = await db.execute(
                    select(func.count(SavedAnalysis.id)).where(SavedAnalysis.user_id == user_id)
                )
                saved_count = saved_res.scalar() or 0
            except Exception:
                pass

        # In-memory tally if DB returned 0 or in test mode
        if total_analyses == 0:
            saved_count = sum(1 for s in cls._memory_saved_analyses.values() if s.user_id == user_id)

        avg_score = (total_score / total_analyses) if total_analyses > 0 else 85.0

        return UserStats(
            total_analyses_count=total_analyses,
            saved_presets_count=saved_count,
            eco_friendly_count=eco_count,
            average_sustainability_score=round(avg_score, 1),
            member_since=member_since,
        )

    @classmethod
    async def to_user_response(
        cls, db: Optional[AsyncSession], user: User, include_stats: bool = True
    ) -> UserResponse:
        """Converts an ORM User model into a serialized Pydantic UserResponse."""
        prefs_dict = user.preferences_json or {}
        preferences = UserPreferences(
            default_eco_priority=prefs_dict.get("default_eco_priority", True),
            default_currency=prefs_dict.get("default_currency", "INR"),
            default_batch_size=prefs_dict.get("default_batch_size", 10000),
            export_organization_header=prefs_dict.get("export_organization_header", user.organization),
        )

        stats = await cls.get_user_stats(db, user.id) if include_stats else None

        return UserResponse(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            organization=user.organization,
            role=user.role or "Packaging Engineer",
            is_active=user.is_active,
            is_admin=user.is_admin,
            created_at=user.created_at or datetime.now(timezone.utc),
            preferences=preferences,
            stats=stats,
        )

    # --- Saved Analysis Presets CRUD ---

    @classmethod
    async def create_saved_analysis(
        cls, db: Optional[AsyncSession], user_id: int, saved_create: SavedAnalysisCreate
    ) -> SavedAnalysis:
        """Pins and persists a recommendation preset for the specified user."""
        res_dict = saved_create.recommendation_result or {}

        # Extract material name, cost, and eco score with fallbacks
        material = saved_create.recommended_material or res_dict.get("material_name") or res_dict.get("recommended_material") or "Optimized Packaging Substrate"
        cost = saved_create.estimated_cost
        if cost is None:
            cost = float(res_dict.get("estimated_cost") or res_dict.get("estimated_cost_per_unit_inr") or res_dict.get("costPerUnit") or 3.50)

        score = saved_create.sustainability_score
        if score is None:
            score = float(res_dict.get("sustainability_score") or res_dict.get("sustainabilityScore") or 85.0)

        now = datetime.now(timezone.utc)
        saved = SavedAnalysis(
            user_id=user_id,
            title=saved_create.title.strip(),
            notes=saved_create.notes.strip() if saved_create.notes else None,
            commodity_name=saved_create.commodity_name.strip(),
            recommended_material=material,
            estimated_cost=round(float(cost), 2),
            sustainability_score=round(float(score), 1),
            input_payload=saved_create.input_payload,
            recommendation_result=saved_create.recommendation_result,
            created_at=now,
            updated_at=now,
        )

        if db is not None:
            try:
                db.add(saved)
                await db.commit()
                await db.refresh(saved)
                cls._memory_saved_analyses[saved.id] = saved
                return saved
            except Exception:
                await db.rollback()

        saved.id = cls._saved_id_seq
        cls._saved_id_seq += 1
        cls._memory_saved_analyses[saved.id] = saved
        return saved

    @classmethod
    async def get_saved_analyses(
        cls, db: Optional[AsyncSession], user_id: int
    ) -> List[SavedAnalysis]:
        """Fetches all saved analysis presets belonging to a specific user."""
        if db is not None:
            try:
                result = await db.execute(
                    select(SavedAnalysis)
                    .where(SavedAnalysis.user_id == user_id)
                    .order_by(SavedAnalysis.created_at.desc())
                )
                return list(result.scalars().all())
            except Exception:
                pass

        user_presets = [s for s in cls._memory_saved_analyses.values() if s.user_id == user_id]
        user_presets.sort(key=lambda s: s.created_at or datetime.min, reverse=True)
        return user_presets

    @classmethod
    async def get_saved_analysis_by_id(
        cls, db: Optional[AsyncSession], user_id: int, analysis_id: int
    ) -> Optional[SavedAnalysis]:
        """Fetches a specific saved preset, enforcing user ownership."""
        if db is not None:
            try:
                result = await db.execute(
                    select(SavedAnalysis).where(
                        SavedAnalysis.id == analysis_id, SavedAnalysis.user_id == user_id
                    )
                )
                return result.scalar_one_or_none()
            except Exception:
                pass

        preset = cls._memory_saved_analyses.get(analysis_id)
        if preset and preset.user_id == user_id:
            return preset
        return None

    @classmethod
    async def delete_saved_analysis(
        cls, db: Optional[AsyncSession], user_id: int, analysis_id: int
    ) -> bool:
        """Deletes a saved preset, ensuring the requester is the owner."""
        if db is not None:
            try:
                result = await db.execute(
                    delete(SavedAnalysis).where(
                        SavedAnalysis.id == analysis_id, SavedAnalysis.user_id == user_id
                    )
                )
                await db.commit()
                if result.rowcount > 0:
                    cls._memory_saved_analyses.pop(analysis_id, None)
                    return True
            except Exception:
                await db.rollback()

        if analysis_id in cls._memory_saved_analyses:
            if cls._memory_saved_analyses[analysis_id].user_id == user_id:
                del cls._memory_saved_analyses[analysis_id]
                return True
        return False

    @classmethod
    def to_saved_analysis_response(cls, saved: SavedAnalysis) -> SavedAnalysisResponse:
        """Serializes ORM SavedAnalysis into SavedAnalysisResponse."""
        return SavedAnalysisResponse(
            id=saved.id,
            user_id=saved.user_id,
            title=saved.title,
            notes=saved.notes,
            commodity_name=saved.commodity_name,
            recommended_material=saved.recommended_material,
            estimated_cost=saved.estimated_cost,
            sustainability_score=saved.sustainability_score,
            input_payload=saved.input_payload,
            recommendation_result=saved.recommendation_result,
            created_at=saved.created_at or datetime.now(timezone.utc),
            updated_at=saved.updated_at,
        )
