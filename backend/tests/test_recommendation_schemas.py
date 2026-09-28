"""
Unit test suite for Explainable Packaging Recommendation Schemas (Task 1.1).
Validates Pydantic schema validation, default assignments, and serialization.
"""

import unittest
from app.schemas.packaging import (
    BarrierProfileSchema,
    PrimaryRecommendationSchema,
    PackagingRecommendationResult,
    BoxGeometrySchema,
    ScientificRationaleSchema,
    PackagingAlternativeSchema,
)


class TestRecommendationSchemas(unittest.TestCase):

    def setUp(self):
        self.barrier = BarrierProfileSchema(
            otr="< 1200 cc/m²/day",
            wvtr="25.0 g/m²/day",
            thickness_microns=30.0,
            tensile_strength_mpa=32.0,
            puncture_resistance_n=22.0,
        )

    def test_primary_recommendation_schema_defaults(self):
        schema = PrimaryRecommendationSchema(
            material_name="Micro-Perforated PLA Bio-Film",
            material_type="Bio-Polymer",
            polymer_family="BREATHABLE_BIO_EMAP",
            structure="Monolayer Bio-Film",
            barrier_profile=self.barrier,
            sustainability_score=88.0,
            estimated_unit_cost_inr=4.20,
            suitability_score=0.96,
        )

        self.assertEqual(schema.packaging_title, "Ventilated Food-Grade Packaging")
        self.assertEqual(schema.packaging_format, "Micro-Perforated Hinged Clamshell")
        self.assertIn("high respiration and moisture sensitivity", schema.recommendation_explanation)
        self.assertEqual(schema.suitable_storage_condition, "Cold Storage (10-12°C, 90-95% RH)")
        self.assertIn("High-respiration fresh produce", schema.expected_application)
        self.assertIsInstance(schema.advantages, list)
        self.assertIsInstance(schema.limitations, list)
        self.assertIsInstance(schema.important_properties, dict)

    def test_primary_recommendation_schema_explicit_values(self):
        schema = PrimaryRecommendationSchema(
            material_name="Metallized BOPP/CPP Pouch",
            material_type="Laminate",
            polymer_family="METALLIZED_BARRIER",
            structure="Tri-layer Met-BOPP/PE/CPP",
            barrier_profile=self.barrier,
            sustainability_score=68.0,
            estimated_unit_cost_inr=2.80,
            suitability_score=0.92,
            packaging_title="Nitrogen-Flushed High-Barrier Pillow Pouch",
            packaging_format="Pillow Pouch with 99.5% N₂ Flush",
            recommendation_explanation="This option is recommended because high lipid content mandates ultra-low oxygen transmission.",
            advantages=[
                "Hermetic light and oxygen barrier (< 1.0 cc/m²/day)",
                "Nitrogen pneumatic cushion protects crisps from breakage",
            ],
            limitations=[
                "Requires multi-layer recycling stream (RIC #7)",
                "Non-compostable packaging substrate",
            ],
            suitable_storage_condition="Ambient Dry Storage (20-25°C, < 65% RH)",
            expected_application="Potato crisps, roasted nuts, puffed snacks",
            important_properties={
                "OTR": "< 1.0 cc/m²/day",
                "WVTR": "< 0.5 g/m²/day",
                "Light Barrier": "100% UV Opacity",
            },
        )

        data = schema.model_dump()
        self.assertEqual(data["packaging_title"], "Nitrogen-Flushed High-Barrier Pillow Pouch")
        self.assertEqual(data["packaging_format"], "Pillow Pouch with 99.5% N₂ Flush")
        self.assertEqual(len(data["advantages"]), 2)
        self.assertEqual(len(data["limitations"]), 2)
        self.assertEqual(data["important_properties"]["Light Barrier"], "100% UV Opacity")

    def test_packaging_recommendation_result_full_roundtrip(self):
        primary = PrimaryRecommendationSchema(
            material_name="Micro-Perforated PLA Bio-Film",
            material_type="Bio-Polymer",
            polymer_family="BREATHABLE_BIO_EMAP",
            structure="Monolayer Bio-Film",
            barrier_profile=self.barrier,
            sustainability_score=88.0,
            estimated_unit_cost_inr=4.20,
            suitability_score=0.96,
            packaging_title="Ventilated Food-Grade Packaging",
        )

        result = PackagingRecommendationResult(
            recommendation_id="rec_test_123",
            primary_recommendation=primary,
            alternatives=[
                PackagingAlternativeSchema(
                    type="ECO_FRIENDLY",
                    material_name="Cellulose NatureFlex Film",
                    sustainability_score=94.0,
                    estimated_unit_cost_inr=5.10,
                    trade_off_summary="Highest bio-score but 20% higher unit cost.",
                )
            ],
            box_geometry=BoxGeometrySchema(
                length_cm=25.0,
                width_cm=15.0,
                height_cm=10.0,
                total_volume_cm3=3750.0,
                space_utilization_pct=74.7,
                cushioning_material="Molded Cellulose Pulp Nest",
            ),
            scientific_rationale=ScientificRationaleSchema(
                summary="Equilibrium MAP prescription.",
                key_drivers=["High respiration", "Anti-fog required"],
            ),
        )

        dumped = result.model_dump()
        self.assertEqual(dumped["recommendation_id"], "rec_test_123")
        self.assertEqual(dumped["primary_recommendation"]["packaging_title"], "Ventilated Food-Grade Packaging")
        self.assertEqual(len(dumped["alternatives"]), 1)


if __name__ == "__main__":
    unittest.main()
