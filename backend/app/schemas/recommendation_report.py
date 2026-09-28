"""
Pydantic v2 Schemas for Module 12: Recommendation Report & Multi-Format Export Engine.
Provides comprehensive type validation, schemas for food context, degradation properties,
prescribed barrier specifications, LCA profiles, converter costing, and export metadata.
"""

from typing import List, Optional, Dict, Any
from datetime import datetime, timezone
from pydantic import BaseModel, Field, ConfigDict


class ReportFoodContext(BaseModel):
    """Commodity and operational packaging context."""
    model_config = ConfigDict(extra="ignore")

    name: str = Field(..., description="Food commodity name (e.g. Roasted Coffee Beans)")
    category: str = Field("General Food", description="Food category (e.g. Beverages, Produce, Bakery)")
    scientific_name: Optional[str] = Field(None, description="Botanical or scientific taxonomy name")
    fill_quantity: str = Field("500g", description="Product fill weight or volume per unit pack")
    batch_size_units: int = Field(10000, ge=1, description="Target production batch volume in units")
    storage_condition: str = Field("Ambient Standard", description="Recommended storage condition")
    storage_temp_c: Optional[float] = Field(None, description="Recommended storage temperature in °C")
    storage_duration_days: int = Field(180, ge=1, description="Target shelf-life duration in days")
    transport_mode: Optional[str] = Field("Ambient Standard Logistics", description="Supply chain transport mode")


class ReportFoodProperties(BaseModel):
    """Biochemical food degradation characteristics and sensitivities."""
    model_config = ConfigDict(extra="ignore")

    moisture_pct: Optional[float] = Field(None, ge=0.0, le=100.0, description="Moisture percentage (%)")
    water_activity_aw: Optional[float] = Field(None, ge=0.0, le=1.0, description="Water activity aw (0.00 - 1.00)")
    ph_level: Optional[float] = Field(None, ge=0.0, le=14.0, description="pH level (0.0 - 14.0)")
    fat_pct: Optional[float] = Field(None, ge=0.0, le=100.0, description="Lipid / Fat percentage (%)")
    respiration_class: Optional[str] = Field(None, description="Respiration rate category (Very Low to Extremely High)")
    respiration_rate_20c: Optional[float] = Field(None, ge=0.0, description="Respiration rate at 20°C in mg CO2/kg-hr")
    oxygen_sensitivity: str = Field("Moderate", description="Oxygen degradation sensitivity level")
    moisture_sensitivity: str = Field("Moderate", description="Moisture gain/loss sensitivity level")
    ethylene_sensitivity: Optional[str] = Field(None, description="Ethylene gas sensitivity")
    chilling_injury_threshold_c: Optional[float] = Field(None, description="Chilling injury critical temperature in °C")


class ReportPrimaryPrescription(BaseModel):
    """Primary prescribed packaging formulation and barrier specifications."""
    model_config = ConfigDict(extra="ignore")

    material_name: str = Field(..., description="Commercial packaging material name")
    material_type: str = Field("Polymer Substrate", description="Material classification type")
    polymer_family: str = Field("MULTILAYER_BARRIER_COEX", description="Polymer resin family identifier")
    structure: str = Field("Monomaterial / Barrier Coex", description="Lamination / film layer structure")
    package_format: str = Field("Stand-up Doypack (Bottom Gusset)", description="Recommended package format")
    dimensions: str = Field("18.0 x 12.0 x 4.0 cm", description="Package dimensions L x W x H/G in cm")
    thickness_microns: float = Field(50.0, gt=0.0, description="Total barrier gauge thickness in microns")
    otr: str = Field("< 10.0 cc/m²/day", description="Oxygen Transmission Rate with units")
    wvtr: str = Field("< 3.0 g/m²/day", description="Water Vapor Transmission Rate with units")
    tensile_strength_mpa: float = Field(35.0, ge=0.0, description="Tensile strength in MPa")
    puncture_resistance_n: float = Field(22.0, ge=0.0, description="Puncture resistance in Newtons")
    suitability_score: float = Field(0.90, ge=0.0, le=1.0, description="Overall compatibility score (0.0 - 1.0)")
    sustainability_score: float = Field(85.0, ge=0.0, le=100.0, description="Baseline sustainability rating")
    estimated_unit_cost_inr: float = Field(3.50, ge=0.0, description="Estimated base cost per pack in INR")
    advantages: List[str] = Field(default_factory=list, description="Key operational and barrier advantages")
    limitations: List[str] = Field(default_factory=list, description="Processing boundaries and limitations")
    important_properties: Dict[str, str] = Field(default_factory=dict, description="Key technical property map")


class ReportAlternativePackaging(BaseModel):
    """Comparative alternative packaging option across trade-off tiers."""
    model_config = ConfigDict(extra="ignore")

    tier_name: str = Field(..., description="Alternative tier (Eco-Champion, Economy, High-Barrier)")
    material_name: str = Field(..., description="Alternative material name")
    packaging_title: str = Field("Alternative Formulation", description="Packaging title display")
    key_tradeoff: str = Field(..., description="Summary of comparative trade-offs")
    cost_delta_pct: float = Field(0.0, description="Cost difference percentage vs primary prescription")
    eco_delta_pct: float = Field(0.0, description="Eco score delta percentage vs primary prescription")
    shelf_life_delta: str = Field("Comparable shelf life", description="Impact on product shelf life")
    star_rating: int = Field(4, ge=1, le=5, description="Compatibility star rating (1 - 5)")


class ReportLcaSummary(BaseModel):
    """Life Cycle Assessment (LCA) environmental profile summary."""
    model_config = ConfigDict(extra="ignore")

    recyclability_tier: str = Field("High", description="Recyclability classification tier")
    resin_identification_code: str = Field("RIC 4 (LDPE)", description="Resin Identification Code")
    biodegradability_standard: Optional[str] = Field(None, description="Certified composting standard")
    reusability_cycles: int = Field(1, ge=1, description="Durability wash cycle count")
    carbon_footprint_g_per_unit: float = Field(..., ge=0.0, description="Embodied carbon footprint per pack in grams CO2e")
    carbon_footprint_batch_kg: float = Field(..., ge=0.0, description="Total batch carbon footprint in kg CO2e")
    pcr_percentage: float = Field(0.0, ge=0.0, le=100.0, description="Post-Consumer Recycled content %")
    pcr_carbon_reduction_pct: float = Field(0.0, ge=0.0, le=100.0, description="Carbon reduction achieved via PCR %")
    water_footprint_l_per_unit: float = Field(..., ge=0.0, description="Freshwater footprint per pack in Liters")
    water_footprint_batch_liters: float = Field(..., ge=0.0, description="Total batch freshwater footprint in Liters")
    unit_waste_grams: float = Field(..., ge=0.0, description="Unit solid waste mass in grams")
    total_batch_waste_kg: float = Field(..., ge=0.0, description="Total batch solid waste mass in kg")
    landfill_diversion_pct: float = Field(80.0, ge=0.0, le=100.0, description="Landfill diversion potential percentage")
    circularity_index_mci: float = Field(0.80, ge=0.0, le=1.0, description="Ellen MacArthur Material Circularity Index (0.0 - 1.0)")
    primary_disposal_pathway: str = Field("Curbside Mechanical Recycling", description="Recommended disposal pathway")


class ReportCostSummary(BaseModel):
    """Converter economics and packaging material yield summary."""
    model_config = ConfigDict(extra="ignore")

    estimated_cost_per_unit_inr: float = Field(..., ge=0.0, description="Estimated unit cost in INR")
    estimated_batch_cost_inr: float = Field(..., ge=0.0, description="Estimated total batch cost in INR")
    gross_material_mass_grams: float = Field(..., ge=0.0, description="Gross substrate weight per pack in grams")
    gross_material_mass_batch_kg: float = Field(..., ge=0.0, description="Total film gross weight required in kg")
    film_surface_area_sqm: float = Field(0.06, ge=0.0, description="Total blank surface area per pack in m²")
    currency: str = Field("INR", description="Currency ISO symbol (e.g. INR, USD)")


class RecommendationReportRequest(BaseModel):
    """Input payload to request structured report synthesis."""
    model_config = ConfigDict(extra="ignore")

    recommendation_id: Optional[str] = Field(None, description="Optional ID of existing recommendation")
    food_name: str = Field(..., description="Food commodity name")
    category: Optional[str] = Field(None, description="Food category")
    fill_quantity: str = Field("500g", description="Fill quantity per package")
    batch_size_units: int = Field(10000, ge=1, description="Production batch size")
    length_cm: float = Field(18.0, gt=0.0, description="Length in cm")
    width_cm: float = Field(12.0, gt=0.0, description="Width in cm")
    depth_or_gusset_cm: float = Field(4.0, ge=0.0, description="Gusset/depth in cm")
    thickness_microns: float = Field(50.0, gt=0.0, description="Thickness in microns")
    pcr_percentage: float = Field(0.0, ge=0.0, le=100.0, description="PCR %")
    target_shelf_life_days: int = Field(180, ge=1, description="Target shelf life duration in days")
    storage_condition: str = Field("Ambient Standard", description="Storage condition")
    selected_material_id: Optional[str] = Field(None, description="Selected packaging material ID")


class RecommendationReportModel(BaseModel):
    """Master structured enterprise packaging prescription report."""
    model_config = ConfigDict(extra="ignore")

    report_id: str = Field(..., description="Unique report identifier (e.g. SPK-2026-9B7C12F)")
    generated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), description="UTC timestamp of report generation")
    engine_version: str = Field("SmartPack AI Engine v2.4-Hybrid", description="Prescription algorithm version")
    verification_hash: str = Field(..., description="SHA-256 integrity verification hash")
    food_context: ReportFoodContext
    food_properties: ReportFoodProperties
    primary_prescription: ReportPrimaryPrescription
    explainable_rationale: str = Field(..., description="Explainable AI narrative prescription rationale")
    key_drivers: List[str] = Field(default_factory=list, description="Primary technical decision drivers")
    alternatives: List[ReportAlternativePackaging] = Field(default_factory=list, description="3-way alternative benchmark options")
    lca_summary: ReportLcaSummary
    cost_summary: ReportCostSummary
    standards_and_citations: List[str] = Field(default_factory=list, description="Scientific citations and test standards")
    share_url: Optional[str] = Field(None, description="Shareable deep-link URL")


class ReportMarkdownResponse(BaseModel):
    """Response containing formatted GitHub-flavored Markdown specification."""
    model_config = ConfigDict(extra="ignore")

    report_id: str
    markdown_content: str
