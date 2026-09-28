"""
Unit Tests for AI Data Preprocessing Transformers & Splitting Pipeline (Module 16).
Tests scaling transformations, label encoding, stratified train/test partitions,
data leakage prevention, and single-sample inference scaling.
"""

import unittest
import numpy as np
from sklearn.preprocessing import StandardScaler, MinMaxScaler, RobustScaler

from app.services.ai_dataset_service import DatasetService
from app.services.ai_preprocessing_service import (
    DataPreprocessingService,
    PreprocessedDatasetBundle,
    CANONICAL_TARGET_CLASSES,
)


class TestAIPipelineTransforms(unittest.TestCase):
    """Test suite for data preprocessing transformers and splitting pipeline."""

    def setUp(self):
        """Load baseline archetypes dataset."""
        self.dataset_service = DatasetService()
        self.df = self.dataset_service.get_dataset_dataframe("baseline_archetypes")

    def test_get_scaler_types(self):
        """Verify scaler instantiation for standard, minmax, and robust methods."""
        scaler_std = DataPreprocessingService.get_scaler("standard")
        scaler_minmax = DataPreprocessingService.get_scaler("minmax")
        scaler_robust = DataPreprocessingService.get_scaler("robust")

        self.assertIsInstance(scaler_std, StandardScaler)
        self.assertIsInstance(scaler_minmax, MinMaxScaler)
        self.assertIsInstance(scaler_robust, RobustScaler)

    def test_fit_transform_dataset_shapes_and_split(self):
        """Verify train/test split partitions, dimensions, and label encodings."""
        bundle = DataPreprocessingService.fit_transform_dataset(
            self.df, scaler_type="standard", test_size=0.2, random_state=42
        )
        self.assertIsInstance(bundle, PreprocessedDatasetBundle)

        total_rows = len(self.df)
        expected_test = int(np.ceil(total_rows * 0.2))
        expected_train = total_rows - expected_test

        self.assertEqual(bundle.X_train.shape[1], 18)
        self.assertEqual(bundle.X_test.shape[1], 18)
        self.assertEqual(len(bundle.X_train) + len(bundle.X_test), total_rows)
        self.assertEqual(len(bundle.y_train), len(bundle.X_train))
        self.assertEqual(len(bundle.y_test), len(bundle.X_test))

    def test_stratification_preserves_all_classes(self):
        """Verify stratified splitting maintains representative class balance in train and test."""
        bundle = DataPreprocessingService.fit_transform_dataset(
            self.df, scaler_type="standard", test_size=0.2, random_state=42
        )
        train_classes = set(np.unique(bundle.y_train))
        test_classes = set(np.unique(bundle.y_test))

        # Baseline has >= 8 samples per class, all 7 classes should appear in both train and test
        self.assertEqual(len(train_classes), 7)
        self.assertEqual(len(test_classes), 7)

    def test_zero_data_leakage_scaler_fit(self):
        """Verify scaler is fit exclusively on X_train without leaking X_test distribution."""
        bundle = DataPreprocessingService.fit_transform_dataset(
            self.df, scaler_type="standard", test_size=0.2, random_state=42
        )
        # Training mean should be close to 0 and std close to 1 for continuous non-constant columns
        train_means = np.mean(bundle.X_train, axis=0)
        # Continuous columns like moisture (index 0) and storage temp (index 8)
        self.assertAlmostEqual(train_means[0], 0.0, places=5)
        self.assertAlmostEqual(train_means[8], 0.0, places=5)

    def test_label_encoding_and_inverse_mapping(self):
        """Verify target labels are mapped to 0..6 and can be inverse transformed."""
        bundle = DataPreprocessingService.fit_transform_dataset(
            self.df, scaler_type="standard", test_size=0.2, random_state=42
        )
        self.assertEqual(set(bundle.classes), set(CANONICAL_TARGET_CLASSES))
        self.assertEqual(len(bundle.classes), 7)
        self.assertTrue(np.all(bundle.y_train >= 0))
        self.assertTrue(np.all(bundle.y_train < 7))

        # Test inverse transform matches classes array
        sample_preds = np.array([0, 1, 2, 3, 4, 5, 6])
        decoded = list(bundle.label_encoder.inverse_transform(sample_preds))
        self.assertEqual(decoded, bundle.classes)

    def test_transform_inference_sample(self):
        """Verify single raw record is transformed into properly scaled (1, 18) array."""
        bundle = DataPreprocessingService.fit_transform_dataset(
            self.df, scaler_type="standard", test_size=0.2, random_state=42
        )
        raw_sample = {
            "name": "Fresh Spinach",
            "category": "Vegetables",
            "moisture": 91.4,
            "fat": 0.4,
            "ph": 6.5,
            "storage_temp_c": 4.0,
            "storage_duration_days": 7,
        }
        scaled_sample = DataPreprocessingService.transform_inference_sample(
            raw_sample, scaler=bundle.scaler
        )
        self.assertEqual(scaled_sample.shape, (1, 18))
        self.assertIsInstance(scaled_sample, np.ndarray)


if __name__ == "__main__":
    unittest.main()
