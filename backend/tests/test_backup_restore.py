"""
Unit Tests for Database Snapshot Backup & Restore Service (Module 19: Security & Validation).
Tests cryptographic snapshot generation, SHA-256 verification, rolling pruning, and restore execution.
"""

import os
import shutil
import tempfile
import unittest

from app.services.backup_service import BackupService
from app.services.audit_service import AuditService


class TestBackupRestoreService(unittest.IsolatedAsyncioTestCase):
    """Test suite verifying automated database backups, verification, and recovery."""

    def setUp(self):
        self.test_dir = tempfile.mkdtemp(prefix="smartpack_test_backups_")
        AuditService.clear_logs()

    def tearDown(self):
        if os.path.exists(self.test_dir):
            shutil.rmtree(self.test_dir, ignore_errors=True)

    async def test_create_and_verify_backup(self):
        # 1. Create a snapshot in the temporary directory
        meta = await BackupService.create_backup(backup_dir=self.test_dir, user_id=1)
        self.assertIsNotNone(meta.backup_id)
        self.assertEqual(len(meta.checksum_sha256), 64)
        self.assertGreater(meta.total_foods, 0)
        self.assertGreater(meta.total_materials, 0)
        self.assertGreater(meta.file_size_bytes, 0)

        snapshot_file = os.path.join(self.test_dir, f"{meta.backup_id}.json")
        self.assertTrue(os.path.exists(snapshot_file))

        # 2. Verify snapshot integrity
        is_valid, msg, verified_meta = BackupService.verify_backup(snapshot_file)
        self.assertTrue(is_valid)
        self.assertIsNotNone(verified_meta)
        self.assertEqual(verified_meta.backup_id, meta.backup_id)
        self.assertEqual(verified_meta.checksum_sha256, meta.checksum_sha256)

        # 3. List backups
        backups = BackupService.list_backups(backup_dir=self.test_dir)
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].backup_id, meta.backup_id)

    async def test_restore_backup_success(self):
        meta = await BackupService.create_backup(backup_dir=self.test_dir, user_id=1)
        snapshot_file = os.path.join(self.test_dir, f"{meta.backup_id}.json")

        success, msg, counts = await BackupService.restore_backup(snapshot_file, user_id=1)
        self.assertTrue(success)
        self.assertIn("Successfully restored", msg)
        self.assertIn("foods_restored", counts)
        self.assertGreater(counts["foods_restored"], 0)

    async def test_verify_and_restore_corrupted_backup_rejected(self):
        meta = await BackupService.create_backup(backup_dir=self.test_dir, user_id=1)
        snapshot_file = os.path.join(self.test_dir, f"{meta.backup_id}.json")

        # Corrupt file content
        with open(snapshot_file, "w") as f:
            f.write('{"invalid_json": true')

        is_valid, msg, _ = BackupService.verify_backup(snapshot_file)
        self.assertFalse(is_valid)

        success, restore_msg, _ = await BackupService.restore_backup(snapshot_file, user_id=1)
        self.assertFalse(success)
        self.assertIn("Restore aborted", restore_msg)

    async def test_rolling_retention_pruning(self):
        # Create 12 backups
        for _ in range(12):
            await BackupService.create_backup(backup_dir=self.test_dir)

        # Verify only the 10 most recent exist
        files = [f for f in os.listdir(self.test_dir) if f.startswith("backup_") and f.endswith(".json")]
        self.assertEqual(len(files), 10)

        backups = BackupService.list_backups(backup_dir=self.test_dir)
        self.assertEqual(len(backups), 10)


if __name__ == "__main__":
    unittest.main()
