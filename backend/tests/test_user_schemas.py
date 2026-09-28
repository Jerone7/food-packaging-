"""
Unit Tests for User & Saved Analysis Pydantic Schemas (Module 14 - Task 2.1).
"""

import unittest
from datetime import datetime, timezone
from pydantic import ValidationError
from app.schemas.user import (
    UserCreate,
    UserLogin,
    UserUpdate,
    UserPreferences,
    UserStats,
    UserResponse,
    TokenResponse,
    TokenPayload,
    SavedAnalysisCreate,
    SavedAnalysisResponse,
)

class TestUserSchemas(unittest.TestCase):
    def test_user_create_valid(self):
        data = {
            "email": "engineer@packtech.io",
            "password": "StrongPassword123!",
            "full_name": "Elena Rostova",
            "organization": "BioPack Global",
            "role": "Lead Materials Scientist",
            "default_eco_priority": True,
            "default_currency": "INR",
        }
        user_create = UserCreate(**data)
        self.assertEqual(user_create.email, "engineer@packtech.io")
        self.assertEqual(user_create.full_name, "Elena Rostova")
        self.assertEqual(user_create.organization, "BioPack Global")
        self.assertTrue(user_create.default_eco_priority)

    def test_user_create_invalid_email(self):
        with self.assertRaises(ValidationError):
            UserCreate(
                email="not-an-email",
                password="StrongPassword123!",
                full_name="Elena Rostova",
            )

    def test_user_create_short_password(self):
        with self.assertRaises(ValidationError):
            UserCreate(
                email="valid@test.com",
                password="short",  # < 8 characters
                full_name="Elena Rostova",
            )

    def test_user_login_valid(self):
        login = UserLogin(email="user@test.com", password="Password123!")
        self.assertEqual(login.email, "user@test.com")
        self.assertEqual(login.password, "Password123!")

    def test_user_response_and_preferences(self):
        now = datetime.now(timezone.utc)
        user_resp = UserResponse(
            id=1,
            email="tech@packaging.org",
            full_name="Marcus Vance",
            organization="AgriPack",
            role="Packaging Engineer",
            is_active=True,
            is_admin=False,
            created_at=now,
            preferences=UserPreferences(
                default_eco_priority=True,
                default_currency="USD",
                default_batch_size=25000,
            ),
            stats=UserStats(
                total_analyses_count=15,
                saved_presets_count=4,
                eco_friendly_count=12,
                average_sustainability_score=87.5,
                member_since=now,
            ),
        )
        
        self.assertEqual(user_resp.id, 1)
        self.assertEqual(user_resp.preferences.default_currency, "USD")
        self.assertEqual(user_resp.preferences.default_batch_size, 25000)
        self.assertEqual(user_resp.stats.total_analyses_count, 15)
        self.assertEqual(user_resp.stats.average_sustainability_score, 87.5)

    def test_token_response_schema(self):
        now = datetime.now(timezone.utc)
        user_resp = UserResponse(
            id=2,
            email="lead@converter.com",
            full_name="Sarah Connor",
            created_at=now,
            preferences=UserPreferences(),
        )
        token_resp = TokenResponse(
            access_token="mock.jwt.token",
            token_type="bearer",
            expires_in_seconds=604800,
            user=user_resp,
        )
        self.assertEqual(token_resp.access_token, "mock.jwt.token")
        self.assertEqual(token_resp.token_type, "bearer")
        self.assertEqual(token_resp.user.email, "lead@converter.com")

    def test_saved_analysis_create_and_response(self):
        now = datetime.now(timezone.utc)
        create_payload = {
            "title": "Fresh Cut Mango MAP Pouch",
            "notes": "Optimal O2 permeability to suppress anaerobic fermentative souring.",
            "commodity_name": "Fresh Cut Mango",
            "recommended_material": "Micro-Perforated PLA / Bio-PET",
            "estimated_cost": 3.45,
            "sustainability_score": 90.0,
            "input_payload": {"name": "Fresh Cut Mango", "weight_g": 250},
            "recommendation_result": {"material": "Micro-Perforated PLA / Bio-PET", "cost_inr": 3.45},
        }
        preset_create = SavedAnalysisCreate(**create_payload)
        self.assertEqual(preset_create.title, "Fresh Cut Mango MAP Pouch")
        self.assertEqual(preset_create.commodity_name, "Fresh Cut Mango")

        preset_resp = SavedAnalysisResponse(
            id=10,
            user_id=1,
            title=preset_create.title,
            notes=preset_create.notes,
            commodity_name=preset_create.commodity_name,
            recommended_material="Micro-Perforated PLA / Bio-PET",
            estimated_cost=3.45,
            sustainability_score=90.0,
            input_payload=preset_create.input_payload,
            recommendation_result=preset_create.recommendation_result,
            created_at=now,
        )
        self.assertEqual(preset_resp.id, 10)
        self.assertEqual(preset_resp.user_id, 1)
        self.assertEqual(preset_resp.recommended_material, "Micro-Perforated PLA / Bio-PET")

if __name__ == "__main__":
    unittest.main()
