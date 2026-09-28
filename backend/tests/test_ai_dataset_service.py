"""
Unit Tests for AI Dataset Management, Validation & Profiling Service (Module 16).
Tests dataset ingestion, schema validation, distribution profiling, error handling,
and file lifecycle management.
"""

import os
import shutil
import tempfile
import unittest
import pandas as pd

from app.services.ai_dataset_service import DatasetService


class TestAIDatasetService(unittest.TestCase):
    """Test suite for DatasetService."""

    def setUp(self):
        """Create a temporary sandbox directory for isolated testing."""
        self.temp_dir = tempfile.mkdtemp()
        self.service = DatasetService(dataset_dir=self.temp_dir)

        # Create a sample valid CSV
        self.valid_csv_content = (
            "food_name,category,moisture_pct,fat_pct,ph,water_activity,respiration_rate_5c,respiration_rate_20c,"
            "ethylene_sensitivity_score,chilling_injury_threshold_c,storage_temp_c,storage_duration_days,"
            "quantity_kg,is_fragile,eco_friendly_priority,is_frozen,is_high_lipid,is_high_resp,is_acidic,"
            "is_perishable_animal_protein,target_polymer_class\n"
            "Fresh Lettuce,Vegetables,95.0,0.1,6.0,0.99,10.0,40.0,0.8,-1.0,4.0,7,5.0,1.0,1.0,0.0,0.0,1.0,0.0,0.0,BREATHABLE_BIO_EMAP\n"
            "Crisp Chips,Snacks,2.0,30.0,6.2,0.25,0.0,0.0,0.0,-1.0,25.0,180,0.5,1.0,0.0,0.0,1.0,0.0,0.0,0.0,METALLIZED_BARRIER\n"
        )
        self.valid_csv_path = os.path.join(self.temp_dir, "sample_valid.csv")
        with open(self.valid_csv_path, "w", encoding="utf-8") as f:
            f.write(self.valid_csv_content)

    def tearDown(self):
        """Clean up temporary sandbox directory."""
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    def test_list_available_datasets(self):
        """Verify listing datasets discovers stored files."""
        datasets = self.service.list_available_datasets()
        self.assertEqual(len(datasets), 1)
        self.assertEqual(datasets[0].dataset_id, "sample_valid")
        self.assertEqual(datasets[0].total_samples, 2)
        self.assertEqual(datasets[0].class_distribution.get("BREATHABLE_BIO_EMAP"), 1)

    def test_validate_valid_dataset(self):
        """Verify validation passes for correctly formatted dataset."""
        report = self.service.validate_dataset(self.valid_csv_path)
        self.assertTrue(report.is_valid)
        self.assertEqual(report.total_rows, 2)
        self.assertEqual(len(report.errors), 0)

    def test_validate_missing_target_column(self):
        """Verify validation fails when target column is missing."""
        invalid_path = os.path.join(self.temp_dir, "invalid_no_target.csv")
        with open(invalid_path, "w", encoding="utf-8") as f:
            f.write("food_name,moisture_pct\nApple,85.0\n")

        report = self.service.validate_dataset(invalid_path)
        self.assertFalse(report.is_valid)
        self.assertTrue(any("target_polymer_class" in err for err in report.errors))

    def test_validate_invalid_target_classes(self):
        """Verify validation catches unrecognized polymer classes."""
        invalid_class_path = os.path.join(self.temp_dir, "invalid_classes.csv")
        with open(invalid_class_path, "w", encoding="utf-8") as f:
            f.write("food_name,target_polymer_class\nFake Food,UNRECOGNIZED_POLYMER_XYZ\n")

        report = self.service.validate_dataset(invalid_class_path)
        self.assertFalse(report.is_valid)
        self.assertEqual(report.invalid_class_count, 1)

    def test_profile_dataset_statistics(self):
        """Verify numerical min, max, mean, and std profiling."""
        feature_summary, class_dist, total_samples = self.service.profile_dataset(self.valid_csv_path)
        self.assertEqual(total_samples, 2)
        self.assertIn("moisture_pct", feature_summary)
        moisture_prof = feature_summary["moisture_pct"]
        self.assertEqual(moisture_prof.min_value, 2.0)
        self.assertEqual(moisture_prof.max_value, 95.0)
        self.assertEqual(moisture_prof.mean_value, 48.5)
        self.assertEqual(moisture_prof.missing_count, 0)
        self.assertEqual(class_dist["METALLIZED_BARRIER"], 1)

    def test_get_dataset_detail(self):
        """Verify detailed metadata, preview rows, and validation report generation."""
        detail = self.service.get_dataset_detail("sample_valid")
        self.assertEqual(detail.dataset_id, "sample_valid")
        self.assertEqual(len(detail.preview_rows), 2)
        self.assertTrue(detail.validation_report.is_valid)

    def test_save_uploaded_dataset_valid_and_invalid(self):
        """Verify file upload ingestion, validation gate, and error rollback."""
        # Valid upload
        resp = self.service.save_uploaded_dataset(
            file_bytes=self.valid_csv_content.encode("utf-8"),
            filename="uploaded_experiment.csv",
            description="Trial run packaging study",
        )
        self.assertIn("uploaded and validated successfully", resp.message)
        self.assertEqual(resp.dataset.dataset_id, "uploaded_experiment")

        # Invalid upload (corrupted schema) should throw ValueError and not leave dangling file
        corrupted_content = b"header1,header2\nval1,val2\n"
        with self.assertRaises(ValueError):
            self.service.save_uploaded_dataset(
                file_bytes=corrupted_content,
                filename="corrupted_run.csv",
            )
        self.assertFalse(os.path.exists(os.path.join(self.temp_dir, "corrupted_run.csv")))

    def test_delete_dataset_and_baseline_protection(self):
        """Verify deletion behavior and baseline archetype protection."""
        # Cannot delete baseline_archetypes
        with self.assertRaises(PermissionError):
            self.service.delete_dataset("baseline_archetypes")

        # Can delete uploaded custom dataset
        self.assertTrue(self.service.delete_dataset("sample_valid"))
        self.assertFalse(os.path.exists(self.valid_csv_path))

    def test_get_dataset_dataframe(self):
        """Verify loading into pandas DataFrame."""
        df = self.service.get_dataset_dataframe("sample_valid")
        self.assertIsInstance(df, pd.DataFrame)
        self.assertEqual(len(df), 2)
        self.assertIn("moisture_pct", df.columns)

    def test_production_baseline_dataset(self):
        """Verify the production baseline dataset loads cleanly through the default service."""
        prod_service = DatasetService()
        baseline_meta = prod_service.get_dataset_detail("baseline_archetypes")
        self.assertGreaterEqual(baseline_meta.total_samples, 60)
        self.assertTrue(baseline_meta.validation_report.is_valid)
        self.assertEqual(baseline_meta.validation_report.missing_critical_count, 0)
        self.assertEqual(len(baseline_meta.class_distribution), 7)


if __name__ == "__main__":
    unittest.main()
