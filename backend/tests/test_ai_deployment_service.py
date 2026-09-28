"""
Unit Tests for AI Zero-Downtime Model Deployment & Hot-Swapping Service (Module 16).
Tests atomic model deployment, in-memory hot-swapping, runtime inference reflection,
and instant version rollbacks.
"""

import os
import shutil
import tempfile
import unittest

from app.schemas.ai_model import AlgorithmTypeEnum, ModelStatusEnum
from app.services.ai_dataset_service import DatasetService
from app.services.ai_training_engine import ModelTrainingEngine
from app.services.ai_evaluation_engine import ModelEvaluationEngine
from app.services.ai_registry_service import ModelRegistryService
from app.services.ai_deployment_service import ModelDeploymentService
from app.services.ml_classifier import MLPackagingClassifier
from app.services.hybrid_recommender import HybridRecommendationEngine


class TestAIDeploymentService(unittest.TestCase):
    """Test suite for ModelDeploymentService."""

    def setUp(self):
        """Create sandboxed environment with dedicated registry and classifier."""
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
        self.df = self.dataset_service.get_dataset_dataframe("baseline_archetypes")
        self.training_engine = ModelTrainingEngine()

        # Train Model 1 (Random Forest)
        self.bundle_rf = self.training_engine.train_sync(
            dataset_df=self.df,
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
        )
        self.metrics_rf = ModelEvaluationEngine.evaluate_bundle(self.bundle_rf)
        self.model_rf_detail = self.registry.register_model(
            bundle=self.bundle_rf,
            metrics=self.metrics_rf,
            dataset_id="baseline_archetypes",
            version_tag="RF-v1.0.0",
            status=ModelStatusEnum.CANDIDATE,
        )

        # Train Model 2 (Gradient Boosting)
        self.bundle_gbdt = self.training_engine.train_sync(
            dataset_df=self.df,
            algorithm=AlgorithmTypeEnum.GRADIENT_BOOSTING,
        )
        self.metrics_gbdt = ModelEvaluationEngine.evaluate_bundle(self.bundle_gbdt)
        self.model_gbdt_detail = self.registry.register_model(
            bundle=self.bundle_gbdt,
            metrics=self.metrics_gbdt,
            dataset_id="baseline_archetypes",
            version_tag="GBDT-v1.0.0",
            status=ModelStatusEnum.CANDIDATE,
        )

    def tearDown(self):
        """Clean up sandbox directory."""
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    def test_deploy_model_hot_swap(self):
        """Verify model deployment immediately hot-swaps classifier in-memory."""
        resp = self.deploy_service.deploy_model(self.model_rf_detail.model_id)

        self.assertEqual(resp.deployed_model_id, self.model_rf_detail.model_id)
        self.assertEqual(self.classifier.active_model_id, self.model_rf_detail.model_id)
        self.assertEqual(self.classifier.active_version, "RF-v1.0.0")
        self.assertIsNotNone(self.classifier.scaler)
        self.assertIsNotNone(self.classifier.label_encoder)

        # Verify inference execution uses new model
        sample_input = {
            "name": "Fresh Spinach",
            "category": "Vegetables",
            "moisture": 91.4,
            "fat": 0.4,
            "ph": 6.5,
            "storage_temp_c": 4.0,
            "storage_duration_days": 7,
            "respiration_rate_20c": 90.0,
        }
        pred_class = self.classifier.classify(sample_input)
        self.assertEqual(pred_class, "BREATHABLE_BIO_EMAP")

    def test_hot_swap_to_second_model(self):
        """Verify seamless transition between two different algorithms."""
        # Deploy RF
        self.deploy_service.deploy_model(self.model_rf_detail.model_id)
        self.assertEqual(self.classifier.active_model_id, self.model_rf_detail.model_id)

        # Deploy GBDT
        resp2 = self.deploy_service.deploy_model(self.model_gbdt_detail.model_id)
        self.assertEqual(resp2.deployed_model_id, self.model_gbdt_detail.model_id)
        self.assertEqual(resp2.previous_model_id, self.model_rf_detail.model_id)
        self.assertEqual(self.classifier.active_model_id, self.model_gbdt_detail.model_id)

    def test_instant_rollback(self):
        """Verify rollback restores previous model active state."""
        self.deploy_service.deploy_model(self.model_rf_detail.model_id)
        self.deploy_service.deploy_model(self.model_gbdt_detail.model_id)

        # Rollback to RF
        rollback_resp = self.deploy_service.rollback_to_model(
            self.model_rf_detail.model_id, reason="Testing rollback mechanism"
        )
        self.assertEqual(rollback_resp.deployed_model_id, self.model_rf_detail.model_id)
        self.assertEqual(self.classifier.active_model_id, self.model_rf_detail.model_id)
        self.assertEqual(self.registry.get_active_model().model_id, self.model_rf_detail.model_id)

    def test_hybrid_recommender_integration_with_deployed_model(self):
        """Verify HybridRecommendationEngine utilizes the active deployed classifier."""
        self.deploy_service.deploy_model(self.model_rf_detail.model_id)
        recommender = HybridRecommendationEngine(classifier=self.classifier)

        food_req = {
            "name": "Potato Crisps",
            "category": "Snacks",
            "moisture": 1.8,
            "fat": 34.0,
            "ph": 6.2,
            "storage_temperature_c": 25.0,
            "duration": 180,
        }
        rec_result = recommender.recommend(food_req)
        self.assertIsNotNone(rec_result)
        self.assertIsNotNone(rec_result.primary_material)
        self.assertGreater(rec_result.suitability_score, 0.0)


if __name__ == "__main__":
    unittest.main()
