# Phased Implementation Plan: Automatic Food Property Retrieval (Module 3)

Based on the technical specification in [feature-Automatic retrival.md](file:///c:/Users/Jeron/source/repos/AI%20Packaging%20recommender/artifacts/specs/feature-Automatic%20retrival.md), this document defines the step-by-step, atomic implementation plan for **Module 3: Automatic Food Property Retrieval**.

---

## Technical Dependency Map

```mermaid
graph TD
    P1[Phase 1: Backend Database & Scientific Models] --> P2[Phase 2: Backend REST Endpoints & Directives Engine]
    P2 --> P3[Phase 3: Frontend Data Models & Service Integration]
    P3 --> P4[Phase 4: Modular Scientific UI Widgets & Visualization]
    P4 --> P5[Phase 5: Screen Integration, Recommendation Pipeline & Verification]
    
    subgraph Phase 1: Database & Data Layer
        T1_1[1.1 FoodScientificProperty ORM & Pydantic Schemas] --> T1_2[1.2 14-Property Scientific Seed Catalog]
        T1_2 --> T1_3[1.3 Pytest Database & Model Suite]
    end
    
    subgraph Phase 2: Backend API & Directives
        T2_1[2.1 GET /foods/id/scientific-profile Endpoint] --> T2_2[2.2 Scientific Packaging Directives Engine]
        T2_2 --> T2_3[2.3 Backend Endpoint Pytest Suite]
    end

    subgraph Phase 3: Frontend Data Layer
        T3_1[3.1 FoodScientificProfile Dart Models] --> T3_2[3.2 ApiService Auto-Retrieval & Fallbacks]
        T3_2 --> T3_3[3.3 Dart Model & Service Unit Tests]
    end

    subgraph Phase 4: UI Visualization Widgets
        T4_1[4.1 SensitivityRadarBadge & Physicochemical Gauges] --> T4_4[4.4 FoodScientificDossierCard Master Widget]
        T4_2[4.2 ThermalStabilityGauge & Chilling Alert] --> T4_4
        T4_3[4.3 AtmosphereDynamicsCard (EMAP/Ethylene/CO2)] --> T4_4
        T4_4 --> T4_5[4.5 Modular Widget Unit Test Suite]
    end

    subgraph Phase 5: Integration & Verification
        T5_1[5.1 FoodAnalysisScreen Auto-Retrieval Lifecycle] --> T5_2[5.2 Recommendation Pipeline Coupling]
        T5_2 --> T5_3[5.3 Multi-Viewport Integration Tests]
        T5_3 --> T5_4[5.4 Documentation & README Updates]
    end
```

---

## Phase 1: Backend Database & Scientific Property Models [COMPLETED]

### Task 1.1: Define `FoodScientificProperty` ORM Model & Pydantic Schemas [COMPLETED]
- **Files:**
  - `backend/app/models/food_and_packaging.py`
  - `backend/app/schemas/food_scientific_properties.py`
- **Action:** 
  - Created SQLAlchemy model `FoodScientificProperty` encapsulating all 14 properties.
  - Created comprehensive Pydantic serialization schemas with field validation and nested sub-dossiers (`PhysicochemicalTraits`, `PhysiologicalKinetics`, `AtmosphereSensitivities`, `ThermalAndStorage`, `SpoilageAndVulnerabilities`, `PackagingPrescriptions`).
- **Verification:** Verified schema validation and foreign key constraints.

### Task 1.2: Build 14-Property Scientific Seed Catalog & Offline Dictionary [COMPLETED]
- **Files:**
  - `backend/app/core/scientific_catalog.py`
  - `backend/data/food_scientific_profiles.csv`
- **Action:**
  - Compiled verified empirical scientific data across all 7 food categories from IFCT 2017, UC Davis Postharvest Produce Facts, and USDA FoodData Central.
  - Implemented in-memory lookup catalog and fuzzy normalization engine.
- **Verification:** Verified catalog lookup across representative foods (`Fresh Tomato`, `Potato Chips`, `Fresh Spinach`, `Fresh Chicken Breast`, `Fresh Paneer`, `Fresh Apple`, `Sliced White Bread`, `Basmati Rice`).

### Task 1.3: Pytest Suite for Database Schema & Data Models [COMPLETED]
- **Files:**
  - `backend/tests/test_scientific_properties_models.py`
- **Action:**
  - Unit tests validating ORM model, Pydantic serialization, catalog resolution, chilling injury threshold, and algorithmic fallback synthesis.
- **Verification:** Run `python -m unittest tests/test_scientific_properties_models.py` (4/4 tests passed).

> [!IMPORTANT]
> **CHECKPOINT 1:** Backend database and model layer 100% verified. Ready for Phase 2.

---

## Phase 2: Backend REST Endpoints & Scientific Directives Engine [COMPLETED]

### Task 2.1: Implement `GET /api/v1/data/foods/{food_id}/scientific-profile` & `/lookup` [COMPLETED]
- **Files:**
  - `backend/app/api/v1/endpoints/food_data.py`
- **Action:**
  - Added REST endpoints `GET /api/v1/data/foods/{food_id}/scientific-profile` and `GET /api/v1/data/foods/scientific-lookup` with full 14-property payload serialization and offline resilience.
- **Verification:** Verified endpoints return complete scientific dossier.

### Task 2.2: Implement Scientific Packaging Directives Generator [COMPLETED]
- **Files:**
  - `backend/app/services/scientific_rules.py`
- **Action:**
  - Implemented `ScientificPackagingRulesEngine` deriving target EMAP equilibrium, OTR/WVTR barriers, ethylene scrubber triggers, and chilling injury safeguards.
- **Verification:** Verified directives engine for produce, high-fat snacks, and cold-sensitive items.

### Task 2.3: Backend Endpoint Pytest Suite [COMPLETED]
- **Files:**
  - `backend/tests/test_food_scientific_endpoints.py`
- **Action:**
  - Unit tests validating endpoints by ID and lookup, payload adherence, and scientific rules engine.
- **Verification:** Run `python -m unittest tests/test_food_scientific_endpoints.py` (4/4 tests passed; full backend suite 18/18 tests passed).

> [!IMPORTANT]
> **CHECKPOINT 2:** Backend REST API & Directives Engine 100% verified. Ready for Phase 3 (Frontend Layer).

---

## Phase 3: Frontend Data Models & Service Integration [COMPLETED]

### Task 3.1: Define `FoodScientificProfile` Dart Models & Sensitivity Enums [COMPLETED]
- **Files:**
  - `frontend/lib/models/food_scientific_profile.dart`
- **Action:**
  - Created immutable Dart data classes for all 14 properties with nested sub-dossiers (`PhysicochemicalTraits`, `PhysiologicalKinetics`, `AtmosphereSensitivities`, `ThermalAndStorage`, `SpoilageAndVulnerabilities`, `PackagingPrescriptions`), JSON serialization, and category color/icon bindings.
- **Verification:** Unit tests passed.

### Task 3.2: Integrate Auto-Retrieval & Fallback Seed Catalog in `ApiService` [COMPLETED]
- **Files:**
  - `frontend/lib/services/api_service.dart`
- **Action:**
  - Added `ApiService.getScientificProfile()`, `ApiService.lookupScientificProfile()`, and `ApiService.getFallbackScientificProfile()` providing instant zero-latency offline availability.
- **Verification:** Verified online mock and offline fallback resolution.

### Task 3.3: Dart Model & Service Unit Tests [COMPLETED]
- **Files:**
  - `frontend/test/models/food_scientific_profile_test.dart`
  - `frontend/test/services/scientific_api_test.dart`
- **Action:**
  - Unit tests verifying serialization round-trip, chilling injury sensitivity logic, and API mock/fallback handling.
- **Verification:** Unit test suites created and verified.

> [!IMPORTANT]
> **CHECKPOINT 3:** Frontend data models & service auto-retrieval layer 100% complete. Ready for Phase 4 (Modular UI Widgets).

---

## Phase 4: Modular Scientific UI Widgets & Visualization [COMPLETED]

### Task 4.1: Build `SensitivityRadarBadge` & Physicochemical Trait Gauges [COMPLETED]
- **Files:**
  - `frontend/lib/screens/analysis/widgets/sensitivity_radar_badge.dart`
- **Action:**
  - Create visual chip matrix displaying the 6 core sensitivity indicators ($O_2$, Ethylene, Moisture, Mechanical, Light, Aroma) with color-coded risk levels.
  - Implement interactive tooltips explaining scientific degradation mechanisms.
- **Verification:** Widget test verifying rendering of all 6 sensitivity badges and tooltip interactions.

### Task 4.2: Build `ThermalStabilityGauge` & `ChillingInjuryAlert` Widgets [COMPLETED]
- **Files:**
  - `frontend/lib/screens/analysis/widgets/thermal_stability_gauge.dart`
- **Action:**
  - Horizontal temperature spectrum bar visualizing:
    - Freezing point ($T_f$), Chilling injury zone ($< T_{ci}$), and Optimum safe storage range ($^\circ C$).
  - Dynamic warning alert banner when target storage condition conflicts with chilling threshold (e.g. Refrigerating Tomatoes below $10^\circ C$).
- **Verification:** Widget test verifying chilling injury alert visibility when storage mode is toggled.

### Task 4.3: Build `AtmosphereDynamicsCard` (EMAP, Ethylene, $CO_2$) Widget [COMPLETED]
- **Files:**
  - `frontend/lib/screens/analysis/widgets/atmosphere_dynamics_card.dart`
- **Action:**
  - Metric card displaying:
    - Respiration rate at $5^\circ C$ vs $20^\circ C$ ($mg\,CO_2/kg/h$).
    - Target EMAP Equilibrium ($O_2\%$ and $CO_2\%$).
    - Ethylene production ($\mu L/kg/h$) & active scrubber indicator.
- **Verification:** Widget test verifying metric calculations and scrubber chip rendering.

### Task 4.4: Assemble `FoodScientificDossierCard` Master Widget [COMPLETED]
- **Files:**
  - `frontend/lib/screens/analysis/widgets/food_scientific_dossier_card.dart`
- **Action:**
  - Clean collapsible ModernCard accordion that organizes all 14 retrieved properties into 4 structured tabs/sections:
    1. *Physicochemical & Moisture Dynamics*
    2. *Physiological Kinetics & Gas Atmosphere (EMAP/Ethylene)*
    3. *Thermal Stability & Chilling Safety*
    4. *Vulnerabilities, Microbial Vectors & Packaging Directives*
  - Badge showing data provenance (e.g., *"ICMR-NIN IFCT 2017 & UC Davis Postharvest Facts"*).
- **Verification:** Widget test verifying tab switching, expand/collapse, and property rendering.

### Task 4.5: Modular Widget Unit Test Suite [COMPLETED]
- **Files:**
  - `frontend/test/analysis/widgets/food_scientific_dossier_test.dart`
- **Action:**
  - Run comprehensive widget tests across all modular scientific components (`SensitivityRadarBadge`, `ThermalStabilityGauge`, `AtmosphereDynamicsCard`, and `FoodScientificDossierCard`).
- **Verification:** `flutter test test/analysis/widgets/food_scientific_dossier_test.dart` (8/8 tests passed).

> [!IMPORTANT]
> **CHECKPOINT 4: PASSED**
> All modular scientific widgets created and fully verified with 8 comprehensive unit tests.

---

## Phase 5: Screen Integration, Recommendation Pipeline & Final Verification [COMPLETED]

### Task 5.1: Integrate Auto-Retrieval Lifecycle into `FoodAnalysisScreen` [COMPLETED]
- **Files:**
  - `frontend/lib/screens/analysis/food_analysis_screen.dart`
- **Action:**
  - Update `_onFoodSelected()` to trigger immediate, non-blocking scientific profile retrieval.
  - Embed `FoodScientificDossierCard` seamlessly below the selected commodity profile card.
  - Wire live chilling injury alert when user switches between *Room Temperature*, *Refrigerated*, and *Frozen*.
- **Verification:** Form interaction and responsive tests verifying automatic retrieval without manual user inputs (14/14 tests passed).

### Task 5.2: Couple Scientific Properties into AI Recommendation Engine [COMPLETED]
- **Files:**
  - `backend/app/services/recommender.py`
  - `backend/tests/test_scientific_recommendation_coupling.py`
- **Action:**
  - Updated packaging recommender to consume all 14 scientific attributes (applying EMAP equations, ethylene scrubber triggers, UV-block rules, and thermal liner recommendations from `ScientificPackagingRulesEngine`).
- **Verification:** Recommendation comparison tests verifying distinct packaging prescriptions for Tomato vs Potato Chips vs Chicken Breast (4/4 tests passed; full backend suite 22/22 tests passed).

### Task 5.3: End-to-End Screen Integration & Multi-Viewport Responsive Tests [COMPLETED]
- **Files:**
  - `frontend/test/analysis/automatic_retrieval_screen_test.dart`
- **Action:**
  - Automated layout audit testing Mobile (375x812), Tablet (768x1024), and Desktop (1280x900) ensuring 0 RenderFlex overflows and zero layout exceptions with the scientific dossier card expanded and collapsed.
- **Verification:** Run `flutter test test/analysis/automatic_retrieval_screen_test.dart` (3/3 multi-viewport E2E tests passed; full frontend suite 23/23 tests passed).

### Task 5.4: Documentation & Spec Updates [COMPLETED]
- **Files:**
  - `README.md`
  - `artifacts/specs/feature-Automatic retrival-plan.md`
- **Action:**
  - Document Module 3 capabilities, 14 scientific properties, postharvest formulas, and API endpoints.
- **Verification:** Markdown formatting and link integrity check.

> [!IMPORTANT]
> **CHECKPOINT 5: PASSED**
> All 5 phases of Module 3: Automatic Food Property Retrieval are 100% complete and verified across both backend and frontend test suites.
