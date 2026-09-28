"""
Integration tests for Sustainability REST API Endpoints (Module 11 - Task 3.1).
Validates HTTP status codes, schema response formatting, error handling,
and multi-material comparison payload processing.
"""

import unittest
from fastapi.testclient import TestClient
from app.main import app


class TestSustainabilityEndpoints(unittest.TestCase):
    """Test suite verifying /api/v1/sustainability routes."""

    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)

    def test_get_material_sustainability_profile(self):
        """Verify GET /api/v1/sustainability/materials/{id} returns 200 and schema."""
        response = self.client.get(
            "/api/v1/sustainability/materials/mat_poly_ldpe_01",
            params={"package_type": "Stand-up Doypack (Bottom Gusset)", "batch_size": 10000},
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["material_id"], "mat_poly_ldpe_01")
        self.assertEqual(data["recyclability"], "Medium")
        self.assertEqual(data["biodegradability"], "Non-Biodegradable")
        self.assertEqual(data["reusability"], "Low")
        self.assertIn("environmental_indicators", data)
        self.assertIn("waste_potential", data)
        self.assertTrue(data["is_empirical_verified"])

    def test_post_evaluate_sustainability(self):
        """Verify POST /api/v1/sustainability/evaluate performs dynamic parametric LCA."""
        payload = {
            "material_id": "mat_pet_bo_04",
            "package_type": "Thermoformed Tray / Clamshell",
            "length_cm": 20.0,
            "width_cm": 15.0,
            "depth_or_gusset_cm": 5.0,
            "thickness_microns": 250.0,
            "batch_size_units": 25000,
            "pcr_percentage": 30.0,
        }
        response = self.client.post("/api/v1/sustainability/evaluate", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["material_id"], "mat_pet_bo_04")
        self.assertEqual(data["recyclability"], "High")
        self.assertAlmostEqual(data["pcr_content_pct"], 30.0)
        self.assertGreater(data["environmental_indicators"]["carbon_footprint_kg_co2e_total_batch"], 10.0)
        self.assertGreater(data["environmental_indicators"]["pcr_carbon_reduction_pct"], 5.0)

    def test_post_compare_sustainability(self):
        """Verify POST /api/v1/sustainability/compare returns multi-material analysis."""
        payload = {
            "material_ids": ["mat_poly_ldpe_01", "mat_bio_emap_01", "mat_rpet_50_05"],
            "package_type": "Stand-up Doypack (Bottom Gusset)",
            "length_cm": 18.0,
            "width_cm": 12.0,
            "depth_or_gusset_cm": 4.0,
            "thickness_microns": 50.0,
            "batch_size_units": 10000,
        }
        response = self.client.post("/api/v1/sustainability/compare", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(len(data["materials"]), 3)
        self.assertTrue(data["best_recyclability_material_id"] in payload["material_ids"])
        self.assertTrue(data["lowest_carbon_material_id"] in payload["material_ids"])
        self.assertTrue(data["lowest_waste_material_id"] in payload["material_ids"])
        self.assertTrue(len(data["eco_tradeoff_summary"]) > 10)

    def test_get_sustainability_matrix(self):
        """Verify GET /api/v1/sustainability/matrix returns complete library."""
        response = self.client.get("/api/v1/sustainability/matrix")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIsInstance(data, list)
        self.assertGreaterEqual(len(data), 7)
        first = data[0]
        self.assertIn("material_id", first)
        self.assertIn("gwp_virgin_kg_co2e_per_kg", first)
        self.assertIn("water_intensity_l_per_kg", first)


if __name__ == "__main__":
    unittest.main()
