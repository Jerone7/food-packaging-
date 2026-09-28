"""
Unit Tests for Module 9: Packaging Comparison Pydantic Schemas.
Verifies data contracts, constraints (2-3 materials), parameter rows,
slot details, and full response models.
"""

import unittest
from pydantic import ValidationError
from app.schemas.packaging_material import (
    ComparisonParameterRow,
    MaterialComparisonSlotDetail,
    PackagingComparisonRequest,
    PackagingComparisonMatrixResponse,
)


class TestPackagingComparisonSchemas(unittest.TestCase):
    def test_valid_2_material_request(self):
        req = PackagingComparisonRequest(
            material_ids=["mat_bio_emap_01", "mat_conv_hdpe_01"]
        )
        self.assertEqual(len(req.material_ids), 2)
        self.assertIsNone(req.food_id)
        self.assertIsNone(req.food_name)

    def test_valid_3_material_request_with_food_context(self):
        req = PackagingComparisonRequest(
            material_ids=["mat_bio_emap_01", "mat_conv_hdpe_01", "mat_lam_pet_alu_01"],
            food_id=1,
            food_name="Fresh Strawberries",
        )
        self.assertEqual(len(req.material_ids), 3)
        self.assertEqual(req.food_id, 1)
        self.assertEqual(req.food_name, "Fresh Strawberries")

    def test_request_constraints_min_and_max_materials(self):
        # Fewer than 2 materials should fail
        with self.assertRaises(ValidationError):
            PackagingComparisonRequest(material_ids=["mat_bio_emap_01"])

        # Empty list should fail
        with self.assertRaises(ValidationError):
            PackagingComparisonRequest(material_ids=[])

        # More than 3 materials should fail
        with self.assertRaises(ValidationError):
            PackagingComparisonRequest(
                material_ids=[
                    "mat_1",
                    "mat_2",
                    "mat_3",
                    "mat_4",
                ]
            )

    def test_comparison_parameter_row_instantiation(self):
        row = ComparisonParameterRow(
            parameter_key="moisture_barrier",
            parameter_label="Moisture Barrier",
            parameter_group="Barrier Performance",
            unit="g/m²/day",
            values={
                "material_a": "High",
                "material_b": "Medium",
                "material_c": "High",
            },
            raw_numeric_values={
                "material_a": 45.0,
                "material_b": 3.7,
                "material_c": 0.01,
            },
            best_slot_id="material_c",
            scientific_note="Foil laminate provides near-zero moisture vapor transmission.",
        )
        self.assertEqual(row.parameter_key, "moisture_barrier")
        self.assertEqual(row.values["material_a"], "High")
        self.assertEqual(row.values["material_b"], "Medium")
        self.assertEqual(row.best_slot_id, "material_c")

    def test_material_comparison_slot_detail(self):
        slot = MaterialComparisonSlotDetail(
            slot_id="material_a",
            material_id="mat_bio_emap_01",
            name="Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)",
            category="Biodegradable Bio-Polymer",
            polymer_family="BIO_PLA",
            structure="Co-extruded Micro-Perforated Blown Film",
            color_token="#0D9488",
            is_primary_recommendation=True,
            moisture_barrier="High",
            oxygen_barrier="Medium",
            gas_exchange="High",
            strength="High",
            recyclability="Yes",
            cost_category="Medium",
            wvtr_value=45.0,
            otr_value=3500.0,
            tensile_strength_mpa=32.0,
            estimated_cost_inr=3.85,
            sustainability_score=94.0,
            suitability_score=0.96,
            suitability_category="Optimal Match",
            star_rating=5,
        )
        self.assertEqual(slot.slot_id, "material_a")
        self.assertTrue(slot.is_primary_recommendation)
        self.assertEqual(slot.moisture_barrier, "High")
        self.assertEqual(slot.gas_exchange, "High")
        self.assertEqual(slot.recyclability, "Yes")
        self.assertEqual(slot.cost_category, "Medium")
        self.assertEqual(slot.star_rating, 5)

    def test_full_packaging_comparison_matrix_response(self):
        slot_a = MaterialComparisonSlotDetail(
            slot_id="material_a",
            material_id="mat_bio_emap_01",
            name="Bio-PLA EMAP Film",
            category="Biodegradable Bio-Polymer",
            polymer_family="BIO_PLA",
            structure="Micro-Perforated Blown Film",
            color_token="#0D9488",
            is_primary_recommendation=True,
            moisture_barrier="High",
            oxygen_barrier="Medium",
            gas_exchange="High",
            strength="High",
            recyclability="Yes",
            cost_category="Medium",
            wvtr_value=45.0,
            otr_value=3500.0,
            tensile_strength_mpa=32.0,
            estimated_cost_inr=3.85,
            sustainability_score=94.0,
            suitability_score=0.96,
            suitability_category="Optimal Match",
            star_rating=5,
        )
        slot_b = MaterialComparisonSlotDetail(
            slot_id="material_b",
            material_id="mat_conv_hdpe_01",
            name="High-Density Polyethylene (HDPE)",
            category="Conventional Polymer",
            polymer_family="POLYOLEFIN_HDPE",
            structure="Monolayer Film",
            color_token="#0284C7",
            is_primary_recommendation=False,
            moisture_barrier="Medium",
            oxygen_barrier="High",
            gas_exchange="Low",
            strength="Medium",
            recyclability="Yes",
            cost_category="High",
            wvtr_value=3.7,
            otr_value=1600.0,
            tensile_strength_mpa=27.9,
            estimated_cost_inr=2.20,
            sustainability_score=58.0,
            suitability_score=0.76,
            suitability_category="Moderate Compatibility",
            star_rating=3,
        )

        rows = [
            ComparisonParameterRow(
                parameter_key="moisture_barrier",
                parameter_label="Moisture Barrier",
                parameter_group="Barrier Performance",
                unit="g/m²/day",
                values={"material_a": "High", "material_b": "Medium"},
                raw_numeric_values={"material_a": 45.0, "material_b": 3.7},
                best_slot_id="material_b",
            ),
            ComparisonParameterRow(
                parameter_key="oxygen_barrier",
                parameter_label="Oxygen Barrier",
                parameter_group="Barrier Performance",
                unit="cc/m²/day",
                values={"material_a": "Medium", "material_b": "High"},
                raw_numeric_values={"material_a": 3500.0, "material_b": 1600.0},
                best_slot_id="material_b",
            ),
            ComparisonParameterRow(
                parameter_key="gas_exchange",
                parameter_label="Gas Exchange",
                parameter_group="Respiration & Atmosphere",
                unit="Selectivity β",
                values={"material_a": "High", "material_b": "Low"},
                best_slot_id="material_a",
            ),
            ComparisonParameterRow(
                parameter_key="strength",
                parameter_label="Strength",
                parameter_group="Mechanical Performance",
                unit="MPa",
                values={"material_a": "High", "material_b": "Medium"},
                raw_numeric_values={"material_a": 32.0, "material_b": 27.9},
                best_slot_id="material_a",
            ),
            ComparisonParameterRow(
                parameter_key="recyclability",
                parameter_label="Recyclability",
                parameter_group="Environmental Circularity",
                unit="RIC / Standard",
                values={"material_a": "Yes", "material_b": "Yes"},
                best_slot_id="material_a",
            ),
            ComparisonParameterRow(
                parameter_key="cost_category",
                parameter_label="Cost Category",
                parameter_group="Economic Profile",
                unit="INR (₹)",
                values={"material_a": "Medium", "material_b": "High"},
                raw_numeric_values={"material_a": 3.85, "material_b": 2.20},
                best_slot_id="material_b",
            ),
        ]

        response = PackagingComparisonMatrixResponse(
            comparison_id="cmp_test_001",
            food_context_name="Fresh Strawberries",
            slots=[slot_a, slot_b],
            parameter_rows=rows,
            best_in_class_summary={
                "Moisture Barrier": "High-Density Polyethylene (HDPE)",
                "Gas Exchange & EMAP": "Bio-PLA EMAP Film",
            },
            ai_trade_off_synthesis="Material A offers optimal biological match for respiring fruits, whereas Material B minimizes unit procurement cost.",
            key_recommendation_rule="Select Material A for shelf-life longevity; Select Material B for bulk cost minimization.",
        )

        self.assertEqual(response.comparison_id, "cmp_test_001")
        self.assertEqual(len(response.slots), 2)
        self.assertEqual(len(response.parameter_rows), 6)
        self.assertIn("Moisture Barrier", response.best_in_class_summary)
        self.assertTrue(len(response.ai_trade_off_synthesis) > 10)


if __name__ == "__main__":
    unittest.main()
