"""
AI Automated & Triggered Retraining Pipeline (Module 16).
Orchestrates end-to-end dataset loading, feature preprocessing, model training,
deep metric evaluation, delta comparison against the active baseline, and policy-governed promotion.
"""

from typing import Optional

from app.schemas.ai_model import (
    AlgorithmTypeEnum,
    ModelStatusEnum,
    ModelHyperparameters,
    RetrainComparisonResponse,
)
from app.services.ai_dataset_service import DatasetService
from app.services.ai_training_engine import ModelTrainingEngine
from app.services.ai_evaluation_engine import ModelEvaluationEngine
from app.services.ai_registry_service import ModelRegistryService
from app.services.ai_deployment_service import ModelDeploymentService


class RetrainingPipeline:
    """Orchestrates end-to-end retraining, performance delta calculation, and auto-promotion."""

    def __init__(
        self,
        dataset_service: Optional[DatasetService] = None,
        training_engine: Optional[ModelTrainingEngine] = None,
        evaluation_engine: Optional[ModelEvaluationEngine] = None,
        registry_service: Optional[ModelRegistryService] = None,
        deployment_service: Optional[ModelDeploymentService] = None,
    ):
        self.dataset_service = dataset_service or DatasetService()
        self.training_engine = training_engine or ModelTrainingEngine()
        self.evaluation_engine = evaluation_engine or ModelEvaluationEngine()
        self.registry_service = registry_service or ModelRegistryService()
        self.deployment_service = (
            deployment_service or ModelDeploymentService(registry_service=self.registry_service)
        )

    def execute_retraining(
        self,
        dataset_id: Optional[str] = "baseline_archetypes",
        algorithm: Optional[AlgorithmTypeEnum] = None,
        auto_promote: bool = False,
        min_accuracy_delta: float = 0.005,
        hyperparameters: Optional[ModelHyperparameters] = None,
    ) -> RetrainComparisonResponse:
        r"""
        Executes complete retraining cycle:
        1. Ingests and loads target dataset DataFrame.
        2. Retrieves active baseline model metrics (if any).
        3. Preprocesses and trains new candidate estimator bundle.
        4. Calculates comprehensive evaluation metrics ($7\times 7$ confusion matrix, 5-fold CV).
        5. Computes performance deltas ($\Delta \text{Accuracy}$, $\Delta F_1$).
        6. Enforces auto-promotion policy or registers as candidate for admin review.
        """
        target_dataset_id = dataset_id or "baseline_archetypes"
        df = self.dataset_service.get_dataset_dataframe(target_dataset_id)

        # 1. Fetch current active baseline
        active_model = self.registry_service.get_active_model()

        # 2. Determine target algorithm
        if algorithm is not None:
            chosen_algo = algorithm
        elif active_model is not None:
            chosen_algo = active_model.algorithm
        else:
            chosen_algo = AlgorithmTypeEnum.RANDOM_FOREST

        # 3. Train candidate model
        candidate_bundle = self.training_engine.train_sync(
            dataset_df=df,
            algorithm=chosen_algo,
            hyperparameters=hyperparameters,
        )

        # 4. Evaluate candidate model
        candidate_metrics = self.evaluation_engine.evaluate_bundle(candidate_bundle)

        # 5. Compute performance delta against active baseline
        if active_model is not None:
            acc_delta = round(candidate_metrics.accuracy - active_model.metrics.accuracy, 4)
            f1_delta = round(candidate_metrics.f1_macro - active_model.metrics.f1_macro, 4)
        else:
            acc_delta = round(candidate_metrics.accuracy, 4)
            f1_delta = round(candidate_metrics.f1_macro, 4)

        # 6. Policy Check for Promotion
        # If auto_promote is True and accuracy improves by >= min_accuracy_delta (or no active model exists)
        is_promoted = False
        if auto_promote and (acc_delta >= min_accuracy_delta or active_model is None):
            is_promoted = True
            init_status = ModelStatusEnum.ACTIVE
        else:
            init_status = ModelStatusEnum.CANDIDATE

        # 7. Register candidate in Model Registry
        candidate_detail = self.registry_service.register_model(
            bundle=candidate_bundle,
            metrics=candidate_metrics,
            dataset_id=target_dataset_id,
            status=init_status,
            notes=f"Retrained on {target_dataset_id} (Delta Acc: {acc_delta:+.4f})",
        )

        # 8. If promoted, hot-swap into live classifier
        if is_promoted:
            self.deployment_service.deploy_model(candidate_detail.model_id)
            message = (
                f"Retraining successful! Candidate model '{candidate_detail.model_id}' outperformed baseline "
                f"(ΔAcc: {acc_delta:+.4f}, ΔF1: {f1_delta:+.4f}) and was automatically promoted to ACTIVE."
            )
        else:
            message = (
                f"Retraining completed. Candidate model '{candidate_detail.model_id}' registered as CANDIDATE "
                f"(ΔAcc: {acc_delta:+.4f}, ΔF1: {f1_delta:+.4f}). Awaiting admin deployment review."
            )

        return RetrainComparisonResponse(
            message=message,
            candidate_model=candidate_detail,
            active_model=active_model,
            accuracy_delta=acc_delta,
            f1_delta=f1_delta,
            is_promoted=is_promoted,
        )
