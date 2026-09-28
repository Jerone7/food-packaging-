"""
Unit & Integration Tests for Rules, Model Registry, and Recommendations Audit REST API (Module 15 - Task 2.4).
Validates dynamic rules updates, ML model registry inspection, audit logs streaming, and RBAC protection.
"""

import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.db.session import get_db
from app.models.user import User
from app.services.auth_service import AuthService
from app.services.admin_service import AdminService
from app.core.security import create_access_token


async def override_get_db():
    yield None


class TestAdminRulesAndAuditApi(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        app.dependency_overrides[get_db] = override_get_db
        cls.client = TestClient(app)

    @classmethod
    def tearDownClass(cls):
        app.dependency_overrides.clear()

    def setUp(self):
        AuthService.reset_memory_store()
        AdminService.reset_runtime_state()

        # Admin user setup
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

        # Non-admin user setup
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

    def test_get_and_update_rules_thresholds(self):
        """Admin fetches and dynamically modifies scientific rule thresholds."""
        # 1. Get default rules
        get_resp = self.client.get("/api/v1/admin/rules", headers=self.admin_headers)
        self.assertEqual(get_resp.status_code, 200)
        rules = get_resp.json()
        self.assertEqual(rules["lipid_oxidation_fat_threshold_pct"], 18.0)
        self.assertEqual(rules["high_respiration_moisture_threshold_pct"], 75.0)

        # 2. Update rules
        update_payload = {
            "lipid_oxidation_fat_threshold_pct": 22.0,
            "chilling_injury_buffer_c": 3.0,
            "eco_priority_multiplier": 1.75,
        }
        put_resp = self.client.put("/api/v1/admin/rules", json=update_payload, headers=self.admin_headers)
        self.assertEqual(put_resp.status_code, 200)
        updated_rules = put_resp.json()
        self.assertEqual(updated_rules["lipid_oxidation_fat_threshold_pct"], 22.0)
        self.assertEqual(updated_rules["chilling_injury_buffer_c"], 3.0)
        self.assertEqual(updated_rules["eco_priority_multiplier"], 1.75)
        # Unmodified should be intact
        self.assertEqual(updated_rules["high_respiration_moisture_threshold_pct"], 75.0)

    def test_model_registry_and_ml_toggle(self):
        """Admin fetches active ML model metadata and toggles ML execution."""
        # 1. Get Model Info
        get_resp = self.client.get("/api/v1/admin/models/active", headers=self.admin_headers)
        self.assertEqual(get_resp.status_code, 200)
        model_data = get_resp.json()
        self.assertEqual(model_data["active_model_name"], "RandomForest-v2.3-18D")
        self.assertEqual(model_data["feature_dimension"], 18)
        self.assertTrue(model_data["is_ml_enabled"])

        # 2. Toggle ML off
        patch_resp = self.client.patch("/api/v1/admin/models/toggle-ml", headers=self.admin_headers)
        self.assertEqual(patch_resp.status_code, 200)
        self.assertFalse(patch_resp.json()["is_ml_enabled"])

        # Toggle back on
        patch_resp_2 = self.client.patch("/api/v1/admin/models/toggle-ml", headers=self.admin_headers)
        self.assertEqual(patch_resp_2.status_code, 200)
        self.assertTrue(patch_resp_2.json()["is_ml_enabled"])

    def test_recommendations_audit_stream(self):
        """Admin fetches system-wide recommendations audit stream."""
        audit_resp = self.client.get("/api/v1/admin/recommendations/audit", headers=self.admin_headers)
        self.assertEqual(audit_resp.status_code, 200)
        data = audit_resp.json()
        self.assertIn("total_count", data)
        self.assertIn("items", data)
        self.assertIsInstance(data["items"], list)
        self.assertGreater(len(data["items"]), 0)

        first_audit = data["items"][0]
        self.assertIn("item_name", first_audit)
        self.assertIn("recommended_box_type", first_audit)
        self.assertIn("sustainability_score", first_audit)
        self.assertIn("formatted_date", first_audit)

    def test_governance_endpoints_reject_non_admin(self):
        """Non-admin standard user receives 403 Forbidden."""
        resp1 = self.client.get("/api/v1/admin/rules", headers=self.user_headers)
        self.assertEqual(resp1.status_code, 403)

        resp2 = self.client.get("/api/v1/admin/models/active", headers=self.user_headers)
        self.assertEqual(resp2.status_code, 403)

        resp3 = self.client.get("/api/v1/admin/recommendations/audit", headers=self.user_headers)
        self.assertEqual(resp3.status_code, 403)

    def test_governance_endpoints_reject_unauthenticated(self):
        """Unauthenticated request receives 401 Unauthorized."""
        resp1 = self.client.get("/api/v1/admin/rules")
        self.assertEqual(resp1.status_code, 401)

        resp2 = self.client.get("/api/v1/admin/models/active")
        self.assertEqual(resp2.status_code, 401)


if __name__ == "__main__":
    unittest.main()
