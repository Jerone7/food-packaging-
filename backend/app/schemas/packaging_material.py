"""
Pydantic Schemas for Module 6: Packaging Material Database.
Encodes the 12 standardized empirical property vectors, multi-parameter filters,
and side-by-side comparison matrices.
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any


class MaterialPropertyRadarSchema(BaseModel):
    barrier_score: float = Field(..., ge=0, le=100, description="Normalized 0-100 gas barrier protection score")
    mechanical_score: float = Field(..., ge=0, le=100, description="Normalized 0-100 tensile and puncture strength score")
    sustainability_score: float = Field(..., ge=0, le=100, description="0-100 environmental eco score")
    thermal_score: float = Field(..., ge=0, le=100, description="0-100 temperature resilience and range score")
    cost_efficiency_score: float = Field(..., ge=0, le=100, description="0-100 procurement cost efficiency score")
    optical_score: float = Field(..., ge=0, le=100, description="0-100 optical clarity or light barrier score")


class BarrierProfileDetailSchema(BaseModel):
    otr_cc_m2_day: float = Field(..., description="Oxygen Transmission Rate at 23°C, 0% RH (cc/m²/day)")
    wvtr_g_m2_day: float = Field(..., description="Water Vapor Transmission Rate at 38°C, 90% RH (g/m²/day)")
    co2_permeability: Optional[float] = Field(default=None, description="CO2 Permeability in cc/m²/day")
    selectivity_beta: Optional[float] = Field(default=None, description="CO2/O2 selectivity ratio (P_CO2 / P_O2)")
    thickness_microns: float = Field(..., description="Nominal gauge thickness in microns")
    barrier_tier: str = Field(..., description="Hermetic, Ultra-High, High, Moderate, Breathable")
    gas_flush_compatible: bool = Field(default=True, description="Compatible with N2/CO2 headspace flush")


class MechanicalProfileSchema(BaseModel):
    tensile_strength_mpa: float = Field(..., description="Tensile yield strength in MPa")
    puncture_resistance_n: float = Field(..., description="Puncture resistance force in Newtons")
    elongation_pct: Optional[float] = Field(default=100.0, description="Elongation at break %")
    form_factor: str = Field(..., description="Flexible Pouch, Film, Thermoformed Tray, Clamshell, Box, Jar, Can")
    durability_rating: str = Field(default="Moderate", description="High, Moderate, Rigid, Flexible")


class ThermalProfileSchema(BaseModel):
    temp_min_c: float = Field(..., description="Minimum operating temperature in °C")
    temp_max_c: float = Field(..., description="Maximum operating temperature in °C")
    thermal_class: str = Field(..., description="Cryogenic, Refrigerated, Ambient, Microwaveable, Retort")
    is_cryogenic_grade: bool = Field(default=False, description="Sub-zero embrittlement protection down to -30°C")
    is_retort_grade: bool = Field(default=False, description="Autoclave thermal sterilization compatibility (121°C)")


class OpticalProfileSchema(BaseModel):
    uv_transmittance_pct: Optional[float] = Field(default=20.0, description="UV transmission percentage (200-400nm)")
    optical_clarity: str = Field(..., description="Crystal Clear, Translucent, Opaque, Amber Tinted")
    light_barrier_rating: str = Field(default="Moderate", description="Total Block, High Shield, Moderate, Clear")


class EnvironmentalProfileSchema(BaseModel):
    sustainability_score: float = Field(..., ge=0, le=100, description="Overall eco-score (0-100)")
    recyclability_score: float = Field(default=0.0, ge=0, le=100, description="Recyclability index (0-100)")
    biodegradability_score: float = Field(default=0.0, ge=0, le=100, description="Biodegradability index (0-100)")
    is_biodegradable: bool = Field(default=False, description="Naturally biodegradable / compostable")
    is_recyclable: bool = Field(default=False, description="Curbside mechanically recyclable")
    resin_code: Optional[str] = Field(default="OTHER_7", description="Resin identification code (RIC #1-#7, PAP, GL, ALU)")
    composting_standard: Optional[str] = Field(default=None, description="EN 13432, ASTM D6400, NF T51-800")


class EconomicProfileSchema(BaseModel):
    cost_category: str = Field(..., description="Budget Economy, Commercial Standard, Premium Barrier, High-Tech")
    estimated_unit_cost_inr: float = Field(..., gt=0, description="Standard unit cost in INR")
    market_scalability: str = Field(default="High", description="Industrial availability and supply chain maturity")


class PackagingMaterialDetailResponse(BaseModel):
    id: Optional[int] = Field(default=None, description="Database unique ID")
    material_id: str = Field(..., description="Unique technical identifier (e.g. mat_bio_emap_01)")
    name: str = Field(..., description="Commercial and technical polymer name")
    category: str = Field(..., description="Domain category (Biodegradable, Conventional, Laminate, etc.)")
    polymer_family: str = Field(..., description="Polymer family code")
    structure: str = Field(..., description="Layer specification")
    form_factor: str = Field(default="Flexible Pouch", description="Form factor")
    barrier_profile: BarrierProfileDetailSchema
    mechanical_profile: MechanicalProfileSchema
    thermal_profile: ThermalProfileSchema
    optical_profile: OpticalProfileSchema
    environmental_profile: EnvironmentalProfileSchema
    economic_profile: EconomicProfileSchema
    functional_flags: Dict[str, bool] = Field(
        default_factory=dict,
        description="is_breathable, is_biodegradable, is_recyclable, is_retort_grade, is_cryogenic_grade, gas_flush_compatible"
    )
    recommended_applications: List[str] = Field(default_factory=list)
    regulatory_certifications: List[str] = Field(default_factory=list)
    radar_scores: MaterialPropertyRadarSchema
    notes: str = Field(default="")
    is_active_entry: bool = Field(default=True)

    class Config:
        from_attributes = True


class MaterialFilterParams(BaseModel):
    search: Optional[str] = Field(None, description="Text search across name, category, and structure")
    category: Optional[str] = Field(None, description="Filter by domain category")
    polymer_family: Optional[str] = Field(None, description="Filter by polymer family code")
    max_otr: Optional[float] = Field(None, ge=0, description="Maximum OTR upper bound (cc/m²/day)")
    max_wvtr: Optional[float] = Field(None, ge=0, description="Maximum WVTR upper bound (g/m²/day)")
    min_sustainability: Optional[float] = Field(None, ge=0, le=100, description="Minimum sustainability score")
    is_biodegradable: Optional[bool] = Field(None, description="Filter for biodegradable materials")
    is_recyclable: Optional[bool] = Field(None, description="Filter for recyclable materials")
    is_cryogenic: Optional[bool] = Field(None, description="Filter for sub-zero cryogenic materials")
    is_retort: Optional[bool] = Field(None, description="Filter for retort autoclave materials")
    cost_tier: Optional[str] = Field(None, description="Budget Economy, Commercial Standard, Premium Barrier, High-Tech")
    sort_by: Optional[str] = Field("sustainability_score", description="Sort field")
    sort_order: Optional[str] = Field("desc", description="asc or desc")
    limit: int = Field(50, ge=1, le=100)
    offset: int = Field(0, ge=0)


class CreatePackagingMaterialInput(BaseModel):
    material_id: Optional[str] = Field(default=None, description="Optional unique identifier (e.g. mat_custom_bio_01)")
    name: str = Field(..., min_length=2, description="Material technical name")
    category: str = Field(..., description="Category domain (e.g. Biodegradable Bio-Polymer, Conventional Polymer)")
    polymer_family: str = Field(..., description="Polymer family class identifier")
    structure: str = Field(..., description="Layer structure specification")
    form_factor: Optional[str] = Field(default="Flexible Pouch", description="Form factor")
    thickness_microns: float = Field(..., gt=0, description="Nominal thickness in microns")
    otr_cc_m2_day: float = Field(..., ge=0, description="Oxygen Transmission Rate at 23°C, 0% RH")
    wvtr_g_m2_day: float = Field(..., ge=0, description="Water Vapor Transmission Rate at 38°C, 90% RH")
    co2_permeability: Optional[float] = Field(default=None, description="CO2 Permeability in cc/m²/day")
    selectivity_beta: Optional[float] = Field(default=None, description="CO2/O2 selectivity ratio")
    tensile_strength_mpa: float = Field(..., ge=0, description="Tensile strength in MPa")
    puncture_resistance_n: float = Field(..., ge=0, description="Puncture resistance in N")
    elongation_pct: Optional[float] = Field(default=100.0, description="Elongation at break %")
    uv_transmittance_pct: Optional[float] = Field(default=10.0, description="UV transmittance %")
    optical_clarity: Optional[str] = Field(default="Translucent", description="Crystal Clear, Translucent, Opaque")
    temp_min_c: float = Field(default=-10.0, description="Minimum operating temperature in °C")
    temp_max_c: float = Field(default=70.0, description="Maximum operating temperature in °C")
    thermal_class: Optional[str] = Field(default="Ambient", description="Thermal class")
    sustainability_score: float = Field(..., ge=0, le=100, description="Sustainability score (0-100)")
    recyclability_score: Optional[float] = Field(default=0.0, ge=0, le=100, description="Recyclability index (0-100)")
    biodegradability_score: Optional[float] = Field(default=0.0, ge=0, le=100, description="Biodegradability index (0-100)")
    resin_code: Optional[str] = Field(default="OTHER_7", description="Resin code")
    composting_standard: Optional[str] = Field(default=None, description="EN 13432, ASTM D6400, etc.")
    cost_category: Optional[str] = Field(default="Commercial Standard", description="Cost tier")
    estimated_unit_cost_inr: float = Field(..., gt=0, description="Standard unit cost in INR")
    is_breathable: bool = Field(default=False)
    is_biodegradable: bool = Field(default=False)
    is_recyclable: bool = Field(default=False)
    is_retort_grade: bool = Field(default=False)
    is_cryogenic_grade: bool = Field(default=False)
    gas_flush_compatible: bool = Field(default=True)
    recommended_applications: List[str] = Field(default_factory=list)
    regulatory_certifications: List[str] = Field(default_factory=list)
    notes: Optional[str] = Field(default="", description="Technical notes")


class MaterialComparisonRequest(BaseModel):
    material_ids: List[str] = Field(..., min_length=2, max_length=4, description="List of 2 to 4 material identifiers to compare")


class MaterialComparisonItemSchema(BaseModel):
    material: PackagingMaterialDetailResponse
    radar_scores: MaterialPropertyRadarSchema
    key_strengths: List[str]
    trade_offs: List[str]


class MaterialComparisonResponse(BaseModel):
    comparison_id: Optional[str] = Field(default=None)
    materials_count: Optional[int] = Field(default=0)
    materials: List[PackagingMaterialDetailResponse] = Field(default_factory=list)
    radar_datasets: Dict[str, MaterialPropertyRadarSchema] = Field(default_factory=dict)
    trade_off_analysis: List[str] = Field(default_factory=list)
    best_in_class_highlights: Dict[str, str] = Field(default_factory=dict)
    items: Optional[List[MaterialComparisonItemSchema]] = Field(default_factory=list)
    comparison_matrix: Optional[Dict[str, Dict[str, Any]]] = Field(default_factory=dict)
    recommendation_summary: Optional[str] = Field(default="")


class MaterialCategorySummaryResponse(BaseModel):
    category: str
    count: int
    sample_materials: List[str]
    average_sustainability: float
    description: str


# ==========================================
# Module 9: 3-Material Packaging Comparison Schemas
# ==========================================

class ComparisonParameterRow(BaseModel):
    parameter_key: str = Field(..., description="Unique key, e.g. moisture_barrier, oxygen_barrier, gas_exchange, strength, recyclability, cost_category")
    parameter_label: str = Field(..., description="Display label, e.g. Moisture Barrier, Oxygen Barrier")
    parameter_group: str = Field(..., description="Barrier Performance, Respiration & Atmosphere, Mechanical Performance, Environmental Circularity, Economic Profile")
    unit: Optional[str] = Field(None, description="Physical engineering unit (e.g. g/m²/day, cc/m²/day, MPa, ₹)")
    values: Dict[str, str] = Field(..., description="Map of slotId ('material_a', 'material_b', 'material_c') -> Qualitative/Formatted Value")
    raw_numeric_values: Optional[Dict[str, float]] = Field(default=None, description="Numeric values for charts/bars")
    best_slot_id: Optional[str] = Field(None, description="Slot ID of the best performing material for this parameter")
    scientific_note: Optional[str] = Field(None, description="Explanation of test conditions or trade-off")


class MaterialComparisonSlotDetail(BaseModel):
    slot_id: str = Field(..., description="'material_a', 'material_b', 'material_c'")
    material_id: str = Field(..., description="Unique material ID, e.g. mat_pla_emap_01")
    name: str = Field(..., description="Full polymer/substrate commercial name")
    category: str = Field(..., description="Category: Biodegradable, Conventional, Laminate, Specialty")
    polymer_family: str = Field(..., description="Family code, e.g. BIO_PLA, POLYOLEFIN_LDPE")
    structure: str = Field(..., description="Layer specification")
    color_token: str = Field(default="#0D9488", description="UI accent color (#0D9488 Teal, #0284C7 Sky, #D97706 Amber)")
    is_primary_recommendation: bool = Field(default=False)
    
    # 6 Standard Comparison Core Values
    moisture_barrier: str = Field(..., description="'High', 'Medium', 'Low', 'Hermetic'")
    oxygen_barrier: str = Field(..., description="'High', 'Medium', 'Low', 'Hermetic'")
    gas_exchange: str = Field(..., description="'High', 'Medium', 'Low', 'Controlled'")
    strength: str = Field(..., description="'High', 'Medium', 'Low', 'Rigid'")
    recyclability: str = Field(..., description="'Yes', 'No', 'Biodegradable', 'Home Compostable'")
    cost_category: str = Field(..., description="'Low', 'Medium', 'High', 'Premium'")
    
    # Quantitative specs
    wvtr_value: float = Field(..., description="WVTR in g/m²/day")
    otr_value: float = Field(..., description="OTR in cc/m²/day")
    tensile_strength_mpa: float = Field(..., description="Tensile strength in MPa")
    estimated_cost_inr: float = Field(..., description="Unit cost in ₹")
    sustainability_score: float = Field(..., description="Eco score 0-100")
    
    # Food context (if provided)
    suitability_score: Optional[float] = Field(None, description="0.00-1.00 compatibility score")
    suitability_category: Optional[str] = Field(None, description="'Optimal Match', 'High Compatibility'")
    star_rating: Optional[int] = Field(None, description="1-5 integer rating")


class PackagingComparisonRequest(BaseModel):
    material_ids: List[str] = Field(..., min_length=2, max_length=3, description="List of 2 or 3 material IDs to compare")
    food_id: Optional[int] = Field(None, description="Optional food commodity ID to provide food-specific context")
    food_name: Optional[str] = Field(None, description="Optional food name string")


class PackagingComparisonMatrixResponse(BaseModel):
    comparison_id: str = Field(..., description="Unique comparison identifier")
    food_context_name: Optional[str] = Field(None, description="Food item context if provided")
    slots: List[MaterialComparisonSlotDetail] = Field(..., description="List of up to 3 materials compared")
    parameter_rows: List[ComparisonParameterRow] = Field(..., description="Structured comparison rows")
    best_in_class_summary: Dict[str, str] = Field(..., description="Parameter -> Best material name")
    ai_trade_off_synthesis: str = Field(..., description="Clear natural language trade-off narrative")
    key_recommendation_rule: str = Field(..., description="Guidance rule for when to choose which material")
