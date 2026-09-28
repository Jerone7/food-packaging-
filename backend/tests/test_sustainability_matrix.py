"""
Unit tests for Empirical Sustainability Matrix (Module 11 - Task 1.2).
Validates matrix integrity, verified scientific sources, non-zero LCA factors,
exact ID lookups, and keyword matching heuristics.
"""

import unittest
from app.core.sustainability_matrix import (
    VERIFIED_SUSTAINABILITY_MATRIX,
    DEFAULT_SUSTAINABILITY_FALLBACK,
    get_sustainability_matrix_entry,
    SustainabilityMatrixEntry,
)
from app.schemas.sustainability import (
    RecyclabilityTier,
    BiodegradabilityTier,
    ReusabilityTier,
)


class TestSustainabilityMatrix(unittest.TestCase):
    """Test suite verifying empirical sustainability matrix dataset."""

    def test_matrix_contains_core_materials(self):
        """Verify that matrix contains key material identifiers."""
        self.assertIn("mat_bio_emap_01", VERIFIED_SUSTAINABILITY_MATRIX)
        self.assertIn("mat_cell_natureflex_02", VERIFIED_SUSTAINABILITY_MATRIX)
        self.assertIn("mat_poly_ldpe_01", VERIFIED_SUSTAINABILITY_MATRIX)
        self.assertIn("mat_poly_hdpe_02", VERIFIED_SUSTAINABILITY_MATRIX)
        self.assertIn("mat_bopp_film_03", VERIFIED_SUSTAINABILITY_MATRIX)
        self.assertIn("mat_pet_bo_04", VERIFIED_SUSTAINABILITY_MATRIX)
        self.assertIn("mat_rpet_50_05", VERIFIED_SUSTAINABILITY_MATRIX)
        self.assertIn("mat_lam_foil_06", VERIFIED_SUSTAINABILITY_MATRIX)
        self.assertIn("mat_board_fsc_07", VERIFIED_SUSTAINABILITY_MATRIX)

    def test_matrix_entry_lca_coefficients_validity(self):
        """Verify every entry in the matrix has non-zero positive LCA coefficients."""
        for mat_id, entry in VERIFIED_SUSTAINABILITY_MATRIX.items():
            self.assertIsInstance(entry, SustainabilityMatrixEntry)
            self.assertGreater(entry.gwp_virgin_kg_co2e_per_kg, 0.0, f"Virgin GWP zero for {mat_id}")
            self.assertGreater(entry.water_intensity_l_per_kg, 0.0, f"Water intensity zero for {mat_id}")
            self.assertGreater(entry.embodied_energy_mj_per_kg, 0.0, f"Embodied energy zero for {mat_id}")
            self.assertGreater(entry.reusability_cycles, 0, f"Reusability cycles zero for {mat_id}")
            self.assertTrue(entry.is_empirical_verified, f"Provenance flag missing for {mat_id}")
            self.assertTrue(len(entry.verified_data_source) > 5, f"Data source missing for {mat_id}")
            self.assertTrue(len(entry.source_doi_or_standard) > 3, f"Source standard/DOI missing for {mat_id}")

    def test_lookup_exact_and_case_insensitive(self):
        """Verify exact ID lookups."""
        entry = get_sustainability_matrix_entry("mat_cell_natureflex_02")
        self.assertEqual(entry.material_id, "mat_cell_natureflex_02")
        self.assertEqual(entry.biodegradability, BiodegradabilityTier.HIGH)
        self.assertEqual(entry.reusability, ReusabilityTier.SINGLE_USE)

        entry_upper = get_sustainability_matrix_entry("MAT_POLY_HDPE_02")
        self.assertEqual(entry_upper.material_id, "mat_poly_hdpe_02")
        self.assertEqual(entry_upper.recyclability, RecyclabilityTier.HIGH)

    def test_lookup_fuzzy_and_heuristics(self):
        """Verify keyword matching for common trade/chemical names."""
        # PLA lookup
        pla_entry = get_sustainability_matrix_entry("Bio-PLA Standup Pouch")
        self.assertEqual(pla_entry.material_id, "mat_bio_emap_01")
        self.assertEqual(pla_entry.biodegradability, BiodegradabilityTier.MEDIUM)

        # rPET lookup
        rpet_entry = get_sustainability_matrix_entry("Recycled PET 50% bottle")
        self.assertEqual(rpet_entry.material_id, "mat_rpet_50_05")
        self.assertEqual(rpet_entry.recyclability, RecyclabilityTier.HIGH)

        # Foil laminate lookup
        foil_entry = get_sustainability_matrix_entry("Aluminium Foil Laminate")
        self.assertEqual(foil_entry.material_id, "mat_lam_foil_06")
        self.assertEqual(foil_entry.recyclability, RecyclabilityTier.NON_RECYCLABLE)

    def test_lookup_fallback_on_unknown(self):
        """Verify fallback behavior for unknown materials."""
        entry = get_sustainability_matrix_entry("xyz_completely_unknown_material_999")
        self.assertEqual(entry.material_id, DEFAULT_SUSTAINABILITY_FALLBACK.material_id)
        self.assertTrue(entry.is_empirical_verified)

    def test_to_dict_serialization(self):
        """Verify dataclass dictionary conversion."""
        entry = VERIFIED_SUSTAINABILITY_MATRIX["mat_poly_ldpe_01"]
        d = entry.to_dict()
        self.assertEqual(d["material_id"], "mat_poly_ldpe_01")
        self.assertEqual(d["recyclability"], RecyclabilityTier.MEDIUM)
        self.assertIn("environmental_considerations", d)


if __name__ == "__main__":
    unittest.main()
