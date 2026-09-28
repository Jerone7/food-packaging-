"""
Pydantic Schemas for Cost Estimation Module (Module 10).
Defines contracts for packaging geometry, substrate material mass calculation,
cost itemization, volume discount tiers, and transparency disclaimer metadata.
"""

from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field


class PackagingFormFactorEnum(str, Enum):
    PILLOW_POUCH = "Pillow Pouch"
    STAND_UP_DOYPACK = "Stand-up Doypack"
    THREE_SIDE_SEAL = "3-Side Seal Pouch"
    FOUR_SIDE_QUAD_SEAL = "4-Side Quad Seal"
    THERMOFORMED_TRAY = "Thermoformed Tray / Clamshell"
    VACUUM_RETORT_POUCH = "Vacuum / Retort Pouch"
    FOLDING_CARTON = "Folding Carton Box"


class FunctionalAddOnEnum(str, Enum):
    RESEALABLE_ZIPPER = "Resealable Zipper"
    DEGASSING_VALVE = "One-Way Degassing Valve"
    TEAR_NOTCH = "Laser Tear Notch"
    ANTI_FOG_COATING = "Anti-Fog Coating"
    MICRO_PERFORATIONS = "Laser Micro-Perforations"
    MAP_GAS_FLUSH = "MAP Gas Flush Seal"


class PricingSourceEnum(str, Enum):
    ESTIMATED_MODEL = "Estimated Baseline Model"
    LIVE_SUPPLIER_QUOTE = "Live Supplier Direct RFQ"


class PackageDimensionsInput(BaseModel):
    length_cm: float = Field(..., gt=0, description="Length in centimeters")
    width_cm: float = Field(..., gt=0, description="Width in centimeters")
    depth_or_gusset_cm: Optional[float] = Field(0.0, ge=0, description="Depth, Height, or Gusset in cm")
    thickness_microns: Optional[float] = Field(None, gt=0, description="Film/sheet thickness in microns")


class MaterialRequirementDetail(BaseModel):
    surface_area_per_unit_sqm: float = Field(..., ge=0, description="Surface area for one unit in m²")
    weight_per_unit_grams: float = Field(..., ge=0, description="Mass for one unit in grams")
    gross_area_required_sqm: float = Field(..., ge=0, description="Total batch area including scrap in m²")
    gross_weight_required_kg: float = Field(..., ge=0, description="Total batch material mass in kg")
    scrap_allowance_percent: float = Field(..., ge=0, description="Trim scrap percentage applied")
    scrap_material_weight_kg: float = Field(..., ge=0, description="Estimated scrap material in kg")


class CostLayerItem(BaseModel):
    category: str = Field(..., description="Substrate, Converting, Add-on, or Tooling")
    item_name: str = Field(..., description="Specific item description")
    cost_per_unit_inr: float = Field(..., ge=0, description="Unit cost contribution in INR")
    total_cost_inr: float = Field(..., ge=0, description="Total batch cost in INR")
    percentage_of_total: float = Field(..., ge=0, le=100.0, description="Percentage contribution to total cost")


class VolumeTierSensitivityPoint(BaseModel):
    tier_label: str = Field(..., description="e.g. 1k Units, 10k Units, 100k Units")
    order_volume: int = Field(..., gt=0, description="Unit count")
    cost_per_unit_inr: float = Field(..., ge=0, description="Estimated unit cost at this volume")
    total_cost_inr: float = Field(..., ge=0, description="Total order cost at this volume")
    discount_percent: float = Field(..., ge=0, le=100.0, description="Volume discount percentage")


class CostEstimationRequest(BaseModel):
    material_id: Optional[str] = Field(None, description="Identifier of material from catalog, e.g. MAT_001")
    material_name: str = Field(..., min_length=1, description="Name of material, e.g. Bio-PLA or LDPE")
    packaging_type: PackagingFormFactorEnum = Field(..., description="Packaging form factor")
    dimensions: PackageDimensionsInput = Field(..., description="Package physical dimensions")
    product_fill_quantity: Optional[str] = Field("500g", description="Net food weight/volume per pack")
    number_of_packages: int = Field(..., gt=0, description="Batch order volume N")
    selected_addons: Optional[List[FunctionalAddOnEnum]] = Field(default_factory=list, description="Add-ons selected")
    custom_material_cost_per_kg: Optional[float] = Field(None, ge=0, description="Override base price INR/kg")
    custom_scrap_rate_percent: Optional[float] = Field(6.0, ge=0, le=30.0, description="Trim scrap allowance percentage")
    include_tooling_amortization: Optional[bool] = Field(True, description="Amortize fixed setup cylinder tooling fee")


class CostEstimationResponse(BaseModel):
    material_id: Optional[str] = None
    material_name: str
    packaging_type: PackagingFormFactorEnum
    number_of_packages: int
    product_fill_quantity: str = "500g"

    # Material Footprint Output
    material_requirement: MaterialRequirementDetail

    # Financial Cost Outputs
    cost_per_unit_inr: float = Field(..., ge=0, description="Final estimated cost per unit in INR")
    total_estimated_cost_inr: float = Field(..., ge=0, description="Total estimated batch cost in INR")

    # Itemized Breakdown
    cost_breakdown: List[CostLayerItem] = Field(default_factory=list)
    substrate_cost_subtotal_inr: float = Field(default=0.0, ge=0)
    converting_cost_subtotal_inr: float = Field(default=0.0, ge=0)
    addons_cost_subtotal_inr: float = Field(default=0.0, ge=0)
    tooling_cost_subtotal_inr: float = Field(default=0.0, ge=0)
    volume_discount_amount_inr: float = Field(default=0.0, ge=0)
    volume_discount_percent: float = Field(default=0.0, ge=0, le=100.0)

    # Volume Sensitivity Curve
    volume_tier_sensitivity: List[VolumeTierSensitivityPoint] = Field(default_factory=list)

    # Mandatory Transparency & Disclaimer Metadata
    pricing_mode: PricingSourceEnum = Field(default=PricingSourceEnum.ESTIMATED_MODEL)
    is_estimated: bool = Field(default=True, description="Always true unless live supplier verified")
    disclaimer_notice: str = Field(
        default="ESTIMATED BASELINE: Values are computed using standard industry conversion ratios, empirical polymer densities, and standard finishing margins. Actual commercial prices may vary based on live polymer index fluctuations and converter tooling specifications."
    )
    supplier_quote_reference_id: Optional[str] = None
    currency_code: str = Field(default="INR", description="Currency ISO code")
