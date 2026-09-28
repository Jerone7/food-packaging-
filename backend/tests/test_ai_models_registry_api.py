"""
Unit & Integration Tests for AI Model Registry, Evaluation & Deployment REST Endpoints (Module 16 - Task 5.3).
Tests registry listing, evaluation inspection, zero-downtime hot-swap deployment, rollbacks, and RBAC authentication.
"""

import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.db.session import get_db
from app.models.user import User
from app.services.auth_service import AuthService
from app.core.security import create_access_token
from app.schemas.ai_model import AlgorithmTypeEnum, ModelStatusEnum
from app.services.ai_dataset_service import DatasetService
from app.services.ai_training_engine import ModelTrainingEngine
from app.services.ai_evaluation_engine import ModelEvaluationEngine
from app.api.v1.endpoints.ai_models import registry_service, deployment_service


async def override_get_db():
    yield None


class TestAIModelsRegistryApi(unittest.TestCase):
    """Test suite for AI Model Registry, Evaluation & Deployment REST API."""

    @classmethod
    def setUpClass(cls):
        app.dependency_overrides[get_db] = override_get_db
        cls.client = TestClient(app)

        # Train and register baseline models in the active endpoint registry service
        dataset_service = DatasetService()
        training_engine = ModelTrainingEngine()
        evaluation_engine = ModelEvaluationEngine()

        df = dataset_service.get_dataset_dataframe("baseline_archetypes")

        # Model 1: Random Forest
        bundle_rf = training_engine.train_sync(df, AlgorithmTypeEnum.RANDOM_FOREST)
        metrics_rf = evaluation_engine.evaluate_bundle(bundle_rf)
        cls.m1 = registry_service.register_model(
            bundle=bundle_rf,
            metrics=metrics_rf,
            dataset_id="baseline_archetypes",
            version_tag="RF-v1.0.0",
            status=ModelStatusEnum.ACTIVE,
        )

        # Model 2: Gradient Boosting
        bundle_gbdt = training_engine.train_sync(df, AlgorithmTypeEnum.GRADIENT_BOOSTING)
        metrics_gbdt = evaluation_engine.evaluate_bundle(bundle_gbdt)
        cls.m2 = registry_service.register_model(
            bundle=bundle_gbdt,
            metrics=metrics_gbdt,
            dataset_id="baseline_archetypes",
            version_tag="GBDT-v1.0.0",
            status=ModelStatusEnum.CANDIDATE,
        )

    @classmethod
    def tearDownClass(cls):
        app.dependency_overrides.clear()

    def setUp(self):
        AuthService.reset_memory_store()

        # Admin user
        self.admin = User(
            id=999,
            email="admin@packtech.io",
            hashed_password="hashed_password",
            full_name="Chief Admin",
            is_active=True,
            is_admin=True,
        )
        AuthService._memory_users[999] = self.admin
        AuthService._memory_users_by_email["admin@packtech.io"] = self.admin
        self.admin_token = create_access_token(subject=999, role="admin")
        self.admin_headers = {"Authorization": f"Bearer {self.admin_token}"}

        # Non-admin user
        self.standard_user = User(
            id=101,
            email="user@packtech.io",
            hashed_password="hashed_password",
            full_name="Standard User",
            is_active=True,
            is_admin=False,
        )
        AuthService._memory_users[101] = self.standard_user
        AuthService._memory_users_by_email["user@packtech.io"] = self.standard_user
        self.user_token = create_access_token(subject=101, role="user")
        self.user_headers = {"Authorization": f"Bearer {self.user_token}"}

    def test_rbac_protection(self):
        """Verify 401 unauthenticated and 403 non-admin on registry and deploy endpoints."""
        # Unauthenticated
        self.assertEqual(self.client.get("/api/v1/admin/models/registry").status_code, 401)
        self.assertEqual(
            self.client.post(f"/api/v1/admin/models/{self.m2.model_id}/deploy").status_code, 401
        )

        # Non-admin
        self.assertEqual(
            self.client.get("/api/v1/admin/models/registry", headers=self.user_headers).status_code,
            403,
        )
        self.assertEqual(
            self.client.post(
                f"/api/v1/admin/models/{self.m2.model_id}/deploy", headers=self.user_headers
            ).status_code,
            403,
        )

    def test_list_registry_and_filter(self):
        """Verify listing registered models and filtering by status."""
        resp = self.client.get("/api/v1/admin/models/registry", headers=self.admin_headers)
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertGreaterEqual(data["total_models"], 2)
        self.assertIn("active_model_id", data)

        # Filter candidate
        resp_cand = self.client.get(
            "/api/v1/admin/models/registry?status=candidate", headers=self.admin_headers
        )
        self.assertEqual(resp_cand.status_code, 200)
        self.assertTrue(all(m["status"] == "candidate" for m in resp_cand.json()["models"]))

    def test_get_model_details_and_evaluation(self):
        """Verify fetching model metadata and deep evaluation metrics."""
        # Details
        resp = self.client.get(
            f"/api/v1/admin/models/{self.m1.model_id}", headers=self.admin_headers
        )
        self.assertEqual(resp.status_code, 200)
        detail = resp.json()
        self.assertEqual(detail["model_id"], self.m1.model_id)
        self.assertEqual(detail["dimensions"], 18)

        # Evaluation metrics
        eval_resp = self.client.get(
            f"/api/v1/admin/models/{self.m1.model_id}/evaluation", headers=self.admin_headers
        )
        self.assertEqual(eval_resp.status_code, 200)
        eval_data = eval_resp.json()
        self.assertIn("confusion_matrix", eval_data)
        self.assertEqual(len(eval_data["confusion_matrix"]), 7)
        self.assertIn("feature_importances", eval_data)
        self.assertEqual(len(eval_data["feature_importances"]), 18)

    def test_deploy_and_rollback_model_api(self):
        """Verify hot-swapping a model to ACTIVE and rolling back."""
        # Deploy Model 2
        deploy_resp = self.client.post(
            f"/api/v1/admin/models/{self.m2.model_id}/deploy",
            headers=self.admin_headers,
            json={"notes": "Deploying GBDT via API"},
        )
        self.assertEqual(deploy_resp.status_code, 200)
        deploy_data = deploy_resp.json()
        self.assertEqual(deploy_data["deployed_model_id"], self.m2.model_id)

        # Rollback to Model 1
        rollback_resp = self.client.post(
            f"/api/v1/admin/models/{self.m1.model_id}/rollback",
            headers=self.admin_headers,
            json={"reason": "Rolling back via API"},
        )
        self.assertEqual(rollback_resp.status_code, 200)
        rollback_data = rollback_resp.json()
        self.assertEqual(rollback_data["deployed_model_id"], self.m1.model_id)

    def test_delete_model_protection(self):
        """Verify active model cannot be deleted (403 Forbidden)."""
        # Attempting to delete active model
        resp = self.client.delete(
            f"/api/v1/admin/models/{self.m1.model_id}", headers=self.admin_headers
        )
        self.assertEqual(resp.status_code, 403)
        self.assertIn("cannot delete the currently active model", resp.json()["detail"].lower())


if __name__ == "__main__":
    unittest.main()
