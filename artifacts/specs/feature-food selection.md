# Technical Specification: Food Commodity Selection (Module 2)

## 1. Overview & Objectives

### 1.1 Purpose
The **Food Commodity Selection** module is the foundational input engine of SmartPack AI. It allows food manufacturers, packaging engineers, and agritech operators to specify the exact food commodity requiring packaging, configure production quantity and target logistics/storage environments, and automatically retrieve verified biochemical properties (Moisture %, Fat %, pH, Respiration class, and Oxygen/Moisture sensitivity) from empirical scientific databases (IFCT 2017, USDA, CRFS).

### 1.2 Target User Goals
- **Instant Search & Autocomplete:** Quickly locate any food item from over 540+ IFCT food profiles and processed foods.
- **Categorical Exploration:** Filter commodities across standard agricultural and processed categories (*Fruits, Vegetables, Grains, Dairy, Meat, Bakery, Other perishables*).
- **Environment & Logistics Modeling:** Configure operational storage conditions (*Room Temperature, Refrigerated, Frozen, Controlled Atmosphere*), storage durations, and transit modes.
- **Biochemical Transparency:** Inspect auto-populated biochemical parameters (Moisture, Fat, pH, $a_w$) with optional custom overrides for customized recipes.
- **Accelerated Workflow:** Re-select recently evaluated foods with one click via a local history cache.

---

## 2. System Architecture & Component Hierarchy

### 2.1 Component Flow Diagram
```mermaid
graph TD
    A[Food Commodity Selection Interface] --> B[Category Filter Chips]
    A --> C[Live Search & Autocomplete]
    A --> D[Recently Selected Foods Carousel]
    
    B --> E[Filtered Commodity Grid / List]
    C --> F[Debounced API Search / Local Cache]
    D --> G[Instant Selection]
    
    E --> H[Selected Commodity Profile Card]
    F --> H
    G --> H
    
    H --> I[Biochemical Specs Preview (Moisture, Fat, pH, Respiration)]
    
    A --> J[Quantity & Unit Selector (kg, g, tonnes, units)]
    A --> K[Storage Condition Selector (Room, Refrig, Frozen, CA)]
    A --> L[Expected Storage Duration (Days/Weeks/Months)]
    A --> M[Optional Transport Condition (Ambient, Cold Chain, Reefer)]
    
    H & J & K & L & M --> N[Validation & Submission Layer]
    N -->|'Analyze Food' CTA| O[Biochemical Analysis & Packaging Recommendation Engine]
```

### 2.2 Navigation Architecture
- **Entry Points:**
  - `HomePage` -> *"Start Packaging Analysis"* or category card click.
  - Direct deep-link / navigation to `/analysis`.
- **Exit Points:**
  - *"Analyze Food"* CTA -> Transition to Biochemical Analysis & Barrier Calculation results.
  - Back Navigation -> `HomePage`.

---

## 3. Functional Requirements & Feature Specifications

### 3.1 Commodity Search & Autocomplete
1. **Search Input Field:**
   - Real-time search with 250ms debouncing.
   - Substring matching against food name, scientific name (botanical name), and group keywords.
   - Clear button `(X)` to reset query.
2. **Autocomplete Dropdown / Overlay:**
   - Displays top 10 ranked matches with Category Badge, Moisture %, and Fat %.
   - Highlights matching text substring.
   - Keyboard navigation support (Arrow Up/Down, Enter).
3. **Custom Commodity Option:**
   - Fallback option *"Can't find your food? Enter custom food item"* enabling manual entry of biochemical traits.

### 3.2 Standard Food Categories & Visual Cues
The system categorizes commodities into 7 standard categories with dedicated iconography and HSL color-coded themes:

| Category | Icon | Theme Color | Example Commodities | Critical Packaging Drivers |
| :--- | :--- | :--- | :--- | :--- |
| **Fruits** | `Icons.apple_rounded` | Coral Orange (`#F97316`) | Apples, Mangoes, Bananas, Berries | Respiration ($O_2/CO_2$), Ethylene, Weight loss |
| **Vegetables** | `Icons.eco_rounded` | Emerald Green (`#059669`) | Leafy greens, Tomatoes, Potatoes, Carrots | High moisture loss, Respiration, Condensation (Anti-fog) |
| **Grains & Pulses** | `Icons.grain_rounded` | Amber Gold (`#D97706`) | Rice, Wheat flour, Millets, Chickpeas | Hygroscopic moisture pickup, Weevil infestation |
| **Dairy** | `Icons.water_drop_rounded` | Sky Blue (`#0284C7`) | Paneer, Cheese, Butter, Milk powders | Lipid oxidation, Light sensitivity, Bacterial growth |
| **Meat & Poultry** | `Icons.set_meal_rounded` | Crimson Red (`#E11D48`) | Fresh chicken, Mutton, Fish fillets | Microbial spoilage, Color preservation (Myoglobin/MAP) |
| **Bakery & Confectionery** | `Icons.cake_rounded` | Rose Violet (`#9333EA`) | Bread, Biscuits, Cookies, Cakes | Staling (Retrogradation), Moisture gain (Crispness loss) |
| **Other Perishables** | `Icons.fastfood_rounded` | Teal Cyan (`#0F766E`) | Ready-to-eat meals, Pickles, Sauces, Extruded snacks | Acid corrosion resistance, Retort barrier integrity |

### 3.3 Selected Food Profile & Biochemical Card
When a food item is selected, a summary card displays its scientific baseline traits:
- **Visuals:** Category avatar icon and high-resolution category graphic illustration.
- **Scientific Attributes:**
  - **Moisture Content (%)**: With visual gauge (Low $<5\%$, Med $5-20\%$, High $>60\%$).
  - **Fat / Oil Content (%)**: Indicator for lipid oxidation risk.
  - **pH Value**: Acidic vs Neutral scale (corrosion/spoilage indicator).
  - **Respiration Class**: *Very Low, Low, Moderate, High, Very High, Extremely High*.
  - **Primary Barrier Needs**: e.g., *"Requires High Moisture Barrier (Low WVTR)"* or *"Requires Gas Permeable Micro-perforated Film"*.
- **Custom Parameter Overrides:** Expandable toggle allowing advanced users to fine-tune Moisture %, Fat %, and pH values for proprietary formulations.

### 3.4 Quantity & Unit Input
- **Quantity Field:** Numeric input supporting decimals (e.g., `500`, `2.5`, `1000`).
- **Unit Selector (Segmented Button / Dropdown):**
  - `g` (Grams - for retail consumer packs)
  - `kg` (Kilograms - standard bulk / food service packs)
  - `tonnes` (Metric Tonnes - industrial / export shipments)
  - `units` (Individual discrete units / pieces, e.g., 24 packets)
- **Unit Normalization Engine:** Automatically converts all inputs to standard SI kilograms ($kg$) for volumetric and barrier calculations.

### 3.5 Storage Conditions
Radio / Card Selector with visual temperature indicators:
1. **Room Temperature / Ambient ($20^\circ\text{C} - 25^\circ\text{C}$):**
   - Relative Humidity baseline: $60\% - 75\% RH$. Standard shelf storage.
2. **Refrigerated / Chill Chain ($2^\circ\text{C} - 8^\circ\text{C}$):**
   - Retards microbial growth, slows respiration for fresh produce.
3. **Frozen ($\le -18^\circ\text{C}$):**
   - Cryogenic preservation; requires cold-crack resistant polymers (e.g., HDPE/LDPE co-extrusions).
4. **Controlled Atmosphere / MAP ($O_2: 2-5\%, CO_2: 3-8\%$):**
   - High-technology gas flushing for long-duration preservation.

### 3.6 Expected Storage Duration
- **Duration Value:** Numeric text field (e.g., `30`, `6`, `12`).
- **Duration Unit:** `Days`, `Weeks`, `Months`, `Years`.
- **Intelligent Validation:** Warns if user specifies impossible durations (e.g., 6 months ambient storage for fresh raw chicken).

### 3.7 Optional Transportation Condition
Expandable logistics accordion allowing transport stress modeling:
- **Transport Mode:**
  - *Ambient Surface Road* (Standard vibration & thermal fluctuation)
  - *Refrigerated Reefer Truck* (Temperature controlled, moderate humidity)
  - *Air Freight* (Low pressure, altitude dehydration, rapid transit)
  - *Sea Freight / Intermodal Container* (High salinity, prolonged moisture exposure)
- **Logistics Distance / Transit Time:** Optional input in hours or kilometers.
- **Fragility / Shock Sensitivity:** Toggle for high impact cushioning requirements.

### 3.8 Recently Selected Foods (UX Memory Feature)
- Displays horizontal scrollable pills/cards of the last 5 selected foods.
- Clicking any pill immediately populates the entire commodity form with saved default parameters.
- Persisted locally via `SharedPreferences` (mobile/web local storage).

### 3.9 "Analyze Food" CTA & Validation Logic
- **Validation Checks:**
  - Commodity must be selected (or valid custom name provided).
  - Quantity must be $> 0$.
  - Duration must be $> 0$.
- **Action:**
  - Pushes payload to backend calculation pipeline (`/api/v1/recommendation/calculate`).
  - Navigates seamlessly to Results & Recommendation Dashboard with animated loading transition.

---

## 4. API & Data Contract Specifications

### 4.1 Backend Endpoints

#### `GET /api/v1/data/foods`
- **Query Parameters:**
  - `search` (string, optional): Search query for food name.
  - `category` (string, optional): Filter by category enum.
  - `limit` (int, default=50): Pagination limit.
- **Response Format:**
```json
[
  {
    "id": 104,
    "name": "Potato Chips",
    "category": "Snacks & Wafers",
    "moisture": 1.5,
    "ph": 6.0,
    "water_activity": 0.25,
    "fat": 32.4,
    "respiration_class": "Very Low",
    "oxygen_sensitivity": "High",
    "moisture_sensitivity": "High",
    "scientific_name": "Solanum tuberosum",
    "recommended_storage": "Room temperature"
  }
]
```

#### `GET /api/v1/data/categories-summary`
- Returns category list with count and representative sample foods.

#### `POST /api/v1/recommendation/analyze` (Input for Module 3)
- **Request Payload:**
```json
{
  "food_id": 104,
  "commodity_name": "Potato Chips",
  "category": "Snacks & Wafers",
  "biochemical_profile": {
    "moisture_pct": 1.5,
    "fat_pct": 32.4,
    "ph": 6.0,
    "water_activity": 0.25,
    "respiration_class": "Very Low",
    "is_custom_override": false
  },
  "quantity": 250.0,
  "unit": "g",
  "normalized_quantity_kg": 0.25,
  "storage_condition": "room_temperature",
  "storage_duration_days": 180,
  "transport_condition": {
    "mode": "ambient_road",
    "transit_days": 3,
    "is_fragile": true
  },
  "eco_friendly_priority": true
}
```

---

## 5. Frontend Architecture & Directory Layout

### 5.1 Directory Layout
```
frontend/lib/
├── models/
│   ├── food_commodity.dart          <-- Data model for food item & traits
│   ├── storage_condition.dart       <-- Enums & metadata for storage & transport
│   └── food_analysis_request.dart   <-- Payload model for recommendation pipeline
├── services/
│   ├── api_service.dart             <-- HTTP client for /foods & /analyze
│   └── recent_foods_service.dart    <-- LocalStorage / SharedPreferences persistence
├── screens/
│   └── analysis/
│       ├── food_analysis_screen.dart <-- Main container screen
│       └── widgets/
│           ├── food_search_bar.dart        <-- Autocomplete search input
│           ├── category_selector.dart      <-- 7-category filter chips
│           ├── recent_foods_bar.dart       <-- Recently selected foods pills
│           ├── food_profile_card.dart      <-- Biochemical preview & custom overrides
│           ├── quantity_unit_input.dart    <-- Quantity input with unit dropdown
│           ├── storage_condition_card.dart <-- Storage mode radio cards
│           ├── storage_duration_input.dart <-- Duration field & unit toggle
│           └── transport_condition_accordion.dart <-- Optional transit modes
```

---

## 6. UI Design Tokens & Visual Layout

### 6.1 Layout Grid Structure
- **Desktop ($> 1024\text{px}$):** Two-column layout:
  - **Left Column (55%):** Food Selection, Category Chips, Search Autocomplete, and Biochemical Traits Preview.
  - **Right Column (45%):** Quantity, Storage Environment, Duration, Transport options, and Primary "Analyze Food" CTA Card.
- **Tablet / Mobile ($< 1024\text{px}$):** Single unified vertical workflow with collapsible sections.

### 6.2 Visual Styling & Aesthetics
- **Card Styling:** `ModernCard` with subtle borders (`#E2E8F0`), soft drop-shadows, and light glassmorphism.
- **Category Badges:** Gradient tints matching respective category colors.
- **Buttons:** `GradientButton` with Teal-to-Mint gradient and interactive micro-animations.

---

## 7. Testing & Verification Strategy

### 7.1 Backend Unit Tests
- `test_food_search_filter()`: Verify search by partial food name and category filtering.
- `test_ifct_foods_mapping()`: Verify biochemical data retrieval across all 7 categories.
- `test_payload_validation()`: Verify validation of quantity, storage conditions, and duration ranges.

### 7.2 Frontend Widget & Integration Tests
- `food_search_bar_test.dart`: Test typing query, debounced API calls, and autocomplete selection.
- `category_selector_test.dart`: Test category tab switching and list filtering.
- `recent_foods_test.dart`: Test saving, loading, and clearing recently selected items.
- `storage_condition_test.dart`: Test selection of Room/Refrig/Frozen/CA options and duration inputs.
- `food_analysis_screen_flow_test.dart`: Full end-to-end form fill and "Analyze Food" submission test across mobile & desktop viewports.

---

## 8. Acceptance Criteria Checklist

- [ ] Interactive search bar with debounced autocomplete for 540+ IFCT food commodities.
- [ ] Category selector supporting all 7 specified categories (*Fruits, Vegetables, Grains, Dairy, Meat, Bakery, Other perishables*).
- [ ] Selected food displays contextual icon, category badge, and biochemical parameters (Moisture %, Fat %, pH, Respiration, Oxygen sensitivity).
- [ ] Support for optional custom biochemical parameter overrides.
- [ ] Quantity input with multi-unit selector (`kg`, `g`, `tonnes`, `units`).
- [ ] 4 storage conditions selectable (*Room temperature, Refrigerated, Frozen, Controlled atmosphere*).
- [ ] Expected storage duration input with unit selection (Days, Weeks, Months).
- [ ] Optional collapsible transportation condition selector (*Ambient, Cold Chain, Air, Sea*).
- [ ] Recently selected foods displayed for fast 1-click re-selection.
- [ ] Form validation prevents submission with missing inputs.
- [ ] "Analyze Food" button packages the payload and transitions to the recommendation calculator engine.
- [ ] Responsive UI verified with zero RenderFlex overflows on Mobile (375px), Tablet (768px), and Desktop (1280px).
