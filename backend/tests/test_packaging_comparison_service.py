"""
Unit Tests for Module 9: Packaging Comparison Service.
Verifies qualitative parameter normalization (High/Medium/Low/Yes),
3-slot comparative matrix assembly, best-in-class identification,
and AI trade-off synthesis.
"""

import unittest
import asyncio
from app.services.packaging_comparison_service import packaging_comparison_service
from app.schemas.packaging_material import PackagingComparisonRequest


class TestPackagingComparisonService(unittest.TestCase):
    def setUp(self):
        self.service = packaging_comparison_service

    def test_qualitative_mappings(self):
        # 1. Moisture Barrier
        self.assertEqual(self.service._qualitative_moisture_barrier(0.5), "High")
        self.assertEqual(self.service._qualitative_moisture_barrier(12.0), "Medium")
        self.assertEqual(self.service._qualitative_moisture_barrier(45.0, is_breathable=True), "High")
        self.assertEqual(self.service._qualitative_moisture_barrier(45.0, is_breathable=False), "Low")

        # 2. Oxygen Barrier
        self.assertEqual(self.service._qualitative_oxygen_barrier(0.05), "High")
        self.assertEqual(self.service._qualitative_oxygen_barrier(1500.0), "Medium")
        self.assertEqual(self.service._qualitative_oxygen_barrier(3500.0, is_breathable=True), "Medium")

        # 3. Gas Exchange
        self.assertEqual(self.service._qualitative_gas_exchange(True, 3500.0), "High")
        self.assertEqual(self.service._qualitative_gas_exchange(False, 0.05), "Low")

        # 4. Strength
        self.assertEqual(self.service._qualitative_strength(32.0, 18.0), "High")
        self.assertEqual(self.service._qualitative_strength(20.0, 14.0), "Medium")
        self.assertEqual(self.service._qualitative_strength(10.0, 8.0), "Low")

        # 5. Recyclability
        self.assertEqual(self.service._qualitative_recyclability(True, False), "Yes")
        self.assertEqual(self.service._qualitative_recyclability(False, True), "Yes")
        self.assertEqual(self.service._qualitative_recyclability(False, False, resin_code="OTHER_7"), "No")

        # 6. Cost Category
        self.assertEqual(self.service._qualitative_cost_category(1.95), "Low")
        self.assertEqual(self.service._qualitative_cost_category(3.85), "Medium")
        self.assertEqual(self.service._qualitative_cost_category(5.50), "High")

    def test_compare_three_materials(self):
        req = PackagingComparisonRequest(
            material_ids=["mat_bio_emap_01", "mat_conv_hdpe_01", "mat_lam_pet_alu_01"],
            food_id=1,
            food_name="Fresh Strawberries",
        )

        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            response = loop.run_until_complete(self.service.compare_materials(req))
        finally:
            loop.close()

        # 1. Validate Slots
        self.assertEqual(len(response.slots), 3)
        slot_a = response.slots[0]
        slot_b = response.slots[1]
        slot_c = response.slots[2]

        self.assertEqual(slot_a.slot_id, "material_a")
        self.assertEqual(slot_a.color_token, "#0D9488")
        self.assertTrue(slot_a.is_primary_recommendation)

        self.assertEqual(slot_b.slot_id, "material_b")
        self.assertEqual(slot_b.color_token, "#0284C7")
        self.assertFalse(slot_b.is_primary_recommendation)

        self.assertEqual(slot_c.slot_id, "material_c")
        self.assertEqual(slot_c.color_token, "#D97706")

        # 2. Validate 6 Core Parameter Rows
        self.assertEqual(len(response.parameter_rows), 6)
        keys = [r.parameter_key for r in response.parameter_rows]
        self.assertIn("moisture_barrier", keys)
        self.assertIn("oxygen_barrier", keys)
        self.assertIn("gas_exchange", keys)
        self.assertIn("strength", keys)
        self.assertIn("recyclability", keys)
        self.assertIn("cost_category", keys)

        # 3. Validate Best In Class
        self.assertIn("Moisture Barrier", response.best_in_class_summary)
        self.assertIn("Strength", response.best_in_class_summary)
        self.assertIn("Cost Category", response.best_in_class_summary)

        # 4. Validate AI Narrative
        self.assertIn("Fresh Strawberries", response.ai_trade_off_synthesis)
        self.assertTrue(len(response.key_recommendation_rule) > 10)

    def test_compare_two_materials_minimal(self):
        req = PackagingComparisonRequest(
            material_ids=["mat_conv_ldpe_01", "mat_conv_pet_01"]
        )

        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            response = loop.run_until_complete(self.service.compare_materials(req))
        finally:
            loop.close()

        self.assertEqual(len(response.slots), 2)
        self.assertEqual(len(response.parameter_rows), 6)
        self.assertIsNone(response.food_context_name)
        self.assertTrue(len(response.ai_trade_off_synthesis) > 10)

    def test_compare_with_unknown_fallback(self):
        req = PackagingComparisonRequest(
            material_ids=["non_existent_mat_abc", "non_existent_mat_xyz"]
        )

        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            response = loop.run_until_complete(self.service.compare_materials(req))
        finally:
            loop.close()

        # Should fall back to catalog entries gracefully
        self.assertGreaterEqual(len(response.slots), 2)
        self.assertEqual(len(response.parameter_rows), 6)


if __name__ == "__main__":
    unittest.main()
