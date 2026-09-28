import unittest
import sys
import os

# Add backend directory to path
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from starlette.testclient import TestClient
from app.main import app
from app.services.scientific_rules import ScientificPackagingRulesEngine

class TestFoodScientificEndpoints(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)

    def test_get_scientific_profile_by_id(self):
        response = self.client.get("/api/v1/data/foods/1/scientific-profile")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        # Verify all 14 property sub-dictionaries exist
        self.assertIn("physicochemical", data)
        self.assertIn("physiological_kinetics", data)
        self.assertIn("atmosphere_sensitivities", data)
        self.assertIn("thermal_and_storage", data)
        self.assertIn("spoilage_and_vulnerabilities", data)
        self.assertIn("packaging_prescriptions", data)

        # Check core physicochemical values
        self.assertGreater(data["physicochemical"]["moisture_pct"], 0)
        self.assertIn("respiration_class", data["physiological_kinetics"])
        self.assertIn("oxygen_sensitivity", data["atmosphere_sensitivities"])
        self.assertIn("perishability", data["thermal_and_storage"])

    def test_lookup_scientific_profile_tomato(self):
        response = self.client.get("/api/v1/data/foods/scientific-lookup?name=Fresh%20Tomato&category=Vegetables")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertEqual(data["commodity_name"], "Fresh Tomato")
        self.assertEqual(data["physicochemical"]["moisture_pct"], 94.5)
        self.assertEqual(data["thermal_and_storage"]["chilling_injury_threshold_c"], 10.0)
        self.assertTrue(data["packaging_prescriptions"]["ethylene_action_required"])
        self.assertIn("Micro-Perforated", data["packaging_prescriptions"]["recommended_barrier_type"])

    def test_lookup_scientific_profile_chips(self):
        response = self.client.get("/api/v1/data/foods/scientific-lookup?name=Potato%20Chips&category=Other%20perishables")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertEqual(data["physicochemical"]["moisture_pct"], 2.0)
        self.assertEqual(data["physicochemical"]["fat_pct"], 33.0)
        self.assertEqual(data["physiological_kinetics"]["respiration_class"], "Non-respiring processed food")
        self.assertIn("Met-PET", data["packaging_prescriptions"]["recommended_barrier_type"])

    def test_scientific_packaging_rules_engine(self):
        # Test 1: Produce with chilling injury warning
        presc1 = ScientificPackagingRulesEngine.derive_prescriptions(
            commodity_name="Fresh Banana",
            category="Fruits",
            moisture_pct=74.9,
            fat_pct=0.3,
            ph=4.8,
            respiration_class="High",
            respiration_rate_20c=45.0,
            ethylene_sensitivity="Extreme",
            chilling_injury_threshold_c=13.0,
            storage_temperature_c=4.0,  # Below threshold!
            eco_friendly=True,
        )
        self.assertTrue(presc1["ethylene_action_required"])
        self.assertIsNotNone(presc1["thermal_warning"])
        self.assertIn("CRITICAL WARNING", presc1["thermal_warning"])

        # Test 2: High fat snack
        presc2 = ScientificPackagingRulesEngine.derive_prescriptions(
            commodity_name="Potato Chips",
            category="Snacks",
            moisture_pct=2.0,
            fat_pct=33.0,
            ph=5.8,
            respiration_class="Non-respiring",
            respiration_rate_20c=0.0,
            ethylene_sensitivity="Insensitive",
            chilling_injury_threshold_c=None,
            storage_temperature_c=22.0,
            eco_friendly=True,
        )
        self.assertFalse(presc2["ethylene_action_required"])
        self.assertIn("Met-PET", presc2["recommended_barrier_type"])

if __name__ == "__main__":
    unittest.main()
