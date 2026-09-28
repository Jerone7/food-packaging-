"""
Unit Tests for Admin Domain Service (Module 15 - Task 1.3).
Validates analytics aggregation, dynamic rules, ML model registry, audit logs, and catalog CRUD.
"""

import unittest
from datetime import datetime, timezone

from app.services.admin_service import AdminService
from app.schemas.admin import (
    RuleThresholdUpdate,
    AdminFoodCreate,
    AdminFoodUpdate,
    AdminMaterialCreate,
    AdminMaterialUpdate,
)


class TestAdminService(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        AdminService.reset_runtime_state()

    def test_rule_thresholds_lifecycle(self):
        """Validates retrieval and dynamic updates of scientific heuristic thresholds."""
        default_rules = AdminService.get_rule_thresholds()
        self.assertEqual(default_rules.lipid_oxidation_fat_threshold_pct, 18.0)
        self.assertEqual(default_rules.high_respiration_moisture_threshold_pct, 75.0)
        self.assertEqual(default_rules.acidic_corrosion_ph_threshold, 4.6)

        # Update specific thresholds
        updated = AdminService.update_rule_thresholds(
            RuleThresholdUpdate(
                lipid_oxidation_fat_threshold_pct=22.5,
                chilling_injury_buffer_c=3.5,
                eco_priority_multiplier=1.8,
            )
        )
        self.assertEqual(updated.lipid_oxidation_fat_threshold_pct, 22.5)
        self.assertEqual(updated.chilling_injury_buffer_c, 3.5)
        self.assertEqual(updated.eco_priority_multiplier, 1.8)
        # Unmodified fields should remain unchanged
        self.assertEqual(updated.high_respiration_moisture_threshold_pct, 75.0)

    def test_model_registry_and_ml_toggle(self):
        """Validates ML model registry information and runtime toggling."""
        model_info = AdminService.get_model_registry_info()
        self.assertEqual(model_info.active_model_name, "RandomForest-v2.3-18D")
        self.assertEqual(model_info.feature_dimension, 18)
        self.assertEqual(model_info.accuracy_score, 0.984)
        self.assertTrue(model_info.is_ml_enabled)

        # Toggle ML off
        status = AdminService.set_ml_enabled(False)
        self.assertFalse(status)
        new_info = AdminService.get_model_registry_info()
        self.assertFalse(new_info.is_ml_enabled)

    async def test_analytics_summary_computation(self):
        """Validates comprehensive analytics aggregation, rankings, and trend generation."""
        summary = await AdminService.get_analytics_summary(db=None)
        self.assertGreater(summary.total_analyses, 0)
        self.assertGreater(summary.total_users, 0)
        self.assertGreater(summary.total_foods_count, 0)
        self.assertGreater(summary.total_materials_count, 0)
        self.assertGreaterEqual(summary.eco_preference_pct, 0.0)
        self.assertGreater(summary.average_system_score, 50.0)

        # Top foods
        self.assertIsInstance(summary.top_foods, list)
        self.assertGreater(len(summary.top_foods), 0)
        self.assertIn("Fresh Tomato", [f.name for f in summary.top_foods])

        # Top materials
        self.assertIsInstance(summary.top_materials, list)
        self.assertGreater(len(summary.top_materials), 0)

        # 30-day trends
        self.assertIsInstance(summary.trends, list)
        self.assertGreater(len(summary.trends), 0)
        self.assertIn("-", summary.trends[0].date)

    async def test_recommendations_audit_stream(self):
        """Validates system-wide recommendation audit retrieval."""
        audit = await AdminService.get_recommendations_audit(db=None)
        self.assertGreater(audit.total_count, 0)
        self.assertGreater(len(audit.items), 0)
        self.assertEqual(audit.items[0].item_name, "Fresh Tomato")
        self.assertIsNotNone(audit.items[0].formatted_date)

    async def test_food_management_crud(self):
        """Validates food commodity creation, attribute update, and deletion lifecycle."""
        # 1. Create
        create_payload = AdminFoodCreate(
            name="Alphonso Mango",
            category="Produce",
            scientific_name="Mangifera indica",
            moisture=84.5,
            ph=4.2,
            water_activity=0.98,
            fat=0.4,
            respiration_class="High",
            oxygen_sensitivity="Moderate",
            moisture_sensitivity="High",
        )
        food = await AdminService.create_food(db=None, payload=create_payload)
        self.assertEqual(food.name, "Alphonso Mango")
        self.assertEqual(food.moisture, 84.5)
        self.assertIsNotNone(food.id)

        # 2. Update
        update_payload = AdminFoodUpdate(
            moisture=82.0,
            fat=0.5,
        )
        updated = await AdminService.update_food(db=None, food_id=food.id, payload=update_payload)
        self.assertIsNotNone(updated)
        self.assertEqual(updated.moisture, 82.0)
        self.assertEqual(updated.fat, 0.5)

        # 3. Delete
        deleted = await AdminService.delete_food(db=None, food_id=food.id)
        self.assertTrue(deleted)

        # Verify not found after delete
        not_found = await AdminService.update_food(db=None, food_id=food.id, payload=update_payload)
        self.assertIsNone(not_found)

    async def test_material_management_crud(self):
        """Validates packaging material creation, property updating, status toggling, and deletion."""
        # 1. Create
        mat_payload = AdminMaterialCreate(
            material_id="mat_bio_pha_01",
            name="High-Barrier PHA Biodegradable Film",
            category="Biodegradable Bio-Polymer",
            polymer_family="BREATHABLE_BIO_EMAP",
            structure="Monolayer 35 µm",
            form_factor="Flexible Pouch",
            thickness_microns=35.0,
            otr_cc_m2_day=2500.0,
            wvtr_g_m2_day=35.0,
            co2_permeability=9000.0,
            selectivity_beta=3.6,
            sustainability_score=96.0,
            recyclability_score=75.0,
            biodegradability_score=100.0,
            estimated_unit_cost_inr=4.50,
            is_breathable=True,
            is_biodegradable=True,
            is_active_entry=True,
        )
        material = await AdminService.create_material(db=None, payload=mat_payload)
        self.assertEqual(material.name, "High-Barrier PHA Biodegradable Film")
        self.assertEqual(material.sustainability_score, 96.0)
        self.assertTrue(material.is_active_entry)

        # 2. Update
        mat_update = AdminMaterialUpdate(
            thickness_microns=38.0,
            estimated_unit_cost_inr=4.75,
        )
        updated_mat = await AdminService.update_material(db=None, mat_id=material.id, payload=mat_update)
        self.assertIsNotNone(updated_mat)
        self.assertEqual(updated_mat.thickness_microns, 38.0)
        self.assertEqual(updated_mat.estimated_unit_cost_inr, 4.75)

        # 3. Toggle Status
        toggled = await AdminService.toggle_material_status(db=None, mat_id=material.id)
        self.assertIsNotNone(toggled)
        self.assertFalse(toggled.is_active_entry)

        # Toggle back
        toggled_back = await AdminService.toggle_material_status(db=None, mat_id=material.id)
        self.assertIsNotNone(toggled_back)
        self.assertTrue(toggled_back.is_active_entry)

        # 4. Delete
        deleted = await AdminService.delete_material(db=None, mat_id=material.id)
        self.assertTrue(deleted)


if __name__ == "__main__":
    unittest.main()
