"""
Unit tests for Geometry Calculator (Module 10 - Task 1.2).
Verifies geometric surface area formulas across all 7 form factors and conversion helpers.
"""

import unittest
from app.schemas.cost_estimation import PackagingFormFactorEnum, PackageDimensionsInput
from app.services.geometry_calculator import GeometryCalculator


class TestGeometryCalculator(unittest.TestCase):
    def test_pillow_pouch_calculation(self):
        """
        Pillow Pouch: L=20cm (0.20m), W=14cm (0.14m), S=0.01m
        Formula: 2 * (L + 2S) * (W + S)
        Expected: 2 * (0.20 + 0.02) * (0.14 + 0.01) = 2 * 0.22 * 0.15 = 0.0660 m²
        """
        dims = PackageDimensionsInput(length_cm=20.0, width_cm=14.0)
        area_sqm = GeometryCalculator.calculate_surface_area(PackagingFormFactorEnum.PILLOW_POUCH, dims)
        self.assertAlmostEqual(area_sqm, 0.0660, places=4)

    def test_stand_up_doypack_calculation(self):
        """
        Stand-up Doypack: L=20cm (0.20m), W=14cm (0.14m), G=6cm (0.06m), S=0.01m
        Main Panels: 2 * (0.20 + 0.01) * (0.14 + 0.01) = 2 * 0.21 * 0.15 = 0.0630 m²
        Bottom Gusset: (0.14 + 0.01) * (0.06 + 0.01) * 1.15 = 0.15 * 0.07 * 1.15 = 0.012075 m²
        Total: 0.0630 + 0.012075 = 0.075075 m²
        """
        dims = PackageDimensionsInput(length_cm=20.0, width_cm=14.0, depth_or_gusset_cm=6.0)
        area_sqm = GeometryCalculator.calculate_surface_area(PackagingFormFactorEnum.STAND_UP_DOYPACK, dims)
        self.assertAlmostEqual(area_sqm, 0.075075, places=5)

    def test_three_side_seal_calculation(self):
        """
        3-Side Seal: L=18cm (0.18m), W=12cm (0.12m), S=0.01m
        Formula: 2 * (L + S) * (W + 2S)
        Expected: 2 * (0.18 + 0.01) * (0.12 + 0.02) = 2 * 0.19 * 0.14 = 0.0532 m²
        """
        dims = PackageDimensionsInput(length_cm=18.0, width_cm=12.0)
        area_sqm = GeometryCalculator.calculate_surface_area(PackagingFormFactorEnum.THREE_SIDE_SEAL, dims)
        self.assertAlmostEqual(area_sqm, 0.0532, places=4)

    def test_four_side_quad_seal_calculation(self):
        """
        4-Side Quad Seal: L=25cm (0.25m), W=10cm (0.10m), G=5cm (0.05m), S=0.01m
        Formula: 2 * (L + 2S) * (W + 2G + 2S)
        Expected: 2 * (0.25 + 0.02) * (0.10 + 0.10 + 0.02) = 2 * 0.27 * 0.22 = 0.1188 m²
        """
        dims = PackageDimensionsInput(length_cm=25.0, width_cm=10.0, depth_or_gusset_cm=5.0)
        area_sqm = GeometryCalculator.calculate_surface_area(PackagingFormFactorEnum.FOUR_SIDE_QUAD_SEAL, dims)
        self.assertAlmostEqual(area_sqm, 0.1188, places=4)

    def test_thermoformed_tray_calculation(self):
        """
        Tray: L=20cm (0.20m), W=15cm (0.15m), H=5cm (0.05m), Factor=1.12
        Box Area = (0.20*0.15) + 2*(0.20*0.05) + 2*(0.15*0.05) = 0.03 + 0.02 + 0.015 = 0.065 m²
        Total: 0.065 * 1.12 = 0.0728 m²
        """
        dims = PackageDimensionsInput(length_cm=20.0, width_cm=15.0, depth_or_gusset_cm=5.0)
        area_sqm = GeometryCalculator.calculate_surface_area(PackagingFormFactorEnum.THERMOFORMED_TRAY, dims)
        self.assertAlmostEqual(area_sqm, 0.0728, places=4)

    def test_vacuum_retort_pouch_calculation(self):
        """
        Vacuum Retort Pouch: L=22cm (0.22m), W=16cm (0.16m), S=0.01m
        Formula: 2 * (L + 2S) * (W + 2S)
        Expected: 2 * (0.22 + 0.02) * (0.16 + 0.02) = 2 * 0.24 * 0.18 = 0.0864 m²
        """
        dims = PackageDimensionsInput(length_cm=22.0, width_cm=16.0)
        area_sqm = GeometryCalculator.calculate_surface_area(PackagingFormFactorEnum.VACUUM_RETORT_POUCH, dims)
        self.assertAlmostEqual(area_sqm, 0.0864, places=4)

    def test_folding_carton_calculation(self):
        """
        Folding Carton: L=15cm (0.15m), W=10cm (0.10m), H=6cm (0.06m), Multiplier=1.22
        6 Faces: 2 * [(0.15*0.10) + (0.15*0.06) + (0.10*0.06)] = 2 * [0.015 + 0.009 + 0.006] = 2 * 0.030 = 0.060 m²
        Total: 0.060 * 1.22 = 0.0732 m²
        """
        dims = PackageDimensionsInput(length_cm=15.0, width_cm=10.0, depth_or_gusset_cm=6.0)
        area_sqm = GeometryCalculator.calculate_surface_area(PackagingFormFactorEnum.FOLDING_CARTON, dims)
        self.assertAlmostEqual(area_sqm, 0.0732, places=4)

    def test_unit_conversion_helpers(self):
        """Test sqm_to_sqcm and sqcm_to_sqm conversion methods."""
        sqm = 0.075
        sqcm = GeometryCalculator.sqm_to_sqcm(sqm)
        self.assertEqual(sqcm, 750.0)

        converted_back = GeometryCalculator.sqcm_to_sqm(sqcm)
        self.assertEqual(converted_back, 0.075)


if __name__ == "__main__":
    unittest.main()
