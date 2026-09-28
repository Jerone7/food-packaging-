"""
Unit tests for Cost Estimation Service (Module 10 - Phase 2).
Tests polymer densities, material footprint requirements, cost itemization,
volume scaling discounts, and disclaimer notice generation.
"""

import unittest
from app.schemas.cost_estimation import (
    PackagingFormFactorEnum,
    FunctionalAddOnEnum,
    PackageDimensionsInput,
    CostEstimationRequest,
    PricingSourceEnum,
)
from app.services.cost_estimation_service import CostEstimationService


class TestCostEstimationService(unittest.TestCase):
    def test_polymer_density_lookups(self):
        """Test looking up empirical densities for various polymer materials."""
        self.assertEqual(CostEstimationService.get_polymer_density("LDPE Film"), 920.0)
        self.assertEqual(CostEstimationService.get_polymer_density("Bio-PLA Compostable"), 1250.0)
        self.assertEqual(CostEstimationService.get_polymer_density("NatureFlex Cellulose"), 1450.0)
        self.assertEqual(CostEstimationService.get_polymer_density("Al-Foil Barrier Laminate"), 2700.0)
        self.assertEqual(CostEstimationService.get_polymer_density("Kraft Paper Sack"), 750.0)
        self.assertEqual(CostEstimationService.get_polymer_density("Unknown Polymer"), 1000.0)

    def test_volume_discount_tiers(self):
        """Test volume discount percentage and tier labels."""
        # Tier 1: < 5,000
        disc, label = CostEstimationService.get_volume_discount_tier(1000)
        self.assertEqual(disc, 0.0)
        self.assertIn("Tier 1", label)

        # Tier 2: 5,000 - 24,999
        disc, label = CostEstimationService.get_volume_discount_tier(10000)
        self.assertEqual(disc, 8.0)
        self.assertIn("Tier 2", label)

        # Tier 3: 25,000 - 99,999
        disc, label = CostEstimationService.get_volume_discount_tier(50000)
        self.assertEqual(disc, 16.0)
        self.assertIn("Tier 3", label)

        # Tier 4: >= 100,000
        disc, label = CostEstimationService.get_volume_discount_tier(200000)
        self.assertEqual(disc, 24.0)
        self.assertIn("Tier 4", label)

    def test_calculate_material_requirements(self):
        """
        Test material requirements calculation for 10,000 Stand-up Doypack units:
        L=20cm, W=14cm, G=6cm, NatureFlex (density 1450 kg/m³, thickness 45µm).
        Unit Area = 0.075075 m²
        Thickness = 45 * 10^-6 m = 0.000045 m
        Unit Weight = 0.075075 * 0.000045 * 1450 = 0.004900 kg = 4.9004 g
        For 10,000 units with 6% scrap:
        Gross Area = 0.075075 * 10,000 * 1.06 = 795.80 m²
        Gross Weight = 4.9004g * 10,000 * 1.06 = 51.944 kg
        """
        dims = PackageDimensionsInput(
            length_cm=20.0,
            width_cm=14.0,
            depth_or_gusset_cm=6.0,
            thickness_microns=45.0,
        )
        req = CostEstimationService.calculate_material_requirements(
            packaging_type=PackagingFormFactorEnum.STAND_UP_DOYPACK,
            dimensions=dims,
            material_name="NatureFlex Cellulose",
            number_of_packages=10000,
            scrap_rate_percent=6.0,
        )

        self.assertAlmostEqual(req.surface_area_per_unit_sqm, 0.075075, places=5)
        self.assertAlmostEqual(req.weight_per_unit_grams, 4.9004, places=2)
        self.assertAlmostEqual(req.gross_area_required_sqm, 795.80, places=1)
        self.assertAlmostEqual(req.gross_weight_required_kg, 51.944, places=1)
        self.assertEqual(req.scrap_allowance_percent, 6.0)

    def test_full_cost_estimate_calculation(self):
        """
        Test full cost estimate with substrate, converting, add-ons, tooling amortization, and volume discount.
        """
        request = CostEstimationRequest(
            material_id="MAT_BIO_001",
            material_name="NatureFlex Cellulose",
            packaging_type=PackagingFormFactorEnum.STAND_UP_DOYPACK,
            dimensions=PackageDimensionsInput(
                length_cm=20.0,
                width_cm=14.0,
                depth_or_gusset_cm=6.0,
                thickness_microns=45.0,
            ),
            product_fill_quantity="500g",
            number_of_packages=10000,
            selected_addons=[
                FunctionalAddOnEnum.RESEALABLE_ZIPPER,
                FunctionalAddOnEnum.DEGASSING_VALVE,
            ],
            custom_material_cost_per_kg=420.0,
            custom_scrap_rate_percent=6.0,
            include_tooling_amortization=True,
        )

        response = CostEstimationService.calculate_cost_estimate(request)

        # Basic validations
        self.assertTrue(response.is_estimated)
        self.assertEqual(response.pricing_mode, PricingSourceEnum.ESTIMATED_MODEL)
        self.assertIn("ESTIMATED BASELINE", response.disclaimer_notice)
        self.assertEqual(response.number_of_packages, 10000)

        # Financial values should be positive and realistic
        self.assertGreater(response.cost_per_unit_inr, 0)
        self.assertGreater(response.total_estimated_cost_inr, 0)
        self.assertEqual(response.volume_discount_percent, 8.0) # 10k units is Tier 2

        # Subtotals should sum appropriately
        self.assertGreater(response.substrate_cost_subtotal_inr, 0)
        self.assertGreater(response.converting_cost_subtotal_inr, 0)
        self.assertGreater(response.addons_cost_subtotal_inr, 0)
        self.assertEqual(response.tooling_cost_subtotal_inr, 12000.0)

        # Add-ons total: (0.40 + 0.85) * 10,000 = 12,500.0 INR
        self.assertAlmostEqual(response.addons_cost_subtotal_inr, 12500.0, places=1)

        # Check breakdown items length: Substrate + Converting + 2 Add-ons + Tooling = 5
        self.assertEqual(len(response.cost_breakdown), 5)

        # Check sensitivity points: 5 volume points
        self.assertEqual(len(response.volume_tier_sensitivity), 5)
        # Unit cost should decrease as volume increases
        unit_costs = [p.cost_per_unit_inr for p in response.volume_tier_sensitivity]
        self.assertEqual(unit_costs, sorted(unit_costs, reverse=True))

    def test_cost_estimate_without_tooling_amortization(self):
        """Test estimation when tooling amortization is excluded."""
        request = CostEstimationRequest(
            material_name="LDPE Polyethylene",
            packaging_type=PackagingFormFactorEnum.PILLOW_POUCH,
            dimensions=PackageDimensionsInput(length_cm=15.0, width_cm=10.0),
            number_of_packages=5000,
            include_tooling_amortization=False,
        )
        response = CostEstimationService.calculate_cost_estimate(request)
        self.assertEqual(response.tooling_cost_subtotal_inr, 0.0)


if __name__ == "__main__":
    unittest.main()
