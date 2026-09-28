"""
Integration tests for Alternative Packaging REST API Endpoint (Module 8 - Task 2.2).
Validates HTTP POST /api/v1/packaging/recommend response payload structure,
multi-candidate portfolio completeness, star ratings, characteristics, and comparison summary.
"""

import unittest
from starlette.testclient import TestClient
from app.main import app


class TestAlternativePackagingAPI(unittest.TestCase):
    """Test suite for REST API multi-option packaging recommendation endpoints."""

    def setUp(self):
        self.client = TestClient(app)

    def test_recommend_endpoint_returns_rich_alternatives_portfolio(self):
        """Verify POST /api/v1/packaging/recommend returns structured alternatives array."""
        payload = {
            "food_name": "Fresh Strawberries",
            "category": "Fruits",
            "quantity": 5.0,
            "moisture": 91.0,
            "fat": 0.3,
            "ph": 3.6,
            "respiration_rate_20c": 55.0,
            "respiration_class": "Extreme",
            "ethylene_sensitivity": "High",
            "storage_temp_c": 4.0,
            "duration": 14,
            "is_fragile": True,
            "eco_friendly_priority": True,
        }

        response = self.client.post("/api/v1/packaging/recommend", json=payload)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn("recommendation_id", data)
        self.assertIn("primary_recommendation", data)
        self.assertIn("alternatives", data)
        self.assertIn("comparison_summary", data)

        alternatives = data["alternatives"]
        self.assertGreaterEqual(len(alternatives), 2)

        # Verify candidate 1 (Eco-Champion)
        eco_cand = next((a for a in alternatives if a["type"] == "ECO_FRIENDLY"), None)
        self.assertIsNotNone(eco_cand)
        self.assertEqual(eco_cand["star_rating"], 4)
        self.assertEqual(eco_cand["star_display"], "★★★★☆")
        self.assertEqual(eco_cand["suitability_category"], "High Compatibility")
        self.assertGreaterEqual(eco_cand["model_derived_probability"], 0.50)
        self.assertLessEqual(eco_cand["model_derived_probability"], 1.0)
        self.assertIn("characteristics", eco_cand)
        self.assertIn("otr", eco_cand["characteristics"])
        self.assertIn("wvtr", eco_cand["characteristics"])
        self.assertIn("cost_tier", eco_cand["characteristics"])
        self.assertTrue(len(eco_cand["advantages"]) > 0)
        self.assertTrue(len(eco_cand["limitations"]) > 0)

        # Verify candidate 2 (Economy)
        econ_cand = next((a for a in alternatives if a["type"] == "ECONOMY"), None)
        self.assertIsNotNone(econ_cand)
        self.assertEqual(econ_cand["star_rating"], 3)
        self.assertEqual(econ_cand["star_display"], "★★★☆☆")
        self.assertEqual(econ_cand["suitability_category"], "Moderate Compatibility")

        # Verify comparison summary
        summary = data["comparison_summary"]
        self.assertEqual(summary["candidate_count"], len(alternatives) + 1)
        self.assertIsNotNone(summary["primary_material"])
        self.assertIsNotNone(summary["eco_champion"])

    def test_recommend_endpoint_chips_portfolio(self):
        """Verify potato chips endpoint response contains snack-specific alternatives."""
        payload = {
            "food_name": "Potato Chips",
            "category": "Snacks",
            "quantity": 1.0,
            "moisture": 1.8,
            "fat": 35.0,
            "ph": 6.2,
            "storage_temp_c": 22.0,
            "duration": 180,
            "is_fragile": True,
            "eco_friendly_priority": False,
        }

        response = self.client.post("/api/v1/packaging/recommend", json=payload)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        alternatives = data["alternatives"]
        self.assertGreaterEqual(len(alternatives), 2)

        for alt in alternatives:
            self.assertIn(alt["star_rating"], [3, 4, 5])
            self.assertIn("cc/m²/day", alt["characteristics"]["otr"])
            self.assertIn("g/m²/day", alt["characteristics"]["wvtr"])
            self.assertGreater(alt["characteristics"]["thickness_microns"], 0)
            self.assertGreater(alt["characteristics"]["estimated_cost_inr"], 0)


if __name__ == "__main__":
    unittest.main()
