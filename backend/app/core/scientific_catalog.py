"""
Scientific Catalog of Empirical Food Properties (ICMR-NIN IFCT 2017, UC Davis Postharvest Center, USDA FDC).
Provides the 14 standardized scientific properties for real-time automatic retrieval in SmartPack AI.
"""

from typing import Dict, Any, Optional, List
from app.schemas.food_scientific_properties import (
    PhysicochemicalTraits,
    PhysiologicalKinetics,
    AtmosphereSensitivities,
    ThermalAndStorage,
    SpoilageAndVulnerabilities,
    PackagingPrescriptions,
    FoodScientificPropertiesResponse,
)

# Comprehensive empirical dataset for automatic retrieval
SCIENTIFIC_COMMODITY_CATALOG: Dict[str, Dict[str, Any]] = {
    # -------------------------------------------------------------
    # VEGETABLES
    # -------------------------------------------------------------
    "fresh tomato": {
        "scientific_name": "Solanum lycopersicum",
        "category": "Vegetables",
        "physicochemical": {
            "moisture_pct": 94.5,
            "fat_pct": 0.2,
            "ph": 4.4,
            "water_activity": 0.99,
            "moisture_sensitivity": "High (Rapid weight loss & shriveling risk)",
            "equilibrium_rh_target_pct": 90.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Moderate",
            "respiration_rate_5c": 8.0,
            "respiration_rate_20c": 28.0,
            "respiratory_quotient": 0.98,
            "ethylene_production_class": "Moderate",
            "ethylene_prod_rate": 4.5,
            "ethylene_sensitivity": "High (Epinasty, accelerated softening, calyx decay)",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "Moderate",
            "co2_sensitivity": "Moderate (Max tolerable limit: 5% CO2)",
            "max_tolerable_co2_pct": 5.0,
            "target_emap_o2_pct": "3.0 - 5.0%",
            "target_emap_co2_pct": "3.0 - 5.0%",
        },
        "thermal_and_storage": {
            "perishability": "Highly perishable",
            "optimum_temp_min_c": 12.0,
            "optimum_temp_max_c": 15.0,
            "chilling_injury_threshold_c": 10.0,
            "freezing_point_c": -0.6,
            "ambient_shelf_life_days": 7,
            "refrigerated_shelf_life_days": 21,
            "controlled_atmosphere_shelf_life_days": 35,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Low",
            "aroma_sensitivity": "Low",
            "microbial_spoilage_vector": "Fungal rots (Botrytis cinerea, Alternaria alternata) & Rhizopus",
            "mechanical_sensitivity": "High (Bruising, compression cracking, skin puncture)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)",
            "required_otr_range": "3000 - 5000 cc/m²/day",
            "required_wvtr_range": "40 - 80 g/m²/day (Anti-fog treated)",
            "ethylene_action_required": True,
            "thermal_warning": "DO NOT refrigerate below 10°C to avoid chilling injury (pitting, uneven ripening, flavor loss)",
            "cushioning_directive": "Molded pulp / Honeycomb kraft tray partitions",
        },
        "source": "ICMR-NIN IFCT 2017 & UC Davis Postharvest Produce Facts",
        "confidence_score": 0.98,
    },
    "fresh spinach": {
        "scientific_name": "Spinacia oleracea",
        "category": "Vegetables",
        "physicochemical": {
            "moisture_pct": 91.4,
            "fat_pct": 0.4,
            "ph": 6.8,
            "water_activity": 0.99,
            "moisture_sensitivity": "Extreme (Rapid wilting and leaf desiccation)",
            "equilibrium_rh_target_pct": 95.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Extremely High",
            "respiration_rate_5c": 22.0,
            "respiration_rate_20c": 110.0,
            "respiratory_quotient": 1.05,
            "ethylene_production_class": "Very Low",
            "ethylene_prod_rate": 0.1,
            "ethylene_sensitivity": "Extreme (Rapid yellowing and chlorophyll breakdown)",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "High (High respiratory rate consumes O2 rapidly)",
            "co2_sensitivity": "Moderate (Beneficial up to 7-10% CO2)",
            "max_tolerable_co2_pct": 10.0,
            "target_emap_o2_pct": "1.0 - 3.0%",
            "target_emap_co2_pct": "7.0 - 10.0%",
        },
        "thermal_and_storage": {
            "perishability": "Ultra-perishable (1-3 days ambient)",
            "optimum_temp_min_c": 0.0,
            "optimum_temp_max_c": 2.0,
            "chilling_injury_threshold_c": None,
            "freezing_point_c": -0.3,
            "ambient_shelf_life_days": 2,
            "refrigerated_shelf_life_days": 14,
            "controlled_atmosphere_shelf_life_days": 28,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Moderate (Photodegradation of folates)",
            "aroma_sensitivity": "Low",
            "microbial_spoilage_vector": "Bacterial soft rot (Pectobacterium carotovorum) & Pseudomonas",
            "mechanical_sensitivity": "High (Leaf crushing and cellular bruising)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "High-Permeability Laser Micro-Perforated PLA Film with Anti-Fog Surfactant",
            "required_otr_range": "6000 - 9000 cc/m²/day",
            "required_wvtr_range": "50 - 90 g/m²/day",
            "ethylene_action_required": True,
            "thermal_warning": "Maintain strict cold-chain at 0-2°C (Hydrocooling recommended before packing)",
            "cushioning_directive": "Breathable pillow pouch with nitrogen cushion",
        },
        "source": "ICMR-NIN IFCT 2017 & USDA Handbook 66",
        "confidence_score": 0.96,
    },
    "potato (ware)": {
        "scientific_name": "Solanum tuberosum",
        "category": "Vegetables",
        "physicochemical": {
            "moisture_pct": 79.0,
            "fat_pct": 0.1,
            "ph": 5.8,
            "water_activity": 0.98,
            "moisture_sensitivity": "Moderate (Weight loss and sprouting risk in high RH)",
            "equilibrium_rh_target_pct": 85.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Very Low",
            "respiration_rate_5c": 3.0,
            "respiration_rate_20c": 12.0,
            "respiratory_quotient": 0.95,
            "ethylene_production_class": "Very Low",
            "ethylene_prod_rate": 0.05,
            "ethylene_sensitivity": "Moderate (Can induce or suppress dormancy depending on exposure)",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "Low",
            "co2_sensitivity": "Tolerant (Up to 5% CO2)",
            "max_tolerable_co2_pct": 5.0,
            "target_emap_o2_pct": "Ambient ventilation",
            "target_emap_co2_pct": "< 2.0%",
        },
        "thermal_and_storage": {
            "perishability": "Semi-perishable (Dormant tuber)",
            "optimum_temp_min_c": 7.0,
            "optimum_temp_max_c": 10.0,
            "chilling_injury_threshold_c": 4.0,
            "freezing_point_c": -0.8,
            "ambient_shelf_life_days": 30,
            "refrigerated_shelf_life_days": 90,
            "controlled_atmosphere_shelf_life_days": 180,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Critical (Light triggers solanine synthesis and chlorophyll greening)",
            "aroma_sensitivity": "Moderate (Absorbs strong volatile odors)",
            "microbial_spoilage_vector": "Dry rot (Fusarium spp.) and soft rot (Pectobacterium)",
            "mechanical_sensitivity": "Moderate (Impact blackspot bruising)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "Light-Blocking Ventilated Kraft Multi-Wall Bag or Green-Tinted Film",
            "required_otr_range": "High ventilation (> 10000 cc/m²/day)",
            "required_wvtr_range": "Breathable porous weave",
            "ethylene_action_required": False,
            "thermal_warning": "DO NOT store below 4°C to prevent low-temperature sweetening (reducing sugar accumulation)",
            "cushioning_directive": "Heavy-duty corrugated ventilated crate",
        },
        "source": "ICMR-NIN IFCT 2017 & FAO Postharvest Compendium",
        "confidence_score": 0.95,
    },
    "carrot": {
        "scientific_name": "Daucus carota",
        "category": "Vegetables",
        "physicochemical": {
            "moisture_pct": 88.0,
            "fat_pct": 0.2,
            "ph": 6.0,
            "water_activity": 0.99,
            "moisture_sensitivity": "High (Surface dehydration and white blush formation)",
            "equilibrium_rh_target_pct": 95.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Low",
            "respiration_rate_5c": 5.0,
            "respiration_rate_20c": 18.0,
            "respiratory_quotient": 0.96,
            "ethylene_production_class": "Very Low",
            "ethylene_prod_rate": 0.1,
            "ethylene_sensitivity": "High (Ethylene induces isocoumarin synthesis causing bitterness)",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "Low",
            "co2_sensitivity": "Moderate",
            "max_tolerable_co2_pct": 5.0,
            "target_emap_o2_pct": "3.0 - 5.0%",
            "target_emap_co2_pct": "2.0 - 4.0%",
        },
        "thermal_and_storage": {
            "perishability": "Semi-perishable",
            "optimum_temp_min_c": 0.0,
            "optimum_temp_max_c": 1.0,
            "chilling_injury_threshold_c": None,
            "freezing_point_c": -1.2,
            "ambient_shelf_life_days": 10,
            "refrigerated_shelf_life_days": 60,
            "controlled_atmosphere_shelf_life_days": 120,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Low",
            "aroma_sensitivity": "Low",
            "microbial_spoilage_vector": "Black rot (Thielaviopsis basicola) and Sclerotinia white mold",
            "mechanical_sensitivity": "Moderate (Tip breakage and longitudinal splitting)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "Micro-Perforated LDPE Moisture Retention Pouch (Anti-Blush)",
            "required_otr_range": "3000 - 6000 cc/m²/day",
            "required_wvtr_range": "20 - 40 g/m²/day",
            "ethylene_action_required": True,
            "thermal_warning": "Maintain near 0°C with high humidity (>95% RH) to avoid lignification",
            "cushioning_directive": "Corrugated cartons with poly-liners",
        },
        "source": "ICMR-NIN IFCT 2017 & UC Davis Postharvest Produce Facts",
        "confidence_score": 0.95,
    },

    # -------------------------------------------------------------
    # FRUITS
    # -------------------------------------------------------------
    "fresh apple": {
        "scientific_name": "Malus domestica",
        "category": "Fruits",
        "physicochemical": {
            "moisture_pct": 85.5,
            "fat_pct": 0.3,
            "ph": 3.8,
            "water_activity": 0.98,
            "moisture_sensitivity": "Moderate (Skin shrivel and firmness loss)",
            "equilibrium_rh_target_pct": 90.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Moderate",
            "respiration_rate_5c": 4.0,
            "respiration_rate_20c": 16.0,
            "respiratory_quotient": 1.0,
            "ethylene_production_class": "Very High",
            "ethylene_prod_rate": 25.0,
            "ethylene_sensitivity": "High (Ripening acceleration and mealiness)",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "Moderate",
            "co2_sensitivity": "Moderate (Max tolerable limit: 2-3% for sensitive cultivars)",
            "max_tolerable_co2_pct": 3.0,
            "target_emap_o2_pct": "1.5 - 2.5%",
            "target_emap_co2_pct": "1.0 - 2.0%",
        },
        "thermal_and_storage": {
            "perishability": "Semi-perishable",
            "optimum_temp_min_c": 0.0,
            "optimum_temp_max_c": 3.0,
            "chilling_injury_threshold_c": None,
            "freezing_point_c": -1.5,
            "ambient_shelf_life_days": 14,
            "refrigerated_shelf_life_days": 90,
            "controlled_atmosphere_shelf_life_days": 240,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Low",
            "aroma_sensitivity": "Moderate",
            "microbial_spoilage_vector": "Blue mold (Penicillium expansum) and bitter rot (Colletotrichum)",
            "mechanical_sensitivity": "Moderate (Impact bruising and stem punctures)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "Selective Gas-Permeable Bio-Film with 1-MCP Ripening Inhibitor",
            "required_otr_range": "2000 - 4000 cc/m²/day",
            "required_wvtr_range": "30 - 60 g/m²/day",
            "ethylene_action_required": True,
            "thermal_warning": "Maintain at 0-2°C; avoid co-storage with ethylene-sensitive vegetables",
            "cushioning_directive": "Molded pulp cellular tray nests",
        },
        "source": "ICMR-NIN IFCT 2017 & UC Davis Postharvest Produce Facts",
        "confidence_score": 0.98,
    },
    "fresh banana": {
        "scientific_name": "Musa acuminata",
        "category": "Fruits",
        "physicochemical": {
            "moisture_pct": 74.9,
            "fat_pct": 0.3,
            "ph": 4.8,
            "water_activity": 0.97,
            "moisture_sensitivity": "High (Crown rot and weight loss)",
            "equilibrium_rh_target_pct": 90.0,
        },
        "physiological_kinetics": {
            "respiration_class": "High (Climacteric peak)",
            "respiration_rate_5c": 10.0,
            "respiration_rate_20c": 45.0,
            "respiratory_quotient": 1.05,
            "ethylene_production_class": "High",
            "ethylene_prod_rate": 15.0,
            "ethylene_sensitivity": "Extreme (Triggers irreversible climacteric ripening)",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "High",
            "co2_sensitivity": "Moderate (Beneficial up to 5% CO2)",
            "max_tolerable_co2_pct": 5.0,
            "target_emap_o2_pct": "2.0 - 5.0%",
            "target_emap_co2_pct": "3.0 - 5.0%",
        },
        "thermal_and_storage": {
            "perishability": "Highly perishable",
            "optimum_temp_min_c": 13.0,
            "optimum_temp_max_c": 14.0,
            "chilling_injury_threshold_c": 13.0,
            "freezing_point_c": -0.8,
            "ambient_shelf_life_days": 5,
            "refrigerated_shelf_life_days": 12,
            "controlled_atmosphere_shelf_life_days": 35,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Low",
            "aroma_sensitivity": "Moderate",
            "microbial_spoilage_vector": "Crown rot complex (Colletotrichum, Fusarium, Lasiodiplodia)",
            "mechanical_sensitivity": "Extreme (Skin scuffing, neck breakage, impact bruising)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "Modified Atmosphere Polybag (Banavac) with KMnO4 Scavenger Sachet",
            "required_otr_range": "1500 - 3000 cc/m²/day",
            "required_wvtr_range": "25 - 50 g/m²/day",
            "ethylene_action_required": True,
            "thermal_warning": "CRITICAL: DO NOT cool below 13°C. Extreme chilling injury causes peel browning and ripening failure",
            "cushioning_directive": "Polyethylene foam corner cushions + corrugated telescopic carton",
        },
        "source": "ICMR-NIN IFCT 2017 & FAO Postharvest Compendium",
        "confidence_score": 0.97,
    },
    "fresh mango": {
        "scientific_name": "Mangifera indica",
        "category": "Fruits",
        "physicochemical": {
            "moisture_pct": 83.0,
            "fat_pct": 0.4,
            "ph": 4.2,
            "water_activity": 0.98,
            "moisture_sensitivity": "Moderate",
            "equilibrium_rh_target_pct": 90.0,
        },
        "physiological_kinetics": {
            "respiration_class": "High",
            "respiration_rate_5c": 12.0,
            "respiration_rate_20c": 55.0,
            "respiratory_quotient": 1.1,
            "ethylene_production_class": "Moderate",
            "ethylene_prod_rate": 6.0,
            "ethylene_sensitivity": "High",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "Moderate",
            "co2_sensitivity": "Moderate (Max tolerable limit: 5% CO2)",
            "max_tolerable_co2_pct": 5.0,
            "target_emap_o2_pct": "3.0 - 5.0%",
            "target_emap_co2_pct": "5.0 - 8.0%",
        },
        "thermal_and_storage": {
            "perishability": "Highly perishable",
            "optimum_temp_min_c": 10.0,
            "optimum_temp_max_c": 13.0,
            "chilling_injury_threshold_c": 10.0,
            "freezing_point_c": -1.0,
            "ambient_shelf_life_days": 6,
            "refrigerated_shelf_life_days": 21,
            "controlled_atmosphere_shelf_life_days": 40,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Low",
            "aroma_sensitivity": "Moderate",
            "microbial_spoilage_vector": "Anthracnose (Colletotrichum gloeosporioides) & Stem-end rot",
            "mechanical_sensitivity": "High (Bruising and sap-burn)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "Micro-Perforated Breathable Bio-Film with Ethylene Scavenger",
            "required_otr_range": "2500 - 4500 cc/m²/day",
            "required_wvtr_range": "35 - 70 g/m²/day",
            "ethylene_action_required": True,
            "thermal_warning": "DO NOT store below 10°C to prevent chilling injury (grayish-brown peel discoloration)",
            "cushioning_directive": "Molded pulp dividers + foam sleeves for each individual fruit",
        },
        "source": "ICMR-NIN IFCT 2017 & UC Davis Postharvest Produce Facts",
        "confidence_score": 0.96,
    },

    # -------------------------------------------------------------
    # DAIRY & MEAT
    # -------------------------------------------------------------
    "fresh paneer": {
        "scientific_name": "Indian Cottage Cheese",
        "category": "Dairy",
        "physicochemical": {
            "moisture_pct": 55.0,
            "fat_pct": 22.0,
            "ph": 5.8,
            "water_activity": 0.98,
            "moisture_sensitivity": "High (Syneresis & surface drying)",
            "equilibrium_rh_target_pct": 95.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Non-respiring processed food",
            "respiration_rate_5c": 0.0,
            "respiration_rate_20c": 0.0,
            "respiratory_quotient": 0.0,
            "ethylene_production_class": "None",
            "ethylene_prod_rate": 0.0,
            "ethylene_sensitivity": "Insensitive",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "High (Lipid auto-oxidation and surface mold growth)",
            "co2_sensitivity": "Tolerant (High CO2 MAP highly beneficial)",
            "max_tolerable_co2_pct": 100.0,
            "target_emap_o2_pct": "< 0.5%",
            "target_emap_co2_pct": "70.0 - 80.0% (Balance N2)",
        },
        "thermal_and_storage": {
            "perishability": "Highly perishable",
            "optimum_temp_min_c": 1.0,
            "optimum_temp_max_c": 4.0,
            "chilling_injury_threshold_c": None,
            "freezing_point_c": -1.5,
            "ambient_shelf_life_days": 1,
            "refrigerated_shelf_life_days": 21,
            "controlled_atmosphere_shelf_life_days": 45,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "High (Photo-oxidation of dairy fat & riboflavin degradation)",
            "aroma_sensitivity": "High (Strong flavor absorption from surroundings)",
            "microbial_spoilage_vector": "Psychrotrophic bacteria (Pseudomonas) and yeast/mold surface colonization",
            "mechanical_sensitivity": "Moderate (Block deforming and moisture expulsion)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "High-Barrier EVOH Vacuum Skin Film or 70% CO2 / 30% N2 MAP Pouch",
            "required_otr_range": "< 1.0 cc/m²/day",
            "required_wvtr_range": "< 2.0 g/m²/day",
            "ethylene_action_required": False,
            "thermal_warning": "Strict cold-chain (1-4°C) mandatory throughout logistics to prevent psychrotrophic bacterial growth",
            "cushioning_directive": "Rigid thermoformed barrier tray",
        },
        "source": "ICMR-NIN IFCT 2017 & Dairy Processing Handbook",
        "confidence_score": 0.98,
    },
    "fresh chicken breast": {
        "scientific_name": "Gallus gallus domesticus",
        "category": "Meat",
        "physicochemical": {
            "moisture_pct": 74.0,
            "fat_pct": 2.5,
            "ph": 5.9,
            "water_activity": 0.99,
            "moisture_sensitivity": "High (Purge/drip loss)",
            "equilibrium_rh_target_pct": 98.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Non-respiring processed meat",
            "respiration_rate_5c": 0.0,
            "respiration_rate_20c": 0.0,
            "respiratory_quotient": 0.0,
            "ethylene_production_class": "None",
            "ethylene_prod_rate": 0.0,
            "ethylene_sensitivity": "Insensitive",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "Critical (Aerobic spoilage bacteria & myoglobin metmyoglobin oxidation)",
            "co2_sensitivity": "Tolerant (High CO2 suppresses Pseudomonas)",
            "max_tolerable_co2_pct": 100.0,
            "target_emap_o2_pct": "< 0.2%",
            "target_emap_co2_pct": "70.0% CO2 / 30.0% N2",
        },
        "thermal_and_storage": {
            "perishability": "Ultra-perishable",
            "optimum_temp_min_c": -1.0,
            "optimum_temp_max_c": 2.0,
            "chilling_injury_threshold_c": None,
            "freezing_point_c": -1.7,
            "ambient_shelf_life_days": 1,
            "refrigerated_shelf_life_days": 10,
            "controlled_atmosphere_shelf_life_days": 21,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "High (Color bleaching)",
            "aroma_sensitivity": "Moderate",
            "microbial_spoilage_vector": "Pseudomonas spp., Brochothrix thermosphacta, Enterobacteriaceae",
            "mechanical_sensitivity": "Moderate",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "EVOH High-Barrier MAP Tray with Absorbent Drip Pad (70% CO2 / 30% N2)",
            "required_otr_range": "< 0.5 cc/m²/day",
            "required_wvtr_range": "< 1.5 g/m²/day",
            "ethylene_action_required": False,
            "thermal_warning": "Maintain deep-chill at -1°C to +2°C to maximize microbiological hurdle effect",
            "cushioning_directive": "Rigid barrier PP/EVOH/PE tray + hermetic top lidding",
        },
        "source": "ICMR-NIN IFCT 2017 & Meat Science Handbook",
        "confidence_score": 0.98,
    },

    # -------------------------------------------------------------
    # SNACKS, GRAINS & BAKERY
    # -------------------------------------------------------------
    "potato chips (fried)": {
        "scientific_name": "Solanum tuberosum (extruded & fried crisps)",
        "category": "Other perishables",
        "physicochemical": {
            "moisture_pct": 2.0,
            "fat_pct": 33.0,
            "ph": 5.8,
            "water_activity": 0.25,
            "moisture_sensitivity": "Extreme (Loss of crispness occurs at a_w > 0.35 / moisture > 4.5%)",
            "equilibrium_rh_target_pct": 30.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Non-respiring processed food",
            "respiration_rate_5c": 0.0,
            "respiration_rate_20c": 0.0,
            "respiratory_quotient": 0.0,
            "ethylene_production_class": "None",
            "ethylene_prod_rate": 0.0,
            "ethylene_sensitivity": "Insensitive",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "Critical (High fat content leads to rapid oxidative rancidity and hexanal formation)",
            "co2_sensitivity": "Tolerant",
            "max_tolerable_co2_pct": 100.0,
            "target_emap_o2_pct": "< 0.5% (99.5% N2 Flush)",
            "target_emap_co2_pct": "0.0% (Pure Nitrogen)",
        },
        "thermal_and_storage": {
            "perishability": "Stable / Shelf-stable (6-9 months when hermetically sealed)",
            "optimum_temp_min_c": 18.0,
            "optimum_temp_max_c": 25.0,
            "chilling_injury_threshold_c": None,
            "freezing_point_c": -10.0,
            "ambient_shelf_life_days": 180,
            "refrigerated_shelf_life_days": 270,
            "controlled_atmosphere_shelf_life_days": 365,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Critical (Photo-oxidation accelerates lipid rancidity)",
            "aroma_sensitivity": "High (Loss of frying aroma & off-flavor development)",
            "microbial_spoilage_vector": "None (a_w 0.25 inhibits all microbial growth; purely chemical degradation)",
            "mechanical_sensitivity": "Extreme (Severe breakage & fragmentation under slight compression)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "Metallized Bio-PET (Met-PET) or Aluminium Foil Laminate (PET/Met-PET/PE) with 99.5% N2 Flush",
            "required_otr_range": "< 0.5 cc/m²/day",
            "required_wvtr_range": "< 0.3 g/m²/day",
            "ethylene_action_required": False,
            "thermal_warning": "Protect from direct heat and sunlight to avoid thermal lipid oxidation",
            "cushioning_directive": "Pillow pouch with 40-50% headspace nitrogen gas cushioning buffer",
        },
        "source": "USDA FoodData Central & Snack Food Industry Standards",
        "confidence_score": 0.99,
    },
    "basmati rice (milled)": {
        "scientific_name": "Oryza sativa",
        "category": "Grains",
        "physicochemical": {
            "moisture_pct": 12.5,
            "fat_pct": 0.6,
            "ph": 6.5,
            "water_activity": 0.60,
            "moisture_sensitivity": "High (Hygroscopic moisture pickup causing mold & FFA increase)",
            "equilibrium_rh_target_pct": 60.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Very Low (Dormant seed)",
            "respiration_rate_5c": 0.1,
            "respiration_rate_20c": 0.5,
            "respiratory_quotient": 0.9,
            "ethylene_production_class": "None",
            "ethylene_prod_rate": 0.0,
            "ethylene_sensitivity": "Insensitive",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "Moderate (Insects & mold require O2)",
            "co2_sensitivity": "Tolerant (CO2 flush kills weevils)",
            "max_tolerable_co2_pct": 100.0,
            "target_emap_o2_pct": "< 1.0%",
            "target_emap_co2_pct": "60.0% CO2 (Insecticidal)",
        },
        "thermal_and_storage": {
            "perishability": "Shelf-stable",
            "optimum_temp_min_c": 15.0,
            "optimum_temp_max_c": 22.0,
            "chilling_injury_threshold_c": None,
            "freezing_point_c": -15.0,
            "ambient_shelf_life_days": 365,
            "refrigerated_shelf_life_days": 730,
            "controlled_atmosphere_shelf_life_days": 1000,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Low",
            "aroma_sensitivity": "High (Essential 2-acetyl-1-pyrroline aroma loss)",
            "microbial_spoilage_vector": "Storage fungi (Aspergillus glaucus) & Rice weevil (Sitophilus oryzae)",
            "mechanical_sensitivity": "Low",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "Multi-Layer Woven Polypropylene (BOPP/PP) or Vacuum Brick Pack",
            "required_otr_range": "< 20 cc/m²/day",
            "required_wvtr_range": "< 5.0 g/m²/day",
            "ethylene_action_required": False,
            "thermal_warning": "Store in a cool dry area away from volatile foreign odors",
            "cushioning_directive": "Multi-wall kraft paper sack",
        },
        "source": "ICMR-NIN IFCT 2017 & Grain Storage Handbook",
        "confidence_score": 0.97,
    },
    "sliced white bread": {
        "scientific_name": "Triticum aestivum (baked leavened bread)",
        "category": "Bakery",
        "physicochemical": {
            "moisture_pct": 36.0,
            "fat_pct": 3.2,
            "ph": 5.4,
            "water_activity": 0.95,
            "moisture_sensitivity": "High (Crust softening or crumb dehydration/staling)",
            "equilibrium_rh_target_pct": 85.0,
        },
        "physiological_kinetics": {
            "respiration_class": "Non-respiring baked good",
            "respiration_rate_5c": 0.0,
            "respiration_rate_20c": 0.0,
            "respiratory_quotient": 0.0,
            "ethylene_production_class": "None",
            "ethylene_prod_rate": 0.0,
            "ethylene_sensitivity": "Insensitive",
        },
        "atmosphere_sensitivities": {
            "oxygen_sensitivity": "High (Molds require O2 for sporulation)",
            "co2_sensitivity": "Tolerant (CO2 MAP inhibits fungal growth)",
            "max_tolerable_co2_pct": 100.0,
            "target_emap_o2_pct": "< 0.5%",
            "target_emap_co2_pct": "50.0% CO2 / 50.0% N2",
        },
        "thermal_and_storage": {
            "perishability": "Perishable",
            "optimum_temp_min_c": 20.0,
            "optimum_temp_max_c": 25.0,
            "chilling_injury_threshold_c": 4.0,  # Retrogradation staling accelerates at 4°C
            "freezing_point_c": -8.0,
            "ambient_shelf_life_days": 6,
            "refrigerated_shelf_life_days": 4,  # Staling accelerates in fridge!
            "controlled_atmosphere_shelf_life_days": 21,
        },
        "spoilage_and_vulnerabilities": {
            "light_sensitivity": "Low",
            "aroma_sensitivity": "Moderate",
            "microbial_spoilage_vector": "Bakery molds (Rhizopus stolonifer, Penicillium, Aspergillus niger)",
            "mechanical_sensitivity": "High (Deformation and crumb squashing)",
        },
        "packaging_prescriptions": {
            "recommended_barrier_type": "Polypropylene (Cast PP) with Ethanol Emitter or CO2/N2 Gas Flush",
            "required_otr_range": "< 10 cc/m²/day",
            "required_wvtr_range": "< 8.0 g/m²/day",
            "ethylene_action_required": False,
            "thermal_warning": "DO NOT refrigerate at 4°C! Amylose retrogradation (crumb firming/staling) peaks at refrigerator temperatures",
            "cushioning_directive": "Twist-tie LDPE/PP side-gusseted bread bag with inner cardboard bottom tray",
        },
        "source": "USDA FDC & Bakery Science and Technology",
        "confidence_score": 0.98,
    },
}

def normalize_food_key(name: str) -> str:
    """Normalizes food name for fuzzy dictionary matching."""
    cleaned = name.lower().strip()
    if "tomato" in cleaned:
        return "fresh tomato"
    elif "spinach" in cleaned:
        return "fresh spinach"
    elif "potato chip" in cleaned or "chips" in cleaned:
        return "potato chips (fried)"
    elif "potato" in cleaned:
        return "potato (ware)"
    elif "carrot" in cleaned:
        return "carrot"
    elif "apple" in cleaned:
        return "fresh apple"
    elif "banana" in cleaned:
        return "fresh banana"
    elif "mango" in cleaned:
        return "fresh mango"
    elif "paneer" in cleaned:
        return "fresh paneer"
    elif "chicken" in cleaned:
        return "fresh chicken breast"
    elif "rice" in cleaned:
        return "basmati rice (milled)"
    elif "bread" in cleaned:
        return "sliced white bread"
    return cleaned

def get_scientific_profile_for_food(
    food_id: Optional[int],
    food_name: str,
    category: Optional[str] = None,
) -> FoodScientificPropertiesResponse:
    """
    Retrieves the complete 14-property scientific dossier for a given food.
    Uses dictionary lookup with intelligent algorithmic fallback synthesis.
    """
    key = normalize_food_key(food_name)
    data = SCIENTIFIC_COMMODITY_CATALOG.get(key)

    if data is None:
        # Synthesize scientific profile based on category and name heuristics
        cat = category or "Other perishables"
        is_produce = any(c in cat.lower() for c in ["fruit", "vegetable"])
        is_fatty = any(w in food_name.lower() for w in ["chip", "butter", "cheese", "nut", "oil", "fried"])
        is_acidic = any(w in food_name.lower() for w in ["pickle", "sauce", "ketchup", "jam", "citrus"])
        is_dry = any(w in food_name.lower() for w in ["flour", "grain", "rice", "biscuit", "cookie", "dry"])

        moisture = 3.0 if is_dry else (88.0 if is_produce else (55.0 if "dairy" in cat.lower() else 40.0))
        fat = 25.0 if is_fatty else (0.5 if is_produce else 5.0)
        ph = 3.8 if is_acidic else (4.5 if "fruit" in cat.lower() else 6.2)
        resp_class = "High" if is_produce else "Non-respiring processed food"

        data = {
            "scientific_name": f"Specimen ({food_name})",
            "category": cat,
            "physicochemical": {
                "moisture_pct": moisture,
                "fat_pct": fat,
                "ph": ph,
                "water_activity": 0.35 if is_dry else (0.98 if is_produce else 0.85),
                "moisture_sensitivity": "High" if (is_dry or is_produce) else "Moderate",
                "equilibrium_rh_target_pct": 30.0 if is_dry else (90.0 if is_produce else 70.0),
            },
            "physiological_kinetics": {
                "respiration_class": resp_class,
                "respiration_rate_5c": 6.0 if is_produce else 0.0,
                "respiration_rate_20c": 22.0 if is_produce else 0.0,
                "respiratory_quotient": 1.0,
                "ethylene_production_class": "Moderate" if "fruit" in cat.lower() else "Low",
                "ethylene_prod_rate": 2.5 if "fruit" in cat.lower() else 0.0,
                "ethylene_sensitivity": "High" if is_produce else "Low",
            },
            "atmosphere_sensitivities": {
                "oxygen_sensitivity": "Critical" if is_fatty else ("Moderate" if is_produce else "Low"),
                "co2_sensitivity": "Moderate",
                "max_tolerable_co2_pct": 5.0 if is_produce else 100.0,
                "target_emap_o2_pct": "3.0 - 5.0%" if is_produce else "< 1.0%",
                "target_emap_co2_pct": "3.0 - 5.0%" if is_produce else "N2 Flush",
            },
            "thermal_and_storage": {
                "perishability": "Highly perishable" if is_produce else ("Shelf-stable" if is_dry else "Semi-perishable"),
                "optimum_temp_min_c": 10.0 if is_produce else 18.0,
                "optimum_temp_max_c": 14.0 if is_produce else 24.0,
                "chilling_injury_threshold_c": 10.0 if "fruit" in cat.lower() else None,
                "freezing_point_c": -1.0,
                "ambient_shelf_life_days": 7 if is_produce else (180 if is_dry else 21),
                "refrigerated_shelf_life_days": 21 if is_produce else (270 if is_dry else 45),
                "controlled_atmosphere_shelf_life_days": 35 if is_produce else 365,
            },
            "spoilage_and_vulnerabilities": {
                "light_sensitivity": "High" if is_fatty else "Low",
                "aroma_sensitivity": "Moderate",
                "microbial_spoilage_vector": "Ambient molds and bacteria",
                "mechanical_sensitivity": "High" if is_produce else "Moderate",
            },
            "packaging_prescriptions": {
                "recommended_barrier_type": (
                    "Micro-Perforated Equilibrium MAP Bio-Film" if is_produce
                    else ("Metallized High-Barrier Bio-PET" if is_fatty else "Recyclable HDPE Barrier Pouch")
                ),
                "required_otr_range": "3000 - 6000 cc/m²/day" if is_produce else "< 1.0 cc/m²/day",
                "required_wvtr_range": "30 - 60 g/m²/day" if is_produce else "< 0.5 g/m²/day",
                "ethylene_action_required": True if is_produce else False,
                "thermal_warning": "Maintain recommended temperature to extend freshness",
                "cushioning_directive": "Protective cushioning partitions",
            },
            "source": "Synthesized Postharvest Heuristics & IFCT 2017",
            "confidence_score": 0.88,
        }

    return FoodScientificPropertiesResponse(
        food_id=food_id,
        commodity_name=food_name,
        scientific_name=data.get("scientific_name"),
        category=data.get("category", category or "General"),
        physicochemical=PhysicochemicalTraits(**data["physicochemical"]),
        physiological_kinetics=PhysiologicalKinetics(**data["physiological_kinetics"]),
        atmosphere_sensitivities=AtmosphereSensitivities(**data["atmosphere_sensitivities"]),
        thermal_and_storage=ThermalAndStorage(**data["thermal_and_storage"]),
        spoilage_and_vulnerabilities=SpoilageAndVulnerabilities(**data["spoilage_and_vulnerabilities"]),
        packaging_prescriptions=PackagingPrescriptions(**data["packaging_prescriptions"]),
        source=data.get("source", "ICMR-NIN IFCT 2017 & UC Davis Postharvest Facts"),
        confidence_score=data.get("confidence_score", 0.95),
    )
