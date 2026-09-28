"""
Unit tests for Sustainability Service (Module 11 - Tasks 2.1 & 2.2).
Validates mathematical calculations for GWP carbon footprint, freshwater consumption,
PCR carbon abatement, solid waste mass, landfill burden, circularity indexing,
and multi-material trade-off comparisons.
"""

import unittest
from app.services.sustainability_service import SustainabilityService
from app.schemas.sustainability import (
    SustainabilityEvaluateRequest,
    SustainabilityCompareRequest,
    RecyclabilityTier,
    BiodegradabilityTier,
    ReusabilityTier,
    WastePotentialLevel,
)


class TestSustainabilityService(unittest.TestCase):
    """Test suite verifying SustainabilityService domain logic and mathematical calculations."""

    def test_evaluate_sustainability_ldpe_baseline(self):
        """Verify baseline evaluation for conventional LDPE pouch."""
        request = SustainabilityEvaluateRequest(
            material_id="mat_poly_ldpe_01",
            package_type="Stand-up Doypack (Bottom Gusset)",
            length_cm=18.0,
            width_cm=12.0,
            depth_or_gusset_cm=4.0,
            thickness_microns=50.0,
            batch_size_units=10000,
            pcr_percentage=0.0,
        )

        profile = SustainabilityService.evaluate_sustainability(request)
        self.assertEqual(profile.material_id, "mat_poly_ldpe_01")
        self.assertEqual(profile.recyclability, RecyclabilityTier.MEDIUM)
        self.assertEqual(profile.biodegradability, BiodegradabilityTier.NON_BIODEGRADABLE)
        self.assertEqual(profile.reusability, ReusabilityTier.LOW)

        # Waste and mass metrics
        self.assertGreater(profile.waste_potential.unit_waste_grams, 0.5)
        self.assertGreater(profile.waste_potential.total_batch_waste_kg, 5.0)
        self.assertEqual(profile.waste_potential.diversion_potential_pct, 65.0)

        # Carbon metrics
        self.assertGreater(profile.environmental_indicators.carbon_footprint_kg_co2e_per_unit, 0.0)
        self.assertGreater(profile.environmental_indicators.carbon_footprint_kg_co2e_total_batch, 0.0)
        self.assertEqual(profile.environmental_indicators.pcr_carbon_reduction_pct, 0.0)

    def test_pcr_carbon_abatement_calculation(self):
        """Verify that adding PCR reduces carbon footprint and computes reduction %."""
        # 0% PCR request
        req_virgin = SustainabilityEvaluateRequest(
            material_id="mat_poly_hdpe_02",
            package_type="Stand-up Doypack (Bottom Gusset)",
            length_cm=20.0,
            width_cm=15.0,
            depth_or_gusset_cm=5.0,
            thickness_microns=60.0,
            batch_size_units=10000,
            pcr_percentage=0.0,
        )
        res_virgin = SustainabilityService.evaluate_sustainability(req_virgin)

        # 50% PCR request
        req_pcr = SustainabilityEvaluateRequest(
            material_id="mat_poly_hdpe_02",
            package_type="Stand-up Doypack (Bottom Gusset)",
            length_cm=20.0,
            width_cm=15.0,
            depth_or_gusset_cm=5.0,
            thickness_microns=60.0,
            batch_size_units=10000,
            pcr_percentage=50.0,
        )
        res_pcr = SustainabilityService.evaluate_sustainability(req_pcr)

        # PCR should reduce total carbon
        self.assertLess(
            res_pcr.environmental_indicators.carbon_footprint_kg_co2e_total_batch,
            res_virgin.environmental_indicators.carbon_footprint_kg_co2e_total_batch,
        )
        self.assertGreater(res_pcr.environmental_indicators.pcr_carbon_reduction_pct, 15.0)
        # Circularity should increase
        self.assertGreater(
            res_pcr.waste_potential.circularity_index,
            res_virgin.waste_potential.circularity_index,
        )

    def test_biodegradable_cellulose_profile(self):
        """Verify NatureFlex biodegradable evaluation."""
        request = SustainabilityEvaluateRequest(
            material_id="mat_cell_natureflex_02",
            package_type="Pillow Pouch",
            length_cm=15.0,
            width_cm=10.0,
            depth_or_gusset_cm=0.0,
            thickness_microns=28.0,
            batch_size_units=5000,
        )
        profile = SustainabilityService.evaluate_sustainability(request)
        self.assertEqual(profile.biodegradability, BiodegradabilityTier.HIGH)
        self.assertTrue(
            "NF T 51-800" in (profile.biodegradability_standard or "")
            or "Compost Home" in (profile.biodegradability_standard or "")
        )
        self.assertEqual(profile.waste_potential.diversion_potential_pct, 95.0)
        self.assertEqual(profile.waste_potential.waste_potential_level, WastePotentialLevel.VERY_LOW)

    def test_high_barrier_foil_profile(self):
        """Verify Aluminium Foil laminate non-recyclable high-carbon profile."""
        request = SustainabilityEvaluateRequest(
            material_id="mat_lam_foil_06",
            package_type="3-Side Seal Pouch",
            length_cm=18.0,
            width_cm=12.0,
            thickness_microns=70.0,
            batch_size_units=10000,
        )
        profile = SustainabilityService.evaluate_sustainability(request)
        self.assertEqual(profile.recyclability, RecyclabilityTier.NON_RECYCLABLE)
        self.assertEqual(profile.waste_potential.waste_potential_level, WastePotentialLevel.VERY_HIGH)
        self.assertGreater(profile.environmental_indicators.carbon_footprint_kg_co2e_per_unit, 0.05)

    def test_compare_sustainability_multi_material(self):
        """Verify side-by-side multi-material comparison."""
        req = SustainabilityCompareRequest(
            material_ids=["mat_poly_ldpe_01", "mat_bio_emap_01", "mat_rpet_50_05"],
            package_type="Stand-up Doypack (Bottom Gusset)",
            length_cm=18.0,
            width_cm=12.0,
            depth_or_gusset_cm=4.0,
            thickness_microns=50.0,
            batch_size_units=10000,
        )
        resp = SustainabilityService.compare_sustainability(req)
        self.assertEqual(len(resp.materials), 3)
        self.assertTrue(resp.best_recyclability_material_id in req.material_ids)
        self.assertTrue(resp.lowest_carbon_material_id in req.material_ids)
        self.assertTrue(resp.lowest_waste_material_id in req.material_ids)
        self.assertTrue(len(resp.eco_tradeoff_summary) > 20)


if __name__ == "__main__":
    unittest.main()
