"""
Unit Tests for AI Retraining & Comparison Pipeline (Module 16).
Tests end-to-end retraining, delta comparison vs. active baseline,
auto-promotion policies, and candidate registration.
"""

import os
import shutil
import tempfile
import unittest

from app.schemas.ai_model import AlgorithmTypeEnum, ModelStatusEnum, ModelHyperparameters
from app.services.ai_dataset_service import DatasetService
from app.services.ai_training_engine import ModelTrainingEngine
from app.services.ai_evaluation_engine import ModelEvaluationEngine
from app.services.ai_registry_service import ModelRegistryService
from app.services.ai_deployment_service import ModelDeploymentService
from app.services.ai_retraining_pipeline import RetrainingPipeline
from app.services.ml_classifier import MLPackagingClassifier


class TestAIRetrainingPipeline(unittest.TestCase):
    """Test suite for RetrainingPipeline."""

    def setUp(self):
        """Setup isolated sandbox environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.models_dir = os.path.join(self.temp_dir, "models")
        self.manifest_path = os.path.join(self.temp_dir, "registry.json")

        self.registry = ModelRegistryService(
            models_dir=self.models_dir, manifest_path=self.manifest_path
        )
        self.classifier = MLPackagingClassifier()
        self.deploy_service = ModelDeploymentService(
            registry_service=self.registry,
            classifier=self.classifier,
        )
        self.dataset_service = DatasetService()
        self.training_engine = ModelTrainingEngine()
        self.evaluation_engine = ModelEvaluationEngine()

        self.pipeline = RetrainingPipeline(
            dataset_service=self.dataset_service,
            training_engine=self.training_engine,
            evaluation_engine=self.evaluation_engine,
            registry_service=self.registry,
            deployment_service=self.deploy_service,
        )

    def tearDown(self):
        """Clean up sandbox directory."""
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    def test_retraining_initial_run_without_active_model(self):
        """Verify retraining when no active model exists."""
        resp = self.pipeline.execute_retraining(
            dataset_id="baseline_archetypes",
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
            auto_promote=False,
        )
        self.assertIsNotNone(resp.candidate_model)
        self.assertIsNone(resp.active_model)
        self.assertFalse(resp.is_promoted)
        self.assertEqual(resp.candidate_model.status, ModelStatusEnum.CANDIDATE)

    def test_retraining_with_active_baseline_comparison(self):
        """Verify performance delta calculation against active baseline model."""
        # 1. Establish an active model first
        resp_initial = self.pipeline.execute_retraining(
            dataset_id="baseline_archetypes",
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
            auto_promote=True,
        )
        self.assertTrue(resp_initial.is_promoted)
        active_id = resp_initial.candidate_model.model_id

        # 2. Retrain with custom hyperparameters without auto-promote
        hp = ModelHyperparameters(n_estimators=30, max_depth=6)
        resp_retrain = self.pipeline.execute_retraining(
            dataset_id="baseline_archetypes",
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
            auto_promote=False,
            hyperparameters=hp,
        )
        self.assertIsNotNone(resp_retrain.active_model)
        self.assertEqual(resp_retrain.active_model.model_id, active_id)
        self.assertFalse(resp_retrain.is_promoted)
        self.assertIsInstance(resp_retrain.accuracy_delta, float)
        self.assertIsInstance(resp_retrain.f1_delta, float)

    def test_auto_promotion_policy_enforcement(self):
        """Verify auto-promotion promotes candidate when delta threshold is met."""
        # Baseline model
        resp1 = self.pipeline.execute_retraining(
            dataset_id="baseline_archetypes",
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
            auto_promote=True,
            hyperparameters=ModelHyperparameters(n_estimators=10, max_depth=2),
        )
        self.assertTrue(resp1.is_promoted)

        # Retrain with deeper trees and auto-promote enabled
        resp2 = self.pipeline.execute_retraining(
            dataset_id="baseline_archetypes",
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
            auto_promote=True,
            min_accuracy_delta=-0.5,  # Force promotion
            hyperparameters=ModelHyperparameters(n_estimators=100, max_depth=12),
        )
        self.assertTrue(resp2.is_promoted)
        self.assertEqual(self.registry.get_active_model().model_id, resp2.candidate_model.model_id)
        self.assertEqual(self.classifier.active_model_id, resp2.candidate_model.model_id)


if __name__ == "__main__":
    unittest.main()
