"""
Cost Estimation Service (Module 10).
Performs parametric geometric area calculations, substrate mass & density determinations,
itemized cost layer aggregations, volume tier discount curve modeling, and transparency metadata assembly.
"""

from typing import Dict, List, Optional, Tuple
from app.schemas.cost_estimation import (
    PackagingFormFactorEnum,
    FunctionalAddOnEnum,
    PricingSourceEnum,
    CostEstimationRequest,
    CostEstimationResponse,
    MaterialRequirementDetail,
    CostLayerItem,
    VolumeTierSensitivityPoint,
)
from app.services.geometry_calculator import GeometryCalculator


class CostEstimationService:
    """
    Core engine for packaging material requirement footprint and cost estimation.
    """

    # Empirical polymer densities in kg/m³
    POLYMER_DENSITIES_KG_M3: Dict[str, float] = {
        "ldpe": 920.0,
        "hdpe": 955.0,
        "bopp": 905.0,
        "pp": 905.0,
        "pet": 1380.0,
        "bio-pla": 1250.0,
        "pla": 1250.0,
        "natureflex": 1450.0,
        "cellulose": 1450.0,
        "al-foil": 2700.0,
        "aluminum": 2700.0,
        "evoh": 1170.0,
        "kraft paper": 750.0,
        "paperboard": 750.0,
    }
    DEFAULT_POLYMER_DENSITY_KG_M3: float = 1000.0

    # Default substrate raw material prices in INR per kg
    DEFAULT_PRICES_INR_PER_KG: Dict[str, float] = {
        "ldpe": 140.0,
        "hdpe": 150.0,
        "bopp": 175.0,
        "pp": 170.0,
        "pet": 165.0,
        "bio-pla": 320.0,
        "pla": 320.0,
        "natureflex": 420.0,
        "cellulose": 420.0,
        "al-foil": 450.0,
        "aluminum": 450.0,
        "evoh": 520.0,
        "kraft paper": 95.0,
        "paperboard": 90.0,
    }
    DEFAULT_PRICE_INR_PER_KG: float = 180.0

    # Functional Add-on unit costs in INR
    ADDON_PRICING_INR: Dict[FunctionalAddOnEnum, float] = {
        FunctionalAddOnEnum.RESEALABLE_ZIPPER: 0.40,
        FunctionalAddOnEnum.DEGASSING_VALVE: 0.85,
        FunctionalAddOnEnum.TEAR_NOTCH: 0.08,
        FunctionalAddOnEnum.ANTI_FOG_COATING: 0.20,
        FunctionalAddOnEnum.MICRO_PERFORATIONS: 0.18,
        FunctionalAddOnEnum.MAP_GAS_FLUSH: 0.15,
    }

    # Standard conversion, printing, and manufacturing fee constants
    PRINTING_FEE_PER_SQM_INR: float = 0.75
    LAMINATION_FEE_PER_SQM_INR: float = 0.45
    POUCH_MAKING_FEE_PER_UNIT_INR: float = 0.35

    # One-time fixed tooling cylinder / die setup fee in INR
    TOOLING_SETUP_BASE_INR: float = 12000.0

    # Default gauge thickness in microns if unspecified
    DEFAULT_THICKNESS_MICRONS: float = 40.0

    @classmethod
    def get_polymer_density(cls, material_name_or_id: str) -> float:
        """Looks up polymer density in kg/m³ with fallback."""
        key = material_name_or_id.strip().lower()
        for k, v in cls.POLYMER_DENSITIES_KG_M3.items():
            if k in key:
                return v
        return cls.DEFAULT_POLYMER_DENSITY_KG_M3

    @classmethod
    def get_base_price_per_kg(cls, material_name_or_id: str, custom_price: Optional[float] = None) -> float:
        """Returns the base material price per kg in INR."""
        if custom_price is not None and custom_price > 0:
            return custom_price
        key = material_name_or_id.strip().lower()
        for k, v in cls.DEFAULT_PRICES_INR_PER_KG.items():
            if k in key:
                return v
        return cls.DEFAULT_PRICE_INR_PER_KG

    @classmethod
    def get_volume_discount_tier(cls, order_volume: int) -> Tuple[float, str]:
        """
        Determines the volume discount percentage and tier name based on batch size.
        """
        if order_volume >= 100000:
            return 24.0, "Tier 4: Enterprise Scale"
        elif order_volume >= 25000:
            return 16.0, "Tier 3: Medium Commercial"
        elif order_volume >= 5000:
            return 8.0, "Tier 2: Small Commercial"
        else:
            return 0.0, "Tier 1: Pilot / Prototype"

    @classmethod
    def calculate_material_requirements(
        cls,
        packaging_type: PackagingFormFactorEnum,
        dimensions,
        material_name: str,
        number_of_packages: int,
        scrap_rate_percent: float = 6.0,
    ) -> MaterialRequirementDetail:
        """
        Computes single-unit area, single-unit weight, gross batch area, and gross batch mass.
        """
        # 1. Surface Area per unit (m²)
        unit_area_sqm = GeometryCalculator.calculate_surface_area(packaging_type, dimensions)

        # 2. Thickness in meters
        thickness_microns = dimensions.thickness_microns if dimensions.thickness_microns else cls.DEFAULT_THICKNESS_MICRONS
        thickness_m = thickness_microns * 1e-6

        # 3. Density in kg/m³
        density_kg_m3 = cls.get_polymer_density(material_name)

        # 4. Unit weight in kg and grams
        unit_weight_kg = unit_area_sqm * thickness_m * density_kg_m3
        unit_weight_g = unit_weight_kg * 1000.0

        # 5. Batch material requirements with scrap allowance
        scrap_factor = scrap_rate_percent / 100.0
        net_area_sqm = unit_area_sqm * number_of_packages
        gross_area_sqm = net_area_sqm * (1.0 + scrap_factor)

        net_weight_kg = unit_weight_kg * number_of_packages
        gross_weight_kg = net_weight_kg * (1.0 + scrap_factor)
        scrap_weight_kg = gross_weight_kg - net_weight_kg

        return MaterialRequirementDetail(
            surface_area_per_unit_sqm=round(unit_area_sqm, 6),
            weight_per_unit_grams=round(unit_weight_g, 4),
            gross_area_required_sqm=round(gross_area_sqm, 2),
            gross_weight_required_kg=round(gross_weight_kg, 4),
            scrap_allowance_percent=round(scrap_rate_percent, 1),
            scrap_material_weight_kg=round(scrap_weight_kg, 4),
        )

    @classmethod
    def calculate_cost_estimate(cls, request: CostEstimationRequest) -> CostEstimationResponse:
        """
        Executes complete parametric packaging cost estimation.
        """
        # 1. Material Requirements
        scrap_rate = request.custom_scrap_rate_percent if request.custom_scrap_rate_percent is not None else 6.0
        mat_req = cls.calculate_material_requirements(
            packaging_type=request.packaging_type,
            dimensions=request.dimensions,
            material_name=request.material_name,
            number_of_packages=request.number_of_packages,
            scrap_rate_percent=scrap_rate,
        )

        # 2. Substrate Raw Material Cost
        base_price_kg = cls.get_base_price_per_kg(request.material_name, request.custom_material_cost_per_kg)
        total_substrate_cost = mat_req.gross_weight_required_kg * base_price_kg
        unit_substrate_cost = total_substrate_cost / request.number_of_packages

        # 3. Converting, Printing & Slitting Cost
        # Printing + lamination per m² + pouch maker conversion fee per unit
        converting_rate_per_sqm = cls.PRINTING_FEE_PER_SQM_INR + cls.LAMINATION_FEE_PER_SQM_INR
        unit_converting_cost = (mat_req.surface_area_per_unit_sqm * converting_rate_per_sqm) + cls.POUCH_MAKING_FEE_PER_UNIT_INR
        total_converting_cost = unit_converting_cost * request.number_of_packages

        # 4. Functional Add-on Costs
        unit_addons_cost = 0.0
        addons_items: List[CostLayerItem] = []
        for addon in (request.selected_addons or []):
            addon_unit_price = cls.ADDON_PRICING_INR.get(addon, 0.0)
            unit_addons_cost += addon_unit_price
            addons_items.append(
                CostLayerItem(
                    category="Add-on",
                    item_name=f"{addon.value} Treatment",
                    cost_per_unit_inr=round(addon_unit_price, 4),
                    total_cost_inr=round(addon_unit_price * request.number_of_packages, 2),
                    percentage_of_total=0.0, # will update after grand total
                )
            )
        total_addons_cost = unit_addons_cost * request.number_of_packages

        # 5. Fixed Tooling Setup Amortization
        if request.include_tooling_amortization:
            total_tooling_cost = cls.TOOLING_SETUP_BASE_INR
            unit_tooling_cost = total_tooling_cost / request.number_of_packages
        else:
            total_tooling_cost = 0.0
            unit_tooling_cost = 0.0

        # 6. Pre-discount Subtotals
        pre_discount_unit_cost = unit_substrate_cost + unit_converting_cost + unit_addons_cost + unit_tooling_cost
        pre_discount_total_cost = total_substrate_cost + total_converting_cost + total_addons_cost + total_tooling_cost

        # 7. Volume Discount Scaling
        discount_pct, _ = cls.get_volume_discount_tier(request.number_of_packages)
        discount_factor = discount_pct / 100.0
        discount_amount_total = pre_discount_total_cost * discount_factor
        final_total_cost = pre_discount_total_cost - discount_amount_total
        final_unit_cost = final_total_cost / request.number_of_packages

        # 8. Itemized Breakdown Assembly
        cost_breakdown: List[CostLayerItem] = [
            CostLayerItem(
                category="Substrate",
                item_name=f"{request.material_name} Raw Substrate",
                cost_per_unit_inr=round(unit_substrate_cost, 4),
                total_cost_inr=round(total_substrate_cost, 2),
                percentage_of_total=round((total_substrate_cost / pre_discount_total_cost) * 100.0, 2) if pre_discount_total_cost > 0 else 0.0,
            ),
            CostLayerItem(
                category="Converting",
                item_name="Printing, Lamination & Pouch Forming",
                cost_per_unit_inr=round(unit_converting_cost, 4),
                total_cost_inr=round(total_converting_cost, 2),
                percentage_of_total=round((total_converting_cost / pre_discount_total_cost) * 100.0, 2) if pre_discount_total_cost > 0 else 0.0,
            ),
        ]

        if addons_items:
            for item in addons_items:
                item.percentage_of_total = round((item.total_cost_inr / pre_discount_total_cost) * 100.0, 2) if pre_discount_total_cost > 0 else 0.0
                cost_breakdown.append(item)

        if total_tooling_cost > 0:
            cost_breakdown.append(
                CostLayerItem(
                    category="Tooling",
                    item_name="Cylinder & Die Setup Amortization",
                    cost_per_unit_inr=round(unit_tooling_cost, 4),
                    total_cost_inr=round(total_tooling_cost, 2),
                    percentage_of_total=round((total_tooling_cost / pre_discount_total_cost) * 100.0, 2) if pre_discount_total_cost > 0 else 0.0,
                )
            )

        # 9. Volume Tier Sensitivity Curve (1k, 5k, 10k, 25k, 100k units)
        sensitivity_volumes = [1000, 5000, 10000, 25000, 100000]
        volume_sensitivity: List[VolumeTierSensitivityPoint] = []
        for vol in sensitivity_volumes:
            tier_discount_pct, tier_label = cls.get_volume_discount_tier(vol)
            # Tooling amortized for this volume
            v_tooling_unit = (cls.TOOLING_SETUP_BASE_INR / vol) if request.include_tooling_amortization else 0.0
            v_pre_unit = unit_substrate_cost + unit_converting_cost + unit_addons_cost + v_tooling_unit
            v_unit = v_pre_unit * (1.0 - (tier_discount_pct / 100.0))
            v_total = v_unit * vol
            volume_sensitivity.append(
                VolumeTierSensitivityPoint(
                    tier_label=f"{vol // 1000}k Units ({tier_label.split(':')[0].strip()})",
                    order_volume=vol,
                    cost_per_unit_inr=round(v_unit, 2),
                    total_cost_inr=round(v_total, 2),
                    discount_percent=round(tier_discount_pct, 1),
                )
            )

        return CostEstimationResponse(
            material_id=request.material_id,
            material_name=request.material_name,
            packaging_type=request.packaging_type,
            number_of_packages=request.number_of_packages,
            product_fill_quantity=request.product_fill_quantity or "500g",
            material_requirement=mat_req,
            cost_per_unit_inr=round(final_unit_cost, 2),
            total_estimated_cost_inr=round(final_total_cost, 2),
            cost_breakdown=cost_breakdown,
            substrate_cost_subtotal_inr=round(total_substrate_cost, 2),
            converting_cost_subtotal_inr=round(total_converting_cost, 2),
            addons_cost_subtotal_inr=round(total_addons_cost, 2),
            tooling_cost_subtotal_inr=round(total_tooling_cost, 2),
            volume_discount_amount_inr=round(discount_amount_total, 2),
            volume_discount_percent=round(discount_pct, 1),
            volume_tier_sensitivity=volume_sensitivity,
            pricing_mode=PricingSourceEnum.ESTIMATED_MODEL,
            is_estimated=True,
            disclaimer_notice=(
                "ESTIMATED BASELINE: Values are computed using standard industry conversion ratios, "
                "empirical polymer densities, and standard finishing margins. Actual commercial prices "
                "may vary based on live polymer index fluctuations and converter tooling specifications."
            ),
        )
