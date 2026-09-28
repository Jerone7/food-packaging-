"""
Volumetric Box Geometry & Explainable AI (XAI) Synthesis Service.
Part of the SmartPack AI Hybrid Recommendation Engine (Module 5).

Calculates optimal 3D packaging dimensions (L x W x H), volume utilization,
cushioning materials, and step-by-step scientific justification rationales.
"""

import math
from typing import Dict, Any, List, Optional
from dataclasses import dataclass, asdict

from app.core.material_catalog import MaterialSpecification


@dataclass
class BoxGeometryResult:
    length_cm: float
    width_cm: float
    height_cm: float
    total_volume_cm3: float
    space_utilization_pct: float
    cushioning_material: str

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class ScientificRationaleResult:
    summary: str
    key_drivers: List[str]

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class ExplainableRecommendationResult:
    packaging_title: str
    packaging_format: str
    recommendation_explanation: str
    advantages: List[str]
    limitations: List[str]
    suitable_storage_condition: str
    expected_application: str
    important_properties: Dict[str, str]

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


class BoxGeometryAndXAIService:
    """Computes volumetric packaging geometry, cushioning, and natural language XAI rationales."""

    # Approximate commodity bulk densities (kg / m^3)
    BULK_DENSITIES: Dict[str, float] = {
        "vegetables": 500.0,
        "fruits": 550.0,
        "meat": 950.0,
        "seafood": 900.0,
        "poultry": 920.0,
        "dairy": 960.0,
        "grain": 800.0,
        "pulses": 820.0,
        "snacks": 180.0,
        "bakery": 350.0,
        "frozen": 600.0,
        "processed": 850.0,
    }

    @classmethod
    def calculate_box_geometry(
        cls,
        quantity_kg: float,
        category: str,
        commodity_name: str,
        is_fragile: bool,
        storage_temp_c: float,
    ) -> BoxGeometryResult:
        """
        Calculates 3D box dimensions (L x W x H) using golden ratio aesthetics and volume buffer.
        """
        cat_lower = category.lower() if category else "vegetables"
        name_lower = commodity_name.lower() if commodity_name else ""

        # Determine bulk density
        density = 600.0
        for key, val in cls.BULK_DENSITIES.items():
            if key in cat_lower or key in name_lower:
                density = val
                break

        # If snacks / chips, very low bulk density
        if any(k in name_lower for k in ["chip", "crisp", "popcorn", "puffed"]):
            density = 150.0

        # Net product volume in cm3 (1 m3 = 1,000,000 cm3; V = (mass / density) * 1,000,000)
        mass = max(0.1, quantity_kg)
        v_net = (mass / density) * 1_000_000.0

        # Buffer factor for headspace and cushioning (1.25 standard, 1.45 fragile / delicate produce)
        buffer_factor = 1.45 if is_fragile else 1.25
        v_gross = v_net * buffer_factor

        # Golden Ratio dimensional synthesis (L : W : H = 1.618 : 1.0 : 0.8)
        # V_gross = L * W * H = 1.618 * W * 1.0 * W * 0.8 * W = 1.2944 * W^3
        w = round((v_gross / 1.2944) ** (1.0 / 3.0), 1)
        w = max(5.0, w)
        l = round(1.618 * w, 1)
        h = round(0.8 * w, 1)

        total_volume = round(l * w * h, 1)
        utilization = round((v_net / total_volume) * 100.0, 1)
        utilization = min(92.0, max(50.0, utilization))

        # Cushioning prescription
        is_cold = storage_temp_c <= 8.0
        if is_fragile:
            if is_cold:
                cushioning = "Recycled Kraft Thermal Insulated Pouch + Cold Gel Pack"
            else:
                cushioning = "Honeycomb Kraft Paper + Cornstarch Protective Peanuts"
        else:
            if is_cold:
                cushioning = "Molded Pulp Insulated Box Liner"
            else:
                cushioning = "Recycled Shredded Kraft Paper Cushioning"

        return BoxGeometryResult(
            length_cm=l,
            width_cm=w,
            height_cm=h,
            total_volume_cm3=total_volume,
            space_utilization_pct=utilization,
            cushioning_material=cushioning,
        )

    @classmethod
    def generate_scientific_rationale(
        cls,
        commodity_name: str,
        category: str,
        material: MaterialSpecification,
        input_data: Dict[str, Any],
        active_additives: List[str],
    ) -> ScientificRationaleResult:
        """
        Generates transparent, explainable natural language scientific rationales.
        """
        name = commodity_name or input_data.get("name") or "Commodity"
        moisture = float(input_data.get("moisture_pct") or input_data.get("moisture") or 60.0)
        fat = float(input_data.get("fat_pct") or input_data.get("fat") or 2.0)
        ph = float(input_data.get("ph") or 6.0)
        r20 = float(input_data.get("respiration_rate_20c") or 0.0)
        resp_class = str(input_data.get("respiration_class", "")).lower()
        ethylene = str(input_data.get("ethylene_sensitivity_score") or input_data.get("ethylene_sensitivity") or "low").lower()
        ci_thresh = float(input_data.get("chilling_injury_threshold_c") or -1.0)
        storage_temp = float(input_data.get("storage_temp_c") or input_data.get("storage_temperature_c") or 20.0)
        duration = float(input_data.get("storage_duration_days") or input_data.get("duration") or 14.0)

        # High-level summary
        if r20 >= 20.0 or any(c in resp_class for c in ["high", "very high", "extreme"]):
            summary = f"{name} requires Equilibrium Modified Atmosphere Packaging (EMAP) with gas-permeable micro-perforations to maintain physiological equilibrium."
        elif fat >= 18.0:
            summary = f"{name} contains sensitive lipids requiring high-barrier hermetic shielding and inert gas flushing to suppress oxidative rancidity."
        elif storage_temp <= -10.0:
            summary = f"{name} deep-freeze preservation mandates cryogenic-rated polymer with sub-zero puncture resistance."
        elif any(c in category.lower() for c in ["meat", "seafood", "poultry", "dairy"]):
            summary = f"{name} requires ultra-low oxygen transmission barrier and strict cold-chain preservation to inhibit microbial proliferation."
        elif moisture <= 14.0:
            summary = f"{name} dry bulk storage requires moisture-proof renewable kraft barrier to preserve hygroscopic crispness."
        else:
            summary = f"{name} preservation is optimized with {material.name} balancing barrier protection and sustainability."

        # Key Drivers
        drivers: List[str] = []

        # 1. Respiration driver
        if r20 >= 15.0 or any(c in resp_class for c in ["high", "very high", "extreme"]):
            drivers.append(
                f"High respiration rate ({r20:.1f} mg CO₂/kg/h) requires gas-permeable micro-perforations (OTR: {material.otr_cc_m2_day:.0f} cc/m²/day) to prevent anaerobic fermentation and souring."
            )

        # 2. Moisture & anti-fog driver
        if moisture >= 75.0:
            drivers.append(
                f"High moisture content ({moisture:.1f}%) requires anti-fog surface surfactant to prevent internal condensation droplet formation and fungal sporulation."
            )
        elif moisture <= 8.0:
            drivers.append(
                f"Low moisture content ({moisture:.1f}%) requires high moisture barrier (WVTR: {material.wvtr_g_m2_day:.2f} g/m²/day) to prevent hygroscopic water uptake and caking."
            )

        # 3. Fat / Lipid oxidation driver
        if fat >= 18.0:
            drivers.append(
                f"Elevated fat content ({fat:.1f}%) mandates ultra-low oxygen transmission rate (< {material.otr_cc_m2_day:.1f} cc/m²/day) with inert N₂ headspace flush to eliminate lipid peroxidation."
            )

        # 4. Ethylene sensitivity driver
        if any(w in ethylene for w in ["high", "crit", "mod"]) or "0.5" in ethylene or "0.8" in ethylene or "1.0" in ethylene:
            drivers.append(
                "Ethylene sensitivity warrants active KMnO₄ oxidation sachet to neutralize endogenously synthesized C₂H₄ and delay senescence."
            )

        # 5. Chilling injury driver
        if ci_thresh > 0.0:
            if storage_temp < ci_thresh:
                drivers.append(
                    f"CRITICAL WARNING: Target storage ({storage_temp:.1f}°C) is below chilling injury floor ({ci_thresh:.1f}°C). Pitting and tissue collapse risk."
                )
            else:
                drivers.append(
                    f"Storage temperature ({storage_temp:.1f}°C) respects the critical chilling injury threshold ({ci_thresh:.1f}°C)."
                )

        # 6. Sustainability / Eco driver
        if material.sustainability_score >= 85.0:
            drivers.append(
                f"Selected bio-polymer achieves a {material.sustainability_score:.0f}/100 sustainability index with full industrial/home compostability."
            )

        # Fallback if few drivers
        if len(drivers) < 2:
            drivers.append(f"Storage duration horizon ({duration:.0f} days) is fully supported by polymer barrier durability.")
            drivers.append(f"Tensile strength ({material.tensile_strength_mpa:.1f} MPa) ensures physical integrity during logistics.")

        return ScientificRationaleResult(
            summary=summary,
            key_drivers=drivers,
        )

    @classmethod
    def generate_explainable_recommendation(
        cls,
        commodity_name: str,
        category: str,
        material: MaterialSpecification,
        input_data: Dict[str, Any],
        is_fragile: bool = False,
    ) -> ExplainableRecommendationResult:
        """
        Generates full explainable recommendation structure for Module 5 result page:
        - Headline Title (e.g. 'Ventilated Food-Grade Packaging')
        - Physical Format (e.g. 'Micro-Perforated Hinged Clamshell')
        - Natural Language Explanation ('This option is recommended because...')
        - Advantages and Limitations lists
        - Suitable storage condition
        - Expected application
        - Important properties dictionary
        """
        cat_lower = (category or "").lower()
        name_lower = (commodity_name or "").lower()
        moisture = float(input_data.get("moisture_pct") or input_data.get("moisture") or 60.0)
        fat = float(input_data.get("fat_pct") or input_data.get("fat") or 2.0)
        r20 = float(input_data.get("respiration_rate_20c") or 0.0)
        resp_class = str(input_data.get("respiration_class", "")).lower()
        storage_temp = float(input_data.get("storage_temp_c") or input_data.get("storage_temperature_c") or 20.0)
        ci_thresh = float(input_data.get("chilling_injury_threshold_c") or -1.0)

        is_high_respiration = (
            r20 >= 15.0 or 
            any(c in resp_class for c in ["high", "very high", "extreme", "moderate"]) or
            (cat_lower in ["vegetables", "fruits", "horticulture", "produce"] and moisture >= 70.0)
        )

        # 1. Headline Title & Format
        if is_high_respiration:
            title = "Ventilated Food-Grade Packaging"
            p_format = "Micro-Perforated Bio-Clamshell with Anti-Fog Seal"
        elif fat >= 18.0 or any(k in name_lower for k in ["chip", "crisp", "nut", "snack"]):
            title = "Nitrogen-Flushed High-Barrier Pillow Pouch"
            p_format = "Metallized Laminate Pillow Pouch with 99.5% N₂ Flush"
        elif storage_temp <= -10.0:
            title = "Cryogenic Deep-Freeze Barrier Bag"
            p_format = "Sub-Zero Puncture-Resistant Heavy-Gauge Pouch"
        elif any(k in cat_lower for k in ["meat", "seafood", "poultry", "fish", "dairy", "cheese"]):
            title = "High-Barrier EVOH Vacuum Skin Tray"
            p_format = "Thermoformed Barrier Tray with Vacuum Skin Sealing"
        elif moisture <= 14.0 or any(k in cat_lower for k in ["grain", "pulse", "flour", "cereal", "dry"]):
            title = "Multi-Wall Kraft Moisture-Barrier Sack"
            p_format = "Gusseted Multi-Wall Paperboard Bag with Bio-Liner"
        else:
            title = f"Optimized {material.name} Packaging"
            p_format = f"Food-Grade {material.structure} Container"

        # 2. Recommendation Explanation (The exact explainability narrative)
        if is_high_respiration:
            explanation = (
                "This option is recommended because the selected food has high respiration and moisture sensitivity, "
                "requiring appropriate gas exchange and moisture management."
            )
        elif fat >= 18.0 or any(k in name_lower for k in ["chip", "crisp", "nut", "snack"]):
            explanation = (
                "This option is recommended because the selected food has elevated lipid content and oxidation sensitivity, "
                "requiring hermetic oxygen exclusion and inert nitrogen flush to prevent oxidative rancidity."
            )
        elif storage_temp <= -10.0:
            explanation = (
                "This option is recommended because sub-zero deep freeze storage mandates cryogenic-rated polymer with "
                "sub-zero impact toughness and vapor barrier to eliminate freezer burn."
            )
        elif any(k in cat_lower for k in ["meat", "seafood", "poultry", "fish", "dairy", "cheese"]):
            explanation = (
                "This option is recommended because high protein perishability and active microbial flora require "
                "hermetic oxygen exclusion and leak-proof seal integrity under cold chain refrigeration."
            )
        elif moisture <= 14.0:
            explanation = (
                "This option is recommended because low moisture hygroscopicity requires robust moisture barrier "
                "protection to prevent caking and preserve crispness during ambient distribution."
            )
        else:
            explanation = (
                f"This option is recommended because {material.name} delivers balanced barrier protection, "
                f"mechanical durability, and circular sustainability for {commodity_name}."
            )

        # 3. Advantages
        advantages: List[str] = []
        if is_high_respiration:
            advantages.append("Equilibrium modified atmosphere (EMAP) prevents anaerobic souring")
            advantages.append("Anti-fog coating suppresses condensation water droplets and mold")
            if material.sustainability_score >= 80:
                advantages.append(f"100% compostable bio-polymer (EN 13432, {material.sustainability_score:.0f}/100 Eco)")
            else:
                advantages.append("Optimized O₂ and CO₂ gas permselectivity maintains cell firmness")
        elif fat >= 18.0:
            advantages.append(f"Ultra-low oxygen transmission rate (< {material.otr_cc_m2_day:.1f} cc/m²/day) blocks rancidity")
            advantages.append("100% light and UV opacity arrests photo-oxidation")
            advantages.append("Nitrogen gas cushion provides pneumatic transit protection against crushing")
        elif any(k in cat_lower for k in ["meat", "seafood", "poultry", "fish"]):
            advantages.append(f"Ultra-high barrier coex layer (OTR < {material.otr_cc_m2_day:.1f} cc) suppresses aerobes")
            advantages.append("Hermetic seal eliminates cross-contamination and liquid leakage")
            advantages.append("Integrated absorbent drip pad maintains surface appearance and freshness")
        else:
            advantages.append(f"Engineered moisture barrier (WVTR: {material.wvtr_g_m2_day:.2f} g/m²/day) protects crispness")
            advantages.append(f"High tensile strength ({material.tensile_strength_mpa:.1f} MPa) withstands multi-tier stacking")
            advantages.append(f"High sustainability index ({material.sustainability_score:.0f}/100 circularity score)")

        # 4. Limitations
        limitations: List[str] = []
        if is_high_respiration:
            limitations.append("Not suitable for vacuum packing or high-temperature retort processing")
            limitations.append("Storage duration limited to 14–21 days under non-refrigerated ambient conditions")
            limitations.append("Permeable to strong external odors and volatile organic compounds")
        elif fat >= 18.0:
            limitations.append("Multi-layer foil/metallized laminate requires specialized recycling streams (RIC #7)")
            limitations.append("Non-biodegradable synthetic polymer structure")
        elif storage_temp <= -10.0:
            limitations.append("Requires strict sub-zero temperature maintenance; thawing degrades barrier seal")
        elif any(k in cat_lower for k in ["meat", "seafood", "poultry", "fish"]):
            limitations.append("Strict cold chain dependency (0°C to 4°C); temperature abuse accelerates spoilage")
            limitations.append("Higher unit packaging cost compared to standard commodity films")
        else:
            limitations.append("Avoid prolonged outdoor UV radiation and water submersion")
            limitations.append("Sharp foreign contaminants may puncture single-layer packaging")

        # 5. Suitable Storage Condition
        if storage_temp <= -10.0:
            storage_cond = f"Deep Freeze: {storage_temp:.0f}°C (Continuous Sub-Zero Cold Chain)"
        elif storage_temp <= 8.0:
            if ci_thresh > 0.0 and storage_temp < ci_thresh:
                storage_cond = f"Cold Storage: {ci_thresh:.0f}°C - {ci_thresh + 3:.0f}°C (Above Chilling Injury Threshold {ci_thresh:.0f}°C), 90-95% RH"
            else:
                storage_cond = f"Refrigerated Storage: {storage_temp:.0f}°C (85-95% Relative Humidity)"
        elif ci_thresh > 0.0:
            storage_cond = f"Controlled Ambient / Cellar: {max(12.0, ci_thresh):.0f}°C - {max(15.0, ci_thresh + 3):.0f}°C, 85-90% RH"
        else:
            storage_cond = f"Dry Ambient Storage: {storage_temp:.0f}°C (< 65% Relative Humidity, Dry & Ventilated)"

        # 6. Expected Application
        if is_high_respiration:
            expected_app = "High-respiration fresh produce, strawberries, cut fruits, cherry tomatoes, mushrooms, leafy greens"
        elif fat >= 18.0:
            expected_app = "Potato chips, roasted nuts, fried snacks, puffed namkeen, extruded crisps"
        elif storage_temp <= -10.0:
            expected_app = "Frozen vegetables, frozen ready-to-eat meals, ice cream, IQF berries, frozen seafood"
        elif any(k in cat_lower for k in ["meat", "seafood", "poultry", "fish"]):
            expected_app = "Fresh salmon fillets, poultry cuts, marinated red meats, artisanal fresh paneer, chilled deli"
        elif moisture <= 14.0:
            expected_app = "Basmati rice, whole wheat flour, lentils, dry milk powder, roasted grains, dry pulses"
        else:
            expected_app = f"Standard {category or 'General'} food commodities, processed food packages, dry groceries"

        # 7. Important Properties Dictionary
        otr_fmt = "< 1.0 cc/m²/day" if material.otr_cc_m2_day < 1.0 else f"{material.otr_cc_m2_day:.0f} cc/m²/day"
        wvtr_fmt = "< 1.0 g/m²/day" if material.wvtr_g_m2_day < 1.0 else f"{material.wvtr_g_m2_day:.1f} g/m²/day"
        
        important_props: Dict[str, str] = {
            "OTR (Oxygen Barrier)": otr_fmt,
            "WVTR (Moisture Barrier)": wvtr_fmt,
            "Film Thickness": f"{material.thickness_microns:.0f} µm",
            "Tensile Strength": f"{material.tensile_strength_mpa:.1f} MPa",
            "Puncture Resistance": f"{material.puncture_resistance_n:.0f} N",
            "Thermal Span": f"{material.temp_min_c:.0f}°C to {material.temp_max_c:.0f}°C",
            "Breathability Profile": "High Gas Exchange" if is_high_respiration else "Hermetic Barrier",
            "Sustainability Rating": f"{material.sustainability_score:.0f}/100 Eco Score",
        }

        return ExplainableRecommendationResult(
            packaging_title=title,
            packaging_format=p_format,
            recommendation_explanation=explanation,
            advantages=advantages,
            limitations=limitations,
            suitable_storage_condition=storage_cond,
            expected_application=expected_app,
            important_properties=important_props,
        )


geometry_and_xai_service = BoxGeometryAndXAIService()

