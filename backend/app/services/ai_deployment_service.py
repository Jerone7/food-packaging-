"""
AI Zero-Downtime Model Deployment & Hot-Swapping Service (Module 16).
Promotes models to ACTIVE, hot-swaps in-memory inference pipelines across
MLPackagingClassifier and HybridPackagingRecommender, and supports instant rollbacks.
"""

from datetime import datetime, timezone
from typing import Optional, Dict, Any

from app.schemas.ai_model import (
    ModelDeployResponse,
    ModelDetailResponse,
)
from app.services.ai_registry_service import ModelRegistryService
from app.services.ml_classifier import MLPackagingClassifier, ml_classifier


class ModelDeploymentService:
    """Service managing atomic zero-downtime model promotions, rollbacks, and inference binding."""

    def __init__(
        self,
        registry_service: Optional[ModelRegistryService] = None,
        classifier: Optional[MLPackagingClassifier] = None,
    ):
        self.registry = registry_service or ModelRegistryService()
        self.classifier = classifier or ml_classifier

    def deploy_model(self, model_id: str, notes: Optional[str] = None) -> ModelDeployResponse:
        """
        Hot-swaps target model into active runtime inference:
        1. Promotes model in registry.json manifest to ACTIVE (demoting previous to ARCHIVED).
        2. Loads .joblib artifact from disk.
        3. Injects model, scaler, label_encoder, and feature metadata into the singleton classifier.
        4. Returns ModelDeployResponse.
        """
        now = datetime.now(timezone.utc)

        # 1. Update manifest status
        promoted_detail, prev_model_id = self.registry.set_active_model(model_id)

        # 2. Load artifact payload
        artifact = self.registry.load_artifact(model_id)

        # 3. Hot-swap live inference singleton
        self.classifier.load_deployed_model(artifact)

        return ModelDeployResponse(
            message=f"Model '{model_id}' deployed successfully with zero server downtime.",
            deployed_model_id=model_id,
            previous_model_id=prev_model_id,
            deployed_at=now,
            active_model=promoted_detail,
        )

    def rollback_to_model(self, model_id: str, reason: Optional[str] = None) -> ModelDeployResponse:
        """
        Rolls back the active model to a designated prior version.
        """
        notes = f"Rollback triggered: {reason}" if reason else "Rollback triggered"
        return self.deploy_model(model_id=model_id, notes=notes)

    def get_active_deployment_info(self) -> Dict[str, Any]:
        """Returns runtime status and metadata of the currently deployed model."""
        active_model = self.registry.get_active_model()
        return {
            "active_model_id": active_model.model_id if active_model else self.classifier.active_model_id,
            "version": active_model.version if active_model else self.classifier.active_version,
            "is_trained": self.classifier._is_trained,
            "has_scaler": self.classifier.scaler is not None,
            "classes": self.classifier.classes,
            "feature_count": len(self.classifier.feature_names),
        }
