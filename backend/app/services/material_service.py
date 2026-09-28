"""
Packaging Material Service & Comparison Engine.
Implements multi-parameter material querying, custom material persistence,
6-axis radar score normalization, and multi-material side-by-side trade-off analysis.
"""

import math
import uuid
import time
import asyncio
from typing import List, Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import or_, and_, desc, asc

from app.models.food_and_packaging import PackagingMaterial
from app.core.material_catalog import (
    PACKAGING_CATALOG,
    MaterialSpecification,
    MaterialCatalogService,
    material_catalog,
)
from app.schemas.packaging_material import (
    MaterialPropertyRadarSchema,
    PackagingMaterialDetailResponse,
    MaterialFilterParams,
    CreatePackagingMaterialInput,
    MaterialComparisonRequest,
    MaterialComparisonResponse,
    MaterialCategorySummaryResponse,
    BarrierProfileDetailSchema,
    MechanicalProfileSchema,
    ThermalProfileSchema,
    OpticalProfileSchema,
    EnvironmentalProfileSchema,
    EconomicProfileSchema,
)


class MaterialService:
    """Core domain service for querying, creating, and comparing packaging materials."""

    def __init__(self, catalog: MaterialCatalogService = material_catalog):
        self.catalog = catalog
        self._db_offline_until: float = 0.0

    def _is_db_ready(self) -> bool:
        return time.time() > self._db_offline_until

    def _mark_db_offline(self):
        self._db_offline_until = time.time() + 10.0  # Cooldown 10s on connection failure

    async def get_materials(
        self,
        db: Optional[AsyncSession] = None,
        filters: Optional[MaterialFilterParams] = None,
        limit: int = 50,
        offset: int = 0,
    ) -> List[PackagingMaterialDetailResponse]:
        """Queries packaging materials with filtering, sorting, and database fallback."""
        if filters is None:
            filters = MaterialFilterParams()

        # 1. Attempt PostgreSQL Query if database session is active and not cooling down
        if db is not None and self._is_db_ready():
            try:
                query = select(PackagingMaterial).where(PackagingMaterial.is_active_entry == True)

                if filters.search:
                    search_term = f"%{filters.search.strip()}%"
                    query = query.where(
                        or_(
                            PackagingMaterial.name.ilike(search_term),
                            PackagingMaterial.category.ilike(search_term),
                            PackagingMaterial.structure.ilike(search_term),
                            PackagingMaterial.polymer_family.ilike(search_term),
                        )
                    )

                if filters.category:
                    query = query.where(PackagingMaterial.category.ilike(f"%{filters.category.strip()}%"))

                if filters.polymer_family:
                    query = query.where(PackagingMaterial.polymer_family.ilike(f"%{filters.polymer_family.strip()}%"))

                if filters.max_otr is not None:
                    query = query.where(PackagingMaterial.otr_cc_m2_day <= filters.max_otr)

                if filters.max_wvtr is not None:
                    query = query.where(PackagingMaterial.wvtr_g_m2_day <= filters.max_wvtr)

                if filters.min_sustainability is not None:
                    query = query.where(PackagingMaterial.sustainability_score >= filters.min_sustainability)

                if filters.is_biodegradable is not None:
                    query = query.where(PackagingMaterial.is_biodegradable == filters.is_biodegradable)

                if filters.is_recyclable is not None:
                    query = query.where(PackagingMaterial.is_recyclable == filters.is_recyclable)

                if filters.is_retort is not None:
                    query = query.where(PackagingMaterial.is_retort_grade == filters.is_retort)

                if filters.is_cryogenic is not None:
                    query = query.where(PackagingMaterial.is_cryogenic_grade == filters.is_cryogenic)

                if filters.cost_tier:
                    query = query.where(PackagingMaterial.cost_category.ilike(f"%{filters.cost_tier.strip()}%"))

                # Sorting
                sort_col = getattr(PackagingMaterial, filters.sort_by or "sustainability_score", PackagingMaterial.sustainability_score)
                if (filters.sort_order or "desc").lower() == "asc":
                    query = query.order_by(asc(sort_col))
                else:
                    query = query.order_by(desc(sort_col))

                query = query.offset(offset).limit(limit)
                result = await db.execute(query)
                db_materials = result.scalars().all()

                if db_materials and len(db_materials) > 0:
                    return [self._db_model_to_detail_response(m) for m in db_materials]
            except Exception:
                self._mark_db_offline()

        # 2. In-Memory Catalog Engine Fallback
        return self.catalog.filter_materials(
            search=filters.search,
            category=filters.category,
            polymer_family=filters.polymer_family,
            max_otr=filters.max_otr,
            max_wvtr=filters.max_wvtr,
            min_sustainability=filters.min_sustainability,
            is_biodegradable=filters.is_biodegradable,
            is_recyclable=filters.is_recyclable,
            is_cryogenic=filters.is_cryogenic,
            is_retort=filters.is_retort,
            cost_tier=filters.cost_tier,
            sort_by=filters.sort_by or "sustainability_score",
            sort_order=filters.sort_order or "desc",
            limit=limit,
            offset=offset,
        )

    async def get_material_by_id(
        self,
        material_id: str,
        db: Optional[AsyncSession] = None,
    ) -> Optional[PackagingMaterialDetailResponse]:
        """Finds a material by ID or unique material identifier."""
        # 1. Check DB if session available and DB is ready
        if db is not None and self._is_db_ready():
            try:
                # Try integer ID or material_id string
                if material_id.isdigit():
                    stmt = select(PackagingMaterial).where(PackagingMaterial.id == int(material_id))
                else:
                    stmt = select(PackagingMaterial).where(PackagingMaterial.material_id == material_id)
                res = await db.execute(stmt)
                m = res.scalars().first()
                if m:
                    return self._db_model_to_detail_response(m)
            except Exception:
                self._mark_db_offline()

        # 2. Check in-memory catalog
        spec = self.catalog.get_material_by_id(material_id)
        if spec:
            return self.catalog.to_detail_response(spec)

        return None

    async def create_material(
        self,
        input_data: CreatePackagingMaterialInput,
        db: Optional[AsyncSession] = None,
    ) -> PackagingMaterialDetailResponse:
        """Persists a new custom packaging material to PostgreSQL and catalog memory."""
        mat_id = input_data.material_id or f"mat_custom_{uuid.uuid4().hex[:8]}"

        spec = MaterialSpecification(
            material_id=mat_id,
            name=input_data.name,
            category=input_data.category,
            polymer_family=input_data.polymer_family,
            structure=input_data.structure,
            thickness_microns=input_data.thickness_microns,
            otr_cc_m2_day=input_data.otr_cc_m2_day,
            wvtr_g_m2_day=input_data.wvtr_g_m2_day,
            tensile_strength_mpa=input_data.tensile_strength_mpa,
            puncture_resistance_n=input_data.puncture_resistance_n,
            sustainability_score=input_data.sustainability_score,
            estimated_unit_cost_inr=input_data.estimated_unit_cost_inr,
            temp_min_c=input_data.temp_min_c,
            temp_max_c=input_data.temp_max_c,
            is_breathable=input_data.is_breathable,
            is_biodegradable=input_data.is_biodegradable,
            is_recyclable=input_data.is_recyclable,
            is_retort_grade=input_data.is_retort_grade,
            is_cryogenic_grade=input_data.is_cryogenic_grade,
            gas_flush_compatible=input_data.gas_flush_compatible,
            recommended_applications=input_data.recommended_applications,
            notes=input_data.notes or "",
            form_factor=input_data.form_factor,
            co2_permeability=input_data.co2_permeability,
            selectivity_beta=input_data.selectivity_beta,
            elongation_pct=input_data.elongation_pct,
            uv_transmittance_pct=input_data.uv_transmittance_pct,
            optical_clarity=input_data.optical_clarity,
            thermal_class=input_data.thermal_class,
            recyclability_score=input_data.recyclability_score,
            biodegradability_score=input_data.biodegradability_score,
            resin_code=input_data.resin_code,
            composting_standard=input_data.composting_standard,
            cost_category=input_data.cost_category,
            regulatory_certifications=input_data.regulatory_certifications,
            is_active_entry=True,
        )

        # Store in in-memory catalog
        self.catalog.add_custom_material(spec)

        db_id = None
        # Attempt DB insert if DB is ready
        if db is not None and self._is_db_ready():
            try:
                db_mat = PackagingMaterial(
                    material_id=mat_id,
                    name=spec.name,
                    category=spec.category,
                    polymer_family=spec.polymer_family,
                    structure=spec.structure,
                    form_factor=spec.form_factor,
                    thickness_microns=spec.thickness_microns,
                    otr_cc_m2_day=spec.otr_cc_m2_day,
                    wvtr_g_m2_day=spec.wvtr_g_m2_day,
                    co2_permeability=spec.co2_permeability,
                    selectivity_beta=spec.selectivity_beta,
                    tensile_strength_mpa=spec.tensile_strength_mpa,
                    puncture_resistance_n=spec.puncture_resistance_n,
                    elongation_pct=spec.elongation_pct,
                    temp_min_c=spec.temp_min_c,
                    temp_max_c=spec.temp_max_c,
                    thermal_class=spec.thermal_class,
                    uv_transmittance_pct=spec.uv_transmittance_pct,
                    optical_clarity=spec.optical_clarity,
                    sustainability_score=spec.sustainability_score,
                    recyclability_score=spec.recyclability_score,
                    biodegradability_score=spec.biodegradability_score,
                    is_biodegradable=spec.is_biodegradable,
                    is_recyclable=spec.is_recyclable,
                    is_breathable=spec.is_breathable,
                    is_retort_grade=spec.is_retort_grade,
                    is_cryogenic_grade=spec.is_cryogenic_grade,
                    gas_flush_compatible=spec.gas_flush_compatible,
                    cost_category=spec.cost_category,
                    estimated_unit_cost_inr=spec.estimated_unit_cost_inr,
                    resin_code=spec.resin_code,
                    composting_standard=spec.composting_standard,
                    recommended_applications=spec.recommended_applications,
                    regulatory_certifications=spec.regulatory_certifications,
                    notes=spec.notes,
                    is_active_entry=True,
                )
                db.add(db_mat)
                await db.commit()
                await db.refresh(db_mat)
                db_id = db_mat.id
            except Exception:
                self._mark_db_offline()
                try:
                    await db.rollback()
                except Exception:
                    pass

        return self.catalog.to_detail_response(spec, db_id=db_id)

    async def update_material(
        self,
        material_id: str,
        input_data: CreatePackagingMaterialInput,
        db: Optional[AsyncSession] = None,
    ) -> Optional[PackagingMaterialDetailResponse]:
        """Updates technical specifications of an existing material."""
        existing = await self.get_material_by_id(material_id, db=db)
        if not existing:
            return None

        # Build updated spec
        spec = MaterialSpecification(
            material_id=material_id,
            name=input_data.name,
            category=input_data.category,
            polymer_family=input_data.polymer_family,
            structure=input_data.structure,
            thickness_microns=input_data.thickness_microns,
            otr_cc_m2_day=input_data.otr_cc_m2_day,
            wvtr_g_m2_day=input_data.wvtr_g_m2_day,
            tensile_strength_mpa=input_data.tensile_strength_mpa,
            puncture_resistance_n=input_data.puncture_resistance_n,
            sustainability_score=input_data.sustainability_score,
            estimated_unit_cost_inr=input_data.estimated_unit_cost_inr,
            temp_min_c=input_data.temp_min_c,
            temp_max_c=input_data.temp_max_c,
            is_breathable=input_data.is_breathable,
            is_biodegradable=input_data.is_biodegradable,
            is_recyclable=input_data.is_recyclable,
            is_retort_grade=input_data.is_retort_grade,
            is_cryogenic_grade=input_data.is_cryogenic_grade,
            gas_flush_compatible=input_data.gas_flush_compatible,
            recommended_applications=input_data.recommended_applications,
            notes=input_data.notes or "",
            form_factor=input_data.form_factor,
            co2_permeability=input_data.co2_permeability,
            selectivity_beta=input_data.selectivity_beta,
            elongation_pct=input_data.elongation_pct,
            uv_transmittance_pct=input_data.uv_transmittance_pct,
            optical_clarity=input_data.optical_clarity,
            thermal_class=input_data.thermal_class,
            recyclability_score=input_data.recyclability_score,
            biodegradability_score=input_data.biodegradability_score,
            resin_code=input_data.resin_code,
            composting_standard=input_data.composting_standard,
            cost_category=input_data.cost_category,
            regulatory_certifications=input_data.regulatory_certifications,
            is_active_entry=True,
        )

        self.catalog.add_custom_material(spec)

        if db is not None and self._is_db_ready():
            try:
                stmt = select(PackagingMaterial).where(PackagingMaterial.material_id == material_id)
                res = await db.execute(stmt)
                db_mat = res.scalars().first()
                if db_mat:
                    for field_name, val in input_data.model_dump(exclude_unset=True).items():
                        setattr(db_mat, field_name, val)
                    await db.commit()
            except Exception:
                self._mark_db_offline()
                try:
                    await db.rollback()
                except Exception:
                    pass

        return self.catalog.to_detail_response(spec, db_id=existing.id)

    async def compare_materials(
        self,
        request: MaterialComparisonRequest,
        db: Optional[AsyncSession] = None,
    ) -> MaterialComparisonResponse:
        """Compares 2 to 4 materials side-by-side on 6-axis performance and highlights trade-offs."""
        materials: List[PackagingMaterialDetailResponse] = []
        for mid in request.material_ids:
            m = await self.get_material_by_id(mid, db=db)
            if m:
                materials.append(m)

        if not materials:
            return MaterialComparisonResponse(
                materials=[],
                radar_datasets={},
                trade_off_analysis=["No valid materials found to compare."],
                best_in_class_highlights={},
            )

        # 1. Compile Radar Datasets
        radar_datasets = {m.material_id: m.radar_scores for m in materials}

        # 2. Determine Best-in-Class
        best_in_class: Dict[str, str] = {}
        best_in_class["Highest Barrier"] = max(materials, key=lambda m: m.radar_scores.barrier_score).name
        best_in_class["Highest Mechanical Strength"] = max(materials, key=lambda m: m.radar_scores.mechanical_score).name
        best_in_class["Most Eco-Friendly"] = max(materials, key=lambda m: m.radar_scores.sustainability_score).name
        best_in_class["Lowest Cost / Unit"] = min(materials, key=lambda m: m.economic_profile.estimated_unit_cost_inr).name
        best_in_class["Widest Thermal Span"] = max(materials, key=lambda m: (m.thermal_profile.temp_max_c - m.thermal_profile.temp_min_c)).name

        # 3. Formulate Trade-off Analysis Statements
        trade_offs: List[str] = []
        if len(materials) >= 2:
            m1 = materials[0]
            for m2 in materials[1:]:
                cost_diff = ((m2.economic_profile.estimated_unit_cost_inr - m1.economic_profile.estimated_unit_cost_inr) / max(0.1, m1.economic_profile.estimated_unit_cost_inr)) * 100.0
                eco_diff = m2.environmental_profile.sustainability_score - m1.environmental_profile.sustainability_score
                
                if abs(eco_diff) >= 15:
                    if eco_diff > 0:
                        trade_offs.append(f"{m2.name} offers +{eco_diff:.0f} pts higher sustainability score over {m1.name} with {cost_diff:+.1f}% cost differential.")
                    else:
                        trade_offs.append(f"{m1.name} provides superior sustainability (+{abs(eco_diff):.0f} pts) compared to {m2.name}.")

                if m2.barrier_profile.otr_cc_m2_day < m1.barrier_profile.otr_cc_m2_day / 2.0:
                    trade_offs.append(f"{m2.name} provides significantly lower oxygen transmission ({m2.barrier_profile.otr_cc_m2_day:.1f} vs {m1.barrier_profile.otr_cc_m2_day:.1f} cc/m²/day).")

        if not trade_offs:
            trade_offs.append(f"Comparison across {len(materials)} candidate materials successfully compiled across 6 evaluation axes.")

        return MaterialComparisonResponse(
            materials=materials,
            radar_datasets=radar_datasets,
            trade_off_analysis=trade_offs,
            best_in_class_highlights=best_in_class,
        )

    async def get_categories_summary(
        self,
        db: Optional[AsyncSession] = None,
    ) -> List[MaterialCategorySummaryResponse]:
        """Provides category taxonomy summaries and aggregates."""
        return self.catalog.get_category_summaries()

    def _db_model_to_detail_response(self, m: PackagingMaterial) -> PackagingMaterialDetailResponse:
        """Converts SQLAlchemy PackagingMaterial row into PackagingMaterialDetailResponse."""
        spec = MaterialSpecification(
            material_id=m.material_id,
            name=m.name,
            category=m.category,
            polymer_family=m.polymer_family,
            structure=m.structure,
            thickness_microns=m.thickness_microns,
            otr_cc_m2_day=m.otr_cc_m2_day,
            wvtr_g_m2_day=m.wvtr_g_m2_day,
            tensile_strength_mpa=m.tensile_strength_mpa,
            puncture_resistance_n=m.puncture_resistance_n,
            sustainability_score=m.sustainability_score,
            estimated_unit_cost_inr=m.estimated_unit_cost_inr,
            temp_min_c=m.temp_min_c,
            temp_max_c=m.temp_max_c,
            is_breathable=m.is_breathable,
            is_biodegradable=m.is_biodegradable,
            is_recyclable=m.is_recyclable,
            is_retort_grade=m.is_retort_grade,
            is_cryogenic_grade=m.is_cryogenic_grade,
            gas_flush_compatible=m.gas_flush_compatible,
            recommended_applications=m.recommended_applications or [],
            notes=m.notes or "",
            form_factor=m.form_factor,
            co2_permeability=m.co2_permeability,
            selectivity_beta=m.selectivity_beta,
            elongation_pct=m.elongation_pct or 100.0,
            uv_transmittance_pct=m.uv_transmittance_pct or 20.0,
            optical_clarity=m.optical_clarity or "Translucent",
            thermal_class=m.thermal_class or "Ambient",
            recyclability_score=m.recyclability_score or 0.0,
            biodegradability_score=m.biodegradability_score or 0.0,
            resin_code=m.resin_code or "OTHER_7",
            composting_standard=m.composting_standard,
            cost_category=m.cost_category or "Commercial Standard",
            regulatory_certifications=m.regulatory_certifications or ["FDA 21 CFR 177", "FSSAI IS 9845"],
            is_active_entry=m.is_active_entry,
        )
        return self.catalog.to_detail_response(spec, db_id=m.id)


material_service = MaterialService()
