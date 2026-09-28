import unittest
import sys
import os

# Add backend directory to path
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from app.schemas.packaging_material import (
    MaterialPropertyRadarSchema,
    BarrierProfileDetailSchema,
    MechanicalProfileSchema,
    ThermalProfileSchema,
    OpticalProfileSchema,
    EnvironmentalProfileSchema,
    EconomicProfileSchema,
    PackagingMaterialDetailResponse,
    MaterialFilterParams,
    CreatePackagingMaterialInput,
    MaterialComparisonRequest,
    MaterialComparisonResponse,
    MaterialComparisonItemSchema,
    MaterialCategorySummaryResponse,
)
from app.models.food_and_packaging import PackagingMaterial


class TestPackagingMaterialSchemas(unittest.TestCase):
    def test_material_radar_schema_instantiation(self):
        radar = MaterialPropertyRadarSchema(
            barrier_score=92.5,
            mechanical_score=85.0,
            sustainability_score=95.0,
            thermal_score=70.0,
            cost_efficiency_score=88.0,
            optical_score=65.0,
        )
        self.assertEqual(radar.barrier_score, 92.5)
        self.assertEqual(radar.sustainability_score, 95.0)
        self.assertDictEqual(
            radar.model_dump(),
            {
                "barrier_score": 92.5,
                "mechanical_score": 85.0,
                "sustainability_score": 95.0,
                "thermal_score": 70.0,
                "cost_efficiency_score": 88.0,
                "optical_score": 65.0,
            }
        )

    def test_barrier_profile_detail_schema(self):
        barrier = BarrierProfileDetailSchema(
            otr_cc_m2_day=0.4,
            wvtr_g_m2_day=1.2,
            co2_permeability=1.6,
            selectivity_beta=4.0,
            thickness_microns=70.0,
            barrier_tier="Ultra-High",
            gas_flush_compatible=True,
        )
        self.assertEqual(barrier.otr_cc_m2_day, 0.4)
        self.assertEqual(barrier.barrier_tier, "Ultra-High")
        self.assertTrue(barrier.gas_flush_compatible)

    def test_packaging_material_detail_response_schema(self):
        res = PackagingMaterialDetailResponse(
            id=1,
            material_id="mat_bio_emap_01",
            name="Micro-Perforated PLA/PBAT Bio-Film",
            category="Biodegradable Bio-Polymer",
            polymer_family="BREATHABLE_BIO_EMAP",
            structure="Co-extruded Micro-Perforated PLA/PBAT Blown Film",
            form_factor="Flexible Pouch",
            barrier_profile=BarrierProfileDetailSchema(
                otr_cc_m2_day=3500.0,
                wvtr_g_m2_day=45.0,
                thickness_microns=30.0,
                barrier_tier="Breathable",
            ),
            mechanical_profile=MechanicalProfileSchema(
                tensile_strength_mpa=32.0,
                puncture_resistance_n=18.0,
                form_factor="Flexible Pouch",
            ),
            thermal_profile=ThermalProfileSchema(
                temp_min_c=0.0,
                temp_max_c=40.0,
                thermal_class="Refrigerated Stable",
            ),
            optical_profile=OpticalProfileSchema(
                optical_clarity="Translucent",
            ),
            environmental_profile=EnvironmentalProfileSchema(
                sustainability_score=94.0,
                is_biodegradable=True,
                composting_standard="EN 13432",
            ),
            economic_profile=EconomicProfileSchema(
                cost_category="Commercial Standard",
                estimated_unit_cost_inr=3.85,
            ),
            functional_flags={"is_breathable": True, "is_biodegradable": True},
            recommended_applications=["Fresh Tomatoes", "Salad Greens"],
            radar_scores=MaterialPropertyRadarSchema(
                barrier_score=80.0,
                mechanical_score=60.0,
                sustainability_score=94.0,
                thermal_score=50.0,
                cost_efficiency_score=75.0,
                optical_score=70.0,
            ),
            notes="Standard breathable EMAP film.",
        )

        self.assertEqual(res.material_id, "mat_bio_emap_01")
        self.assertEqual(res.environmental_profile.sustainability_score, 94.0)
        self.assertEqual(res.barrier_profile.otr_cc_m2_day, 3500.0)

    def test_create_packaging_material_input_validation(self):
        input_data = CreatePackagingMaterialInput(
            name="Custom Nanoclay PLA Film",
            category="Biodegradable Bio-Polymer",
            polymer_family="BIO_NANOCOMPOSITE",
            structure="PLA 25µm + Nanoclay Barrier Layer",
            thickness_microns=25.0,
            otr_cc_m2_day=12.0,
            wvtr_g_m2_day=5.5,
            tensile_strength_mpa=45.0,
            puncture_resistance_n=22.0,
            sustainability_score=92.0,
            estimated_unit_cost_inr=4.20,
            is_biodegradable=True,
            recommended_applications=["Organic berries", "Dry snacks"],
        )
        self.assertEqual(input_data.name, "Custom Nanoclay PLA Film")
        self.assertEqual(input_data.thickness_microns, 25.0)
        self.assertTrue(input_data.is_biodegradable)

    def test_material_filter_params_defaults(self):
        params = MaterialFilterParams()
        self.assertEqual(params.limit, 50)
        self.assertEqual(params.offset, 0)
        self.assertEqual(params.sort_by, "sustainability_score")
        self.assertEqual(params.sort_order, "desc")

    def test_material_comparison_schemas(self):
        req = MaterialComparisonRequest(material_ids=["mat_1", "mat_2"])
        self.assertEqual(len(req.material_ids), 2)

        resp = MaterialComparisonResponse(
            comparison_id="comp_123",
            materials_count=2,
            items=[],
            comparison_matrix={
                "otr": {"mat_1": 0.4, "mat_2": 3500.0},
                "sustainability": {"mat_1": 52.0, "mat_2": 94.0},
            },
            recommendation_summary="mat_1 offers higher gas barrier; mat_2 offers superior biodegradability."
        )
        self.assertEqual(resp.materials_count, 2)
        self.assertIn("otr", resp.comparison_matrix)

    def test_sqlalchemy_packaging_material_model_attributes(self):
        model = PackagingMaterial(
            material_id="mat_test_01",
            name="Test Barrier Film",
            category="High-Barrier Laminate",
            polymer_family="HIGH_BARRIER_EVOH_VSP",
            thickness_microns=70.0,
            otr_cc_m2_day=0.4,
            wvtr_g_m2_day=1.2,
            tensile_strength_mpa=65.0,
            puncture_resistance_n=50.0,
            sustainability_score=52.0,
            estimated_unit_cost_inr=5.80,
            is_breathable=False,
            is_biodegradable=False,
            is_recyclable=False,
            is_retort_grade=False,
            is_cryogenic_grade=False,
            gas_flush_compatible=True,
            is_active_entry=True,
        )
        self.assertEqual(model.material_id, "mat_test_01")
        self.assertEqual(model.thickness_microns, 70.0)
        self.assertEqual(model.otr_cc_m2_day, 0.4)
        self.assertTrue(model.is_active_entry)


if __name__ == "__main__":
    unittest.main()
