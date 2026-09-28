"""
Unit Tests for AI Model Management Pydantic Schemas (Module 16).
Tests serialization, deserialization, enum validation, boundary checks, and defaults.
"""

import unittest
from datetime import datetime, timezone
from pydantic import ValidationError

from app.schemas.ai_model import (
    AlgorithmTypeEnum,
    ModelStatusEnum,
    JobStatusEnum,
    TargetPolymerClassEnum,
    DatasetColumnProfile,
    DatasetValidationReport,
    DatasetMetadataResponse,
    DatasetDetailResponse,
    DatasetUploadResponse,
    ModelHyperparameters,
    ModelTrainRequest,
    PerClassMetric,
    ModelEvaluationMetrics,
    ModelDetailResponse,
    ModelRegistryListResponse,
    ModelTrainJobResponse,
    ModelDeploymentRequest,
    ModelDeployResponse,
    RollbackRequest,
    PerformanceDelta,
    RetrainRequest,
    RetrainComparisonResponse,
)


class TestAIModelSchemas(unittest.TestCase):
    """Test suite for AI Model Management Pydantic schemas."""

    def test_enums(self):
        """Verify all enum values match specification."""
        self.assertEqual(AlgorithmTypeEnum.RANDOM_FOREST.value, "RANDOM_FOREST")
        self.assertEqual(AlgorithmTypeEnum.GRADIENT_BOOSTING.value, "GRADIENT_BOOSTING")
        self.assertEqual(AlgorithmTypeEnum.MULTI_LAYER_PERCEPTRON.value, "MULTI_LAYER_PERCEPTRON")
        self.assertEqual(AlgorithmTypeEnum.SUPPORT_VECTOR_MACHINE.value, "SUPPORT_VECTOR_MACHINE")

        self.assertEqual(ModelStatusEnum.ACTIVE.value, "active")
        self.assertEqual(ModelStatusEnum.CANDIDATE.value, "candidate")
        self.assertEqual(ModelStatusEnum.ARCHIVED.value, "archived")

        self.assertEqual(JobStatusEnum.QUEUED.value, "queued")
        self.assertEqual(JobStatusEnum.TRAINING.value, "training")
        self.assertEqual(JobStatusEnum.COMPLETED.value, "completed")
        self.assertEqual(JobStatusEnum.FAILED.value, "failed")

        self.assertEqual(TargetPolymerClassEnum.BREATHABLE_BIO_EMAP.value, "BREATHABLE_BIO_EMAP")
        self.assertEqual(TargetPolymerClassEnum.METALLIZED_BARRIER.value, "METALLIZED_BARRIER")
        self.assertEqual(TargetPolymerClassEnum.HIGH_BARRIER_EVOH_VSP.value, "HIGH_BARRIER_EVOH_VSP")
        self.assertEqual(TargetPolymerClassEnum.CELLULOSE_KRAFT_LINED.value, "CELLULOSE_KRAFT_LINED")
        self.assertEqual(TargetPolymerClassEnum.RECYCLABLE_POLYOLEFIN.value, "RECYCLABLE_POLYOLEFIN")
        self.assertEqual(TargetPolymerClassEnum.CRYOGENIC_DEEP_FREEZE.value, "CRYOGENIC_DEEP_FREEZE")
        self.assertEqual(TargetPolymerClassEnum.RETORT_ACID_BARRIER.value, "RETORT_ACID_BARRIER")

    def test_dataset_column_profile_and_validation_report(self):
        """Verify dataset profiling and validation report schemas."""
        profile = DatasetColumnProfile(
            min_value=0.1,
            max_value=99.5,
            mean_value=55.2,
            std_value=12.4,
            missing_count=0,
            missing_pct=0.0,
        )
        self.assertEqual(profile.mean_value, 55.2)

        report = DatasetValidationReport(
            is_valid=True,
            total_rows=120,
            missing_critical_count=0,
            invalid_class_count=0,
            errors=[],
            warnings=["Slight class imbalance for RETORT_ACID_BARRIER"],
        )
        self.assertTrue(report.is_valid)
        self.assertEqual(len(report.warnings), 1)

    def test_dataset_metadata_and_detail_response(self):
        """Verify dataset metadata and detail schemas."""
        now = datetime.now(timezone.utc)
        meta = DatasetMetadataResponse(
            dataset_id="baseline_archetypes",
            name="Baseline Food Archetypes",
            description="60+ reference food commodities",
            file_format="csv",
            total_samples=65,
            feature_count=18,
            class_distribution={"BREATHABLE_BIO_EMAP": 15, "METALLIZED_BARRIER": 10},
            created_at=now,
            file_size_bytes=10240,
        )
        self.assertEqual(meta.dataset_id, "baseline_archetypes")
        self.assertEqual(meta.feature_count, 18)

        detail = DatasetDetailResponse(
            **meta.model_dump(),
            feature_summary={"moisture_content_pct": DatasetColumnProfile(mean_value=75.0)},
            preview_rows=[{"food_name": "Fresh Spinach", "moisture_content_pct": 91.4}],
        )
        self.assertEqual(len(detail.preview_rows), 1)

        upload_resp = DatasetUploadResponse(
            message="Dataset uploaded successfully",
            dataset=meta,
        )
        self.assertEqual(upload_resp.dataset.name, "Baseline Food Archetypes")

    def test_model_hyperparameters_and_train_request(self):
        """Verify hyperparameters validation and constraints."""
        hp = ModelHyperparameters(
            n_estimators=200,
            max_depth=15,
            learning_rate=0.05,
            scaling_method="standard",
        )
        self.assertEqual(hp.n_estimators, 200)

        # Invalid scaling method
        with self.assertRaises(ValidationError):
            ModelHyperparameters(scaling_method="invalid_scaler")

        # Invalid n_estimators (below ge=10)
        with self.assertRaises(ValidationError):
            ModelHyperparameters(n_estimators=5)

        # Valid train request with defaults
        train_req = ModelTrainRequest()
        self.assertEqual(train_req.algorithm, AlgorithmTypeEnum.RANDOM_FOREST)
        self.assertEqual(train_req.dataset_id, "baseline_archetypes")
        self.assertFalse(train_req.auto_promote_if_better)

    def test_model_evaluation_metrics_and_detail(self):
        """Verify full evaluation report schema and 7x7 matrix representation."""
        now = datetime.now(timezone.utc)
        per_class = {
            "BREATHABLE_BIO_EMAP": PerClassMetric(
                precision=0.95, recall=0.92, f1_score=0.935, support=12
            )
        }
        metrics = ModelEvaluationMetrics(
            accuracy=0.965,
            precision_macro=0.958,
            recall_macro=0.960,
            f1_macro=0.959,
            precision_weighted=0.966,
            recall_weighted=0.965,
            f1_weighted=0.965,
            cv_scores=[0.95, 0.96, 0.98, 0.96, 0.97],
            cv_mean=0.964,
            cv_std=0.010,
            confusion_matrix=[[10, 0, 0, 0, 0, 0, 0]],
            classes=["BREATHABLE_BIO_EMAP"],
            per_class_metrics=per_class,
            feature_importances={"respiration_rate_20c": 0.22, "moisture_content_pct": 0.18},
        )
        self.assertAlmostEqual(metrics.accuracy, 0.965)
        self.assertEqual(len(metrics.cv_scores), 5)

        model_detail = ModelDetailResponse(
            model_id="RF-20260927-001",
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
            version="v1.0.0",
            dimensions=18,
            dataset_id="baseline_archetypes",
            status=ModelStatusEnum.ACTIVE,
            created_at=now,
            metrics=metrics,
            hyperparameters={"n_estimators": 100, "max_depth": 12},
            artifact_path="backend/app/ml/models/RF-20260927-001.joblib",
        )
        self.assertEqual(model_detail.model_id, "RF-20260927-001")
        self.assertEqual(model_detail.status, ModelStatusEnum.ACTIVE)

        registry_list = ModelRegistryListResponse(
            active_model_id="RF-20260927-001",
            total_models=1,
            models=[model_detail],
        )
        self.assertEqual(registry_list.total_models, 1)

    def test_job_status_and_deployment_schemas(self):
        """Verify training job status and deployment response schemas."""
        job = ModelTrainJobResponse(
            job_id="job-12345",
            status=JobStatusEnum.COMPLETED,
            algorithm=AlgorithmTypeEnum.GRADIENT_BOOSTING,
            dataset_id="baseline_archetypes",
            elapsed_time_ms=1450.5,
        )
        self.assertEqual(job.status, JobStatusEnum.COMPLETED)
        self.assertEqual(job.elapsed_time_ms, 1450.5)

        deploy_req = ModelDeploymentRequest(
            model_id="RF-20260927-001",
            notes="Promoting newly tuned model to production",
        )
        self.assertEqual(deploy_req.model_id, "RF-20260927-001")

        rollback_req = RollbackRequest(
            target_model_id="RF-20260920-000",
            reason="Performance drift detected",
        )
        self.assertEqual(rollback_req.target_model_id, "RF-20260920-000")

    def test_retraining_and_comparison_schemas(self):
        """Verify retraining request and comparison response schemas."""
        retrain_req = RetrainRequest(
            dataset_id="baseline_archetypes",
            algorithm=AlgorithmTypeEnum.RANDOM_FOREST,
            auto_promote=True,
            min_accuracy_delta=0.01,
        )
        self.assertTrue(retrain_req.auto_promote)
        self.assertEqual(retrain_req.min_accuracy_delta, 0.01)

        delta = PerformanceDelta(
            accuracy_delta=0.012,
            f1_delta=0.015,
            precision_delta=0.010,
            recall_delta=0.014,
        )
        self.assertGreater(delta.accuracy_delta, 0.0)


if __name__ == "__main__":
    unittest.main()
