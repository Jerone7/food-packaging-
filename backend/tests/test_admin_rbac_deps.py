"""
Unit Tests for Admin RBAC Security Dependency (Module 15 - Task 1.1).
Validates get_current_admin_user role checks and HTTP exception triggers.
"""

import unittest
import asyncio
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials
from app.api.deps import get_current_user, get_current_admin_user
from app.models.user import User
from app.services.auth_service import AuthService
from app.core.security import create_access_token


class TestAdminRbacDependencies(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        AuthService.reset_memory_store()

        # Create standard user (non-admin)
        self.standard_user = User(
            id=101,
            email="user@example.com",
            hashed_password="hashed_pwd",
            full_name="Standard Engineer",
            is_active=True,
            is_admin=False,
        )
        AuthService._memory_users[101] = self.standard_user
        AuthService._memory_users_by_email["user@example.com"] = self.standard_user

        # Create admin user
        self.admin_user = User(
            id=999,
            email="admin@example.com",
            hashed_password="hashed_pwd",
            full_name="Admin Officer",
            is_active=True,
            is_admin=True,
        )
        AuthService._memory_users[999] = self.admin_user
        AuthService._memory_users_by_email["admin@example.com"] = self.admin_user

        # Create deactivated admin user
        self.deactivated_admin = User(
            id=888,
            email="inactive_admin@example.com",
            hashed_password="hashed_pwd",
            full_name="Deactivated Admin",
            is_active=False,
            is_admin=True,
        )
        AuthService._memory_users[888] = self.deactivated_admin
        AuthService._memory_users_by_email["inactive_admin@example.com"] = self.deactivated_admin

    async def test_admin_user_passes_verification(self):
        """Admin user with is_admin=True successfully passes get_current_admin_user."""
        result = await get_current_admin_user(current_user=self.admin_user)
        self.assertEqual(result.id, 999)
        self.assertEqual(result.email, "admin@example.com")
        self.assertTrue(result.is_admin)

    async def test_non_admin_user_raises_403(self):
        """Standard user with is_admin=False raises 403 Forbidden with descriptive detail."""
        with self.assertRaises(HTTPException) as ctx:
            await get_current_admin_user(current_user=self.standard_user)
        
        self.assertEqual(ctx.exception.status_code, 403)
        self.assertIn("Admin privileges required", ctx.exception.detail)

    async def test_e2e_jwt_token_admin_resolution(self):
        """End-to-end resolution from JWT Bearer token to get_current_admin_user."""
        admin_token = create_access_token(subject=999, role="admin")
        creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials=admin_token)

        resolved_user = await get_current_user(credentials=creds, db=None)
        self.assertEqual(resolved_user.id, 999)
        
        admin_guard_result = await get_current_admin_user(current_user=resolved_user)
        self.assertEqual(admin_guard_result.id, 999)
        self.assertTrue(admin_guard_result.is_admin)

    async def test_e2e_jwt_token_non_admin_rejection(self):
        """End-to-end resolution from JWT token for standard user gets rejected by admin guard."""
        user_token = create_access_token(subject=101, role="user")
        creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials=user_token)

        resolved_user = await get_current_user(credentials=creds, db=None)
        self.assertEqual(resolved_user.id, 101)

        with self.assertRaises(HTTPException) as ctx:
            await get_current_admin_user(current_user=resolved_user)

        self.assertEqual(ctx.exception.status_code, 403)

    async def test_deactivated_admin_rejected_at_auth_layer(self):
        """Deactivated admin user is rejected at get_current_user with 403 before reaching admin check."""
        token = create_access_token(subject=888, role="admin")
        creds = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)

        with self.assertRaises(HTTPException) as ctx:
            await get_current_user(credentials=creds, db=None)

        self.assertEqual(ctx.exception.status_code, 403)
        self.assertIn("deactivated", ctx.exception.detail)


if __name__ == "__main__":
    unittest.main()
