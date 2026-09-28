"""
Unit tests for Alternative Packaging Candidate Scoring & Multi-Option Synthesis (Module 8 - Task 1.3).
Validates multi-candidate portfolio generation, star ratings (5/5, 4/5, 3/5),
descriptive suitability categories, model-derived probabilities, characteristics,
and relative deltas across representative food archetypes.
"""

import unittest
from app.services.hybrid_recommender import HybridRecommendationEngine, hybrid_recommender
from app.schemas.packaging import (
    SuitabilityCategoryEnum,
    AlternativeTypeEnum,
)


class TestAlternativePackagingService(unittest.TestCase):
    """Test suite for alternative packaging candidate generation and scoring."""

    def setUp(self):
        self.engine = hybrid_recommender

    def test_strawberries_multi_option_portfolio(self):
        """Test high-respiration fresh produce (Strawberries)."""
        strawberry_input = {
            "name": "Fresh Strawberries",
            "category": "Fruits",
            "moisture_pct": 91.0,
            "fat_pct": 0.3,
            "ph": 3.6,
            "respiration_rate_20c": 55.0,
            "respiration_class": "Extreme",
            "ethylene_sensitivity": "High",
            "storage_temp_c": 4.0,
            "duration": 14,
            "is_fragile": True,
            "eco_friendly_priority": True,
        }
        res = self.engine.recommend(strawberry_input)

        # 1. Primary Recommendation
        self.assertIsNotNone(res.primary_material)
        self.assertTrue(res.primary_material.is_breathable or res.primary_material.otr_cc_m2_day >= 1000.0)
        self.assertGreaterEqual(res.suitability_score, 0.50)

        # 2. Alternatives Portfolio
        self.assertIsNotNone(res.alternatives)
        self.assertGreaterEqual(len(res.alternatives), 2)
        
        # Verify Eco-Champion Alternative
        eco_alt = next((a for a in res.alternatives if a.type == "ECO_FRIENDLY"), None)
        self.assertIsNotNone(eco_alt)
        self.assertEqual(eco_alt.star_rating, 4)
        self.assertEqual(eco_alt.star_display, "★★★★☆")
        self.assertEqual(eco_alt.suitability_category, SuitabilityCategoryEnum.HIGH_COMPATIBILITY)
        self.assertGreaterEqual(eco_alt.model_derived_probability, 0.50)
        self.assertLessEqual(eco_alt.model_derived_probability, 1.0)
        self.assertIn("cc/m²/day", eco_alt.characteristics.otr)
        self.assertIn("g/m²/day", eco_alt.characteristics.wvtr)
        self.assertGreater(eco_alt.characteristics.thickness_microns, 0)
        self.assertGreater(len(eco_alt.advantages), 0)

        # Verify Economy Alternative
        econ_alt = next((a for a in res.alternatives if a.type == "ECONOMY"), None)
        self.assertIsNotNone(econ_alt)
        self.assertEqual(econ_alt.star_rating, 3)
        self.assertEqual(econ_alt.star_display, "★★★☆☆")
        self.assertEqual(econ_alt.suitability_category, SuitabilityCategoryEnum.MODERATE_COMPATIBILITY)
        self.assertLessEqual(econ_alt.characteristics.estimated_cost_inr, res.primary_material.estimated_unit_cost_inr)

    def test_roasted_cashews_multi_option_portfolio(self):
        """Test high-fat, moisture-sensitive snacks (Roasted Cashews)."""
        cashew_input = {
            "name": "Roasted Salted Cashews",
            "category": "Snacks",
            "moisture_pct": 2.5,
            "fat_pct": 46.0,
            "ph": 6.5,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 22.0,
            "duration": 120,
            "is_fragile": False,
            "eco_friendly_priority": False,
        }
        res = self.engine.recommend(cashew_input)

        # High fat requires low OTR
        self.assertLessEqual(res.primary_material.otr_cc_m2_day, 5.0)
        self.assertIsNotNone(res.alternatives)
        self.assertGreaterEqual(len(res.alternatives), 2)

        for alt in res.alternatives:
            # Closeness metric must be strictly labeled as model_derived_probability
            self.assertGreaterEqual(alt.model_derived_probability, 0.50)
            self.assertLessEqual(alt.model_derived_probability, 1.0)
            self.assertTrue(any(k in alt.compatibility_confidence for k in ["Confidence", "Fit", "Compatibility"]))
            self.assertIsNotNone(alt.cost_delta_pct)
            self.assertIsNotNone(alt.eco_delta_pct)

    def test_fresh_salmon_fillet_multi_option_portfolio(self):
        """Test high-moisture perishable protein (Fresh Salmon)."""
        salmon_input = {
            "name": "Fresh Atlantic Salmon Fillet",
            "category": "Seafood",
            "moisture_pct": 68.0,
            "fat_pct": 13.0,
            "ph": 6.2,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 1.0,
            "duration": 10,
            "is_fragile": True,
            "eco_friendly_priority": True,
        }
        res = self.engine.recommend(salmon_input)

        self.assertIsNotNone(res.primary_material)
        self.assertLessEqual(res.primary_material.otr_cc_m2_day, 35.0)
        self.assertIsNotNone(res.alternatives)
        self.assertGreaterEqual(len(res.alternatives), 2)

        # Verify candidate ids are distinct
        cand_ids = [a.candidate_id for a in res.alternatives]
        self.assertEqual(len(cand_ids), len(set(cand_ids)), "All candidate IDs in portfolio must be unique")

    def test_basmati_rice_ambient_grain_portfolio(self):
        """Test dry ambient grain (Basmati Rice)."""
        rice_input = {
            "name": "Aged Basmati Rice",
            "category": "Grains",
            "moisture_pct": 12.0,
            "fat_pct": 0.6,
            "ph": 6.8,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 25.0,
            "duration": 365,
            "is_fragile": False,
            "eco_friendly_priority": True,
        }
        res = self.engine.recommend(rice_input)

        self.assertIsNotNone(res.primary_material)
        self.assertIsNotNone(res.alternatives)
        self.assertGreaterEqual(len(res.alternatives), 2)

        # Check characteristics consistency
        for alt in res.alternatives:
            chars = alt.characteristics
            self.assertTrue(chars.cost_tier in ["Low (₹)", "Moderate (₹₹)", "Premium (₹₹₹)"])
            self.assertGreater(chars.tensile_strength_mpa, 0)
            self.assertTrue("°C" in chars.thermal_range)


if __name__ == "__main__":
    unittest.main()
