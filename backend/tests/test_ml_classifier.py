"""
Unit tests for MLPackagingClassifier and FeatureVectorizer (Task 1.1).
Validates feature vector encoding, random forest model training, probability predictions,
and heuristic fallbacks across standard food commodity archetypes.
"""

import unittest
from app.services.ml_classifier import (
    FeatureVectorizer,
    MLPackagingClassifier,
    FEATURE_NAMES,
    POLYMER_CLASSES,
    ml_classifier,
)


class TestMLPackagingClassifier(unittest.TestCase):

    def setUp(self):
        self.classifier = MLPackagingClassifier(n_estimators=30, random_state=42)

    def test_feature_vectorizer_dimensions_and_defaults(self):
        raw_data = {
            "moisture_pct": 94.5,
            "fat_pct": 0.2,
            "ph": 4.4,
            "respiration_rate_5c": 10.0,
            "respiration_rate_20c": 45.0,
            "ethylene_sensitivity": "High",
            "chilling_injury_threshold_c": 10.0,
            "storage_temp_c": 12.0,
            "duration": 21,
            "quantity": 5.0,
            "is_fragile": True,
            "eco_friendly_priority": True,
            "category": "Vegetables",
            "name": "Fresh Tomato",
        }
        vec = FeatureVectorizer.vectorize(raw_data)
        self.assertEqual(len(vec), 18)
        self.assertEqual(len(FEATURE_NAMES), 18)
        self.assertAlmostEqual(vec[0], 94.5)  # moisture
        self.assertAlmostEqual(vec[1], 0.2)   # fat
        self.assertAlmostEqual(vec[2], 4.4)   # pH
        self.assertAlmostEqual(vec[6], 0.8)   # ethylene high
        self.assertEqual(vec[11], 1.0)        # fragile
        self.assertEqual(vec[12], 1.0)        # eco priority
        self.assertEqual(vec[15], 1.0)        # high respiration interaction
        self.assertEqual(vec[16], 1.0)        # acidic interaction

    def test_predict_probabilities_produce_tomato(self):
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
            "duration": 21,
            "is_fragile": True,
            "eco_friendly_priority": True,
        }
        probs = self.classifier.predict_polymer_probabilities(tomato_data)
        
        # Must return valid probability mapping for all classes
        for cls_name in POLYMER_CLASSES:
            self.assertIn(cls_name, probs)
            self.assertGreaterEqual(probs[cls_name], 0.0)
            self.assertLessEqual(probs[cls_name], 1.0)
        
        total_prob = sum(probs.values())
        self.assertAlmostEqual(total_prob, 1.0, places=2)

        # BREATHABLE_BIO_EMAP should be dominant for fresh tomato
        predicted = self.classifier.classify(tomato_data)
        self.assertEqual(predicted, "BREATHABLE_BIO_EMAP")
        self.assertGreater(probs["BREATHABLE_BIO_EMAP"], 0.30)

    def test_predict_probabilities_high_lipid_chips(self):
        chips_data = {
            "name": "Crispy Potato Chips",
            "category": "Snacks",
            "moisture_pct": 1.8,
            "fat_pct": 35.0,
            "ph": 6.2,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 22.0,
            "duration": 180,
            "is_fragile": True,
            "eco_friendly_priority": False,
        }
        predicted = self.classifier.classify(chips_data)
        self.assertEqual(predicted, "METALLIZED_BARRIER")

    def test_predict_probabilities_fresh_meat(self):
        meat_data = {
            "name": "Fresh Chicken Breast",
            "category": "Meat",
            "moisture_pct": 74.0,
            "fat_pct": 3.0,
            "ph": 5.8,
            "respiration_rate_20c": 0.0,
            "storage_temp_c": 2.0,
            "duration": 10,
            "eco_friendly_priority": False,
        }
        predicted = self.classifier.classify(meat_data)
        self.assertEqual(predicted, "HIGH_BARRIER_EVOH_VSP")

    def test_predict_probabilities_deep_freeze(self):
        frozen_data = {
            "name": "Frozen Green Peas",
            "category": "Frozen Food",
            "moisture_pct": 78.0,
            "storage_temp_c": -18.0,
            "duration": 365,
        }
        predicted = self.classifier.classify(frozen_data)
        self.assertEqual(predicted, "CRYOGENIC_DEEP_FREEZE")

    def test_predict_probabilities_dry_grain(self):
        grain_data = {
            "name": "Basmati Rice",
            "category": "Grain",
            "moisture_pct": 12.0,
            "fat_pct": 0.5,
            "storage_temp_c": 25.0,
            "duration": 365,
            "eco_friendly_priority": True,
        }
        predicted = self.classifier.classify(grain_data)
        self.assertEqual(predicted, "CELLULOSE_KRAFT_LINED")

    def test_feature_importances(self):
        importances = self.classifier.get_feature_importances()
        self.assertEqual(len(importances), 18)
        self.assertGreater(sum(importances.values()), 0.0)
        # Verify key scientific features exist in importance map
        self.assertIn("moisture_pct", importances)
        self.assertIn("fat_pct", importances)
        self.assertIn("respiration_rate_20c", importances)
        self.assertIn("storage_temp_c", importances)


if __name__ == "__main__":
    unittest.main()
