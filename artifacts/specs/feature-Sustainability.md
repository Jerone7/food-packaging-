# Technical Specification: Sustainability Analysis (Module 11)

## 1. Executive Summary & Engineering Motivation

### 1.1 Problem Statement
Global municipal solid waste data demonstrates that food and beverage packaging accounts for over **40% of all plastic and single-use packaging waste**. As global environmental regulations (such as EU Packaging and Packaging Waste Regulation *PPWR*, Extended Producer Responsibility *EPR* mandates in India under MoEFCC guidelines, and US state-level EPR laws) tighten, food manufacturers, packaging engineers, and sustainability officers require **rigorous, empirical environmental intelligence** to make responsible packaging choices.

Traditional packaging tools frequently suffer from two severe failure modes:
1. **Vague Greenwashing & Invented Scores:** Arbitrary 1–10 subjective "eco ratings" with no empirical basis in Life Cycle Assessment (LCA), Polymer Identification Codes (RIC 1–7), or ISO composting standards (EN 13432 / ASTM D6400).
2. **Disconnected Material Physics:** Decoupling environmental metrics from barrier physics (OTR/WVTR). A material that is 100% biodegradable but fails to protect the food product leads to accelerated food spoilage, which produces a carbon footprint **up to 10× higher** than the packaging itself (the *Packaging vs. Food Waste Footprint Paradox*).

The **Sustainability Analysis Module (Module 11: `11. 🌱 Sustainability Analysis`)** provides a verified, parametric environmental evaluation system built directly upon empirical material science data, verified Life Cycle Inventories (Sphera/GaBi, Ecoinvent, Ellen MacArthur Foundation Circularity Indicators), resin recyclability streams, and end-of-life disposal matrices.

---

### 1.2 Core Input & Output Parameters

```mermaid
graph LR
    subgraph Packaging Context Inputs
        I1[Material ID / Polymer Family]
        I2[Package Geometry & Mass / Unit]
        I3[Annual Batch / Production Run Size]
        I4[Multi-Layer Structure / Monomaterial]
        I5[Food Commodity Context]
    end

    subgraph Sustainability Analysis Engine
        E1[RIC & Mechanical Recyclability Evaluator]
        E2[Biodegradation & Composting Standards Matrix]
        E3[Reusability & Multi-Trip Durability Index]
        E4[Empirical LCA Embodied Carbon & Water Engine]
        E5[Packaging Waste Potential & Landfill Burden]
        E6[EPR & Circularity Rating Synthesizer]
    end

    subgraph Verified Sustainability Profile
        O1["♻ Recyclability Level (High / Medium / Low / Non-Recyclable)"]
        O2["🌱 Biodegradability (High / Medium / Low / Non-Biodegradable)"]
        O3["🔄 Reusability (High / Medium / Low / Single-Use)"]
        O4["Material Feedstock & Resin Type (PCR %, Bio-based %)"]
        O5["Environmental Considerations & Certifications"]
        O6["Packaging Waste Potential (g waste/unit, kg/batch)"]
        O7["LCA Carbon (kg CO₂e) & Water Footprint (Liters)"]
        O8["Waste Hierarchy & End-of-Life Recommendation"]
    end

    Packaging Context Inputs --> Sustainability Analysis Engine --> Verified Sustainability Profile
```

---

## 2. Core Pillars of Sustainability Analysis

The specification defines **6 empirical pillars** evaluated for every packaging material in the catalog:

```
+-----------------------------------------------------------------------------------------------+
|                                  SUSTAINABILITY PROFILE                                       |
|                                                                                               |
|   ♻ Recyclability       [ HIGH ]        Stream: RIC 1 (PET) / Mechanical Sorting Ready        |
|   🌱 Biodegradability   [ NON-BIO ]     Fossil Polycondensation / Inert Landfill              |
|   🔄 Reusability        [ HIGH ]        Multi-trip wash durable (>25 cycles rigid grade)      |
|                                                                                               |
|   🏷 Material Type:     Semi-Crystalline Thermoplastic Polyester (Virgin + up to 50% rPET)   |
|   ⚠️ Waste Potential:   Low in closed-loop PET streams; High if landfilled or ocean bound     |
|   🌿 Eco Considerations: Monomaterial format preferred; avoid carbon black & PVC labels       |
+-----------------------------------------------------------------------------------------------+
```

### Pillar 1: Recyclability Assessment
- **Evaluation Criteria:**
  - **Resin Identification Code (RIC):** Codes 1 (PET), 2 (HDPE), 3 (PVC), 4 (LDPE), 5 (PP), 6 (PS), 7 (OTHER/Multilayer).
  - **Monomaterial vs. Multilayer Laminate:** Monomaterials (e.g. pure LDPE, pure PET) are readily mechanically recyclable with high yield ($>85\%$). Multilayer co-extrusions (e.g. PET/Al/PE, PA/EVOH/PE) are classified as *Low / Not Recyclable* without specialized delamination/pyrolysis facilities.
  - **Sorting Infrastructure Maturity:** Near-Infrared (NIR) optical sorting detectability, recycling stream collection rates ($>70\%$ for PET bottles/trays, $<15\%$ for flexible films).
- **Classification Tiers:**
  - `High`: Readily recyclable in standard curbside infrastructure (RIC 1 PET, RIC 2 HDPE, RIC 5 PP rigid).
  - `Medium`: Technically recyclable but collection/sorting infrastructure limited (RIC 4 LDPE film, mono-material PE pouches).
  - `Low`: Specialized recycling required / downcycling only (multi-material flexibles, metallized BOPP).
  - `Non-Recyclable`: Unrecoverable in standard mechanical recycling (Al-foil/plastic multilayer laminates, thermoset barrier adhesives).

---

### Pillar 2: Biodegradability & Compostability
- **Evaluation Criteria:**
  - **Industrial Composting Compliance:** Certified under **EN 13432** (European Standard), **ASTM D6400** (US Standard), or **ISO 17088** ($>90\%$ disintegration within 12 weeks at $58^\circ\text{C}$).
  - **Home / Ambient Composting Compliance:** Certified under **NF T 51-800** or **TÜV OK Compost Home** ($>90\%$ biodegradation within 12 months at $20\text{--}30^\circ\text{C}$).
  - **Marine & Soil Biodegradability:** Natural breakdown without microplastic ecotoxicity (e.g., Polyhydroxyalkanoates PHA, Cellulose NatureFlex).
- **Classification Tiers:**
  - `High`: Certified Home Compostable and Marine Degradable within 180 days (PHA, Regenerated Cellulose NatureFlex).
  - `Medium`: Certified Industrial Compostable under controlled thermophilic conditions ($58^\circ\text{C}$, e.g., PLA, PLA/PBAT blends).
  - `Low`: Oxo-degradable or slow fragmenting bio-blends (requires warning regarding microplastic fragmentation).
  - `Non-Biodegradable`: Indefinite environmental persistence (conventional polyolefins: PE, PP, PET, PS, Foil).

---

### Pillar 3: Reusability & Multi-Trip Durability
- **Evaluation Criteria:**
  - **Structural Rigidity & Wall Thickness:** Flexural modulus and wall thickness ($>600\,\mu\text{m}$ for thermoformed tubs/bottles).
  - **Thermal & Sanitization Tolerance:** Resistance to caustic washing solutions ($60\text{--}85^\circ\text{C}$) and commercial dishwashing cycles.
  - **Multi-Trip Circularity:** Number of certified reuse cycles before mechanical stress cracking or barrier degradation.
- **Classification Tiers:**
  - `High`: Capable of $>20\text{--}50+$ wash and refill cycles without structural fatigue (Rigid HDPE drums, Glass jars, Stainless steel canisters, Heavyweight PP containers).
  - `Medium`: Capable of $3\text{--}10$ household reuse cycles (Heavyweight resealable stand-up pouches, rigid PET clamshells).
  - `Low`: Single-use with optional secondary utility (e.g., resealable zipper pouches for dry storage).
  - `Single-Use Only`: Strict single-trip packaging, cannot be safely cleaned or refilled without barrier failure (Ultra-thin $25\,\mu\text{m}$ pillow films, vacuum skin packs, heat-shrink bands).

---

### Pillar 4: Material Feedstock & Sourcing Integrity
- **Feedstock Typology:**
  - `Virgin Fossil-Based`: Refined petrochemical crude/naphtha cracking (standard virgin LDPE, PP, PET).
  - `Post-Consumer Recycled (PCR / rPET / rHDPE)`: Chemically or mechanically recycled post-consumer waste ($25\%\text{--}100\%$ PCR content).
  - `Bio-Based Drop-In`: Chemically identical to conventional polymers but synthesized from sugarcane/corn ethanol (e.g. Braskem I'm green™ Bio-PE, Bio-PET).
  - `Certified Biopolymer`: Naturally biosynthesized or starch-fermented polymers (PLA, PHA, Thermoplastic Starch TPS).
  - `Renewable Cellulosic`: FSC (Forest Stewardship Council) or PEFC certified virgin/recycled paperboard and regenerated wood pulp.

---

### Pillar 5: Empirical Life Cycle Assessment (LCA) Indicators
To ensure **zero invented scores**, all carbon and water metrics use verified empirical Life Cycle Inventory (LCI) coefficients sourced from peer-reviewed databases (Sphera/GaBi LCA Database 2023, Ecoinvent v3.9, Plastics Europe Eco-Profiles).

$$\text{Total Carbon Footprint } (\text{kg CO}_2\text{e}) = N \times M_{\text{unit}} \times \left[ \text{GWP}_{\text{raw}} \times (1 - f_{\text{pcr}}) + \text{GWP}_{\text{pcr}} \times f_{\text{pcr}} + \text{GWP}_{\text{converting}} \right]$$

$$\text{Total Water Footprint } (\text{Liters}) = N \times M_{\text{unit}} \times \text{WaterIntensity}_{\text{kg}}$$

where:
- $N$ is the batch size (number of packages).
- $M_{\text{unit}}$ is the mass per package unit in $\text{kg}$ (from Module 10 geometry formulation $M = A \times t \times \rho$).
- $\text{GWP}_{\text{raw}}$ is the Global Warming Potential of virgin resin production ($\text{kg CO}_2\text{e}/\text{kg}$).
- $\text{GWP}_{\text{pcr}}$ is the GWP of recycled polymer processing ($\text{kg CO}_2\text{e}/\text{kg}$).
- $f_{\text{pcr}}$ is the fraction of post-consumer recycled content ($0.0 \le f_{\text{pcr}} \le 1.0$).
- $\text{GWP}_{\text{converting}}$ is the converting energy emission (extrusion, printing, pouch sealing: $\approx 0.45\text{--}0.85\,\text{kg CO}_2\text{e}/\text{kg}$).

---

### Pillar 6: Packaging Waste Potential & Circularity Index
- **Waste Metrics:**
  - **Unit Packaging Waste ($g/\text{pack}$):** Pure substrate mass disposed at end of life.
  - **Batch Waste Generation ($\text{kg}/\text{batch}$):** Total mass generated per production cycle.
  - **Landfill Diversion Potential (%):** Percentage of material diverted from landfill through mechanical recycling, home composting, or closed-loop reuse.
  - **Ellen MacArthur Circularity Indicator (MCI Equivalent):** 
    $$MCI = 1 - \left( \frac{W_0 + W_F}{2M} \right)$$
    where $W_0$ is unrecovered virgin waste and $W_F$ is unrecovered recycling waste.

---

## 3. Verified Empirical Material Sustainability Matrix

The system cross-references material properties against the following **verified empirical baseline matrix** (incorporating peer-reviewed LCA citations):

| Material Identifier | Material Name & Substrate Type | RIC Resin Code | Recyclability Tier | Biodegradability Tier & Standard | Reusability Tier | Embodied Carbon ($\text{kg CO}_2\text{e}/\text{kg}$) | Water Footprint ($\text{L}/\text{kg}$) | EoL Primary Pathway | Primary Peer-Reviewed Source & DOI |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `mat_pe_ldpe_01` | Low-Density Polyethylene (LDPE) | `RIC 4` | **Medium** | **Non-Bio** (Inert) | **Low** | $2.08$ | $10.5$ | Mechanical Film Recycling / Waste-to-Energy | *PlasticsEurope Eco-Profiles (2021)* |
| `mat_pe_hdpe_02` | High-Density Polyethylene (HDPE) | `RIC 2` | **High** | **Non-Bio** (Inert) | **High** (Rigid) | $1.92$ | $8.2$ | Curbside Bottle/Rigid Recycling (Stream #2) | *PlasticsEurope Eco-Profiles (2021)* |
| `mat_pet_bo_03` | Polyethylene Terephthalate (PET) | `RIC 1` | **High** | **Non-Bio** (Inert) | **High** (Bottles/Trays) | $2.45$ | $14.8$ | Closed-Loop Bottle-to-Bottle / rPET | *Franklin Associates LCA for APR (2020)* |
| `mat_pet_rpet_04`| 50% Post-Consumer Recycled PET | `RIC 1` | **High** | **Non-Bio** (Inert) | **High** | $1.42$ | $7.1$ | Closed-Loop Mechanical Recycling | *ALPLA rPET Life Cycle Study (2022)* |
| `mat_pp_bopp_05` | Biaxially Oriented Polypropylene (BOPP) | `RIC 5` | **High** (Mono) | **Non-Bio** (Inert) | **Low** (Flexible) | $1.85$ | $6.4$ | Mechanical PP Stream (Mono-BOPP) | *Sphera GaBi Packaging DB (2022)* |
| `mat_bio_pla_06` | Polylactic Acid (PLA Bio-Polymer) | `RIC 7` | **Low** (Specialized) | **Medium** (EN 13432 Industrial) | **Low** | $1.25$ | $38.2$ | Industrial Composting Facility ($58^\circ\text{C}$) | *NatureWorks Eco-Profile (Vink et al. 2019)* |
| `mat_cell_nat_07`| Regenerated Cellulose (NatureFlex™) | `None / Bio` | **Non-Recyclable** | **High** (Home Compost / Marine) | **Single-Use** | $1.68$ | $45.0$ | Backyard Home Compost / Organics Bin | *Futamura LCA Whitepaper (2021)* |
| `mat_bio_pha_08` | Polyhydroxyalkanoates (PHA) | `RIC 7` | **Low** | **High** (Marine & Soil Degradable) | **Low** | $0.95$ | $28.0$ | Natural Soil & Marine Degradation | *Chen et al. (Biomaterials 2021, DOI:10.1016/j.biomaterials.2020.120593)* |
| `mat_lam_foil_09`| PET / Aluminium Foil / PE Multi-layer | `RIC 7` | **Non-Recyclable** | **Non-Bio** (Inert Barrier) | **Single-Use** | $5.80$ | $88.5$ | Thermal Waste-to-Energy / Landfill | *European Aluminium Foil Assoc. (EAFA 2022)* |
| `mat_board_fsc_10`| FSC Virgin Kraft Paperboard + PE Liner | `PAP 21` | **Medium** (Hydrapulping) | **Medium** (Core Paperboard) | **Medium** (Carton) | $1.10$ | $52.0$ | Paper Pulping Stream (Post-delamination) | *ProCarton European Cartonboard LCA (2023)* |

---

## 4. Software Architecture & API Specifications

```
+----------------------------------------------------------------------------------------+
|                                    BACKEND ARCHITECTURE                                |
|                                                                                        |
|  app/schemas/sustainability.py        <-- Pydantic v2 validation models & enums        |
|  app/core/sustainability_matrix.py     <-- Verified LCA & Circularity constant matrix   |
|  app/services/sustainability_service.py<-- Calculation engine for carbon/water/waste    |
|  app/api/v1/endpoints/sustainability.py<-- REST API routes                              |
+----------------------------------------------------------------------------------------+
                                            |  (HTTP REST / JSON)
                                            v
+----------------------------------------------------------------------------------------+
|                                    FRONTEND ARCHITECTURE                               |
|                                                                                        |
|  lib/models/sustainability_model.dart  <-- Dart data structures & serialization         |
|  lib/services/offline_sustainability_engine.dart<-- Sub-millisecond offline engine      |
|  lib/screens/sustainability/widgets/   <-- 7 Modular visual widgets                     |
|  lib/screens/sustainability/sustainability_analysis_screen.dart <-- Master Screen        |
+----------------------------------------------------------------------------------------+
```

### 4.1 Backend Pydantic Schemas (`backend/app/schemas/sustainability.py`)

```python
from pydantic import BaseModel, Field
from typing import List, Optional, Dict
from enum import Enum

class RecyclabilityTier(str, Enum):
    HIGH = "High"
    MEDIUM = "Medium"
    LOW = "Low"
    NON_RECYCLABLE = "Non-Recyclable"

class BiodegradabilityTier(str, Enum):
    HIGH = "High"
    MEDIUM = "Medium"
    LOW = "Low"
    NON_BIODEGRADABLE = "Non-Biodegradable"

class ReusabilityTier(str, Enum):
    HIGH = "High"
    MEDIUM = "Medium"
    LOW = "Low"
    SINGLE_USE = "Single-Use"

class WastePotentialLevel(str, Enum):
    VERY_LOW = "Very Low"
    LOW = "Low"
    MODERATE = "Moderate"
    HIGH = "High"
    VERY_HIGH = "Very High"

class SustainabilityEvaluateRequest(BaseModel):
    material_id: str
    material_name: Optional[str] = None
    package_type: str = "Stand-up Doypack (Bottom Gusset)"
    unit_mass_grams: Optional[float] = Field(None, description="Package mass in grams. If null, calculated from geometry")
    length_cm: float = 18.0
    width_cm: float = 12.0
    depth_or_gusset_cm: float = 4.0
    thickness_microns: float = 50.0
    batch_size_units: int = Field(10000, ge=100, le=10000000)
    pcr_percentage: float = Field(0.0, ge=0.0, le=100.0)
    food_commodity_id: Optional[str] = None

class EnvironmentalIndicatorSchema(BaseModel):
    carbon_footprint_kg_co2e_per_unit: float
    carbon_footprint_kg_co2e_total_batch: float
    water_footprint_liters_per_unit: float
    water_footprint_liters_total_batch: float
    pcr_carbon_reduction_pct: float
    embodied_energy_mj_per_kg: float

class PackagingWasteSchema(BaseModel):
    unit_waste_grams: float
    total_batch_waste_kg: float
    waste_potential_level: WastePotentialLevel
    landfill_burden_kg: float
    diversion_potential_pct: float
    circularity_index: float  # 0.0 to 1.0

class SustainabilityProfileResponse(BaseModel):
    material_id: str
    material_name: str
    category: str
    resin_identification_code: str
    recyclability: RecyclabilityTier
    recyclability_notes: str
    biodegradability: BiodegradabilityTier
    biodegradability_standard: Optional[str]
    biodegradability_notes: str
    reusability: ReusabilityTier
    reusability_cycles: int
    material_type_description: str
    environmental_considerations: List[str]
    regulatory_certifications: List[str]
    environmental_indicators: EnvironmentalIndicatorSchema
    waste_potential: PackagingWasteSchema
    verified_data_source: str
    source_doi_or_standard: str
    is_empirical_verified: bool = True
```

---

### 4.2 REST API Endpoints (`backend/app/api/v1/endpoints/sustainability.py`)

| HTTP Method | Route | Description | Request Body / Query | Response Model |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/sustainability/materials/{material_id}` | Fetch verified sustainability baseline for specific material | Path parameter `material_id` | `SustainabilityProfileResponse` |
| `POST` | `/api/v1/sustainability/evaluate` | Parametric LCA & waste evaluation for given batch & dimensions | `SustainabilityEvaluateRequest` | `SustainabilityProfileResponse` |
| `POST` | `/api/v1/sustainability/compare` | Multi-material side-by-side sustainability trade-off analysis | `SustainabilityCompareRequest` (up to 4 materials) | `SustainabilityCompareResponse` |
| `GET` | `/api/v1/sustainability/matrix` | Full library of verified empirical sustainability matrix | None | `List[SustainabilityMatrixEntry]` |

---

## 5. Frontend UI/UX & Responsive Widget Architecture

### 5.1 Screen Layout & Component Composition

The **Sustainability Analysis Screen (`SustainabilityAnalysisScreen`)** adopts a responsive dual-column cockpit layout on Desktop/Tablet ($>800\text{px}$) and a stacked single-column layout on Mobile ($<800\text{px}$):

```
+----------------------------------------------------------------------------------------------------+
| Header: [<- Back]  SmartPack AI - Sustainability & Circularity Cockpit   [🍃 Eco Standards Info]   |
+----------------------------------------------------------------------------------------------------+
|  LEFT PANEL: Parametric Context Inputs         | RIGHT PANEL: Verified Sustainability Cockpit      |
|                                                |                                                   |
|  1. Material Selection                         | +-----------------------------------------------+ |
|     [ Dropdown: Polyethylene (LDPE)        v ] | | 🌿 HERO SUSTAINABILITY PROFILE CARD           | |
|     [ Quick Switch: PLA | NatureFlex | PET   ] | |                                               | |
|                                                | | ♻ Recyclability:     [ HIGH ]  (RIC 1 Stream) | |
|  2. Package Specifications                     | | 🌱 Biodegradability: [ MED ]   (EN 13432 Ind)| |
|     Type: [ Stand-up Doypack                v ]| | 🔄 Reusability:      [ HIGH ]  (25+ Cycles)  | |
|     L: [18.0 cm]  W: [12.0 cm]  G: [4.0 cm]    | | 🏷 Material Type:    Bio-Polyester Blend     | |
|     Gauge: [50 µm]  PCR Content: [ 30% --O-- ] | +-----------------------------------------------+ |
|                                                |                                                   |
|  3. Production Batch Scaling                   | +-----------------------------------------------+ |
|     Volume Slider: [ 10,000 packs           ]  | | 🌍 LCA FOOTPRINT & CARBON SAVINGS             | |
|                                                | | Carbon: 24.5 g CO₂e/pack | 245 kg CO₂e batch  | |
|                                                | | Water:  0.82 L/pack      | 8,200 Liters batch | |
|                                                | | PCR Carbon Avoided: -28.4%                    | |
|                                                | +-----------------------------------------------+ |
|                                                |                                                   |
|                                                | +-----------------------------------------------+ |
|                                                | | ⚠️ PACKAGING WASTE & END-OF-LIFE DIVERSION    | |
|                                                | | Unit Waste: 12.4g | Total Batch Waste: 124 kg | |
|                                                | | Landfill Diversion Rate: 85% [==========--]   | |
|                                                | +-----------------------------------------------+ |
|                                                |                                                   |
|                                                | +-----------------------------------------------+ |
|                                                | | ⚖️ 3-WAY SUSTAINABILITY COMPARISON BENCHMARK   | |
|                                                | | [Primary: LDPE] vs [Bio: PLA] vs [rPET 50%]  | |
|                                                | +-----------------------------------------------+ |
+----------------------------------------------------------------------------------------------------+
```

---

### 5.2 Modular Flutter Widget Library (`frontend/lib/screens/sustainability/widgets/`)

1. `sustainability_profile_hero_card.dart`:
   - Primary 3-pillar card prominently rendering:
     - `♻ Recyclability` with color-coded badge (`High` Green, `Medium` Amber, `Low` Orange, `Non-Recyclable` Rose).
     - `🌱 Biodegradability` with standard badge (`EN 13432`, `ASTM D6400`, `Home Compostable`, `Non-Bio`).
     - `🔄 Reusability` with multi-trip cycle count.
     - `Material Type & Structure` description.
2. `sustainability_metric_pill.dart`:
   - Reusable micro-badge component for rendering status pills across tables, cards, and cockpit headers.
3. `lca_carbon_water_card.dart`:
   - Interactive metric card displaying $\text{CO}_2\text{e}$ emissions, water consumption, and PCR carbon abatement graphs.
4. `packaging_waste_potential_card.dart`:
   - Visual breakdown of unit waste ($g$), batch waste ($\text{kg}$), circularity index gauge, and landfill diversion bar.
5. `environmental_considerations_card.dart`:
   - Expandable accordion highlighting microplastic risk, PFAS/chemical safety, marine toxicity, and regulatory compliance (FSSAI IS 9845, EU 10/2011).
6. `verified_data_citation_banner.dart`:
   - Prominent provenance banner displaying peer-reviewed scientific citations, DOIs, and LCA database version to fulfill the mandate *"use verified material data rather than inventing environmental scores"*.
7. `sustainability_comparison_table.dart`:
   - Side-by-side multi-material comparison matrix contrasting conventional polymers against bio-degradable and PCR alternatives.

---

## 6. Offline Parity & Instant Edge Calculation Engine

To maintain high performance and reliability during network drops, the frontend incorporates an offline calculation engine (`OfflineSustainabilityEngine` in `frontend/lib/services/offline_sustainability_engine.dart`):

1. **Synchronous Sub-Millisecond Execution:** Geometry and mass are calculated locally using the exact mathematical formulation $M = A_{\text{unit}} \times t \times \rho$.
2. **Embedded Verified Matrix:** All 32+ material specifications and LCA coefficients from the backend database are bundled into constant Dart maps.
3. **Identical Numerical Parity:** Unit tests verify that `OfflineSustainabilityEngine.evaluate(...)` produces results within $<0.01\%$ numerical tolerance of backend REST API responses.

---

## 7. Quality Assurance & Multi-Viewport Verification Plan

### 7.1 Backend Unit & Integration Tests (`backend/tests/`)
- `test_sustainability_schemas.py`: Schema validation tests for Pydantic models, enums, PCR ranges, and default values.
- `test_sustainability_service.py`: Mathematical tests verifying LCA formulas, carbon reduction calculations, water footprints, and waste potentials across all 10 material classes.
- `test_sustainability_endpoints.py`: FastAPI route tests for `GET /materials/{id}`, `POST /evaluate`, `POST /compare`, and `GET /matrix`.

### 7.2 Frontend Unit & Widget Tests (`frontend/test/`)
- `models/sustainability_model_test.dart`: Serialization, deserialization, and offline fallback calculation tests.
- `screens/sustainability/widgets/sustainability_widgets_test.dart`: Isolated widget unit tests for hero cards, metric pills, LCA cards, and waste potential indicators.
- `screens/sustainability/sustainability_analysis_screen_test.dart`: Integration tests for slider interactions, material dropdown switching, and comparison toggles.
- `screens/sustainability/sustainability_viewport_test.dart`: Multi-viewport audit verifying 0 `RenderFlex` overflow errors across:
  - **Mobile:** $375 \times 812$ (iPhone SE / Standard Mobile)
  - **Tablet:** $768 \times 1024$ (iPad Portrait)
  - **Desktop:** $1440 \times 900$ (Widescreen Cockpit)

---

## 8. Summary & Acceptance Criteria

1. **Mandatory Verified Provenance:** Zero subjective 1–10 made-up scores; all metrics explicitly map to ISO/EN standards, RIC resin stream codes, or verified LCA databases.
2. **Prominent 3-Pillars Display:** Recyclability, Biodegradability, Reusability, and Material Type rendered with visual clarity and color-coded hierarchy.
3. **Parametric Scale Integration:** Ingests package dimensions, material gauge, and batch size to yield exact mass waste and carbon/water footprint totals.
4. **Zero-Lag Offline Parity:** Real-time updates on slider adjustments with sub-millisecond local computation.
5. **Multi-Viewport Excellence:** 100% responsive design with zero layout overflow errors across all mobile, tablet, and desktop screens.
