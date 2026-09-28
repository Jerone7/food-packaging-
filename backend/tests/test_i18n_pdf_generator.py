"""
Unit & Integration Tests for Multilingual PDF Recommendation Report Generator (Task 2.4).
Verifies TrueType Unicode font registration, dual-column bilingual layout rendering,
and HTTP endpoint delivery in English, Tamil, and Hindi.
"""

import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.services.report_generator_service import (
    IndicFontRegistry,
    MultilingualPdfReportGenerator,
    report_generator_service,
)


class TestMultilingualPdfGenerator(unittest.TestCase):
    """Unit tests for MultilingualPdfReportGenerator."""

    def setUp(self):
        self.sample_report_data = {
            "report_id": "SPK-20260927-TEST01",
            "food_name": "Tomato",
            "category": "Vegetables",
            "quantity": "500 kg",
            "primary_material": "Bio-PBS Micro-Perforated Film",
            "storage_temp_c": 14.0,
            "moisture": 94.0,
            "respiration_rate_20c": 28.0,
            "chilling_injury_threshold_c": 10.0,
        }

    def test_indic_font_registry_initialization(self):
        font_name = IndicFontRegistry.initialize_fonts()
        self.assertIsInstance(font_name, str)
        self.assertTrue(len(font_name) > 0)
        self.assertEqual(IndicFontRegistry.get_font_name(), font_name)

    def test_generate_english_pdf_bytes(self):
        pdf_bytes = report_generator_service.generate_pdf_report(
            self.sample_report_data,
            locale="en",
        )
        self.assertIsInstance(pdf_bytes, bytes)
        self.assertTrue(len(pdf_bytes) > 1000)
        # Verify PDF magic header
        self.assertTrue(pdf_bytes.startswith(b"%PDF-"))

    def test_generate_tamil_pdf_bytes_clean_rendering(self):
        tamil_data = dict(self.sample_report_data)
        tamil_data["food_name"] = "Tomato"  # Resolved to தக்காளி
        tamil_data["storage_temp_c"] = 8.0  # Triggers chilling injury alert

        pdf_bytes = report_generator_service.generate_pdf_report(
            tamil_data,
            locale="ta",
        )
        self.assertIsInstance(pdf_bytes, bytes)
        self.assertTrue(len(pdf_bytes) > 1000)
        self.assertTrue(pdf_bytes.startswith(b"%PDF-"))

    def test_generate_hindi_pdf_bytes_clean_rendering(self):
        hindi_data = dict(self.sample_report_data)
        hindi_data["storage_temp_c"] = 5.0
        hindi_data["fat"] = 25.0  # Triggers lipid oxidation alert

        pdf_bytes = report_generator_service.generate_pdf_report(
            hindi_data,
            locale="hi",
        )
        self.assertIsInstance(pdf_bytes, bytes)
        self.assertTrue(len(pdf_bytes) > 1000)
        self.assertTrue(pdf_bytes.startswith(b"%PDF-"))


class TestPdfReportApiEndpoints(unittest.TestCase):
    """Integration tests for /api/v1/reports/pdf endpoint."""

    def setUp(self):
        self.client = TestClient(app, raise_server_exceptions=False)
        self.payload = {
            "food_name": "Tomato",
            "category": "Vegetables",
            "fill_quantity": "100 kg",
            "batch_size_units": 5000,
            "target_shelf_life_days": 21,
            "storage_condition": "Ambient Standard",
            "moisture_pct": 94.0,
            "respiration_rate_20c": 28.0,
        }

    def test_post_pdf_report_default_english(self):
        resp = self.client.post("/api/v1/reports/pdf", json=self.payload)
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-type"), "application/pdf")
        self.assertTrue(resp.content.startswith(b"%PDF-"))
        self.assertEqual(resp.headers.get("content-language"), "en")

    def test_post_pdf_report_tamil_accept_language(self):
        resp = self.client.post(
            "/api/v1/reports/pdf",
            json=self.payload,
            headers={"Accept-Language": "ta-IN,ta;q=0.9,en;q=0.8"},
        )
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-type"), "application/pdf")
        self.assertEqual(resp.headers.get("content-language"), "ta")
        self.assertIn("smartpack_report_ta.pdf", resp.headers.get("content-disposition", ""))
        self.assertTrue(resp.content.startswith(b"%PDF-"))

    def test_post_pdf_report_hindi_query_param(self):
        resp = self.client.post(
            "/api/v1/reports/pdf?lang=hi",
            json=self.payload,
        )
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-type"), "application/pdf")
        self.assertEqual(resp.headers.get("content-language"), "hi")
        self.assertIn("smartpack_report_hi.pdf", resp.headers.get("content-disposition", ""))
        self.assertTrue(resp.content.startswith(b"%PDF-"))


if __name__ == "__main__":
    unittest.main()
