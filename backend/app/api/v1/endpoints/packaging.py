"""
Packaging Recommendation API Endpoints (Module 5).
REST endpoints for hybrid AI/ML packaging recommendations, history retrieval,
and multi-material alternative evaluation.
"""

import uuid
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Dict, Any, Optional

from app.db.session import get_db
from app.models.packaging import PackagingRecommendation
from app.models.user import User
from app.api.deps import get_optional_current_user
from app.core.i18n import get_requested_locale
from app.schemas.packaging import (
    PackagingInput,
    PackagingRecommendationResult,
    PackagingHistoryItem,
    PackagingRecordResponse,
    PrimaryRecommendationSchema,
    PackagingAlternativeSchema,
    BarrierProfileSchema,
    BoxGeometrySchema,
    ScientificRationaleSchema,
    PackagingComparisonRequest,
    PackagingComparisonMatrixResponse,
)
from app.schemas.cost_estimation import (
    PackagingFormFactorEnum,
    CostEstimationRequest,
    CostEstimationResponse,
)
from app.services.hybrid_recommender import hybrid_recommender
from app.services.geometry_and_xai import geometry_and_xai_service
from app.services.packaging_comparison_service import packaging_comparison_service
from app.services.cost_estimation_service import CostEstimationService
from app.services.packaging_service import PackagingHistoryService
from app.services.recommendation_service import recommendation_service
from app.core.material_catalog import MaterialSpecification

router = APIRouter()


def _format_alternative_tradeoff(alt_type: str, mat: MaterialSpecification, primary_cost: float) -> str:
    """Generates concise trade-off summary for alternative materials."""
    if alt_type == "ECO_FRIENDLY":
        diff = ((mat.estimated_unit_cost_inr - primary_cost) / max(0.1, primary_cost)) * 100.0
        sign = "+" if diff >= 0 else ""
        return f"Highest sustainability score ({mat.sustainability_score:.0f}/100); {sign}{diff:.0f}% unit cost difference."
    elif alt_type == "ECONOMY":
        diff = ((mat.estimated_unit_cost_inr - primary_cost) / max(0.1, primary_cost)) * 100.0
        return f"Lowest procurement cost (₹{mat.estimated_unit_cost_inr:.2f}); {diff:.0f}% cost savings for bulk distribution."
    elif alt_type == "HIGH_BARRIER":
        return f"Maximum mechanical puncture buffer ({mat.puncture_resistance_n:.0f} N) and structural crush resistance."
    return f"Alternative option with {mat.sustainability_score:.0f}/100 eco-score."


@router.post("/recommend", response_model=PackagingRecommendationResult, summary="Get packaging recommendation")
async def get_packaging_recommendation(
    payload: PackagingInput,
    request: Request,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Two-Stage Hybrid Packaging Recommendation Endpoint.
    Combines deterministic Food Science physics rules, Random Forest classification,
    and TOPSIS multi-criteria optimization to prescribe primary material, 3 alternatives,
    box geometry, and explainable scientific rationales.
    """
    locale = get_requested_locale(request)

    # 1. Resolve naming and quantity
    name = payload.food_name or payload.item_name or "Fresh Commodity"
    qty = payload.quantity or payload.weight or 5.0
    category = payload.category or "General"
    is_fragile = payload.is_fragile
    eco_prio = payload.eco_friendly_priority if payload.eco_friendly_priority is not None else payload.eco_friendly

    # 2. Storage temperature inference
    storage_temp = payload.storage_temp_c
    if storage_temp is None:
        cond = (payload.storage_condition or "").lower()
        if "froz" in cond:
            storage_temp = -18.0
        elif "refrig" in cond or "chill" in cond or "cold" in cond:
            storage_temp = 4.0
        elif "ambient" in cond or "room" in cond:
            storage_temp = 22.0
        else:
            storage_temp = 20.0

    duration = payload.storage_duration_days or payload.duration or 14

    # 3. Assemble unified input dictionary
    input_data: Dict[str, Any] = {
        "name": name,
        "food_name": name,
        "category": category,
        "quantity_kg": qty,
        "quantity": qty,
        "storage_temp_c": storage_temp,
        "storage_duration_days": duration,
        "duration": duration,
        "is_fragile": is_fragile,
        "eco_friendly_priority": eco_prio,
        "moisture_pct": payload.moisture,
        "fat_pct": payload.fat,
        "ph": payload.ph,
        "water_activity": payload.water_activity,
        "respiration_class": payload.respiration_class,
        "respiration_rate_20c": payload.respiration_rate_20c,
        "ethylene_sensitivity": payload.ethylene_sensitivity,
        "chilling_injury_threshold_c": payload.chilling_injury_threshold_c,
    }

    # Apply custom overrides if provided
    if payload.custom_overrides:
        input_data.update(payload.custom_overrides)

    # 4. Execute Hybrid Recommendation Engine
    hybrid_res = hybrid_recommender.recommend(input_data)
    primary_mat = hybrid_res.primary_material

    # 5. Compute Box Geometry & Cushioning
    box_geom = geometry_and_xai_service.calculate_box_geometry(
        quantity_kg=qty,
        category=category,
        commodity_name=name,
        is_fragile=is_fragile,
        storage_temp_c=storage_temp,
    )

    # 6. Generate Explainable AI (XAI) Scientific Rationale & Result Breakdown
    if locale in ["ta", "hi"]:
        xai_res = recommendation_service.generate_scientific_rationale(
            commodity_name=name,
            category=category,
            material=primary_mat,
            input_data=input_data,
            active_additives=hybrid_res.active_additives,
            locale=locale,
        )
        explainable_res = recommendation_service.generate_explainable_recommendation(
            commodity_name=name,
            category=category,
            material=primary_mat,
            input_data=input_data,
            is_fragile=is_fragile,
            locale=locale,
        )
    else:
        xai_res = geometry_and_xai_service.generate_scientific_rationale(
            commodity_name=name,
            category=category,
            material=primary_mat,
            input_data=input_data,
            active_additives=hybrid_res.active_additives,
        )
        explainable_res = geometry_and_xai_service.generate_explainable_recommendation(
            commodity_name=name,
            category=category,
            material=primary_mat,
            input_data=input_data,
            is_fragile=is_fragile,
        )

    # 7. Alternatives Portfolio
    alts_list: List[PackagingAlternativeSchema] = hybrid_res.alternatives or []

    # Assemble Multi-Candidate Comparison Summary
    comparison_summary = {
        "candidate_count": len(alts_list) + 1,
        "primary_material": primary_mat.name,
        "primary_cost_inr": primary_mat.estimated_unit_cost_inr,
        "primary_eco_score": primary_mat.sustainability_score,
        "alternatives_count": len(alts_list),
        "eco_champion": next((a.material_name for a in alts_list if a.type == "ECO_FRIENDLY"), None),
        "economy_option": next((a.material_name for a in alts_list if a.type == "ECONOMY"), None),
        "high_barrier_option": next((a.material_name for a in alts_list if a.type == "HIGH_BARRIER"), None),
    }

    # 8. Assemble Full Response Payload
    rec_id = f"rec_{uuid.uuid4().hex[:8]}"
    item_volume = round(box_geom.total_volume_cm3 * (box_geom.space_utilization_pct / 100.0), 1)

    result = PackagingRecommendationResult(
        recommendation_id=rec_id,
        primary_recommendation=PrimaryRecommendationSchema(
            material_name=primary_mat.name,
            material_type=primary_mat.category,
            polymer_family=primary_mat.polymer_family,
            structure=primary_mat.structure,
            packaging_title=explainable_res.packaging_title,
            packaging_format=explainable_res.packaging_format,
            recommendation_explanation=explainable_res.recommendation_explanation,
            advantages=explainable_res.advantages,
            limitations=explainable_res.limitations,
            suitable_storage_condition=explainable_res.suitable_storage_condition,
            expected_application=explainable_res.expected_application,
            important_properties=explainable_res.important_properties,
            barrier_profile=BarrierProfileSchema(
                otr=f"{primary_mat.otr_cc_m2_day:.1f} cc/m²/day",
                wvtr=f"{primary_mat.wvtr_g_m2_day:.2f} g/m²/day",
                thickness_microns=primary_mat.thickness_microns,
                tensile_strength_mpa=primary_mat.tensile_strength_mpa,
                puncture_resistance_n=primary_mat.puncture_resistance_n,
            ),
            sustainability_score=primary_mat.sustainability_score,
            estimated_unit_cost_inr=primary_mat.estimated_unit_cost_inr,
            suitability_score=hybrid_res.suitability_score,
            active_additives=hybrid_res.active_additives,
        ),
        alternatives=alts_list,
        comparison_summary=comparison_summary,
        box_geometry=BoxGeometrySchema(
            length_cm=box_geom.length_cm,
            width_cm=box_geom.width_cm,
            height_cm=box_geom.height_cm,
            total_volume_cm3=box_geom.total_volume_cm3,
            space_utilization_pct=box_geom.space_utilization_pct,
            cushioning_material=box_geom.cushioning_material,
        ),
        scientific_rationale=ScientificRationaleSchema(
            summary=xai_res.summary,
            key_drivers=xai_res.key_drivers,
        ),
        # Legacy fields
        recommended_box_type=f"{explainable_res.packaging_title} ({primary_mat.name})",
        recommended_dimensions=f"{box_geom.length_cm:.1f} x {box_geom.width_cm:.1f} x {box_geom.height_cm:.1f} cm",
        box_volume_cm3=box_geom.total_volume_cm3,
        item_volume_cm3=item_volume,
        space_utilization_pct=box_geom.space_utilization_pct,
        cushioning_material=box_geom.cushioning_material,
        estimated_cost=primary_mat.estimated_unit_cost_inr,
        sustainability_score=primary_mat.sustainability_score,
        notes=explainable_res.recommendation_explanation,
    )

    # 9. Save recommendation to DB history ONLY for registered/logged in users
    if current_user is not None:
        await PackagingHistoryService.save_history(
            db=db,
            item_name=name,
            length=box_geom.length_cm,
            width=box_geom.width_cm,
            height=box_geom.height_cm,
            weight=qty,
            is_fragile=is_fragile,
            eco_friendly=eco_prio,
            recommended_box_type=result.recommended_box_type,
            recommended_dimensions=result.recommended_dimensions,
            cushioning_material=result.cushioning_material,
            estimated_cost=result.estimated_cost,
            sustainability_score=result.sustainability_score,
            notes=result.notes,
            user_id=current_user.id,
        )

    return result


@router.get("/history", response_model=List[PackagingHistoryItem], summary="Get past recommendations")
async def get_recommendation_history(
    skip: int = 0,
    limit: int = 20,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Fetch history of packaging recommendations. Supports user-scoping if authenticated.
    """
    records = await PackagingHistoryService.get_user_history(
        db, user_id=current_user.id if current_user else None, limit=limit, offset=skip
    )
    return [PackagingHistoryService.to_history_item_schema(r) for r in records]


@router.get("/history/{history_id}", response_model=PackagingHistoryItem, summary="Get past recommendation by ID")
async def get_history_detail(
    history_id: int,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Fetch full technical details for a specific historical recommendation run.
    """
    record = await PackagingHistoryService.get_history_by_id(
        db, history_id=history_id, user_id=current_user.id if current_user else None
    )
    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Historical recommendation #{history_id} not found.",
        )
    return PackagingHistoryService.to_history_item_schema(record)


@router.delete("/history/{history_id}", status_code=status.HTTP_200_OK, summary="Delete a single historical recommendation run")
async def delete_history_entry(
    history_id: int,
    current_user: Optional[User] = Depends(get_optional_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Deletes a single recommendation history record.
    """
    success = await PackagingHistoryService.delete_history_item(
        db, history_id=history_id, user_id=current_user.id if current_user else None
    )
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Historical recommendation #{history_id} not found.",
        )
    return {
        "success": True,
        "message": f"Historical recommendation #{history_id} deleted successfully.",
        "deleted_id": history_id,
    }




@router.post("/compare", response_model=PackagingComparisonMatrixResponse, summary="Compare up to 3 packaging materials")
async def compare_packaging_materials(
    payload: PackagingComparisonRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Module 9: Multi-Material Side-by-Side Comparison Endpoint.
    Compares 2 to 3 packaging materials across Moisture Barrier, Oxygen Barrier,
    Gas Exchange, Strength, Recyclability, and Cost Category with AI trade-off synthesis.
    """
    return await packaging_comparison_service.compare_materials(request=payload, db=db)


@router.post("/cost-estimate", response_model=CostEstimationResponse, summary="Calculate packaging material footprint and estimated procurement cost")
async def estimate_packaging_cost(
    payload: CostEstimationRequest,
):
    """
    Module 10: Parametric Packaging Cost & Material Footprint Estimator.
    Computes single-unit surface area, material gross mass with scrap allowance,
    itemized converting and add-on costs, volume tier scaling, and transparency disclaimer metadata.
    """
    try:
        return CostEstimationService.calculate_cost_estimate(payload)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cost estimation calculation error: {str(e)}",
        )


@router.get("/cost-parameters", summary="Retrieve default cost parameters, densities, and discount tiers")
async def get_cost_parameters() -> Dict[str, Any]:
    """
    Returns reference metadata for polymer densities, functional add-on fees,
    standard form factors, and volume scaling discount tiers.
    """
    return {
        "standard_form_factors": [f.value for f in PackagingFormFactorEnum],
        "polymer_densities_kg_m3": CostEstimationService.POLYMER_DENSITIES_KG_M3,
        "default_material_prices_inr_per_kg": CostEstimationService.DEFAULT_PRICES_INR_PER_KG,
        "addons_pricing_inr": {k.value: v for k, v in CostEstimationService.ADDON_PRICING_INR.items()},
        "printing_fee_per_sqm_inr": CostEstimationService.PRINTING_FEE_PER_SQM_INR,
        "lamination_fee_per_sqm_inr": CostEstimationService.LAMINATION_FEE_PER_SQM_INR,
        "pouch_making_fee_per_unit_inr": CostEstimationService.POUCH_MAKING_FEE_PER_UNIT_INR,
        "tooling_setup_base_inr": CostEstimationService.TOOLING_SETUP_BASE_INR,
        "volume_discount_tiers": [
            {"min_qty": 100, "max_qty": 4999, "discount_pct": 0.0, "tier_name": "Tier 1: Pilot / Prototype"},
            {"min_qty": 5000, "max_qty": 24999, "discount_pct": 8.0, "tier_name": "Tier 2: Small Commercial"},
            {"min_qty": 25000, "max_qty": 99999, "discount_pct": 16.0, "tier_name": "Tier 3: Medium Commercial"},
            {"min_qty": 100000, "max_qty": None, "discount_pct": 24.0, "tier_name": "Tier 4: Enterprise Scale"},
        ],
    }


@router.post("/spoilage-alerts", summary="Generate localized spoilage alerts & physiological risk warnings")
async def get_spoilage_alerts(
    payload: PackagingInput,
    request: Request,
) -> Dict[str, Any]:
    """
    Evaluates commodity physiological parameters (chilling injury, condensation mold,
    lipid rancidity, anaerobic respiration, ethylene sensitivity) and returns
    vernacular mitigation advice in English, Tamil, or Hindi.
    """
    locale = get_requested_locale(request)
    name = payload.food_name or payload.item_name or "Commodity"
    input_data = payload.model_dump()
    alerts = recommendation_service.generate_spoilage_alerts(
        commodity_name=name,
        input_data=input_data,
        locale=locale,
    )
    return {
        "commodity": name,
        "locale": locale,
        "alert_count": len(alerts),
        "alerts": [a.to_dict() for a in alerts],
    }



