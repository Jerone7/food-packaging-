"""
Unit & Integration Tests for Multilingual XAI Prescription Explanations & Spoilage Alerts (Task 2.3).
Tests MultilingualRecommendationService and /api/v1/packaging/recommend + /spoilage-alerts endpoints
in English, Tamil, and Hindi.
"""

import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.services.recommendation_service import (
    MultilingualRecommendationService,
    recommendation_service,
    LocalizedScientificRationale,
    LocalizedSpoilageAlert,
    LocalizedExplainableRecommendation,
)


class TestMultilingualRecommendationService(unittest.TestCase):
    """Unit tests for MultilingualRecommendationService."""

    def test_english_scientific_rationale_high_respiration(self):
        input_data = {
            "name": "Fresh Tomato",
            "moisture_pct": 94.5,
            "respiration_rate_20c": 28.0,
            "respiration_class": "high",
        }
        res = recommendation_service.generate_scientific_rationale(
            commodity_name="Fresh Tomato",
            category="Vegetables",
            material="Bio-PBS Clamshell",
            input_data=input_data,
            locale="en",
        )
        self.assertIsInstance(res, LocalizedScientificRationale)
        self.assertIn("Equilibrium Modified Atmosphere Packaging", res.summary)
        self.assertTrue(any("gas-permeable micro-perforations" in d for d in res.key_drivers))
        self.assertTrue(any("anti-fog surfactant" in d for d in res.key_drivers))

    def test_tamil_scientific_rationale_vernacular(self):
        input_data = {
            "name": "தக்காளி",
            "moisture_pct": 94.5,
            "respiration_rate_20c": 28.0,
            "respiration_class": "high",
        }
        res = recommendation_service.generate_scientific_rationale(
            commodity_name="தக்காளி",
            category="Vegetables",
            material="மக்கும் பயோ-பாலிமர்",
            input_data=input_data,
            locale="ta",
        )
        self.assertIn("பூஞ்சை காளான் வளர்ச்சியை தடுக்கவும்", res.summary)
        self.assertIn("சீரான காற்றோட்டப் பைகள் (EMAP)", res.summary)
        self.assertTrue(any("அதிக சுவாசித்தல் வீதம்" in d for d in res.key_drivers))
        self.assertTrue(any("பனிமூட்டம் தடுக்கும் பூச்சு" in d for d in res.key_drivers))

    def test_hindi_scientific_rationale_vernacular(self):
        input_data = {
            "name": "टमाटर",
            "moisture_pct": 94.5,
            "respiration_rate_20c": 28.0,
            "respiration_class": "high",
        }
        res = recommendation_service.generate_scientific_rationale(
            commodity_name="टमाटर",
            category="Vegetables",
            material="बायो-पीबीएस",
            input_data=input_data,
            locale="hi",
        )
        self.assertIn("संतुलित वायुमंडलीय पैकेजिंग (EMAP)", res.summary)
        self.assertTrue(any("उच्च श्वसन दर" in d for d in res.key_drivers))
        self.assertTrue(any("एंटी-फॉग कोटिंग" in d for d in res.key_drivers))

    def test_lipid_oxidation_rationale_high_fat(self):
        input_data = {
            "name": "Fried Banana Chips",
            "fat_pct": 32.0,
            "moisture_pct": 2.5,
        }
        res_ta = recommendation_service.generate_scientific_rationale(
            commodity_name="வாழைக்காய் சிப்ஸ்",
            category="Snacks",
            material="மெட்டலைஸ் பில்லோ பை",
            input_data=input_data,
            locale="ta",
        )
        self.assertIn("நைட்ரஜன் நிரப்பப்பட்ட", res_ta.summary)
        self.assertTrue(any("எண்ணெய் வாசனை கெடுவதைத் தவிர்க்க" in d for d in res_ta.key_drivers))

        res_hi = recommendation_service.generate_scientific_rationale(
            commodity_name="केले के चिप्स",
            category="Snacks",
            material="मेटलाइज्ड पाउच",
            input_data=input_data,
            locale="hi",
        )
        self.assertIn("नाइट्रोजन गैस", res_hi.summary)
        self.assertTrue(any("रैनसिडिटी" in d for d in res_hi.key_drivers))

    def test_chilling_injury_warning_driver(self):
        input_data = {
            "name": "Alphonso Mango",
            "storage_temp_c": 5.0,
            "chilling_injury_threshold_c": 12.0,
            "moisture_pct": 82.0,
        }
        res_ta = recommendation_service.generate_scientific_rationale(
            commodity_name="மாம்பழம்",
            category="Fruits",
            material="பாக்ஸ்",
            input_data=input_data,
            locale="ta",
        )
        self.assertTrue(any("குளிர் தாங்கும் வரம்பை விட" in d for d in res_ta.key_drivers))

    def test_spoilage_alerts_chilling_injury(self):
        input_data = {
            "name": "Alphonso Mango",
            "storage_temp_c": 6.0,
            "chilling_injury_threshold_c": 12.0,
            "moisture_pct": 80.0,
        }
        alerts_en = recommendation_service.generate_spoilage_alerts("Alphonso Mango", input_data, locale="en")
        ci_alert_en = next((a for a in alerts_en if a.alert_type == "CHILLING_INJURY"), None)
        self.assertIsNotNone(ci_alert_en)
        self.assertEqual(ci_alert_en.severity, "CRITICAL")
        self.assertIn("chilling injury floor", ci_alert_en.message.lower())

        alerts_ta = recommendation_service.generate_spoilage_alerts("அல்போன்சா மாம்பழம்", input_data, locale="ta")
        ci_alert_ta = next((a for a in alerts_ta if a.alert_type == "CHILLING_INJURY"), None)
        self.assertIsNotNone(ci_alert_ta)
        self.assertIn("குளிர் காயம் எச்சரிக்கை", ci_alert_ta.title)
        self.assertIn("திசு சேதமடைந்து", ci_alert_ta.message)

    def test_spoilage_alerts_condensation_and_lipid_and_ethylene(self):
        input_data = {
            "name": "Test Mixed Product",
            "moisture_pct": 85.0,
            "fat_pct": 22.0,
            "respiration_rate_20c": 35.0,
            "respiration_class": "extreme",
            "ethylene_sensitivity": "high",
        }
        alerts_ta = recommendation_service.generate_spoilage_alerts("பரிசோதனை உணவு", input_data, locale="ta")
        types = [a.alert_type for a in alerts_ta]
        self.assertIn("MOISTURE_CONDENSATION", types)
        self.assertIn("LIPID_OXIDATION", types)
        self.assertIn("RESPIRATION_SOURING", types)
        self.assertIn("ETHYLENE_SENESCENCE", types)

        cond_alert = next(a for a in alerts_ta if a.alert_type == "MOISTURE_CONDENSATION")
        self.assertIn("பூஞ்சை", cond_alert.title)

        lipid_alert = next(a for a in alerts_ta if a.alert_type == "LIPID_OXIDATION")
        self.assertIn("கொழுப்பு", lipid_alert.title)

    def test_explainable_recommendation_tamil_and_hindi(self):
        input_data = {
            "name": "Tomato",
            "moisture_pct": 92.0,
            "respiration_rate_20c": 22.0,
            "respiration_class": "high",
        }
        exp_ta = recommendation_service.generate_explainable_recommendation(
            commodity_name="தக்காளி",
            category="Vegetables",
            material="மக்கும் பை",
            input_data=input_data,
            locale="ta",
        )
        self.assertEqual(exp_ta.packaging_title, "காற்றோட்டமான உணவுப் பாதுகாப்பு பை")
        self.assertIn("ஈரப்பதம்", exp_ta.recommendation_explanation)
        self.assertTrue(len(exp_ta.advantages) > 0)

        exp_hi = recommendation_service.generate_explainable_recommendation(
            commodity_name="टमाटर",
            category="Vegetables",
            material="बायो-फिल्म",
            input_data=input_data,
            locale="hi",
        )
        self.assertEqual(exp_hi.packaging_title, "हवादार खाद्य-ग्रेड पैकेजिंग")
        self.assertIn("श्वसन", exp_hi.recommendation_explanation)


class TestPackagingApiLocalization(unittest.TestCase):
    """Integration tests verifying /api/v1/packaging localization behavior."""

    def setUp(self):
        self.client = TestClient(app, raise_server_exceptions=False)

    def test_post_recommend_with_tamil_accept_language(self):
        payload = {
            "food_name": "Tomato",
            "category": "Vegetables",
            "quantity": 10.0,
            "moisture": 94.0,
            "respiration_rate_20c": 25.0,
            "respiration_class": "high",
            "storage_temp_c": 15.0,
            "storage_duration_days": 10,
        }
        resp = self.client.post(
            "/api/v1/packaging/recommend",
            json=payload,
            headers={"Accept-Language": "ta-IN,ta;q=0.9,en;q=0.8"}
        )
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-language"), "ta")
        data = resp.json()

        # Localized scientific rationale in Tamil
        rat = data.get("scientific_rationale", {})
        self.assertIn("பூஞ்சை", rat.get("summary", ""))
        self.assertTrue(any("சுவாசித்தல்" in d for d in rat.get("key_drivers", [])))

        # Localized primary recommendation title
        primary = data.get("primary_recommendation", {})
        self.assertEqual(primary.get("packaging_title"), "காற்றோட்டமான உணவுப் பாதுகாப்பு பை")

    def test_post_recommend_with_hindi_query_param(self):
        payload = {
            "food_name": "Tomato",
            "category": "Vegetables",
            "quantity": 10.0,
            "moisture": 94.0,
            "respiration_rate_20c": 25.0,
            "respiration_class": "high",
            "storage_temp_c": 15.0,
        }
        resp = self.client.post(
            "/api/v1/packaging/recommend?lang=hi",
            json=payload,
        )
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-language"), "hi")
        data = resp.json()
        rat = data.get("scientific_rationale", {})
        self.assertIn("संतुलित वायुमंडलीय पैकेजिंग", rat.get("summary", ""))
        primary = data.get("primary_recommendation", {})
        self.assertEqual(primary.get("packaging_title"), "हवादार खाद्य-ग्रेड पैकेजिंग")

    def test_post_spoilage_alerts_endpoint(self):
        payload = {
            "food_name": "Alphonso Mango",
            "category": "Fruits",
            "moisture": 84.0,
            "storage_temp_c": 5.0,
            "chilling_injury_threshold_c": 12.0,
            "ethylene_sensitivity": "high",
        }
        resp = self.client.post(
            "/api/v1/packaging/spoilage-alerts",
            json=payload,
            headers={"Accept-Language": "ta"}
        )
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertEqual(data.get("locale"), "ta")
        self.assertGreaterEqual(data.get("alert_count"), 2)
        alerts = data.get("alerts", [])
        ci_alert = next((a for a in alerts if a["alert_type"] == "CHILLING_INJURY"), None)
        self.assertIsNotNone(ci_alert)
        self.assertEqual(ci_alert["severity"], "CRITICAL")
        self.assertIn("குளிர் காயம்", ci_alert["title"])


if __name__ == "__main__":
    unittest.main()
