"""
Unit Tests for Admin Pydantic Schemas (Module 15 - Task 1.2).
Validates schema initialization, validation boundaries, and serialization.
"""

import unittest
from datetime import datetime, timezone
from pydantic import ValidationError

from app.schemas.admin import (
    AdminFoodCreate,
    AdminFoodUpdate,
    AdminScientificPropertiesUpdate,
    AdminFoodListItem,
    AdminFoodDetailResponse,
    AdminFoodListResponse,
    AdminMaterialCreate,
    AdminMaterialUpdate,
    AdminMaterialResponse,
    AdminMaterialListResponse,
    RuleThresholdConfig,
    RuleThresholdUpdate,
    ModelRegistryResponse,
    AdminRecommendationAuditItem,
    AdminRecommendationAuditResponse,
    FoodSearchStat,
    MaterialRecommendStat,
    DailyUsageTrend,
    AdminAnalyticsSummary,
)


class TestAdminSchemas(unittest.TestCase):
    def test_admin_food_create_validation(self):
        """Tests AdminFoodCreate schema validation and boundary checks."""
        valid_data = {
            "name": "Alphonso Mango",
            "category": "Produce",
            "scientific_name": "Mangifera indica",
            "moisture": 84.5,
            "ph": 4.1,
            "water_activity": 0.98,
            "fat": 0.4,
            "respiration_class": "High",
            "oxygen_sensitivity": "Moderate",
            "moisture_sensitivity": "High",
        }
        item = AdminFoodCreate(**valid_data)
        self.assertEqual(item.name, "Alphonso Mango")
        self.assertEqual(item.moisture, 84.5)
        self.assertEqual(item.ph, 4.1)

        # Negative checks: invalid moisture > 100
        invalid_data = valid_data.copy()
        invalid_data["moisture"] = 150.0
        with self.assertRaises(ValidationError):
            AdminFoodCreate(**invalid_data)

        # Invalid pH < 1.0
        invalid_data = valid_data.copy()
        invalid_data["ph"] = 0.5
        with self.assertRaises(ValidationError):
            AdminFoodCreate(**invalid_data)

    def test_admin_scientific_properties_update(self):
        """Tests AdminScientificPropertiesUpdate schema for 14-parameter traits."""
        update_data = {
            "respiration_rate_20c": 35.5,
            "respiration_rate_5c": 12.0,
            "respiratory_quotient": 1.05,
            "ethylene_production_class": "Moderate",
            "chilling_injury_threshold_c": 12.0,
            "optimum_temp_min_c": 13.0,
            "optimum_temp_max_c": 15.0,
            "ambient_shelf_life_days": 10,
            "refrigerated_shelf_life_days": 21,
        }
        item = AdminScientificPropertiesUpdate(**update_data)
        self.assertEqual(item.respiration_rate_20c, 35.5)
        self.assertEqual(item.chilling_injury_threshold_c, 12.0)
        self.assertEqual(item.refrigerated_shelf_life_days, 21)

    def test_admin_material_create_and_update(self):
        """Tests AdminMaterialCreate and AdminMaterialUpdate schemas."""
        mat_data = {
            "material_id": "mat_bio_pha_01",
            "name": "High-Barrier PHA Biodegradable Film",
            "category": "Biodegradable Bio-Polymer",
            "polymer_family": "BREATHABLE_BIO_EMAP",
            "structure": "Monolayer 35 µm",
            "form_factor": "Flexible Pouch",
            "thickness_microns": 35.0,
            "otr_cc_m2_day": 2500.0,
            "wvtr_g_m2_day": 35.0,
            "co2_permeability": 9000.0,
            "selectivity_beta": 3.6,
            "tensile_strength_mpa": 28.5,
            "puncture_resistance_n": 15.0,
            "sustainability_score": 96.0,
            "recyclability_score": 75.0,
            "biodegradability_score": 100.0,
            "estimated_unit_cost_inr": 4.50,
            "is_breathable": True,
            "is_biodegradable": True,
            "is_active_entry": True,
        }
        item = AdminMaterialCreate(**mat_data)
        self.assertEqual(item.material_id, "mat_bio_pha_01")
        self.assertEqual(item.sustainability_score, 96.0)
        self.assertTrue(item.is_biodegradable)

        # Update schema with partial fields
        update_item = AdminMaterialUpdate(
            thickness_microns=40.0,
            estimated_unit_cost_inr=4.80,
            is_active_entry=False,
        )
        self.assertEqual(update_item.thickness_microns, 40.0)
        self.assertFalse(update_item.is_active_entry)

    def test_rule_thresholds_config(self):
        """Tests RuleThresholdConfig default values and range validations."""
        rules = RuleThresholdConfig()
        self.assertEqual(rules.lipid_oxidation_fat_threshold_pct, 18.0)
        self.assertEqual(rules.high_respiration_moisture_threshold_pct, 75.0)
        self.assertEqual(rules.acidic_corrosion_ph_threshold, 4.6)
        self.assertEqual(rules.chilling_injury_buffer_c, 2.0)
        self.assertEqual(rules.eco_priority_multiplier, 1.35)

        # Updating threshold
        rule_update = RuleThresholdUpdate(
            lipid_oxidation_fat_threshold_pct=20.0,
            eco_priority_multiplier=1.5,
        )
        self.assertEqual(rule_update.lipid_oxidation_fat_threshold_pct, 20.0)
        self.assertEqual(rule_update.eco_priority_multiplier, 1.5)

    def test_model_registry_schema(self):
        """Tests ModelRegistryResponse serialization."""
        now = datetime.now(timezone.utc)
        model_info = ModelRegistryResponse(
            active_model_name="RandomForest-v2.3-18D",
            algorithm="Random Forest Ensemble (100 Estimators)",
            feature_dimension=18,
            accuracy_score=0.984,
            is_ml_enabled=True,
            is_heuristic_fallback_active=True,
            last_trained_at=now,
            version_tag="v2.3.0-prod",
        )
        self.assertEqual(model_info.feature_dimension, 18)
        self.assertEqual(model_info.accuracy_score, 0.984)
        self.assertTrue(model_info.is_ml_enabled)

    def test_analytics_summary_schema(self):
        """Tests AdminAnalyticsSummary complete envelope serialization."""
        summary = AdminAnalyticsSummary(
            total_analyses=1420,
            total_users=85,
            total_foods_count=38,
            total_materials_count=16,
            eco_preference_pct=82.6,
            average_system_score=91.4,
            top_foods=[
                FoodSearchStat(name="Fresh Tomato", category="Produce", query_count=480, share_pct=33.8),
                FoodSearchStat(name="Alphonso Mango", category="Produce", query_count=310, share_pct=21.8),
            ],
            top_materials=[
                MaterialRecommendStat(
                    material_name="Micro-Perforated Bio-Film (PLA/PBAT)",
                    polymer_family="BREATHABLE_BIO_EMAP",
                    recommend_count=620,
                    share_pct=43.6,
                    average_score=95.5,
                )
            ],
            trends=[
                DailyUsageTrend(
                    date="2026-09-27",
                    total_analyses=54,
                    eco_analyses=46,
                    avg_sustainability_score=92.1,
                    avg_cost_inr=3.25,
                )
            ],
        )
        self.assertEqual(summary.total_analyses, 1420)
        self.assertEqual(len(summary.top_foods), 2)
        self.assertEqual(len(summary.top_materials), 1)
        self.assertEqual(len(summary.trends), 1)
        self.assertEqual(summary.top_foods[0].name, "Fresh Tomato")


if __name__ == "__main__":
    unittest.main()
