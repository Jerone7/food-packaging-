"""
Unit Tests for Authentication & User Data Service Logic (Module 14 - Task 2.2).
"""

import asyncio
import unittest
from app.services.auth_service import AuthService
from app.schemas.user import UserCreate, UserUpdate, SavedAnalysisCreate
from app.core.security import decode_access_token

class TestAuthService(unittest.TestCase):
    def setUp(self):
        AuthService.reset_memory_store()

    def test_user_registration_and_duplicate_prevention(self):
        async def run_test():
            user_data = UserCreate(
                email="scientist@packtech.io",
                password="SecurePassword123!",
                full_name="Dr. Elena Vance",
                organization="PackTech Innovations",
                role="Senior Packaging Scientist",
                default_eco_priority=True,
                default_currency="INR",
            )
            user = await AuthService.create_user(None, user_data)
            self.assertIsNotNone(user)
            self.assertEqual(user.email, "scientist@packtech.io")
            self.assertEqual(user.full_name, "Dr. Elena Vance")
            self.assertEqual(user.preferences_json["default_currency"], "INR")

            # Duplicate registration attempt should raise ValueError
            with self.assertRaises(ValueError):
                await AuthService.create_user(None, user_data)

        asyncio.run(run_test())

    def test_user_authentication(self):
        async def run_test():
            user_data = UserCreate(
                email="lead@converter.com",
                password="Password2026!",
                full_name="Mark Sloan",
            )
            await AuthService.create_user(None, user_data)

            # Valid login
            authenticated = await AuthService.authenticate_user(None, "lead@converter.com", "Password2026!")
            self.assertIsNotNone(authenticated)
            self.assertEqual(authenticated.email, "lead@converter.com")

            # Invalid password
            failed_pw = await AuthService.authenticate_user(None, "lead@converter.com", "WrongPassword!")
            self.assertIsNone(failed_pw)

            # Non-existent user
            non_existent = await AuthService.authenticate_user(None, "ghost@converter.com", "Password2026!")
            self.assertIsNone(non_existent)

        asyncio.run(run_test())

    def test_issue_token_response(self):
        async def run_test():
            user_data = UserCreate(
                email="analyst@foodlabs.org",
                password="Password123!",
                full_name="Ananya Sharma",
                organization="FoodLabs India",
            )
            user = await AuthService.create_user(None, user_data)
            token_resp = await AuthService.issue_token_response(None, user)

            self.assertIsNotNone(token_resp.access_token)
            self.assertEqual(token_resp.token_type, "bearer")
            self.assertEqual(token_resp.user.email, "analyst@foodlabs.org")
            self.assertEqual(token_resp.user.organization, "FoodLabs India")

            # Validate JWT
            payload = decode_access_token(token_resp.access_token)
            self.assertIsNotNone(payload)
            self.assertEqual(payload["sub"], str(user.id))
            self.assertEqual(payload["email"], "analyst@foodlabs.org")

        asyncio.run(run_test())

    def test_update_profile_and_preferences(self):
        async def run_test():
            user_data = UserCreate(
                email="designer@pack.com",
                password="Password123!",
                full_name="Original Name",
                organization="Old Org",
            )
            user = await AuthService.create_user(None, user_data)

            update_data = UserUpdate(
                full_name="Updated Name",
                organization="New Bio Packaging Co.",
                role="Principal Engineer",
                default_currency="USD",
                default_batch_size=50000,
            )
            updated = await AuthService.update_user_profile(None, user.id, update_data)
            self.assertIsNotNone(updated)
            self.assertEqual(updated.full_name, "Updated Name")
            self.assertEqual(updated.organization, "New Bio Packaging Co.")
            self.assertEqual(updated.role, "Principal Engineer")
            self.assertEqual(updated.preferences_json["default_currency"], "USD")
            self.assertEqual(updated.preferences_json["default_batch_size"], 50000)

        asyncio.run(run_test())

    def test_saved_analyses_crud_and_multi_tenant_isolation(self):
        async def run_test():
            # User A
            user_a = await AuthService.create_user(None, UserCreate(
                email="user.a@test.com",
                password="PasswordA123!",
                full_name="User Alpha",
            ))

            # User B
            user_b = await AuthService.create_user(None, UserCreate(
                email="user.b@test.com",
                password="PasswordB123!",
                full_name="User Beta",
            ))

            # User A creates a saved preset
            preset_a = await AuthService.create_saved_analysis(
                None,
                user_a.id,
                SavedAnalysisCreate(
                    title="Alphonso Mango Export Spec",
                    notes="Tested for 21 days maritime cold chain.",
                    commodity_name="Fresh Alphonso Mango",
                    recommended_material="Micro-Perforated PLA / Bio-PET",
                    estimated_cost=4.20,
                    sustainability_score=94.0,
                    input_payload={"item_name": "Fresh Alphonso Mango"},
                    recommendation_result={"material_name": "Micro-Perforated PLA / Bio-PET"},
                )
            )
            self.assertEqual(preset_a.user_id, user_a.id)

            # User A can retrieve it
            list_a = await AuthService.get_saved_analyses(None, user_a.id)
            self.assertEqual(len(list_a), 1)
            self.assertEqual(list_a[0].title, "Alphonso Mango Export Spec")

            # User B cannot see User A's preset
            list_b = await AuthService.get_saved_analyses(None, user_b.id)
            self.assertEqual(len(list_b), 0)

            # User B cannot read User A's preset by ID
            b_lookup = await AuthService.get_saved_analysis_by_id(None, user_b.id, preset_a.id)
            self.assertIsNone(b_lookup)

            # User B cannot delete User A's preset
            b_delete = await AuthService.delete_saved_analysis(None, user_b.id, preset_a.id)
            self.assertFalse(b_delete)

            # User A can delete their preset
            a_delete = await AuthService.delete_saved_analysis(None, user_a.id, preset_a.id)
            self.assertTrue(a_delete)
            self.assertEqual(len(await AuthService.get_saved_analyses(None, user_a.id)), 0)

        asyncio.run(run_test())

if __name__ == "__main__":
    unittest.main()
