"""
Admin Dashboard & Data Governance Pydantic Schemas (Module 15).
Defines request and response schemas for Food Management, Packaging Material Management,
Scientific Rule Thresholds, Machine Learning Model Registry, Recommendations Audit, and Analytics.
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field


# ==========================================
# 1. Food Management Schemas
# ==========================================

class AdminFoodCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=255, description="Food commodity name (e.g., Alphonso Mango)")
    category: str = Field(..., min_length=2, max_length=100, description="Category taxonomy (e.g., Produce, Snacks, Bakery)")
    scientific_name: Optional[str] = Field(default=None, max_length=255, description="Botanical or scientific name")
    moisture: float = Field(..., ge=0.0, le=100.0, description="Moisture content percentage")
    ph: float = Field(..., ge=1.0, le=14.0, description="Acidity pH value")
    water_activity: Optional[float] = Field(default=None, ge=0.0, le=1.0, description="Water activity a_w")
    fat: float = Field(..., ge=0.0, le=100.0, description="Lipid/fat fraction in percentage")
    respiration_class: str = Field(default="Moderate", max_length=50, description="Respiration classification")
    oxygen_sensitivity: str = Field(default="Moderate", max_length=50, description="Oxygen vulnerability rating")
    moisture_sensitivity: str = Field(default="Moderate", max_length=50, description="Moisture sensitivity rating")


class AdminFoodUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=2, max_length=255)
    category: Optional[str] = Field(default=None, min_length=2, max_length=100)
    scientific_name: Optional[str] = Field(default=None, max_length=255)
    moisture: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    ph: Optional[float] = Field(default=None, ge=1.0, le=14.0)
    water_activity: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    fat: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    respiration_class: Optional[str] = Field(default=None, max_length=50)
    oxygen_sensitivity: Optional[str] = Field(default=None, max_length=50)
    moisture_sensitivity: Optional[str] = Field(default=None, max_length=50)


class AdminScientificPropertiesUpdate(BaseModel):
    moisture_sensitivity: Optional[str] = Field(default=None, max_length=50)
    equilibrium_rh_target_pct: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    respiration_class: Optional[str] = Field(default=None, max_length=50)
    respiration_rate_20c: Optional[float] = Field(default=None, ge=0.0)
    respiration_rate_5c: Optional[float] = Field(default=None, ge=0.0)
    respiratory_quotient: Optional[float] = Field(default=None, ge=0.1, le=3.0)
    oxygen_sensitivity: Optional[str] = Field(default=None, max_length=50)
    co2_sensitivity: Optional[str] = Field(default=None, max_length=50)
    max_tolerable_co2_pct: Optional[float] = Field(default=None, ge=0.0, le=50.0)
    ethylene_production_class: Optional[str] = Field(default=None, max_length=50)
    ethylene_prod_rate: Optional[float] = Field(default=None, ge=0.0)
    ethylene_sensitivity: Optional[str] = Field(default=None, max_length=50)
    perishability: Optional[str] = Field(default=None, max_length=50)
    optimum_temp_min_c: Optional[float] = Field(default=None, ge=-30.0, le=60.0)
    optimum_temp_max_c: Optional[float] = Field(default=None, ge=-30.0, le=60.0)
    chilling_injury_threshold_c: Optional[float] = Field(default=None, ge=-10.0, le=30.0)
    freezing_point_c: Optional[float] = Field(default=None, ge=-30.0, le=10.0)
    light_sensitivity: Optional[str] = Field(default=None, max_length=50)
    aroma_sensitivity: Optional[str] = Field(default=None, max_length=50)
    microbial_spoilage_vector: Optional[str] = Field(default=None, max_length=150)
    mechanical_sensitivity: Optional[str] = Field(default=None, max_length=50)
    ambient_shelf_life_days: Optional[int] = Field(default=None, ge=1)
    refrigerated_shelf_life_days: Optional[int] = Field(default=None, ge=1)
    controlled_atmosphere_shelf_life_days: Optional[int] = Field(default=None, ge=1)


class AdminFoodListItem(BaseModel):
    id: int
    name: str
    category: str
    scientific_name: Optional[str] = None
    moisture: Optional[float] = None
    ph: Optional[float] = None
    fat: Optional[float] = None
    water_activity: Optional[float] = None
    respiration_class: Optional[str] = None
    oxygen_sensitivity: Optional[str] = None
    moisture_sensitivity: Optional[str] = None
    has_scientific_properties: bool = True

    class Config:
        from_attributes = True


class AdminFoodDetailResponse(BaseModel):
    id: int
    name: str
    category: str
    scientific_name: Optional[str] = None
    moisture: Optional[float] = None
    ph: Optional[float] = None
    water_activity: Optional[float] = None
    fat: Optional[float] = None
    respiration_class: Optional[str] = None
    oxygen_sensitivity: Optional[str] = None
    moisture_sensitivity: Optional[str] = None
    scientific_properties: Optional[Dict[str, Any]] = None

    class Config:
        from_attributes = True


class AdminFoodListResponse(BaseModel):
    total_count: int
    items: List[AdminFoodListItem]


# ==========================================
# 2. Packaging Material Management Schemas
# ==========================================

class AdminMaterialCreate(BaseModel):
    material_id: str = Field(..., max_length=100, description="Unique material identifier code")
    name: str = Field(..., min_length=2, max_length=150, description="Commercial material name")
    category: str = Field(..., max_length=100, description="Category (Bio-Polymer, Mono-Polymer, Laminate)")
    polymer_family: str = Field(..., max_length=100, description="Standard ML polymer target family")
    structure: Optional[str] = Field(default="Monolayer", max_length=255)
    form_factor: str = Field(default="Flexible Pouch", max_length=100)
    thickness_microns: Optional[float] = Field(default=30.0, ge=1.0, le=1000.0)
    otr_cc_m2_day: Optional[float] = Field(default=None, ge=0.0)
    wvtr_g_m2_day: Optional[float] = Field(default=None, ge=0.0)
    co2_permeability: Optional[float] = Field(default=None, ge=0.0)
    selectivity_beta: Optional[float] = Field(default=None, ge=0.1, le=20.0)
    tensile_strength_mpa: Optional[float] = Field(default=None, ge=0.0)
    puncture_resistance_n: Optional[float] = Field(default=None, ge=0.0)
    elongation_pct: Optional[float] = Field(default=None, ge=0.0)
    optical_clarity: Optional[str] = Field(default="Translucent", max_length=100)
    temp_min_c: Optional[float] = Field(default=0.0, ge=-50.0, le=100.0)
    temp_max_c: Optional[float] = Field(default=40.0, ge=-50.0, le=250.0)
    thermal_class: Optional[str] = Field(default="Ambient Stable", max_length=100)
    sustainability_score: float = Field(..., ge=0.0, le=100.0)
    recyclability_score: float = Field(default=0.0, ge=0.0, le=100.0)
    biodegradability_score: float = Field(default=0.0, ge=0.0, le=100.0)
    resin_code: Optional[str] = Field(default=None, max_length=50)
    cost_category: Optional[str] = Field(default="Commercial Standard", max_length=50)
    estimated_unit_cost_inr: float = Field(..., ge=0.0, description="Estimated unit cost in INR")
    is_breathable: bool = False
    is_biodegradable: bool = False
    is_recyclable: bool = False
    is_retort_grade: bool = False
    is_cryogenic_grade: bool = False
    gas_flush_compatible: bool = False
    recommended_applications: Optional[str] = None
    notes: Optional[str] = None
    is_active_entry: bool = True


class AdminMaterialUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=2, max_length=150)
    category: Optional[str] = Field(default=None, max_length=100)
    polymer_family: Optional[str] = Field(default=None, max_length=100)
    structure: Optional[str] = Field(default=None, max_length=255)
    form_factor: Optional[str] = Field(default=None, max_length=100)
    thickness_microns: Optional[float] = Field(default=None, ge=1.0, le=1000.0)
    otr_cc_m2_day: Optional[float] = Field(default=None, ge=0.0)
    wvtr_g_m2_day: Optional[float] = Field(default=None, ge=0.0)
    co2_permeability: Optional[float] = Field(default=None, ge=0.0)
    selectivity_beta: Optional[float] = Field(default=None, ge=0.1, le=20.0)
    tensile_strength_mpa: Optional[float] = Field(default=None, ge=0.0)
    puncture_resistance_n: Optional[float] = Field(default=None, ge=0.0)
    optical_clarity: Optional[str] = Field(default=None, max_length=100)
    temp_min_c: Optional[float] = Field(default=None, ge=-50.0, le=100.0)
    temp_max_c: Optional[float] = Field(default=None, ge=-50.0, le=250.0)
    thermal_class: Optional[str] = Field(default=None, max_length=100)
    sustainability_score: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    recyclability_score: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    biodegradability_score: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    estimated_unit_cost_inr: Optional[float] = Field(default=None, ge=0.0)
    is_breathable: Optional[bool] = None
    is_biodegradable: Optional[bool] = None
    is_recyclable: Optional[bool] = None
    is_retort_grade: Optional[bool] = None
    is_cryogenic_grade: Optional[bool] = None
    gas_flush_compatible: Optional[bool] = None
    recommended_applications: Optional[str] = None
    notes: Optional[str] = None
    is_active_entry: Optional[bool] = None


class AdminMaterialResponse(BaseModel):
    id: int
    material_id: Optional[str] = None
    name: str
    category: Optional[str] = None
    polymer_family: Optional[str] = None
    structure: Optional[str] = None
    form_factor: Optional[str] = None
    thickness_microns: Optional[float] = None
    otr_cc_m2_day: Optional[float] = None
    wvtr_g_m2_day: Optional[float] = None
    co2_permeability: Optional[float] = None
    selectivity_beta: Optional[float] = None
    tensile_strength_mpa: Optional[float] = None
    puncture_resistance_n: Optional[float] = None
    optical_clarity: Optional[str] = None
    temp_min_c: Optional[float] = None
    temp_max_c: Optional[float] = None
    thermal_class: Optional[str] = None
    sustainability_score: Optional[float] = None
    recyclability_score: Optional[float] = None
    biodegradability_score: Optional[float] = None
    resin_code: Optional[str] = None
    cost_category: Optional[str] = None
    estimated_unit_cost_inr: Optional[float] = None
    is_breathable: bool = False
    is_biodegradable: bool = False
    is_recyclable: bool = False
    is_retort_grade: bool = False
    is_cryogenic_grade: bool = False
    gas_flush_compatible: bool = False
    recommended_applications: Optional[str] = None
    notes: Optional[str] = None
    is_active_entry: bool = True

    class Config:
        from_attributes = True


class AdminMaterialListResponse(BaseModel):
    total_count: int
    items: List[AdminMaterialResponse]


# ==========================================
# 3. Rules & Model Governance Schemas
# ==========================================

class RuleThresholdConfig(BaseModel):
    lipid_oxidation_fat_threshold_pct: float = Field(default=18.0, ge=0.0, le=100.0)
    high_respiration_moisture_threshold_pct: float = Field(default=75.0, ge=0.0, le=100.0)
    acidic_corrosion_ph_threshold: float = Field(default=4.6, ge=1.0, le=14.0)
    chilling_injury_buffer_c: float = Field(default=2.0, ge=0.0, le=10.0)
    gas_cushion_headspace_min_pct: float = Field(default=40.0, ge=0.0, le=100.0)
    gas_cushion_headspace_max_pct: float = Field(default=50.0, ge=0.0, le=100.0)
    eco_priority_multiplier: float = Field(default=1.35, ge=1.0, le=3.0)


class RuleThresholdUpdate(BaseModel):
    lipid_oxidation_fat_threshold_pct: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    high_respiration_moisture_threshold_pct: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    acidic_corrosion_ph_threshold: Optional[float] = Field(default=None, ge=1.0, le=14.0)
    chilling_injury_buffer_c: Optional[float] = Field(default=None, ge=0.0, le=10.0)
    gas_cushion_headspace_min_pct: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    gas_cushion_headspace_max_pct: Optional[float] = Field(default=None, ge=0.0, le=100.0)
    eco_priority_multiplier: Optional[float] = Field(default=None, ge=1.0, le=3.0)


class ModelRegistryResponse(BaseModel):
    active_model_name: str = "RandomForest-v2.3-18D"
    algorithm: str = "Random Forest Ensemble (100 Estimators)"
    feature_dimension: int = 18
    accuracy_score: float = 0.984
    is_ml_enabled: bool = True
    is_heuristic_fallback_active: bool = True
    last_trained_at: datetime
    version_tag: str = "v2.3.0-prod"


# ==========================================
# 4. Recommendations Audit Schemas
# ==========================================

class AdminRecommendationAuditItem(BaseModel):
    id: int
    user_id: Optional[int] = None
    user_email: Optional[str] = None
    item_name: str
    length: float
    width: float
    height: float
    weight: float
    is_fragile: bool
    eco_friendly: bool
    recommended_box_type: str
    recommended_dimensions: str
    cushioning_material: Optional[str] = None
    estimated_cost: float
    sustainability_score: float
    notes: Optional[str] = None
    created_at: datetime
    formatted_date: Optional[str] = None

    class Config:
        from_attributes = True


class AdminRecommendationAuditResponse(BaseModel):
    total_count: int
    items: List[AdminRecommendationAuditItem]


# ==========================================
# 5. System Analytics & Trend Schemas
# ==========================================

class FoodSearchStat(BaseModel):
    name: str
    category: str
    query_count: int
    share_pct: float


class MaterialRecommendStat(BaseModel):
    material_name: str
    polymer_family: str
    recommend_count: int
    share_pct: float
    average_score: float


class DailyUsageTrend(BaseModel):
    date: str  # YYYY-MM-DD
    total_analyses: int
    eco_analyses: int
    avg_sustainability_score: float
    avg_cost_inr: float


class AdminAnalyticsSummary(BaseModel):
    total_analyses: int
    total_users: int
    total_foods_count: int
    total_materials_count: int
    eco_preference_pct: float
    average_system_score: float
    top_foods: List[FoodSearchStat]
    top_materials: List[MaterialRecommendStat]
    trends: List[DailyUsageTrend]
