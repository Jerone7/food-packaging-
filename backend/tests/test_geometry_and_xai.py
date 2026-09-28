"""
Unit tests for BoxGeometryAndXAIService (Task 2.1).
Validates golden-ratio 3D box dimensional calculations, bulk density adaptation,
space utilization efficiency, cushioning selection, and XAI scientific rationale generation.
"""

import unittest
from app.services.geometry_and_xai import (
    BoxGeometryAndXAIService,
    geometry_and_xai_service,
)
from app.core.material_catalog import PACKAGING_CATALOG


class TestBoxGeometryAndXAIService(unittest.TestCase):

    def test_box_geometry_fresh_tomato(self):
        geom = BoxGeometryAndXAIService.calculate_box_geometry(
            quantity_kg=5.0,
            category="Vegetables",
            commodity_name="Fresh Tomato",
            is_fragile=True,
            storage_temp_c=12.0,
        )
        self.assertGreater(geom.length_cm, 0)
        self.assertGreater(geom.width_cm, 0)
        self.assertGreater(geom.height_cm, 0)
        # Golden ratio check: L = 1.618 * W, H = 0.8 * W
        self.assertAlmostEqual(geom.length_cm / geom.width_cm, 1.618, delta=0.1)
        self.assertAlmostEqual(geom.height_cm / geom.width_cm, 0.8, delta=0.1)
        self.assertGreaterEqual(geom.space_utilization_pct, 50.0)
        self.assertLessEqual(geom.space_utilization_pct, 95.0)
        # Fragile + Ambient/Mild temp
        self.assertIn("Kraft", geom.cushioning_material)

    def test_box_geometry_cold_chain_chicken(self):
        geom = BoxGeometryAndXAIService.calculate_box_geometry(
            quantity_kg=2.0,
            category="Meat",
            commodity_name="Fresh Chicken Breast",
            is_fragile=True,
            storage_temp_c=2.0,
        )
        # Cold temp (2.0°C <= 8.0°C) + fragile
        self.assertIn("Thermal Insulated", geom.cushioning_material)
        self.assertIn("Gel Pack", geom.cushioning_material)

    def test_scientific_rationale_tomato(self):
        material = PACKAGING_CATALOG[0]  # Micro-perforated MAP PLA/PBAT
        tomato_data = {
            "name": "Fresh Tomato",
            "category": "Vegetables",
            "moisture_pct": 94.5,
            "fat_pct": 0.2,
            "ph": 4.4,
            "respiration_rate_20c": 45.0,
            "respiration_class": "High",
            "ethylene_sensitivity": "High",
            "chilling_injury_threshold_c": 10.0,
            "storage_temp_c": 12.0,
        }
        additives = [
            "Potassium Permanganate (KMnO₄) Ethylene Scavenger Sachet",
            "Antifog Surface Surfactant Coating",
        ]
        xai = BoxGeometryAndXAIService.generate_scientific_rationale(
            commodity_name="Fresh Tomato",
            category="Vegetables",
            material=material,
            input_data=tomato_data,
            active_additives=additives,
        )
        self.assertIn("Tomato", xai.summary)
        self.assertGreaterEqual(len(xai.key_drivers), 3)
        # Verify specific biochemical drivers exist in output
        self.assertTrue(any("respiration" in d.lower() for d in xai.key_drivers))
        self.assertTrue(any("anti-fog" in d.lower() or "moisture" in d.lower() for d in xai.key_drivers))
        self.assertTrue(any("ethylene" in d.lower() or "kmno₄" in d.lower() for d in xai.key_drivers))

    def test_scientific_rationale_chilling_warning(self):
        material = PACKAGING_CATALOG[0]
        banana_data = {
            "name": "Banana",
            "category": "Fruits",
            "moisture_pct": 75.0,
            "fat_pct": 0.3,
            "respiration_rate_20c": 35.0,
            "chilling_injury_threshold_c": 13.0,
            "storage_temp_c": 5.0,  # Below CI threshold!
        }
        xai = BoxGeometryAndXAIService.generate_scientific_rationale(
            commodity_name="Banana",
            category="Fruits",
            material=material,
            input_data=banana_data,
            active_additives=[],
        )
        self.assertTrue(any("CRITICAL WARNING" in d for d in xai.key_drivers), "Must generate chilling injury warning")


if __name__ == "__main__":
    unittest.main()
