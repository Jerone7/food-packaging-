"""
Unit Tests for Security & Validation Pydantic Schemas (Module 19: Security & Validation).
Tests strict bounds, extra-field prohibition, serialization, and deserialization across security contracts.
"""

import unittest
from datetime import datetime, timezone
from pydantic import ValidationError

from app.schemas.security import (
    ApiErrorDetail,
    ApiErrorEnvelope,
    SecurityHealthResponse,
    PasswordChangeRequest,
    SecurityAuditLogItem,
    BackupMetadata,
    BackupListResponse,
)


class TestSecuritySchemas(unittest.TestCase):
    """Test suite verifying strict validation and serialization for security data contracts."""

    def test_api_error_detail_valid(self):
        detail = ApiErrorDetail(
            code="UNAUTHORIZED",
            message="Invalid credentials provided.",
            status_code=401,
            request_id="req_12345",
            details=[{"field": "password", "issue": "incorrect"}],
        )
        self.assertEqual(detail.code, "UNAUTHORIZED")
        self.assertEqual(detail.status_code, 401)
        self.assertIsNotNone(detail.timestamp)
        self.assertEqual(len(detail.details), 1)

    def test_api_error_envelope_serialization(self):
        envelope = ApiErrorEnvelope(
            error=ApiErrorDetail(
                code="NOT_FOUND",
                message="Food item not found.",
                status_code=404,
            )
        )
        data = envelope.model_dump()
        self.assertIn("error", data)
        self.assertEqual(data["error"]["code"], "NOT_FOUND")
        self.assertEqual(data["error"]["status_code"], 404)

    def test_api_error_detail_extra_field_forbidden(self):
        with self.assertRaises(ValidationError):
            ApiErrorDetail(
                code="ERR",
                message="Error",
                status_code=500,
                injected_field="malicious_payload",  # Should trigger ValidationError due to extra="forbid"
            )

    def test_security_health_response_defaults(self):
        health = SecurityHealthResponse(cors_origins_configured=2)
        self.assertEqual(health.status, "SECURE")
        self.assertEqual(health.jwt_algorithm, "HS256")
        self.assertEqual(health.password_hashing, "PBKDF2-HMAC-SHA256")
        self.assertEqual(health.pbkdf2_iterations, 100000)
        self.assertTrue(health.rate_limiting_active)
        self.assertEqual(health.cors_origins_configured, 2)

    def test_password_change_request_validation(self):
        req = PasswordChangeRequest(
            current_password="OldPassword123!",
            new_password="NewSecurePassword456!",
        )
        self.assertEqual(req.current_password, "OldPassword123!")
        self.assertEqual(req.new_password, "NewSecurePassword456!")

        # Rejects password shorter than 8 chars
        with self.assertRaises(ValidationError):
            PasswordChangeRequest(
                current_password="OldPassword123!",
                new_password="short",
            )

    def test_security_audit_log_item(self):
        log = SecurityAuditLogItem(
            id="evt_9876",
            action="ADMIN_FOOD_CREATE",
            user_id=1,
            ip_address="127.0.0.1",
            status="SUCCESS",
            details={"food_id": 43, "food_name": "Dragonfruit"},
        )
        self.assertEqual(log.id, "evt_9876")
        self.assertEqual(log.action, "ADMIN_FOOD_CREATE")
        self.assertEqual(log.status, "SUCCESS")
        self.assertEqual(log.details["food_name"], "Dragonfruit")

    def test_backup_metadata_checksum_validation(self):
        valid_checksum = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"  # 64-char hex
        metadata = BackupMetadata(
            backup_id="backup_20260927_120000",
            total_foods=42,
            total_materials=18,
            total_users=5,
            total_recommendations=1245,
            file_size_bytes=1048576,
            checksum_sha256=valid_checksum,
        )
        self.assertEqual(metadata.backup_id, "backup_20260927_120000")
        self.assertEqual(metadata.total_foods, 42)
        self.assertEqual(metadata.file_size_bytes, 1048576)

        # Rejects invalid checksum length
        with self.assertRaises(ValidationError):
            BackupMetadata(
                backup_id="backup_invalid",
                total_foods=42,
                total_materials=18,
                total_users=5,
                total_recommendations=1245,
                file_size_bytes=1048576,
                checksum_sha256="invalid_short_hash",
            )

    def test_backup_list_response(self):
        valid_checksum = "a" * 64
        resp = BackupListResponse(
            total_backups=1,
            backups=[
                BackupMetadata(
                    backup_id="backup_001",
                    total_foods=10,
                    total_materials=5,
                    total_users=2,
                    total_recommendations=20,
                    file_size_bytes=51200,
                    checksum_sha256=valid_checksum,
                )
            ],
        )
        self.assertEqual(resp.total_backups, 1)
        self.assertEqual(len(resp.backups), 1)


if __name__ == "__main__":
    unittest.main()
