"""
Unit Tests for Role-Based Access Control (RBAC) & Audit Logging (Module 19: Security & Validation).
Tests admin elevation prevention, guest 401 barriers, admin 200 access, and audit trail capture.
"""

import unittest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from app.main import app
from app.core.security import create_access_token
from app.core.rate_limiter import rate_limiter
from app.services.audit_service import AuditService
from app.models.user import User


class TestRbacAccessControl(unittest.TestCase):
    """Test suite verifying RBAC guards and security audit logging."""

    def setUp(self):
        self.client = TestClient(app, raise_server_exceptions=False)
        rate_limiter.reset()
        AuditService.clear_logs()

        self.standard_user = User(
            id=101,
            email="standard.user@packaging.com",
            full_name="Standard User",
            is_active=True,
            is_admin=False,
            role="user",
        )

        self.admin_user = User(
            id=1,
            email="admin@packaging.com",
            full_name="Platform Admin",
            is_active=True,
            is_admin=True,
            role="admin",
        )

    def test_guest_access_to_protected_endpoint_rejected_with_401(self):
        # No Authorization header
        resp = self.client.get("/api/v1/admin/analytics/summary")
        self.assertEqual(resp.status_code, 401)
        data = resp.json()
        self.assertEqual(data["error"]["code"], "UNAUTHORIZED")

    @patch("app.services.auth_service.AuthService.get_user_by_id")
    def test_standard_user_access_to_admin_endpoint_forbidden_with_403(self, mock_get_user):
        mock_get_user.return_value = self.standard_user
        token = create_access_token(subject=self.standard_user.id, role="user")

        headers = {"Authorization": f"Bearer {token}"}
        resp = self.client.get("/api/v1/admin/analytics/summary", headers=headers)
        self.assertEqual(resp.status_code, 403)
        data = resp.json()
        self.assertEqual(data["error"]["code"], "FORBIDDEN")
        self.assertIn("Admin privileges required", data["error"]["message"])

        # Verify audit log was recorded for elevation attempt
        logs, total = AuditService.get_audit_logs(action_filter="UNAUTHORIZED_ADMIN_ELEVATION_ATTEMPT")
        self.assertGreaterEqual(total, 1)
        self.assertEqual(logs[0].user_id, self.standard_user.id)
        self.assertEqual(logs[0].status, "WARNING")

    @patch("app.services.auth_service.AuthService.get_user_by_id")
    @patch("app.services.admin_service.AdminService.get_analytics_summary", new_callable=AsyncMock)
    def test_admin_user_access_to_admin_endpoint_succeeds(self, mock_get_summary, mock_get_user):
        from app.schemas.admin import AdminAnalyticsSummary
        mock_get_user.return_value = self.admin_user
        mock_get_summary.return_value = AdminAnalyticsSummary(
            total_analyses=1245,
            total_users=10,
            total_foods_count=42,
            total_materials_count=18,
            eco_preference_pct=45.2,
            average_system_score=88.5,
            top_foods=[],
            top_materials=[],
            trends=[],
        )
        token = create_access_token(subject=self.admin_user.id, role="admin")

        headers = {"Authorization": f"Bearer {token}"}
        resp = self.client.get("/api/v1/admin/analytics/summary", headers=headers)
        self.assertEqual(resp.status_code, 200)

    def test_audit_service_logging_and_filtering(self):
        AuditService.log_event(action="AUTH_LOGIN", status="SUCCESS", user_id=101)
        AuditService.log_event(action="ADMIN_DELETE_FOOD", status="WARNING", user_id=1, details={"food_id": 5})
        AuditService.log_event(action="AUTH_FAILED", status="FAILURE", ip_address="192.168.1.99")

        # Total count
        all_logs, total = AuditService.get_audit_logs()
        self.assertEqual(total, 3)
        self.assertEqual(len(all_logs), 3)

        # Filter by action
        auth_logs, auth_total = AuditService.get_audit_logs(action_filter="AUTH")
        self.assertEqual(auth_total, 2)

        # Filter by status
        failure_logs, fail_total = AuditService.get_audit_logs(status_filter="FAILURE")
        self.assertEqual(fail_total, 1)
        self.assertEqual(failure_logs[0].ip_address, "192.168.1.99")


if __name__ == "__main__":
    unittest.main()
