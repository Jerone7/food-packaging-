"""
Unit & Integration Tests for Packaging Material Management Admin Endpoints (Module 15 - Task 2.3).
Validates full CRUD lifecycle, status toggle, and RBAC authentication.
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


class TestAdminMaterialCrudApi(unittest.TestCase):
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

    def test_list_admin_materials(self):
        """Admin successfully retrieves materials list with filters."""
        response = self.client.get("/api/v1/admin/materials?polymer_family=BREATHABLE_BIO_EMAP", headers=self.admin_headers)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("total_count", data)
        self.assertIn("items", data)
        self.assertIsInstance(data["items"], list)

    def test_full_material_crud_and_toggle_lifecycle(self):
        """Validates create, get, update, toggle active status, and delete."""
        # 1. Create
        create_payload = {
            "material_id": "mat_pha_nanocomposite_01",
            "name": "High-Barrier PHA Nanocomposite Bio-Film",
            "category": "Biodegradable Bio-Polymer",
            "polymer_family": "BREATHABLE_BIO_EMAP",
            "structure": "Monolayer 35 µm",
            "form_factor": "Flexible Pouch",
            "thickness_microns": 35.0,
            "otr_cc_m2_day": 1800.0,
            "wvtr_g_m2_day": 25.0,
            "co2_permeability": 7200.0,
            "selectivity_beta": 4.0,
            "tensile_strength_mpa": 36.0,
            "puncture_resistance_n": 19.5,
            "sustainability_score": 98.0,
            "recyclability_score": 75.0,
            "biodegradability_score": 100.0,
            "estimated_unit_cost_inr": 4.85,
            "is_breathable": True,
            "is_biodegradable": True,
            "is_active_entry": True,
        }
        create_resp = self.client.post("/api/v1/admin/materials", json=create_payload, headers=self.admin_headers)
        self.assertEqual(create_resp.status_code, 201)
        created_mat = create_resp.json()
        mat_id = created_mat["id"]
        self.assertEqual(created_mat["material_id"], "mat_pha_nanocomposite_01")
        self.assertTrue(created_mat["is_active_entry"])

        # 2. Get Single Material
        get_resp = self.client.get(f"/api/v1/admin/materials/{mat_id}", headers=self.admin_headers)
        self.assertEqual(get_resp.status_code, 200)
        self.assertEqual(get_resp.json()["id"], mat_id)

        # 3. Update Material
        update_payload = {
            "thickness_microns": 40.0,
            "estimated_unit_cost_inr": 5.10,
        }
        update_resp = self.client.put(f"/api/v1/admin/materials/{mat_id}", json=update_payload, headers=self.admin_headers)
        self.assertEqual(update_resp.status_code, 200)
        self.assertEqual(update_resp.json()["thickness_microns"], 40.0)
        self.assertEqual(update_resp.json()["estimated_unit_cost_inr"], 5.10)

        # 4. Toggle Status (Active -> Inactive)
        toggle_resp = self.client.patch(f"/api/v1/admin/materials/{mat_id}/toggle-status", headers=self.admin_headers)
        self.assertEqual(toggle_resp.status_code, 200)
        self.assertFalse(toggle_resp.json()["is_active_entry"])

        # Toggle back (Inactive -> Active)
        toggle_resp_2 = self.client.patch(f"/api/v1/admin/materials/{mat_id}/toggle-status", headers=self.admin_headers)
        self.assertEqual(toggle_resp_2.status_code, 200)
        self.assertTrue(toggle_resp_2.json()["is_active_entry"])

        # 5. Delete Material
        del_resp = self.client.delete(f"/api/v1/admin/materials/{mat_id}", headers=self.admin_headers)
        self.assertEqual(del_resp.status_code, 204)

        # 6. Verify 404 after deletion
        not_found_resp = self.client.get(f"/api/v1/admin/materials/{mat_id}", headers=self.admin_headers)
        self.assertEqual(not_found_resp.status_code, 404)

    def test_materials_endpoints_reject_non_admin(self):
        """Standard user is rejected with 403 Forbidden."""
        resp1 = self.client.get("/api/v1/admin/materials", headers=self.user_headers)
        self.assertEqual(resp1.status_code, 403)

        resp2 = self.client.post("/api/v1/admin/materials", json={"name": "Test"}, headers=self.user_headers)
        self.assertEqual(resp2.status_code, 403)

    def test_materials_endpoints_reject_unauthenticated(self):
        """Unauthenticated request returns 401 Unauthorized."""
        resp = self.client.get("/api/v1/admin/materials")
        self.assertEqual(resp.status_code, 401)


if __name__ == "__main__":
    unittest.main()
