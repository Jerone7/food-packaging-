"""
Unit Tests for AI Model Registry, Manifest Catalog & Artifact Serialization Service (Module 16).
Tests model registration, .joblib persistence, manifest state transitions,
active model promotion, and deletion constraints.
"""

import os
import shutil
import tempfile
import unittest
import numpy as np

from app.schemas.ai_model import AlgorithmTypeEnum, ModelStatusEnum
from app.services.ai_dataset_service import DatasetService
from app.services.ai_training_engine import ModelTrainingEngine
from app.services.ai_evaluation_engine import ModelEvaluationEngine
from app.services.ai_registry_service import ModelRegistryService


class TestAIRegistryService(unittest.TestCase):
    """Test suite for ModelRegistryService."""

    def setUp(self):
        """Create sandbox directory for test models and manifest."""
        self.temp_dir = tempfile.mkdtemp()
        self.models_dir = os.path.join(self.temp_dir, "models")
        self.manifest_path = os.path.join(self.temp_dir, "registry.json")

        self.registry = ModelRegistryService(
            models_dir=self.models_dir, manifest_path=self.manifest_path
        )
        self.dataset_service = DatasetService()
        self.df = self.dataset_service.get_dataset_dataframe("baseline_archetypes")
        self.training_engine = ModelTrainingEngine()

        # Train a sample bundle for tests
        self.sample_bundle = self.training_engine.train_sync(
            dataset_df=self.df,
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
        )
        self.sample_metrics = ModelEvaluationEngine.evaluate_bundle(self.sample_bundle)

    def tearDown(self):
        """Clean up temporary sandbox."""
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    def test_register_model_and_artifact_persistence(self):
        """Verify registering a model writes .joblib file and updates registry.json."""
        detail = self.registry.register_model(
            bundle=self.sample_bundle,
            metrics=self.sample_metrics,
            dataset_id="baseline_archetypes",
            version_tag="v1.0.0-test",
            status=ModelStatusEnum.CANDIDATE,
        )
        self.assertTrue(detail.model_id.startswith("RF-"))
        self.assertEqual(detail.status, ModelStatusEnum.CANDIDATE)
        self.assertEqual(detail.version, "v1.0.0-test")
        self.assertTrue(os.path.exists(detail.artifact_path))

        # Query back from registry
        queried = self.registry.get_model(detail.model_id)
        self.assertIsNotNone(queried)
        self.assertEqual(queried.model_id, detail.model_id)
        self.assertAlmostEqual(queried.metrics.accuracy, self.sample_metrics.accuracy, places=3)

    def test_load_artifact_and_reproduce_inference(self):
        """Verify loaded .joblib model produces identical predictions as in-memory model."""
        detail = self.registry.register_model(
            bundle=self.sample_bundle,
            metrics=self.sample_metrics,
            dataset_id="baseline_archetypes",
        )
        loaded = self.registry.load_artifact(detail.model_id)

        self.assertEqual(loaded["model_id"], detail.model_id)
        self.assertIn("model", loaded)
        self.assertIn("scaler", loaded)
        self.assertIn("label_encoder", loaded)

        # Run test predictions
        original_preds = self.sample_bundle.model.predict(
            self.sample_bundle.preprocessed_bundle.X_test
        )
        loaded_preds = loaded["model"].predict(
            self.sample_bundle.preprocessed_bundle.X_test
        )
        np.testing.assert_array_equal(original_preds, loaded_preds)

    def test_active_model_promotion_and_demotion(self):
        """Verify promoting a model updates active_model_id and demotes former active model."""
        # Register Model 1 as ACTIVE
        m1 = self.registry.register_model(
            bundle=self.sample_bundle,
            metrics=self.sample_metrics,
            dataset_id="baseline_archetypes",
            version_tag="v1.0",
            status=ModelStatusEnum.ACTIVE,
        )
        self.assertEqual(self.registry.get_active_model().model_id, m1.model_id)

        # Register Model 2 as CANDIDATE
        m2_bundle = self.training_engine.train_sync(
            dataset_df=self.df,
            algorithm=AlgorithmTypeEnum.GRADIENT_BOOSTING,
        )
        m2_metrics = ModelEvaluationEngine.evaluate_bundle(m2_bundle)
        m2 = self.registry.register_model(
            bundle=m2_bundle,
            metrics=m2_metrics,
            dataset_id="baseline_archetypes",
            version_tag="v2.0",
            status=ModelStatusEnum.CANDIDATE,
        )

        # Promote Model 2 to ACTIVE
        promoted, prev_id = self.registry.set_active_model(m2.model_id)
        self.assertEqual(promoted.model_id, m2.model_id)
        self.assertEqual(promoted.status, ModelStatusEnum.ACTIVE)
        self.assertEqual(prev_id, m1.model_id)

        # Verify m1 is now ARCHIVED
        m1_updated = self.registry.get_model(m1.model_id)
        self.assertEqual(m1_updated.status, ModelStatusEnum.ARCHIVED)

    def test_list_models_with_filters(self):
        """Verify list_models filtering by status."""
        self.registry.register_model(
            bundle=self.sample_bundle,
            metrics=self.sample_metrics,
            dataset_id="baseline_archetypes",
            status=ModelStatusEnum.ACTIVE,
        )
        self.registry.register_model(
            bundle=self.sample_bundle,
            metrics=self.sample_metrics,
            dataset_id="baseline_archetypes",
            status=ModelStatusEnum.CANDIDATE,
        )

        all_models = self.registry.list_models("all")
        self.assertEqual(all_models.total_models, 2)

        active_models = self.registry.list_models("active")
        self.assertEqual(active_models.total_models, 1)

        candidate_models = self.registry.list_models("candidate")
        self.assertEqual(candidate_models.total_models, 1)

    def test_delete_model_and_active_protection(self):
        """Verify deletion behavior and active model protection."""
        m_active = self.registry.register_model(
            bundle=self.sample_bundle,
            metrics=self.sample_metrics,
            dataset_id="baseline_archetypes",
            status=ModelStatusEnum.ACTIVE,
        )
        m_candidate = self.registry.register_model(
            bundle=self.sample_bundle,
            metrics=self.sample_metrics,
            dataset_id="baseline_archetypes",
            status=ModelStatusEnum.CANDIDATE,
        )

        # Attempting to delete active model must raise PermissionError
        with self.assertRaises(PermissionError):
            self.registry.delete_model(m_active.model_id)

        # Deleting candidate model should succeed and remove artifact file
        candidate_path = m_candidate.artifact_path
        self.assertTrue(os.path.exists(candidate_path))
        self.assertTrue(self.registry.delete_model(m_candidate.model_id))
        self.assertFalse(os.path.exists(candidate_path))
        self.assertIsNone(self.registry.get_model(m_candidate.model_id))


if __name__ == "__main__":
    unittest.main()
