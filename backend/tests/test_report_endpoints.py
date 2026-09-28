"""
Integration tests for Recommendation Report REST API Endpoints (Module 12: Recommendation Report).
Verifies POST /api/v1/reports/generate, POST /api/v1/reports/markdown, and GET /api/v1/reports/{report_id}.
"""

import unittest
from fastapi.testclient import TestClient
from app.main import app


class TestReportEndpoints(unittest.TestCase):
    """Test suite verifying /api/v1/reports routes and response structures."""

    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)

    def test_generate_report_endpoint(self):
        """Verify POST /api/v1/reports/generate returns 200 and a complete RecommendationReportModel."""
        payload = {
            "food_name": "Fresh Tomato",
            "category": "Vegetables",
            "fill_quantity": "500g",
            "batch_size_units": 10000,
            "length_cm": 18.0,
            "width_cm": 12.0,
            "depth_or_gusset_cm": 4.0,
            "thickness_microns": 35.0,
            "pcr_percentage": 25.0,
            "target_shelf_life_days": 21,
            "storage_condition": "Refrigerated (4°C - 8°C)",
        }
        response = self.client.post("/api/v1/reports/generate", json=payload)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertTrue(data["report_id"].startswith("SPK-"))
        self.assertEqual(data["engine_version"], "SmartPack AI Engine v2.4-Hybrid")
        self.assertIsNotNone(data["verification_hash"])
        self.assertEqual(len(data["verification_hash"]), 64)

        # Verify Food Context & Properties
        self.assertEqual(data["food_context"]["name"], "Fresh Tomato")
        self.assertEqual(data["food_context"]["fill_quantity"], "500g")
        self.assertEqual(data["food_context"]["transport_mode"], "Refrigerated Cold Chain")
        self.assertGreater(data["food_properties"]["moisture_pct"], 80.0)

        # Verify Primary Prescription & Rationale
        self.assertIn("material_name", data["primary_prescription"])
        self.assertGreater(data["primary_prescription"]["tensile_strength_mpa"], 0.0)
        self.assertTrue(len(data["explainable_rationale"]) > 20)
        self.assertGreaterEqual(len(data["key_drivers"]), 3)

        # Verify 3-Way Alternatives
        self.assertEqual(len(data["alternatives"]), 3)
        tier_names = [a["tier_name"] for a in data["alternatives"]]
        self.assertIn("Eco-Champion", tier_names)
        self.assertIn("Economy", tier_names)
        self.assertIn("High-Barrier", tier_names)

        # Verify LCA & Cost Summaries
        self.assertGreater(data["lca_summary"]["carbon_footprint_g_per_unit"], 0.0)
        self.assertGreater(data["lca_summary"]["water_footprint_l_per_unit"], 0.0)
        self.assertEqual(data["lca_summary"]["pcr_percentage"], 25.0)
        self.assertGreater(data["cost_summary"]["estimated_cost_per_unit_inr"], 0.0)
        self.assertGreater(data["cost_summary"]["estimated_batch_cost_inr"], 0.0)
        self.assertGreaterEqual(len(data["standards_and_citations"]), 3)

    def test_generate_markdown_endpoint(self):
        """Verify POST /api/v1/reports/markdown returns 200 and formatted Markdown text."""
        payload = {
            "food_name": "Roasted Coffee Beans",
            "category": "Beverages & Dry Powders",
            "fill_quantity": "1kg",
            "batch_size_units": 5000,
            "length_cm": 24.0,
            "width_cm": 16.0,
            "depth_or_gusset_cm": 6.0,
            "thickness_microns": 70.0,
            "pcr_percentage": 0.0,
            "target_shelf_life_days": 365,
            "storage_condition": "Ambient Standard",
            "selected_material_id": "mat_al_foil_lam_13",
        }
        response = self.client.post("/api/v1/reports/markdown", json=payload)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertTrue(data["report_id"].startswith("SPK-"))
        markdown_text = data["markdown_content"]
        self.assertIn("# 📄 SmartPack AI Packaging Recommendation Specification Report", markdown_text)
        self.assertIn("Roasted Coffee Beans", markdown_text)
        self.assertIn("## 1. Food Commodity Context & Operational Parameters", markdown_text)
        self.assertIn("## 6. Environmental Sustainability & Life Cycle Assessment (LCA) Impact", markdown_text)
        self.assertIn("## 7. Converter Cost Economics Baseline", markdown_text)

    def test_get_report_by_id_endpoint(self):
        """Verify GET /api/v1/reports/{report_id} returns cached and fallback synthesized reports."""
        # 1. First generate a report to cache it
        payload = {
            "food_name": "Potato Chips",
            "category": "Snacks & Wafers",
            "fill_quantity": "150g",
            "batch_size_units": 20000,
            "target_shelf_life_days": 180,
            "storage_condition": "Ambient Standard",
        }
        gen_res = self.client.post("/api/v1/reports/generate", json=payload)
        self.assertEqual(gen_res.status_code, 200)
        report_id = gen_res.json()["report_id"]

        # 2. Retrieve the report by ID
        get_res = self.client.get(f"/api/v1/reports/{report_id}")
        self.assertEqual(get_res.status_code, 200)
        retrieved_data = get_res.json()
        self.assertEqual(retrieved_data["report_id"], report_id)
        self.assertEqual(retrieved_data["food_context"]["name"], "Potato Chips")

        # 3. Retrieve arbitrary valid report ID to trigger fallback synthesis
        fallback_res = self.client.get("/api/v1/reports/SPK-2026-UNKNOWN")
        self.assertEqual(fallback_res.status_code, 200)
        fallback_data = fallback_res.json()
        self.assertEqual(fallback_data["report_id"], "SPK-2026-UNKNOWN")
        self.assertIsNotNone(fallback_data["primary_prescription"])

    def test_generate_report_validation_error(self):
        """Verify POST /api/v1/reports/generate returns 422 on invalid schema."""
        # Missing required food_name
        invalid_payload = {
            "fill_quantity": "500g",
        }
        response = self.client.post("/api/v1/reports/generate", json=invalid_payload)
        self.assertEqual(response.status_code, 422)


if __name__ == "__main__":
    unittest.main()
