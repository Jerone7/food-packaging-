"""
Multilingual Pydantic Schemas for Food Commodities and Packaging Materials.
(Module 22: Multi-Language Support).
"""

from typing import List, Optional, Union
from pydantic import BaseModel, Field


class FoodCommodityLocalized(BaseModel):
    """
    Standard localized food commodity representation.
    Returns the culturally localized vernacular name, spoilage vector,
    and storage guidance according to client Accept-Language.
    """
    id: Union[int, str]
    name: str = Field(..., description="Localized display name according to active locale")
    name_en: str = Field(..., description="Canonical English name")
    name_ta: Optional[str] = Field(default=None, description="Vernacular Tamil name")
    name_hi: Optional[str] = Field(default=None, description="Vernacular Hindi name")
    category: str = Field(..., description="Food commodity category")
    scientific_name: Optional[str] = Field(default=None, description="Botanical or biological name")
    moisture_content_percent: float = Field(..., description="Moisture content %")
    water_activity: float = Field(..., description="Water activity a_w")
    respiration_rate_mg_co2_kg_h: Optional[float] = Field(default=None, description="Respiration rate mg CO2/kg/h")
    spoilage_vector: str = Field(..., description="Localized degradation and vulnerability explanation")
    storage_recommendation: str = Field(..., description="Localized vernacular storage guidance")


class PackagingMaterialLocalized(BaseModel):
    """
    Standard localized packaging material representation.
    """
    material_id: str
    name: str = Field(..., description="Localized display name")
    name_en: str
    name_ta: Optional[str] = None
    name_hi: Optional[str] = None
    category: str
    description: str = Field(..., description="Localized vernacular material overview")
    otr: str = Field(..., description="Oxygen transmission rate")
    wvtr: str = Field(..., description="Water vapor transmission rate")
    recommended_applications: List[str] = Field(default_factory=list)
    sustainability_score: Optional[float] = None
    is_biodegradable: bool = False
    is_recyclable: bool = False


class LocalizedCategoryResponse(BaseModel):
    """
    Localized category descriptor for navigation and filter chips.
    """
    category: str
    name: str
    description: str
    icon: Optional[str] = None
    color: Optional[str] = None
    sample_items: List[str] = Field(default_factory=list)
