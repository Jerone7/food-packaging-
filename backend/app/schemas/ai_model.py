"""
AI Model Management & MLOps Pydantic Schemas (Module 16).
Defines request and response schemas for Dataset Ingestion & Profiling,
Model Preprocessing, Training, Evaluation, Model Registry & Versioning,
Zero-Downtime Deployment, and Retraining Workflows.
"""

from datetime import datetime
from enum import Enum
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field, ConfigDict


# ==========================================
# 1. Enums & Class Taxonomies
# ==========================================

class AlgorithmTypeEnum(str, Enum):
    RANDOM_FOREST = "RANDOM_FOREST"
    GRADIENT_BOOSTING = "GRADIENT_BOOSTING"
    MULTI_LAYER_PERCEPTRON = "MULTI_LAYER_PERCEPTRON"
    SUPPORT_VECTOR_MACHINE = "SUPPORT_VECTOR_MACHINE"


class ModelStatusEnum(str, Enum):
    ACTIVE = "active"
    CANDIDATE = "candidate"
    ARCHIVED = "archived"


class JobStatusEnum(str, Enum):
    QUEUED = "queued"
    TRAINING = "training"
    COMPLETED = "completed"
    FAILED = "failed"


class TargetPolymerClassEnum(str, Enum):
    BREATHABLE_BIO_EMAP = "BREATHABLE_BIO_EMAP"
    METALLIZED_BARRIER = "METALLIZED_BARRIER"
    HIGH_BARRIER_EVOH_VSP = "HIGH_BARRIER_EVOH_VSP"
    CELLULOSE_KRAFT_LINED = "CELLULOSE_KRAFT_LINED"
    RECYCLABLE_POLYOLEFIN = "RECYCLABLE_POLYOLEFIN"
    CRYOGENIC_DEEP_FREEZE = "CRYOGENIC_DEEP_FREEZE"
    RETORT_ACID_BARRIER = "RETORT_ACID_BARRIER"


# ==========================================
# 2. Dataset Management & Profiling Schemas
# ==========================================

class DatasetColumnProfile(BaseModel):
    min_value: Optional[float] = None
    max_value: Optional[float] = None
    mean_value: Optional[float] = None
    std_value: Optional[float] = None
    missing_count: int = 0
    missing_pct: float = 0.0


class DatasetValidationReport(BaseModel):
    is_valid: bool
    total_rows: int
    missing_critical_count: int
    invalid_class_count: int
    errors: List[str] = Field(default_factory=list)
    warnings: List[str] = Field(default_factory=list)


class DatasetMetadataResponse(BaseModel):
    dataset_id: str
    name: str
    description: Optional[str] = None
    file_format: str
    total_samples: int
    feature_count: int = 18
    class_distribution: Dict[str, int]
    created_at: datetime
    file_size_bytes: int


class DatasetDetailResponse(DatasetMetadataResponse):
    feature_summary: Dict[str, DatasetColumnProfile] = Field(default_factory=dict)
    preview_rows: List[Dict[str, Any]] = Field(default_factory=list)
    validation_report: Optional[DatasetValidationReport] = None


class DatasetUploadResponse(BaseModel):
    message: str
    dataset: DatasetMetadataResponse


# ==========================================
# 3. Model Training & Preprocessing Schemas
# ==========================================

class ModelHyperparameters(BaseModel):
    n_estimators: Optional[int] = Field(default=100, ge=10, le=1000)
    max_depth: Optional[int] = Field(default=12, ge=1, le=50)
    learning_rate: Optional[float] = Field(default=0.1, ge=0.001, le=1.0)
    min_samples_split: Optional[int] = Field(default=2, ge=2, le=20)
    random_state: Optional[int] = Field(default=42)
    test_size: Optional[float] = Field(default=0.2, ge=0.05, le=0.5)
    scaling_method: Optional[str] = Field(default="standard", pattern="^(standard|minmax|robust)$")


class ModelTrainRequest(BaseModel):
    dataset_id: Optional[str] = Field(default="baseline_archetypes", description="Dataset identifier or baseline")
    algorithm: AlgorithmTypeEnum = Field(default=AlgorithmTypeEnum.RANDOM_FOREST, description="ML classifier algorithm")
    model_tag: Optional[str] = Field(default=None, description="Optional custom tag/name for the version")
    hyperparameters: Optional[ModelHyperparameters] = Field(default_factory=ModelHyperparameters)
    auto_promote_if_better: bool = Field(default=False, description="Automatically promote if outperforming active model")


# ==========================================
# 4. Evaluation & Metrics Intelligence Schemas
# ==========================================

class PerClassMetric(BaseModel):
    precision: float
    recall: float
    f1_score: float
    support: int


class ModelEvaluationMetrics(BaseModel):
    accuracy: float
    precision_macro: float
    recall_macro: float
    f1_macro: float
    precision_weighted: float
    recall_weighted: float
    f1_weighted: float
    cv_scores: List[float] = Field(default_factory=list)
    cv_mean: float
    cv_std: float
    confusion_matrix: List[List[int]] = Field(default_factory=list)
    classes: List[str] = Field(default_factory=list)
    per_class_metrics: Dict[str, PerClassMetric] = Field(default_factory=dict)
    feature_importances: Dict[str, float] = Field(default_factory=dict)


class ModelDetailResponse(BaseModel):
    model_id: str
    algorithm: AlgorithmTypeEnum
    version: str
    dimensions: int = 18
    dataset_id: str
    status: ModelStatusEnum
    created_at: datetime
    metrics: ModelEvaluationMetrics
    hyperparameters: Dict[str, Any] = Field(default_factory=dict)
    artifact_path: str


class ModelRegistryListResponse(BaseModel):
    active_model_id: str
    total_models: int
    models: List[ModelDetailResponse]


class ModelTrainJobResponse(BaseModel):
    job_id: str
    status: JobStatusEnum
    algorithm: AlgorithmTypeEnum
    dataset_id: str
    elapsed_time_ms: Optional[float] = None
    error_message: Optional[str] = None
    model_result: Optional[ModelDetailResponse] = None


# ==========================================
# 5. Deployment, Hot-Swap & Rollback Schemas
# ==========================================

class ModelDeploymentRequest(BaseModel):
    model_id: Optional[str] = None
    notes: Optional[str] = None


class ModelDeployResponse(BaseModel):
    message: str
    deployed_model_id: str
    previous_model_id: Optional[str] = None
    deployed_at: datetime
    active_model: ModelDetailResponse


class RollbackRequest(BaseModel):
    target_model_id: Optional[str] = None
    reason: Optional[str] = None


# ==========================================
# 6. Retraining & Performance Delta Schemas
# ==========================================

class PerformanceDelta(BaseModel):
    accuracy_delta: float
    f1_delta: float
    precision_delta: float
    recall_delta: float


class RetrainRequest(BaseModel):
    dataset_id: Optional[str] = None
    algorithm: Optional[AlgorithmTypeEnum] = None
    auto_promote: bool = False
    min_accuracy_delta: float = Field(default=0.005, ge=0.0, le=1.0)


class RetrainComparisonResponse(BaseModel):
    message: str
    candidate_model: ModelDetailResponse
    active_model: Optional[ModelDetailResponse] = None
    accuracy_delta: float
    f1_delta: float
    is_promoted: bool
