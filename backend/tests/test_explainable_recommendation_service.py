"""
Unit test suite for Explainable AI (XAI) Synthesis Service (Task 1.2 & 1.3).
Tests natural language explanations, advantages, limitations, storage conditions,
applications, and formatted properties across diverse food commodity profiles.
"""

import unittest
from app.core.material_catalog import material_catalog
from app.services.geometry_and_xai import geometry_and_xai_service, ExplainableRecommendationResult


class TestExplainableRecommendationService(unittest.TestCase):

    def setUp(self):
        self.pla_material = material_catalog.get_material_by_id("PLA-EMAP-01") or material_catalog.get_all_materials()[0]
        self.bopp_material = material_catalog.get_material_by_id("MET-BOPP-01") or material_catalog.get_all_materials()[0]
        self.evoh_material = material_catalog.get_material_by_id("EVOH-COEX-01") or material_catalog.get_all_materials()[0]
        self.kraft_material = material_catalog.get_material_by_id("KRAFT-MW-01") or material_catalog.get_all_materials()[0]

    def test_high_respiration_produce_explanation_and_title(self):
        input_data = {
            "name": "Fresh Strawberries",
            "category": "Fruits",
            "moisture": 91.0,
            "respiration_rate_20c": 45.0,
            "respiration_class": "Very High",
            "storage_temp_c": 4.0,
            "chilling_injury_threshold_c": 0.0,
        }

        result = geometry_and_xai_service.generate_explainable_recommendation(
            commodity_name="Fresh Strawberries",
            category="Fruits",
            material=self.pla_material,
            input_data=input_data,
        )

        self.assertIsInstance(result, ExplainableRecommendationResult)
        self.assertEqual(result.packaging_title, "Ventilated Food-Grade Packaging")
        self.assertIn("Micro-Perforated", result.packaging_format)
        
        # User requirement exact phrase check
        expected_phrase = (
            "This option is recommended because the selected food has high respiration and moisture sensitivity, "
            "requiring appropriate gas exchange and moisture management."
        )
        self.assertEqual(result.recommendation_explanation, expected_phrase)

        # Advantages & Limitations
        self.assertTrue(any("EMAP" in a or "Equilibrium" in a for a in result.advantages))
        self.assertTrue(any("Anti-fog" in a for a in result.advantages))
        self.assertTrue(any("vacuum" in l.lower() for l in result.limitations))

        # Storage & Application
        self.assertIn("Refrigerated", result.suitable_storage_condition)
        self.assertIn("berries", result.expected_application.lower())

        # Important properties
        self.assertIn("OTR (Oxygen Barrier)", result.important_properties)
        self.assertIn("WVTR (Moisture Barrier)", result.important_properties)
        self.assertEqual(result.important_properties["Breathability Profile"], "High Gas Exchange")

    def test_high_fat_snacks_nitrogen_flush_prescription(self):
        input_data = {
            "name": "Kettle Potato Chips",
            "category": "Snacks",
            "moisture": 1.5,
            "fat": 34.0,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 22.0,
        }

        result = geometry_and_xai_service.generate_explainable_recommendation(
            commodity_name="Kettle Potato Chips",
            category="Snacks",
            material=self.bopp_material,
            input_data=input_data,
        )

        self.assertEqual(result.packaging_title, "Nitrogen-Flushed High-Barrier Pillow Pouch")
        self.assertIn("Pillow Pouch", result.packaging_format)
        self.assertIn("elevated lipid content and oxidation sensitivity", result.recommendation_explanation)
        self.assertTrue(any("Nitrogen" in a for a in result.advantages))
        self.assertTrue(any("RIC #7" in l or "recycling" in l for l in result.limitations))
        self.assertIn("Potato chips", result.expected_application)
        self.assertIn("Ambient", result.suitable_storage_condition)

    def test_fresh_perishable_protein_vacuum_prescription(self):
        input_data = {
            "name": "Atlantic Salmon Fillet",
            "category": "Seafood",
            "moisture": 72.0,
            "fat": 12.0,
            "storage_temp_c": 2.0,
        }

        result = geometry_and_xai_service.generate_explainable_recommendation(
            commodity_name="Atlantic Salmon Fillet",
            category="Seafood",
            material=self.evoh_material,
            input_data=input_data,
        )

        self.assertEqual(result.packaging_title, "High-Barrier EVOH Vacuum Skin Tray")
        self.assertIn("Vacuum Skin", result.packaging_format)
        self.assertIn("high protein perishability and active microbial flora", result.recommendation_explanation)
        self.assertTrue(any("cross-contamination" in a or "suppresses aerobes" in a for a in result.advantages))
        self.assertTrue(any("cold chain" in l.lower() for l in result.limitations))

    def test_chilling_sensitive_tropical_fruit_preserves_floor(self):
        input_data = {
            "name": "Alphonso Mango",
            "category": "Fruits",
            "moisture": 84.0,
            "respiration_rate_20c": 25.0,
            "chilling_injury_threshold_c": 12.0,
            "storage_temp_c": 5.0,  # Below threshold
        }

        result = geometry_and_xai_service.generate_explainable_recommendation(
            commodity_name="Alphonso Mango",
            category="Fruits",
            material=self.pla_material,
            input_data=input_data,
        )

        self.assertIn("12°C", result.suitable_storage_condition)
        self.assertIn("Chilling Injury", result.suitable_storage_condition)

    def test_important_properties_dictionary_keys_and_values(self):
        input_data = {"name": "Generic Commodity"}
        result = geometry_and_xai_service.generate_explainable_recommendation(
            commodity_name="Generic",
            category="General",
            material=self.pla_material,
            input_data=input_data,
        )

        props = result.important_properties
        required_keys = [
            "OTR (Oxygen Barrier)",
            "WVTR (Moisture Barrier)",
            "Film Thickness",
            "Tensile Strength",
            "Puncture Resistance",
            "Thermal Span",
            "Breathability Profile",
            "Sustainability Rating",
        ]
        for key in required_keys:
            self.assertIn(key, props)
            self.assertTrue(len(props[key]) > 0)


if __name__ == "__main__":
    unittest.main()
