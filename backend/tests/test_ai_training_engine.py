"""
Unit Tests for AI Multi-Algorithm Classifier Training Engine (Module 16).
Tests estimator instantiation, synchronous training across RF, GBDT, MLP, SVC,
hyperparameter overrides, and background job coordination.
"""

import time
import unittest
import numpy as np

from app.schemas.ai_model import AlgorithmTypeEnum, JobStatusEnum, ModelHyperparameters
from app.services.ai_dataset_service import DatasetService
from app.services.ai_training_engine import ModelTrainingEngine, TrainedModelBundle


class TestAITrainingEngine(unittest.TestCase):
    """Test suite for ModelTrainingEngine."""

    def setUp(self):
        """Initialize engine and load baseline dataset."""
        self.engine = ModelTrainingEngine()
        self.dataset_service = DatasetService()
        self.df = self.dataset_service.get_dataset_dataframe("baseline_archetypes")

    def test_train_random_forest(self):
        """Verify Random Forest classifier training on baseline archetypes."""
        hp = ModelHyperparameters(n_estimators=50, max_depth=10, random_state=42)
        bundle = self.engine.train_sync(
            dataset_df=self.df,
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
            hyperparameters=hp,
        )
        self.assertIsInstance(bundle, TrainedModelBundle)
        self.assertEqual(bundle.algorithm, AlgorithmTypeEnum.RANDOM_FOREST)
        self.assertGreater(bundle.elapsed_time_ms, 0.0)

        # Predict on test set
        preds = bundle.model.predict(bundle.preprocessed_bundle.X_test)
        self.assertEqual(len(preds), len(bundle.preprocessed_bundle.y_test))
        self.assertTrue(np.all(preds >= 0))
        self.assertTrue(np.all(preds < 7))

    def test_train_gradient_boosting(self):
        """Verify Gradient Boosting classifier training."""
        hp = ModelHyperparameters(n_estimators=30, learning_rate=0.1, max_depth=3, random_state=42)
        bundle = self.engine.train_sync(
            dataset_df=self.df,
            algorithm=AlgorithmTypeEnum.GRADIENT_BOOSTING,
            hyperparameters=hp,
        )
        self.assertEqual(bundle.algorithm, AlgorithmTypeEnum.GRADIENT_BOOSTING)
        preds = bundle.model.predict(bundle.preprocessed_bundle.X_test)
        self.assertEqual(len(preds), len(bundle.preprocessed_bundle.y_test))

    def test_train_multi_layer_perceptron(self):
        """Verify Multi-Layer Perceptron neural network training."""
        bundle = self.engine.train_sync(
            dataset_df=self.df,
            algorithm=AlgorithmTypeEnum.MULTI_LAYER_PERCEPTRON,
        )
        self.assertEqual(bundle.algorithm, AlgorithmTypeEnum.MULTI_LAYER_PERCEPTRON)
        preds = bundle.model.predict(bundle.preprocessed_bundle.X_test)
        self.assertEqual(len(preds), len(bundle.preprocessed_bundle.y_test))

    def test_train_support_vector_machine(self):
        """Verify Support Vector Classifier training with probability calibration."""
        bundle = self.engine.train_sync(
            dataset_df=self.df,
            algorithm=AlgorithmTypeEnum.SUPPORT_VECTOR_MACHINE,
        )
        self.assertEqual(bundle.algorithm, AlgorithmTypeEnum.SUPPORT_VECTOR_MACHINE)
        probs = bundle.model.predict_proba(bundle.preprocessed_bundle.X_test)
        self.assertEqual(probs.shape[1], 7)

    def test_async_training_job_lifecycle(self):
        """Verify background job submission, status polling, and bundle retrieval."""
        job_id = self.engine.submit_training_job(
            dataset_df=self.df,
            dataset_id="baseline_archetypes",
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
        )
        self.assertTrue(job_id.startswith("job-"))

        # Poll status until completed (timeout 10s)
        max_attempts = 50
        status_resp = None
        for _ in range(max_attempts):
            status_resp = self.engine.get_job_status(job_id)
            if status_resp and status_resp.status in [JobStatusEnum.COMPLETED, JobStatusEnum.FAILED]:
                break
            time.sleep(0.1)

        self.assertIsNotNone(status_resp)
        self.assertEqual(status_resp.status, JobStatusEnum.COMPLETED)
        self.assertIsNotNone(status_resp.elapsed_time_ms)

        bundle = self.engine.get_job_bundle(job_id)
        self.assertIsNotNone(bundle)
        self.assertEqual(bundle.algorithm, AlgorithmTypeEnum.RANDOM_FOREST)


if __name__ == "__main__":
    unittest.main()
