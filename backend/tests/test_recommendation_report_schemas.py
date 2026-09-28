"""
Unit tests for Module 12: Recommendation Report Pydantic v2 Schemas (Task 1.1).
"""

import unittest
from datetime import datetime, timezone
from pydantic import ValidationError

from app.schemas.recommendation_report import (
    ReportFoodContext,
    ReportFoodProperties,
    ReportPrimaryPrescription,
    ReportAlternativePackaging,
    ReportLcaSummary,
    ReportCostSummary,
    RecommendationReportRequest,
    RecommendationReportModel,
    ReportMarkdownResponse,
)


class TestRecommendationReportSchemas(unittest.TestCase):
    def setUp(self):
        self.food_context = ReportFoodContext(
            name="Roasted Arabica Coffee Beans",
            category="Beverages",
            scientific_name="Coffea arabica",
            fill_quantity="500g",
            batch_size_units=10000,
            storage_condition="Cool Dry Storage (20°C, 50% RH)",
            storage_temp_c=20.0,
            storage_duration_days=180,
            transport_mode="Dry Ambient Freight",
        )

        self.food_properties = ReportFoodProperties(
            moisture_pct=2.5,
            water_activity_aw=0.35,
            ph_level=5.2,
            fat_pct=14.0,
            respiration_class="Very Low",
            respiration_rate_20c=0.0,
            oxygen_sensitivity="High",
            moisture_sensitivity="High",
            ethylene_sensitivity="Low",
            chilling_injury_threshold_c=None,
        )

        self.primary_prescription = ReportPrimaryPrescription(
            material_name="EVOH High-Barrier Metallized Pouch",
            material_type="Multilayer Barrier Coex",
            polymer_family="MULTILAYER_BARRIER_COEX",
            structure="BOPET 12µ / EVOH 15µ / LLDPE 50µ",
            package_format="Stand-up Doypack (Bottom Gusset)",
            dimensions="18.0 x 12.0 x 4.0 cm",
            thickness_microns=77.0,
            otr="< 1.5 cc/m²/day",
            wvtr="< 0.8 g/m²/day",
            tensile_strength_mpa=48.0,
            puncture_resistance_n=28.0,
            suitability_score=0.96,
            sustainability_score=82.0,
            estimated_unit_cost_inr=4.25,
            advantages=["Hermetic oxygen barrier preserves aromatic volatiles", "High puncture resistance"],
            limitations=["Not suitable for retort sterilization > 121°C"],
            important_properties={"OTR": "< 1.5 cc/m²/day", "WVTR": "< 0.8 g/m²/day"},
        )

        self.alternative = ReportAlternativePackaging(
            tier_name="Eco-Champion",
            material_name="NatureFlex™ NK Bio-Cellulose",
            packaging_title="Home Compostable Film",
            key_tradeoff="100% Home Compostable bio-origin with 12% cost delta",
            cost_delta_pct=12.5,
            eco_delta_pct=15.0,
            shelf_life_delta="120 days vs 180 days baseline",
            star_rating=4,
        )

        self.lca_summary = ReportLcaSummary(
            recyclability_tier="Medium",
            resin_identification_code="RIC 7 (OTHER)",
            biodegradability_standard="EN 13432 (Industrial Compost)",
            reusability_cycles=1,
            carbon_footprint_g_per_unit=16.8,
            carbon_footprint_batch_kg=168.0,
            pcr_percentage=20.0,
            pcr_carbon_reduction_pct=14.2,
            water_footprint_l_per_unit=0.45,
            water_footprint_batch_liters=4500.0,
            unit_waste_grams=14.2,
            total_batch_waste_kg=142.0,
            landfill_diversion_pct=75.0,
            circularity_index_mci=0.72,
            primary_disposal_pathway="Energy Recovery / Industrial Composting",
        )

        self.cost_summary = ReportCostSummary(
            estimated_cost_per_unit_inr=4.25,
            estimated_batch_cost_inr=42500.0,
            gross_material_mass_grams=14.2,
            gross_material_mass_batch_kg=142.0,
            film_surface_area_sqm=0.062,
            currency="INR",
        )

    def test_report_food_context_validation(self):
        """Verify ReportFoodContext valid creation and default fallbacks."""
        ctx = self.food_context
        self.assertEqual(ctx.name, "Roasted Arabica Coffee Beans")
        self.assertEqual(ctx.category, "Beverages")
        self.assertEqual(ctx.storage_duration_days, 180)
        self.assertEqual(ctx.batch_size_units, 10000)

        # Invalid batch size
        with self.assertRaises(ValidationError):
            ReportFoodContext(name="Tea", fill_quantity="100g", batch_size_units=0, storage_condition="Ambient", storage_duration_days=30)

    def test_report_food_properties_ranges(self):
        """Verify boundary constraints on biochemical metrics."""
        props = self.food_properties
        self.assertEqual(props.moisture_pct, 2.5)
        self.assertEqual(props.water_activity_aw, 0.35)
        self.assertEqual(props.ph_level, 5.2)

        # Invalid aw > 1.0
        with self.assertRaises(ValidationError):
            ReportFoodProperties(water_activity_aw=1.5)

        # Invalid pH < 0.0
        with self.assertRaises(ValidationError):
            ReportFoodProperties(ph_level=-1.0)

    def test_report_primary_prescription_fields(self):
        """Verify ReportPrimaryPrescription schema validation."""
        rx = self.primary_prescription
        self.assertEqual(rx.material_name, "EVOH High-Barrier Metallized Pouch")
        self.assertEqual(rx.thickness_microns, 77.0)
        self.assertEqual(rx.suitability_score, 0.96)
        self.assertIn("OTR", rx.important_properties)

        # Invalid thickness <= 0
        with self.assertRaises(ValidationError):
            ReportPrimaryPrescription(
                material_name="Test",
                thickness_microns=0.0,
            )

    def test_report_alternative_packaging_model(self):
        """Verify ReportAlternativePackaging serialization and star rating."""
        alt = self.alternative
        self.assertEqual(alt.tier_name, "Eco-Champion")
        self.assertEqual(alt.star_rating, 4)
        self.assertEqual(alt.cost_delta_pct, 12.5)

        # Invalid star rating > 5
        with self.assertRaises(ValidationError):
            ReportAlternativePackaging(
                tier_name="Eco",
                material_name="Bio",
                key_tradeoff="Tradeoff",
                star_rating=6,
            )

    def test_report_lca_and_cost_summaries(self):
        """Verify LCA and Cost summary schemas."""
        lca = self.lca_summary
        cost = self.cost_summary

        self.assertEqual(lca.carbon_footprint_g_per_unit, 16.8)
        self.assertEqual(lca.circularity_index_mci, 0.72)
        self.assertEqual(cost.estimated_cost_per_unit_inr, 4.25)
        self.assertEqual(cost.estimated_batch_cost_inr, 42500.0)

    def test_recommendation_report_model_serialization(self):
        """Verify complete RecommendationReportModel JSON serialization and deserialization."""
        report = RecommendationReportModel(
            report_id="SPK-2026-9B7C12F",
            engine_version="SmartPack AI Engine v2.4-Hybrid",
            verification_hash="9f8a3c2e1b4d0e7a5c6b8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a",
            food_context=self.food_context,
            food_properties=self.food_properties,
            primary_prescription=self.primary_prescription,
            explainable_rationale="Matched ultra-low OTR (<1.5) to prevent volatile aromatic lipid oxidation.",
            key_drivers=["Moisture Sensitivity", "Volatile Lipid Oxidation Risk"],
            alternatives=[self.alternative],
            lca_summary=self.lca_summary,
            cost_summary=self.cost_summary,
            standards_and_citations=["ASTM F1927 (OTR)", "ASTM F1249 (WVTR)", "Sphera GaBi 2023"],
            share_url="https://smartpack.ai/reports/SPK-2026-9B7C12F",
        )

        data = report.model_dump()
        self.assertEqual(data["report_id"], "SPK-2026-9B7C12F")
        self.assertEqual(data["food_context"]["name"], "Roasted Arabica Coffee Beans")
        self.assertEqual(data["primary_prescription"]["thickness_microns"], 77.0)
        self.assertEqual(len(data["alternatives"]), 1)

        # Roundtrip JSON validation
        json_str = report.model_dump_json()
        restored = RecommendationReportModel.model_validate_json(json_str)
        self.assertEqual(restored.report_id, "SPK-2026-9B7C12F")
        self.assertEqual(restored.verification_hash, report.verification_hash)

    def test_report_markdown_response(self):
        """Verify ReportMarkdownResponse model."""
        resp = ReportMarkdownResponse(
            report_id="SPK-2026-9B7C12F",
            markdown_content="# SmartPack AI Report\n| Spec | Value |\n|---|---|",
        )
        self.assertEqual(resp.report_id, "SPK-2026-9B7C12F")
        self.assertIn("# SmartPack AI Report", resp.markdown_content)


if __name__ == "__main__":
    unittest.main()
