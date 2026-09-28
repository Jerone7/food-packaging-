"""
Unit & Integration Tests for AI Model Dataset Management Endpoints (Module 16 - Task 5.1).
Tests upload, validation, listing, profiling, and RBAC authentication on /api/v1/admin/models/datasets.
"""

import io
import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.db.session import get_db
from app.models.user import User
from app.services.auth_service import AuthService
from app.core.security import create_access_token


async def override_get_db():
    yield None


class TestAIModelsDatasetApi(unittest.TestCase):
    """Test suite for AI Model Dataset REST endpoints."""

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

    def test_rbac_unauthenticated_and_forbidden(self):
        """Verify unauthenticated requests return 401 and non-admin requests return 403."""
        # Unauthenticated
        resp = self.client.get("/api/v1/admin/models/datasets")
        self.assertEqual(resp.status_code, 401)

        # Non-admin
        resp_forbidden = self.client.get(
            "/api/v1/admin/models/datasets", headers=self.user_headers
        )
        self.assertEqual(resp_forbidden.status_code, 403)

    def test_list_datasets_as_admin(self):
        """Verify admin can list datasets and discover baseline_archetypes."""
        resp = self.client.get("/api/v1/admin/models/datasets", headers=self.admin_headers)
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertIsInstance(data, list)
        self.assertTrue(any(d["dataset_id"] == "baseline_archetypes" for d in data))

    def test_get_dataset_profile_and_preview(self):
        """Verify admin can fetch detailed column distributions and preview rows for baseline."""
        resp = self.client.get(
            "/api/v1/admin/models/datasets/baseline_archetypes", headers=self.admin_headers
        )
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertEqual(data["dataset_id"], "baseline_archetypes")
        self.assertIn("feature_summary", data)
        self.assertIn("preview_rows", data)
        self.assertGreater(len(data["preview_rows"]), 0)
        self.assertIn("class_distribution", data)
        self.assertEqual(len(data["class_distribution"]), 7)

    def test_upload_valid_dataset_and_delete(self):
        """Verify admin can upload a valid CSV dataset and delete it."""
        valid_csv = (
            "food_name,category,moisture_pct,fat_pct,ph,water_activity,respiration_rate_5c,respiration_rate_20c,"
            "ethylene_sensitivity_score,chilling_injury_threshold_c,storage_temp_c,storage_duration_days,"
            "quantity_kg,is_fragile,eco_friendly_priority,is_frozen,is_high_lipid,is_high_resp,is_acidic,"
            "is_perishable_animal_protein,target_polymer_class\n"
            "Guava,Fruits,86.0,0.5,4.8,0.97,12.0,50.0,0.8,8.0,10.0,14,5.0,1.0,1.0,0.0,0.0,1.0,0.0,0.0,BREATHABLE_BIO_EMAP\n"
        )
        files = {"file": ("guava_trial.csv", io.BytesIO(valid_csv.encode("utf-8")), "text/csv")}
        data = {"description": "Tropical guava packaging trial"}

        # Upload
        resp = self.client.post(
            "/api/v1/admin/models/datasets/upload",
            headers=self.admin_headers,
            files=files,
            data=data,
        )
        self.assertEqual(resp.status_code, 201)
        res_data = resp.json()
        self.assertEqual(res_data["dataset"]["dataset_id"], "guava_trial")

        # Delete
        del_resp = self.client.delete(
            "/api/v1/admin/models/datasets/guava_trial", headers=self.admin_headers
        )
        self.assertEqual(del_resp.status_code, 200)
        self.assertIn("deleted successfully", del_resp.json()["message"])

    def test_upload_invalid_schema_rejected(self):
        """Verify corrupted/incomplete CSV uploads are rejected with 422 Unprocessable Entity."""
        invalid_csv = "food_name,moisture_pct\nGuava,86.0\n"
        files = {"file": ("bad_guava.csv", io.BytesIO(invalid_csv.encode("utf-8")), "text/csv")}

        resp = self.client.post(
            "/api/v1/admin/models/datasets/upload",
            headers=self.admin_headers,
            files=files,
        )
        self.assertEqual(resp.status_code, 422)
        self.assertIn("validation failed", resp.json()["detail"].lower())

    def test_delete_baseline_dataset_forbidden(self):
        """Verify attempting to delete baseline_archetypes is blocked with 403 Forbidden."""
        resp = self.client.delete(
            "/api/v1/admin/models/datasets/baseline_archetypes", headers=self.admin_headers
        )
        self.assertEqual(resp.status_code, 403)
        self.assertIn("cannot be deleted", resp.json()["detail"])


if __name__ == "__main__":
    unittest.main()
