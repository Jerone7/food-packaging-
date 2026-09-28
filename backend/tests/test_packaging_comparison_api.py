"""
Integration tests for Packaging Comparison REST API Endpoint (Module 9 - Task 2.2).
Validates HTTP POST /api/v1/packaging/compare request/response cycles,
3-material matrix data contracts, 6 core parameters, and error handling.
"""

import unittest
from starlette.testclient import TestClient
from app.main import app


class TestPackagingComparisonAPI(unittest.TestCase):
    """Integration test suite for POST /api/v1/packaging/compare."""

    def setUp(self):
        self.client = TestClient(app)

    def test_compare_three_materials_success(self):
        payload = {
            "material_ids": [
                "mat_bio_emap_01",
                "mat_conv_hdpe_01",
                "mat_lam_pet_alu_01",
            ],
            "food_id": 1,
            "food_name": "Fresh Strawberries",
        }

        response = self.client.post("/api/v1/packaging/compare", json=payload)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertIn("comparison_id", data)
        self.assertEqual(data["food_context_name"], "Fresh Strawberries")

        # 1. Validate Slots (3 slots)
        slots = data["slots"]
        self.assertEqual(len(slots), 3)
        self.assertEqual(slots[0]["slot_id"], "material_a")
        self.assertEqual(slots[0]["color_token"], "#0D9488")
        self.assertTrue(slots[0]["is_primary_recommendation"])

        self.assertEqual(slots[1]["slot_id"], "material_b")
        self.assertEqual(slots[1]["color_token"], "#0284C7")

        self.assertEqual(slots[2]["slot_id"], "material_c")
        self.assertEqual(slots[2]["color_token"], "#D97706")

        # 2. Validate Parameter Rows (6 rows)
        rows = data["parameter_rows"]
        self.assertEqual(len(rows), 6)
        row_keys = [r["parameter_key"] for r in rows]
        self.assertIn("moisture_barrier", row_keys)
        self.assertIn("oxygen_barrier", row_keys)
        self.assertIn("gas_exchange", row_keys)
        self.assertIn("strength", row_keys)
        self.assertIn("recyclability", row_keys)
        self.assertIn("cost_category", row_keys)

        # Check qualitative values map
        mb_row = next(r for r in rows if r["parameter_key"] == "moisture_barrier")
        self.assertIn("material_a", mb_row["values"])
        self.assertIn("material_b", mb_row["values"])
        self.assertIn("material_c", mb_row["values"])

        # 3. Validate Highlights and AI Synthesis
        self.assertIn("best_in_class_summary", data)
        self.assertIn("ai_trade_off_synthesis", data)
        self.assertIn("key_recommendation_rule", data)
        self.assertTrue(len(data["ai_trade_off_synthesis"]) > 20)

    def test_compare_two_materials_success(self):
        payload = {
            "material_ids": [
                "mat_conv_ldpe_01",
                "mat_conv_pet_01",
            ]
        }

        response = self.client.post("/api/v1/packaging/compare", json=payload)
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertEqual(len(data["slots"]), 2)
        self.assertEqual(len(data["parameter_rows"]), 6)
        self.assertIsNone(data["food_context_name"])

    def test_compare_invalid_material_counts(self):
        # 1 material (less than 2) should return 422
        resp_1 = self.client.post("/api/v1/packaging/compare", json={"material_ids": ["mat_1"]})
        self.assertEqual(resp_1.status_code, 422)

        # 4 materials (more than 3) should return 422
        resp_4 = self.client.post(
            "/api/v1/packaging/compare",
            json={"material_ids": ["mat_1", "mat_2", "mat_3", "mat_4"]},
        )
        self.assertEqual(resp_4.status_code, 422)

        # Empty list should return 422
        resp_empty = self.client.post("/api/v1/packaging/compare", json={"material_ids": []})
        self.assertEqual(resp_empty.status_code, 422)


if __name__ == "__main__":
    unittest.main()
