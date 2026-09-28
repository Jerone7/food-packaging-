# Phased Implementation Plan: AI/ML Recommendation Engine (Module 5)

Based on the technical specification in [feature-Recommendation Engine.md](file:///c:/Users/Jeron/source/repos/AI%20Packaging%20recommender/artifacts/specs/feature-Recommendation%20Engine.md), this document defines the step-by-step, atomic implementation plan for **Module 5: AI/ML Recommendation Engine**.

---

## Technical Dependency Map

```mermaid
graph TD
    P1[Phase 1: Backend Machine Learning & Hybrid TOPSIS Engine] --> P2[Phase 2: Backend Geometry, XAI & REST Endpoints]
    P2 --> P3[Phase 3: Frontend Data Models & ApiService Integration]
    P3 --> P4[Phase 4: Modular Visual Result & Comparison Widgets]
    P4 --> P5[Phase 5: Master Screen Integration, Multi-Viewport Audit & Verification]

    subgraph Phase 1: ML & TOPSIS Engine
        T1_1[1.1 MLPackagingClassifier & Feature Vectorizer] --> T1_2[1.2 HybridRecommendationEngine TOPSIS Scorer]
        T1_2 --> T1_3[1.3 Hybrid Engine Pytest Suite]
    end

    subgraph Phase 2: Geometry, XAI & API
        T2_1[2.1 BoxGeometry & XAI Synthesis Service] --> T2_2[2.2 REST /packaging/recommend Endpoint & Schemas]
        T2_2 --> T2_3[2.3 Endpoint Integration Pytest Suite]
    end

    subgraph Phase 3: Frontend Data Layer
        T3_1[3.1 Packaging Recommendation Dart Models] --> T3_2[3.2 ApiService Hybrid Request & Offline Fallbacks]
        T3_2 --> T3_3[3.3 Dart Model & Service Unit Tests]
    end

    subgraph Phase 4: UI Result Widgets
        T4_1[4.1 PrimaryRecommendationCard Widget] --> T4_4[4.4 Recommendation Results Cockpit]
        T4_2[4.2 AlternativeMaterialsMatrix Widget] --> T4_4
        T4_3[4.3 BoxGeometryCard & ExplainableAiRationaleCard] --> T4_4
        T4_4 --> T4_5[4.5 Modular Result Widget Test Suite]
    end

    subgraph Phase 5: Integration & Verification
        T5_1[5.1 FoodAnalysisScreen Results Cockpit Lifecycle] --> T5_2[5.2 Multi-Viewport Responsive Layout Audit]
        T5_2 --> T5_3[5.3 Accuracy Benchmark Validation]
        T5_3 --> T5_4[5.4 Documentation & README Updates]
    end
```

---

## Phase 1: Backend Machine Learning & Hybrid TOPSIS Engine

### Task 1.1: Build `MLPackagingClassifier` & Feature Vectorizer
- **Files:**
  - `backend/app/services/ml_classifier.py`
- **Action:**
  - Implement `MLPackagingClassifier` using decision trees / random forest ensemble mapping 18-dimension input vectors (Moisture %, Fat %, pH, $a_w$, $R_5$, $R_{20}$, Ethylene, $T_{ci}$, $T_{storage}$, Duration, Mass, Fragility, Eco-Priority) to optimal polymer family probabilities.
  - Include deterministic fallback classifier for environments where scikit-learn model weights are initialized or loaded dynamically.
- **Verification:** Unit test asserting polymer class probability distributions and feature importance weights.

### Task 1.2: Build `HybridRecommendationEngine` with TOPSIS Multi-Criteria Scorer
- **Files:**
  - `backend/app/services/hybrid_recommender.py`
  - `backend/app/core/material_catalog.py`
- **Action:**
  - Implement Stage 1: Deterministic Food Science physics & barrier pruning ($OTR_{max}$, $WVTR_{max}$, chilling floor, ethylene scrubbing, cryogenic $T_{min}$).
  - Implement Stage 2: TOPSIS multi-criteria utility scoring across 25+ packaging materials in `packaging_materials.csv`:
    - Weighted criteria: Barrier Match (35%), Shelf-Life Horizon (25%), Sustainability Index (20%), Cost Efficiency (10%), Mechanical Puncture Buffer (10%).
  - Synthesize top-ranked Primary Recommendation and 3 distinct alternatives (Eco-Champion, Economy Option, High-Barrier Option).
- **Verification:** Unit test asserting correct ranking, positive closeness score $C_i \in [0.0, 1.0]$, and exclusion of biophysically incompatible polymers.

### Task 1.3: Pytest Suite for Hybrid ML & TOPSIS Scoring Engine
- **Files:**
  - `backend/tests/test_hybrid_recommendation_engine.py`
- **Action:**
  - Comprehensive unit test suite verifying:
    - Pruning logic for Tomato (rejecting hermetic barrier without ventilation).
    - Pruning logic for Potato Chips (rejecting high OTR films).
    - TOPSIS closeness calculations and alternative extraction.
- **Verification:** Run `python -m unittest tests/test_hybrid_recommendation_engine.py` (assert 100% pass rate).

> [!IMPORTANT]
> **CHECKPOINT 1:** Backend ML & Hybrid TOPSIS scoring engine 100% verified with automated tests. Ready for Phase 2.

---

## Phase 2: Backend Volumetric Geometry, XAI Synthesis & REST Endpoints

### Task 2.1: Build `BoxGeometryAndXAIService`
- **Files:**
  - `backend/app/services/geometry_and_xai.py`
- **Action:**
  - Implement volumetric dimension allocation $(L \times W \times H)$ using golden ratio proportions and commodity bulk densities.
  - Calculate space utilization percentage and cushioning prescription (e.g. Honeycomb Kraft vs Thermal Insulated Gel Pouch).
  - Implement Explainable AI (XAI) natural language generator extracting step-by-step scientific drivers for the selected polymer and active additives.
- **Verification:** Unit test asserting non-zero box dimensions, utilization $> 65\%$, and key driver extraction.

### Task 2.2: Upgrade `POST /api/v1/packaging/recommend` & Pydantic Schemas
- **Files:**
  - `backend/app/schemas/packaging.py`
  - `backend/app/api/v1/endpoints/packaging.py`
- **Action:**
  - Update `PackagingRecommendationResponse` schema with:
    - `primary_recommendation`: Material name, type, barrier profile, eco-score, unit cost, suitability score, active additives.
    - `alternatives`: List of 3 alternatives (Eco, Economy, High-Barrier) with trade-off summaries.
    - `box_geometry`: Dimensions, volume, space utilization %, cushioning material.
    - `scientific_rationale`: Summary and key scientific drivers.
  - Wire `HybridRecommendationEngine` and `BoxGeometryAndXAIService` into `POST /api/v1/packaging/recommend` and PostgreSQL history persistence.
- **Verification:** Integration test verifying complete JSON payload serialization.

### Task 2.3: Endpoint Integration Pytest Suite
- **Files:**
  - `backend/tests/test_recommendation_endpoints.py`
- **Action:**
  - Unit and integration tests testing `/packaging/recommend` and `/packaging/history` with custom overrides, offline database fallbacks, and multi-alternative payload validation.
- **Verification:** Run `python -m unittest tests/test_recommendation_endpoints.py` (assert 100% pass rate; full backend suite clean).

> [!IMPORTANT]
> **CHECKPOINT 2:** Recommendation REST API, box geometry, and XAI rationale generator 100% verified. Ready for Phase 3 (Frontend Layer).

---

## Phase 3: Frontend Data Models & ApiService Integration

### Task 3.1: Upgrade `PackagingModel` Dart Models
- **Files:**
  - `frontend/lib/models/packaging_model.dart`
- **Action:**
  - Update immutable Dart models:
    - `PrimaryRecommendation`: Material name, type, barrier profile, sustainability score, estimated cost, active additives.
    - `PackagingAlternative`: Type enum (`ecoFriendly`, `economy`, `highBarrier`), material name, score, cost, trade-off summary.
    - `BoxGeometrySpecs`: Dimensions ($L, W, H$), volume, space utilization %, cushioning.
    - `ExplainableAiRationale`: Summary and key drivers list.
    - `PackagingRecommendationResult`: Complete response container with JSON serialization.
- **Verification:** Unit test asserting round-trip JSON serialization and parsing.

### Task 3.2: Extend `ApiService.getRecommendation()` with Offline Hybrid Synthesis
- **Files:**
  - `frontend/lib/services/api_service.dart`
- **Action:**
  - Update `ApiService.getRecommendation()` to send full payload and parse the enhanced response.
  - Enhance offline fallback generator in `ApiService` with instant client-side hybrid recommendation synthesis when backend is offline.
- **Verification:** Service test verifying online mock and offline fallback resolution.

### Task 3.3: Dart Model & Service Unit Test Suite
- **Files:**
  - `frontend/test/models/packaging_model_test.dart`
  - `frontend/test/services/recommendation_api_test.dart`
- **Action:**
  - Test model parsing, fallback synthesis, and error handling.
- **Verification:** Run `flutter test test/models/packaging_model_test.dart test/services/recommendation_api_test.dart` (assert 100% pass rate).

> [!IMPORTANT]
> **CHECKPOINT 3:** Frontend data layer and API service 100% verified. Ready for Phase 4 (Modular UI Widgets).

---

## Phase 4: Modular Visual Result & Comparison Widgets

### Task 4.1: Build `PrimaryRecommendationCard` Widget
- **Files:**
  - `frontend/lib/screens/analysis/widgets/primary_recommendation_card.dart`
- **Action:**
  - Hero recommendation card with:
    - Material name, polymer family badge, match suitability percentage gauge.
    - Sustainability eco-score badge (`AppColors.emeraldEco`).
    - Quantitative barrier specs grid ($OTR$, $WVTR$, thickness, tensile strength).
    - Active packaging additives list ($\text{KMnO}_4$ scrubber, $O_2$ scavenger, anti-fog).
- **Verification:** Widget test verifying rendering of barrier metrics and active additives.

### Task 4.2: Build `AlternativeMaterialsMatrix` Widget
- **Files:**
  - `frontend/lib/screens/analysis/widgets/alternative_materials_matrix.dart`
- **Action:**
  - 3-card side-by-side or responsive grid comparing:
    - 🌿 **Eco-Champion** (e.g. Cellulose NatureFlex, PLA)
    - 💰 **Economy Option** (e.g. Recyclable LDPE/PP)
    - 🛡️ **High-Barrier Preservation** (e.g. EVOH/Al-Foil Laminate)
  - Trade-off summary pill, cost comparison, and 1-click select/apply callback.
- **Verification:** Widget test verifying rendering of all 3 alternative cards and selection callbacks.

### Task 4.3: Build `BoxGeometryCard` & `ExplainableAiRationaleCard` Widgets
- **Files:**
  - `frontend/lib/screens/analysis/widgets/box_geometry_card.dart`
  - `frontend/lib/screens/analysis/widgets/explainable_ai_rationale_card.dart`
- **Action:**
  - `BoxGeometryCard`: Dimensional box diagram $(L \times W \times H)$, space utilization progress bar, and cushioning pill.
  - `ExplainableAiRationaleCard`: Step-by-step scientific justification breakdown with bulleted biochemical triggers.
- **Verification:** Widget test verifying box dimensions and rationale bullets.

### Task 4.4: Modular Result Widget Unit Test Suite
- **Files:**
  - `frontend/test/analysis/widgets/recommendation_widgets_test.dart`
- **Action:**
  - Comprehensive widget tests across all 4 result components.
- **Verification:** Run `flutter test test/analysis/widgets/recommendation_widgets_test.dart` (assert 100% pass rate).

> [!IMPORTANT]
> **CHECKPOINT 4:** Modular recommendation result and comparison widgets 100% verified. Ready for Phase 5.

---

## Phase 5: Master Screen Integration, Multi-Viewport Audit & Verification

### Task 5.1: Integrate Recommendation Results Cockpit into `FoodAnalysisScreen` [COMPLETED]
- **Files:**
  - `frontend/lib/screens/analysis/food_analysis_screen.dart`
- **Action:**
  - Replace the legacy basic recommendation box with the full multi-card **Recommendation Results Cockpit** upon submission.
  - Support switching between primary recommendation and user-selected alternative materials.
- **Verification:** Integrated and verified.

### Task 5.2: Multi-Viewport Responsive Layout Audit Suite [COMPLETED]
- **Files:**
  - `frontend/test/analysis/recommendation_results_viewport_test.dart`
- **Action:**
  - Automated layout audit across Mobile ($375\times812$), Tablet ($768\times1024$), and Desktop ($1280\times900$) viewports ensuring 0 RenderFlex overflow with results expanded.
- **Verification:** Run `flutter test test/analysis/recommendation_results_viewport_test.dart` (100% pass rate; all 105 frontend tests pass).

### Task 5.3: Accuracy Benchmark Validation [COMPLETED]
- **Files:**
  - `backend/tests/test_recommendation_benchmarks.py`
- **Action:**
  - Validate engine output against standard empirical packaging benchmarks:
    - Tomato $\to$ Micro-Perforated EMAP + KMnO₄ scrubber.
    - Potato Chips $\to$ Metallized Bio-PET/BOPP + Nitrogen Flush.
    - Fresh Chicken $\to$ High-Barrier EVOH Vacuum Skin Film.
    - Basmati Rice $\to$ Woven PP / Kraft with PLA Liner.
- **Verification:** Run `python -m unittest tests/test_recommendation_benchmarks.py` (100% pass rate; all 46 backend tests pass).

### Task 5.4: Documentation & README Updates [COMPLETED]
- **Files:**
  - `README.md`
  - `artifacts/specs/feature-Recommendation Engine-plan.md`
- **Action:**
  - Document hybrid AI/ML recommendation methodology, mathematical formulas, API endpoints, and UI widgets.
- **Verification:** Markdown verified.

> [!IMPORTANT]
> **CHECKPOINT 5:** Module 5 AI/ML Hybrid Recommendation Engine is 100% completed and verified with 46 backend unit/integration tests and 105 Flutter frontend tests. Ready for user demonstration and sign-off.
