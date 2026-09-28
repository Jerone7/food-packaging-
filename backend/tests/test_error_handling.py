"""
Unit Tests for Global Exception Handling & Error Sanitization (Module 19: Security & Validation).
Verifies uniform ApiErrorEnvelope format, field-specific validation errors, and stack trace redaction on 500 errors.
"""

import unittest
from fastapi.testclient import TestClient
from app.main import app
from app.core.rate_limiter import rate_limiter


class TestErrorHandling(unittest.TestCase):
    """Test suite verifying standardized API error envelopes and information disclosure prevention."""

    def setUp(self):
        self.client = TestClient(app, raise_server_exceptions=False)
        rate_limiter.reset()

    def test_404_not_found_standardized_envelope(self):
        resp = self.client.get("/api/v1/non_existent_route_12345")
        self.assertEqual(resp.status_code, 404)
        data = resp.json()

        self.assertIn("error", data)
        self.assertEqual(data["error"]["code"], "NOT_FOUND")
        self.assertEqual(data["error"]["status_code"], 404)
        self.assertIsNotNone(data["error"]["timestamp"])

    def test_422_validation_error_standardized_envelope(self):
        # Send malformed payload to /auth/signup (missing password & invalid email)
        bad_payload = {
            "email": "not-an-email",
            "full_name": "Test User",
        }
        resp = self.client.post("/api/v1/auth/signup", json=bad_payload)
        self.assertEqual(resp.status_code, 422)
        data = resp.json()

        self.assertIn("error", data)
        self.assertEqual(data["error"]["code"], "VALIDATION_ERROR")
        self.assertEqual(data["error"]["status_code"], 422)
        self.assertIsInstance(data["error"]["details"], list)
        self.assertTrue(len(data["error"]["details"]) > 0)

    def test_401_unauthorized_error_envelope(self):
        # Access protected user profile without token
        resp = self.client.get("/api/v1/users/me")
        self.assertEqual(resp.status_code, 401)
        data = resp.json()

        self.assertIn("error", data)
        self.assertEqual(data["error"]["code"], "UNAUTHORIZED")
        self.assertEqual(data["error"]["status_code"], 401)

    def test_500_unhandled_exception_redacts_stack_trace(self):
        # Temporarily register a dummy route that raises an unhandled ZeroDivisionError
        @app.get("/api/v1/test-simulated-fault")
        async def simulated_fault():
            return 1 / 0

        try:
            resp = self.client.get("/api/v1/test-simulated-fault")
            self.assertEqual(resp.status_code, 500)
            data = resp.json()

            self.assertIn("error", data)
            self.assertEqual(data["error"]["code"], "INTERNAL_SERVER_ERROR")
            self.assertEqual(data["error"]["status_code"], 500)
            self.assertIsNotNone(data["error"]["request_id"])
            self.assertTrue(data["error"]["request_id"].startswith("err_"))

            # Critical assertion: Verify zero internal Python traceback strings are leaked
            body_text = resp.text
            self.assertNotIn("ZeroDivisionError", body_text)
            self.assertNotIn("Traceback", body_text)
            self.assertNotIn("File \"", body_text)
        finally:
            # Clean up temporary test route
            app.routes[:] = [r for r in app.routes if getattr(r, "path", None) != "/api/v1/test-simulated-fault"]


if __name__ == "__main__":
    unittest.main()
