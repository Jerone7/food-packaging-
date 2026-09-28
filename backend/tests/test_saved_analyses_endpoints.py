"""
Integration tests for Saved Analyses Vault REST API Endpoints (Module 14: User Account - Task 3.2).
Tests listing, creating, fetching by ID, deleting, and multi-tenant isolation of saved presets.
"""

import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.db.session import get_db
from app.services.auth_service import AuthService


async def override_get_db():
    yield None


class TestSavedAnalysesEndpoints(unittest.TestCase):
    """Test suite verifying /api/v1/saved-analyses endpoints and data isolation."""

    @classmethod
    def setUpClass(cls):
        app.dependency_overrides[get_db] = override_get_db
        cls.client = TestClient(app)

    @classmethod
    def tearDownClass(cls):
        app.dependency_overrides.clear()

    def setUp(self):
        AuthService.reset_memory_store()

    def _create_user_and_token(self, email: str, name: str) -> str:
        """Helper to create a user and return access token."""
        res = self.client.post("/api/v1/auth/signup", json={
            "email": email,
            "password": "Password123!",
            "full_name": name,
        })
        self.assertEqual(res.status_code, 201)
        return res.json()["access_token"]

    def test_unauthorized_access_rejected(self):
        """Verify accessing saved analyses without Bearer token returns 401."""
        res = self.client.get("/api/v1/saved-analyses")
        self.assertEqual(res.status_code, 401)

        res_post = self.client.post("/api/v1/saved-analyses", json={
            "title": "Unauthorized Preset",
            "commodity_name": "Tomatoes",
        })
        self.assertEqual(res_post.status_code, 401)

    def test_create_and_list_saved_analyses(self):
        """Verify creating and retrieving pinned presets for a user."""
        token = self._create_user_and_token("vault_user@smartpack.io", "Vault User")
        headers = {"Authorization": f"Bearer {token}"}

        # Initial list is empty
        list_res = self.client.get("/api/v1/saved-analyses", headers=headers)
        self.assertEqual(list_res.status_code, 200)
        self.assertEqual(list_res.json(), [])

        # Create first preset
        preset_payload = {
            "title": "Organic Strawberries Cold Chain Spec",
            "notes": "Verified for 14-day transit at 4°C with active MAP.",
            "commodity_name": "Fresh Strawberries",
            "recommended_material": "PLA / Bio-based MAP Film",
            "estimated_cost": 4.25,
            "sustainability_score": 92.5,
            "input_payload": {
                "commodity": "Fresh Strawberries",
                "temperature": 4.0,
                "shelf_life_days": 14,
            },
            "recommendation_result": {
                "material_name": "PLA / Bio-based MAP Film",
                "estimated_cost": 4.25,
                "sustainability_score": 92.5,
                "barrier_score": 88.0,
            },
        }

        create_res = self.client.post(
            "/api/v1/saved-analyses", json=preset_payload, headers=headers
        )
        self.assertEqual(create_res.status_code, 201)
        created_data = create_res.json()
        preset_id = created_data["id"]

        self.assertEqual(created_data["title"], "Organic Strawberries Cold Chain Spec")
        self.assertEqual(created_data["notes"], "Verified for 14-day transit at 4°C with active MAP.")
        self.assertEqual(created_data["commodity_name"], "Fresh Strawberries")
        self.assertEqual(created_data["recommended_material"], "PLA / Bio-based MAP Film")
        self.assertEqual(created_data["estimated_cost"], 4.25)
        self.assertEqual(created_data["sustainability_score"], 92.5)
        self.assertIn("input_payload", created_data)
        self.assertIn("recommendation_result", created_data)

        # List now has 1 preset
        list_res2 = self.client.get("/api/v1/saved-analyses", headers=headers)
        self.assertEqual(list_res2.status_code, 200)
        items = list_res2.json()
        self.assertEqual(len(items), 1)
        self.assertEqual(items[0]["id"], preset_id)

    def test_get_saved_analysis_by_id(self):
        """Verify retrieving specific preset by ID."""
        token = self._create_user_and_token("fetch_user@smartpack.io", "Fetch User")
        headers = {"Authorization": f"Bearer {token}"}

        create_res = self.client.post(
            "/api/v1/saved-analyses",
            json={
                "title": "Avocado Export Carton",
                "commodity_name": "Avocados",
                "recommended_material": "Recycled Kraft Corrugated",
                "estimated_cost": 5.10,
                "sustainability_score": 89.0,
            },
            headers=headers,
        )
        preset_id = create_res.json()["id"]

        # Fetch by ID
        get_res = self.client.get(f"/api/v1/saved-analyses/{preset_id}", headers=headers)
        self.assertEqual(get_res.status_code, 200)
        self.assertEqual(get_res.json()["title"], "Avocado Export Carton")

        # Fetch nonexistent ID -> 404
        bad_get = self.client.get("/api/v1/saved-analyses/99999", headers=headers)
        self.assertEqual(bad_get.status_code, 404)

    def test_multi_tenant_isolation(self):
        """Verify User B cannot view or delete User A's saved analysis."""
        token_a = self._create_user_and_token("usera@smartpack.io", "User A")
        token_b = self._create_user_and_token("userb@smartpack.io", "User B")

        headers_a = {"Authorization": f"Bearer {token_a}"}
        headers_b = {"Authorization": f"Bearer {token_b}"}

        # User A creates a preset
        create_res = self.client.post(
            "/api/v1/saved-analyses",
            json={
                "title": "User A Proprietary Packaging Formula",
                "commodity_name": "Mangoes",
                "recommended_material": "Coated Bagasse Tray",
            },
            headers=headers_a,
        )
        preset_id = create_res.json()["id"]

        # User B lists saved analyses -> empty
        list_b = self.client.get("/api/v1/saved-analyses", headers=headers_b)
        self.assertEqual(list_b.json(), [])

        # User B attempts to fetch User A's preset -> 404
        get_b = self.client.get(f"/api/v1/saved-analyses/{preset_id}", headers=headers_b)
        self.assertEqual(get_b.status_code, 404)

        # User B attempts to delete User A's preset -> 404
        del_b = self.client.delete(f"/api/v1/saved-analyses/{preset_id}", headers=headers_b)
        self.assertEqual(del_b.status_code, 404)

        # User A can fetch own preset -> 200
        get_a = self.client.get(f"/api/v1/saved-analyses/{preset_id}", headers=headers_a)
        self.assertEqual(get_a.status_code, 200)

    def test_delete_saved_analysis(self):
        """Verify owner can successfully delete a saved preset."""
        token = self._create_user_and_token("delete_user@smartpack.io", "Delete User")
        headers = {"Authorization": f"Bearer {token}"}

        create_res = self.client.post(
            "/api/v1/saved-analyses",
            json={
                "title": "Temporary Test Preset",
                "commodity_name": "Apples",
            },
            headers=headers,
        )
        preset_id = create_res.json()["id"]

        # Delete preset
        del_res = self.client.delete(f"/api/v1/saved-analyses/{preset_id}", headers=headers)
        self.assertEqual(del_res.status_code, 200)
        self.assertEqual(del_res.json()["status"], "success")

        # Verify no longer exists
        get_res = self.client.get(f"/api/v1/saved-analyses/{preset_id}", headers=headers)
        self.assertEqual(get_res.status_code, 404)


if __name__ == "__main__":
    unittest.main()
