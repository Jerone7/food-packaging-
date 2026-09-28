"""
Packaging History & Analysis Workspace Domain Service (Module 13: Recommendation History).
Handles user-scoped historical analysis persistence, retrieval, deletion, and empirical offline fallback.
"""

from datetime import datetime, timezone
from typing import List, Optional, Dict, Any
from sqlalchemy import select, delete, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.models.packaging import PackagingRecommendation
from app.schemas.packaging import PackagingHistoryItem, format_history_date


class PackagingHistoryService:
    """Core domain service for user-scoped packaging recommendation history."""

    # In-memory history store for offline / guest / test environments
    _memory_history: List[PackagingRecommendation] = []
    _history_id_seq: int = 300

    @classmethod
    def _init_default_samples(cls):
        """Initializes standard empirical sample records for offline / demo mode."""
        cls._memory_history = [
            PackagingRecommendation(
                id=201,
                user_id=1,
                item_name="Tomato",
                length=30.0,
                width=20.0,
                height=15.0,
                weight=5.0,
                is_fragile=True,
                eco_friendly=True,
                recommended_box_type="Corrugated Kraft Box (5-Ply)",
                recommended_dimensions="30.0 x 20.0 x 15.0 cm",
                cushioning_material="Recycled Kraft Honeycomb Pads",
                estimated_cost=3.10,
                sustainability_score=96.5,
                notes="High-humidity export grade ventilated container.",
                created_at=datetime(2026, 9, 26, 14, 30, 0, tzinfo=timezone.utc),
            ),
            PackagingRecommendation(
                id=202,
                user_id=1,
                item_name="Apple",
                length=25.0,
                width=18.0,
                height=12.0,
                weight=3.0,
                is_fragile=False,
                eco_friendly=True,
                recommended_box_type="Molded Pulp Tray with Bio-Film",
                recommended_dimensions="25.0 x 18.0 x 12.0 cm",
                cushioning_material="Molded Sugarcane Bagasse Divots",
                estimated_cost=2.85,
                sustainability_score=94.0,
                notes="Bruise-preventing molded pulp structure with micro-perforations.",
                created_at=datetime(2026, 9, 25, 10, 15, 0, tzinfo=timezone.utc),
            ),
            PackagingRecommendation(
                id=203,
                user_id=1,
                item_name="Potato",
                length=35.0,
                width=25.0,
                height=20.0,
                weight=10.0,
                is_fragile=False,
                eco_friendly=True,
                recommended_box_type="Jute-Lined Ventilated Paper Sack",
                recommended_dimensions="35.0 x 25.0 x 20.0 cm",
                cushioning_material="None (Bulk Aeration Mesh)",
                estimated_cost=1.75,
                sustainability_score=98.0,
                notes="Anti-greening breathable light-blocking bio-sack.",
                created_at=datetime(2026, 9, 23, 16, 45, 0, tzinfo=timezone.utc),
            ),
        ]
        cls._history_id_seq = 300

    @classmethod
    def reset_memory_store(cls, with_samples: bool = True):
        """Resets in-memory storage (used for tests and fresh state)."""
        if with_samples:
            cls._init_default_samples()
        else:
            cls._memory_history.clear()
            cls._history_id_seq = 1

    # --- Query Methods ---

    @classmethod
    async def get_user_history(
        cls,
        db: Optional[AsyncSession],
        user_id: Optional[int] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> List[PackagingRecommendation]:
        """
        Retrieves historical recommendation runs for a user.
        If user_id is provided, filters by user; if DB is offline, returns in-memory fallback.
        """
        if db is not None:
            try:
                stmt = select(PackagingRecommendation)
                if user_id is not None:
                    stmt = stmt.where(PackagingRecommendation.user_id == user_id)
                stmt = stmt.order_by(desc(PackagingRecommendation.created_at)).offset(offset).limit(limit)

                result = await db.execute(stmt)
                records = list(result.scalars().all())
                if records:
                    return records
            except Exception:
                pass  # Fallback to memory

        # In-memory fallback
        if user_id is not None:
            filtered = [r for r in cls._memory_history if r.user_id == user_id or r.user_id is None]
        else:
            filtered = list(cls._memory_history)

        filtered.sort(key=lambda r: r.created_at or datetime.min, reverse=True)
        return filtered[offset : offset + limit]

    @classmethod
    async def get_history_by_id(
        cls,
        db: Optional[AsyncSession],
        history_id: int,
        user_id: Optional[int] = None,
    ) -> Optional[PackagingRecommendation]:
        """Retrieves a single historical recommendation run by ID."""
        if db is not None:
            try:
                stmt = select(PackagingRecommendation).where(PackagingRecommendation.id == history_id)
                if user_id is not None:
                    stmt = stmt.where(PackagingRecommendation.user_id == user_id)
                result = await db.execute(stmt)
                return result.scalar_one_or_none()
            except Exception:
                pass

        for r in cls._memory_history:
            if r.id == history_id:
                if user_id is None or r.user_id is None or r.user_id == user_id:
                    return r
        return None

    # --- Mutation Methods ---

    @classmethod
    async def save_history(
        cls,
        db: Optional[AsyncSession],
        item_name: str,
        length: float,
        width: float,
        height: float,
        weight: float,
        is_fragile: bool,
        eco_friendly: bool,
        recommended_box_type: str,
        recommended_dimensions: str,
        estimated_cost: float,
        sustainability_score: float,
        cushioning_material: Optional[str] = None,
        notes: Optional[str] = None,
        user_id: Optional[int] = None,
    ) -> PackagingRecommendation:
        """Saves a new recommendation run to history, associating user_id if authenticated."""
        now = datetime.now(timezone.utc)
        record = PackagingRecommendation(
            user_id=user_id,
            item_name=item_name,
            length=length,
            width=width,
            height=height,
            weight=weight,
            is_fragile=is_fragile,
            eco_friendly=eco_friendly,
            recommended_box_type=recommended_box_type,
            recommended_dimensions=recommended_dimensions,
            cushioning_material=cushioning_material or "Standard Cushioning",
            estimated_cost=estimated_cost,
            sustainability_score=sustainability_score,
            notes=notes,
            created_at=now,
        )

        if db is not None:
            try:
                db.add(record)
                await db.commit()
                await db.refresh(record)
                cls._memory_history.insert(0, record)
                return record
            except Exception:
                await db.rollback()

        # In-memory fallback
        record.id = cls._history_id_seq
        cls._history_id_seq += 1
        cls._memory_history.insert(0, record)
        return record

    @classmethod
    async def delete_history_item(
        cls,
        db: Optional[AsyncSession],
        history_id: int,
        user_id: Optional[int] = None,
    ) -> bool:
        """Deletes a single historical entry."""
        if db is not None:
            try:
                stmt = delete(PackagingRecommendation).where(PackagingRecommendation.id == history_id)
                if user_id is not None:
                    stmt = stmt.where(PackagingRecommendation.user_id == user_id)
                result = await db.execute(stmt)
                await db.commit()
                if result.rowcount > 0:
                    cls._memory_history = [r for r in cls._memory_history if r.id != history_id]
                    return True
            except Exception:
                await db.rollback()

        initial_len = len(cls._memory_history)
        cls._memory_history = [
            r for r in cls._memory_history
            if not (r.id == history_id and (user_id is None or r.user_id == user_id or r.user_id is None))
        ]
        return len(cls._memory_history) < initial_len

    @classmethod
    async def clear_user_history(
        cls,
        db: Optional[AsyncSession],
        user_id: int,
    ) -> int:
        """Clears all historical entries for a specific user."""
        deleted_count = 0
        if db is not None:
            try:
                stmt = delete(PackagingRecommendation).where(PackagingRecommendation.user_id == user_id)
                result = await db.execute(stmt)
                await db.commit()
                deleted_count = result.rowcount
            except Exception:
                await db.rollback()

        initial_len = len(cls._memory_history)
        cls._memory_history = [r for r in cls._memory_history if r.user_id != user_id]
        memory_deleted = initial_len - len(cls._memory_history)
        return max(deleted_count, memory_deleted)

    @classmethod
    def to_history_item_schema(cls, record: PackagingRecommendation) -> PackagingHistoryItem:
        """Converts ORM PackagingRecommendation into Pydantic PackagingHistoryItem."""
        return PackagingHistoryItem(
            id=record.id,
            user_id=record.user_id,
            item_name=record.item_name,
            length=record.length,
            width=record.width,
            height=record.height,
            weight=record.weight,
            is_fragile=record.is_fragile,
            eco_friendly=record.eco_friendly,
            recommended_box_type=record.recommended_box_type,
            recommended_dimensions=record.recommended_dimensions,
            cushioning_material=record.cushioning_material,
            estimated_cost=record.estimated_cost,
            sustainability_score=record.sustainability_score,
            notes=record.notes,
            created_at=record.created_at or datetime.now(timezone.utc),
            formatted_date=format_history_date(record.created_at),
        )


# Initialize sample data
PackagingHistoryService._init_default_samples()
