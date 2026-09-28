"""
Scientific Rule-Based Packaging Directives & Barrier Engine.
Translates empirical post-harvest traits into precision packaging barrier rules.
"""

from typing import Dict, Any, Optional

class ScientificPackagingRulesEngine:
    @staticmethod
    def derive_prescriptions(
        commodity_name: str,
        category: str,
        moisture_pct: float,
        fat_pct: float,
        ph: float,
        respiration_class: str,
        respiration_rate_20c: Optional[float],
        ethylene_sensitivity: str,
        chilling_injury_threshold_c: Optional[float],
        storage_temperature_c: Optional[float] = None,
        eco_friendly: bool = True,
    ) -> Dict[str, Any]:
        """
        Derives scientific packaging prescriptions based on postharvest & biochemical traits.
        """
        cat_lower = category.lower()
        name_lower = commodity_name.lower()

        # 1. Barrier Polymer Recommendation
        if "frozen" in cat_lower or (storage_temperature_c is not None and storage_temperature_c <= -15.0):
            barrier = "Cryogenic Puncture-Resistant LLDPE / Cast Polyamide Deep-Freeze Pouch"
            otr_range = "< 2.0 cc/m²/day"
            wvtr_range = "< 0.5 g/m²/day"
            thermal_warning = None
        elif fat_pct > 18.0 or moisture_pct < 8.0:
            barrier = (
                "Metallized High-Barrier Bio-PET (Met-PET) Film with N₂ Gas Flush"
                if eco_friendly
                else "Tri-Layer Aluminium Foil Barrier Laminate (PET/AL/PE)"
            )
            otr_range = "< 0.5 cc/m²/day"
            wvtr_range = "< 0.3 g/m²/day"
            thermal_warning = "Protect from direct heat and sunlight to avoid thermal lipid oxidation"
        elif moisture_pct > 75.0 and (respiration_class.lower() in ["high", "very high", "extremely high"] or any(w in name_lower for w in ["tomato", "spinach", "berry", "apple", "banana"])):
            barrier = (
                "Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)"
                if eco_friendly
                else "Antifog Micro-Perforated Polyolefin Breathable Film (LDPE)"
            )
            otr_range = "3000 - 6000 cc/m²/day"
            wvtr_range = "40 - 80 g/m²/day (Anti-fog treated)"
            thermal_warning = (
                f"DO NOT store below {chilling_injury_threshold_c:.1f}°C to prevent chilling injury"
                if chilling_injury_threshold_c is not None
                else None
            )
        elif ph < 4.6:
            barrier = "Acid-Resistant Multi-Layer Retort Barrier Pouch (PET/AL/PA/PP)"
            otr_range = "< 1.0 cc/m²/day"
            wvtr_range = "< 1.0 g/m²/day"
            thermal_warning = None
        elif any(c in cat_lower for c in ["meat", "dairy"]):
            barrier = "High-Barrier EVOH Vacuum Skin Film (VSP / MAP CO₂ Flush)"
            otr_range = "< 0.5 cc/m²/day"
            wvtr_range = "< 1.5 g/m²/day"
            thermal_warning = "Strict cold-chain (0-4°C) mandatory throughout logistics"
        elif any(c in cat_lower for c in ["grain", "bakery"]):
            barrier = (
                "Unbleached Recycled Kraft with Biodegradable PLA Moisture Liner"
                if eco_friendly
                else "Biaxially Oriented Polypropylene (BOPP) Pouch"
            )
            otr_range = "< 15 cc/m²/day"
            wvtr_range = "< 5.0 g/m²/day"
            thermal_warning = "Store in a cool dry area away from volatile foreign odors"
        else:
            barrier = "Recyclable High-Density Polyethylene (HDPE) Barrier Pouch"
            otr_range = "< 50 cc/m²/day"
            wvtr_range = "< 4.0 g/m²/day"
            thermal_warning = None

        # 2. Ethylene Scrubber Trigger
        ethylene_action = (
            any(w in ethylene_sensitivity.lower() for w in ["high", "extreme", "moderate"])
            and moisture_pct > 60.0
        )

        # 3. Chilling Warning Check
        if storage_temperature_c is not None and chilling_injury_threshold_c is not None:
            if storage_temperature_c < chilling_injury_threshold_c:
                thermal_warning = (
                    f"CRITICAL WARNING: Target storage ({storage_temperature_c}°C) is below the "
                    f"Chilling Injury threshold ({chilling_injury_threshold_c}°C). Risk of pitting, "
                    f"tissue collapse, and flavor degradation!"
                )

        # 4. Cushioning Directive
        if "spinach" in name_lower or "berry" in name_lower or "tomato" in name_lower:
            cushioning = "Honeycomb kraft protective tray partitions"
        elif "chip" in name_lower or "crisp" in name_lower:
            cushioning = "Nitrogen gas headspace pillow buffer (40-50% vol)"
        elif "banana" in name_lower:
            cushioning = "Foam end-caps + corrugated telescopic carton"
        elif "meat" in cat_lower or "dairy" in cat_lower:
            cushioning = "Rigid thermoformed barrier tray with absorbent drip pad"
        else:
            cushioning = "Corrugated flute liner"

        return {
            "recommended_barrier_type": barrier,
            "required_otr_range": otr_range,
            "required_wvtr_range": wvtr_range,
            "ethylene_action_required": ethylene_action,
            "thermal_warning": thermal_warning,
            "cushioning_directive": cushioning,
        }
