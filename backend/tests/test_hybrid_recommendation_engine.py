"""
Unit tests for HybridRecommendationEngine (Task 1.2 & Task 1.3).
Validates Stage 1 Physics-based pruning, Stage 2 TOPSIS ranking,
active additives triggers, and 3-alternative synthesis across food archetypes.
"""

import unittest
from app.services.hybrid_recommender import (
    HybridRecommendationEngine,
    hybrid_recommender,
)
from app.core.material_catalog import (
    PACKAGING_CATALOG,
    MaterialCatalogService,
)


class TestHybridRecommendationEngine(unittest.TestCase):

    def setUp(self):
        self.engine = HybridRecommendationEngine()

    def test_stage1_pruning_tomato(self):
        tomato_data = {
            "name": "Fresh Tomato",
            "category": "Vegetables",
            "moisture_pct": 94.5,
            "fat_pct": 0.2,
            "ph": 4.4,
            "respiration_rate_20c": 45.0,
            "respiration_class": "High",
            "ethylene_sensitivity": "High",
            "storage_temp_c": 12.0,
        }
        candidates, rules = self.engine.run_stage1_pruning(tomato_data, PACKAGING_CATALOG)
        self.assertTrue(len(candidates) > 0)
        self.assertTrue(len(rules) > 0)
        
        # Verify hermetic non-breathable foil (e.g. Al-Foil Laminate with OTR=0.05) is pruned out
        foil = next((m for m in candidates if "Aluminium Foil" in m.name), None)
        self.assertIsNone(foil, "Aluminium foil must be pruned for highly respiring tomato")

        # Verify breathable EMAP bio-film is preserved in candidates
        emap = next((m for m in candidates if "Micro-Perforated Equilibrium MAP" in m.name), None)
        self.assertIsNotNone(emap, "Micro-perforated MAP film must be present in tomato candidates")

    def test_stage1_pruning_potato_chips(self):
        chips_data = {
            "name": "Potato Chips",
            "category": "Snacks",
            "moisture_pct": 1.8,
            "fat_pct": 35.0,
            "ph": 6.2,
            "storage_temp_c": 22.0,
        }
        candidates, rules = self.engine.run_stage1_pruning(chips_data, PACKAGING_CATALOG)
        self.assertTrue(len(candidates) > 0)
        
        # Verify high-OTR films (e.g. standard LDPE with OTR 7400) are pruned out
        ldpe = next((m for m in candidates if m.material_id == "mat_ldpe_perforated_05"), None)
        self.assertIsNone(ldpe, "Perforated LDPE must be pruned for high-fat chips")

        # Verify metallized barrier films are retained
        met_pet = next((m for m in candidates if "Metallized" in m.name), None)
        self.assertIsNotNone(met_pet, "Metallized barrier films must be present for potato chips")

    def test_stage1_pruning_frozen_food(self):
        frozen_data = {
            "name": "Frozen Green Peas",
            "category": "Frozen Food",
            "moisture_pct": 78.0,
            "storage_temp_c": -18.0,
        }
        candidates, rules = self.engine.run_stage1_pruning(frozen_data, PACKAGING_CATALOG)
        self.assertTrue(len(candidates) > 0)
        
        # All candidates must tolerate -18°C
        for mat in candidates:
            self.assertLessEqual(mat.temp_min_c, -18.0)

    def test_recommend_fresh_tomato_full_pipeline(self):
        tomato_input = {
            "name": "Fresh Tomato",
            "category": "Vegetables",
            "moisture_pct": 94.5,
            "fat_pct": 0.2,
            "ph": 4.4,
            "respiration_rate_5c": 10.0,
            "respiration_rate_20c": 45.0,
            "respiration_class": "High",
            "ethylene_sensitivity": "High",
            "chilling_injury_threshold_c": 10.0,
            "storage_temp_c": 12.0,
            "duration": 21,
            "quantity": 5.0,
            "is_fragile": True,
            "eco_friendly_priority": True,
        }
        result = self.engine.recommend(tomato_input)

        # 1. Primary Recommendation checks
        self.assertIsNotNone(result.primary_material)
        self.assertTrue("MAP" in result.primary_material.name or "Breathable" in result.primary_material.name)
        self.assertGreater(result.suitability_score, 0.50)
        self.assertLessEqual(result.suitability_score, 1.0)

        # 2. Active Additives triggers
        self.assertTrue(any("KMnO₄" in a for a in result.active_additives), "Must trigger KMnO4 ethylene scrubber")
        self.assertTrue(any("Antifog" in a for a in result.active_additives), "Must trigger anti-fog coating")

        # 3. Alternatives checks
        self.assertIsNotNone(result.eco_champion_alternative)
        self.assertGreaterEqual(result.eco_champion_alternative.sustainability_score, 80.0)
        self.assertIsNotNone(result.economy_alternative)
        self.assertIsNotNone(result.high_barrier_alternative)
        self.assertNotEqual(result.primary_material.material_id, result.eco_champion_alternative.material_id)

        # 4. Rich Alternative Schema Portfolio checks (Module 8)
        self.assertIsNotNone(result.alternatives)
        self.assertGreaterEqual(len(result.alternatives), 2)
        for alt in result.alternatives:
            self.assertIn(alt.star_rating, [3, 4, 5])
            self.assertIn(alt.star_display, ["★★★★★", "★★★★☆", "★★★☆☆"])
            self.assertIsNotNone(alt.suitability_category)
            self.assertGreater(alt.model_derived_probability, 0.5)
            self.assertLessEqual(alt.model_derived_probability, 1.0)
            self.assertIsNotNone(alt.characteristics.otr)
            self.assertIsNotNone(alt.characteristics.wvtr)
            self.assertGreater(alt.characteristics.thickness_microns, 0)
            self.assertGreater(alt.characteristics.estimated_cost_inr, 0)
            self.assertTrue(len(alt.advantages) > 0)
            self.assertTrue(len(alt.limitations) > 0)

    def test_recommend_potato_chips_full_pipeline(self):
        chips_input = {
            "name": "Potato Chips",
            "category": "Snacks",
            "moisture_pct": 1.8,
            "fat_pct": 35.0,
            "ph": 6.2,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 22.0,
            "duration": 180,
            "quantity": 1.0,
            "is_fragile": True,
            "eco_friendly_priority": True,
        }
        result = self.engine.recommend(chips_input)
        
        self.assertIsNotNone(result.primary_material)
        self.assertTrue("Metallized" in result.primary_material.name or result.primary_material.otr_cc_m2_day <= 1.5)
        self.assertTrue(any("Nitrogen" in a for a in result.active_additives), "Must trigger N2 flush")
        self.assertIsNotNone(result.alternatives)
        self.assertGreaterEqual(len(result.alternatives), 2)

    def test_recommend_fresh_chicken_full_pipeline(self):
        chicken_input = {
            "name": "Fresh Chicken Breast",
            "category": "Meat",
            "moisture_pct": 74.0,
            "fat_pct": 2.5,
            "ph": 5.9,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 2.0,
            "duration": 12,
            "quantity": 2.0,
            "eco_friendly_priority": False,
        }
        result = self.engine.recommend(chicken_input)
        
        self.assertIsNotNone(result.primary_material)
        self.assertTrue("EVOH" in result.primary_material.name or "PA/PE" in result.primary_material.name or "Barrier" in result.primary_material.name)
        self.assertLessEqual(result.primary_material.otr_cc_m2_day, 30.0)
        self.assertIsNotNone(result.alternatives)


if __name__ == "__main__":
    unittest.main()
