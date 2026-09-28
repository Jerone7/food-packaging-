from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, Text, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from app.db.session import Base

class PackagingRecommendation(Base):
    __tablename__ = "packaging_recommendations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    item_name = Column(String(255), nullable=False, index=True)
    length = Column(Float, nullable=False)   # in cm
    width = Column(Float, nullable=False)    # in cm
    height = Column(Float, nullable=False)   # in cm
    weight = Column(Float, nullable=False)   # in kg
    is_fragile = Column(Boolean, default=False)
    eco_friendly = Column(Boolean, default=True)
    
    # Recommended results
    recommended_box_type = Column(String(100), nullable=False)
    recommended_dimensions = Column(String(100), nullable=False)
    cushioning_material = Column(String(150), nullable=False)
    estimated_cost = Column(Float, nullable=False)
    sustainability_score = Column(Float, nullable=False) # 1-100
    notes = Column(Text, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationship
    user = relationship("User", back_populates="recommendations")

