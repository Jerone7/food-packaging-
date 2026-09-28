# SmartPack AI - Sustainable Packaging Recommender

An AI-driven decision-support platform built with **Flutter (Dart)**, **FastAPI (Python)**, and **PostgreSQL** that correlates food commodity biochemical traits (moisture, pH, fat, respiration) with optimal polymer barrier performance (OTR, WVTR), box geometry, and sustainable cushioning materials.

---

## 🌟 Key Features

1. **SmartPack AI Home Landing Experience:**
   - **Hero Section:** High-impact value proposition with sustainability chips, sample recommendation preview card, and instant "Start Analysis" CTAs.
   - **3-Step Workflow:** *Select Food Commodity $\rightarrow$ Analyze Chemical Needs $\rightarrow$ Recommend Optimized Packaging*.
   - **Core Advantages:** Shelf-life protection (OTR/WVTR matching), eco-friendly polymer alternatives (PLA/Kraft), dimensional volume optimization, and peer-reviewed science backing.
   - **Knowledge Base Preview:** 8+ food categories covering 540+ items from the **ICMR-NIN IFCT 2017** database.
   - **About & Provenance:** Scientific citations (NIN, USDA FoodData Central, FAO) and full stack technology details.

2. **Module 2: Food Commodity Selection & Parameter Configuration:**
   - **7-Category Taxonomy:** Direct filtering across *Fruits, Vegetables, Grains, Dairy, Meat, Bakery, Other perishables*.
   - **Debounced Autocomplete Search:** Instant querying across 540+ items with biochemical attribute preview.
   - **Biochemical Trait Profile:** Live gauges for Moisture %, Fat %, pH, and Respiration Rate class with expandable custom recipe parameter overrides.
   - **Multi-Unit Quantity Selector:** Input amounts in `kg`, `g`, `tonnes`, or individual `units` with live SI kilogram normalization.
   - **Storage Condition Engine:** 4 storage regimes (*Room Temperature, Refrigerated, Frozen, Controlled Atmosphere*) with customizable duration (Days/Weeks/Months).
   - **Logistics & Cold-Chain Accordion:** Optional transportation condition parameters (*Ambient Road, Reefer Truck, Air Freight, Sea Container*) and fragility sensitivity.
   - **Recently Selected Foods Cache:** In-memory LRU cache bar for 1-click commodity re-selection.

3. **Module 3: Automatic Food Property Retrieval ("Zero Manual Scientific Data Entry"):**
   - **14 Empirical Biochemical & Postharvest Properties:**
     1. *Moisture Content (%)*
     2. *Moisture Sensitivity*
     3. *Respiration Rate ($5^\circ\text{C}$ & $20^\circ\text{C}$ in $\text{mg}\,\text{CO}_2/\text{kg}/\text{h}$)*
     4. *Oxygen ($O_2$) Sensitivity*
     5. *Carbon Dioxide ($CO_2$) Sensitivity & Maximum Tolerable Limit*
     6. *Ethylene Production Rate ($\mu\text{L}/\text{kg}/\text{h}$)*
     7. *Ethylene Sensitivity*
     8. *Perishability Tier*
     9. *Temperature Sensitivity & Chilling Injury Threshold ($T_{ci}$ in $^\circ\text{C}$)*
     10. *Light / Photo-Oxidation Sensitivity*
     11. *Aroma Scalping & Odor Sensitivity*
     12. *Microbial Spoilage Vector (Botrytis, Alternaria, Penicillium, Pseudomonas, etc.)*
     13. *Mechanical Damage Sensitivity*
     14. *Multi-Tier Shelf Life (Ambient, Cold Storage, CA/MAP)*
   - **Modular UI Visualization:**
     - `FoodScientificDossierCard`: Master collapsible accordion with confidence score and data provenance.
     - `SensitivityRadarBadge`: Color-coded 6-vector vulnerability badges (*Critical, High, Moderate, Low, Insensitive*).
     - `ThermalStabilityGauge`: Temperature spectrum visualization with dynamic **Chilling Injury Warning Banners** when produce is subjected to $T < T_{ci}$.
     - `AtmosphereDynamicsCard`: Gas equilibrium targets (EMAP $O_2\%/CO_2\%$) and active $\text{KMnO}_4$ ethylene scrubber mandates.

4. **Module 4: Food Analysis Dashboard (Visual Analytics & Diagnostic Cockpit):**
   - **Critical Vulnerability Banner:** Instantly flags urgent degradation triggers (*Chilling Injury below 10°C, High Metabolic Respiration, Desiccation Risk, Ethylene Segregation Rules*).
   - **High / Medium / Low Indicator Bar Matrix (`SensitivityBarMatrix`):** 8 normalized progress bars (*Moisture, Respiration, Oxygen, Perishability, Temperature, Ethylene, Mechanical, Light*) with quantitative readouts, color levels, and expandable physical packaging consequence cards.
   - **6-Axis Characteristics Radar Chart (`CharacteristicsRadarChart`):** Custom canvas spider visualization with 5 concentric polygon reference grid rings, smooth gradient polygon fill, glowing vertices, radial labels, and interactive tap inspection HUD.
   - **Preservation & Shelf-Life Horizon Matrix (`ShelfLifeMatrixCard`):** 4-regime product durability comparison (*Ambient*, *Refrigerated*, *Frozen*, *MAP*) with **MAP Extension Multipliers** and an interactive **Arrhenius Temperature Degradation Simulator ($Q_{10} = 2.2$)**.
   - **Storage & Environmental Safeguards (`StorageRequirementsCard`):** Optimum temperature bands ($T_{safe}$), freezing point ($T_f$), chilling injury lock ($T_{ci}$), target RH% bands, and ethylene segregation directives.

5. **Module 5: AI/ML Hybrid Recommendation Engine & Optimization Cockpit:**
   - **Stage 1 (Deterministic Food Science & Biophysical Rule-Based Pruning):**
     - Mass-transfer barrier constraints ($OTR_{max}$, $WVTR_{max}$) matching food sensitivity.
     - Thermal stability ceilings, cryogenic sub-zero embrittlement floors ($T \le -10^\circ\text{C}$), and chilling injury locks ($T < T_{ci}$).
     - High-metabolic respiring produce breathable EMAP film matching.
     - Active packaging additive synthesis ($\text{KMnO}_4$ ethylene scrubbers, $O_2$ scavengers, food-grade desiccants, anti-fog surfactants, and $N_2$ gas flush).
   - **Stage 2 (Machine Learning + TOPSIS Multi-Criteria Decision Making):**
     - **Random Forest ML Polymer Classifier (`MLPackagingClassifier`):** 18-dimension feature vector mapping biochemical parameters to polymer class probability distributions.
     - **TOPSIS MCDM Ranking (`HybridRecommendationEngine`):** 5 weighted objective criteria: *Barrier Match (35%), Shelf-Life Horizon (25%), Sustainability Eco-Score (20%), Procurement Cost Efficiency (10%), Mechanical Puncture Buffer (10%)*.
     - **Multi-Alternative Prescription:** Generates primary recommendation plus 3 specialized alternatives: 🌿 *Eco-Champion*, 💰 *Economy Option*, and 🛡️ *High-Barrier Protection*.
   - **Volumetric Box Geometry & Cushioning Synthesis (`BoxGeometryAndXAIService`):**
     - Golden-ratio dimensional box allocation $(L \times W \times H)$ using commodity bulk densities and space utilization metrics ($> 65\%$).
     - Structural cushioning prescription (Honeycomb Kraft, Bio-Foam, Molded Pulp, Insulated Gel Packs).
   - **Explainable AI (XAI) Scientific Rationale Generator:**
     - Transparent, step-by-step biochemical justification explaining exact preservation physics and degradation prevention drivers.
   - **Modular Frontend Results Cockpit (`RecommendationResultsCockpit`):**
     - `PrimaryRecommendationCard`: Hero gauge, polymer structure badge, quantitative barrier metrics grid, active additives.
     - `AlternativeMaterialsMatrix`: Side-by-side interactive comparison matrix with 1-click material switching.
     - `BoxGeometryCard`: Dimensional box diagram, volume calculations, space utilization progress bar.
     - `ExplainableAiRationaleCard`: Transparent step-by-step scientific justification breakdown.

6. **Persistent PostgreSQL History:**
   - Stores every calculated packaging recommendation, commodity profile, and alternative trade-off for future audit and review.

---

## 🏗️ Project Architecture

```
AI Packaging recommender/
├── backend/
│   ├── app/
│   │   ├── api/v1/endpoints/
│   │   │   ├── food_data.py               # /foods, /categories, /categories-summary, /scientific-profile, /scientific-lookup
│   │   │   └── packaging.py               # /packaging/recommend, /packaging/history
│   │   ├── core/
│   │   │   ├── config.py                  # App settings & CORS configuration
│   │   │   └── scientific_catalog.py      # Empirical 14-property empirical postharvest catalog
│   │   ├── db/session.py                  # PostgreSQL async engine & session
│   │   ├── models/
│   │   │   ├── food_and_packaging.py      # Food, FoodScientificProperty, RespirationData, PackagingMaterial, Source
│   │   │   └── packaging.py               # PackagingRecommendation DB model
│   │   ├── schemas/
│   │   │   ├── food_scientific_properties.py # Pydantic schemas for 14 empirical properties
│   │   │   └── packaging.py               # Pydantic validation schemas
│   │   ├── services/
│   │   │   ├── recommender.py             # Packaging optimization logic coupled with scientific traits
│   │   │   └── scientific_rules.py        # Rules Engine for barrier, EMAP & chilling directives
│   │   └── main.py                        # FastAPI entry point
│   ├── data/                              # Cleaned CSV datasets & food_scientific_profiles.csv
│   ├── scripts/
│   │   ├── clean_and_save_csvs.py         # CSV sanitization
│   │   └── seed_database.py               # Database seeder for PostgreSQL
│   ├── tests/
│   │   ├── test_food_data_api.py          # API & Recommender unit tests
│   │   ├── test_food_selection_api.py     # Module 2 Food Search & Taxonomy pytest suite
│   │   ├── test_scientific_properties_models.py # Model & schema unit tests
│   │   ├── test_food_scientific_endpoints.py   # REST endpoint & lookup tests
│   │   └── test_scientific_recommendation_coupling.py # Recommender coupling unit tests
│   ├── .env
│   └── requirements.txt
├── frontend/
│   ├── lib/
│   │   ├── models/
│   │   │   ├── commodity_model.dart       # Category summary & preview models
│   │   │   ├── food_commodity.dart        # FoodCommodity & BiochemicalProfile models
│   │   │   ├── food_scientific_profile.dart # 14-property scientific profile Dart models
│   │   │   ├── storage_condition.dart     # StorageMode, QuantityUnit, TransportMode
│   │   │   ├── food_analysis_request.dart # FoodAnalysisRequest payload model
│   │   │   └── packaging_model.dart       # Recommendation input & result models
│   │   ├── screens/
│   │   │   ├── landing/
│   │   │   │   ├── home_page.dart         # Master Home Page screen
│   │   │   │   └── widgets/
│   │   │   │       ├── home_header.dart   # Top nav bar with anchor links
│   │   │   │       ├── hero_section.dart  # Hero branding & CTAs
│   │   │   │       ├── workflow_section.dart # 3-step visual pipeline
│   │   │   │       ├── benefits_section.dart # 4 key advantages grid
│   │   │   │       ├── food_preview_section.dart # 8 category cards
│   │   │   │       └── about_section.dart # Scientific provenance & footer
│   │   │   ├── analysis/
│   │   │   │   ├── food_analysis_screen.dart # Responsive 2-column food selection & calculator
│   │   │   │   └── widgets/
│   │   │   │       ├── food_analysis_dashboard.dart # Master visual analytics cockpit
│   │   │   │       ├── critical_vulnerability_banner.dart # Urgent degradation risk chips
│   │   │   │       ├── sensitivity_bar_matrix.dart # 8-row High/Med/Low bar indicators
│   │   │   │       ├── characteristics_radar_chart.dart # 6-axis CustomPainter spider visualization
│   │   │   │       ├── shelf_life_matrix_card.dart # 4-regime comparison & Arrhenius Q10 slider
│   │   │   │       ├── storage_requirements_card.dart # Environmental safeguards & T_ci alerts
│   │   │   │       ├── category_selector.dart # 7-category chip bar
│   │   │   │       ├── food_search_bar.dart   # Debounced autocomplete search
│   │   │   │       ├── recent_foods_bar.dart  # Quick-access LRU cache chips
│   │   │   │       ├── food_profile_card.dart # Biochemical gauges & override inputs
│   │   │   │       ├── food_scientific_dossier_card.dart # Collapsible master scientific dossier
│   │   │   │       ├── sensitivity_radar_badge.dart      # 6-vector sensitivity radar chips
│   │   │   │       ├── thermal_stability_gauge.dart       # Temperature spectrum & chilling alerts
│   │   │   │       ├── atmosphere_dynamics_card.dart     # Respiration, EMAP & ethylene gas cards
│   │   │   │       ├── quantity_unit_input.dart # Multi-unit numeric input
│   │   │   │       ├── storage_condition_card.dart # 4-mode storage selector
│   │   │   │       ├── storage_duration_input.dart # Duration & time unit selector
│   │   │   │       └── transport_condition_accordion.dart # Logistics & cold-chain accordion
│   │   │   └── history/
│   │   │       └── history_screen.dart    # Recommendation audit history
│   │   ├── services/
│   │   │   ├── api_service.dart           # HTTP client with searchFoods & scientific profile lookups
│   │   │   ├── food_analysis_normalizer.dart # Mathematical normalization, radar vectors & Q10 decay
│   │   │   └── recent_foods_service.dart  # LRU memory cache for recent selections
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Teal / Mint design tokens & typography
│   │   ├── widgets/
│   │   │   ├── brand_logo.dart            # SmartPack AI logo
│   │   │   ├── gradient_button.dart       # Hover-animated CTA buttons
│   │   │   ├── feature_badge.dart         # Eco & barrier indicator pills
│   │   │   └── modern_card.dart           # Rounded cards with hover elevation
│   │   └── main.dart                      # Flutter app entry point
│   ├── test/                              # Comprehensive Flutter unit, widget & integration tests
│   │   ├── models/
│   │   ├── services/
│   │   ├── analysis/                      # Food analysis screen & responsive tests
│   │   ├── analysis/widgets/              # 7 modular widget unit tests
│   │   └── landing/                       # Landing page & hero tests
│   └── pubspec.yaml
├── docker-compose.yml                     # PostgreSQL container configuration
└── README.md
```

---

## 🚀 Getting Started

### 1. Start PostgreSQL Database
```powershell
docker compose up -d
```

### 2. Seed Database with Food Commodities & Packaging Materials
```powershell
python backend/scripts/seed_database.py
```

### 3. Run FastAPI Backend
```powershell
cd backend
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```
- Swagger Documentation: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- Health Check: [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

### 4. Run Flutter Web / Desktop Client
```powershell
cd frontend
flutter pub get
flutter run -d chrome
# Or run on Windows desktop:
# flutter run -d windows
```

---

## 🧪 Testing

### Backend Test Suites
```powershell
cd backend
# Run all backend unit & API tests
python -m pytest tests/ -v
```

### Frontend Test Suite (Models, Services, Widgets, Screen Integration & Responsive Audit)
```powershell
cd frontend
flutter test
```
#   f o o d - p a c k a g i n g -  
 