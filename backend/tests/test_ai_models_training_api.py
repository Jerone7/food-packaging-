"""
Unit & Integration Tests for AI Model Training & Retraining Endpoints (Module 16 - Task 5.2).
Tests async training job dispatch, status polling, retraining pipeline execution, and RBAC authentication.
"""

import time
import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.db.session import get_db
from app.models.user import User
from app.services.auth_service import AuthService
from app.core.security import create_access_token
from app.schemas.ai_model import AlgorithmTypeEnum


async def override_get_db():
    yield None


class TestAIModelsTrainingApi(unittest.TestCase):
    """Test suite for AI Model Training & Retraining REST endpoints."""

    @classmethod
    def setUpClass(cls):
        app.dependency_overrides[get_db] = override_get_db
        cls.client = TestClient(app)

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

    def test_rbac_protection_on_training_and_retraining(self):
        """Verify unauthenticated requests return 401 and non-admin requests return 403."""
        # Unauthenticated /train
        resp = self.client.post("/api/v1/admin/models/train", json={})
        self.assertEqual(resp.status_code, 401)

        # Non-admin /train
        resp_forbidden = self.client.post(
            "/api/v1/admin/models/train", json={}, headers=self.user_headers
        )
        self.assertEqual(resp_forbidden.status_code, 403)

        # Non-admin /retrain
        resp_retrain_forbidden = self.client.post(
            "/api/v1/admin/models/retrain", json={}, headers=self.user_headers
        )
        self.assertEqual(resp_retrain_forbidden.status_code, 403)

    def test_trigger_and_poll_training_job(self):
        """Verify admin can trigger async training job and poll until completion."""
        train_payload = {
            "dataset_id": "baseline_archetypes",
            "algorithm": "RANDOM_FOREST",
            "hyperparameters": {
                "n_estimators": 50,
                "max_depth": 10,
                "scaling_method": "standard",
            },
        }

        # 1. Trigger training
        resp = self.client.post(
            "/api/v1/admin/models/train",
            headers=self.admin_headers,
            json=train_payload,
        )
        self.assertEqual(resp.status_code, 202)
        job_data = resp.json()
        self.assertIn("job_id", job_data)
        self.assertTrue(job_data["job_id"].startswith("job-"))
        job_id = job_data["job_id"]

        # 2. Poll job status
        max_attempts = 40
        status_data = None
        for _ in range(max_attempts):
            poll_resp = self.client.get(
                f"/api/v1/admin/models/jobs/{job_id}", headers=self.admin_headers
            )
            self.assertEqual(poll_resp.status_code, 200)
            status_data = poll_resp.json()
            if status_data["status"] in ["completed", "failed"]:
                break
            time.sleep(0.1)

        self.assertIsNotNone(status_data)
        self.assertEqual(status_data["status"], "completed")
        self.assertIsNotNone(status_data["elapsed_time_ms"])
        self.assertIsNotNone(status_data["model_result"])
        self.assertTrue(status_data["model_result"]["model_id"].startswith("RF-"))

    def test_trigger_retraining_pipeline_api(self):
        """Verify triggering retraining computes deltas and returns comparison report."""
        retrain_payload = {
            "dataset_id": "baseline_archetypes",
            "algorithm": "RANDOM_FOREST",
            "auto_promote": False,
            "min_accuracy_delta": 0.005,
        }

        resp = self.client.post(
            "/api/v1/admin/models/retrain",
            headers=self.admin_headers,
            json=retrain_payload,
        )
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertIn("candidate_model", data)
        self.assertIn("accuracy_delta", data)
        self.assertIn("f1_delta", data)
        self.assertIn("is_promoted", data)
        self.assertFalse(data["is_promoted"])


if __name__ == "__main__":
    unittest.main()
