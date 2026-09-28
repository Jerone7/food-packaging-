"""
Unit tests for ReportService (Module 12: Recommendation Report & Multi-Format Export Engine).
Verifies report synthesis, SHA-256 verification hashing, empirical LCA/cost breakdowns,
3-way alternatives benchmarking, and Markdown document serialization.
"""

import unittest
from datetime import datetime, timezone
from app.schemas.recommendation_report import RecommendationReportRequest, RecommendationReportModel
from app.services.report_service import ReportService


class TestReportService(unittest.TestCase):
    """Test suite for ReportService synthesis and export capabilities."""

    def setUp(self):
        self.standard_request = RecommendationReportRequest(
            food_name="Fresh Tomato",
            category="Vegetables",
            fill_quantity="500g",
            batch_size_units=10000,
            length_cm=18.0,
            width_cm=12.0,
            depth_or_gusset_cm=4.0,
            thickness_microns=45.0,
            pcr_percentage=20.0,
            target_shelf_life_days=21,
            storage_condition="Refrigerated (4°C - 8°C)",
        )

    def test_compute_verification_hash(self):
        """Verify that SHA-256 hash computation is deterministic and reproducible."""
        hash1 = ReportService.compute_verification_hash(
            food_name="Fresh Tomato",
            material_name="Bio-Based EMAP Film",
            thickness_microns=45.0,
            otr="1200.0 cc/m²/day",
            wvtr="45.0 g/m²/day",
            timestamp_str="2026-09-26T12:00:00Z",
        )
        hash2 = ReportService.compute_verification_hash(
            food_name="Fresh Tomato",
            material_name="Bio-Based EMAP Film",
            thickness_microns=45.0,
            otr="1200.0 cc/m²/day",
            wvtr="45.0 g/m²/day",
            timestamp_str="2026-09-26T12:00:00Z",
        )
        hash3 = ReportService.compute_verification_hash(
            food_name="Potato Chips",
            material_name="Bio-Based EMAP Film",
            thickness_microns=45.0,
            otr="1200.0 cc/m²/day",
            wvtr="45.0 g/m²/day",
            timestamp_str="2026-09-26T12:00:00Z",
        )
        self.assertEqual(hash1, hash2)
        self.assertNotEqual(hash1, hash3)
        self.assertEqual(len(hash1), 64)

    def test_synthesize_report_with_scientific_profile(self):
        """Verify report synthesis correctly links to scientific food database."""
        report = ReportService.synthesize_report(self.standard_request)

        self.assertIsInstance(report, RecommendationReportModel)
        self.assertTrue(report.report_id.startswith("SPK-"))
        self.assertEqual(report.engine_version, "SmartPack AI Engine v2.4-Hybrid")
        self.assertIsNotNone(report.verification_hash)

        # Check food context
        self.assertEqual(report.food_context.name, "Fresh Tomato")
        self.assertEqual(report.food_context.category, "Vegetables")
        self.assertEqual(report.food_context.fill_quantity, "500g")
        self.assertEqual(report.food_context.storage_temp_c, 4.0)
        self.assertEqual(report.food_context.transport_mode, "Refrigerated Cold Chain")

        # Check food properties resolved from scientific catalog
        self.assertIsNotNone(report.food_properties.moisture_pct)
        self.assertGreater(report.food_properties.moisture_pct, 80.0)
        self.assertEqual(report.food_properties.respiration_class, "Moderate")

        # Check primary prescription
        self.assertIsNotNone(report.primary_prescription.material_name)
        self.assertGreater(report.primary_prescription.tensile_strength_mpa, 0.0)
        self.assertGreater(report.primary_prescription.puncture_resistance_n, 0.0)

        # Check XAI rationale and decision drivers
        self.assertTrue(len(report.explainable_rationale) > 20)
        self.assertGreaterEqual(len(report.key_drivers), 3)

        # Check 3-way alternatives
        self.assertEqual(len(report.alternatives), 3)
        tier_names = [a.tier_name for a in report.alternatives]
        self.assertIn("Eco-Champion", tier_names)
        self.assertIn("Economy", tier_names)
        self.assertIn("High-Barrier", tier_names)

        # Check LCA & cost summaries
        self.assertGreater(report.lca_summary.carbon_footprint_g_per_unit, 0.0)
        self.assertGreater(report.lca_summary.carbon_footprint_batch_kg, 0.0)
        self.assertEqual(report.lca_summary.pcr_percentage, 20.0)
        self.assertGreater(report.cost_summary.estimated_cost_per_unit_inr, 0.0)
        self.assertGreater(report.cost_summary.estimated_batch_cost_inr, 0.0)

    def test_synthesize_report_with_explicit_material_selection(self):
        """Verify report synthesis with explicit material ID."""
        request = RecommendationReportRequest(
            food_name="Roasted Coffee Beans",
            category="Beverages & Dry Powders",
            fill_quantity="1kg",
            batch_size_units=5000,
            length_cm=24.0,
            width_cm=16.0,
            depth_or_gusset_cm=6.0,
            thickness_microns=70.0,
            pcr_percentage=0.0,
            target_shelf_life_days=365,
            storage_condition="Ambient Standard",
            selected_material_id="mat_al_foil_lam_13",
        )
        report = ReportService.synthesize_report(request, report_id="SPK-TEST-001")

        self.assertEqual(report.report_id, "SPK-TEST-001")
        self.assertEqual(report.food_context.name, "Roasted Coffee Beans")
        self.assertEqual(report.food_context.storage_duration_days, 365)
        self.assertEqual(report.primary_prescription.thickness_microns, 70.0)
        self.assertIn("Aluminium Foil", report.primary_prescription.material_name)

    def test_format_markdown_report(self):
        """Verify Markdown serializer outputs clean GitHub Flavored Markdown specification document."""
        report = ReportService.synthesize_report(self.standard_request)
        md_content = ReportService.format_markdown_report(report)

        self.assertIsInstance(md_content, str)
        self.assertIn("# 📄 SmartPack AI Packaging Recommendation Specification Report", md_content)
        self.assertIn(f"**Report ID:** `{report.report_id}`", md_content)
        self.assertIn(f"**Provenance Verification Hash:** `{report.verification_hash}`", md_content)
        self.assertIn("## 1. Food Commodity Context & Operational Parameters", md_content)
        self.assertIn("## 2. Biochemical Food Degradation Profile", md_content)
        self.assertIn("## 3. Primary Prescribed Packaging Formulation & Barrier Specifications", md_content)
        self.assertIn("## 4. Explainable AI (XAI) Prescription Rationale & Key Drivers", md_content)
        self.assertIn("## 5. Multi-Material Comparative Benchmarking Matrix", md_content)
        self.assertIn("## 6. Environmental Sustainability & Life Cycle Assessment (LCA) Impact", md_content)
        self.assertIn("## 7. Converter Cost Economics Baseline", md_content)
        self.assertIn("## 8. Regulatory Compliance, Standards & Citations", md_content)
        self.assertIn("ASTM F1927", md_content)
        self.assertIn("Fresh Tomato", md_content)

    def test_synthesize_report_unrecognized_food_fallback(self):
        """Verify graceful fallback when food name is not in predefined catalog."""
        request = RecommendationReportRequest(
            food_name="Unknown Exotic Space Snack",
            fill_quantity="250g",
            batch_size_units=1000,
            storage_condition="Ambient Standard",
            target_shelf_life_days=90,
        )
        report = ReportService.synthesize_report(request)
        self.assertEqual(report.food_context.name, "Unknown Exotic Space Snack")
        self.assertIsNotNone(report.primary_prescription)
        self.assertIsNotNone(report.lca_summary)
        self.assertIsNotNone(report.cost_summary)


if __name__ == "__main__":
    unittest.main()
