"""
Unit & Integration Tests for Food Management Admin Endpoints (Module 15 - Task 2.2).
Validates full CRUD lifecycle, 14 scientific properties updates, and RBAC authentication.
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


class TestAdminFoodCrudApi(unittest.TestCase):
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

    def test_list_admin_foods(self):
        """Admin successfully retrieves paginated and filtered foods list."""
        response = self.client.get("/api/v1/admin/foods?category=Produce", headers=self.admin_headers)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("total_count", data)
        self.assertIn("items", data)
        self.assertIsInstance(data["items"], list)

    def test_full_food_crud_lifecycle(self):
        """Validates create, get, update core, update scientific props, and delete."""
        # 1. Create
        create_payload = {
            "name": "Dragon Fruit",
            "category": "Produce",
            "scientific_name": "Selenicereus undatus",
            "moisture": 87.0,
            "ph": 4.5,
            "water_activity": 0.98,
            "fat": 0.3,
            "respiration_class": "Moderate",
            "oxygen_sensitivity": "Moderate",
            "moisture_sensitivity": "High",
        }
        create_resp = self.client.post("/api/v1/admin/foods", json=create_payload, headers=self.admin_headers)
        self.assertEqual(create_resp.status_code, 201)
        created_food = create_resp.json()
        food_id = created_food["id"]
        self.assertEqual(created_food["name"], "Dragon Fruit")

        # 2. Get Single Food
        get_resp = self.client.get(f"/api/v1/admin/foods/{food_id}", headers=self.admin_headers)
        self.assertEqual(get_resp.status_code, 200)
        self.assertEqual(get_resp.json()["id"], food_id)

        # 3. Update Core Attributes
        update_payload = {
            "moisture": 85.0,
            "fat": 0.4,
        }
        update_resp = self.client.put(f"/api/v1/admin/foods/{food_id}", json=update_payload, headers=self.admin_headers)
        self.assertEqual(update_resp.status_code, 200)
        self.assertEqual(update_resp.json()["moisture"], 85.0)
        self.assertEqual(update_resp.json()["fat"], 0.4)

        # 4. Update 14 Scientific Properties
        sc_payload = {
            "respiration_rate_20c": 28.0,
            "respiration_rate_5c": 9.5,
            "chilling_injury_threshold_c": 10.0,
            "ambient_shelf_life_days": 12,
            "refrigerated_shelf_life_days": 25,
        }
        sc_resp = self.client.put(f"/api/v1/admin/foods/{food_id}/scientific-properties", json=sc_payload, headers=self.admin_headers)
        self.assertEqual(sc_resp.status_code, 200)
        sc_data = sc_resp.json()["scientific_properties"]
        self.assertIsNotNone(sc_data)
        self.assertEqual(sc_data["respiration_rate_20c"], 28.0)
        self.assertEqual(sc_data["chilling_injury_threshold_c"], 10.0)

        # 5. Delete Food
        delete_resp = self.client.delete(f"/api/v1/admin/foods/{food_id}", headers=self.admin_headers)
        self.assertEqual(delete_resp.status_code, 204)

        # 6. Verify 404 on subsequent get
        not_found_resp = self.client.get(f"/api/v1/admin/foods/{food_id}", headers=self.admin_headers)
        self.assertEqual(not_found_resp.status_code, 404)

    def test_food_endpoints_reject_non_admin(self):
        """Standard user is rejected with 403 Forbidden."""
        resp1 = self.client.get("/api/v1/admin/foods", headers=self.user_headers)
        self.assertEqual(resp1.status_code, 403)

        resp2 = self.client.post("/api/v1/admin/foods", json={"name": "Test"}, headers=self.user_headers)
        self.assertEqual(resp2.status_code, 403)

    def test_food_endpoints_reject_unauthenticated(self):
        """Unauthenticated call returns 401 Unauthorized."""
        resp = self.client.get("/api/v1/admin/foods")
        self.assertEqual(resp.status_code, 401)


if __name__ == "__main__":
    unittest.main()
