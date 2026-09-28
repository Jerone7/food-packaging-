"""
Unit Tests for AI Comprehensive Model Evaluation & Metrics Intelligence Engine (Module 16).
Tests multi-class metrics, confusion matrix dimensions, 5-fold cross validation,
per-class precision/recall/F1, and feature importance rankings.
"""

import unittest
import numpy as np

from app.schemas.ai_model import AlgorithmTypeEnum, ModelEvaluationMetrics
from app.services.ai_dataset_service import DatasetService
from app.services.ai_training_engine import ModelTrainingEngine
from app.services.ai_evaluation_engine import ModelEvaluationEngine


class TestAIEvaluationEngine(unittest.TestCase):
    """Test suite for ModelEvaluationEngine."""

    @classmethod
    def setUpClass(cls):
        """Train baseline Random Forest and MLP bundles for evaluation tests."""
        cls.dataset_service = DatasetService()
        cls.df = cls.dataset_service.get_dataset_dataframe("baseline_archetypes")
        cls.training_engine = ModelTrainingEngine()

        cls.rf_bundle = cls.training_engine.train_sync(
            dataset_df=cls.df,
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
        )
        cls.mlp_bundle = cls.training_engine.train_sync(
            dataset_df=cls.df,
            algorithm=AlgorithmTypeEnum.MULTI_LAYER_PERCEPTRON,
        )

    def test_evaluate_random_forest_metrics(self):
        """Verify evaluation metrics calculation on Random Forest bundle."""
        metrics = ModelEvaluationEngine.evaluate_bundle(self.rf_bundle)
        self.assertIsInstance(metrics, ModelEvaluationMetrics)

        # Bounds validation
        self.assertTrue(0.0 <= metrics.accuracy <= 1.0)
        self.assertTrue(0.0 <= metrics.precision_macro <= 1.0)
        self.assertTrue(0.0 <= metrics.recall_macro <= 1.0)
        self.assertTrue(0.0 <= metrics.f1_macro <= 1.0)
        self.assertTrue(0.0 <= metrics.f1_weighted <= 1.0)

        # Baseline accuracy should be high on well-separated archetypes
        self.assertGreaterEqual(metrics.accuracy, 0.85)

    def test_confusion_matrix_dimensions_and_sum(self):
        """Verify 7x7 confusion matrix structure and total test count alignment."""
        metrics = ModelEvaluationEngine.evaluate_bundle(self.rf_bundle)
        cm = metrics.confusion_matrix

        self.assertEqual(len(cm), 7, "Confusion matrix must have 7 rows")
        for row in cm:
            self.assertEqual(len(row), 7, "Confusion matrix rows must each have 7 columns")

        total_cm_count = sum(sum(row) for row in cm)
        self.assertEqual(
            total_cm_count,
            len(self.rf_bundle.preprocessed_bundle.y_test),
            "Confusion matrix sum must equal test partition size",
        )

    def test_per_class_metrics_completeness(self):
        """Verify all 7 polymer classes have precision, recall, f1, and support."""
        metrics = ModelEvaluationEngine.evaluate_bundle(self.rf_bundle)
        self.assertEqual(len(metrics.per_class_metrics), 7)

        for class_name in metrics.classes:
            self.assertIn(class_name, metrics.per_class_metrics)
            item = metrics.per_class_metrics[class_name]
            self.assertTrue(0.0 <= item.precision <= 1.0)
            self.assertTrue(0.0 <= item.recall <= 1.0)
            self.assertTrue(0.0 <= item.f1_score <= 1.0)
            self.assertGreaterEqual(item.support, 0)

    def test_cross_validation_scores(self):
        """Verify 5-fold cross validation scores array, mean, and variance."""
        metrics = ModelEvaluationEngine.evaluate_bundle(self.rf_bundle, n_splits=5)
        self.assertGreaterEqual(len(metrics.cv_scores), 2)
        self.assertTrue(0.0 <= metrics.cv_mean <= 1.0)
        self.assertTrue(0.0 <= metrics.cv_std <= 0.5)

    def test_tree_feature_importances(self):
        """Verify feature importances for tree-based ensemble."""
        metrics = ModelEvaluationEngine.evaluate_bundle(self.rf_bundle)
        self.assertEqual(len(metrics.feature_importances), 18)

        total_imp = sum(metrics.feature_importances.values())
        self.assertAlmostEqual(total_imp, 1.0, places=2)

        # Check descending order
        vals = list(metrics.feature_importances.values())
        self.assertEqual(vals, sorted(vals, reverse=True))

    def test_mlp_permutation_feature_importances(self):
        """Verify permutation importance extraction for neural network models."""
        metrics = ModelEvaluationEngine.evaluate_bundle(self.mlp_bundle)
        self.assertEqual(len(metrics.feature_importances), 18)

        total_imp = sum(metrics.feature_importances.values())
        self.assertAlmostEqual(total_imp, 1.0, places=2)


if __name__ == "__main__":
    unittest.main()
