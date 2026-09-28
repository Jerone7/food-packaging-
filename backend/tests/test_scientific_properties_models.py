import unittest
import sys
import os

# Add backend directory to path
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from app.models.food_and_packaging import Food, FoodScientificProperty, Source
from app.schemas.food_scientific_properties import (
    PhysicochemicalTraits,
    PhysiologicalKinetics,
    AtmosphereSensitivities,
    ThermalAndStorage,
    SpoilageAndVulnerabilities,
    PackagingPrescriptions,
    FoodScientificPropertiesResponse,
)

class TestScientificPropertiesModels(unittest.TestCase):
    def test_orm_model_instantiation(self):
        food = Food(
            name="Fresh Tomato",
            category="Vegetables",
            moisture=94.5,
            fat=0.2,
            ph=4.4,
            water_activity=0.99,
        )

        prop = FoodScientificProperty(
            food=food,
            moisture_sensitivity="High",
            equilibrium_rh_target_pct=90.0,
            respiration_class="Moderate",
            respiration_rate_5c=8.0,
            respiration_rate_20c=28.0,
            respiratory_quotient=0.98,
            oxygen_sensitivity="Moderate",
            co2_sensitivity="Moderate",
            max_tolerable_co2_pct=5.0,
            ethylene_production_class="Moderate",
            ethylene_prod_rate=4.5,
            ethylene_sensitivity="High",
            perishability="Highly perishable",
            optimum_temp_min_c=12.0,
            optimum_temp_max_c=15.0,
            chilling_injury_threshold_c=10.0,
            freezing_point_c=-0.6,
            light_sensitivity="Low",
            aroma_sensitivity="Low",
            microbial_spoilage_vector="Fungal rots (Botrytis, Alternaria)",
            mechanical_sensitivity="High",
            ambient_shelf_life_days=7,
            refrigerated_shelf_life_days=21,
            controlled_atmosphere_shelf_life_days=35,
        )

        self.assertEqual(prop.respiration_class, "Moderate")
        self.assertEqual(prop.chilling_injury_threshold_c, 10.0)
        self.assertEqual(prop.ethylene_sensitivity, "High")
        self.assertEqual(prop.food.name, "Fresh Tomato")
        self.assertEqual(food.scientific_properties, prop)

    def test_pydantic_schema_validation(self):
        data = {
            "food_id": 12,
            "commodity_name": "Fresh Tomato",
            "scientific_name": "Solanum lycopersicum",
            "category": "Vegetables",
            "physicochemical": {
                "moisture_pct": 94.5,
                "fat_pct": 0.2,
                "ph": 4.4,
                "water_activity": 0.99,
                "moisture_sensitivity": "High",
                "equilibrium_rh_target_pct": 90.0,
            },
            "physiological_kinetics": {
                "respiration_class": "Moderate",
                "respiration_rate_5c": 8.0,
                "respiration_rate_20c": 28.0,
                "respiratory_quotient": 0.98,
                "ethylene_production_class": "Moderate",
                "ethylene_prod_rate": 4.5,
                "ethylene_sensitivity": "High",
            },
            "atmosphere_sensitivities": {
                "oxygen_sensitivity": "Moderate",
                "co2_sensitivity": "Moderate",
                "max_tolerable_co2_pct": 5.0,
                "target_emap_o2_pct": "3.0 - 5.0%",
                "target_emap_co2_pct": "3.0 - 5.0%",
            },
            "thermal_and_storage": {
                "perishability": "Highly perishable",
                "optimum_temp_min_c": 12.0,
                "optimum_temp_max_c": 15.0,
                "chilling_injury_threshold_c": 10.0,
                "freezing_point_c": -0.6,
                "ambient_shelf_life_days": 7,
                "refrigerated_shelf_life_days": 21,
                "controlled_atmosphere_shelf_life_days": 35,
            },
            "spoilage_and_vulnerabilities": {
                "light_sensitivity": "Low",
                "aroma_sensitivity": "Low",
                "microbial_spoilage_vector": "Fungal rots (Botrytis, Alternaria)",
                "mechanical_sensitivity": "High",
            },
            "packaging_prescriptions": {
                "recommended_barrier_type": "Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)",
                "required_otr_range": "3000 - 5000 cc/m²/day",
                "required_wvtr_range": "40 - 80 g/m²/day",
                "ethylene_action_required": True,
                "thermal_warning": "DO NOT refrigerate below 10°C to avoid chilling injury",
                "cushioning_directive": "Honeycomb kraft protective sleeving",
            },
            "source": "ICMR-NIN IFCT 2017 & UC Davis Postharvest Compendium",
            "confidence_score": 0.98,
        }

        response = FoodScientificPropertiesResponse(**data)
        self.assertEqual(response.commodity_name, "Fresh Tomato")
        self.assertEqual(response.physicochemical.moisture_pct, 94.5)
        self.assertEqual(response.physiological_kinetics.respiration_rate_20c, 28.0)
        self.assertEqual(response.thermal_and_storage.chilling_injury_threshold_c, 10.0)
        self.assertTrue(response.packaging_prescriptions.ethylene_action_required)

    def test_scientific_catalog_resolution(self):
        from app.core.scientific_catalog import get_scientific_profile_for_food, normalize_food_key

        # Test Tomato resolution
        tomato_profile = get_scientific_profile_for_food(1, "Fresh Tomato", "Vegetables")
        self.assertEqual(tomato_profile.commodity_name, "Fresh Tomato")
        self.assertEqual(tomato_profile.physicochemical.moisture_pct, 94.5)
        self.assertEqual(tomato_profile.thermal_and_storage.chilling_injury_threshold_c, 10.0)
        self.assertTrue(tomato_profile.packaging_prescriptions.ethylene_action_required)

        # Test Potato Chips resolution
        chips_profile = get_scientific_profile_for_food(2, "Potato Chips (fried)", "Other perishables")
        self.assertEqual(chips_profile.physicochemical.moisture_pct, 2.0)
        self.assertEqual(chips_profile.physicochemical.fat_pct, 33.0)
        self.assertEqual(chips_profile.physiological_kinetics.respiration_class, "Non-respiring processed food")
        self.assertFalse(chips_profile.packaging_prescriptions.ethylene_action_required)

        # Test Banana Chilling Injury resolution
        banana_profile = get_scientific_profile_for_food(3, "Fresh Banana", "Fruits")
        self.assertEqual(banana_profile.thermal_and_storage.chilling_injury_threshold_c, 13.0)
        self.assertEqual(banana_profile.physiological_kinetics.ethylene_sensitivity, "Extreme (Triggers irreversible climacteric ripening)")

        # Test Paneer Dairy resolution
        paneer_profile = get_scientific_profile_for_food(4, "Fresh Paneer", "Dairy")
        self.assertEqual(paneer_profile.physicochemical.moisture_pct, 55.0)
        self.assertEqual(paneer_profile.physicochemical.fat_pct, 22.0)

        # Test Chicken Meat resolution
        chicken_profile = get_scientific_profile_for_food(5, "Fresh Chicken Breast", "Meat")
        self.assertEqual(chicken_profile.physicochemical.moisture_pct, 74.0)

        # Test Bread Bakery resolution
        bread_profile = get_scientific_profile_for_food(6, "Sliced White Bread", "Bakery")
        self.assertEqual(bread_profile.physicochemical.moisture_pct, 36.0)
        self.assertEqual(bread_profile.thermal_and_storage.chilling_injury_threshold_c, 4.0)

        # Test Rice Grain resolution
        rice_profile = get_scientific_profile_for_food(7, "Basmati Rice (milled)", "Grains")
        self.assertEqual(rice_profile.physicochemical.moisture_pct, 12.5)

    def test_scientific_catalog_fallback_synthesis(self):
        from app.core.scientific_catalog import get_scientific_profile_for_food

        # Unlisted custom item
        profile = get_scientific_profile_for_food(999, "Exotic Organic Dragonfruit", "Fruits")
        self.assertEqual(profile.commodity_name, "Exotic Organic Dragonfruit")
        self.assertIsNotNone(profile.physicochemical.moisture_pct)
        self.assertIsNotNone(profile.physiological_kinetics.respiration_class)
        self.assertIsNotNone(profile.packaging_prescriptions.recommended_barrier_type)

if __name__ == "__main__":
    unittest.main()

