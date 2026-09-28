"""
Integration Test Suite for Packaging Material Database Endpoints (/api/v1/materials).
Tests filtering, detail retrieval, custom material creation, update, category summaries,
and multi-material side-by-side radar comparison.
"""

import unittest
import sys
import os

backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from starlette.testclient import TestClient
from app.main import app


class TestPackagingMaterialsEndpoints(unittest.TestCase):
    """Verifies REST API endpoints for Module 6: Packaging Material Database."""

    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)

    def test_list_materials_default(self):
        """Verify list endpoint returns catalog materials with full 12-property profiles."""
        response = self.client.get("/api/v1/materials?limit=20")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIsInstance(data, list)
        self.assertGreaterEqual(len(data), 20)

        first = data[0]
        self.assertIn("material_id", first)
        self.assertIn("name", first)
        self.assertIn("category", first)
        self.assertIn("barrier_profile", first)
        self.assertIn("mechanical_profile", first)
        self.assertIn("thermal_profile", first)
        self.assertIn("optical_profile", first)
        self.assertIn("environmental_profile", first)
        self.assertIn("economic_profile", first)
        self.assertIn("radar_scores", first)

        # Radar scores check
        radar = first["radar_scores"]
        self.assertIn("barrier_score", radar)
        self.assertIn("mechanical_score", radar)
        self.assertIn("sustainability_score", radar)
        self.assertIn("thermal_score", radar)
        self.assertIn("cost_efficiency_score", radar)
        self.assertIn("optical_score", radar)

    def test_filter_materials_by_search_and_category(self):
        """Test search query and domain category filtering."""
        # 1. Search for 'kraft'
        res = self.client.get("/api/v1/materials?search=kraft")
        self.assertEqual(res.status_code, 200)
        results = res.json()
        self.assertGreaterEqual(len(results), 1)
        self.assertTrue(any("kraft" in m["name"].lower() or "kraft" in m["structure"].lower() for m in results))

        # 2. Category filter for 'Biodegradable'
        res_cat = self.client.get("/api/v1/materials?category=Biodegradable")
        self.assertEqual(res_cat.status_code, 200)
        bio_results = res_cat.json()
        self.assertGreaterEqual(len(bio_results), 3)
        for m in bio_results:
            self.assertIn("biodegradable", m["category"].lower())

    def test_filter_by_functional_properties(self):
        """Test filtering by barrier bounds, biodegradability, recyclability, and retort grade."""
        # Biodegradable
        res_bio = self.client.get("/api/v1/materials?is_biodegradable=true")
        self.assertEqual(res_bio.status_code, 200)
        bio_items = res_bio.json()
        self.assertGreater(len(bio_items), 0)
        for item in bio_items:
            self.assertTrue(item["environmental_profile"]["is_biodegradable"])

        # High barrier (max_otr <= 2.0)
        res_barrier = self.client.get("/api/v1/materials?max_otr=2.0")
        self.assertEqual(res_barrier.status_code, 200)
        barrier_items = res_barrier.json()
        self.assertGreater(len(barrier_items), 0)
        for item in barrier_items:
            self.assertLessEqual(item["barrier_profile"]["otr_cc_m2_day"], 2.0)

    def test_get_categories_summary(self):
        """Test categories grouping endpoint."""
        response = self.client.get("/api/v1/materials/categories")
        self.assertEqual(response.status_code, 200)
        categories = response.json()
        self.assertIsInstance(categories, list)
        self.assertGreaterEqual(len(categories), 5)
        for cat in categories:
            self.assertIn("category", cat)
            self.assertIn("count", cat)
            self.assertIn("sample_materials", cat)
            self.assertIn("average_sustainability", cat)
            self.assertGreater(cat["count"], 0)

    def test_get_material_detail_by_id(self):
        """Test single material detail endpoint with valid and invalid IDs."""
        # Valid ID
        response = self.client.get("/api/v1/materials/mat_al_foil_lam_13")
        self.assertEqual(response.status_code, 200)
        mat = response.json()
        self.assertEqual(mat["material_id"], "mat_al_foil_lam_13")
        self.assertEqual(mat["category"], "High-Barrier Laminate")
        self.assertLessEqual(mat["barrier_profile"]["otr_cc_m2_day"], 0.1)

        # Invalid ID -> 404
        bad_response = self.client.get("/api/v1/materials/non_existent_material_xyz")
        self.assertEqual(bad_response.status_code, 404)

    def test_create_and_update_custom_material(self):
        """Test creating a custom material and subsequent updates."""
        custom_payload = {
            "material_id": "mat_custom_mushroom_mycelium",
            "name": "Bio-Composite Mycelium Cushioning",
            "category": "Biodegradable Bio-Polymer",
            "polymer_family": "Molded Mycelium",
            "structure": "Agricultural Waste / Fungal Mycelium Matrix",
            "form_factor": "Molded Cushion Box",
            "thickness_microns": 15000.0,
            "otr_cc_m2_day": 850.0,
            "wvtr_g_m2_day": 120.0,
            "tensile_strength_mpa": 14.5,
            "puncture_resistance_n": 85.0,
            "elongation_pct": 12.0,
            "sustainability_score": 99.0,
            "recyclability_score": 100.0,
            "biodegradability_score": 100.0,
            "estimated_unit_cost_inr": 8.50,
            "temp_min_c": -15.0,
            "temp_max_c": 80.0,
            "thermal_class": "Ambient Shock Absorber",
            "uv_transmittance_pct": 0.0,
            "optical_clarity": "Opaque",
            "is_breathable": True,
            "is_biodegradable": True,
            "is_recyclable": True,
            "is_retort_grade": False,
            "is_cryogenic_grade": False,
            "gas_flush_compatible": False,
            "cost_category": "Premium Barrier",
            "resin_code": "PAP_22",
            "composting_standard": "EN 13432 / Home Compostable",
            "recommended_applications": ["Fragile glass protection", "Luxury organic cosmetics", "Electronics shipping"],
            "regulatory_certifications": ["FSSAI Secondary Pack", "OK Compost Home"],
            "notes": "100% home compostable mushroom mycelium protective packaging."
        }

        # POST /materials
        create_res = self.client.post("/api/v1/materials", json=custom_payload)
        self.assertEqual(create_res.status_code, 201)
        created_data = create_res.json()
        self.assertEqual(created_data["material_id"], "mat_custom_mushroom_mycelium")
        self.assertEqual(created_data["name"], "Bio-Composite Mycelium Cushioning")
        self.assertEqual(created_data["radar_scores"]["sustainability_score"], 99.0)

        # Retrieve newly created material
        get_res = self.client.get("/api/v1/materials/mat_custom_mushroom_mycelium")
        self.assertEqual(get_res.status_code, 200)
        self.assertEqual(get_res.json()["name"], "Bio-Composite Mycelium Cushioning")

        # Update material via PUT
        custom_payload["name"] = "Bio-Composite Mycelium Ultra-Cushioning"
        custom_payload["estimated_unit_cost_inr"] = 7.90
        put_res = self.client.put("/api/v1/materials/mat_custom_mushroom_mycelium", json=custom_payload)
        self.assertEqual(put_res.status_code, 200)
        self.assertEqual(put_res.json()["name"], "Bio-Composite Mycelium Ultra-Cushioning")
        self.assertEqual(put_res.json()["economic_profile"]["estimated_unit_cost_inr"], 7.90)

    def test_compare_materials_endpoint(self):
        """Test multi-material side-by-side comparison and radar profile compilation."""
        payload = {
            "material_ids": [
                "mat_bio_emap_01",
                "mat_al_foil_lam_13",
                "mat_sbs_paperboard_22"
            ]
        }
        response = self.client.post("/api/v1/materials/compare", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertIn("materials", data)
        self.assertEqual(len(data["materials"]), 3)
        self.assertIn("radar_datasets", data)
        self.assertEqual(len(data["radar_datasets"]), 3)
        self.assertIn("best_in_class_highlights", data)
        self.assertIn("trade_off_analysis", data)
        self.assertGreater(len(data["trade_off_analysis"]), 0)

        # Check best in class highlights keys
        highlights = data["best_in_class_highlights"]
        self.assertIn("Highest Barrier", highlights)
        self.assertIn("Most Eco-Friendly", highlights)


if __name__ == "__main__":
    unittest.main()
