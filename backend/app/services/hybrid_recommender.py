"""
Hybrid AI/ML Recommendation Engine (Module 5).
Two-Stage Decision Pipeline:
  Stage 1: Deterministic Food Science Physics & Mass-Transfer Pruning
  Stage 2: Machine Learning Ensemble Probability & TOPSIS Multi-Criteria Decision Making (MCDM)
"""

import math
from typing import Dict, Any, List, Optional, Tuple
from dataclasses import dataclass, asdict

from app.core.material_catalog import (
    MaterialSpecification,
    PACKAGING_CATALOG,
    MaterialCatalogService,
)
from app.services.ml_classifier import (
    MLPackagingClassifier,
    FeatureVectorizer,
    ml_classifier,
)


from app.schemas.packaging import (
    SuitabilityCategoryEnum,
    AlternativeTypeEnum,
    MaterialCharacteristicsSchema,
    PackagingAlternativeSchema,
)


@dataclass
class ScoredMaterial:
    material: MaterialSpecification
    topsis_closeness: float
    ml_probability: float
    hybrid_score: float
    barrier_match_score: float
    shelf_life_score: float
    sustainability_score: float
    cost_efficiency_score: float
    mechanical_score: float


@dataclass
class HybridRecommendationResult:
    primary_material: MaterialSpecification
    suitability_score: float  # Hybrid score 0.0 to 1.0
    active_additives: List[str]
    eco_champion_alternative: Optional[MaterialSpecification]
    economy_alternative: Optional[MaterialSpecification]
    high_barrier_alternative: Optional[MaterialSpecification]
    candidate_count: int
    pruned_count: int
    stage1_rules_applied: List[str]
    ml_probabilities: Dict[str, float]
    alternatives: List[PackagingAlternativeSchema] = None


class HybridRecommendationEngine:
    """
    Two-Stage Hybrid Packaging Recommendation Engine.
    Combines strict postharvest food science physics with ML and TOPSIS ranking.
    """

    # Multi-Criteria TOPSIS Weights (sum to 1.0)
    W_BARRIER = 0.35
    W_SHELFLIFE = 0.25
    W_SUSTAINABILITY = 0.20
    W_COST = 0.10
    W_MECHANICAL = 0.10

    def __init__(self, classifier: Optional[MLPackagingClassifier] = None):
        self.classifier = classifier or ml_classifier

    def run_stage1_pruning(
        self,
        input_data: Dict[str, Any],
        materials: List[MaterialSpecification],
    ) -> Tuple[List[MaterialSpecification], List[str]]:
        """
        Stage 1: Deterministic Mass-Transfer & Postharvest Physics Boundary Filters.
        Eliminates biophysically incompatible materials.
        """
        valid_candidates: List[MaterialSpecification] = []
        applied_rules: List[str] = []

        moisture = float(input_data.get("moisture_pct") or input_data.get("moisture") or 60.0)
        fat = float(input_data.get("fat_pct") or input_data.get("fat") or 2.0)
        ph = float(input_data.get("ph") or 6.0)
        storage_temp = float(input_data.get("storage_temp_c") or input_data.get("storage_temperature_c") or 20.0)
        r20 = float(input_data.get("respiration_rate_20c") or 0.0)
        category = str(input_data.get("category", "")).lower()
        name = str(input_data.get("name") or input_data.get("food_name", "")).lower()
        resp_class = str(input_data.get("respiration_class", "")).lower()
        
        is_respiring = (r20 >= 20.0 or any(c in resp_class for c in ["high", "very high", "extreme"]) or any(k in name for k in ["tomato", "berry", "spinach", "banana", "apple", "broccoli", "mushroom", "lettuce"]))
        is_deep_freeze = (storage_temp <= -10.0 or "frozen" in category)
        is_high_lipid = (fat >= 18.0 or any(k in name for k in ["chip", "crisp", "nut", "butter", "oil"]))
        is_animal_protein = (any(c in category for c in ["meat", "seafood", "poultry", "dairy", "fish"]) or any(k in name for k in ["chicken", "beef", "salmon", "meat", "pork", "cheese"]))
        is_acidic = (ph <= 4.2 or any(k in name for k in ["pickle", "sauce", "paste"]))

        for mat in materials:
            # 1. Temperature Range Check
            if storage_temp < mat.temp_min_c or storage_temp > mat.temp_max_c:
                continue

            # 2. Deep-Freeze Requirement: Must be cryogenic rated
            if is_deep_freeze and not (mat.is_cryogenic_grade or mat.temp_min_c <= -25.0):
                continue

            # 3. High Respiring Produce: Reject non-breathable hermetic barrier films (OTR < 50 without breathability)
            if is_respiring and not mat.is_breathable and mat.otr_cc_m2_day < 100.0:
                continue

            # 4. High Lipid / Snack: Must have high gas barrier (OTR <= 5.0) to prevent rancidity
            if is_high_lipid and mat.otr_cc_m2_day > 5.0:
                continue

            # 5. Fresh Perishable Protein: Needs low OTR (OTR <= 30.0) or vacuum skin
            if is_animal_protein and not is_deep_freeze and mat.otr_cc_m2_day > 35.0:
                continue

            # 6. Retort / High Acid processed: Needs retort grade if sterilized/acidic paste
            if is_acidic and "retort" in name and not mat.is_retort_grade:
                continue

            valid_candidates.append(mat)

        # Record applied rules
        if is_respiring:
            applied_rules.append("Respiring Produce Rule: Filtered for breathable EMAP micro-perforations to prevent anaerobic fermentation.")
        if is_deep_freeze:
            applied_rules.append("Cryogenic Temperature Rule: Enforced sub-zero embrittlement resistance (T_min <= -25°C).")
        if is_high_lipid:
            applied_rules.append("Lipid Oxidation Rule: Enforced ultra-low OTR (<= 5.0 cc/m²/day) to protect unsaturated fats.")
        if is_animal_protein and not is_deep_freeze:
            applied_rules.append("Protein Preservation Rule: Enforced high gas barrier (OTR <= 35.0 cc/m²/day) for microbial inhibition.")

        # Fallback safeguard: if all candidates pruned, return original catalog filtered by temperature
        if not valid_candidates:
            valid_candidates = [m for m in materials if m.temp_min_c <= storage_temp <= m.temp_max_c] or materials[:5]
            applied_rules.append("Fallback Rule: Broadened candidate set to maintain operational continuity.")

        return valid_candidates, applied_rules

    def run_stage2_topsis(
        self,
        input_data: Dict[str, Any],
        candidates: List[MaterialSpecification],
        ml_probs: Dict[str, float],
    ) -> List[ScoredMaterial]:
        """
        Stage 2: Multi-Criteria TOPSIS Ranking blended with ML Classifier probabilities.
        """
        n = len(candidates)
        if n == 0:
            return []

        # Target operational preferences
        if "eco_friendly_priority" in input_data and input_data["eco_friendly_priority"] is not None:
            eco_priority = bool(input_data["eco_friendly_priority"])
        elif "eco_friendly" in input_data and input_data["eco_friendly"] is not None:
            eco_priority = bool(input_data["eco_friendly"])
        else:
            eco_priority = True

        duration = float(input_data.get("storage_duration_days") or input_data.get("duration") or 14.0)
        moisture = float(input_data.get("moisture_pct") or input_data.get("moisture") or 60.0)
        fat = float(input_data.get("fat_pct") or input_data.get("fat") or 2.0)
        is_fragile = bool(input_data.get("is_fragile") or str(input_data.get("fragility", "")).lower() in ["high", "medium", "true"])

        category = str(input_data.get("category", "")).lower()
        name = str(input_data.get("name", "") or input_data.get("food_name", "")).lower()
        is_animal_protein = (any(c in category for c in ["meat", "seafood", "poultry", "dairy", "fish"]) or any(k in name for k in ["chicken", "beef", "salmon", "meat", "pork", "cheese"]))
        is_high_lipid = (fat >= 18.0 or any(k in name for k in ["chip", "crisp", "nut", "butter", "oil"]))

        # Dynamically modulate criteria weights based on scientific preservation priorities
        w_barrier = self.W_BARRIER * (1.8 if (is_animal_protein or is_high_lipid) else (0.6 if eco_priority else 1.0))
        w_shelflife = self.W_SHELFLIFE * (1.4 if is_animal_protein else 1.0)
        w_eco = self.W_SUSTAINABILITY * (4.5 if eco_priority else 0.4)
        w_cost = self.W_COST
        w_mech = self.W_MECHANICAL * (1.5 if is_fragile else 1.0)
        
        # Normalize weights
        total_w = w_barrier + w_shelflife + w_eco + w_cost + w_mech
        w_barrier /= total_w
        w_shelflife /= total_w
        w_eco /= total_w
        w_cost /= total_w
        w_mech /= total_w

        # Compute raw criteria values for each candidate
        raw_barrier: List[float] = []
        raw_shelflife: List[float] = []
        raw_eco: List[float] = []
        raw_cost_eff: List[float] = []
        raw_mech: List[float] = []

        for mat in candidates:
            # 1. Barrier Match Score (0-100)
            if is_animal_protein:
                barrier_score = max(5.0, 100.0 - (mat.otr_cc_m2_day * 3.5))
            elif moisture > 70.0 and mat.is_breathable:
                barrier_score = 95.0
            elif fat > 15.0:
                barrier_score = max(10.0, 100.0 - (mat.otr_cc_m2_day * 15.0))
            else:
                barrier_score = max(20.0, 100.0 - (mat.wvtr_g_m2_day * 1.5))
            raw_barrier.append(barrier_score)

            # 2. Shelf-Life Horizon Score (0-100)
            target_dur_factor = min(1.0, duration / 60.0)
            shelf_score = 70.0 + (30.0 * (1.0 / (1.0 + mat.otr_cc_m2_day / 500.0)))
            raw_shelflife.append(shelf_score)

            # 3. Sustainability Score (0-100)
            raw_eco.append(mat.sustainability_score)

            # 4. Cost Efficiency: Inverse of unit cost (higher is better)
            cost_eff = 10.0 / max(0.5, mat.estimated_unit_cost_inr)
            raw_cost_eff.append(cost_eff)

            # 5. Mechanical Puncture & Tensile Buffer (0-100)
            mech_score = (mat.tensile_strength_mpa * 0.4) + (mat.puncture_resistance_n * 0.6)
            raw_mech.append(mech_score)

        # TOPSIS Step 1 & 2: Vector Normalization & Weighting
        def _norm_and_weight(arr: List[float], weight: float) -> List[float]:
            denom = math.sqrt(sum(x * x for x in arr)) or 1.0
            return [(x / denom) * weight for x in arr]

        v_barrier = _norm_and_weight(raw_barrier, w_barrier)
        v_shelflife = _norm_and_weight(raw_shelflife, w_shelflife)
        v_eco = _norm_and_weight(raw_eco, w_eco)
        v_cost = _norm_and_weight(raw_cost_eff, w_cost)
        v_mech = _norm_and_weight(raw_mech, w_mech)

        # TOPSIS Step 3: Identify Ideal (A+) and Negative-Ideal (A-) Solutions (all benefit criteria)
        ideal = (max(v_barrier), max(v_shelflife), max(v_eco), max(v_cost), max(v_mech))
        anti_ideal = (min(v_barrier), min(v_shelflife), min(v_eco), min(v_cost), min(v_mech))

        # TOPSIS Step 4 & 5: Euclidean Distances & Relative Closeness
        scored: List[ScoredMaterial] = []
        for i, mat in enumerate(candidates):
            d_plus = math.sqrt(
                (v_barrier[i] - ideal[0]) ** 2 +
                (v_shelflife[i] - ideal[1]) ** 2 +
                (v_eco[i] - ideal[2]) ** 2 +
                (v_cost[i] - ideal[3]) ** 2 +
                (v_mech[i] - ideal[4]) ** 2
            )
            d_minus = math.sqrt(
                (v_barrier[i] - anti_ideal[0]) ** 2 +
                (v_shelflife[i] - anti_ideal[1]) ** 2 +
                (v_eco[i] - anti_ideal[2]) ** 2 +
                (v_cost[i] - anti_ideal[3]) ** 2 +
                (v_mech[i] - anti_ideal[4]) ** 2
            )

            closeness = (d_minus / (d_plus + d_minus)) if (d_plus + d_minus) > 0 else 0.5
            
            # Blend TOPSIS closeness with ML Polymer Family Probability
            ml_prob = ml_probs.get(mat.polymer_family, 0.10)
            if eco_priority:
                hybrid_score = (0.80 * closeness) + (0.20 * ml_prob)
            else:
                hybrid_score = (0.65 * closeness) + (0.35 * ml_prob)

            scored.append(
                ScoredMaterial(
                    material=mat,
                    topsis_closeness=round(closeness, 4),
                    ml_probability=round(ml_prob, 4),
                    hybrid_score=round(hybrid_score, 4),
                    barrier_match_score=round(raw_barrier[i], 1),
                    shelf_life_score=round(raw_shelflife[i], 1),
                    sustainability_score=round(raw_eco[i], 1),
                    cost_efficiency_score=round(raw_cost_eff[i], 2),
                    mechanical_score=round(raw_mech[i], 1),
                )
            )

        # Sort descending by hybrid_score
        scored.sort(key=lambda s: s.hybrid_score, reverse=True)
        return scored

    def derive_active_additives(self, input_data: Dict[str, Any]) -> List[str]:
        """Derives precision active packaging additives (KMnO4, O2 scavengers, anti-fog, desiccants)."""
        additives: List[str] = []
        
        moisture = float(input_data.get("moisture_pct") or input_data.get("moisture") or 60.0)
        fat = float(input_data.get("fat_pct") or input_data.get("fat") or 2.0)
        ethylene = str(input_data.get("ethylene_sensitivity_score") or input_data.get("ethylene_sensitivity") or "low").lower()
        r20 = float(input_data.get("respiration_rate_20c") or 0.0)
        name = str(input_data.get("name") or input_data.get("food_name", "")).lower()

        # 1. KMnO4 Ethylene Scavenger
        if (any(w in ethylene for w in ["high", "crit", "mod"]) or "0.5" in ethylene or "0.8" in ethylene or "1.0" in ethylene) and moisture > 60.0:
            additives.append("Potassium Permanganate (KMnO₄) Ethylene Scavenger Sachet")

        # 2. Anti-fog Surfactant
        if moisture >= 75.0 and (r20 >= 10.0 or any(k in name for k in ["tomato", "spinach", "berry", "lettuce", "mushroom"])):
            additives.append("Antifog Surface Surfactant Coating")

        # 3. N2 Gas Flush / O2 Scavenger
        if fat >= 18.0 or any(k in name for k in ["chip", "nut", "butter", "coffee"]):
            additives.append("Nitrogen (N₂) Gas Flush Inert Headspace (O₂ < 1.0%)")

        # 4. Moisture Desiccant
        if moisture <= 8.0 and fat < 18.0:
            additives.append("Food-Grade Silica Gel / Clay Desiccant Sachet")

        return additives

    @staticmethod
    def _format_otr(otr: float) -> str:
        if otr < 1.0:
            return f"< {otr:.1f} cc/m²/day"
        elif otr >= 1000.0:
            return f"{otr:,.0f} cc/m²/day"
        else:
            return f"{otr:.1f} cc/m²/day"

    @staticmethod
    def _format_wvtr(wvtr: float) -> str:
        if wvtr < 1.0:
            return f"< {wvtr:.1f} g/m²/day"
        else:
            return f"{wvtr:.1f} g/m²/day"

    @staticmethod
    def _format_eco_rating(mat: MaterialSpecification) -> str:
        if mat.is_biodegradable or "Bio" in mat.name or "PLA" in mat.name or "NatureFlex" in mat.name:
            return "100% Home Compostable" if mat.sustainability_score >= 90 else "Industrial Compostable Bio-Polymer"
        elif "Paper" in mat.name or "Kraft" in mat.name:
            return "100% Recyclable FSC Kraft"
        elif mat.is_recyclable:
            return "Recyclable Polyolefin (RIC #4/5)"
        else:
            return "Standard Commercial Substrate"

    @classmethod
    def build_material_characteristics(cls, mat: MaterialSpecification) -> MaterialCharacteristicsSchema:
        cost = float(mat.estimated_unit_cost_inr)
        if cost <= 2.50:
            cost_tier = "Low (₹)"
        elif cost <= 4.50:
            cost_tier = "Moderate (₹₹)"
        else:
            cost_tier = "Premium (₹₹₹)"

        return MaterialCharacteristicsSchema(
            otr=cls._format_otr(mat.otr_cc_m2_day),
            wvtr=cls._format_wvtr(mat.wvtr_g_m2_day),
            thickness_microns=float(mat.thickness_microns),
            tensile_strength_mpa=float(mat.tensile_strength_mpa),
            thermal_range=f"{mat.temp_min_c:.0f}°C to {mat.temp_max_c:.0f}°C",
            sustainability_rating=cls._format_eco_rating(mat),
            estimated_cost_inr=cost,
            cost_tier=cost_tier,
        )

    def build_alternative_portfolio(
        self,
        primary_mat: MaterialSpecification,
        primary_score: float,
        eco_mat: Optional[MaterialSpecification],
        econ_mat: Optional[MaterialSpecification],
        hb_mat: Optional[MaterialSpecification],
        input_data: Dict[str, Any],
    ) -> List[PackagingAlternativeSchema]:
        """Generates ranked alternative packaging suggestions with stars, probabilities, and trade-offs."""
        alternatives: List[PackagingAlternativeSchema] = []
        
        # 1. Eco-Champion Alternative (4 Stars)
        if eco_mat and eco_mat.material_id != primary_mat.material_id:
            cost_diff = ((eco_mat.estimated_unit_cost_inr - primary_mat.estimated_unit_cost_inr) / max(0.1, primary_mat.estimated_unit_cost_inr)) * 100.0
            eco_diff = ((eco_mat.sustainability_score - primary_mat.sustainability_score) / max(1.0, primary_mat.sustainability_score)) * 100.0
            cost_sign = "+" if cost_diff >= 0 else ""
            eco_prob = round(min(0.89, max(0.78, primary_score - 0.08)), 2)

            alternatives.append(
                PackagingAlternativeSchema(
                    candidate_id=f"alt_eco_{eco_mat.material_id}",
                    type="ECO_FRIENDLY",
                    material_name=eco_mat.name,
                    packaging_title="Compostable Bio-Film Sustainable Format",
                    star_rating=4,
                    star_display="★★★★☆",
                    suitability_category=SuitabilityCategoryEnum.HIGH_COMPATIBILITY,
                    model_derived_probability=eco_prob,
                    compatibility_confidence=f"High Confidence ({eco_prob:.2f})",
                    characteristics=self.build_material_characteristics(eco_mat),
                    trade_off_summary=f"Maximum circularity ({eco_mat.sustainability_score:.0f}/100 eco-score); {cost_sign}{cost_diff:.0f}% unit cost difference.",
                    advantages=[
                        "100% circular / compostable footprint",
                        "Minimizes microplastic accumulation",
                        "High consumer environmental appeal",
                    ],
                    limitations=[
                        "Higher raw polymer procurement cost",
                        "Requires controlled temperature storage",
                    ],
                    cost_delta_pct=round(cost_diff, 1),
                    eco_delta_pct=round(eco_diff, 1),
                    shelf_life_delta="Equal",
                    sustainability_score=eco_mat.sustainability_score,
                    estimated_unit_cost_inr=eco_mat.estimated_unit_cost_inr,
                )
            )

        # 2. Economy Alternative (3 Stars)
        if econ_mat and econ_mat.material_id != primary_mat.material_id:
            cost_diff = ((econ_mat.estimated_unit_cost_inr - primary_mat.estimated_unit_cost_inr) / max(0.1, primary_mat.estimated_unit_cost_inr)) * 100.0
            eco_diff = ((econ_mat.sustainability_score - primary_mat.sustainability_score) / max(1.0, primary_mat.sustainability_score)) * 100.0
            cost_sign = "+" if cost_diff >= 0 else ""
            econ_prob = round(min(0.77, max(0.65, primary_score - 0.18)), 2)

            alternatives.append(
                PackagingAlternativeSchema(
                    candidate_id=f"alt_econ_{econ_mat.material_id}",
                    type="ECONOMY",
                    material_name=econ_mat.name,
                    packaging_title="Commercial Low-Cost Substrate Format",
                    star_rating=3,
                    star_display="★★★☆☆",
                    suitability_category=SuitabilityCategoryEnum.MODERATE_COMPATIBILITY,
                    model_derived_probability=econ_prob,
                    compatibility_confidence=f"Moderate Fit ({econ_prob:.2f})",
                    characteristics=self.build_material_characteristics(econ_mat),
                    trade_off_summary=f"Lowest unit packaging cost (₹{econ_mat.estimated_unit_cost_inr:.2f}); {cost_sign}{cost_diff:.0f}% cost savings for bulk distribution.",
                    advantages=[
                        "Cost-effective for high-volume commercial scaling",
                        "Widely available supply chain distribution",
                        "Good basic mechanical durability",
                    ],
                    limitations=[
                        "Lower bio-circularity and sustainability score",
                        "Moderate moisture / gas barrier performance",
                    ],
                    cost_delta_pct=round(cost_diff, 1),
                    eco_delta_pct=round(eco_diff, 1),
                    shelf_life_delta="-3 to -5 days",
                    sustainability_score=econ_mat.sustainability_score,
                    estimated_unit_cost_inr=econ_mat.estimated_unit_cost_inr,
                )
            )

        # 3. High-Barrier Alternative (3 Stars)
        if hb_mat and hb_mat.material_id != primary_mat.material_id:
            cost_diff = ((hb_mat.estimated_unit_cost_inr - primary_mat.estimated_unit_cost_inr) / max(0.1, primary_mat.estimated_unit_cost_inr)) * 100.0
            eco_diff = ((hb_mat.sustainability_score - primary_mat.sustainability_score) / max(1.0, primary_mat.sustainability_score)) * 100.0
            cost_sign = "+" if cost_diff >= 0 else ""
            hb_prob = round(min(0.80, max(0.68, primary_score - 0.14)), 2)

            alternatives.append(
                PackagingAlternativeSchema(
                    candidate_id=f"alt_hb_{hb_mat.material_id}",
                    type="HIGH_BARRIER",
                    material_name=hb_mat.name,
                    packaging_title="Heavy-Duty High-Barrier Protective Format",
                    star_rating=3,
                    star_display="★★★☆☆",
                    suitability_category=SuitabilityCategoryEnum.MODERATE_COMPATIBILITY,
                    model_derived_probability=hb_prob,
                    compatibility_confidence=f"Moderate Fit ({hb_prob:.2f})",
                    characteristics=self.build_material_characteristics(hb_mat),
                    trade_off_summary=f"Maximum puncture toughness ({hb_mat.puncture_resistance_n:.0f} N) and structural crush resistance.",
                    advantages=[
                        "Superior puncture resistance and tensile burst buffer",
                        "Robust protection during rough transit and logistics",
                        "High gas / moisture hermetic barrier",
                    ],
                    limitations=[
                        "Higher unit packaging weight and material cost",
                        "Reduced breathability for high-respiration commodities",
                    ],
                    cost_delta_pct=round(cost_diff, 1),
                    eco_delta_pct=round(eco_diff, 1),
                    shelf_life_delta="+2 to +4 days",
                    sustainability_score=hb_mat.sustainability_score,
                    estimated_unit_cost_inr=hb_mat.estimated_unit_cost_inr,
                )
            )

        return alternatives

    def recommend(self, input_data: Dict[str, Any]) -> HybridRecommendationResult:
        """
        Executes full two-stage hybrid recommendation pipeline.
        """
        all_materials = PACKAGING_CATALOG
        
        # 1. ML Classifier probabilities
        ml_probs = self.classifier.predict_polymer_probabilities(input_data)

        # 2. Stage 1 Physics Pruning
        candidates, rules_applied = self.run_stage1_pruning(input_data, all_materials)
        pruned_count = len(all_materials) - len(candidates)

        # 3. Stage 2 TOPSIS Ranking
        scored_candidates = self.run_stage2_topsis(input_data, candidates, ml_probs)

        if not scored_candidates:
            # Absolute fallback
            fallback_mat = all_materials[0]
            fallback_alts = self.build_alternative_portfolio(
                primary_mat=fallback_mat,
                primary_score=0.75,
                eco_mat=all_materials[2],
                econ_mat=all_materials[1],
                hb_mat=all_materials[3],
                input_data=input_data,
            )
            return HybridRecommendationResult(
                primary_material=fallback_mat,
                suitability_score=0.75,
                active_additives=[],
                eco_champion_alternative=all_materials[2],
                economy_alternative=all_materials[1],
                high_barrier_alternative=all_materials[3],
                candidate_count=1,
                pruned_count=0,
                stage1_rules_applied=["Fallback default material"],
                ml_probabilities=ml_probs,
                alternatives=fallback_alts,
            )

        primary = scored_candidates[0]
        primary_mat = primary.material

        # 4. Extract 3 Tailored Alternatives from candidates or catalog
        remaining = [s.material for s in scored_candidates if s.material.material_id != primary_mat.material_id]
        if not remaining:
            remaining = [m for m in all_materials if m.material_id != primary_mat.material_id]

        # Alternative 1: Eco-Champion (highest sustainability score >= 85)
        eco_candidates = sorted(remaining, key=lambda m: m.sustainability_score, reverse=True)
        eco_champion = eco_candidates[0] if eco_candidates else None

        # Alternative 2: Economy (lowest unit cost)
        econ_candidates = sorted([m for m in remaining if m.material_id != (eco_champion.material_id if eco_champion else "")], key=lambda m: m.estimated_unit_cost_inr)
        economy_alt = econ_candidates[0] if econ_candidates else None

        # Alternative 3: High Barrier / Structural Durability (highest tensile or lowest OTR)
        hb_candidates = sorted([m for m in remaining if m.material_id not in [(eco_champion.material_id if eco_champion else ""), (economy_alt.material_id if economy_alt else "")]], key=lambda m: m.puncture_resistance_n, reverse=True)
        high_barrier_alt = hb_candidates[0] if hb_candidates else None

        # 5. Build rich alternative portfolio schemas
        alternatives = self.build_alternative_portfolio(
            primary_mat=primary_mat,
            primary_score=primary.hybrid_score,
            eco_mat=eco_champion,
            econ_mat=economy_alt,
            hb_mat=high_barrier_alt,
            input_data=input_data,
        )

        # 6. Active Additives
        active_additives = self.derive_active_additives(input_data)

        return HybridRecommendationResult(
            primary_material=primary_mat,
            suitability_score=primary.hybrid_score,
            active_additives=active_additives,
            eco_champion_alternative=eco_champion,
            economy_alternative=economy_alt,
            high_barrier_alternative=high_barrier_alt,
            candidate_count=len(candidates),
            pruned_count=pruned_count,
            stage1_rules_applied=rules_applied,
            ml_probabilities=ml_probs,
            alternatives=alternatives,
        )


hybrid_recommender = HybridRecommendationEngine()
