"""
Unit tests for Cost Estimation Pydantic Schemas (Module 10 - Task 1.1).
Verifies data contracts, serialization, enums, boundary validations, and default fallbacks.
"""

import unittest
from pydantic import ValidationError
from app.schemas.cost_estimation import (
    PackagingFormFactorEnum,
    FunctionalAddOnEnum,
    PricingSourceEnum,
    PackageDimensionsInput,
    MaterialRequirementDetail,
    CostLayerItem,
    VolumeTierSensitivityPoint,
    CostEstimationRequest,
    CostEstimationResponse,
)


class TestCostEstimationSchemas(unittest.TestCase):
    def setUp(self):
        self.valid_dimensions = PackageDimensionsInput(
            length_cm=20.0,
            width_cm=14.0,
            depth_or_gusset_cm=6.0,
            thickness_microns=45.0,
        )

        self.valid_request_data = {
            "material_id": "MAT_BIO_001",
            "material_name": "NatureFlex Regenerated Cellulose",
            "packaging_type": PackagingFormFactorEnum.STAND_UP_DOYPACK,
            "dimensions": self.valid_dimensions,
            "product_fill_quantity": "500g",
            "number_of_packages": 10000,
            "selected_addons": [
                FunctionalAddOnEnum.RESEALABLE_ZIPPER,
                FunctionalAddOnEnum.DEGASSING_VALVE,
            ],
            "custom_material_cost_per_kg": 420.0,
            "custom_scrap_rate_percent": 6.0,
            "include_tooling_amortization": True,
        }

    def test_valid_request_creation(self):
        """Test creating a valid CostEstimationRequest object."""
        req = CostEstimationRequest(**self.valid_request_data)
        self.assertEqual(req.material_name, "NatureFlex Regenerated Cellulose")
        self.assertEqual(req.packaging_type, PackagingFormFactorEnum.STAND_UP_DOYPACK)
        self.assertEqual(req.number_of_packages, 10000)
        self.assertEqual(len(req.selected_addons), 2)
        self.assertTrue(req.include_tooling_amortization)

    def test_dimensions_boundary_validation(self):
        """Test that non-positive dimensions raise a validation error."""
        # Non-positive length
        with self.assertRaises(ValidationError):
            PackageDimensionsInput(length_cm=0.0, width_cm=10.0)

        with self.assertRaises(ValidationError):
            PackageDimensionsInput(length_cm=-5.0, width_cm=10.0)

        # Non-positive width
        with self.assertRaises(ValidationError):
            PackageDimensionsInput(length_cm=10.0, width_cm=-1.0)

        # Negative depth
        with self.assertRaises(ValidationError):
            PackageDimensionsInput(length_cm=10.0, width_cm=10.0, depth_or_gusset_cm=-2.0)

    def test_request_number_of_packages_boundary(self):
        """Test that number of packages must be greater than zero."""
        data = self.valid_request_data.copy()
        data["number_of_packages"] = 0
        with self.assertRaises(ValidationError):
            CostEstimationRequest(**data)

        data["number_of_packages"] = -500
        with self.assertRaises(ValidationError):
            CostEstimationRequest(**data)

    def test_scrap_rate_boundary(self):
        """Test custom scrap rate percent upper and lower limits."""
        data = self.valid_request_data.copy()
        data["custom_scrap_rate_percent"] = 35.0  # Exceeds max 30%
        with self.assertRaises(ValidationError):
            CostEstimationRequest(**data)

        data["custom_scrap_rate_percent"] = -1.0  # Negative
        with self.assertRaises(ValidationError):
            CostEstimationRequest(**data)

    def test_all_form_factor_enums(self):
        """Verify all 7 packaging form factor enums are defined."""
        expected_factors = {
            "Pillow Pouch",
            "Stand-up Doypack",
            "3-Side Seal Pouch",
            "4-Side Quad Seal",
            "Thermoformed Tray / Clamshell",
            "Vacuum / Retort Pouch",
            "Folding Carton Box",
        }
        enum_values = {f.value for f in PackagingFormFactorEnum}
        self.assertEqual(expected_factors, enum_values)

    def test_all_addon_enums(self):
        """Verify functional add-on enums."""
        expected_addons = {
            "Resealable Zipper",
            "One-Way Degassing Valve",
            "Laser Tear Notch",
            "Anti-Fog Coating",
            "Laser Micro-Perforations",
            "MAP Gas Flush Seal",
        }
        enum_values = {a.value for a in FunctionalAddOnEnum}
        self.assertEqual(expected_addons, enum_values)

    def test_cost_estimation_response_structure(self):
        """Test creating and serializing a full CostEstimationResponse."""
        mat_req = MaterialRequirementDetail(
            surface_area_per_unit_sqm=0.064,
            weight_per_unit_grams=4.15,
            gross_area_required_sqm=678.4,
            gross_weight_required_kg=43.99,
            scrap_allowance_percent=6.0,
            scrap_material_weight_kg=2.49,
        )

        cost_layers = [
            CostLayerItem(
                category="Substrate",
                item_name="Raw NatureFlex Polymer",
                cost_per_unit_inr=1.85,
                total_cost_inr=18500.0,
                percentage_of_total=40.2,
            ),
            CostLayerItem(
                category="Converting",
                item_name="Printing & Lamination",
                cost_per_unit_inr=1.35,
                total_cost_inr=13500.0,
                percentage_of_total=29.3,
            ),
            CostLayerItem(
                category="Add-on",
                item_name="Resealable Zipper + Valve",
                cost_per_unit_inr=1.25,
                total_cost_inr=12500.0,
                percentage_of_total=27.2,
            ),
            CostLayerItem(
                category="Tooling",
                item_name="Setup Cylinder Amortization",
                cost_per_unit_inr=0.15,
                total_cost_inr=1500.0,
                percentage_of_total=3.3,
            ),
        ]

        sensitivity_points = [
            VolumeTierSensitivityPoint(
                tier_label="1k Units",
                order_volume=1000,
                cost_per_unit_inr=6.80,
                total_cost_inr=6800.0,
                discount_percent=0.0,
            ),
            VolumeTierSensitivityPoint(
                tier_label="10k Units",
                order_volume=10000,
                cost_per_unit_inr=4.60,
                total_cost_inr=46000.0,
                discount_percent=8.0,
            ),
            VolumeTierSensitivityPoint(
                tier_label="100k Units",
                order_volume=100000,
                cost_per_unit_inr=3.50,
                total_cost_inr=350000.0,
                discount_percent=24.0,
            ),
        ]

        response = CostEstimationResponse(
            material_id="MAT_BIO_001",
            material_name="NatureFlex Regenerated Cellulose",
            packaging_type=PackagingFormFactorEnum.STAND_UP_DOYPACK,
            number_of_packages=10000,
            product_fill_quantity="500g",
            material_requirement=mat_req,
            cost_per_unit_inr=4.60,
            total_estimated_cost_inr=46000.0,
            cost_breakdown=cost_layers,
            substrate_cost_subtotal_inr=18500.0,
            converting_cost_subtotal_inr=13500.0,
            addons_cost_subtotal_inr=12500.0,
            tooling_cost_subtotal_inr=1500.0,
            volume_discount_amount_inr=4000.0,
            volume_discount_percent=8.0,
            volume_tier_sensitivity=sensitivity_points,
            pricing_mode=PricingSourceEnum.ESTIMATED_MODEL,
            is_estimated=True,
        )

        self.assertTrue(response.is_estimated)
        self.assertIn("ESTIMATED BASELINE", response.disclaimer_notice)
        self.assertEqual(response.cost_per_unit_inr, 4.60)
        self.assertEqual(len(response.cost_breakdown), 4)
        self.assertEqual(len(response.volume_tier_sensitivity), 3)

        # Test dictionary export & re-parsing
        json_data = response.model_dump()
        reparsed = CostEstimationResponse(**json_data)
        self.assertEqual(reparsed.total_estimated_cost_inr, 46000.0)


if __name__ == "__main__":
    unittest.main()
