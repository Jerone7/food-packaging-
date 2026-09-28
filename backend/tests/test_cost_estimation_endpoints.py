"""
Integration tests for Cost Estimation REST API Endpoints (Module 10 - Phase 3).
Tests POST /api/v1/packaging/cost-estimate and GET /api/v1/packaging/cost-parameters.
"""

import unittest
from fastapi.testclient import TestClient
from app.main import app


class TestCostEstimationEndpoints(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_post_cost_estimate_success(self):
        """Test successful cost estimation calculation via REST endpoint."""
        payload = {
            "material_id": "MAT_BIO_001",
            "material_name": "NatureFlex Regenerated Cellulose",
            "packaging_type": "Stand-up Doypack",
            "dimensions": {
                "length_cm": 20.0,
                "width_cm": 14.0,
                "depth_or_gusset_cm": 6.0,
                "thickness_microns": 45.0,
            },
            "product_fill_quantity": "500g",
            "number_of_packages": 10000,
            "selected_addons": [
                "Resealable Zipper",
                "One-Way Degassing Valve",
            ],
            "custom_material_cost_per_kg": 420.0,
            "custom_scrap_rate_percent": 6.0,
            "include_tooling_amortization": True,
        }

        response = self.client.post("/api/v1/packaging/cost-estimate", json=payload)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertEqual(data["material_name"], "NatureFlex Regenerated Cellulose")
        self.assertEqual(data["packaging_type"], "Stand-up Doypack")
        self.assertEqual(data["number_of_packages"], 10000)
        self.assertTrue(data["is_estimated"])
        self.assertIn("ESTIMATED BASELINE", data["disclaimer_notice"])
        self.assertGreater(data["cost_per_unit_inr"], 0)
        self.assertGreater(data["total_estimated_cost_inr"], 0)

        # Check material footprint
        mat_req = data["material_requirement"]
        self.assertAlmostEqual(mat_req["surface_area_per_unit_sqm"], 0.075075, places=4)
        self.assertGreater(mat_req["gross_weight_required_kg"], 0)

        # Check breakdown
        self.assertGreater(len(data["cost_breakdown"]), 0)
        self.assertEqual(len(data["volume_tier_sensitivity"]), 5)

    def test_post_cost_estimate_invalid_dimensions(self):
        """Test 422 validation error when negative or zero dimensions are sent."""
        payload = {
            "material_name": "LDPE Polyethylene",
            "packaging_type": "Pillow Pouch",
            "dimensions": {
                "length_cm": -10.0,
                "width_cm": 15.0,
            },
            "number_of_packages": 5000,
        }
        response = self.client.post("/api/v1/packaging/cost-estimate", json=payload)
        self.assertEqual(response.status_code, 422)

    def test_post_cost_estimate_invalid_form_factor(self):
        """Test 422 validation error when unknown form factor is sent."""
        payload = {
            "material_name": "LDPE Polyethylene",
            "packaging_type": "NonExistentPouchType",
            "dimensions": {
                "length_cm": 20.0,
                "width_cm": 15.0,
            },
            "number_of_packages": 5000,
        }
        response = self.client.post("/api/v1/packaging/cost-estimate", json=payload)
        self.assertEqual(response.status_code, 422)

    def test_get_cost_parameters_success(self):
        """Test GET /api/v1/packaging/cost-parameters returns reference configuration."""
        response = self.client.get("/api/v1/packaging/cost-parameters")
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn("standard_form_factors", data)
        self.assertIn("polymer_densities_kg_m3", data)
        self.assertIn("default_material_prices_inr_per_kg", data)
        self.assertIn("addons_pricing_inr", data)
        self.assertIn("volume_discount_tiers", data)

        self.assertIn("Pillow Pouch", data["standard_form_factors"])
        self.assertEqual(len(data["volume_discount_tiers"]), 4)


if __name__ == "__main__":
    unittest.main()
