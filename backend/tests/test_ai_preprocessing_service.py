"""
Unit Tests for AI Data Preprocessing, Vectorization & Feature Engineering Service (Module 16).
Tests 18-D feature vectorization, missing value imputation, flag derivation,
and dataframe transformation.
"""

import unittest
import numpy as np
import pandas as pd

from app.services.ai_preprocessing_service import (
    DataPreprocessingService,
    CANONICAL_FEATURE_NAMES,
    CANONICAL_TARGET_CLASSES,
)
from app.services.ml_classifier import FeatureVectorizer


class TestAIPreprocessingService(unittest.TestCase):
    """Test suite for DataPreprocessingService."""

    def test_canonical_feature_names_and_classes(self):
        """Verify 18 feature names and 7 target classes match specification."""
        self.assertEqual(len(CANONICAL_FEATURE_NAMES), 18)
        self.assertEqual(len(CANONICAL_TARGET_CLASSES), 7)
        self.assertIn("moisture_pct", CANONICAL_FEATURE_NAMES)
        self.assertIn("is_perishable_animal_protein", CANONICAL_FEATURE_NAMES)

    def test_ethylene_encoding(self):
        """Verify ethylene string and numeric mapping."""
        self.assertAlmostEqual(DataPreprocessingService.encode_ethylene_score("Critical"), 1.0)
        self.assertAlmostEqual(DataPreprocessingService.encode_ethylene_score("Very High"), 1.0)
        self.assertAlmostEqual(DataPreprocessingService.encode_ethylene_score("High"), 0.8)
        self.assertAlmostEqual(DataPreprocessingService.encode_ethylene_score("Moderate"), 0.5)
        self.assertAlmostEqual(DataPreprocessingService.encode_ethylene_score("Low"), 0.2)
        self.assertAlmostEqual(DataPreprocessingService.encode_ethylene_score("None"), 0.0)
        self.assertAlmostEqual(DataPreprocessingService.encode_ethylene_score(0.75), 0.75)
        self.assertAlmostEqual(DataPreprocessingService.encode_ethylene_score(None), 0.2)

    def test_impute_and_vectorize_sample_with_defaults(self):
        """Verify vectorization with completely empty input applies postharvest defaults."""
        vec = DataPreprocessingService.impute_and_vectorize_sample({})
        self.assertEqual(len(vec), 18)
        self.assertEqual(vec[0], 60.0)  # moisture default
        self.assertEqual(vec[1], 2.0)   # fat default
        self.assertEqual(vec[2], 6.0)   # ph default
        self.assertAlmostEqual(vec[3], 0.6)  # aw derived for moisture 60%
        self.assertEqual(vec[8], 20.0)  # temp default
        self.assertEqual(vec[9], 14.0)  # duration default

    def test_derived_interaction_flags(self):
        """Verify derived flags (frozen, high lipid, high respiration, acidic, animal protein)."""
        # Frozen item
        frozen_sample = {
            "name": "Frozen Peas",
            "storage_temp_c": -18.0,
            "category": "Frozen Food",
        }
        vec_frozen = DataPreprocessingService.impute_and_vectorize_sample(frozen_sample)
        self.assertEqual(vec_frozen[13], 1.0)  # is_frozen

        # High lipid snack
        snack_sample = {
            "name": "Potato Chips",
            "fat_pct": 35.0,
            "moisture_pct": 1.5,
        }
        vec_snack = DataPreprocessingService.impute_and_vectorize_sample(snack_sample)
        self.assertEqual(vec_snack[14], 1.0)  # is_high_lipid

        # High respiring produce
        produce_sample = {
            "name": "Fresh Spinach",
            "respiration_rate_20c": 90.0,
            "moisture_pct": 92.0,
        }
        vec_produce = DataPreprocessingService.impute_and_vectorize_sample(produce_sample)
        self.assertEqual(vec_produce[15], 1.0)  # is_high_resp

        # Acidic retort food
        acidic_sample = {
            "name": "Pickled Gherkins",
            "ph": 3.2,
        }
        vec_acidic = DataPreprocessingService.impute_and_vectorize_sample(acidic_sample)
        self.assertEqual(vec_acidic[16], 1.0)  # is_acidic

        # Animal protein
        meat_sample = {
            "name": "Chicken Breast",
            "category": "Meat",
            "fat_pct": 3.0,
        }
        vec_meat = DataPreprocessingService.impute_and_vectorize_sample(meat_sample)
        self.assertEqual(vec_meat[17], 1.0)  # is_perishable_animal_protein

    def test_vectorize_dataframe(self):
        """Verify batch vectorization of DataFrame produces (N, 18) array."""
        df = pd.DataFrame([
            {
                "food_name": "Fresh Tomato",
                "moisture_pct": 94.5,
                "fat_pct": 0.2,
                "ph": 4.4,
                "storage_temp_c": 12.0,
                "target_polymer_class": "BREATHABLE_BIO_EMAP",
            },
            {
                "food_name": "Beef Steak",
                "moisture_pct": 70.0,
                "fat_pct": 8.0,
                "ph": 5.6,
                "category": "Meat",
                "storage_temp_c": 2.0,
                "target_polymer_class": "HIGH_BARRIER_EVOH_VSP",
            },
        ])

        X, y, feature_names = DataPreprocessingService.vectorize_dataframe(df)
        self.assertEqual(X.shape, (2, 18))
        self.assertEqual(len(y), 2)
        self.assertEqual(y[0], "BREATHABLE_BIO_EMAP")
        self.assertEqual(y[1], "HIGH_BARRIER_EVOH_VSP")
        self.assertEqual(feature_names, CANONICAL_FEATURE_NAMES)

    def test_parity_with_feature_vectorizer(self):
        """Verify consistency between DataPreprocessingService and FeatureVectorizer."""
        sample = {
            "name": "Apple",
            "category": "Fruits",
            "moisture": 85.5,
            "fat": 0.2,
            "ph": 3.8,
            "aw": 0.97,
            "r5": 4.0,
            "r20": 15.0,
            "ethylene": "Critical",
            "ci": 2.0,
            "temp": 3.0,
            "duration": 60,
            "qty": 20,
            "fragile": False,
            "eco": True,
        }
        v1 = DataPreprocessingService.impute_and_vectorize_sample(sample)
        v2 = FeatureVectorizer.vectorize(sample)
        self.assertEqual(len(v1), len(v2))
        np.testing.assert_allclose(v1, v2, rtol=1e-5, atol=1e-5)


if __name__ == "__main__":
    unittest.main()
