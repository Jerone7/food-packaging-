"""
Integration Tests for Packaging History REST API Endpoints (Module 13 - Task 2.1).
Validates /users/me/history, /packaging/history, and /packaging/history/{id}.
"""

import unittest
from fastapi.testclient import TestClient
from app.main import app
from app.db.session import get_db
from app.services.auth_service import AuthService
from app.services.packaging_service import PackagingHistoryService
from app.core.security import create_access_token


async def override_get_db():
    yield None


class TestHistoryEndpoints(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        app.dependency_overrides[get_db] = override_get_db
        cls.client = TestClient(app)

    @classmethod
    def tearDownClass(cls):
        app.dependency_overrides.clear()

    def setUp(self):
        # Reset memory stores
        AuthService.reset_memory_store()
        PackagingHistoryService.reset_memory_store(with_samples=True)

        # Create user via signup endpoint to ensure complete session registration
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


    def test_get_my_history_authenticated(self):
        """Verify GET /api/v1/users/me/history returns user-scoped records with formatted_date."""
        res = self.client.get("/api/v1/users/me/history", headers=self.auth_headers)
        self.assertEqual(res.status_code, 200)

        data = res.json()
        self.assertIsInstance(data, list)
        self.assertGreaterEqual(len(data), 3)

        # Check chronological items and formatted date string
        self.assertEqual(data[0]["item_name"], "Tomato")
        self.assertEqual(data[0]["formatted_date"], "26 Sep 2026")
        self.assertEqual(data[1]["item_name"], "Apple")
        self.assertEqual(data[1]["formatted_date"], "25 Sep 2026")
        self.assertEqual(data[2]["item_name"], "Potato")
        self.assertEqual(data[2]["formatted_date"], "23 Sep 2026")

    def test_get_my_history_unauthenticated_fails(self):
        """Verify GET /api/v1/users/me/history requires Bearer authentication."""
        res = self.client.get("/api/v1/users/me/history")
        self.assertEqual(res.status_code, 401)

    def test_get_packaging_history_endpoint(self):
        """Verify GET /api/v1/packaging/history returns list of history items."""
        res = self.client.get("/api/v1/packaging/history", headers=self.auth_headers)
        self.assertEqual(res.status_code, 200)

        data = res.json()
        self.assertIsInstance(data, list)
        self.assertGreaterEqual(len(data), 3)
        self.assertEqual(data[0]["item_name"], "Tomato")
        self.assertEqual(data[0]["formatted_date"], "26 Sep 2026")

    def test_get_history_detail_endpoint(self):
        """Verify GET /api/v1/packaging/history/{id} returns single record details."""
        res = self.client.get("/api/v1/packaging/history/201")
        self.assertEqual(res.status_code, 200)

        data = res.json()
        self.assertEqual(data["id"], 201)
        self.assertEqual(data["item_name"], "Tomato")
        self.assertEqual(data["formatted_date"], "26 Sep 2026")
        self.assertEqual(data["recommended_box_type"], "Corrugated Kraft Box (5-Ply)")

    def test_get_history_detail_not_found(self):
        """Verify GET /api/v1/packaging/history/{id} returns 404 for nonexistent id."""
        res = self.client.get("/api/v1/packaging/history/99999")
        self.assertEqual(res.status_code, 404)

    def test_recommendation_auto_saves_user_history(self):
        """Verify POST /api/v1/packaging/recommend records history with authenticated user ID."""
        payload = {
            "food_name": "Fresh Strawberries",
            "quantity": 1.0,
            "category": "Fruits",
            "is_fragile": True,
            "eco_friendly": True,
        }

        res = self.client.post("/api/v1/packaging/recommend", json=payload, headers=self.auth_headers)
        self.assertEqual(res.status_code, 200)

        # Verify history was updated
        history_res = self.client.get("/api/v1/users/me/history", headers=self.auth_headers)
        self.assertEqual(history_res.status_code, 200)
        history_data = history_res.json()
        self.assertEqual(history_data[0]["item_name"], "Fresh Strawberries")


if __name__ == "__main__":
    unittest.main()
