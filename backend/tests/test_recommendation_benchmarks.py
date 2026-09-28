"""
Empirical Packaging Accuracy Benchmark Validation Suite (Task 5.3).
Validates the AI/ML Recommendation Engine against standard scientific packaging benchmarks
across standard food commodities: Fresh Tomato, Potato Chips, Fresh Chicken Breast, and Basmati Rice.
"""

import unittest
from app.services.hybrid_recommender import hybrid_recommender
from app.services.geometry_and_xai import geometry_and_xai_service


class TestRecommendationBenchmarks(unittest.TestCase):

    def test_benchmark_tomato_emap_and_additives(self):
        """
        Benchmark 1: Fresh Tomato (Respiring, high moisture, high ethylene).
        Expected: Breathable MAP film (PLA/PBAT), KMnO4 scrubber, Anti-fog coating.
        """
        tomato = {
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
        res = hybrid_recommender.recommend(tomato)
        xai = geometry_and_xai_service.generate_scientific_rationale(
            "Fresh Tomato", "Vegetables", res.primary_material, tomato, res.active_additives
        )

        self.assertTrue(res.primary_material.is_breathable, "Primary material must be gas-permeable for Tomato")
        self.assertGreater(res.primary_material.otr_cc_m2_day, 1000.0)
        self.assertTrue(any("KMnO₄" in a for a in res.active_additives), "Must contain KMnO4 ethylene scavenger")
        self.assertTrue(any("Antifog" in a for a in res.active_additives), "Must contain anti-fog coating")
        self.assertTrue(any("respiration" in d.lower() for d in xai.key_drivers))

    def test_benchmark_potato_chips_high_lipid(self):
        """
        Benchmark 2: Potato Chips (35% Fat, 1.8% Moisture).
        Expected: Metallized Barrier Film with N2 Flush (OTR <= 1.5).
        """
        chips = {
            "name": "Crispy Potato Chips",
            "category": "Snacks",
            "moisture_pct": 1.8,
            "fat_pct": 35.0,
            "ph": 6.2,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 22.0,
            "duration": 180,
            "quantity": 0.5,
            "is_fragile": True,
            "eco_friendly_priority": True,
        }
        res = hybrid_recommender.recommend(chips)
        xai = geometry_and_xai_service.generate_scientific_rationale(
            "Potato Chips", "Snacks", res.primary_material, chips, res.active_additives
        )

        self.assertLessEqual(res.primary_material.otr_cc_m2_day, 1.5, "OTR must be <= 1.5 for lipid preservation")
        self.assertTrue("Metallized" in res.primary_material.name or "Bio-PET" in res.primary_material.name)
        self.assertTrue(any("Nitrogen" in a for a in res.active_additives), "Must trigger N2 flush")
        self.assertTrue(any("fat" in d.lower() or "lipid" in d.lower() for d in xai.key_drivers))

    def test_benchmark_fresh_chicken_protein_barrier(self):
        """
        Benchmark 3: Fresh Chicken Breast (74% Moisture, Perishable Meat, 2°C Storage).
        Expected: High-Barrier EVOH Vacuum Skin Film / Barrier bag (OTR <= 30).
        """
        chicken = {
            "name": "Fresh Chicken Breast",
            "category": "Meat",
            "moisture_pct": 74.0,
            "fat_pct": 2.5,
            "ph": 5.9,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 2.0,
            "duration": 12,
            "quantity": 2.0,
            "is_fragile": False,
            "eco_friendly_priority": False,
        }
        res = hybrid_recommender.recommend(chicken)
        xai = geometry_and_xai_service.generate_scientific_rationale(
            "Fresh Chicken Breast", "Meat", res.primary_material, chicken, res.active_additives
        )

        self.assertLessEqual(res.primary_material.otr_cc_m2_day, 30.0)
        self.assertTrue("EVOH" in res.primary_material.name or "PA/PE" in res.primary_material.name or "Barrier" in res.primary_material.name)
        self.assertIn("Chicken", xai.summary)

    def test_benchmark_basmati_rice_grain_kraft(self):
        """
        Benchmark 4: Basmati Rice (12% Moisture, 365 days ambient storage).
        Expected: Unbleached Kraft with PLA Liner / Heavy-Duty Paper.
        """
        rice = {
            "name": "Basmati Rice",
            "category": "Grain",
            "moisture_pct": 12.0,
            "fat_pct": 0.6,
            "ph": 6.6,
            "storage_temp_c": 25.0,
            "duration": 365,
            "quantity": 20.0,
            "is_fragile": False,
            "eco_friendly_priority": True,
        }
        res = hybrid_recommender.recommend(rice)

        self.assertGreaterEqual(res.primary_material.sustainability_score, 90.0)
        self.assertTrue("Kraft" in res.primary_material.name or "Paper" in res.primary_material.name)


if __name__ == "__main__":
    unittest.main()
