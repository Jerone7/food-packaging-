"""
AI Data Preprocessing, Vectorization & Feature Engineering Service (Module 16).
Transforms raw food traits, operational logistics, and experimental records into
standardized 18-dimensional feature vectors with domain-specific imputation,
interaction feature derivation, feature scaling, target label encoding,
and stratified train-test splitting.
"""

from dataclasses import dataclass
from typing import Dict, Any, List, Optional, Tuple, Union
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler, MinMaxScaler, RobustScaler, LabelEncoder
from sklearn.model_selection import train_test_split

from app.schemas.ai_model import TargetPolymerClassEnum

# 18 Canonical Feature Names in Fixed Vector Order
CANONICAL_FEATURE_NAMES: List[str] = [
    "moisture_pct",                 # 0: Moisture content (0-100%)
    "fat_pct",                      # 1: Lipid/Fat content (0-100%)
    "ph",                           # 2: Acidity pH (1.0-14.0)
    "water_activity",               # 3: Water activity a_w (0.0-1.0)
    "respiration_rate_5c",          # 4: Respiration rate at 5°C (mg CO2/kg/h)
    "respiration_rate_20c",         # 5: Respiration rate at 20°C (mg CO2/kg/h)
    "ethylene_sensitivity_score",   # 6: Ethylene sensitivity score (0.0 - 1.0)
    "chilling_injury_threshold_c",  # 7: Chilling injury threshold (°C, -1.0 if none)
    "storage_temp_c",               # 8: Target storage temperature (°C)
    "storage_duration_days",        # 9: Required shelf-life duration (days)
    "quantity_kg",                  # 10: Batch weight / quantity (kg)
    "is_fragile",                   # 11: Fragility / bruising vulnerability (0.0 or 1.0)
    "eco_friendly_priority",        # 12: Eco-friendly material priority (0.0 or 1.0)
    "is_frozen",                    # 13: Freezing risk / condition flag (0.0 or 1.0)
    "is_high_lipid",                # 14: Lipid oxidation risk flag (0.0 or 1.0)
    "is_high_resp",                 # 15: Active gas exchange respiration flag (0.0 or 1.0)
    "is_acidic",                    # 16: Acid barrier / retort need flag (0.0 or 1.0)
    "is_perishable_animal_protein", # 17: Animal protein vacuum/gas barrier flag (0.0 or 1.0)
]

# Canonical 7 Target Polymer Classes in Fixed Order
CANONICAL_TARGET_CLASSES: List[str] = [e.value for e in TargetPolymerClassEnum]


@dataclass
class PreprocessedDatasetBundle:
    """Container holding preprocessed train/test partitions and fitted transformers."""
    X_train: np.ndarray
    X_test: np.ndarray
    y_train: np.ndarray
    y_test: np.ndarray
    scaler: Any
    label_encoder: LabelEncoder
    feature_names: List[str]
    classes: List[str]
    scaling_method: str


class DataPreprocessingService:
    """Service providing feature extraction, domain imputation, 18-D vectorization, and data partitioning."""

    @staticmethod
    def encode_ethylene_score(val: Any) -> float:
        """Encodes textual or numerical ethylene sensitivity into normalized [0.0, 1.0] range."""
        if val is None or val == "":
            return 0.2
        if isinstance(val, (int, float)):
            try:
                v = float(val)
                if np.isnan(v):
                    return 0.2
                return float(max(0.0, min(1.0, v)))
            except (ValueError, TypeError):
                return 0.2

        s = str(val).strip().lower()
        if any(k in s for k in ["crit", "extrem", "very high"]):
            return 1.0
        if "high" in s:
            return 0.8
        if any(k in s for k in ["mod", "med"]):
            return 0.5
        if "low" in s:
            return 0.2
        if any(k in s for k in ["none", "zero", "na", "null"]):
            return 0.0
        return 0.2

    @classmethod
    def impute_and_vectorize_sample(cls, data: Dict[str, Any]) -> List[float]:
        """
        Converts a single food record dictionary (with flexible keys) into a canonical
        18-dimensional feature vector, applying postharvest domain defaults for missing values.
        """
        # 0. Moisture percentage
        moisture_raw = data.get("moisture_pct")
        if moisture_raw is None:
            moisture_raw = data.get("moisture") or data.get("moisture_content_pct") or 60.0
        try:
            moisture = float(moisture_raw)
            if np.isnan(moisture):
                moisture = 60.0
        except (ValueError, TypeError):
            moisture = 60.0

        # 1. Fat percentage
        fat_raw = data.get("fat_pct")
        if fat_raw is None:
            fat_raw = data.get("fat") or data.get("fat_content_pct") or 2.0
        try:
            fat = float(fat_raw)
            if np.isnan(fat):
                fat = 2.0
        except (ValueError, TypeError):
            fat = 2.0

        # 2. pH
        ph_raw = data.get("ph")
        if ph_raw is None:
            ph_raw = data.get("ph_level") or 6.0
        try:
            ph = float(ph_raw)
            if np.isnan(ph):
                ph = 6.0
        except (ValueError, TypeError):
            ph = 6.0

        # 3. Water Activity (a_w)
        aw_raw = data.get("water_activity")
        if aw_raw is None:
            aw_raw = data.get("aw")
        if aw_raw is None or (isinstance(aw_raw, float) and np.isnan(aw_raw)):
            aw = 0.95 if moisture > 60.0 else max(0.1, min(0.99, moisture / 100.0))
        else:
            try:
                aw = float(aw_raw)
                if np.isnan(aw):
                    aw = 0.95 if moisture > 60.0 else max(0.1, min(0.99, moisture / 100.0))
            except (ValueError, TypeError):
                aw = 0.95

        # 4. Respiration rate at 5°C
        r5_raw = data.get("respiration_rate_5c")
        if r5_raw is None:
            r5_raw = data.get("r5")
        if r5_raw is None or (isinstance(r5_raw, float) and np.isnan(r5_raw)):
            r5 = 10.0 if moisture > 70.0 else 0.0
        else:
            try:
                r5 = float(r5_raw)
                if np.isnan(r5):
                    r5 = 10.0 if moisture > 70.0 else 0.0
            except (ValueError, TypeError):
                r5 = 0.0

        # 5. Respiration rate at 20°C
        r20_raw = data.get("respiration_rate_20c")
        if r20_raw is None:
            r20_raw = data.get("r20")
        if r20_raw is None or (isinstance(r20_raw, float) and np.isnan(r20_raw)):
            r20 = r5 * 2.5 if r5 > 0.0 else 0.0
        else:
            try:
                r20 = float(r20_raw)
                if np.isnan(r20):
                    r20 = r5 * 2.5 if r5 > 0.0 else 0.0
            except (ValueError, TypeError):
                r20 = 0.0

        # 6. Ethylene sensitivity
        ethylene_raw = (
            data.get("ethylene_sensitivity_score")
            or data.get("ethylene_sensitivity")
            or data.get("ethylene")
            or "Low"
        )
        ethylene_score = cls.encode_ethylene_score(ethylene_raw)

        # 7. Chilling injury threshold (°C)
        ci_raw = data.get("chilling_injury_threshold_c")
        if ci_raw is None:
            ci_raw = data.get("ci") or data.get("chilling_threshold_c") or -1.0
        try:
            ci_thresh = float(ci_raw)
            if np.isnan(ci_thresh):
                ci_thresh = -1.0
        except (ValueError, TypeError):
            ci_thresh = -1.0

        # 8. Storage temperature (°C)
        temp_raw = data.get("storage_temp_c")
        if temp_raw is None:
            temp_raw = data.get("storage_temperature_c") or data.get("temp") or 20.0
        try:
            storage_temp = float(temp_raw)
            if np.isnan(storage_temp):
                storage_temp = 20.0
        except (ValueError, TypeError):
            storage_temp = 20.0

        # 9. Storage duration (days)
        dur_raw = data.get("storage_duration_days")
        if dur_raw is None:
            dur_raw = data.get("duration") or 14.0
        try:
            duration = float(dur_raw)
            if np.isnan(duration):
                duration = 14.0
        except (ValueError, TypeError):
            duration = 14.0

        # 10. Quantity / Batch weight (kg)
        qty_raw = data.get("quantity_kg")
        if qty_raw is None:
            qty_raw = data.get("quantity") or data.get("batch_weight_g")
            if qty_raw is not None and data.get("batch_weight_g") is not None:
                try:
                    qty_raw = float(qty_raw) / 1000.0  # Convert grams to kg
                except Exception:
                    qty_raw = 5.0
        if qty_raw is None:
            qty_raw = 5.0
        try:
            quantity = float(qty_raw)
            if np.isnan(quantity):
                quantity = 5.0
        except (ValueError, TypeError):
            quantity = 5.0

        # 11. Fragility flag
        fragile_raw = data.get("is_fragile")
        if fragile_raw is None:
            fragile_raw = data.get("fragile") or data.get("fragility_score")
        if fragile_raw is None:
            fragile = 0.0
        elif isinstance(fragile_raw, bool):
            fragile = 1.0 if fragile_raw else 0.0
        elif isinstance(fragile_raw, (int, float)):
            fragile = 1.0 if float(fragile_raw) >= 0.5 else 0.0
        else:
            fragile = 1.0 if str(fragile_raw).strip().lower() in ["true", "1", "high", "medium", "yes"] else 0.0

        # 12. Eco friendly priority flag
        eco_raw = data.get("eco_friendly_priority")
        if eco_raw is None:
            eco_raw = data.get("eco_priority") or data.get("eco_friendly") or True
        if isinstance(eco_raw, bool):
            eco_prio = 1.0 if eco_raw else 0.0
        elif isinstance(eco_raw, (int, float)):
            eco_prio = 1.0 if float(eco_raw) >= 0.5 else 0.0
        else:
            eco_prio = 1.0 if str(eco_raw).strip().lower() in ["true", "1", "high", "yes"] else 0.0

        # Metadata for derived flags
        category = str(data.get("category", "")).strip().lower()
        name = str(data.get("name") or data.get("food_name", "")).strip().lower()

        # 13. is_frozen flag
        if data.get("is_frozen") is not None:
            is_frozen = 1.0 if float(data["is_frozen"]) >= 0.5 else 0.0
        else:
            is_frozen = 1.0 if (storage_temp <= -10.0 or "frozen" in category or "ice" in name) else 0.0

        # 14. is_high_lipid flag
        if data.get("is_high_lipid") is not None:
            is_high_lipid = 1.0 if float(data["is_high_lipid"]) >= 0.5 else 0.0
        else:
            is_high_lipid = 1.0 if (fat >= 18.0 or any(k in name for k in ["chip", "crisp", "nut", "butter", "oil", "fried", "cookie", "chocolate"])) else 0.0

        # 15. is_high_resp flag
        if data.get("is_high_resp") is not None:
            is_high_resp = 1.0 if float(data["is_high_resp"]) >= 0.5 else 0.0
        else:
            resp_class = str(data.get("respiration_class", "")).lower()
            is_high_resp = 1.0 if (
                r20 >= 20.0
                or any(c in resp_class for c in ["high", "very high", "extreme"])
                or any(k in name for k in ["tomato", "berry", "spinach", "banana", "apple", "broccoli", "mushroom", "lettuce", "pepper"])
            ) else 0.0

        # 16. is_acidic flag
        if data.get("is_acidic") is not None:
            is_acidic = 1.0 if float(data["is_acidic"]) >= 0.5 else 0.0
        else:
            is_acidic = 1.0 if (ph <= 4.6 or any(k in name for k in ["pickle", "sauce", "citrus", "lemon", "lime", "tomato", "vinegar", "salsa", "curry"])) else 0.0

        # 17. is_perishable_animal_protein flag
        if data.get("is_perishable_animal_protein") is not None:
            is_animal = 1.0 if float(data["is_perishable_animal_protein"]) >= 0.5 else 0.0
        else:
            is_animal = 1.0 if (
                any(c in category for c in ["meat", "seafood", "poultry", "dairy", "fish"])
                or any(k in name for k in ["chicken", "beef", "pork", "fish", "cheese", "milk", "mutton", "salmon", "shrimp", "bacon", "steak", "cod", "prawn"])
            ) else 0.0

        return [
            float(moisture),
            float(fat),
            float(ph),
            float(aw),
            float(r5),
            float(r20),
            float(ethylene_score),
            float(ci_thresh),
            float(storage_temp),
            float(duration),
            float(quantity),
            float(fragile),
            float(eco_prio),
            float(is_frozen),
            float(is_high_lipid),
            float(is_high_resp),
            float(is_acidic),
            float(is_animal),
        ]

    @classmethod
    def vectorize_dataframe(cls, df: pd.DataFrame) -> Tuple[np.ndarray, Optional[np.ndarray], List[str]]:
        """
        Transforms an entire DataFrame into an (N, 18) float64 NumPy matrix and optional target array.
        """
        records = df.to_dict(orient="records")
        X_list = [cls.impute_and_vectorize_sample(row) for row in records]
        X = np.array(X_list, dtype=np.float64)

        y = None
        if "target_polymer_class" in df.columns:
            y = df["target_polymer_class"].astype(str).str.strip().to_numpy()

        return X, y, CANONICAL_FEATURE_NAMES

    @staticmethod
    def get_scaler(scaling_method: str = "standard") -> Any:
        """Instantiates the requested feature scaling transformer."""
        method = (scaling_method or "standard").lower().strip()
        if method == "minmax":
            return MinMaxScaler()
        if method == "robust":
            return RobustScaler()
        return StandardScaler()

    @classmethod
    def fit_transform_dataset(
        cls,
        df: pd.DataFrame,
        scaler_type: str = "standard",
        test_size: float = 0.2,
        random_state: int = 42,
    ) -> PreprocessedDatasetBundle:
        """
        Fits label encoder and scaler on training partition and splits into stratified train/test sets.
        Prevents data leakage by fitting scaler strictly on X_train.
        """
        X, y_raw, feature_names = cls.vectorize_dataframe(df)
        if y_raw is None or len(y_raw) == 0:
            raise ValueError("Dataset does not contain a valid 'target_polymer_class' column.")

        # Fit label encoder over canonical classes first to ensure fixed indexing
        label_encoder = LabelEncoder()
        label_encoder.fit(CANONICAL_TARGET_CLASSES)
        classes = [str(c) for c in label_encoder.classes_]

        # Encode target vector
        y_encoded = label_encoder.transform(y_raw)

        # Check stratification feasibility (each class in dataset needs >= 2 samples)
        unique_classes, counts = np.unique(y_encoded, return_counts=True)
        can_stratify = bool(len(counts) > 0 and np.all(counts >= 2))

        if can_stratify:
            X_train, X_test, y_train, y_test = train_test_split(
                X,
                y_encoded,
                test_size=test_size,
                random_state=random_state,
                stratify=y_encoded,
            )
        else:
            X_train, X_test, y_train, y_test = train_test_split(
                X,
                y_encoded,
                test_size=test_size,
                random_state=random_state,
            )

        # Fit scaler on X_train ONLY
        scaler = cls.get_scaler(scaler_type)
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        return PreprocessedDatasetBundle(
            X_train=X_train_scaled,
            X_test=X_test_scaled,
            y_train=y_train,
            y_test=y_test,
            scaler=scaler,
            label_encoder=label_encoder,
            feature_names=feature_names,
            classes=classes,
            scaling_method=scaler_type,
        )

    @classmethod
    def transform_inference_sample(
        cls, sample: Dict[str, Any], scaler: Optional[Any] = None
    ) -> np.ndarray:
        """
        Transforms a single runtime inference request dictionary into a scaled 2D array of shape (1, 18).
        """
        vec = cls.impute_and_vectorize_sample(sample)
        arr = np.array([vec], dtype=np.float64)
        if scaler is not None:
            return scaler.transform(arr)
        return arr
