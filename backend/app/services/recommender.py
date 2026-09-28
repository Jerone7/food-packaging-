import math
from typing import Optional
from app.schemas.packaging import PackagingInput, PackagingRecommendationResult
from app.core.scientific_catalog import get_scientific_profile_for_food
from app.services.scientific_rules import ScientificPackagingRulesEngine

class PackagingRecommenderService:
    @staticmethod
    def recommend(data: PackagingInput) -> PackagingRecommendationResult:
        weight_kg = max(0.05, data.weight)
        name_lower = data.item_name.lower()
        category = data.category or "General"
        storage_cond = (data.storage_condition or "room temperature").lower()
        duration_days = data.storage_duration_days or 30

        # Retrieve comprehensive 14-property empirical scientific profile
        profile = get_scientific_profile_for_food(None, data.item_name, category=category)
        
        # Override with any custom user inputs if provided
        moisture = data.moisture if data.moisture is not None else profile.physicochemical.moisture_pct
        fat = data.fat if data.fat is not None else profile.physicochemical.fat_pct
        ph = data.ph if data.ph is not None else profile.physicochemical.ph
        water_activity = data.water_activity if data.water_activity is not None else profile.physicochemical.water_activity
        respiration_class = data.respiration_class or profile.physiological_kinetics.respiration_class

        # Determine target storage temperature in Celsius
        if "frozen" in storage_cond:
            target_temp_c = -18.0
        elif "refrigerated" in storage_cond or "cold" in storage_cond:
            target_temp_c = 4.0
        else:
            target_temp_c = 22.0

        # Derive precision scientific prescriptions from Rules Engine
        prescriptions = ScientificPackagingRulesEngine.derive_prescriptions(
            commodity_name=data.item_name,
            category=category,
            moisture_pct=moisture,
            fat_pct=fat,
            ph=ph,
            respiration_class=respiration_class,
            respiration_rate_20c=profile.physiological_kinetics.respiration_rate_20c,
            ethylene_sensitivity=profile.physiological_kinetics.ethylene_sensitivity,
            chilling_injury_threshold_c=profile.thermal_and_storage.chilling_injury_threshold_c,
            storage_temperature_c=target_temp_c,
            eco_friendly=data.eco_friendly,
        )

        barrier_material = prescriptions["recommended_barrier_type"]
        otr_req = prescriptions["required_otr_range"]
        wvtr_req = prescriptions["required_wvtr_range"]
        ethylene_action = prescriptions["ethylene_action_required"]
        thermal_warning = prescriptions.get("thermal_warning")
        cushioning_directive = prescriptions.get("cushioning_directive")

        # Sustainability score calculation based on eco-friendly priorities and material profile
        if data.eco_friendly:
            if "Bio-Film" in barrier_material or "Bio-PET" in barrier_material or "Kraft" in barrier_material:
                base_sustainability = 95.0
            elif "HDPE" in barrier_material:
                base_sustainability = 88.0
            else:
                base_sustainability = 85.0
        else:
            if "Aluminium" in barrier_material or "Retort" in barrier_material:
                base_sustainability = 62.0
            elif "EVOH" in barrier_material or "Deep-Freeze" in barrier_material:
                base_sustainability = 65.0
            else:
                base_sustainability = 68.0

        # Unit pricing rates based on barrier technology tier
        if "Aluminium" in barrier_material or "EVOH" in barrier_material:
            unit_rate = 0.58
        elif "Met-PET" in barrier_material or "Deep-Freeze" in barrier_material or "Retort" in barrier_material:
            unit_rate = 0.48
        elif "MAP" in barrier_material or "Bio-Film" in barrier_material:
            unit_rate = 0.42
        elif "Kraft" in barrier_material or "BOPP" in barrier_material:
            unit_rate = 0.32
        else:
            unit_rate = 0.35

        # Volumetric sizing calculation based on empirical bulk density
        density_g_cm3 = 0.35 if moisture < 10.0 else (0.65 if moisture > 75.0 else 0.50)
        item_vol = max(150.0, (weight_kg * 1000.0) / density_g_cm3)
        box_vol = item_vol * (1.25 if data.is_fragile else 1.15)

        cube_side = math.pow(box_vol, 1 / 3)
        dim_l = max(15.0, round(cube_side * 1.3, 1))
        dim_w = max(10.0, round(cube_side * 1.0, 1))
        dim_h = max(8.0, round(cube_side * 0.75, 1))
        actual_box_vol = round(dim_l * dim_w * dim_h, 1)
        utilization = min(96.0, round((item_vol / actual_box_vol) * 100, 1))

        # Protective cushioning & logistics configuration
        if "refrigerated" in storage_cond or "frozen" in storage_cond or "reefer" in (data.transport_mode or "").lower():
            cushioning = (
                "Recycled Kraft Thermal Insulated Pouch + Cold Gel Pack"
                if data.eco_friendly
                else "Insulated Metallized Bubble Liner + Dry Ice Pack"
            )
            cushion_cost = 0.65
        elif data.is_fragile or profile.spoilage_and_vulnerabilities.mechanical_sensitivity.lower().startswith("high"):
            cushioning = (
                cushioning_directive
                or ("Honeycomb Kraft Protective Sleeving + Cornstarch Peanuts" if data.eco_friendly else "Heavy-Duty Inflatable Air Pillows")
            )
            cushion_cost = 0.45
        else:
            cushioning = "Corrugated Flute Inner Partitions" if data.eco_friendly else "Expanded Polyethylene (EPE) Cushioning"
            cushion_cost = 0.20

        total_cost = round((weight_kg * unit_rate) + cushion_cost + 0.30, 2)
        dimensions_str = f"{int(dim_l)} x {int(dim_w)} x {int(dim_h)} cm"

        # Formulate comprehensive scientific summary notes
        notes_parts = [
            f"Tailored for {data.item_name} ({storage_cond.title()}, {duration_days} days).",
            f"Biochemical Profile: Moisture {moisture:.1f}%, Fat {fat:.1f}%, pH {ph:.1f}, Aw {water_activity:.2f}.",
            f"Barrier Requirements: OTR: {otr_req}, WVTR: {wvtr_req}.",
        ]

        if ethylene_action:
            notes_parts.append("Active Potassium Permanganate (KMnO₄) Ethylene Scavenger included.")

        if thermal_warning:
            notes_parts.append(f"⚠️ {thermal_warning}")

        notes = " ".join(notes_parts)

        return PackagingRecommendationResult(
            recommended_box_type=barrier_material,
            recommended_dimensions=dimensions_str,
            box_volume_cm3=float(actual_box_vol),
            item_volume_cm3=float(round(item_vol, 1)),
            space_utilization_pct=utilization,
            cushioning_material=cushioning,
            estimated_cost=total_cost,
            sustainability_score=base_sustainability,
            notes=notes,
        )
