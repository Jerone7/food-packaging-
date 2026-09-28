import unittest
import sys
import os

backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from app.schemas.packaging import PackagingInput
from app.services.recommender import PackagingRecommenderService

class TestScientificRecommendationCoupling(unittest.TestCase):
    def test_tomato_scientific_recommendation_with_chilling_warning(self):
        # Tomato at refrigerated 4°C should trigger chilling warning and EMAP barrier
        input_data = PackagingInput(
            item_name="Fresh Tomato",
            weight=0.5,
            category="Vegetables",
            storage_condition="Refrigerated",
            eco_friendly=True,
        )
        result = PackagingRecommenderService.recommend(input_data)

        self.assertIn("Micro-Perforated", result.recommended_box_type)
        self.assertGreaterEqual(result.sustainability_score, 90.0)
        self.assertIn("Ethylene Scavenger", result.notes)
        self.assertIn("Chilling Injury", result.notes)
        self.assertIn("OTR:", result.notes)
        self.assertGreater(result.box_volume_cm3, 0)

    def test_potato_chips_high_fat_low_moisture_recommendation(self):
        # Potato Chips (high fat > 30%, low moisture < 3%) requires ultra-high barrier Met-PET
        input_data = PackagingInput(
            item_name="Potato Chips (fried)",
            weight=0.15,
            category="Other perishables",
            storage_condition="Room Temperature",
            eco_friendly=True,
        )
        result = PackagingRecommenderService.recommend(input_data)

        self.assertIn("Met-PET", result.recommended_box_type)
        self.assertIn("OTR: < 0.5", result.notes)
        self.assertGreaterEqual(result.sustainability_score, 90.0)

    def test_chicken_breast_meat_high_barrier_evoh(self):
        # Fresh Chicken Breast requires EVOH vacuum skin packaging
        input_data = PackagingInput(
            item_name="Fresh Chicken Breast",
            weight=1.0,
            category="Meat",
            storage_condition="Refrigerated",
            eco_friendly=False,
        )
        result = PackagingRecommenderService.recommend(input_data)

        self.assertIn("EVOH", result.recommended_box_type)
        self.assertTrue("cold-chain" in result.notes or "Thermal Insulated" in result.cushioning_material)

    def test_eco_friendly_toggle_changes_polymer_family(self):
        eco_input = PackagingInput(
            item_name="Potato Chips (fried)",
            weight=0.2,
            eco_friendly=True,
        )
        conv_input = PackagingInput(
            item_name="Potato Chips (fried)",
            weight=0.2,
            eco_friendly=False,
        )

        eco_res = PackagingRecommenderService.recommend(eco_input)
        conv_res = PackagingRecommenderService.recommend(conv_input)

        self.assertIn("Met-PET", eco_res.recommended_box_type)
        self.assertIn("Aluminium Foil", conv_res.recommended_box_type)
        self.assertGreater(eco_res.sustainability_score, conv_res.sustainability_score)

if __name__ == '__main__':
    unittest.main()
