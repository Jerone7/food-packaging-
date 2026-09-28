"""
Unit tests for Alternative Packaging Pydantic Schemas (Module 8).
Validates schema initialization, validation constraints, default fallbacks,
and JSON serialization for multi-option recommendation portfolios.
"""

import unittest
from app.schemas.packaging import (
    SuitabilityCategoryEnum,
    AlternativeTypeEnum,
    MaterialCharacteristicsSchema,
    PackagingAlternativeSchema,
    BarrierProfileSchema,
    PrimaryRecommendationSchema,
    PackagingRecommendationResult,
    BoxGeometrySchema,
    ScientificRationaleSchema,
)


class TestAlternativePackagingSchemas(unittest.TestCase):
    """Test suite for alternative packaging data contracts and schemas."""

    def test_suitability_category_enum_values(self):
        """Verify SuitabilityCategoryEnum contains all standardized descriptive categories."""
        self.assertEqual(SuitabilityCategoryEnum.OPTIMAL_MATCH.value, "Optimal Match")
        self.assertEqual(SuitabilityCategoryEnum.HIGH_COMPATIBILITY.value, "High Compatibility")
        self.assertEqual(SuitabilityCategoryEnum.MODERATE_COMPATIBILITY.value, "Moderate Compatibility")
        self.assertEqual(SuitabilityCategoryEnum.CONDITIONAL_ALTERNATIVE.value, "Conditional Alternative")

    def test_alternative_type_enum_values(self):
        """Verify AlternativeTypeEnum contains all optimization role types."""
        self.assertEqual(AlternativeTypeEnum.ECO_FRIENDLY.value, "ECO_FRIENDLY")
        self.assertEqual(AlternativeTypeEnum.ECONOMY.value, "ECONOMY")
        self.assertEqual(AlternativeTypeEnum.HIGH_BARRIER.value, "HIGH_BARRIER")
        self.assertEqual(AlternativeTypeEnum.SPECIALTY_CIRCULAR.value, "SPECIALTY_CIRCULAR")

    def test_material_characteristics_schema_defaults_and_custom(self):
        """Verify MaterialCharacteristicsSchema handles defaults and custom physical parameters."""
        # Default initialization
        default_chars = MaterialCharacteristicsSchema()
        self.assertIn("cc/m²/day", default_chars.otr)
        self.assertIn("g/m²/day", default_chars.wvtr)
        self.assertGreater(default_chars.thickness_microns, 0)
        self.assertGreater(default_chars.tensile_strength_mpa, 0)
        self.assertGreater(default_chars.estimated_cost_inr, 0)

        # Custom characteristics (e.g. Cellulose Bio-Film)
        custom_chars = MaterialCharacteristicsSchema(
            otr="2,800 cc/m²/day",
            wvtr="50.0 g/m²/day",
            thickness_microns=30.0,
            tensile_strength_mpa=45.0,
            thermal_range="-5°C to 60°C",
            sustainability_rating="100% Home Compostable",
            estimated_cost_inr=4.50,
            cost_tier="Moderate (₹₹)",
        )
        self.assertEqual(custom_chars.otr, "2,800 cc/m²/day")
        self.assertEqual(custom_chars.wvtr, "50.0 g/m²/day")
        self.assertEqual(custom_chars.thickness_microns, 30.0)
        self.assertEqual(custom_chars.estimated_cost_inr, 4.50)

    def test_packaging_alternative_schema_full_initialization(self):
        """Verify complete PackagingAlternativeSchema validation and attributes."""
        alt = PackagingAlternativeSchema(
            candidate_id="mat_natureflex_01",
            type="ECO_FRIENDLY",
            material_name="Cellulose Breathable Bio-Film (NatureFlex)",
            packaging_title="Heat-Sealed Bio-Pouch with Micro-Laser Vents",
            star_rating=4,
            star_display="★★★★☆",
            suitability_category=SuitabilityCategoryEnum.HIGH_COMPATIBILITY,
            model_derived_probability=0.86,
            compatibility_confidence="High Confidence (0.86)",
            characteristics=MaterialCharacteristicsSchema(
                otr="2,800 cc/m²/day",
                wvtr="50.0 g/m²/day",
                thickness_microns=30.0,
                tensile_strength_mpa=45.0,
                thermal_range="-5°C to 60°C",
                sustainability_rating="100% Home Compostable",
                estimated_cost_inr=4.50,
                cost_tier="Moderate (₹₹)",
            ),
            trade_off_summary="100% Home compostable with crystal optical clarity; +17% unit cost.",
            advantages=["100% bio-derived and marine degradable", "Excellent gas permselectivity"],
            limitations=["Slightly higher unit cost than fossil LDPE", "Moderate moisture barrier"],
            cost_delta_pct=16.88,
            eco_delta_pct=4.26,
            shelf_life_delta="Equal (21 days)",
        )

        data = alt.model_dump()
        self.assertEqual(data["candidate_id"], "mat_natureflex_01")
        self.assertEqual(data["star_rating"], 4)
        self.assertEqual(data["star_display"], "★★★★☆")
        self.assertEqual(data["suitability_category"], "High Compatibility")
        self.assertEqual(data["model_derived_probability"], 0.86)
        self.assertEqual(data["cost_delta_pct"], 16.88)
        self.assertEqual(len(data["advantages"]), 2)
        self.assertEqual(len(data["limitations"]), 2)

    def test_packaging_alternative_rating_bounds(self):
        """Verify star_rating enforces 1 to 5 bounds and model_derived_probability enforces 0.0 to 1.0."""
        # Valid bounds
        valid_alt = PackagingAlternativeSchema(
            type="ECONOMY",
            material_name="Macro-Perforated LDPE Poly-Bag",
            star_rating=3,
            star_display="★★★☆☆",
            model_derived_probability=0.72,
            trade_off_summary="49% Cost savings; standard mechanical recycling.",
        )
        self.assertEqual(valid_alt.star_rating, 3)

        # Invalid star rating > 5
        with self.assertRaises(ValueError):
            PackagingAlternativeSchema(
                type="ECONOMY",
                material_name="Invalid Rating",
                star_rating=6,
                trade_off_summary="Invalid",
            )

        # Invalid probability > 1.0
        with self.assertRaises(ValueError):
            PackagingAlternativeSchema(
                type="ECONOMY",
                material_name="Invalid Prob",
                model_derived_probability=1.5,
                trade_off_summary="Invalid",
            )

    def test_packaging_recommendation_result_with_multi_alternatives(self):
        """Verify PackagingRecommendationResult contains primary + multiple ranked alternatives."""
        barrier = BarrierProfileSchema(
            otr="3,500 cc/m²/day",
            wvtr="45.0 g/m²/day",
            thickness_microns=35.0,
            tensile_strength_mpa=42.0,
            puncture_resistance_n=28.0,
        )

        primary = PrimaryRecommendationSchema(
            material_name="Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)",
            material_type="Bio-Composite EMAP Film",
            polymer_family="BREATHABLE_BIO_EMAP",
            structure="Co-Extruded Vented Bio-Film",
            barrier_profile=barrier,
            sustainability_score=94.0,
            estimated_unit_cost_inr=3.85,
            suitability_score=0.94,
            packaging_title="Ventilated Food-Grade Packaging",
            packaging_format="Micro-Perforated Hinged Clamshell",
            recommendation_explanation="Optimal gas equilibrium for high respiration strawberries.",
        )

        alt1 = PackagingAlternativeSchema(
            candidate_id="mat_natureflex_01",
            type="ECO_FRIENDLY",
            material_name="Cellulose Breathable Bio-Film (NatureFlex)",
            packaging_title="Heat-Sealed Bio-Pouch",
            star_rating=4,
            star_display="★★★★☆",
            suitability_category=SuitabilityCategoryEnum.HIGH_COMPATIBILITY,
            model_derived_probability=0.86,
            trade_off_summary="100% Home compostable with crystal clarity; +17% unit cost.",
        )

        alt2 = PackagingAlternativeSchema(
            candidate_id="mat_ldpe_perf_02",
            type="ECONOMY",
            material_name="Macro-Perforated LDPE Poly-Bag",
            packaging_title="Punched-Hole Flexible Bag",
            star_rating=3,
            star_display="★★★☆☆",
            suitability_category=SuitabilityCategoryEnum.MODERATE_COMPATIBILITY,
            model_derived_probability=0.72,
            trade_off_summary="Lowest unit packaging cost; standard recycling.",
            cost_delta_pct=-49.35,
            eco_delta_pct=-34.04,
        )

        result = PackagingRecommendationResult(
            recommendation_id="rec_strawberries_001",
            primary_recommendation=primary,
            alternatives=[alt1, alt2],
            box_geometry=BoxGeometrySchema(
                length_cm=20.0,
                width_cm=14.0,
                height_cm=8.0,
                total_volume_cm3=2240.0,
                space_utilization_pct=78.5,
                cushioning_material="Cellulose Pulp Punched Tray",
            ),
            scientific_rationale=ScientificRationaleSchema(
                summary="Dynamic respiration equilibrium packaging.",
                key_drivers=["High respiration rate", "Condensation mitigation"],
            ),
            comparison_summary={
                "candidate_count": 3,
                "eco_champion": "Cellulose Breathable Bio-Film (NatureFlex)",
                "economy_option": "Macro-Perforated LDPE Poly-Bag",
            },
        )

        dumped = result.model_dump()
        self.assertEqual(len(dumped["alternatives"]), 2)
        self.assertEqual(dumped["alternatives"][0]["star_display"], "★★★★☆")
        self.assertEqual(dumped["alternatives"][1]["star_display"], "★★★☆☆")
        self.assertEqual(dumped["alternatives"][1]["cost_delta_pct"], -49.35)
        self.assertIsNotNone(dumped["comparison_summary"])


if __name__ == "__main__":
    unittest.main()
