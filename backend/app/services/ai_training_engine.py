"""
AI Multi-Algorithm Classifier Training Engine (Module 16).
Supports parameterized training across Random Forest, Gradient Boosting,
Multi-Layer Perceptron (MLP), and Support Vector Machine (SVC) architectures
with asynchronous job execution, progress tracking, and trained bundle encapsulation.
"""

import time
import uuid
import threading
from datetime import datetime, timezone
from dataclasses import dataclass
from typing import Dict, Any, Optional, List, Tuple

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.svm import SVC

from app.schemas.ai_model import (
    AlgorithmTypeEnum,
    JobStatusEnum,
    ModelHyperparameters,
    ModelTrainJobResponse,
)
from app.services.ai_preprocessing_service import (
    DataPreprocessingService,
    PreprocessedDatasetBundle,
)


@dataclass
class TrainedModelBundle:
    """Encapsulates a fitted ML estimator alongside its preprocessing artifacts and metadata."""
    model: Any
    preprocessed_bundle: PreprocessedDatasetBundle
    algorithm: AlgorithmTypeEnum
    hyperparameters: Dict[str, Any]
    elapsed_time_ms: float
    trained_at: datetime


class ModelTrainingEngine:
    """Engine responsible for estimator initialization, training execution, and background job coordination."""

    def __init__(self):
        self._jobs: Dict[str, ModelTrainJobResponse] = {}
        self._job_bundles: Dict[str, TrainedModelBundle] = {}
        self._lock = threading.Lock()

    @staticmethod
    def _build_estimator(
        algorithm: AlgorithmTypeEnum, hp: ModelHyperparameters
    ) -> Tuple[Any, Dict[str, Any]]:
        """Instantiates the specified scikit-learn classifier with calibrated hyperparameters."""
        n_est = hp.n_estimators or 100
        max_d = hp.max_depth or 12
        lr = hp.learning_rate or 0.1
        min_split = hp.min_samples_split or 2
        rand = hp.random_state or 42

        if algorithm == AlgorithmTypeEnum.RANDOM_FOREST:
            model = RandomForestClassifier(
                n_estimators=n_est,
                max_depth=max_d,
                min_samples_split=min_split,
                class_weight="balanced",
                random_state=rand,
            )
            applied_hp = {
                "n_estimators": n_est,
                "max_depth": max_d,
                "min_samples_split": min_split,
                "class_weight": "balanced",
                "random_state": rand,
                "scaling_method": hp.scaling_method or "standard",
            }
        elif algorithm == AlgorithmTypeEnum.GRADIENT_BOOSTING:
            model = GradientBoostingClassifier(
                n_estimators=n_est,
                learning_rate=lr,
                max_depth=min(max_d, 8),
                random_state=rand,
            )
            applied_hp = {
                "n_estimators": n_est,
                "learning_rate": lr,
                "max_depth": min(max_d, 8),
                "random_state": rand,
                "scaling_method": hp.scaling_method or "standard",
            }
        elif algorithm == AlgorithmTypeEnum.MULTI_LAYER_PERCEPTRON:
            model = MLPClassifier(
                hidden_layer_sizes=(64, 32),
                activation="relu",
                max_iter=500,
                alpha=0.001,
                random_state=rand,
            )
            applied_hp = {
                "hidden_layer_sizes": [64, 32],
                "activation": "relu",
                "max_iter": 500,
                "alpha": 0.001,
                "random_state": rand,
                "scaling_method": hp.scaling_method or "standard",
            }
        elif algorithm == AlgorithmTypeEnum.SUPPORT_VECTOR_MACHINE:
            try:
                from sklearn.calibration import CalibratedClassifierCV
                base_svc = SVC(C=1.0, kernel="rbf", random_state=rand)
                model = CalibratedClassifierCV(estimator=base_svc, cv=3)
            except Exception:
                model = SVC(C=1.0, kernel="rbf", probability=True, random_state=rand)
            applied_hp = {
                "C": 1.0,
                "kernel": "rbf",
                "probability": True,
                "random_state": rand,
                "scaling_method": hp.scaling_method or "standard",
            }
        else:
            raise ValueError(f"Unsupported algorithm type: {algorithm}")

        return model, applied_hp

    def train_sync(
        self,
        dataset_df: pd.DataFrame,
        algorithm: AlgorithmTypeEnum = AlgorithmTypeEnum.RANDOM_FOREST,
        hyperparameters: Optional[ModelHyperparameters] = None,
    ) -> TrainedModelBundle:
        """
        Executes end-to-end model training synchronously:
        1. Preprocesses and splits dataset using DataPreprocessingService.
        2. Instantiates target estimator with hyperparameters.
        3. Fits model on X_train.
        4. Returns TrainedModelBundle.
        """
        hp = hyperparameters or ModelHyperparameters()
        scaling_method = hp.scaling_method or "standard"
        test_size = hp.test_size or 0.2
        random_state = hp.random_state or 42

        start_time = time.perf_counter()

        # Step 1: Preprocess and split
        preprocessed = DataPreprocessingService.fit_transform_dataset(
            df=dataset_df,
            scaler_type=scaling_method,
            test_size=test_size,
            random_state=random_state,
        )

        # Step 2: Build estimator
        estimator, applied_hp = self._build_estimator(algorithm, hp)

        # Step 3: Fit estimator on X_train
        estimator.fit(preprocessed.X_train, preprocessed.y_train)

        elapsed_ms = (time.perf_counter() - start_time) * 1000.0

        return TrainedModelBundle(
            model=estimator,
            preprocessed_bundle=preprocessed,
            algorithm=algorithm,
            hyperparameters=applied_hp,
            elapsed_time_ms=elapsed_ms,
            trained_at=datetime.now(timezone.utc),
        )

    def submit_training_job(
        self,
        dataset_df: pd.DataFrame,
        dataset_id: str,
        algorithm: AlgorithmTypeEnum = AlgorithmTypeEnum.RANDOM_FOREST,
        hyperparameters: Optional[ModelHyperparameters] = None,
    ) -> str:
        """Submits a training job for background execution and returns a unique job_id."""
        job_id = f"job-{uuid.uuid4().hex[:8]}"
        hp = hyperparameters or ModelHyperparameters()

        with self._lock:
            self._jobs[job_id] = ModelTrainJobResponse(
                job_id=job_id,
                status=JobStatusEnum.QUEUED,
                algorithm=algorithm,
                dataset_id=dataset_id,
                elapsed_time_ms=None,
                error_message=None,
                model_result=None,
            )

        def _worker():
            with self._lock:
                if job_id in self._jobs:
                    self._jobs[job_id].status = JobStatusEnum.TRAINING

            try:
                bundle = self.train_sync(
                    dataset_df=dataset_df,
                    algorithm=algorithm,
                    hyperparameters=hp,
                )
                with self._lock:
                    self._job_bundles[job_id] = bundle
                    self._jobs[job_id].status = JobStatusEnum.COMPLETED
                    self._jobs[job_id].elapsed_time_ms = bundle.elapsed_time_ms
            except Exception as e:
                with self._lock:
                    self._jobs[job_id].status = JobStatusEnum.FAILED
                    self._jobs[job_id].error_message = str(e)

        thread = threading.Thread(target=_worker, daemon=True)
        thread.start()
        return job_id

    def get_job_status(self, job_id: str) -> Optional[ModelTrainJobResponse]:
        """Returns the current status of a background training job."""
        with self._lock:
            return self._jobs.get(job_id)

    def get_job_bundle(self, job_id: str) -> Optional[TrainedModelBundle]:
        """Returns the completed TrainedModelBundle for a job_id if finished."""
        with self._lock:
            return self._job_bundles.get(job_id)
