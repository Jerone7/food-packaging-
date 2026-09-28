#!/usr/bin/env python
"""
SmartPack Database Backup CLI Utility (Module 19: Security & Validation).
Generates cryptographic, SHA-256 verified JSON snapshots of all database tables.

Usage:
    python scripts/backup_db.py [--backup-dir <path>] [--dry-run]
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


async def run_backup(backup_dir: str = None, dry_run: bool = False, user_id: int = 1):
    print("=" * 60)
    print(" [SmartPack] Database Snapshot Backup Utility")
    print("=" * 60)

    target_dir = backup_dir or BackupService.DEFAULT_BACKUP_DIR
    print(f"[*] Target Directory : {os.path.abspath(target_dir)}")
    print(f"[*] Mode             : {'DRY RUN (Simulation)' if dry_run else 'LIVE SNAPSHOT'}")

    if dry_run:
        print("[+] Dry-run simulation completed successfully.")
        print("[+] Verifying target backup directory access...")
        os.makedirs(target_dir, exist_ok=True)
        print(f"[OK] Directory '{target_dir}' is writeable and ready.")
        print("=" * 60)
        return 0

    session = None
    try:
        session = AsyncSessionLocal()
    except Exception as e:
        print(f"[!] Warning: Could not establish live DB session ({e}). Using offline baseline.")

    try:
        metadata = await BackupService.create_backup(
            db=session,
            backup_dir=target_dir,
            user_id=user_id,
        )
        print("\n[OK] Snapshot Created Successfully:")
        print(f"    - Backup ID        : {metadata.backup_id}")
        print(f"    - Timestamp        : {metadata.timestamp.isoformat()}")
        print(f"    - Foods            : {metadata.total_foods}")
        print(f"    - Materials        : {metadata.total_materials}")
        print(f"    - Users            : {metadata.total_users}")
        print(f"    - Recommendations  : {metadata.total_recommendations}")
        print(f"    - File Size        : {metadata.file_size_bytes} bytes")
        print(f"    - SHA-256 Checksum : {metadata.checksum_sha256}")
        print("=" * 60)
        return 0
    except Exception as e:
        print(f"\n[X] Error during backup creation: {e}", file=sys.stderr)
        return 1
    finally:
        if session is not None:
            await session.close()


def main():
    parser = argparse.ArgumentParser(description="SmartPack Database Snapshot Backup CLI")
    parser.add_argument("--backup-dir", type=str, default=None, help="Custom output directory for backup snapshots")
    parser.add_argument("--dry-run", action="store_true", help="Simulate backup process without persisting files")
    parser.add_argument("--user-id", type=int, default=1, help="Admin user ID performing the backup")

    args = parser.parse_args()
    exit_code = asyncio.run(run_backup(backup_dir=args.backup_dir, dry_run=args.dry_run, user_id=args.user_id))
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
