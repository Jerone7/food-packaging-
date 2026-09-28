"""
Unit & Integration Tests for Admin Analytics & Trends REST API (Module 15 - Task 2.1).
Validates endpoint responses, payload integrity, and RBAC security gates.
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


class TestAdminAnalyticsApi(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        app.dependency_overrides[get_db] = override_get_db
        cls.client = TestClient(app)

    @classmethod
    def tearDownClass(cls):
        app.dependency_overrides.clear()

    def setUp(self):
        self.client = TestClient(app)
        AuthService.reset_memory_store()
        AdminService.reset_runtime_state()

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

        # Standard user
        self.standard_user = User(
            id=101,
            email="engineer@packtech.io",
            hashed_password="hashed_password",
            full_name="Standard User",
            is_active=True,
            is_admin=False,
        )
        AuthService._memory_users[101] = self.standard_user
        AuthService._memory_users_by_email["engineer@packtech.io"] = self.standard_user
        self.user_token = create_access_token(subject=101, role="user")

    def test_get_analytics_summary_authorized(self):
        """Admin successfully fetches system analytics summary."""
        headers = {"Authorization": f"Bearer {self.admin_token}"}
        response = self.client.get("/api/v1/admin/analytics/summary", headers=headers)

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("total_analyses", data)
        self.assertIn("total_users", data)
        self.assertIn("total_foods_count", data)
        self.assertIn("total_materials_count", data)
        self.assertIn("eco_preference_pct", data)
        self.assertIn("average_system_score", data)
        self.assertIn("top_foods", data)
        self.assertIn("top_materials", data)
        self.assertIn("trends", data)
        self.assertIsInstance(data["top_foods"], list)
        self.assertIsInstance(data["top_materials"], list)

    def test_get_analytics_trends_authorized(self):
        """Admin successfully fetches 30-day usage trends."""
        headers = {"Authorization": f"Bearer {self.admin_token}"}
        response = self.client.get("/api/v1/admin/analytics/trends", headers=headers)

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIsInstance(data, list)
        self.assertGreater(len(data), 0)
        first_day = data[0]
        self.assertIn("date", first_day)
        self.assertIn("total_analyses", first_day)
        self.assertIn("eco_analyses", first_day)
        self.assertIn("avg_sustainability_score", first_day)

    def test_analytics_endpoints_reject_non_admin(self):
        """Standard non-admin user receives 403 Forbidden."""
        headers = {"Authorization": f"Bearer {self.user_token}"}
        
        resp1 = self.client.get("/api/v1/admin/analytics/summary", headers=headers)
        self.assertEqual(resp1.status_code, 403)
        self.assertIn("Admin privileges required", resp1.json()["detail"])

        resp2 = self.client.get("/api/v1/admin/analytics/trends", headers=headers)
        self.assertEqual(resp2.status_code, 403)

    def test_analytics_endpoints_reject_unauthenticated(self):
        """Unauthenticated request without Bearer token receives 401 Unauthorized."""
        resp1 = self.client.get("/api/v1/admin/analytics/summary")
        self.assertEqual(resp1.status_code, 401)

        resp2 = self.client.get("/api/v1/admin/analytics/trends")
        self.assertEqual(resp2.status_code, 401)


if __name__ == "__main__":
    unittest.main()
