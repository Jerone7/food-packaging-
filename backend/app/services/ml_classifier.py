"""
Machine Learning Packaging Polymer Classifier & Feature Vectorizer.
Part of the SmartPack AI Hybrid Recommendation Engine (Module 5).

Maps 18-dimensional food biochemical and logistics feature vectors to
optimal polymer family classifications using a domain-trained Random Forest ensemble
with deterministic fallback capability.
"""

import math
from typing import Dict, Any, List, Optional, Tuple

try:
    import numpy as np
    from sklearn.ensemble import RandomForestClassifier
    SKLEARN_AVAILABLE = True
except ImportError:
    SKLEARN_AVAILABLE = False
    np = None
    RandomForestClassifier = None


# Standardized Target Polymer Family Classes
POLYMER_CLASSES = [
    "BREATHABLE_BIO_EMAP",      # Micro-perforated bio-film (PLA/PBAT) for respiring produce
    "METALLIZED_BARRIER",       # Metallized Bio-PET / BOPP with N2 flush for snacks & lipids
    "HIGH_BARRIER_EVOH_VSP",    # High-barrier EVOH / PA vacuum skin for meats, seafood, dairy
    "CELLULOSE_KRAFT_LINED",    # Unbleached kraft with PLA liner for dry grains, pulses & bakery
    "RECYCLABLE_POLYOLEFIN",    # Standard mono-material recyclable LDPE/HDPE/PP
    "CRYOGENIC_DEEP_FREEZE",    # Deep-freeze puncture-resistant LLDPE/Cast PA
    "RETORT_ACID_BARRIER",      # Multi-layer acid-resistant retort pouch
]

# 18-Dimensional Feature Definitions
FEATURE_NAMES = [
    "moisture_pct",                 # 0: Moisture content (0-100%)
    "fat_pct",                      # 1: Fat/Lipid content (0-100%)
    "ph",                           # 2: Acidity pH (0-14)
    "water_activity",               # 3: a_w (0.0-1.0)
    "respiration_rate_5c",          # 4: mg CO2/kg/h at 5°C
    "respiration_rate_20c",         # 5: mg CO2/kg/h at 20°C
    "ethylene_sensitivity_score",   # 6: 0.0 (None) to 1.0 (Critical)
    "chilling_injury_threshold_c",  # 7: °C threshold (default -1.0 if none)
    "storage_temp_c",               # 8: Storage temperature (°C)
    "storage_duration_days",        # 9: Days required (1-730)
    "quantity_kg",                  # 10: Batch weight (kg)
    "is_fragile",                   # 11: 1.0 if bruising/crush sensitive, 0.0 otherwise
    "eco_friendly_priority",        # 12: 1.0 if sustainability prioritized, 0.0 otherwise
    "is_frozen",                    # 13: 1.0 if storage_temp <= -10°C or category Frozen
    "is_high_lipid",                # 14: 1.0 if fat >= 18.0% or lipid oxidation risk
    "is_high_respiration",          # 15: 1.0 if R20 >= 20.0 mg CO2/kg/h or resp class high
    "is_acidic",                    # 16: 1.0 if pH <= 4.6
    "is_perishable_animal_protein", # 17: 1.0 if meat, seafood, poultry, dairy
]


class FeatureVectorizer:
    """Transforms raw food traits and operational logistics into an 18-dim feature vector."""

    @classmethod
    def vectorize(cls, data: Dict[str, Any]) -> List[float]:
        """
        Converts input dictionary into normalized 18-dim vector.
        Delegates to DataPreprocessingService for canonical 18-D feature extraction.
        """
        from app.services.ai_preprocessing_service import DataPreprocessingService
        return DataPreprocessingService.impute_and_vectorize_sample(data)



class MLPackagingClassifier:
    """
    Random Forest Polymer Classification Engine.
    Trained on domain-calibrated scientific food archetypes with probabilistic output,
    supporting runtime hot-swapping and custom feature scaling transformers.
    """

    def __init__(self, n_estimators: int = 50, random_state: int = 42):
        self.feature_names = FEATURE_NAMES
        self.classes = POLYMER_CLASSES
        self.model: Optional[Any] = None
        self.scaler: Optional[Any] = None
        self.label_encoder: Optional[Any] = None
        self.active_model_id: Optional[str] = None
        self.active_version: Optional[str] = None
        self._is_trained = False
        self._feature_importances: Dict[str, float] = {}

        if SKLEARN_AVAILABLE:
            self._train_domain_ensemble(n_estimators, random_state)
        else:
            self._init_heuristic_importances()

    def load_deployed_model(self, artifact_data: Dict[str, Any]) -> None:
        """
        Hot-swaps the live model, scaler, and label encoder in-memory with zero downtime.
        """
        self.model = artifact_data.get("model")
        self.scaler = artifact_data.get("scaler")
        self.label_encoder = artifact_data.get("label_encoder")
        self.classes = artifact_data.get("classes") or POLYMER_CLASSES
        self.feature_names = artifact_data.get("feature_names") or FEATURE_NAMES
        self.active_model_id = artifact_data.get("model_id")
        self.active_version = artifact_data.get("version")
        self._is_trained = self.model is not None

        metrics = artifact_data.get("metrics")
        if isinstance(metrics, dict) and "feature_importances" in metrics:
            self._feature_importances = metrics["feature_importances"]
        elif hasattr(self.model, "feature_importances_"):
            imp = self.model.feature_importances_
            self._feature_importances = {
                name: round(float(val), 4) for name, val in zip(self.feature_names, imp)
            }

    def predict_polymer_probabilities(self, input_data: Dict[str, Any]) -> Dict[str, float]:
        """
        Predicts normalized probability distribution across all polymer classes.
        """
        from app.services.ai_preprocessing_service import DataPreprocessingService
        vec = DataPreprocessingService.impute_and_vectorize_sample(input_data)

        if self._is_trained and self.model is not None and SKLEARN_AVAILABLE:
            X_arr = np.array([vec], dtype=np.float64)
            if self.scaler is not None:
                X_arr = self.scaler.transform(X_arr)

            probs = self.model.predict_proba(X_arr)[0]
            model_classes = list(self.model.classes_) if hasattr(self.model, "classes_") else list(range(len(probs)))

            prob_dict = {cls_name: 0.001 for cls_name in self.classes}
            for cls_target, p in zip(model_classes, probs):
                if isinstance(cls_target, str) and not cls_target.isdigit():
                    cls_name = cls_target
                else:
                    idx = int(cls_target)
                    if self.label_encoder is not None:
                        cls_name = str(self.label_encoder.inverse_transform([idx])[0])
                    elif idx < len(self.classes):
                        cls_name = self.classes[idx]
                    else:
                        cls_name = str(idx)
                prob_dict[cls_name] = float(p)

            # Normalize sum to 1.0
            total = sum(prob_dict.values())
            return {k: round(v / total, 4) for k, v in prob_dict.items()}

        # Deterministic Fallback Probability Model
        return self._heuristic_probabilities(vec, input_data)

    def _generate_synthetic_training_data(self) -> Tuple[List[List[float]], List[str]]:
        """Generates calibrated scientific training archetypes representing food preservation domains."""
        X = []
        y = []

        # 1. Respiring fresh produce archetypes -> BREATHABLE_BIO_EMAP
        produce_samples = [
            # Tomato
            {"moisture": 94.5, "fat": 0.2, "ph": 4.4, "aw": 0.99, "r5": 10.0, "r20": 45.0, "ethylene": "High", "ci": 10.0, "temp": 12.0, "duration": 21, "qty": 10, "fragile": True, "eco": True, "cat": "Vegetables", "name": "Tomato"},
            # Spinach
            {"moisture": 91.4, "fat": 0.4, "ph": 6.5, "aw": 0.98, "r5": 25.0, "r20": 90.0, "ethylene": "Moderate", "ci": -1.0, "temp": 4.0, "duration": 7, "qty": 5, "fragile": True, "eco": True, "cat": "Vegetables", "name": "Spinach"},
            # Strawberry
            {"moisture": 90.9, "fat": 0.3, "ph": 3.5, "aw": 0.98, "r5": 15.0, "r20": 60.0, "ethylene": "Moderate", "ci": -1.0, "temp": 2.0, "duration": 10, "qty": 2, "fragile": True, "eco": True, "cat": "Fruits", "name": "Strawberry"},
            # Apple
            {"moisture": 85.5, "fat": 0.2, "ph": 3.8, "aw": 0.97, "r5": 4.0, "r20": 15.0, "ethylene": "Critical", "ci": 2.0, "temp": 3.0, "duration": 60, "qty": 20, "fragile": False, "eco": True, "cat": "Fruits", "name": "Apple"},
            # Mushroom
            {"moisture": 92.5, "fat": 0.3, "ph": 6.7, "aw": 0.99, "r5": 30.0, "r20": 120.0, "ethylene": "High", "ci": -1.0, "temp": 4.0, "duration": 5, "qty": 1, "fragile": True, "eco": True, "cat": "Vegetables", "name": "Mushroom"},
        ]
        for s in produce_samples:
            vec = FeatureVectorizer.vectorize(s)
            X.append(vec)
            y.append("BREATHABLE_BIO_EMAP")
            # Perturb slightly for training robustness
            for d_temp in [-2.0, 2.0]:
                perturbed = list(vec)
                perturbed[8] += d_temp
                X.append(perturbed)
                y.append("BREATHABLE_BIO_EMAP")

        # 2. High-fat, low-moisture snacks & lipids -> METALLIZED_BARRIER
        lipid_samples = [
            # Potato Chips
            {"moisture": 1.8, "fat": 35.0, "ph": 6.2, "aw": 0.20, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 25.0, "duration": 180, "qty": 0.5, "fragile": True, "eco": False, "cat": "Snacks", "name": "Potato Chips"},
            # Roasted Almonds / Cashews
            {"moisture": 3.2, "fat": 50.0, "ph": 6.4, "aw": 0.30, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 22.0, "duration": 240, "qty": 1.0, "fragile": False, "eco": True, "cat": "Nuts", "name": "Almonds"},
            # Butter Cookies
            {"moisture": 4.5, "fat": 24.0, "ph": 6.8, "aw": 0.35, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 20.0, "duration": 120, "qty": 0.4, "fragile": True, "eco": False, "cat": "Bakery", "name": "Cookies"},
        ]
        for s in lipid_samples:
            vec = FeatureVectorizer.vectorize(s)
            X.append(vec)
            y.append("METALLIZED_BARRIER")
            for d_dur in [-30.0, 30.0]:
                perturbed = list(vec)
                perturbed[9] += d_dur
                X.append(perturbed)
                y.append("METALLIZED_BARRIER")

        # 3. Meat, Poultry, Seafood, Fresh Dairy -> HIGH_BARRIER_EVOH_VSP
        protein_samples = [
            # Fresh Chicken Breast
            {"moisture": 74.0, "fat": 2.5, "ph": 5.9, "aw": 0.99, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 2.0, "duration": 14, "qty": 2.0, "fragile": False, "eco": False, "cat": "Meat", "name": "Chicken Breast"},
            # Fresh Salmon Fillet
            {"moisture": 68.5, "fat": 12.0, "ph": 6.2, "aw": 0.98, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 1.0, "duration": 10, "qty": 1.5, "fragile": True, "eco": False, "cat": "Seafood", "name": "Salmon"},
            # Cheddar Cheese
            {"moisture": 36.7, "fat": 33.0, "ph": 5.2, "aw": 0.88, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 4.0, "duration": 90, "qty": 1.0, "fragile": False, "eco": False, "cat": "Dairy", "name": "Cheese"},
        ]
        for s in protein_samples:
            vec = FeatureVectorizer.vectorize(s)
            X.append(vec)
            y.append("HIGH_BARRIER_EVOH_VSP")
            for d_temp in [-1.0, 1.0]:
                perturbed = list(vec)
                perturbed[8] += d_temp
                X.append(perturbed)
                y.append("HIGH_BARRIER_EVOH_VSP")

        # 4. Bulk Grains, Pulses, Flour, Dry Bakery -> CELLULOSE_KRAFT_LINED
        grain_samples = [
            # Basmati Rice
            {"moisture": 12.0, "fat": 0.6, "ph": 6.6, "aw": 0.55, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 25.0, "duration": 365, "qty": 25.0, "fragile": False, "eco": True, "cat": "Grain", "name": "Basmati Rice"},
            # Wheat Flour
            {"moisture": 13.5, "fat": 1.2, "ph": 6.3, "aw": 0.60, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 22.0, "duration": 180, "qty": 10.0, "fragile": False, "eco": True, "cat": "Grain", "name": "Wheat Flour"},
            # Red Lentils
            {"moisture": 11.0, "fat": 1.0, "ph": 6.5, "aw": 0.50, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 24.0, "duration": 300, "qty": 5.0, "fragile": False, "eco": True, "cat": "Pulses", "name": "Lentils"},
        ]
        for s in grain_samples:
            vec = FeatureVectorizer.vectorize(s)
            X.append(vec)
            y.append("CELLULOSE_KRAFT_LINED")
            for d_dur in [-60.0, 60.0]:
                perturbed = list(vec)
                perturbed[9] += d_dur
                X.append(perturbed)
                y.append("CELLULOSE_KRAFT_LINED")

        # 5. Deep-Freeze Cryogenic Items -> CRYOGENIC_DEEP_FREEZE
        frozen_samples = [
            # Frozen Peas
            {"moisture": 78.0, "fat": 0.4, "ph": 6.5, "aw": 0.90, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": -18.0, "duration": 365, "qty": 2.0, "fragile": False, "eco": False, "cat": "Frozen Food", "name": "Frozen Peas"},
            # Frozen Shrimp
            {"moisture": 75.0, "fat": 1.5, "ph": 6.8, "aw": 0.90, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": -22.0, "duration": 270, "qty": 1.0, "fragile": False, "eco": False, "cat": "Frozen Food", "name": "Frozen Shrimp"},
        ]
        for s in frozen_samples:
            vec = FeatureVectorizer.vectorize(s)
            X.append(vec)
            y.append("CRYOGENIC_DEEP_FREEZE")
            for d_temp in [-5.0, 2.0]:
                perturbed = list(vec)
                perturbed[8] += d_temp
                X.append(perturbed)
                y.append("CRYOGENIC_DEEP_FREEZE")

        # 6. High Acid / Retort Foods -> RETORT_ACID_BARRIER
        acid_samples = [
            # Tomato Paste / Puree
            {"moisture": 70.0, "fat": 0.5, "ph": 3.8, "aw": 0.92, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 25.0, "duration": 365, "qty": 0.5, "fragile": False, "eco": False, "cat": "Processed", "name": "Tomato Paste"},
            # Pickled Gherkins
            {"moisture": 88.0, "fat": 0.1, "ph": 3.2, "aw": 0.94, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 20.0, "duration": 365, "qty": 0.7, "fragile": False, "eco": False, "cat": "Processed", "name": "Pickles"},
        ]
        for s in acid_samples:
            vec = FeatureVectorizer.vectorize(s)
            X.append(vec)
            y.append("RETORT_ACID_BARRIER")

        # 7. Standard Ambient Commodity -> RECYCLABLE_POLYOLEFIN
        standard_samples = [
            # Solid Confectionery
            {"moisture": 8.0, "fat": 5.0, "ph": 6.0, "aw": 0.50, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 22.0, "duration": 90, "qty": 1.0, "fragile": False, "eco": False, "cat": "Sweets", "name": "Hard Candy"},
            # Dry Pasta
            {"moisture": 11.5, "fat": 1.5, "ph": 6.5, "aw": 0.55, "r5": 0.0, "r20": 0.0, "ethylene": "None", "ci": -1.0, "temp": 25.0, "duration": 365, "qty": 1.0, "fragile": True, "eco": False, "cat": "Pasta", "name": "Macaroni"},
        ]
        for s in standard_samples:
            vec = FeatureVectorizer.vectorize(s)
            X.append(vec)
            y.append("RECYCLABLE_POLYOLEFIN")

        return X, y

    def _train_domain_ensemble(self, n_estimators: int, random_state: int):
        """Fits Random Forest model on scientific training domain."""
        X, y = self._generate_synthetic_training_data()
        self.model = RandomForestClassifier(
            n_estimators=n_estimators,
            max_depth=8,
            min_samples_split=2,
            random_state=random_state,
            class_weight="balanced",
        )
        self.model.fit(X, y)
        self._is_trained = True

        # Extract normalized feature importances
        if hasattr(self.model, "feature_importances_"):
            imp = self.model.feature_importances_
            self._feature_importances = {
                name: round(float(val), 4) for name, val in zip(self.feature_names, imp)
            }

    def _init_heuristic_importances(self):
        """Default theoretical feature importance distribution when sklearn is absent."""
        self._feature_importances = {
            "moisture_pct": 0.12,
            "fat_pct": 0.15,
            "ph": 0.08,
            "water_activity": 0.07,
            "respiration_rate_5c": 0.05,
            "respiration_rate_20c": 0.14,
            "ethylene_sensitivity_score": 0.05,
            "chilling_injury_threshold_c": 0.04,
            "storage_temp_c": 0.11,
            "storage_duration_days": 0.06,
            "quantity_kg": 0.02,
            "is_fragile": 0.03,
            "eco_friendly_priority": 0.04,
            "is_frozen": 0.08,
            "is_high_lipid": 0.10,
            "is_high_respiration": 0.12,
            "is_acidic": 0.06,
            "is_perishable_animal_protein": 0.10,
        }


    def _heuristic_probabilities(self, vec: List[float], data: Dict[str, Any]) -> Dict[str, float]:
        """Physics-based heuristic fallback if scikit-learn model is unavailable."""
        scores = {cls_name: 0.05 for cls_name in self.classes}

        moisture = vec[0]
        fat = vec[1]
        ph = vec[2]
        r20 = vec[5]
        temp = vec[8]
        is_frozen = vec[13]
        is_high_lipid = vec[14]
        is_high_resp = vec[15]
        is_acidic = vec[16]
        is_animal = vec[17]
        eco_prio = vec[12]

        if is_frozen > 0.5 or temp <= -10.0:
            scores["CRYOGENIC_DEEP_FREEZE"] += 0.85
        elif is_high_lipid > 0.5 or fat >= 18.0:
            scores["METALLIZED_BARRIER"] += 0.80
        elif is_high_resp > 0.5 or (moisture > 75.0 and r20 >= 15.0):
            scores["BREATHABLE_BIO_EMAP"] += 0.82
        elif is_animal > 0.5:
            scores["HIGH_BARRIER_EVOH_VSP"] += 0.80
        elif is_acidic > 0.5 or ph <= 4.2:
            scores["RETORT_ACID_BARRIER"] += 0.75
        elif moisture <= 15.0 and eco_prio > 0.5:
            scores["CELLULOSE_KRAFT_LINED"] += 0.70
        else:
            scores["RECYCLABLE_POLYOLEFIN"] += 0.65

        total = sum(scores.values())
        return {k: round(v / total, 4) for k, v in scores.items()}

    def classify(self, input_data: Dict[str, Any]) -> str:
        """Returns the highest-probability polymer category."""
        probs = self.predict_polymer_probabilities(input_data)
        return max(probs.items(), key=lambda x: x[1])[0]

    def get_feature_importances(self) -> Dict[str, float]:
        """Returns normalized feature importances from the trained ensemble."""
        return dict(self._feature_importances)


# Global singleton instance for high-efficiency reuse across API calls
ml_classifier = MLPackagingClassifier()
