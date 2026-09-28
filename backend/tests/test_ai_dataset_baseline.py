"""
Unit Tests for AI Baseline Training Dataset (Module 16).
Validates baseline_archetypes.csv integrity, feature schema, class balance,
and numerical range constraints.
"""

import os
import csv
import unittest

from app.schemas.ai_model import TargetPolymerClassEnum

DATASET_PATH = os.path.join(
    os.path.dirname(__file__), "..", "app", "ml", "datasets", "baseline_archetypes.csv"
)

EXPECTED_COLUMNS = [
    "food_name",
    "category",
    "moisture_pct",
    "fat_pct",
    "ph",
    "water_activity",
    "respiration_rate_5c",
    "respiration_rate_20c",
    "ethylene_sensitivity_score",
    "chilling_injury_threshold_c",
    "storage_temp_c",
    "storage_duration_days",
    "quantity_kg",
    "is_fragile",
    "eco_friendly_priority",
    "is_frozen",
    "is_high_lipid",
    "is_high_resp",
    "is_acidic",
    "is_perishable_animal_protein",
    "target_polymer_class",
]


class TestAIBaselineDataset(unittest.TestCase):
    """Test suite verifying baseline archetype dataset integrity."""

    def test_file_exists_and_readable(self):
        """Ensure baseline_archetypes.csv exists and is readable."""
        self.assertTrue(os.path.exists(DATASET_PATH), f"File not found: {DATASET_PATH}")
        self.assertGreater(os.path.getsize(DATASET_PATH), 500, "Dataset file is too small")

    def test_columns_and_row_count(self):
        """Verify required columns and row count >= 60."""
        with open(DATASET_PATH, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            headers = [h.strip() for h in reader.fieldnames] if reader.fieldnames else []
            self.assertEqual(headers, EXPECTED_COLUMNS, "CSV headers do not match expected schema")

            rows = list(reader)
            self.assertGreaterEqual(len(rows), 60, f"Expected >= 60 samples, got {len(rows)}")

    def test_no_null_or_empty_values(self):
        """Verify no empty cells exist in any row."""
        with open(DATASET_PATH, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for idx, row in enumerate(reader, start=1):
                for col in EXPECTED_COLUMNS:
                    val = row.get(col)
                    self.assertIsNotNone(val, f"Row {idx} has None in column {col}")
                    self.assertNotEqual(val.strip(), "", f"Row {idx} has empty string in column {col}")

    def test_class_representation_and_taxonomy(self):
        """Verify all 7 polymer classes are present with adequate representation."""
        valid_classes = {e.value for e in TargetPolymerClassEnum}
        class_counts = {c: 0 for c in valid_classes}

        with open(DATASET_PATH, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                cls_name = row["target_polymer_class"].strip()
                self.assertIn(cls_name, valid_classes, f"Unknown polymer class: {cls_name}")
                class_counts[cls_name] += 1

        for cls_name, count in class_counts.items():
            self.assertGreaterEqual(
                count, 8, f"Polymer class {cls_name} has insufficient samples ({count})"
            )

    def test_numerical_ranges(self):
        """Validate physical and biochemical numerical ranges across all rows."""
        with open(DATASET_PATH, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for idx, row in enumerate(reader, start=1):
                moisture = float(row["moisture_pct"])
                fat = float(row["fat_pct"])
                ph = float(row["ph"])
                aw = float(row["water_activity"])
                r5 = float(row["respiration_rate_5c"])
                r20 = float(row["respiration_rate_20c"])
                ethylene = float(row["ethylene_sensitivity_score"])
                ci = float(row["chilling_injury_threshold_c"])
                temp = float(row["storage_temp_c"])
                duration = float(row["storage_duration_days"])
                qty = float(row["quantity_kg"])

                self.assertTrue(0.0 <= moisture <= 100.0, f"Row {idx}: Invalid moisture {moisture}")
                self.assertTrue(0.0 <= fat <= 100.0, f"Row {idx}: Invalid fat {fat}")
                self.assertTrue(1.0 <= ph <= 14.0, f"Row {idx}: Invalid pH {ph}")
                self.assertTrue(0.0 <= aw <= 1.0, f"Row {idx}: Invalid aw {aw}")
                self.assertTrue(0.0 <= r5 <= 500.0, f"Row {idx}: Invalid r5 {r5}")
                self.assertTrue(0.0 <= r20 <= 1000.0, f"Row {idx}: Invalid r20 {r20}")
                self.assertTrue(0.0 <= ethylene <= 1.0, f"Row {idx}: Invalid ethylene {ethylene}")
                self.assertTrue(-20.0 <= ci <= 30.0, f"Row {idx}: Invalid chilling injury {ci}")
                self.assertTrue(-30.0 <= temp <= 50.0, f"Row {idx}: Invalid storage temp {temp}")
                self.assertTrue(1.0 <= duration <= 1000.0, f"Row {idx}: Invalid duration {duration}")
                self.assertTrue(0.01 <= qty <= 1000.0, f"Row {idx}: Invalid quantity {qty}")

                # Binary flags must be 0.0 or 1.0
                for flag_col in [
                    "is_fragile",
                    "eco_friendly_priority",
                    "is_frozen",
                    "is_high_lipid",
                    "is_high_resp",
                    "is_acidic",
                    "is_perishable_animal_protein",
                ]:
                    flag_val = float(row[flag_col])
                    self.assertIn(
                        flag_val, [0.0, 1.0], f"Row {idx}: Flag {flag_col} is not binary ({flag_val})"
                    )


if __name__ == "__main__":
    unittest.main()
