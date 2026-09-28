"""
AI Model Registry, Manifest Catalog & Artifact Serialization Service (Module 16).
Manages model versioning, .joblib artifact serialization, JSON catalog tracking,
and active/candidate/archived lifecycle state transitions.
"""

import os
import json
import threading
from datetime import datetime, timezone
from typing import Dict, Any, List, Optional, Tuple

import joblib

from app.schemas.ai_model import (
    AlgorithmTypeEnum,
    ModelStatusEnum,
    ModelDetailResponse,
    ModelRegistryListResponse,
    ModelEvaluationMetrics,
)
from app.services.ai_training_engine import TrainedModelBundle

DEFAULT_ML_DIR = os.path.join(os.path.dirname(__file__), "..", "ml")
DEFAULT_MODELS_DIR = os.path.join(DEFAULT_ML_DIR, "models")
DEFAULT_MANIFEST_PATH = os.path.join(DEFAULT_ML_DIR, "registry.json")


class ModelRegistryService:
    """Service managing model catalog manifest, version serialization, and artifact retrieval."""

    def __init__(
        self,
        models_dir: Optional[str] = None,
        manifest_path: Optional[str] = None,
    ):
        self.models_dir = os.path.abspath(models_dir or DEFAULT_MODELS_DIR)
        self.manifest_path = os.path.abspath(manifest_path or DEFAULT_MANIFEST_PATH)
        os.makedirs(self.models_dir, exist_ok=True)
        os.makedirs(os.path.dirname(self.manifest_path), exist_ok=True)
        self._lock = threading.Lock()
        self._ensure_manifest_exists()

    def _ensure_manifest_exists(self) -> None:
        """Initializes empty manifest file if not present."""
        with self._lock:
            if not os.path.exists(self.manifest_path):
                initial_data = {
                    "active_model_id": "",
                    "models": {},
                }
                with open(self.manifest_path, "w", encoding="utf-8") as f:
                    json.dump(initial_data, f, indent=2)

    def _read_manifest(self) -> Dict[str, Any]:
        """Reads and parses registry.json with thread safety."""
        with open(self.manifest_path, "r", encoding="utf-8") as f:
            return json.load(f)

    def _write_manifest(self, data: Dict[str, Any]) -> None:
        """Writes dictionary to registry.json with thread safety."""
        with open(self.manifest_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)

    def register_model(
        self,
        bundle: TrainedModelBundle,
        metrics: ModelEvaluationMetrics,
        dataset_id: str,
        version_tag: Optional[str] = None,
        status: ModelStatusEnum = ModelStatusEnum.CANDIDATE,
        notes: Optional[str] = None,
    ) -> ModelDetailResponse:
        """
        Serializes model bundle to .joblib and adds an entry to registry.json.
        """
        now = datetime.now(timezone.utc)
        timestamp_str = now.strftime("%Y%m%d-%H%M%S")
        import uuid
        uid = uuid.uuid4().hex[:4]
        algo_prefix = {
            AlgorithmTypeEnum.RANDOM_FOREST: "RF",
            AlgorithmTypeEnum.GRADIENT_BOOSTING: "GBDT",
            AlgorithmTypeEnum.MULTI_LAYER_PERCEPTRON: "MLP",
            AlgorithmTypeEnum.SUPPORT_VECTOR_MACHINE: "SVC",
        }.get(bundle.algorithm, "MODEL")

        model_id = f"{algo_prefix}-{timestamp_str}-{uid}"
        version = version_tag or f"v{timestamp_str}"
        artifact_filename = f"{model_id}.joblib"
        artifact_path = os.path.join(self.models_dir, artifact_filename)

        # 1. Serialize artifact bundle with joblib
        artifact_payload = {
            "model_id": model_id,
            "version": version,
            "algorithm": bundle.algorithm.value,
            "model": bundle.model,
            "scaler": bundle.preprocessed_bundle.scaler,
            "label_encoder": bundle.preprocessed_bundle.label_encoder,
            "feature_names": bundle.preprocessed_bundle.feature_names,
            "classes": bundle.preprocessed_bundle.classes,
            "scaling_method": bundle.preprocessed_bundle.scaling_method,
            "hyperparameters": bundle.hyperparameters,
            "metrics": metrics.model_dump(),
            "dataset_id": dataset_id,
            "trained_at": bundle.trained_at.isoformat(),
            "notes": notes,
        }
        joblib.dump(artifact_payload, artifact_path)

        # 2. Update manifest
        model_detail = ModelDetailResponse(
            model_id=model_id,
            algorithm=bundle.algorithm,
            version=version,
            dimensions=len(bundle.preprocessed_bundle.feature_names),
            dataset_id=dataset_id,
            status=status,
            created_at=now,
            metrics=metrics,
            hyperparameters=bundle.hyperparameters,
            artifact_path=artifact_path,
        )

        with self._lock:
            manifest = self._read_manifest()
            if status == ModelStatusEnum.ACTIVE:
                # Demote current active model to archived
                old_active = manifest.get("active_model_id")
                if old_active and old_active in manifest["models"]:
                    manifest["models"][old_active]["status"] = ModelStatusEnum.ARCHIVED.value
                manifest["active_model_id"] = model_id

            manifest["models"][model_id] = model_detail.model_dump(mode="json")
            self._write_manifest(manifest)

        return model_detail

    def get_model(self, model_id: str) -> Optional[ModelDetailResponse]:
        """Fetches a specific model manifest by model_id."""
        with self._lock:
            manifest = self._read_manifest()
            item = manifest["models"].get(model_id)
            if item:
                return ModelDetailResponse(**item)
        return None

    def list_models(self, status_filter: Optional[str] = None) -> ModelRegistryListResponse:
        """Lists all registered models, optionally filtered by status ('all', 'active', 'candidate', 'archived')."""
        with self._lock:
            manifest = self._read_manifest()
            active_id = manifest.get("active_model_id", "")
            models_dict = manifest.get("models", {})

        model_list: List[ModelDetailResponse] = []
        for mid, mdata in models_dict.items():
            parsed = ModelDetailResponse(**mdata)
            if status_filter and status_filter.lower() not in ["all", ""]:
                if parsed.status.value.lower() != status_filter.lower():
                    continue
            model_list.append(parsed)

        # Sort by creation timestamp descending
        model_list.sort(key=lambda m: m.created_at, reverse=True)

        return ModelRegistryListResponse(
            active_model_id=active_id,
            total_models=len(model_list),
            models=model_list,
        )

    def load_artifact(self, model_id: str) -> Dict[str, Any]:
        """Loads and returns the deserialized joblib model bundle."""
        model_detail = self.get_model(model_id)
        if not model_detail:
            raise FileNotFoundError(f"Model ID '{model_id}' not found in registry.")

        artifact_path = model_detail.artifact_path
        if not os.path.exists(artifact_path):
            raise FileNotFoundError(f"Model artifact file missing on disk: {artifact_path}")

        return joblib.load(artifact_path)

    def set_active_model(self, model_id: str) -> Tuple[ModelDetailResponse, Optional[str]]:
        """
        Promotes target model to ACTIVE in the registry manifest.
        Returns (promoted_model_detail, previous_active_model_id).
        """
        with self._lock:
            manifest = self._read_manifest()
            if model_id not in manifest["models"]:
                raise FileNotFoundError(f"Model '{model_id}' does not exist in registry.")

            prev_active_id = manifest.get("active_model_id")
            if prev_active_id and prev_active_id in manifest["models"]:
                manifest["models"][prev_active_id]["status"] = ModelStatusEnum.ARCHIVED.value

            manifest["active_model_id"] = model_id
            manifest["models"][model_id]["status"] = ModelStatusEnum.ACTIVE.value
            self._write_manifest(manifest)

            promoted_detail = ModelDetailResponse(**manifest["models"][model_id])
            return promoted_detail, prev_active_id

    def get_active_model(self) -> Optional[ModelDetailResponse]:
        """Returns the currently active ModelDetailResponse or None."""
        with self._lock:
            manifest = self._read_manifest()
            active_id = manifest.get("active_model_id")
            if active_id and active_id in manifest["models"]:
                return ModelDetailResponse(**manifest["models"][active_id])
        return None

    def delete_model(self, model_id: str) -> bool:
        """
        Deletes a model entry and its .joblib artifact.
        Cannot delete the currently ACTIVE model.
        """
        with self._lock:
            manifest = self._read_manifest()
            if model_id not in manifest["models"]:
                return False

            if manifest.get("active_model_id") == model_id:
                raise PermissionError("Cannot delete the currently ACTIVE model. Deploy another version first.")

            item = manifest["models"].pop(model_id)
            self._write_manifest(manifest)

        artifact_path = item.get("artifact_path")
        if artifact_path and os.path.exists(artifact_path):
            try:
                os.remove(artifact_path)
            except OSError:
                pass

        return True
