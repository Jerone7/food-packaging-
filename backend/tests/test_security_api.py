"""
Unit & Integration Tests for Security REST Endpoints (Module 19: Security & Validation).
Tests /api/v1/security/health and /api/v1/security/admin/audit-logs with RBAC permissions.
"""

import unittest
from unittest.mock import patch
from fastapi.testclient import TestClient

from app.main import app
from app.core.security import create_access_token
from app.core.rate_limiter import rate_limiter
from app.services.audit_service import AuditService
from app.models.user import User


class TestSecurityApi(unittest.TestCase):
    """Test suite verifying /api/v1/security endpoints."""

    def setUp(self):
        self.client = TestClient(app, raise_server_exceptions=False)
        rate_limiter.reset()
        AuditService.clear_logs()

        self.standard_user = User(
            id=202,
            email="user@example.com",
            full_name="Standard User",
            is_active=True,
            is_admin=False,
            role="user",
        )

        self.admin_user = User(
            id=1,
            email="admin@example.com",
            full_name="Admin User",
            is_active=True,
            is_admin=True,
            role="admin",
        )

    def test_get_security_health_public(self):
        resp = self.client.get("/api/v1/security/health")
        self.assertEqual(resp.status_code, 200)
        data = resp.json()

        self.assertEqual(data["status"], "SECURE")
        self.assertEqual(data["jwt_algorithm"], "HS256")
        self.assertEqual(data["password_hashing"], "PBKDF2-HMAC-SHA256")
        self.assertEqual(data["pbkdf2_iterations"], 100000)
        self.assertTrue(data["rate_limiting_active"])
        self.assertGreaterEqual(data["cors_origins_configured"], 1)

    def test_audit_logs_unauthenticated_rejected(self):
        resp = self.client.get("/api/v1/security/admin/audit-logs")
        self.assertEqual(resp.status_code, 401)
        data = resp.json()
        self.assertEqual(data["error"]["code"], "UNAUTHORIZED")

    @patch("app.services.auth_service.AuthService.get_user_by_id")
    def test_audit_logs_standard_user_forbidden(self, mock_get_user):
        mock_get_user.return_value = self.standard_user
        token = create_access_token(subject=self.standard_user.id, role="user")

        headers = {"Authorization": f"Bearer {token}"}
        resp = self.client.get("/api/v1/security/admin/audit-logs", headers=headers)
        self.assertEqual(resp.status_code, 403)
        data = resp.json()
        self.assertEqual(data["error"]["code"], "FORBIDDEN")

    @patch("app.services.auth_service.AuthService.get_user_by_id")
    def test_audit_logs_admin_succeeds_with_pagination_and_filtering(self, mock_get_user):
        mock_get_user.return_value = self.admin_user
        token = create_access_token(subject=self.admin_user.id, role="admin")

        # Seed sample audit events
        AuditService.log_event(action="AUTH_LOGIN", status="SUCCESS", user_id=202)
        AuditService.log_event(action="ADMIN_CREATE_FOOD", status="SUCCESS", user_id=1, details={"name": "Avocado"})
        AuditService.log_event(action="AUTH_FAILED", status="FAILURE", ip_address="192.168.1.100")

        headers = {"Authorization": f"Bearer {token}"}

        # Query all
        resp = self.client.get("/api/v1/security/admin/audit-logs", headers=headers)
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertGreaterEqual(data["total"], 3)
        self.assertIsInstance(data["items"], list)

        # Query with action filter
        resp_filtered = self.client.get("/api/v1/security/admin/audit-logs?action=ADMIN", headers=headers)
        self.assertEqual(resp_filtered.status_code, 200)
        data_filtered = resp_filtered.json()
        self.assertGreaterEqual(data_filtered["total"], 1)
        self.assertTrue(all("ADMIN" in item["action"] for item in data_filtered["items"]))


if __name__ == "__main__":
    unittest.main()
