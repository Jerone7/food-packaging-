"""
Tests for analysis history saving policy based on authentication status.
Policy:
- If user is logged in, analysis is stored in their registered account history.
- If user is NOT logged in (guest/anonymous), analysis is NOT saved to database history.
"""

import unittest
from fastapi.testclient import TestClient
from app.main import app
from app.db.session import get_db
from app.services.auth_service import AuthService
from app.services.packaging_service import PackagingHistoryService


async def override_get_db():
    yield None


class TestAuthenticatedHistoryPersistence(unittest.TestCase):
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

        # Create user via signup endpoint
        signup_payload = {
            "email": "lead@smartpack.io",
            "password": "Password@123",
            "full_name": "Lead Engineer",
            "organization": "BioPack Lab",
        }
        res = self.client.post("/api/v1/auth/signup", json=signup_payload)
        self.assertEqual(res.status_code, 201)
        data = res.json()
        self.user_id = data["user"]["id"]
        self.auth_token = data["access_token"]
        self.auth_headers = {"Authorization": f"Bearer {self.auth_token}"}

    def test_authenticated_user_analysis_is_saved_in_history(self):
        initial_history = self.client.get("/api/v1/users/me/history", headers=self.auth_headers).json()
        initial_count = len(initial_history)

        payload = {
            "item_name": "Premium Avocado",
            "length": 22.0,
            "width": 14.0,
            "height": 10.0,
            "weight": 1.5,
            "is_fragile": True,
            "eco_friendly": True,
            "category": "Fruits",
            "moisture": 72.0,
            "fat": 15.0,
            "storage_temp_c": 8.0,
            "storage_duration_days": 12,
        }

        # Submit analysis as authenticated user
        response = self.client.post("/api/v1/packaging/recommend", json=payload, headers=self.auth_headers)
        self.assertEqual(response.status_code, 200)

        # Verify it now appears in user's history
        updated_history = self.client.get("/api/v1/users/me/history", headers=self.auth_headers).json()
        self.assertEqual(len(updated_history), initial_count + 1)
        self.assertEqual(updated_history[0]["item_name"], "Premium Avocado")

    def test_unauthenticated_user_analysis_is_not_saved_in_history(self):
        initial_history = self.client.get("/api/v1/users/me/history", headers=self.auth_headers).json()
        initial_count = len(initial_history)

        payload = {
            "item_name": "Anonymous Papaya",
            "length": 30.0,
            "width": 18.0,
            "height": 16.0,
            "weight": 2.5,
            "is_fragile": False,
            "eco_friendly": False,
            "category": "Fruits",
        }

        # Submit analysis without auth headers (guest/unauthenticated)
        response = self.client.post("/api/v1/packaging/recommend", json=payload)
        self.assertEqual(response.status_code, 200)
        self.assertIn("recommended_box_type", response.json())

        # Verify user history count did not change and item does not exist
        updated_history = self.client.get("/api/v1/users/me/history", headers=self.auth_headers).json()
        self.assertEqual(len(updated_history), initial_count)
        self.assertFalse(any(item["item_name"] == "Anonymous Papaya" for item in updated_history))


if __name__ == "__main__":
    unittest.main()
