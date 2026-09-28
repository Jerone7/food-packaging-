"""
Geometry Calculator for Packaging Form Factors (Module 10).
Calculates accurate single-unit geometric surface area (in m² and cm²)
accounting for seam allowances, gusset depth, bottom inserts, and draw margins.
"""

from typing import Union
from app.schemas.cost_estimation import PackagingFormFactorEnum, PackageDimensionsInput


class GeometryCalculator:
    """
    Parametric Surface Area Calculator for Food Packaging Form Factors.
    All internal calculations use meters (m) and output square meters (m²).
    """

    # Standard seam allowance in meters (10mm = 0.01m)
    DEFAULT_SEAM_MARGIN_M: float = 0.010

    # Doypack bottom oval insert trim factor
    DOYPACK_BOTTOM_INSERT_FACTOR: float = 1.15

    # Thermoformed tray draw thinning and perimeter flange margin factor
    TRAY_DRAW_FLANGE_FACTOR: float = 1.12

    # Folding carton tuck flaps, glue tabs, and dust wings multiplier
    CARTON_FLAP_MULTIPLIER: float = 1.22

    @classmethod
    def calculate_surface_area(
        cls,
        packaging_type: Union[PackagingFormFactorEnum, str],
        dimensions: PackageDimensionsInput,
        custom_seam_margin_m: float = DEFAULT_SEAM_MARGIN_M,
    ) -> float:
        """
        Calculates the single-unit packaging surface area in square meters (m²).
        
        :param packaging_type: Packaging form factor enum or string name
        :param dimensions: PackageDimensionsInput with length_cm, width_cm, depth_or_gusset_cm
        :param custom_seam_margin_m: Optional override for edge heat-seam margin in meters
        :return: Single-unit surface area in m²
        """
        # Convert dimensions from cm to meters
        L_m = dimensions.length_cm / 100.0
        W_m = dimensions.width_cm / 100.0
        G_m = (dimensions.depth_or_gusset_cm or 0.0) / 100.0
        S_m = custom_seam_margin_m

        # Normalize string packaging_type to enum value
        type_str = packaging_type.value if hasattr(packaging_type, "value") else str(packaging_type)

        if type_str == PackagingFormFactorEnum.PILLOW_POUCH.value:
            # Form-Fill-Seal pillow pouch: 2 panels with top/bottom cross seal (2S) and fin/lap seal (S)
            return 2.0 * (L_m + 2.0 * S_m) * (W_m + S_m)

        elif type_str == PackagingFormFactorEnum.STAND_UP_DOYPACK.value:
            # Stand-up Doypack: Front and Back panels + W-fold bottom gusset insert with trim allowance
            gusset = G_m if G_m > 0 else (W_m * 0.35) # fallback if 0
            main_panels = 2.0 * (L_m + S_m) * (W_m + S_m)
            bottom_gusset = (W_m + S_m) * (gusset + S_m) * cls.DOYPACK_BOTTOM_INSERT_FACTOR
            return main_panels + bottom_gusset

        elif type_str == PackagingFormFactorEnum.THREE_SIDE_SEAL.value:
            # 3-Side Seal Flat Pouch: 2 side seams (2S) and 1 bottom/top seam (S)
            return 2.0 * (L_m + S_m) * (W_m + 2.0 * S_m)

        elif type_str == PackagingFormFactorEnum.FOUR_SIDE_QUAD_SEAL.value:
            # 4-Side Quad Seal (Side-Gusset Pouch): 2 main faces + 2 side gussets + 4 corner edge seals
            gusset = G_m if G_m > 0 else (W_m * 0.40)
            return 2.0 * (L_m + 2.0 * S_m) * (W_m + 2.0 * gusset + 2.0 * S_m)

        elif type_str == PackagingFormFactorEnum.THERMOFORMED_TRAY.value:
            # Rigid Tray / Hinged Clamshell: Base + 2 Length sides + 2 Width sides + draw flange
            H_m = G_m if G_m > 0 else 0.04 # fallback 4cm depth if not specified
            raw_box_area = (L_m * W_m) + 2.0 * (L_m * H_m) + 2.0 * (W_m * H_m)
            return raw_box_area * cls.TRAY_DRAW_FLANGE_FACTOR

        elif type_str == PackagingFormFactorEnum.VACUUM_RETORT_POUCH.value:
            # Vacuum Retort Pouch: Heavy perimeter 4-side hermetic seal (2S length, 2S width)
            return 2.0 * (L_m + 2.0 * S_m) * (W_m + 2.0 * S_m)

        elif type_str == PackagingFormFactorEnum.FOLDING_CARTON.value:
            # Paperboard Folding Box: 6 faces + glue flap + tuck wings
            H_m = G_m if G_m > 0 else 0.05 # fallback 5cm depth
            six_faces = 2.0 * ((L_m * W_m) + (L_m * H_m) + (W_m * H_m))
            return six_faces * cls.CARTON_FLAP_MULTIPLIER

        else:
            # Default conservative rectangular sleeve
            return 2.0 * (L_m + 2.0 * S_m) * (W_m + 2.0 * S_m)

    @staticmethod
    def sqm_to_sqcm(area_sqm: float) -> float:
        """Converts square meters (m²) to square centimeters (cm²)."""
        return area_sqm * 10000.0

    @staticmethod
    def sqcm_to_sqm(area_sqcm: float) -> float:
        """Converts square centimeters (cm²) to square meters (m²)."""
        return area_sqcm / 10000.0
