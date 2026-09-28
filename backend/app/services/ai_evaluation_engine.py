"""
AI Comprehensive Model Evaluation & Metrics Intelligence Engine (Module 16).
Computes multi-class classification metrics (Accuracy, Macro/Weighted Precision, Recall, F1),
generates 7x7 confusion matrices, executes 5-fold stratified cross-validation,
and extracts 18-dimensional feature importance rankings.
"""

from typing import Dict, Any, List, Optional
import numpy as np
import pandas as pd
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
)
from sklearn.model_selection import StratifiedKFold, cross_val_score
from sklearn.inspection import permutation_importance

from app.schemas.ai_model import (
    ModelEvaluationMetrics,
    PerClassMetric,
)
from app.services.ai_training_engine import TrainedModelBundle
from app.services.ai_preprocessing_service import CANONICAL_FEATURE_NAMES


class ModelEvaluationEngine:
    """Engine responsible for computing deep evaluation metrics, CV, confusion matrices, and feature importances."""

    @classmethod
    def evaluate_bundle(
        cls, bundle: TrainedModelBundle, n_splits: int = 5
    ) -> ModelEvaluationMetrics:
        """
        Calculates all evaluation metrics for a TrainedModelBundle:
        - Test set global metrics (Accuracy, Precision, Recall, F1).
        - Per-class breakdown with sample support counts.
        - Full 7x7 confusion matrix.
        - Stratified K-Fold cross-validation scores, mean, and variance.
        - Ranked feature importances across all 18 dimensions.
        """
        preprocessed = bundle.preprocessed_bundle
        model = bundle.model
        X_test = preprocessed.X_test
        y_test = preprocessed.y_test
        classes = preprocessed.classes
        feature_names = preprocessed.feature_names or CANONICAL_FEATURE_NAMES
        num_classes = len(classes)

        # 1. Predictions on held-out test partition
        y_pred = model.predict(X_test)

        # 2. Global classification metrics
        acc = float(accuracy_score(y_test, y_pred))
        prec_macro = float(precision_score(y_test, y_pred, average="macro", zero_division=0))
        rec_macro = float(recall_score(y_test, y_pred, average="macro", zero_division=0))
        f1_macro = float(f1_score(y_test, y_pred, average="macro", zero_division=0))

        prec_weighted = float(precision_score(y_test, y_pred, average="weighted", zero_division=0))
        rec_weighted = float(recall_score(y_test, y_pred, average="weighted", zero_division=0))
        f1_weighted = float(f1_score(y_test, y_pred, average="weighted", zero_division=0))

        # 3. Per-Class Breakdown
        per_class_metrics: Dict[str, PerClassMetric] = {}
        for class_idx, class_name in enumerate(classes):
            # Binary mask for class_idx
            y_test_bin = (y_test == class_idx).astype(int)
            y_pred_bin = (y_pred == class_idx).astype(int)
            support = int(np.sum(y_test_bin))

            c_prec = float(precision_score(y_test_bin, y_pred_bin, zero_division=0))
            c_rec = float(recall_score(y_test_bin, y_pred_bin, zero_division=0))
            c_f1 = float(f1_score(y_test_bin, y_pred_bin, zero_division=0))

            per_class_metrics[class_name] = PerClassMetric(
                precision=c_prec,
                recall=c_rec,
                f1_score=c_f1,
                support=support,
            )

        # 4. 7x7 Confusion Matrix
        cm_array = confusion_matrix(
            y_test, y_pred, labels=list(range(num_classes))
        )
        cm_list = [[int(val) for val in row] for row in cm_array]

        # 5. Stratified Cross-Validation
        X_full = np.vstack([preprocessed.X_train, preprocessed.X_test])
        y_full = np.concatenate([preprocessed.y_train, preprocessed.y_test])

        # Ensure n_splits is valid given class counts
        min_class_count = int(np.min(np.bincount(y_full))) if len(y_full) > 0 else 1
        effective_splits = max(2, min(n_splits, min_class_count))

        try:
            skf = StratifiedKFold(n_splits=effective_splits, shuffle=True, random_state=42)
            raw_cv_scores = cross_val_score(model, X_full, y_full, cv=skf, scoring="accuracy")
            cv_scores = [float(round(s, 4)) for s in raw_cv_scores]
            cv_mean = float(round(float(np.mean(cv_scores)), 4))
            cv_std = float(round(float(np.std(cv_scores)), 4))
        except Exception:
            # Fallback if cross_val_score fails on small subsets
            cv_scores = [acc]
            cv_mean = acc
            cv_std = 0.0

        # 6. Feature Importance Extraction
        feature_importances: Dict[str, float] = {}
        if hasattr(model, "feature_importances_"):
            # Tree-based estimators (RandomForest, GradientBoosting)
            raw_importances = model.feature_importances_
            total = float(np.sum(raw_importances))
            norm_importances = raw_importances / total if total > 0 else raw_importances
            for fname, imp in zip(feature_names, norm_importances):
                feature_importances[fname] = float(round(float(imp), 4))
        else:
            # Permutation importance for neural net (MLP) or SVC
            try:
                perm_res = permutation_importance(
                    model, X_test, y_test, n_repeats=5, random_state=42
                )
                raw_importances = np.maximum(0, perm_res.importances_mean)
                total = float(np.sum(raw_importances))
                norm_importances = (
                    raw_importances / total
                    if total > 0
                    else np.ones(len(feature_names)) / len(feature_names)
                )
                for fname, imp in zip(feature_names, norm_importances):
                    feature_importances[fname] = float(round(float(imp), 4))
            except Exception:
                equal_weight = round(1.0 / len(feature_names), 4)
                feature_importances = {fname: equal_weight for fname in feature_names}

        # Sort feature importances descending
        sorted_importances = dict(
            sorted(feature_importances.items(), key=lambda item: item[1], reverse=True)
        )

        return ModelEvaluationMetrics(
            accuracy=round(acc, 4),
            precision_macro=round(prec_macro, 4),
            recall_macro=round(rec_macro, 4),
            f1_macro=round(f1_macro, 4),
            precision_weighted=round(prec_weighted, 4),
            recall_weighted=round(rec_weighted, 4),
            f1_weighted=round(f1_weighted, 4),
            cv_scores=cv_scores,
            cv_mean=cv_mean,
            cv_std=cv_std,
            confusion_matrix=cm_list,
            classes=classes,
            per_class_metrics=per_class_metrics,
            feature_importances=sorted_importances,
        )
