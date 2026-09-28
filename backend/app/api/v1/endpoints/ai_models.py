"""
AI Model Management & MLOps REST API Endpoints (Module 16).
Provides secure, RBAC-guarded endpoints for dataset ingestion, profiling,
multi-algorithm training, evaluation metrics, registry tracking, and zero-downtime hot-swap deployments.
"""

from typing import List, Optional, Dict, Any
from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
    UploadFile,
    File,
    Form,
    status,
)

from app.api.deps import get_current_admin_user
from app.models.user import User
from app.schemas.ai_model import (
    AlgorithmTypeEnum,
    DatasetMetadataResponse,
    DatasetDetailResponse,
    DatasetUploadResponse,
    ModelTrainRequest,
    ModelTrainJobResponse,
    ModelDetailResponse,
    ModelRegistryListResponse,
    ModelDeployResponse,
    ModelDeploymentRequest,
    RollbackRequest,
    RetrainRequest,
    RetrainComparisonResponse,
    ModelEvaluationMetrics,
)
from app.services.ai_dataset_service import DatasetService
from app.services.ai_training_engine import ModelTrainingEngine
from app.services.ai_evaluation_engine import ModelEvaluationEngine
from app.services.ai_registry_service import ModelRegistryService
from app.services.ai_deployment_service import ModelDeploymentService
from app.services.ai_retraining_pipeline import RetrainingPipeline

router = APIRouter()

# Global service singletons
dataset_service = DatasetService()
training_engine = ModelTrainingEngine()
evaluation_engine = ModelEvaluationEngine()
registry_service = ModelRegistryService()
deployment_service = ModelDeploymentService(registry_service=registry_service)
retraining_pipeline = RetrainingPipeline(
    dataset_service=dataset_service,
    training_engine=training_engine,
    evaluation_engine=evaluation_engine,
    registry_service=registry_service,
    deployment_service=deployment_service,
)


# ==========================================
# 1. Dataset Management & Profiling Endpoints
# ==========================================

@router.post(
    "/datasets/upload",
    response_model=DatasetUploadResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload & Validate New Training Dataset",
    description="Ingests CSV or JSON food packaging dataset, performs schema validation, and profiles distributions.",
)
async def upload_training_dataset(
    file: UploadFile = File(..., description="CSV or JSON dataset file"),
    description: Optional[str] = Form(None, description="Dataset description"),
    current_admin: User = Depends(get_current_admin_user),
) -> DatasetUploadResponse:
    """Uploads, validates, and profiles a packaging training dataset."""
    filename = file.filename or "uploaded_dataset.csv"
    if not (filename.endswith(".csv") or filename.endswith(".json")):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid file format. Only .csv and .json files are supported.",
        )

    try:
        content = await file.read()
        if len(content) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uploaded file is empty (0 bytes).",
            )

        resp = dataset_service.save_uploaded_dataset(
            file_bytes=content,
            filename=filename,
            description=description,
        )
        return resp
    except ValueError as e:
        raise HTTPException(
            status_code=422,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process dataset: {str(e)}",
        )


@router.get(
    "/datasets",
    response_model=List[DatasetMetadataResponse],
    summary="List All Available Training Datasets",
    description="Returns metadata, sample counts, and class distributions for all stored datasets.",
)
async def list_training_datasets(
    current_admin: User = Depends(get_current_admin_user),
) -> List[DatasetMetadataResponse]:
    """Lists all stored dataset files and summaries."""
    return dataset_service.list_available_datasets()


@router.get(
    "/datasets/{dataset_id}",
    response_model=DatasetDetailResponse,
    summary="Get Dataset Deep Statistical Profile & Preview",
    description="Returns detailed 18-D column distributions (min, max, mean, std), class frequencies, and sample preview rows.",
)
async def get_dataset_profile(
    dataset_id: str,
    current_admin: User = Depends(get_current_admin_user),
) -> DatasetDetailResponse:
    """Returns deep statistical profile and preview rows for target dataset."""
    try:
        return dataset_service.get_dataset_detail(dataset_id)
    except FileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Dataset '{dataset_id}' not found.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error profiling dataset: {str(e)}",
        )


@router.delete(
    "/datasets/{dataset_id}",
    summary="Delete Custom Dataset",
    description="Deletes custom uploaded dataset file. Baseline dataset is protected from deletion.",
)
async def delete_dataset(
    dataset_id: str,
    current_admin: User = Depends(get_current_admin_user),
) -> Dict[str, str]:
    """Deletes an uploaded dataset file."""
    try:
        success = dataset_service.delete_dataset(dataset_id)
        if success:
            return {"message": f"Dataset '{dataset_id}' deleted successfully."}
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Dataset '{dataset_id}' not found.",
        )
    except PermissionError as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete dataset: {str(e)}",
        )


# ==========================================
# 2. Model Training & Job Lifecycle Endpoints
# ==========================================

@router.post(
    "/train",
    response_model=ModelTrainJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
    summary="Trigger Model Training Run",
    description="Initiates asynchronous training of specified classifier architecture on chosen dataset.",
)
async def trigger_model_training(
    request: ModelTrainRequest,
    current_admin: User = Depends(get_current_admin_user),
) -> ModelTrainJobResponse:
    """Submits a model training job for execution."""
    target_dataset_id = request.dataset_id or "baseline_archetypes"
    try:
        df = dataset_service.get_dataset_dataframe(target_dataset_id)
    except FileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Dataset '{target_dataset_id}' not found.",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to load dataset: {str(e)}",
        )

    job_id = training_engine.submit_training_job(
        dataset_df=df,
        dataset_id=target_dataset_id,
        algorithm=request.algorithm,
        hyperparameters=request.hyperparameters,
    )

    job_status = training_engine.get_job_status(job_id)
    if not job_status:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to initialize training job.",
        )
    return job_status


@router.get(
    "/jobs/{job_id}",
    response_model=ModelTrainJobResponse,
    summary="Check Training Job Status",
    description="Polls real-time training progress, elapsed time, and returns trained model metadata once completed.",
)
async def get_training_job_status(
    job_id: str,
    current_admin: User = Depends(get_current_admin_user),
) -> ModelTrainJobResponse:
    """Returns training job status and resolves model registration upon completion."""
    job_status = training_engine.get_job_status(job_id)
    if not job_status:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Training job '{job_id}' not found.",
        )

    # If completed and not yet registered in model manifest, finalize registration
    if job_status.status == "completed" and job_status.model_result is None:
        bundle = training_engine.get_job_bundle(job_id)
        if bundle:
            metrics = evaluation_engine.evaluate_bundle(bundle)
            model_detail = registry_service.register_model(
                bundle=bundle,
                metrics=metrics,
                dataset_id=job_status.dataset_id,
            )
            job_status.model_result = model_detail

    return job_status


# ==========================================
# 3. Model Retraining & Policy Promotion Endpoints
# ==========================================

@router.post(
    "/retrain",
    response_model=RetrainComparisonResponse,
    summary="Trigger Retraining & Baseline Comparison",
    description="Retrains model on target dataset, computes performance deltas against active model, and applies auto-promotion policy.",
)
async def trigger_retraining_pipeline(
    request: RetrainRequest,
    current_admin: User = Depends(get_current_admin_user),
) -> RetrainComparisonResponse:
    """Executes end-to-end retraining with performance delta calculation and auto-promotion policy gating."""
    try:
        comparison_resp = retraining_pipeline.execute_retraining(
            dataset_id=request.dataset_id,
            algorithm=request.algorithm,
            auto_promote=request.auto_promote,
            min_accuracy_delta=request.min_accuracy_delta,
        )
        return comparison_resp
    except FileNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Retraining pipeline failure: {str(e)}",
        )


# ==========================================
# 4. Model Registry, Evaluation & Deployment
# ==========================================

@router.get(
    "/registry",
    response_model=ModelRegistryListResponse,
    summary="List Model Registry Versions",
    description="Returns all registered model versions, active pointer, and accuracy metrics with optional status filter.",
)
async def list_model_registry(
    status: Optional[str] = Query("all", description="Filter by status: all | active | candidate | archived"),
    current_admin: User = Depends(get_current_admin_user),
) -> ModelRegistryListResponse:
    """Lists all registered models with version tags and status."""
    return registry_service.list_models(status_filter=status)


@router.get(
    "/{model_id}",
    response_model=ModelDetailResponse,
    summary="Get Model Details & Hyperparameters",
    description="Fetches model metadata, applied hyperparameters, feature dimensions, and evaluation summary.",
)
async def get_model_details(
    model_id: str,
    current_admin: User = Depends(get_current_admin_user),
) -> ModelDetailResponse:
    """Returns detailed metadata for a specific model version."""
    model = registry_service.get_model(model_id)
    if not model:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Model '{model_id}' not found in registry.",
        )
    return model


@router.get(
    "/{model_id}/evaluation",
    response_model=ModelEvaluationMetrics,
    summary="Get Deep Evaluation Metrics & Confusion Matrix",
    description="Returns full multi-class evaluation: Accuracy, Precision, Recall, F1, 7x7 confusion matrix, 5-fold CV, and feature importances.",
)
async def get_model_evaluation(
    model_id: str,
    current_admin: User = Depends(get_current_admin_user),
) -> ModelEvaluationMetrics:
    """Returns comprehensive evaluation metrics for target model."""
    model = registry_service.get_model(model_id)
    if not model:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Model '{model_id}' not found in registry.",
        )
    return model.metrics


@router.post(
    "/{model_id}/deploy",
    response_model=ModelDeployResponse,
    summary="Hot-Swap Model to ACTIVE (Zero-Downtime)",
    description="Promotes candidate model to ACTIVE in the registry and hot-swaps live inference engine without server restart.",
)
async def deploy_model_version(
    model_id: str,
    request: Optional[ModelDeploymentRequest] = None,
    current_admin: User = Depends(get_current_admin_user),
) -> ModelDeployResponse:
    """Promotes model to ACTIVE and hot-swaps live inference."""
    notes = request.notes if request else None
    try:
        return deployment_service.deploy_model(model_id=model_id, notes=notes)
    except FileNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to deploy model: {str(e)}",
        )


@router.post(
    "/{model_id}/rollback",
    response_model=ModelDeployResponse,
    summary="Instant Rollback to Target Model Version",
    description="Rolls back active inference to a specified historical model version with zero downtime.",
)
async def rollback_model_version(
    model_id: str,
    request: Optional[RollbackRequest] = None,
    current_admin: User = Depends(get_current_admin_user),
) -> ModelDeployResponse:
    """Rolls back the active model to a target version."""
    reason = request.reason if request else None
    try:
        return deployment_service.rollback_to_model(model_id=model_id, reason=reason)
    except FileNotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to rollback model: {str(e)}",
        )


@router.delete(
    "/{model_id}",
    summary="Delete Non-Active Model Version",
    description="Deletes a candidate or archived model entry and cleans up its .joblib artifact. Active model cannot be deleted.",
)
async def delete_model_version(
    model_id: str,
    current_admin: User = Depends(get_current_admin_user),
) -> Dict[str, str]:
    """Deletes a candidate/archived model version."""
    try:
        success = registry_service.delete_model(model_id)
        if success:
            return {"message": f"Model '{model_id}' deleted successfully."}
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Model '{model_id}' not found.",
        )
    except PermissionError as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete model: {str(e)}",
        )


