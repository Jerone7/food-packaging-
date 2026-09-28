"""
Unit tests for Sustainability Analysis Schemas (Module 11 - Task 1.1).
Validates enum definitions, input validations, nested schemas, default values,
and serialization/deserialization integrity.
"""

import unittest
from pydantic import ValidationError

from app.schemas.sustainability import (
    RecyclabilityTier,
    BiodegradabilityTier,
    ReusabilityTier,
    WastePotentialLevel,
    SustainabilityEvaluateRequest,
    EnvironmentalIndicatorSchema,
    PackagingWasteSchema,
    SustainabilityProfileResponse,
    SustainabilityCompareRequest,
    SustainabilityCompareResponse,
)


class TestSustainabilitySchemas(unittest.TestCase):
    """Test suite verifying Sustainability Pydantic v2 schemas."""

    def test_enums_definition(self):
        """Verify all tier enums contain required classification values."""
        self.assertEqual(RecyclabilityTier.HIGH.value, "High")
        self.assertEqual(RecyclabilityTier.MEDIUM.value, "Medium")
        self.assertEqual(RecyclabilityTier.LOW.value, "Low")
        self.assertEqual(RecyclabilityTier.NON_RECYCLABLE.value, "Non-Recyclable")

        self.assertEqual(BiodegradabilityTier.HIGH.value, "High")
        self.assertEqual(BiodegradabilityTier.MEDIUM.value, "Medium")
        self.assertEqual(BiodegradabilityTier.LOW.value, "Low")
        self.assertEqual(BiodegradabilityTier.NON_BIODEGRADABLE.value, "Non-Biodegradable")

        self.assertEqual(ReusabilityTier.HIGH.value, "High")
        self.assertEqual(ReusabilityTier.MEDIUM.value, "Medium")
        self.assertEqual(ReusabilityTier.LOW.value, "Low")
        self.assertEqual(ReusabilityTier.SINGLE_USE.value, "Single-Use")

        self.assertEqual(WastePotentialLevel.VERY_LOW.value, "Very Low")
        self.assertEqual(WastePotentialLevel.HIGH.value, "High")

    def test_sustainability_evaluate_request_defaults(self):
        """Verify defaults and validations for evaluate request."""
        req = SustainabilityEvaluateRequest(material_id="mat_pe_ldpe_01")
        self.assertEqual(req.material_id, "mat_pe_ldpe_01")
        self.assertEqual(req.batch_size_units, 10000)
        self.assertEqual(req.length_cm, 18.0)
        self.assertEqual(req.width_cm, 12.0)
        self.assertEqual(req.depth_or_gusset_cm, 4.0)
        self.assertEqual(req.thickness_microns, 50.0)
        self.assertEqual(req.pcr_percentage, 0.0)

    def test_sustainability_evaluate_request_validation_failures(self):
        """Verify validation errors on invalid values."""
        # Batch size too low (<100)
        with self.assertRaises(ValidationError):
            SustainabilityEvaluateRequest(material_id="mat_1", batch_size_units=50)

        # Negative length
        with self.assertRaises(ValidationError):
            SustainabilityEvaluateRequest(material_id="mat_1", length_cm=-5.0)

        # Invalid PCR percentage (>100)
        with self.assertRaises(ValidationError):
            SustainabilityEvaluateRequest(material_id="mat_1", pcr_percentage=120.0)

    def test_environmental_indicator_schema(self):
        """Verify EnvironmentalIndicatorSchema instantiates correctly."""
        indicators = EnvironmentalIndicatorSchema(
            carbon_footprint_kg_co2e_per_unit=0.0245,
            carbon_footprint_kg_co2e_total_batch=245.0,
            water_footprint_liters_per_unit=0.82,
            water_footprint_liters_total_batch=8200.0,
            pcr_carbon_reduction_pct=28.4,
            embodied_energy_mj_per_kg=78.5,
        )
        self.assertAlmostEqual(indicators.carbon_footprint_kg_co2e_per_unit, 0.0245)
        self.assertAlmostEqual(indicators.pcr_carbon_reduction_pct, 28.4)

    def test_packaging_waste_schema(self):
        """Verify PackagingWasteSchema bounds and properties."""
        waste = PackagingWasteSchema(
            unit_waste_grams=12.4,
            total_batch_waste_kg=124.0,
            waste_potential_level=WastePotentialLevel.LOW,
            landfill_burden_kg=18.6,
            diversion_potential_pct=85.0,
            circularity_index=0.76,
            primary_disposal_pathway="Curbside Mechanical Recycling",
        )
        self.assertEqual(waste.waste_potential_level, WastePotentialLevel.LOW)
        self.assertAlmostEqual(waste.circularity_index, 0.76)

        # Circularity index > 1.0 should fail validation
        with self.assertRaises(ValidationError):
            PackagingWasteSchema(
                unit_waste_grams=12.4,
                total_batch_waste_kg=124.0,
                waste_potential_level=WastePotentialLevel.LOW,
                landfill_burden_kg=18.6,
                diversion_potential_pct=85.0,
                circularity_index=1.5,
                primary_disposal_pathway="Curbside Mechanical Recycling",
            )

    def test_sustainability_profile_response(self):
        """Verify full SustainabilityProfileResponse master schema."""
        profile = SustainabilityProfileResponse(
            material_id="mat_pe_hdpe_02",
            material_name="High-Density Polyethylene (HDPE)",
            category="Conventional Polymer",
            polymer_family="RIGID_POLYMER",
            resin_identification_code="RIC 2",
            recyclability=RecyclabilityTier.HIGH,
            recyclability_notes="Extensively recycled globally in standard rigid plastics collection stream #2.",
            biodegradability=BiodegradabilityTier.NON_BIODEGRADABLE,
            biodegradability_standard=None,
            biodegradability_notes="Fossil-based polyolefin. Does not biodegrade in ambient or industrial compost.",
            reusability=ReusabilityTier.HIGH,
            reusability_cycles=30,
            material_type_description="Semi-crystalline thermoplastic polymer with high strength-to-density ratio.",
            pcr_content_pct=30.0,
            bio_based_content_pct=0.0,
            environmental_considerations=["Avoid carbon black pigmentation to ensure NIR optical sortability."],
            regulatory_certifications=["FDA 21 CFR 177.1520", "FSSAI IS 9845"],
            environmental_indicators=EnvironmentalIndicatorSchema(
                carbon_footprint_kg_co2e_per_unit=0.0192,
                carbon_footprint_kg_co2e_total_batch=192.0,
                water_footprint_liters_per_unit=0.65,
                water_footprint_liters_total_batch=6500.0,
                pcr_carbon_reduction_pct=22.5,
                embodied_energy_mj_per_kg=76.2,
            ),
            waste_potential=PackagingWasteSchema(
                unit_waste_grams=10.0,
                total_batch_waste_kg=100.0,
                waste_potential_level=WastePotentialLevel.LOW,
                landfill_burden_kg=15.0,
                diversion_potential_pct=85.0,
                circularity_index=0.82,
                primary_disposal_pathway="Curbside Rigid Plastic Bin (#2)",
            ),
            verified_data_source="PlasticsEurope Eco-Profiles & Franklin Associates LCA (2021)",
            source_doi_or_standard="10.1016/j.jclepro.2020.124500",
            is_empirical_verified=True,
        )

        self.assertEqual(profile.material_id, "mat_pe_hdpe_02")
        self.assertEqual(profile.recyclability, RecyclabilityTier.HIGH)
        self.assertEqual(profile.reusability_cycles, 30)
        self.assertTrue(profile.is_empirical_verified)

    def test_sustainability_compare_schemas(self):
        """Verify SustainabilityCompareRequest and SustainabilityCompareResponse."""
        req = SustainabilityCompareRequest(
            material_ids=["mat_pe_ldpe_01", "mat_bio_pla_06"],
            package_type="Pillow Pouch",
            length_cm=15.0,
            width_cm=10.0,
            depth_or_gusset_cm=0.0,
            thickness_microns=40.0,
            batch_size_units=5000,
        )
        self.assertEqual(len(req.material_ids), 2)

        # Less than 2 materials should fail
        with self.assertRaises(ValidationError):
            SustainabilityCompareRequest(material_ids=["mat_pe_ldpe_01"])

        # More than 4 materials should fail
        with self.assertRaises(ValidationError):
            SustainabilityCompareRequest(
                material_ids=["mat_1", "mat_2", "mat_3", "mat_4", "mat_5"]
            )


if __name__ == "__main__":
    unittest.main()
