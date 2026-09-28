"""
Sustainability Analysis & Life Cycle Assessment (LCA) Service (Module 11).
Computes empirical carbon footprint (GWP in kg CO2e), freshwater consumption (Liters),
PCR carbon abatement, packaging solid waste burden, landfill diversion, and
Material Circularity Index (MCI) using verified peer-reviewed LCI coefficients.
"""

from typing import Dict, List, Optional, Any
from app.schemas.sustainability import (
    RecyclabilityTier,
    BiodegradabilityTier,
    ReusabilityTier,
    WastePotentialLevel,
    SustainabilityEvaluateRequest,
    EnvironmentalIndicatorSchema,
    PackagingWasteSchema,
    SustainabilityProfileResponse,
    SustainabilityCompareRequest,
    SustainabilityCompareResponse,
)
from app.core.sustainability_matrix import (
    SustainabilityMatrixEntry,
    VERIFIED_SUSTAINABILITY_MATRIX,
    DEFAULT_SUSTAINABILITY_FALLBACK,
    get_sustainability_matrix_entry,
)
from app.services.geometry_calculator import GeometryCalculator
from app.schemas.cost_estimation import PackageDimensionsInput, PackagingFormFactorEnum


class SustainabilityService:
    """Core domain service for empirical packaging sustainability and LCA calculations."""

    # Density lookups in kg/m³ for precise mass calculations
    POLYMER_DENSITIES_KG_M3: Dict[str, float] = {
        "mat_bio_emap_01": 1250.0,
        "mat_cell_natureflex_02": 1450.0,
        "mat_poly_ldpe_01": 920.0,
        "mat_poly_hdpe_02": 955.0,
        "mat_bopp_film_03": 905.0,
        "mat_pet_bo_04": 1380.0,
        "mat_rpet_50_05": 1380.0,
        "mat_lam_foil_06": 2700.0,
        "mat_board_fsc_07": 750.0,
    }
    DEFAULT_DENSITY_KG_M3: float = 1000.0

    @classmethod
    def get_matrix_entries(cls) -> List[SustainabilityMatrixEntry]:
        """Returns the full verified empirical sustainability matrix dataset."""
        return list(VERIFIED_SUSTAINABILITY_MATRIX.values())

    @classmethod
    def get_material_profile(
        cls,
        material_id: str,
        batch_size_units: int = 10000,
        package_type: str = "Stand-up Doypack (Bottom Gusset)",
        length_cm: float = 18.0,
        width_cm: float = 12.0,
        depth_or_gusset_cm: float = 4.0,
        thickness_microns: float = 50.0,
        pcr_percentage: float = 0.0,
    ) -> SustainabilityProfileResponse:
        """Convenience method to retrieve baseline profile for a material ID."""
        request = SustainabilityEvaluateRequest(
            material_id=material_id,
            package_type=package_type,
            length_cm=length_cm,
            width_cm=width_cm,
            depth_or_gusset_cm=depth_or_gusset_cm,
            thickness_microns=thickness_microns,
            batch_size_units=batch_size_units,
            pcr_percentage=pcr_percentage,
        )
        return cls.evaluate_sustainability(request)

    @classmethod
    def evaluate_sustainability(
        cls,
        request: SustainabilityEvaluateRequest,
    ) -> SustainabilityProfileResponse:
        """
        Performs parametric LCA carbon/water footprint and waste circularity evaluation.
        """
        # 1. Fetch verified LCI matrix entry
        entry = get_sustainability_matrix_entry(request.material_id or request.material_name or "")

        # 2. Derive Unit Mass (M_unit in kg)
        unit_mass_kg = 0.0
        if request.unit_mass_grams is not None and request.unit_mass_grams > 0:
            unit_mass_kg = request.unit_mass_grams / 1000.0
        else:
            # Calculate geometric surface area
            dims = PackageDimensionsInput(
                length_cm=request.length_cm,
                width_cm=request.width_cm,
                depth_or_gusset_cm=request.depth_or_gusset_cm,
                thickness_microns=request.thickness_microns,
            )
            form_factor = cls._map_to_form_factor(request.package_type)
            surface_area_m2 = GeometryCalculator.calculate_surface_area(form_factor, dims)
            
            # Substrate thickness in meters (microns * 10^-6)
            thickness_m = (request.thickness_microns or 50.0) * 1e-6
            
            # Substrate density in kg/m³
            density_kg_m3 = cls.POLYMER_DENSITIES_KG_M3.get(entry.material_id, cls.DEFAULT_DENSITY_KG_M3)
            
            # Unit mass in kg
            unit_mass_kg = surface_area_m2 * thickness_m * density_kg_m3

        unit_mass_grams = max(0.1, unit_mass_kg * 1000.0)
        batch_size = request.batch_size_units
        total_batch_mass_kg = unit_mass_kg * batch_size

        # 3. PCR Content & Carbon Footprint Calculation
        # Clamp PCR fraction to material maximum allowance
        max_pcr = entry.max_pcr_content_pct / 100.0
        requested_pcr = (request.pcr_percentage or 0.0) / 100.0
        effective_pcr_fraction = min(max_pcr, max(0.0, requested_pcr))
        
        # If material is already an rPET blend (e.g. 50% rPET), account for baseline PCR
        if "rpet" in entry.material_id.lower() and effective_pcr_fraction == 0.0:
            effective_pcr_fraction = 0.50

        # GWP raw calculation: (GWP_virgin * (1 - f_pcr)) + (GWP_pcr * f_pcr)
        gwp_resin = (entry.gwp_virgin_kg_co2e_per_kg * (1.0 - effective_pcr_fraction)) + (
            entry.gwp_pcr_kg_co2e_per_kg * effective_pcr_fraction
        )
        total_gwp_per_kg = gwp_resin + entry.gwp_converting_kg_co2e_per_kg
        
        # Unit and Batch Carbon footprint in kg CO2e
        carbon_per_unit = unit_mass_kg * total_gwp_per_kg
        carbon_total_batch = carbon_per_unit * batch_size

        # Carbon reduction percentage from PCR compared to 100% virgin
        virgin_total_gwp = entry.gwp_virgin_kg_co2e_per_kg + entry.gwp_converting_kg_co2e_per_kg
        pcr_carbon_reduction_pct = 0.0
        if virgin_total_gwp > 0 and effective_pcr_fraction > 0:
            pcr_carbon_reduction_pct = round(
                ((virgin_total_gwp - total_gwp_per_kg) / virgin_total_gwp) * 100.0, 1
            )

        # 4. Freshwater Consumption Footprint (Liters)
        # PCR also saves water compared to virgin synthesis
        water_intensity = entry.water_intensity_l_per_kg * (1.0 - (0.45 * effective_pcr_fraction))
        water_per_unit = unit_mass_kg * water_intensity
        water_total_batch = water_per_unit * batch_size

        # Primary energy demand in MJ/kg
        embodied_energy = entry.embodied_energy_mj_per_kg * (1.0 - (0.35 * effective_pcr_fraction))

        # 5. Packaging Solid Waste & Circularity Metrics
        landfill_diversion_pct = entry.diversion_potential_pct
        landfill_burden_kg = total_batch_mass_kg * (1.0 - (landfill_diversion_pct / 100.0))
        
        # Adjust circularity index with PCR usage
        circularity_index = min(
            1.0, round(entry.circularity_base_index + (0.12 * effective_pcr_fraction), 2)
        )

        return SustainabilityProfileResponse(
            material_id=entry.material_id,
            material_name=entry.name,
            category=entry.category,
            polymer_family=entry.polymer_family,
            resin_identification_code=entry.resin_identification_code,
            recyclability=entry.recyclability,
            recyclability_notes=entry.recyclability_notes,
            biodegradability=entry.biodegradability,
            biodegradability_standard=entry.biodegradability_standard,
            biodegradability_notes=entry.biodegradability_notes,
            reusability=entry.reusability,
            reusability_cycles=entry.reusability_cycles,
            material_type_description=entry.material_type_description,
            pcr_content_pct=round(effective_pcr_fraction * 100.0, 1),
            bio_based_content_pct=entry.bio_based_content_pct,
            environmental_considerations=entry.environmental_considerations,
            regulatory_certifications=entry.regulatory_certifications,
            environmental_indicators=EnvironmentalIndicatorSchema(
                carbon_footprint_kg_co2e_per_unit=round(carbon_per_unit, 4),
                carbon_footprint_kg_co2e_total_batch=round(carbon_total_batch, 2),
                water_footprint_liters_per_unit=round(water_per_unit, 2),
                water_footprint_liters_total_batch=round(water_total_batch, 1),
                pcr_carbon_reduction_pct=pcr_carbon_reduction_pct,
                embodied_energy_mj_per_kg=round(embodied_energy, 1),
            ),
            waste_potential=PackagingWasteSchema(
                unit_waste_grams=round(unit_mass_grams, 2),
                total_batch_waste_kg=round(total_batch_mass_kg, 2),
                waste_potential_level=entry.waste_potential_level,
                landfill_burden_kg=round(landfill_burden_kg, 2),
                diversion_potential_pct=landfill_diversion_pct,
                circularity_index=circularity_index,
                primary_disposal_pathway=entry.primary_disposal_pathway,
            ),
            verified_data_source=entry.verified_data_source,
            source_doi_or_standard=entry.source_doi_or_standard,
            is_empirical_verified=True,
        )

    @classmethod
    def compare_sustainability(
        cls,
        request: SustainabilityCompareRequest,
    ) -> SustainabilityCompareResponse:
        """
        Evaluates and ranks up to 4 materials side-by-side on sustainability criteria.
        """
        profiles: List[SustainabilityProfileResponse] = []
        for mat_id in request.material_ids:
            eval_req = SustainabilityEvaluateRequest(
                material_id=mat_id,
                package_type=request.package_type,
                length_cm=request.length_cm,
                width_cm=request.width_cm,
                depth_or_gusset_cm=request.depth_or_gusset_cm,
                thickness_microns=request.thickness_microns,
                batch_size_units=request.batch_size_units,
            )
            profiles.append(cls.evaluate_sustainability(eval_req))

        # Determine best in class
        # 1. Best recyclability: Highest enum order or High tier
        best_rec_profile = max(
            profiles,
            key=lambda p: (
                3 if p.recyclability == RecyclabilityTier.HIGH else (
                    2 if p.recyclability == RecyclabilityTier.MEDIUM else (
                        1 if p.recyclability == RecyclabilityTier.LOW else 0
                    )
                ),
                p.waste_potential.circularity_index,
            )
        )

        # 2. Lowest carbon footprint
        lowest_carbon_profile = min(
            profiles,
            key=lambda p: p.environmental_indicators.carbon_footprint_kg_co2e_total_batch,
        )

        # 3. Lowest total solid waste
        lowest_waste_profile = min(
            profiles,
            key=lambda p: p.waste_potential.total_batch_waste_kg,
        )

        # Synthesize eco trade-off summary
        summary = (
            f"Comparison of {len(profiles)} packaging formats for a batch of {request.batch_size_units:,} units: "
            f"'{lowest_carbon_profile.material_name}' offers the lowest carbon footprint "
            f"({lowest_carbon_profile.environmental_indicators.carbon_footprint_kg_co2e_total_batch:.1f} kg CO2e), "
            f"while '{best_rec_profile.material_name}' provides superior circularity and recyclability ({best_rec_profile.recyclability.value})."
        )

        return SustainabilityCompareResponse(
            materials=profiles,
            best_recyclability_material_id=best_rec_profile.material_id,
            lowest_carbon_material_id=lowest_carbon_profile.material_id,
            lowest_waste_material_id=lowest_waste_profile.material_id,
            eco_tradeoff_summary=summary,
        )

    @staticmethod
    def _map_to_form_factor(form_factor_str: str) -> PackagingFormFactorEnum:
        """Normalizes user input string to PackagingFormFactorEnum."""
        if not form_factor_str:
            return PackagingFormFactorEnum.STAND_UP_DOYPACK

        cleaned = form_factor_str.lower()
        if "pillow" in cleaned:
            return PackagingFormFactorEnum.PILLOW_POUCH
        if "3-side" in cleaned or "three" in cleaned:
            return PackagingFormFactorEnum.THREE_SIDE_SEAL
        if "4-side" in cleaned or "quad" in cleaned:
            return PackagingFormFactorEnum.FOUR_SIDE_QUAD_SEAL
        if "tray" in cleaned or "clamshell" in cleaned or "thermoform" in cleaned:
            return PackagingFormFactorEnum.THERMOFORMED_TRAY
        if "vacuum" in cleaned or "retort" in cleaned:
            return PackagingFormFactorEnum.VACUUM_BAG
        if "carton" in cleaned or "box" in cleaned:
            return PackagingFormFactorEnum.FOLDING_CARTON
        return PackagingFormFactorEnum.STAND_UP_DOYPACK
