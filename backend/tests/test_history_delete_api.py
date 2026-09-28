"""
Integration Tests for Packaging History Deletion Endpoints (Module 13 - Task 2.2).
Validates DELETE /packaging/history/{id} and DELETE /users/me/history.
"""

import unittest
from fastapi.testclient import TestClient
from app.main import app
from app.db.session import get_db
from app.services.auth_service import AuthService
from app.services.packaging_service import PackagingHistoryService


async def override_get_db():
    yield None


class TestHistoryDeleteEndpoints(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        app.dependency_overrides[get_db] = override_get_db
        cls.client = TestClient(app)

    @classmethod
    def tearDownClass(cls):
        app.dependency_overrides.clear()

    def setUp(self):
        AuthService.reset_memory_store()
        PackagingHistoryService.reset_memory_store(with_samples=True)

        signup_payload = {
            "email": "engineer@smartpack.io",
            "password": "Password@123",
            "full_name": "Dr. Sarah Jenkins",
            "organization": "SmartPack Labs",
            "role": "Packaging Lead",
        }
        res = self.client.post("/api/v1/auth/signup", json=signup_payload)
        self.assertEqual(res.status_code, 201)
        data = res.json()
        self.user_id = data["user"]["id"]
        self.auth_token = data["access_token"]
        self.auth_headers = {"Authorization": f"Bearer {self.auth_token}"}

    def test_delete_individual_history_entry(self):
        """Verify DELETE /api/v1/packaging/history/{id} deletes the item."""
        res = self.client.delete("/api/v1/packaging/history/201", headers=self.auth_headers)
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertTrue(data["success"])
        self.assertEqual(data["deleted_id"], 201)

        # Verify it no longer exists
        get_res = self.client.get("/api/v1/packaging/history/201")
        self.assertEqual(get_res.status_code, 404)

    def test_delete_nonexistent_history_entry_fails(self):
        """Verify deleting a nonexistent ID returns 404."""
        res = self.client.delete("/api/v1/packaging/history/99999", headers=self.auth_headers)
        self.assertEqual(res.status_code, 404)

    def test_clear_my_history_authenticated(self):
        """Verify DELETE /api/v1/users/me/history clears all user records."""
        res = self.client.delete("/api/v1/users/me/history", headers=self.auth_headers)
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertTrue(data["success"])
        self.assertGreaterEqual(data["deleted_count"], 3)

        # Verify history is now empty
        history_res = self.client.get("/api/v1/users/me/history", headers=self.auth_headers)
        self.assertEqual(history_res.status_code, 200)
        self.assertEqual(len(history_res.json()), 0)

    def test_clear_my_history_unauthenticated_fails(self):
        """Verify DELETE /api/v1/users/me/history requires authentication."""
        res = self.client.delete("/api/v1/users/me/history")
        self.assertEqual(res.status_code, 401)


if __name__ == "__main__":
    unittest.main()
