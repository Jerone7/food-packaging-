"""
AI Dataset Management, Validation & Profiling Service (Module 16).
Handles ingestion, schema validation, statistical distribution profiling,
and persistence of training datasets for AI model training.
"""

import os
import json
import re
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional, Tuple

import pandas as pd
import numpy as np

from app.schemas.ai_model import (
    DatasetColumnProfile,
    DatasetValidationReport,
    DatasetMetadataResponse,
    DatasetDetailResponse,
    DatasetUploadResponse,
    TargetPolymerClassEnum,
)

# Canonical 18 Numerical & Binary Feature Column Names
NUMERICAL_FEATURE_COLUMNS = [
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
]

DEFAULT_DATASET_DIR = os.path.join(
    os.path.dirname(__file__), "..", "ml", "datasets"
)


class DatasetService:
    """Service managing dataset ingestion, validation, profiling, and retrieval."""

    def __init__(self, dataset_dir: Optional[str] = None):
        self.dataset_dir = os.path.abspath(dataset_dir or DEFAULT_DATASET_DIR)
        os.makedirs(self.dataset_dir, exist_ok=True)

    def _resolve_dataset_path(self, dataset_id: str) -> str:
        """Finds the absolute filepath corresponding to a dataset_id."""
        clean_id = dataset_id.strip()
        # Direct match or with extensions
        for ext in ["", ".csv", ".json"]:
            path = os.path.join(self.dataset_dir, f"{clean_id}{ext}")
            if os.path.isfile(path):
                return path
        raise FileNotFoundError(f"Dataset '{dataset_id}' not found in {self.dataset_dir}")

    def load_raw_dataframe(self, filepath: str) -> pd.DataFrame:
        """Loads a CSV or JSON file into a Pandas DataFrame."""
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"File not found: {filepath}")

        if filepath.endswith(".csv"):
            df = pd.read_csv(filepath)
        elif filepath.endswith(".json"):
            df = pd.read_json(filepath)
        else:
            raise ValueError("Unsupported file format. Only CSV and JSON are supported.")
        return df

    def validate_dataset(self, filepath: str) -> DatasetValidationReport:
        """
        Validates dataset schema, column presence, missing values, and target classes.
        """
        errors: List[str] = []
        warnings: List[str] = []

        try:
            df = self.load_raw_dataframe(filepath)
        except Exception as e:
            return DatasetValidationReport(
                is_valid=False,
                total_rows=0,
                missing_critical_count=0,
                invalid_class_count=0,
                errors=[f"Failed to parse file: {str(e)}"],
                warnings=[],
            )

        total_rows = len(df)
        if total_rows == 0:
            return DatasetValidationReport(
                is_valid=False,
                total_rows=0,
                missing_critical_count=0,
                invalid_class_count=0,
                errors=["Dataset is empty (0 rows)."],
                warnings=[],
            )

        # Check target column
        if "target_polymer_class" not in df.columns:
            errors.append("Missing required target column: 'target_polymer_class'")
            invalid_class_count = 0
        else:
            valid_classes = {e.value for e in TargetPolymerClassEnum}
            target_series = df["target_polymer_class"].astype(str).str.strip()
            invalid_classes = target_series[~target_series.isin(valid_classes)]
            invalid_class_count = len(invalid_classes)
            if invalid_class_count > 0:
                unique_invalid = list(invalid_classes.unique())[:5]
                errors.append(
                    f"Found {invalid_class_count} rows with invalid target classes: {unique_invalid}"
                )

        # Check feature columns
        missing_critical_count = 0
        missing_cols = [c for c in NUMERICAL_FEATURE_COLUMNS if c not in df.columns]
        if missing_cols:
            warnings.append(
                f"Missing feature columns (will use domain defaults if trained): {missing_cols}"
            )

        # Check for NaN counts in existing columns
        for col in df.columns:
            null_count = int(df[col].isna().sum())
            if null_count > 0:
                if col in ["target_polymer_class"]:
                    missing_critical_count += null_count
                    errors.append(f"Target column has {null_count} null/missing entries.")
                else:
                    warnings.append(f"Column '{col}' has {null_count} null values.")

        is_valid = len(errors) == 0
        return DatasetValidationReport(
            is_valid=is_valid,
            total_rows=total_rows,
            missing_critical_count=missing_critical_count,
            invalid_class_count=invalid_class_count,
            errors=errors,
            warnings=warnings,
        )

    def profile_dataset(self, filepath: str) -> Tuple[Dict[str, DatasetColumnProfile], Dict[str, int], int]:
        """
        Generates statistical distribution summary (min, max, mean, std, null count) and class distribution.
        """
        df = self.load_raw_dataframe(filepath)
        total_samples = len(df)

        feature_summary: Dict[str, DatasetColumnProfile] = {}
        for col in df.columns:
            if pd.api.types.is_numeric_dtype(df[col]):
                series = df[col].dropna()
                missing_cnt = int(df[col].isna().sum())
                missing_pct = float(missing_cnt / total_samples) if total_samples > 0 else 0.0

                if len(series) > 0:
                    profile = DatasetColumnProfile(
                        min_value=float(series.min()),
                        max_value=float(series.max()),
                        mean_value=float(series.mean()),
                        std_value=float(series.std()) if len(series) > 1 else 0.0,
                        missing_count=missing_cnt,
                        missing_pct=missing_pct,
                    )
                else:
                    profile = DatasetColumnProfile(
                        min_value=None,
                        max_value=None,
                        mean_value=None,
                        std_value=None,
                        missing_count=missing_cnt,
                        missing_pct=missing_pct,
                    )
                feature_summary[col] = profile

        # Class distribution
        class_distribution: Dict[str, int] = {}
        if "target_polymer_class" in df.columns:
            counts = df["target_polymer_class"].astype(str).str.strip().value_counts().to_dict()
            class_distribution = {k: int(v) for k, v in counts.items()}

        return feature_summary, class_distribution, total_samples

    def list_available_datasets(self) -> List[DatasetMetadataResponse]:
        """Lists all CSV and JSON datasets stored in the datasets directory."""
        results: List[DatasetMetadataResponse] = []
        if not os.path.exists(self.dataset_dir):
            return results

        for filename in sorted(os.listdir(self.dataset_dir)):
            if filename.endswith(".csv") or filename.endswith(".json"):
                filepath = os.path.join(self.dataset_dir, filename)
                dataset_id = os.path.splitext(filename)[0]
                file_format = "csv" if filename.endswith(".csv") else "json"
                file_size = os.path.getsize(filepath)
                created_at = datetime.fromtimestamp(os.path.getctime(filepath), tz=timezone.utc)

                try:
                    _, class_dist, total_samples = self.profile_dataset(filepath)
                except Exception:
                    class_dist = {}
                    total_samples = 0

                name = dataset_id.replace("_", " ").title()
                results.append(
                    DatasetMetadataResponse(
                        dataset_id=dataset_id,
                        name=name,
                        description=f"{file_format.upper()} packaging dataset with {total_samples} samples",
                        file_format=file_format,
                        total_samples=total_samples,
                        feature_count=18,
                        class_distribution=class_dist,
                        created_at=created_at,
                        file_size_bytes=file_size,
                    )
                )
        return results

    def get_dataset_detail(self, dataset_id: str) -> DatasetDetailResponse:
        """Returns deep statistical metadata, column summaries, and preview rows."""
        filepath = self._resolve_dataset_path(dataset_id)
        filename = os.path.basename(filepath)
        file_format = "csv" if filename.endswith(".csv") else "json"
        file_size = os.path.getsize(filepath)
        created_at = datetime.fromtimestamp(os.path.getctime(filepath), tz=timezone.utc)

        df = self.load_raw_dataframe(filepath)
        validation_report = self.validate_dataset(filepath)
        feature_summary, class_dist, total_samples = self.profile_dataset(filepath)

        # Preview rows (replace NaN with None for valid JSON serialization)
        preview_df = df.head(5).replace({np.nan: None})
        preview_rows = preview_df.to_dict(orient="records")

        name = os.path.splitext(filename)[0].replace("_", " ").title()
        return DatasetDetailResponse(
            dataset_id=os.path.splitext(filename)[0],
            name=name,
            description=f"Detailed {file_format.upper()} dataset with {total_samples} samples",
            file_format=file_format,
            total_samples=total_samples,
            feature_count=18,
            class_distribution=class_dist,
            created_at=created_at,
            file_size_bytes=file_size,
            feature_summary=feature_summary,
            preview_rows=preview_rows,
            validation_report=validation_report,
        )

    def save_uploaded_dataset(
        self, file_bytes: bytes, filename: str, description: Optional[str] = None
    ) -> DatasetUploadResponse:
        """
        Saves uploaded file bytes to datasets directory and performs validation.
        """
        if not filename.endswith(".csv") and not filename.endswith(".json"):
            raise ValueError("Invalid file extension. Only .csv and .json files are allowed.")

        # Sanitize filename
        safe_name = re.sub(r"[^a-zA-Z0-9_\-\.]", "_", filename)
        dest_path = os.path.join(self.dataset_dir, safe_name)

        with open(dest_path, "wb") as f:
            f.write(file_bytes)

        # Validate
        val_report = self.validate_dataset(dest_path)
        if not val_report.is_valid:
            # Delete corrupted file if invalid
            if os.path.exists(dest_path):
                os.remove(dest_path)
            raise ValueError(f"Dataset validation failed: {'; '.join(val_report.errors)}")

        dataset_id = os.path.splitext(safe_name)[0]
        detail = self.get_dataset_detail(dataset_id)
        if description:
            detail.description = description

        meta = DatasetMetadataResponse(
            dataset_id=detail.dataset_id,
            name=detail.name,
            description=detail.description,
            file_format=detail.file_format,
            total_samples=detail.total_samples,
            feature_count=detail.feature_count,
            class_distribution=detail.class_distribution,
            created_at=detail.created_at,
            file_size_bytes=detail.file_size_bytes,
        )

        return DatasetUploadResponse(
            message=f"Dataset '{safe_name}' uploaded and validated successfully.",
            dataset=meta,
        )

    def get_dataset_dataframe(self, dataset_id: str) -> pd.DataFrame:
        """Loads and returns DataFrame for dataset_id."""
        filepath = self._resolve_dataset_path(dataset_id)
        return self.load_raw_dataframe(filepath)

    def delete_dataset(self, dataset_id: str) -> bool:
        """Deletes a custom dataset. Protects baseline_archetypes from deletion."""
        if dataset_id == "baseline_archetypes":
            raise PermissionError("Baseline archetype dataset cannot be deleted.")

        filepath = self._resolve_dataset_path(dataset_id)
        if os.path.exists(filepath):
            os.remove(filepath)
            return True
        return False
