"""
Unit test suite for Packaging Material Catalog & 12-Property Specifications Matrix.
Tests verification of 32 empirical materials, empirical boundary conditions,
6-axis radar calculation, filtering, search, and category grouping.
"""

import unittest
from app.core.material_catalog import PACKAGING_CATALOG, MaterialCatalogService, material_catalog, MaterialSpecification
from app.schemas.packaging_material import PackagingMaterialDetailResponse


class TestPackagingMaterialCatalog(unittest.TestCase):
    """Verifies catalog depth, physical realism, and service logic."""

    def setUp(self):
        self.service = MaterialCatalogService()

    def test_catalog_contains_at_least_30_materials(self):
        """Verify the empirical matrix contains 30+ distinct packaging materials."""
        materials = self.service.get_all_materials()
        self.assertGreaterEqual(len(materials), 30)
        # Verify unique IDs
        ids = [m.material_id for m in materials]
        self.assertEqual(len(ids), len(set(ids)), "All material_ids must be unique")

    def test_material_domains_coverage(self):
        """Ensure coverage across all essential packaging material domains."""
        categories = {m.category for m in self.service.get_all_materials()}
        expected_categories = [
            "Conventional Polymer",
            "High-Barrier Laminate",
            "Biodegradable Bio-Polymer",
            "Cellulosic & Fiber Board",
            "Vacuum & Cryogenic",
            "Retort Barrier",
            "Rigid Inert Glass & Metal",
        ]
        for cat in expected_categories:
            self.assertTrue(
                any(cat.lower() in c.lower() for c in categories),
                f"Missing coverage for category domain: {cat}"
            )

    def test_physical_boundary_conditions(self):
        """Ensure all materials adhere to physical boundaries and empirical consistency."""
        for m in self.service.get_all_materials():
            with self.subTest(material=m.material_id):
                # Permeability boundaries
                self.assertGreaterEqual(m.otr_cc_m2_day, 0.0, f"OTR must be >= 0 for {m.material_id}")
                self.assertGreaterEqual(m.wvtr_g_m2_day, 0.0, f"WVTR must be >= 0 for {m.material_id}")
                
                # Thickness
                self.assertGreater(m.thickness_microns, 0.0, f"Thickness must be > 0 for {m.material_id}")
                
                # Mechanical
                self.assertGreater(m.tensile_strength_mpa, 0.0, f"Tensile strength must be > 0 for {m.material_id}")
                self.assertGreater(m.puncture_resistance_n, 0.0, f"Puncture resistance must be > 0 for {m.material_id}")
                self.assertGreaterEqual(m.elongation_pct, 0.0, f"Elongation must be >= 0 for {m.material_id}")
                
                # Thermal
                self.assertLess(m.temp_min_c, m.temp_max_c, f"T_min must be < T_max for {m.material_id}")
                
                # Sustainability & Cost
                self.assertTrue(0.0 <= m.sustainability_score <= 100.0, f"Sustainability must be [0,100] for {m.material_id}")
                self.assertGreater(m.estimated_unit_cost_inr, 0.0, f"Cost must be > 0 for {m.material_id}")
                
                # Optical & UV
                self.assertTrue(0.0 <= m.uv_transmittance_pct <= 100.0, f"UV transmittance must be [0,100] for {m.material_id}")

    def test_radar_score_calculation(self):
        """Test calculation of normalized 6-axis radar scores for a material."""
        mat = self.service.get_material_by_id("mat_al_foil_lam_13")
        self.assertIsNotNone(mat)
        
        detail = self.service.to_detail_response(mat)
        self.assertIsInstance(detail, PackagingMaterialDetailResponse)
        
        radar = detail.radar_scores
        # High barrier foil should have high barrier score and high optical protection (low UV transmission)
        self.assertGreaterEqual(radar.barrier_score, 90.0)
        self.assertGreaterEqual(radar.optical_score, 85.0)
        self.assertTrue(0.0 <= radar.sustainability_score <= 100.0)
        self.assertTrue(0.0 <= radar.thermal_score <= 100.0)
        self.assertTrue(0.0 <= radar.mechanical_score <= 100.0)
        self.assertTrue(0.0 <= radar.cost_efficiency_score <= 100.0)

    def test_filter_materials(self):
        """Test search and multi-parameter filtering capabilities."""
        # 1. Search query
        search_results = self.service.filter_materials(search="paperboard")
        self.assertGreaterEqual(len(search_results), 1)
        self.assertTrue(any("paperboard" in r.name.lower() or "board" in r.category.lower() for r in search_results))

        # 2. Biodegradable filter
        bio_results = self.service.filter_materials(is_biodegradable=True)
        self.assertGreater(len(bio_results), 0)
        for r in bio_results:
            self.assertTrue(r.environmental_profile.is_biodegradable)

        # 3. Recyclable filter
        rec_results = self.service.filter_materials(is_recyclable=True)
        self.assertGreater(len(rec_results), 0)
        for r in rec_results:
            self.assertTrue(r.environmental_profile.is_recyclable)

        # 4. Retort filter
        retort_results = self.service.filter_materials(is_retort=True)
        self.assertGreater(len(retort_results), 0)
        for r in retort_results:
            self.assertTrue(r.thermal_profile.is_retort_grade)

        # 5. Combined barrier & cost filter
        high_barrier = self.service.filter_materials(max_otr=10.0, max_wvtr=2.0)
        self.assertGreater(len(high_barrier), 0)
        for r in high_barrier:
            self.assertLessEqual(r.barrier_profile.otr_cc_m2_day, 10.0)
            self.assertLessEqual(r.barrier_profile.wvtr_g_m2_day, 2.0)

    def test_category_summaries(self):
        """Test category summaries grouping and aggregate metrics."""
        summaries = self.service.get_category_summaries()
        self.assertGreaterEqual(len(summaries), 5)
        total_count = sum(s.count for s in summaries)
        self.assertEqual(total_count, len(self.service.get_all_materials()))
        for s in summaries:
            self.assertGreater(s.count, 0)
            self.assertTrue(0.0 <= s.average_sustainability <= 100.0)
            self.assertGreater(len(s.sample_materials), 0)

    def test_add_custom_material(self):
        """Test adding and retrieving a custom material specification."""
        custom_spec = MaterialSpecification(
            material_id="custom_nanocellulose_film",
            name="Bio-Nanocellulose Ultra-Barrier Film",
            category="Biodegradable Bio-Polymer",
            polymer_family="Cellulose",
            structure="Nanocellulose / Chitosan Composite",
            thickness_microns=30.0,
            otr_cc_m2_day=0.8,
            wvtr_g_m2_day=1.5,
            tensile_strength_mpa=85.0,
            puncture_resistance_n=32.0,
            sustainability_score=96.0,
            estimated_unit_cost_inr=5.5,
            temp_min_c=-20.0,
            temp_max_c=120.0,
            is_breathable=False,
            is_biodegradable=True,
            is_recyclable=True,
            is_retort_grade=False,
            is_cryogenic_grade=False,
            gas_flush_compatible=True,
            recommended_applications=["Snack packaging", "Organic powders"],
            notes="Experimental 100% bio-based barrier film",
            resin_code="PAP_22",
            composting_standard="EN 13432 / OK Compost Home",
            regulatory_certifications=["FDA 21 CFR §176.170", "EU 10/2011"],
        )
        
        added = self.service.add_custom_material(custom_spec)
        self.assertEqual(added.material_id, "custom_nanocellulose_film")
        
        retrieved = self.service.get_material_by_id("custom_nanocellulose_film")
        self.assertIsNotNone(retrieved)
        self.assertEqual(retrieved.name, "Bio-Nanocellulose Ultra-Barrier Film")


if __name__ == "__main__":
    unittest.main()
