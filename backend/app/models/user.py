from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.db.session import Base

def _utcnow():
    return datetime.now(timezone.utc)

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(150), nullable=False)
    organization = Column(String(150), nullable=True)
    role = Column(String(100), default="Packaging Engineer")
    
    # Flags & Access Levels
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)
    
    # Custom Preferences (e.g., currency, eco priority, default batch size)
    preferences_json = Column(JSON, nullable=True, default=lambda: {
        "default_eco_priority": True,
        "default_currency": "INR",
        "default_batch_size": 10000,
    })
    
    created_at = Column(DateTime, default=_utcnow)
    updated_at = Column(DateTime, default=_utcnow, onupdate=_utcnow)

    # Relationships
    saved_analyses = relationship("SavedAnalysis", back_populates="user", cascade="all, delete-orphan")
    recommendations = relationship("PackagingRecommendation", back_populates="user")

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        if self.is_active is None:
            self.is_active = True
        if self.is_admin is None:
            self.is_admin = False
        if self.role is None:
            self.role = "Packaging Engineer"
        if self.preferences_json is None:
            self.preferences_json = {
                "default_eco_priority": True,
                "default_currency": "INR",
                "default_batch_size": 10000,
            }
        if self.created_at is None:
            self.created_at = _utcnow()
        if self.updated_at is None:
            self.updated_at = _utcnow()


class SavedAnalysis(Base):
    __tablename__ = "saved_analyses"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(255), nullable=False, index=True)
    notes = Column(Text, nullable=True)
    
    commodity_name = Column(String(255), nullable=False)
    recommended_material = Column(String(255), nullable=False)
    estimated_cost = Column(Float, nullable=False, default=0.0)
    sustainability_score = Column(Float, nullable=False, default=0.0)
    
    input_payload = Column(JSON, nullable=False)
    recommendation_result = Column(JSON, nullable=False)
    
    created_at = Column(DateTime, default=_utcnow)
    updated_at = Column(DateTime, default=_utcnow, onupdate=_utcnow)

    # Relationship
    user = relationship("User", back_populates="saved_analyses")

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        if self.estimated_cost is None:
            self.estimated_cost = 0.0
        if self.sustainability_score is None:
            self.sustainability_score = 0.0
        if self.created_at is None:
            self.created_at = _utcnow()
        if self.updated_at is None:
            self.updated_at = _utcnow()
