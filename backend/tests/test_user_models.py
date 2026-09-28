"""
Unit Tests for User & Saved Analysis Relational Models (Module 14 - Task 1.2).
"""

import unittest
from datetime import datetime
from app.models.user import User, SavedAnalysis
from app.models.packaging import PackagingRecommendation

class TestUserModels(unittest.TestCase):
    def test_user_instantiation_defaults(self):
        user = User(
            email="researcher@agrofood.org",
            hashed_password="pbkdf2_sha256$100000$salt$hash",
            full_name="Dr. Aris Thorne",
            organization="AgroFood Institute",
            role="Senior Packaging Scientist",
        )
        
        self.assertEqual(user.email, "researcher@agrofood.org")
        self.assertEqual(user.full_name, "Dr. Aris Thorne")
        self.assertEqual(user.role, "Senior Packaging Scientist")
        self.assertTrue(user.is_active)
        self.assertFalse(user.is_admin)
        self.assertIsInstance(user.created_at, datetime)
        self.assertEqual(user.preferences_json["default_currency"], "INR")

    def test_saved_analysis_instantiation(self):
        saved = SavedAnalysis(
            user_id=1,
            title="Q4 High Barrier Strawberry Spec",
            notes="Evaluated for 14-day ambient shelf-life with EVOH substrate",
            commodity_name="Fresh Strawberries",
            recommended_material="Micro-Perforated PLA / Bio-PET",
            estimated_cost=4.80,
            sustainability_score=92.0,
            input_payload={"item_name": "Fresh Strawberries", "weight": 500.0, "moisture": 91.0},
            recommendation_result={"material_name": "Micro-Perforated PLA / Bio-PET", "estimated_cost": 4.80},
        )
        
        self.assertEqual(saved.user_id, 1)
        self.assertEqual(saved.title, "Q4 High Barrier Strawberry Spec")
        self.assertEqual(saved.commodity_name, "Fresh Strawberries")
        self.assertEqual(saved.estimated_cost, 4.80)
        self.assertEqual(saved.sustainability_score, 92.0)
        self.assertIn("item_name", saved.input_payload)
        self.assertIn("material_name", saved.recommendation_result)

    def test_user_and_saved_analysis_relationship(self):
        user = User(
            id=10,
            email="lead@converter.com",
            hashed_password="hash",
            full_name="Alex Rivera",
        )
        saved = SavedAnalysis(
            id=101,
            user_id=10,
            title="Coffee Roasted Beans Pouch",
            commodity_name="Roasted Coffee Beans",
            recommended_material="Tri-Layer Aluminium Foil Laminate",
            input_payload={"item_name": "Roasted Coffee Beans"},
            recommendation_result={"material_name": "Tri-Layer Aluminium Foil Laminate"},
            user=user,
        )
        
        self.assertEqual(len(user.saved_analyses), 1)
        self.assertEqual(user.saved_analyses[0].title, "Coffee Roasted Beans Pouch")
        self.assertEqual(saved.user.email, "lead@converter.com")

    def test_packaging_recommendation_user_link(self):
        user = User(
            id=5,
            email="operator@packline.com",
            hashed_password="hash",
            full_name="Operations Team",
        )
        rec = PackagingRecommendation(
            id=501,
            user_id=5,
            item_name="Alphonso Mango",
            length=15.0,
            width=10.0,
            height=8.0,
            weight=0.35,
            is_fragile=True,
            eco_friendly=True,
            recommended_box_type="Corrugated Box with Molded Pulp",
            recommended_dimensions="16 x 11 x 9 cm",
            cushioning_material="Molded Pulp Trays",
            estimated_cost=3.20,
            sustainability_score=88.0,
            user=user,
        )
        
        self.assertEqual(rec.user_id, 5)
        self.assertEqual(rec.user.full_name, "Operations Team")
        self.assertEqual(len(user.recommendations), 1)
        self.assertEqual(user.recommendations[0].item_name, "Alphonso Mango")

if __name__ == "__main__":
    unittest.main()
