import 'package:flutter/material.dart';

class PhysicochemicalTraits {
  final double moisturePct;
  final double fatPct;
  final double ph;
  final double waterActivity;
  final String moistureSensitivity;
  final double? equilibriumRhTargetPct;

  const PhysicochemicalTraits({
    required this.moisturePct,
    required this.fatPct,
    required this.ph,
    required this.waterActivity,
    required this.moistureSensitivity,
    this.equilibriumRhTargetPct,
  });

  factory PhysicochemicalTraits.fromJson(Map<String, dynamic> json) {
    return PhysicochemicalTraits(
      moisturePct: (json['moisture_pct'] as num?)?.toDouble() ?? 0.0,
      fatPct: (json['fat_pct'] as num?)?.toDouble() ?? 0.0,
      ph: (json['ph'] as num?)?.toDouble() ?? 7.0,
      waterActivity: (json['water_activity'] as num?)?.toDouble() ?? 0.70,
      moistureSensitivity: json['moisture_sensitivity']?.toString() ?? 'Moderate',
      equilibriumRhTargetPct: (json['equilibrium_rh_target_pct'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'moisture_pct': moisturePct,
        'fat_pct': fatPct,
        'ph': ph,
        'water_activity': waterActivity,
        'moisture_sensitivity': moistureSensitivity,
        'equilibrium_rh_target_pct': equilibriumRhTargetPct,
      };
}

class PhysiologicalKinetics {
  final String respirationClass;
  final double? respirationRate5c;
  final double? respirationRate20c;
  final double respiratoryQuotient;
  final String ethyleneProductionClass;
  final double? ethyleneProdRate;
  final String ethyleneSensitivity;

  const PhysiologicalKinetics({
    required this.respirationClass,
    this.respirationRate5c,
    this.respirationRate20c,
    this.respiratoryQuotient = 1.0,
    this.ethyleneProductionClass = 'Low',
    this.ethyleneProdRate,
    this.ethyleneSensitivity = 'Low',
  });

  factory PhysiologicalKinetics.fromJson(Map<String, dynamic> json) {
    return PhysiologicalKinetics(
      respirationClass: json['respiration_class']?.toString() ?? 'Low',
      respirationRate5c: (json['respiration_rate_5c'] as num?)?.toDouble(),
      respirationRate20c: (json['respiration_rate_20c'] as num?)?.toDouble(),
      respiratoryQuotient: (json['respiratory_quotient'] as num?)?.toDouble() ?? 1.0,
      ethyleneProductionClass: json['ethylene_production_class']?.toString() ?? 'Low',
      ethyleneProdRate: (json['ethylene_prod_rate'] as num?)?.toDouble(),
      ethyleneSensitivity: json['ethylene_sensitivity']?.toString() ?? 'Low',
    );
  }

  Map<String, dynamic> toJson() => {
        'respiration_class': respirationClass,
        'respiration_rate_5c': respirationRate5c,
        'respiration_rate_20c': respirationRate20c,
        'respiratory_quotient': respiratoryQuotient,
        'ethylene_production_class': ethyleneProductionClass,
        'ethylene_prod_rate': ethyleneProdRate,
        'ethylene_sensitivity': ethyleneSensitivity,
      };
}

class AtmosphereSensitivities {
  final String oxygenSensitivity;
  final String co2Sensitivity;
  final double? maxTolerableCo2Pct;
  final String? targetEmapO2Pct;
  final String? targetEmapCo2Pct;

  const AtmosphereSensitivities({
    required this.oxygenSensitivity,
    required this.co2Sensitivity,
    this.maxTolerableCo2Pct,
    this.targetEmapO2Pct,
    this.targetEmapCo2Pct,
  });

  factory AtmosphereSensitivities.fromJson(Map<String, dynamic> json) {
    return AtmosphereSensitivities(
      oxygenSensitivity: json['oxygen_sensitivity']?.toString() ?? 'Moderate',
      co2Sensitivity: json['co2_sensitivity']?.toString() ?? 'Tolerant',
      maxTolerableCo2Pct: (json['max_tolerable_co2_pct'] as num?)?.toDouble(),
      targetEmapO2Pct: json['target_emap_o2_pct']?.toString(),
      targetEmapCo2Pct: json['target_emap_co2_pct']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'oxygen_sensitivity': oxygenSensitivity,
        'co2_sensitivity': co2Sensitivity,
        'max_tolerable_co2_pct': maxTolerableCo2Pct,
        'target_emap_o2_pct': targetEmapO2Pct,
        'target_emap_co2_pct': targetEmapCo2Pct,
      };
}

class ThermalAndStorage {
  final String perishability;
  final double optimumTempMinC;
  final double optimumTempMaxC;
  final double? chillingInjuryThresholdC;
  final double freezingPointC;
  final int ambientShelfLifeDays;
  final int? refrigeratedShelfLifeDays;
  final int? controlledAtmosphereShelfLifeDays;

  const ThermalAndStorage({
    required this.perishability,
    required this.optimumTempMinC,
    required this.optimumTempMaxC,
    this.chillingInjuryThresholdC,
    this.freezingPointC = -0.5,
    required this.ambientShelfLifeDays,
    this.refrigeratedShelfLifeDays,
    this.controlledAtmosphereShelfLifeDays,
  });

  bool get isChillingSensitive => chillingInjuryThresholdC != null;

  factory ThermalAndStorage.fromJson(Map<String, dynamic> json) {
    return ThermalAndStorage(
      perishability: json['perishability']?.toString() ?? 'Highly perishable',
      optimumTempMinC: (json['optimum_temp_min_c'] as num?)?.toDouble() ?? 10.0,
      optimumTempMaxC: (json['optimum_temp_max_c'] as num?)?.toDouble() ?? 15.0,
      chillingInjuryThresholdC: (json['chilling_injury_threshold_c'] as num?)?.toDouble(),
      freezingPointC: (json['freezing_point_c'] as num?)?.toDouble() ?? -0.5,
      ambientShelfLifeDays: json['ambient_shelf_life_days'] as int? ?? 7,
      refrigeratedShelfLifeDays: json['refrigerated_shelf_life_days'] as int?,
      controlledAtmosphereShelfLifeDays: json['controlled_atmosphere_shelf_life_days'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'perishability': perishability,
        'optimum_temp_min_c': optimumTempMinC,
        'optimum_temp_max_c': optimumTempMaxC,
        'chilling_injury_threshold_c': chillingInjuryThresholdC,
        'freezing_point_c': freezingPointC,
        'ambient_shelf_life_days': ambientShelfLifeDays,
        'refrigerated_shelf_life_days': refrigeratedShelfLifeDays,
        'controlled_atmosphere_shelf_life_days': controlledAtmosphereShelfLifeDays,
      };
}

class SpoilageAndVulnerabilities {
  final String lightSensitivity;
  final String aromaSensitivity;
  final String microbialSpoilageVector;
  final String mechanicalSensitivity;

  const SpoilageAndVulnerabilities({
    required this.lightSensitivity,
    required this.aromaSensitivity,
    required this.microbialSpoilageVector,
    required this.mechanicalSensitivity,
  });

  factory SpoilageAndVulnerabilities.fromJson(Map<String, dynamic> json) {
    return SpoilageAndVulnerabilities(
      lightSensitivity: json['light_sensitivity']?.toString() ?? 'Low',
      aromaSensitivity: json['aroma_sensitivity']?.toString() ?? 'Low',
      microbialSpoilageVector: json['microbial_spoilage_vector']?.toString() ?? 'Ambient molds & bacteria',
      mechanicalSensitivity: json['mechanical_sensitivity']?.toString() ?? 'Moderate',
    );
  }

  Map<String, dynamic> toJson() => {
        'light_sensitivity': lightSensitivity,
        'aroma_sensitivity': aromaSensitivity,
        'microbial_spoilage_vector': microbialSpoilageVector,
        'mechanical_sensitivity': mechanicalSensitivity,
      };
}

class PackagingPrescriptions {
  final String recommendedBarrierType;
  final String requiredOtrRange;
  final String requiredWvtrRange;
  final bool ethyleneActionRequired;
  final String? thermalWarning;
  final String? cushioningDirective;

  const PackagingPrescriptions({
    required this.recommendedBarrierType,
    required this.requiredOtrRange,
    required this.requiredWvtrRange,
    this.ethyleneActionRequired = false,
    this.thermalWarning,
    this.cushioningDirective,
  });

  factory PackagingPrescriptions.fromJson(Map<String, dynamic> json) {
    return PackagingPrescriptions(
      recommendedBarrierType: json['recommended_barrier_type']?.toString() ?? 'HDPE Recyclable Pouch',
      requiredOtrRange: json['required_otr_range']?.toString() ?? '< 50 cc/m²/day',
      requiredWvtrRange: json['required_wvtr_range']?.toString() ?? '< 5.0 g/m²/day',
      ethyleneActionRequired: json['ethylene_action_required'] as bool? ?? false,
      thermalWarning: json['thermal_warning']?.toString(),
      cushioningDirective: json['cushioning_directive']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'recommended_barrier_type': recommendedBarrierType,
        'required_otr_range': requiredOtrRange,
        'required_wvtr_range': requiredWvtrRange,
        'ethylene_action_required': ethyleneActionRequired,
        'thermal_warning': thermalWarning,
        'cushioning_directive': cushioningDirective,
      };
}

class FoodScientificProfile {
  final int? foodId;
  final String commodityName;
  final String? scientificName;
  final String category;
  final PhysicochemicalTraits physicochemical;
  final PhysiologicalKinetics physiologicalKinetics;
  final AtmosphereSensitivities atmosphereSensitivities;
  final ThermalAndStorage thermalAndStorage;
  final SpoilageAndVulnerabilities spoilageAndVulnerabilities;
  final PackagingPrescriptions packagingPrescriptions;
  final String source;
  final double confidenceScore;

  const FoodScientificProfile({
    this.foodId,
    required this.commodityName,
    this.scientificName,
    required this.category,
    required this.physicochemical,
    required this.physiologicalKinetics,
    required this.atmosphereSensitivities,
    required this.thermalAndStorage,
    required this.spoilageAndVulnerabilities,
    required this.packagingPrescriptions,
    this.source = 'ICMR-NIN IFCT 2017 & UC Davis Postharvest Facts',
    this.confidenceScore = 0.95,
  });

  factory FoodScientificProfile.fromJson(Map<String, dynamic> json) {
    return FoodScientificProfile(
      foodId: json['food_id'] as int?,
      commodityName: json['commodity_name']?.toString() ?? 'Unknown Food',
      scientificName: json['scientific_name']?.toString(),
      category: json['category']?.toString() ?? 'General',
      physicochemical: PhysicochemicalTraits.fromJson(
        Map<String, dynamic>.from(json['physicochemical'] ?? {}),
      ),
      physiologicalKinetics: PhysiologicalKinetics.fromJson(
        Map<String, dynamic>.from(json['physiological_kinetics'] ?? {}),
      ),
      atmosphereSensitivities: AtmosphereSensitivities.fromJson(
        Map<String, dynamic>.from(json['atmosphere_sensitivities'] ?? {}),
      ),
      thermalAndStorage: ThermalAndStorage.fromJson(
        Map<String, dynamic>.from(json['thermal_and_storage'] ?? {}),
      ),
      spoilageAndVulnerabilities: SpoilageAndVulnerabilities.fromJson(
        Map<String, dynamic>.from(json['spoilage_and_vulnerabilities'] ?? {}),
      ),
      packagingPrescriptions: PackagingPrescriptions.fromJson(
        Map<String, dynamic>.from(json['packaging_prescriptions'] ?? {}),
      ),
      source: json['source']?.toString() ?? 'ICMR-NIN IFCT 2017',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.95,
    );
  }

  Map<String, dynamic> toJson() => {
        'food_id': foodId,
        'commodity_name': commodityName,
        'scientific_name': scientificName,
        'category': category,
        'physicochemical': physicochemical.toJson(),
        'physiological_kinetics': physiologicalKinetics.toJson(),
        'atmosphere_sensitivities': atmosphereSensitivities.toJson(),
        'thermal_and_storage': thermalAndStorage.toJson(),
        'spoilage_and_vulnerabilities': spoilageAndVulnerabilities.toJson(),
        'packaging_prescriptions': packagingPrescriptions.toJson(),
        'source': source,
        'confidence_score': confidenceScore,
      };

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'fruits':
        return const Color(0xFFF97316);
      case 'vegetables':
        return const Color(0xFF059669);
      case 'grains':
        return const Color(0xFFD97706);
      case 'dairy':
        return const Color(0xFF0284C7);
      case 'meat':
        return const Color(0xFFE11D48);
      case 'bakery':
        return const Color(0xFF9333EA);
      case 'other perishables':
      default:
        return const Color(0xFF0F766E);
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Icons.apple_rounded;
      case 'vegetables':
        return Icons.eco_rounded;
      case 'grains':
        return Icons.grain_rounded;
      case 'dairy':
        return Icons.water_drop_rounded;
      case 'meat':
        return Icons.set_meal_rounded;
      case 'bakery':
        return Icons.cake_rounded;
      case 'other perishables':
      default:
        return Icons.fastfood_rounded;
    }
  }
}
