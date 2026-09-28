#!/usr/bin/env python
"""
SmartPack Database Restore CLI Utility (Module 19: Security & Validation).
Verifies cryptographic SHA-256 integrity and restores database snapshots.

Usage:
    python scripts/restore_db.py --file <snapshot_path> [--verify-only]
    python scripts/restore_db.py --latest [--verify-only]
"""

import argparse
import asyncio
import os
import sys

# Ensure UTF-8 output encoding on Windows if supported
if sys.stdout.encoding != "utf-8" and hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

# Ensure backend root is on sys.path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import AsyncSessionLocal
from app.services.backup_service import BackupService


async def run_restore(
    file_path: str = None,
    latest: bool = False,
    verify_only: bool = False,
    backup_dir: str = None,
    user_id: int = 1,
):
    print("=" * 60)
    print(" [SmartPack] Database Snapshot Restore & Verify Utility")
    print("=" * 60)

    target_dir = backup_dir or BackupService.DEFAULT_BACKUP_DIR

    # Resolve target file
    selected_path = file_path
    if latest or not selected_path:
        backups = BackupService.list_backups(target_dir)
        if not backups:
            print(f"[X] Error: No backup files found in '{target_dir}'.", file=sys.stderr)
            return 1
        latest_meta = backups[0]
        selected_path = os.path.join(target_dir, f"{latest_meta.backup_id}.json")
        print(f"[*] Auto-selected latest snapshot: {latest_meta.backup_id}")

    if not os.path.isabs(selected_path):
        selected_path = os.path.abspath(selected_path)

    print(f"[*] Snapshot File : {selected_path}")
    print(f"[*] Operation     : {'INTEGRITY VERIFICATION ONLY' if verify_only else 'DATABASE RESTORATION'}")

    # 1. Verify Snapshot Integrity
    is_valid, msg, metadata = BackupService.verify_backup(selected_path)
    if not is_valid or metadata is None:
        print(f"\n[X] Verification Failed: {msg}", file=sys.stderr)
        return 1

    print("\n[OK] Cryptographic Checksum Passed (SHA-256):")
    print(f"    - Backup ID        : {metadata.backup_id}")
    print(f"    - Timestamp        : {metadata.timestamp.isoformat()}")
    print(f"    - Version          : {metadata.version}")
    print(f"    - Foods            : {metadata.total_foods}")
    print(f"    - Materials        : {metadata.total_materials}")
    print(f"    - Users            : {metadata.total_users}")
    print(f"    - Recommendations  : {metadata.total_recommendations}")
    print(f"    - File Size        : {metadata.file_size_bytes} bytes")
    print(f"    - SHA-256 Checksum : {metadata.checksum_sha256}")

    if verify_only:
        print("\n[OK] Snapshot is authentic and structurally valid. No restore needed.")
        print("=" * 60)
        return 0

    # 2. Execute Restore
    session = None
    try:
        session = AsyncSessionLocal()
    except Exception as e:
        print(f"[!] Warning: Could not establish live DB session ({e}). Simulating restore.")

    try:
        success, restore_msg, counts = await BackupService.restore_backup(
            snapshot_path=selected_path,
            db=session,
            user_id=user_id,
        )
        if success:
            print("\n[OK] Restore Operation Complete:")
            for entity, count in counts.items():
                print(f"    - {entity.replace('_', ' ').title():<22}: {count}")
            print(f"\n[OK] {restore_msg}")
            print("=" * 60)
            return 0
        else:
            print(f"\n[X] Restore Failed: {restore_msg}", file=sys.stderr)
            return 1
    except Exception as e:
        print(f"\n[X] Error during restore execution: {e}", file=sys.stderr)
        return 1
    finally:
        if session is not None:
            await session.close()


def main():
    parser = argparse.ArgumentParser(description="SmartPack Database Snapshot Restore CLI")
    parser.add_argument("--file", type=str, default=None, help="Path to backup snapshot JSON file")
    parser.add_argument("--latest", action="store_true", help="Restore or verify the most recent snapshot")
    parser.add_argument("--verify-only", action="store_true", help="Only verify cryptographic checksum without modifying DB")
    parser.add_argument("--backup-dir", type=str, default=None, help="Directory to search for backups when using --latest")
    parser.add_argument("--user-id", type=int, default=1, help="Admin user ID performing the restore")

    args = parser.parse_args()
    if not args.file and not args.latest:
        parser.print_help()
        sys.exit(1)

    exit_code = asyncio.run(
        run_restore(
            file_path=args.file,
            latest=args.latest,
            verify_only=args.verify_only,
            backup_dir=args.backup_dir,
            user_id=args.user_id,
        )
    )
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
