"""
Integration tests for User Authentication & Profile REST Endpoints (Module 14: User Account).
Tests signup, login, logout, get/update profile, and user history endpoints.
"""

import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.db.session import get_db
from app.services.auth_service import AuthService


async def override_get_db():
    yield None


class TestAuthAndUserEndpoints(unittest.TestCase):
    """Test suite verifying /api/v1/auth and /api/v1/users endpoints."""

    @classmethod
    def setUpClass(cls):
        app.dependency_overrides[get_db] = override_get_db
        cls.client = TestClient(app)

    @classmethod
    def tearDownClass(cls):
        app.dependency_overrides.clear()

    def setUp(self):
        AuthService.reset_memory_store()

    def test_signup_success(self):
        """Verify successful user signup returns 201 Created and TokenResponse."""
        payload = {
            "email": "engineer@smartpack.io",
            "password": "SecurePassword123!",
            "full_name": "Dr. Sarah Jenkins",
            "organization": "BioPackaging Labs",
            "role": "Chief Packaging Engineer",
            "default_eco_priority": True,
            "default_currency": "EUR",
        }
        response = self.client.post("/api/v1/auth/signup", json=payload)
        self.assertEqual(response.status_code, 201)

        data = response.json()
        self.assertIn("access_token", data)
        self.assertEqual(data["token_type"], "bearer")
        self.assertGreater(data["expires_in_seconds"], 0)

        user = data["user"]
        self.assertEqual(user["email"], "engineer@smartpack.io")
        self.assertEqual(user["full_name"], "Dr. Sarah Jenkins")
        self.assertEqual(user["organization"], "BioPackaging Labs")
        self.assertEqual(user["role"], "Chief Packaging Engineer")
        self.assertTrue(user["is_active"])
        self.assertEqual(user["preferences"]["default_currency"], "EUR")
        self.assertTrue(user["preferences"]["default_eco_priority"])
        self.assertIsNotNone(user["stats"])

    def test_signup_duplicate_email_fails(self):
        """Verify duplicate signup with identical email returns 400 Bad Request."""
        payload = {
            "email": "duplicate@smartpack.io",
            "password": "Password123!",
            "full_name": "First User",
        }
        res1 = self.client.post("/api/v1/auth/signup", json=payload)
        self.assertEqual(res1.status_code, 201)

        # Attempt duplicate registration
        res2 = self.client.post("/api/v1/auth/signup", json=payload)
        self.assertEqual(res2.status_code, 400)
        self.assertIn("already exists", res2.json()["detail"])

    def test_signup_invalid_inputs_validation(self):
        """Verify Pydantic schema rejection on invalid email format and short passwords."""
        # Short password (<6 chars)
        res1 = self.client.post("/api/v1/auth/signup", json={
            "email": "valid@email.com",
            "password": "123",
            "full_name": "Test User"
        })
        self.assertEqual(res1.status_code, 422)

        # Invalid email
        res2 = self.client.post("/api/v1/auth/signup", json={
            "email": "not-an-email",
            "password": "ValidPassword123!",
            "full_name": "Test User"
        })
        self.assertEqual(res2.status_code, 422)

    def test_login_success_and_invalid_credentials(self):
        """Verify login returns token on valid credentials and 401 on invalid passwords."""
        # Register user
        self.client.post("/api/v1/auth/signup", json={
            "email": "login_test@smartpack.io",
            "password": "CorrectPassword123!",
            "full_name": "Alex Mercer",
        })

        # Correct login
        login_res = self.client.post("/api/v1/auth/login", json={
            "email": "login_test@smartpack.io",
            "password": "CorrectPassword123!",
        })
        self.assertEqual(login_res.status_code, 200)
        token_data = login_res.json()
        self.assertIn("access_token", token_data)
        self.assertEqual(token_data["user"]["email"], "login_test@smartpack.io")

        # Wrong password
        wrong_pw_res = self.client.post("/api/v1/auth/login", json={
            "email": "login_test@smartpack.io",
            "password": "WrongPassword999!",
        })
        self.assertEqual(wrong_pw_res.status_code, 401)

        # Nonexistent email
        unknown_email_res = self.client.post("/api/v1/auth/login", json={
            "email": "ghost@smartpack.io",
            "password": "CorrectPassword123!",
        })
        self.assertEqual(unknown_email_res.status_code, 401)

    def test_logout_endpoint(self):
        """Verify logout endpoint returns success status."""
        response = self.client.post("/api/v1/auth/logout")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "success")

    def test_get_current_user_profile(self):
        """Verify GET /api/v1/users/me with Bearer token header."""
        # Signup
        signup_res = self.client.post("/api/v1/auth/signup", json={
            "email": "me_test@smartpack.io",
            "password": "Password123!",
            "full_name": "Morgan Vance",
        })
        token = signup_res.json()["access_token"]

        # Call /users/me without token -> 401
        unauth_res = self.client.get("/api/v1/users/me")
        self.assertEqual(unauth_res.status_code, 401)

        # Call /users/me with invalid token -> 401
        invalid_res = self.client.get(
            "/api/v1/users/me",
            headers={"Authorization": "Bearer invalid.token.payload"}
        )
        self.assertEqual(invalid_res.status_code, 401)

        # Call /users/me with valid Bearer token -> 200
        auth_res = self.client.get(
            "/api/v1/users/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        self.assertEqual(auth_res.status_code, 200)
        user_data = auth_res.json()
        self.assertEqual(user_data["email"], "me_test@smartpack.io")
        self.assertEqual(user_data["full_name"], "Morgan Vance")
        self.assertIn("stats", user_data)
        self.assertIn("preferences", user_data)

    def test_update_user_profile(self):
        """Verify PUT /api/v1/users/me updates name, role, and engineering preferences."""
        signup_res = self.client.post("/api/v1/auth/signup", json={
            "email": "update_me@smartpack.io",
            "password": "Password123!",
            "full_name": "Initial Name",
        })
        token = signup_res.json()["access_token"]

        update_payload = {
            "full_name": "Updated Name, PhD",
            "organization": "Global Packaging Alliance",
            "role": "Principal Sustainability Scientist",
            "default_eco_priority": False,
            "default_currency": "USD",
            "default_batch_size": 50000,
        }

        put_res = self.client.put(
            "/api/v1/users/me",
            json=update_payload,
            headers={"Authorization": f"Bearer {token}"}
        )
        self.assertEqual(put_res.status_code, 200)
        updated_data = put_res.json()

        self.assertEqual(updated_data["full_name"], "Updated Name, PhD")
        self.assertEqual(updated_data["organization"], "Global Packaging Alliance")
        self.assertEqual(updated_data["role"], "Principal Sustainability Scientist")
        self.assertEqual(updated_data["preferences"]["default_currency"], "USD")
        self.assertFalse(updated_data["preferences"]["default_eco_priority"])
        self.assertEqual(updated_data["preferences"]["default_batch_size"], 50000)

    def test_user_history_endpoint(self):
        """Verify GET /api/v1/users/me/history returns historical list."""
        signup_res = self.client.post("/api/v1/auth/signup", json={
            "email": "history_test@smartpack.io",
            "password": "Password123!",
            "full_name": "History Inspector",
        })
        token = signup_res.json()["access_token"]

        history_res = self.client.get(
            "/api/v1/users/me/history",
            headers={"Authorization": f"Bearer {token}"}
        )
        self.assertEqual(history_res.status_code, 200)
        self.assertIsInstance(history_res.json(), list)


if __name__ == "__main__":
    unittest.main()
