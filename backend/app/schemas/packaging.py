"""
Pydantic Schemas for Packaging Recommendation Engine (Module 5).
Defines comprehensive data contracts for hybrid recommendation requests and responses.
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime


class BarrierProfileSchema(BaseModel):
    otr: str = Field(..., description="Oxygen transmission rate formatted with units")
    wvtr: str = Field(..., description="Water vapor transmission rate formatted with units")
    thickness_microns: float = Field(..., description="Film or sheet thickness in microns")
    tensile_strength_mpa: float = Field(..., description="Ultimate tensile strength in MPa")
    puncture_resistance_n: float = Field(..., description="Puncture resistance in Newtons")


class PrimaryRecommendationSchema(BaseModel):
    material_name: str
    material_type: str
    polymer_family: str
    structure: str
    barrier_profile: BarrierProfileSchema
    sustainability_score: float = Field(..., ge=0, le=100)
    estimated_unit_cost_inr: float = Field(..., gt=0)
    suitability_score: float = Field(..., ge=0, le=1.0)
    active_additives: List[str] = Field(default_factory=list)
    
    # Explainable Recommendation Fields (Module 5 Result Page)
    packaging_title: str = Field(
        default="Ventilated Food-Grade Packaging",
        description="Headline packaging format (e.g. Ventilated Food-Grade Packaging)"
    )
    packaging_format: str = Field(
        default="Micro-Perforated Hinged Clamshell",
        description="Physical structural format (e.g. Vented Hinged Clamshell, Nitrogen-Flushed Pouch)"
    )
    recommendation_explanation: str = Field(
        default="This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.",
        description="Explainable natural language rationale explaining why this option was chosen"
    )
    advantages: List[str] = Field(
        default_factory=list,
        description="Preservation benefits and operational strengths"
    )
    limitations: List[str] = Field(
        default_factory=list,
        description="Technical constraints and operational boundaries"
    )
    suitable_storage_condition: str = Field(
        default="Cold Storage (10-12°C, 90-95% RH)",
        description="Target storage condition and environmental thresholds"
    )
    expected_application: str = Field(
        default="High-respiration fresh produce, cut fruits, cherry tomatoes",
        description="Best-suited food commodity applications"
    )
    important_properties: Dict[str, str] = Field(
        default_factory=dict,
        description="Formatted key technical properties (OTR, WVTR, Breathability, Thermal Range, Tensile)"
    )


from enum import Enum


class SuitabilityCategoryEnum(str, Enum):
    OPTIMAL_MATCH = "Optimal Match"
    HIGH_COMPATIBILITY = "High Compatibility"
    MODERATE_COMPATIBILITY = "Moderate Compatibility"
    CONDITIONAL_ALTERNATIVE = "Conditional Alternative"


class AlternativeTypeEnum(str, Enum):
    ECO_FRIENDLY = "ECO_FRIENDLY"
    ECONOMY = "ECONOMY"
    HIGH_BARRIER = "HIGH_BARRIER"
    SPECIALTY_CIRCULAR = "SPECIALTY_CIRCULAR"


class MaterialCharacteristicsSchema(BaseModel):
    otr: str = Field(default="< 1200 cc/m²/day", description="Oxygen transmission rate with engineering units")
    wvtr: str = Field(default="25.0 g/m²/day", description="Water vapor transmission rate with units")
    thickness_microns: float = Field(default=25.0, description="Material thickness in µm")
    tensile_strength_mpa: float = Field(default=35.0, description="Tensile burst resistance in MPa")
    thermal_range: str = Field(default="-10°C to 70°C", description="Operational temperature span")
    sustainability_rating: str = Field(default="100% Home Compostable", description="Descriptive eco-classification")
    estimated_cost_inr: float = Field(default=3.50, description="Cost per unit in INR (₹)")
    cost_tier: str = Field(default="Moderate (₹₹)", description="Low (₹), Moderate (₹₹), Premium (₹₹₹)")


class PackagingAlternativeSchema(BaseModel):
    candidate_id: str = Field(default="mat_alt_candidate", description="Unique material candidate ID")
    type: str = Field(..., description="ECO_FRIENDLY | ECONOMY | HIGH_BARRIER | SPECIALTY_CIRCULAR")
    material_name: str
    packaging_title: str = Field(default="Alternative Packaging Format", description="User-facing descriptive format title")
    
    # 1. Star Rating & Descriptive Classification
    star_rating: int = Field(default=4, ge=1, le=5, description="1 to 5 integer rating (5 = ★★★★★, 4 = ★★★★☆, 3 = ★★★☆☆)")
    star_display: str = Field(default="★★★★☆", description="Unicode star string")
    suitability_category: SuitabilityCategoryEnum = Field(default=SuitabilityCategoryEnum.HIGH_COMPATIBILITY, description="Descriptive compatibility level")
    
    # 2. Model-Derived Match Probability (Properly Labeled)
    model_derived_probability: float = Field(
        default=0.85, ge=0.0, le=1.0, 
        description="MCDA/TOPSIS algorithmic closeness score (0.00 to 1.00), labeled as model-derived"
    )
    compatibility_confidence: str = Field(
        default="High Confidence (0.85)", description="Confidence label"
    )
    
    # 3. Relevant Characteristics
    characteristics: MaterialCharacteristicsSchema = Field(default_factory=MaterialCharacteristicsSchema)
    
    # 4. Objective Trade-Off Rationale
    trade_off_summary: str = Field(..., description="Crisp explanation of benefits vs sacrifices")
    advantages: List[str] = Field(default_factory=list, description="Preservation and operational advantages")
    limitations: List[str] = Field(default_factory=list, description="Technical boundaries and operational limits")
    
    # 5. Delta Highlights Compared to Primary
    cost_delta_pct: float = Field(default=0.0, description="Percentage cost difference relative to primary (+15% or -30%)")
    eco_delta_pct: float = Field(default=0.0, description="Percentage sustainability difference relative to primary")
    shelf_life_delta: str = Field(default="Equal", description="Shelf-life impact relative to primary")

    # Backward compatibility fields
    sustainability_score: Optional[float] = Field(default=80.0, ge=0, le=100)
    estimated_unit_cost_inr: Optional[float] = Field(default=3.50, gt=0)


class BoxGeometrySchema(BaseModel):
    length_cm: float
    width_cm: float
    height_cm: float
    total_volume_cm3: float
    space_utilization_pct: float
    cushioning_material: str


class ScientificRationaleSchema(BaseModel):
    summary: str
    key_drivers: List[str]


class PackagingInput(BaseModel):
    food_id: Optional[int] = Field(default=None, description="Database ID of commodity if available")
    item_name: Optional[str] = Field(default="Fresh Commodity", example="Fresh Tomato")
    food_name: Optional[str] = Field(default=None, example="Fresh Tomato")
    category: Optional[str] = Field(default=None, description="Food category (e.g. Fruits, Vegetables, Meat)")
    quantity: Optional[float] = Field(default=None, gt=0, description="Batch quantity in kg")
    weight: Optional[float] = Field(default=5.0, gt=0, description="Weight in kg (alias for quantity)")
    unit: Optional[str] = Field(default="kg", description="Unit of measurement")
    
    length: Optional[float] = Field(default=20.0, gt=0, description="Length in cm")
    width: Optional[float] = Field(default=15.0, gt=0, description="Width in cm")
    height: Optional[float] = Field(default=10.0, gt=0, description="Height in cm")
    
    is_fragile: bool = Field(default=False, description="Whether the item is fragile/bruising sensitive")
    eco_friendly: bool = Field(default=True, description="Prioritize sustainable materials")
    eco_friendly_priority: Optional[bool] = Field(default=None, description="Explicit eco priority flag")
    
    moisture: Optional[float] = Field(default=None, description="Moisture content percentage")
    fat: Optional[float] = Field(default=None, description="Fat content percentage")
    ph: Optional[float] = Field(default=None, description="pH level")
    water_activity: Optional[float] = Field(default=None, description="Water activity a_w")
    respiration_class: Optional[str] = Field(default=None, description="Respiration level class")
    respiration_rate_20c: Optional[float] = Field(default=None, description="mg CO2/kg/h at 20°C")
    ethylene_sensitivity: Optional[str] = Field(default=None, description="Ethylene sensitivity level")
    chilling_injury_threshold_c: Optional[float] = Field(default=None, description="Chilling injury threshold °C")
    
    storage_condition: Optional[str] = Field(default=None, description="Target storage condition (e.g. ambient, refrigerated, frozen)")
    storage_temp_c: Optional[float] = Field(default=None, description="Explicit storage temperature in °C")
    storage_duration_days: Optional[int] = Field(default=None, description="Storage duration in days")
    duration: Optional[int] = Field(default=14, description="Duration in days")
    duration_unit: Optional[str] = Field(default="days", description="Duration unit")
    transport_mode: Optional[str] = Field(default=None, description="Transport logistics mode")
    custom_overrides: Optional[Dict[str, Any]] = Field(default=None, description="Custom biochemical trait overrides")


class PackagingRecommendationResult(BaseModel):
    recommendation_id: str = Field(default="rec_legacy")
    primary_recommendation: Optional[PrimaryRecommendationSchema] = None
    alternatives: List[PackagingAlternativeSchema] = Field(default_factory=list)
    box_geometry: Optional[BoxGeometrySchema] = None
    scientific_rationale: Optional[ScientificRationaleSchema] = None
    comparison_summary: Optional[Dict[str, Any]] = Field(
        default=None, description="Multi-candidate comparative matrix breakdown"
    )
    
    # Legacy backward compatibility fields
    recommended_box_type: str = "Optimized Packaging"
    recommended_dimensions: str = "25.0 x 15.0 x 12.0 cm"
    box_volume_cm3: float = 4500.0
    item_volume_cm3: float = 3500.0
    space_utilization_pct: float = 75.0
    cushioning_material: str = "Recycled Shredded Kraft Paper"
    estimated_cost: float = 3.50
    sustainability_score: float = 85.0
    notes: Optional[str] = None

    def model_post_init(self, __context: Any) -> None:
        if self.primary_recommendation is None:
            self.primary_recommendation = PrimaryRecommendationSchema(
                material_name=self.recommended_box_type,
                material_type="Optimized Polymer",
                polymer_family="RECYCLABLE_POLYOLEFIN",
                structure="Standard Structure",
                barrier_profile=BarrierProfileSchema(
                    otr="< 10 cc/m²/day",
                    wvtr="< 3.0 g/m²/day",
                    thickness_microns=25.0,
                    tensile_strength_mpa=30.0,
                    puncture_resistance_n=20.0,
                ),
                sustainability_score=self.sustainability_score,
                estimated_unit_cost_inr=self.estimated_cost,
                suitability_score=0.90,
                active_additives=[],
            )
        if self.box_geometry is None:
            self.box_geometry = BoxGeometrySchema(
                length_cm=25.0,
                width_cm=15.0,
                height_cm=12.0,
                total_volume_cm3=self.box_volume_cm3,
                space_utilization_pct=self.space_utilization_pct,
                cushioning_material=self.cushioning_material,
            )
        if self.scientific_rationale is None:
            self.scientific_rationale = ScientificRationaleSchema(
                summary=self.notes or "Optimized packaging prescription.",
                key_drivers=[],
            )


def format_history_date(dt: Optional[datetime]) -> str:
    """Format datetime into standard 'dd MMM yyyy' display string (e.g. '26 Sep 2026')."""
    if dt is None:
        return ""
    return dt.strftime("%d %b %Y")


class PackagingHistoryItem(BaseModel):
    id: int
    user_id: Optional[int] = Field(default=None, description="Owner user ID if authenticated")
    item_name: str
    length: float
    width: float
    height: float
    weight: float
    is_fragile: bool = False
    eco_friendly: bool = False
    recommended_box_type: str
    recommended_dimensions: str
    box_volume_cm3: Optional[float] = 0.0
    item_volume_cm3: Optional[float] = 0.0
    space_utilization_pct: Optional[float] = 0.0
    cushioning_material: Optional[str] = None
    estimated_cost: float
    sustainability_score: float
    notes: Optional[str] = None
    created_at: datetime
    formatted_date: Optional[str] = Field(
        default=None,
        description="Formatted human-readable date e.g. '26 Sep 2026'"
    )

    class Config:
        from_attributes = True

    def model_post_init(self, __context: Any) -> None:
        if self.formatted_date is None and self.created_at is not None:
            self.formatted_date = format_history_date(self.created_at)


class UserHistoryResponse(BaseModel):
    total_count: int
    records: List[PackagingHistoryItem] = Field(default_factory=list)

    class Config:
        from_attributes = True


class PackagingRecordResponse(PackagingHistoryItem):
    """Backward-compatible alias for PackagingHistoryItem."""
    pass


# Re-export Module 9 schemas for unified packaging import
from app.schemas.packaging_material import (
    ComparisonParameterRow,
    MaterialComparisonSlotDetail,
    PackagingComparisonRequest,
    PackagingComparisonMatrixResponse,
)


