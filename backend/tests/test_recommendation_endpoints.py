"""
Integration test suite for POST /api/v1/packaging/recommend and GET /api/v1/packaging/history (Task 2.3).
Tests endpoint schemas, multi-material recommendations, alternatives, box geometry,
and XAI rationales using FastAPI TestClient.
"""

import unittest
from starlette.testclient import TestClient
from app.main import app


class TestPackagingRecommendationEndpoints(unittest.TestCase):

    def setUp(self):
        self.client = TestClient(app)

    def test_post_recommend_tomato_hybrid_payload(self):
        payload = {
            "food_name": "Fresh Tomato",
            "category": "Vegetables",
            "quantity": 5.0,
            "unit": "kg",
            "storage_condition": "refrigerated",
            "storage_temp_c": 12.0,
            "duration": 21,
            "is_fragile": True,
            "eco_friendly_priority": True,
            "moisture": 94.5,
            "fat": 0.2,
            "ph": 4.4,
            "respiration_class": "High",
            "respiration_rate_20c": 45.0,
            "ethylene_sensitivity": "High",
            "chilling_injury_threshold_c": 10.0,
        }
        response = self.client.post("/api/v1/packaging/recommend", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()

        # 1. Structure Assertions
        self.assertIn("recommendation_id", data)
        self.assertIn("primary_recommendation", data)
        self.assertIn("alternatives", data)
        self.assertIn("box_geometry", data)
        self.assertIn("scientific_rationale", data)

        # 2. Primary Recommendation & Explainability
        primary = data["primary_recommendation"]
        self.assertIn("material_name", primary)
        self.assertIn("barrier_profile", primary)
        self.assertEqual(primary["packaging_title"], "Ventilated Food-Grade Packaging")
        self.assertIn("Micro-Perforated", primary["packaging_format"])
        self.assertIn("high respiration and moisture sensitivity", primary["recommendation_explanation"])
        self.assertGreaterEqual(len(primary["advantages"]), 2)
        self.assertGreaterEqual(len(primary["limitations"]), 2)
        self.assertIn("RH", primary["suitable_storage_condition"])
        self.assertIn("produce", primary["expected_application"].lower())
        self.assertIn("OTR (Oxygen Barrier)", primary["important_properties"])
        self.assertIn("WVTR (Moisture Barrier)", primary["important_properties"])
        self.assertGreater(primary["sustainability_score"], 80.0)
        self.assertGreater(primary["suitability_score"], 0.50)
        self.assertTrue(len(primary["active_additives"]) >= 2)

        # 3. Alternatives
        alts = data["alternatives"]
        self.assertGreaterEqual(len(alts), 2)
        alt_types = [a["type"] for a in alts]
        self.assertIn("ECO_FRIENDLY", alt_types)
        for a in alts:
            self.assertIn("trade_off_summary", a)
            self.assertGreater(a["estimated_unit_cost_inr"], 0)

        # 4. Box Geometry
        geom = data["box_geometry"]
        self.assertGreater(geom["length_cm"], 0)
        self.assertGreater(geom["width_cm"], 0)
        self.assertGreater(geom["height_cm"], 0)
        self.assertGreaterEqual(geom["space_utilization_pct"], 50.0)
        self.assertIn("cushioning_material", geom)

        # 5. Scientific Rationale
        xai = data["scientific_rationale"]
        self.assertIn("summary", xai)
        self.assertGreaterEqual(len(xai["key_drivers"]), 2)

        # 6. Backward compatibility fields
        self.assertIn("recommended_box_type", data)
        self.assertIn("recommended_dimensions", data)
        self.assertIn("space_utilization_pct", data)

    def test_post_recommend_potato_chips_overrides(self):
        payload = {
            "food_name": "Potato Chips",
            "category": "Snacks",
            "quantity": 1.0,
            "is_fragile": True,
            "eco_friendly_priority": False,
            "custom_overrides": {
                "moisture_pct": 1.8,
                "fat_pct": 35.0,
                "ph": 6.2,
            }
        }
        response = self.client.post("/api/v1/packaging/recommend", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        primary = data["primary_recommendation"]
        self.assertEqual(primary["packaging_title"], "Nitrogen-Flushed High-Barrier Pillow Pouch")
        self.assertIn("elevated lipid content and oxidation sensitivity", primary["recommendation_explanation"])
        self.assertTrue(any("Nitrogen" in a for a in primary["advantages"]))
        self.assertTrue(any("Nitrogen" in a for a in primary["active_additives"]))

    def test_get_history_endpoint(self):
        response = self.client.get("/api/v1/packaging/history")
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.json(), list)


if __name__ == "__main__":
    unittest.main()
