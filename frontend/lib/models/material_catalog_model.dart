/// Packaging Material Database & 12-Property Specifications Dart Models (Module 6).
/// Provides strongly-typed immutable models for catalog exploration, multi-axis radar charts,
/// side-by-side comparison, and custom material management.
library;

class MaterialRadarScores {
  final double barrierScore;
  final double mechanicalScore;
  final double sustainabilityScore;
  final double thermalScore;
  final double costEfficiencyScore;
  final double opticalScore;

  const MaterialRadarScores({
    required this.barrierScore,
    required this.mechanicalScore,
    required this.sustainabilityScore,
    required this.thermalScore,
    required this.costEfficiencyScore,
    required this.opticalScore,
  });

  factory MaterialRadarScores.fromJson(Map<String, dynamic> json) {
    return MaterialRadarScores(
      barrierScore: (json['barrier_score'] as num?)?.toDouble() ?? 50.0,
      mechanicalScore: (json['mechanical_score'] as num?)?.toDouble() ?? 50.0,
      sustainabilityScore: (json['sustainability_score'] as num?)?.toDouble() ?? 50.0,
      thermalScore: (json['thermal_score'] as num?)?.toDouble() ?? 50.0,
      costEfficiencyScore: (json['cost_efficiency_score'] as num?)?.toDouble() ?? 50.0,
      opticalScore: (json['optical_score'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'barrier_score': barrierScore,
        'mechanical_score': mechanicalScore,
        'sustainability_score': sustainabilityScore,
        'thermal_score': thermalScore,
        'cost_efficiency_score': costEfficiencyScore,
        'optical_score': opticalScore,
      };
}

class BarrierProfileDetail {
  final double otrCcM2Day;
  final double wvtrGM2Day;
  final double? co2Permeability;
  final double? selectivityBeta;
  final double thicknessMicrons;
  final String barrierTier;
  final bool gasFlushCompatible;

  const BarrierProfileDetail({
    required this.otrCcM2Day,
    required this.wvtrGM2Day,
    this.co2Permeability,
    this.selectivityBeta,
    required this.thicknessMicrons,
    required this.barrierTier,
    this.gasFlushCompatible = true,
  });

  factory BarrierProfileDetail.fromJson(Map<String, dynamic> json) {
    return BarrierProfileDetail(
      otrCcM2Day: (json['otr_cc_m2_day'] as num?)?.toDouble() ?? 50.0,
      wvtrGM2Day: (json['wvtr_g_m2_day'] as num?)?.toDouble() ?? 5.0,
      co2Permeability: (json['co2_permeability'] as num?)?.toDouble(),
      selectivityBeta: (json['selectivity_beta'] as num?)?.toDouble(),
      thicknessMicrons: (json['thickness_microns'] as num?)?.toDouble() ?? 25.0,
      barrierTier: json['barrier_tier']?.toString() ?? 'Moderate Barrier',
      gasFlushCompatible: json['gas_flush_compatible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'otr_cc_m2_day': otrCcM2Day,
        'wvtr_g_m2_day': wvtrGM2Day,
        'co2_permeability': co2Permeability,
        'selectivity_beta': selectivityBeta,
        'thickness_microns': thicknessMicrons,
        'barrier_tier': barrierTier,
        'gas_flush_compatible': gasFlushCompatible,
      };
}

class MechanicalProfile {
  final double tensileStrengthMpa;
  final double punctureResistanceN;
  final double elongationPct;
  final String formFactor;
  final String durabilityRating;

  const MechanicalProfile({
    required this.tensileStrengthMpa,
    required this.punctureResistanceN,
    this.elongationPct = 100.0,
    required this.formFactor,
    this.durabilityRating = 'Moderate',
  });

  factory MechanicalProfile.fromJson(Map<String, dynamic> json) {
    return MechanicalProfile(
      tensileStrengthMpa: (json['tensile_strength_mpa'] as num?)?.toDouble() ?? 30.0,
      punctureResistanceN: (json['puncture_resistance_n'] as num?)?.toDouble() ?? 25.0,
      elongationPct: (json['elongation_pct'] as num?)?.toDouble() ?? 100.0,
      formFactor: json['form_factor']?.toString() ?? 'Flexible Pouch',
      durabilityRating: json['durability_rating']?.toString() ?? 'Moderate',
    );
  }

  Map<String, dynamic> toJson() => {
        'tensile_strength_mpa': tensileStrengthMpa,
        'puncture_resistance_n': punctureResistanceN,
        'elongation_pct': elongationPct,
        'form_factor': formFactor,
        'durability_rating': durabilityRating,
      };
}

class ThermalProfile {
  final double tempMinC;
  final double tempMaxC;
  final String thermalClass;
  final bool isCryogenicGrade;
  final bool isRetortGrade;

  const ThermalProfile({
    required this.tempMinC,
    required this.tempMaxC,
    required this.thermalClass,
    this.isCryogenicGrade = false,
    this.isRetortGrade = false,
  });

  factory ThermalProfile.fromJson(Map<String, dynamic> json) {
    return ThermalProfile(
      tempMinC: (json['temp_min_c'] as num?)?.toDouble() ?? -10.0,
      tempMaxC: (json['temp_max_c'] as num?)?.toDouble() ?? 70.0,
      thermalClass: json['thermal_class']?.toString() ?? 'Ambient',
      isCryogenicGrade: json['is_cryogenic_grade'] as bool? ?? false,
      isRetortGrade: json['is_retort_grade'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'temp_min_c': tempMinC,
        'temp_max_c': tempMaxC,
        'thermal_class': thermalClass,
        'is_cryogenic_grade': isCryogenicGrade,
        'is_retort_grade': isRetortGrade,
      };
}

class OpticalProfile {
  final double uvTransmittancePct;
  final String opticalClarity;
  final String lightBarrierRating;

  const OpticalProfile({
    this.uvTransmittancePct = 20.0,
    required this.opticalClarity,
    this.lightBarrierRating = 'Moderate',
  });

  factory OpticalProfile.fromJson(Map<String, dynamic> json) {
    return OpticalProfile(
      uvTransmittancePct: (json['uv_transmittance_pct'] as num?)?.toDouble() ?? 20.0,
      opticalClarity: json['optical_clarity']?.toString() ?? 'Translucent',
      lightBarrierRating: json['light_barrier_rating']?.toString() ?? 'Moderate',
    );
  }

  Map<String, dynamic> toJson() => {
        'uv_transmittance_pct': uvTransmittancePct,
        'optical_clarity': opticalClarity,
        'light_barrier_rating': lightBarrierRating,
      };
}

class EnvironmentalProfile {
  final double sustainabilityScore;
  final double recyclabilityScore;
  final double biodegradabilityScore;
  final bool isBiodegradable;
  final bool isRecyclable;
  final String resinCode;
  final String? compostingStandard;

  const EnvironmentalProfile({
    required this.sustainabilityScore,
    this.recyclabilityScore = 0.0,
    this.biodegradabilityScore = 0.0,
    this.isBiodegradable = false,
    this.isRecyclable = false,
    this.resinCode = 'OTHER_7',
    this.compostingStandard,
  });

  factory EnvironmentalProfile.fromJson(Map<String, dynamic> json) {
    return EnvironmentalProfile(
      sustainabilityScore: (json['sustainability_score'] as num?)?.toDouble() ?? 50.0,
      recyclabilityScore: (json['recyclability_score'] as num?)?.toDouble() ?? 0.0,
      biodegradabilityScore: (json['biodegradability_score'] as num?)?.toDouble() ?? 0.0,
      isBiodegradable: json['is_biodegradable'] as bool? ?? false,
      isRecyclable: json['is_recyclable'] as bool? ?? false,
      resinCode: json['resin_code']?.toString() ?? 'OTHER_7',
      compostingStandard: json['composting_standard']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sustainability_score': sustainabilityScore,
        'recyclability_score': recyclabilityScore,
        'biodegradability_score': biodegradabilityScore,
        'is_biodegradable': isBiodegradable,
        'is_recyclable': isRecyclable,
        'resin_code': resinCode,
        'composting_standard': compostingStandard,
      };
}

class EconomicProfile {
  final String costCategory;
  final double estimatedUnitCostInr;
  final String marketScalability;

  const EconomicProfile({
    required this.costCategory,
    required this.estimatedUnitCostInr,
    this.marketScalability = 'High',
  });

  factory EconomicProfile.fromJson(Map<String, dynamic> json) {
    return EconomicProfile(
      costCategory: json['cost_category']?.toString() ?? 'Commercial Standard',
      estimatedUnitCostInr: (json['estimated_unit_cost_inr'] as num?)?.toDouble() ?? 2.50,
      marketScalability: json['market_scalability']?.toString() ?? 'High',
    );
  }

  Map<String, dynamic> toJson() => {
        'cost_category': costCategory,
        'estimated_unit_cost_inr': estimatedUnitCostInr,
        'market_scalability': marketScalability,
      };
}

class PackagingMaterialDetail {
  final int? id;
  final String materialId;
  final String name;
  final String category;
  final String polymerFamily;
  final String structure;
  final String formFactor;
  final BarrierProfileDetail barrierProfile;
  final MechanicalProfile mechanicalProfile;
  final ThermalProfile thermalProfile;
  final OpticalProfile opticalProfile;
  final EnvironmentalProfile environmentalProfile;
  final EconomicProfile economicProfile;
  final Map<String, bool> functionalFlags;
  final List<String> recommendedApplications;
  final List<String> regulatoryCertifications;
  final MaterialRadarScores radarScores;
  final String notes;
  final bool isActiveEntry;

  const PackagingMaterialDetail({
    this.id,
    required this.materialId,
    required this.name,
    required this.category,
    required this.polymerFamily,
    required this.structure,
    this.formFactor = 'Flexible Pouch',
    required this.barrierProfile,
    required this.mechanicalProfile,
    required this.thermalProfile,
    required this.opticalProfile,
    required this.environmentalProfile,
    required this.economicProfile,
    this.functionalFlags = const {},
    this.recommendedApplications = const [],
    this.regulatoryCertifications = const [],
    required this.radarScores,
    this.notes = '',
    this.isActiveEntry = true,
  });

  factory PackagingMaterialDetail.fromJson(Map<String, dynamic> json) {
    return PackagingMaterialDetail(
      id: json['id'] as int?,
      materialId: json['material_id']?.toString() ?? 'unknown_mat',
      name: json['name']?.toString() ?? 'Unnamed Packaging Material',
      category: json['category']?.toString() ?? 'Conventional Polymer',
      polymerFamily: json['polymer_family']?.toString() ?? 'POLYMER',
      structure: json['structure']?.toString() ?? 'Standard Gauge Film',
      formFactor: json['form_factor']?.toString() ?? 'Flexible Pouch',
      barrierProfile: BarrierProfileDetail.fromJson(
        json['barrier_profile'] as Map<String, dynamic>? ?? {},
      ),
      mechanicalProfile: MechanicalProfile.fromJson(
        json['mechanical_profile'] as Map<String, dynamic>? ?? {},
      ),
      thermalProfile: ThermalProfile.fromJson(
        json['thermal_profile'] as Map<String, dynamic>? ?? {},
      ),
      opticalProfile: OpticalProfile.fromJson(
        json['optical_profile'] as Map<String, dynamic>? ?? {},
      ),
      environmentalProfile: EnvironmentalProfile.fromJson(
        json['environmental_profile'] as Map<String, dynamic>? ?? {},
      ),
      economicProfile: EconomicProfile.fromJson(
        json['economic_profile'] as Map<String, dynamic>? ?? {},
      ),
      functionalFlags: (json['functional_flags'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as bool? ?? false),
          ) ??
          {},
      recommendedApplications: (json['recommended_applications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      regulatoryCertifications: (json['regulatory_certifications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      radarScores: MaterialRadarScores.fromJson(
        json['radar_scores'] as Map<String, dynamic>? ?? {},
      ),
      notes: json['notes']?.toString() ?? '',
      isActiveEntry: json['is_active_entry'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'material_id': materialId,
        'name': name,
        'category': category,
        'polymer_family': polymerFamily,
        'structure': structure,
        'form_factor': formFactor,
        'barrier_profile': barrierProfile.toJson(),
        'mechanical_profile': mechanicalProfile.toJson(),
        'thermal_profile': thermalProfile.toJson(),
        'optical_profile': opticalProfile.toJson(),
        'environmental_profile': environmentalProfile.toJson(),
        'economic_profile': economicProfile.toJson(),
        'functional_flags': functionalFlags,
        'recommended_applications': recommendedApplications,
        'regulatory_certifications': regulatoryCertifications,
        'radar_scores': radarScores.toJson(),
        'notes': notes,
        'is_active_entry': isActiveEntry,
      };
}

class MaterialComparisonResult {
  final List<PackagingMaterialDetail> materials;
  final Map<String, MaterialRadarScores> radarDatasets;
  final List<String> tradeOffAnalysis;
  final Map<String, String> bestInClassHighlights;

  const MaterialComparisonResult({
    required this.materials,
    required this.radarDatasets,
    required this.tradeOffAnalysis,
    required this.bestInClassHighlights,
  });

  factory MaterialComparisonResult.fromJson(Map<String, dynamic> json) {
    final matList = (json['materials'] as List<dynamic>?)
            ?.map((e) => PackagingMaterialDetail.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final radarMap = <String, MaterialRadarScores>{};
    if (json['radar_datasets'] != null) {
      (json['radar_datasets'] as Map<String, dynamic>).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          radarMap[k] = MaterialRadarScores.fromJson(v);
        }
      });
    }

    final highlightsMap = <String, String>{};
    if (json['best_in_class_highlights'] != null) {
      (json['best_in_class_highlights'] as Map<String, dynamic>).forEach((k, v) {
        highlightsMap[k] = v.toString();
      });
    }

    return MaterialComparisonResult(
      materials: matList,
      radarDatasets: radarMap,
      tradeOffAnalysis: (json['trade_off_analysis'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bestInClassHighlights: highlightsMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'materials': materials.map((m) => m.toJson()).toList(),
        'radar_datasets': radarDatasets.map((k, v) => MapEntry(k, v.toJson())),
        'trade_off_analysis': tradeOffAnalysis,
        'best_in_class_highlights': bestInClassHighlights,
      };
}

class MaterialCategorySummary {
  final String category;
  final int count;
  final List<String> sampleMaterials;
  final double averageSustainability;
  final String description;

  const MaterialCategorySummary({
    required this.category,
    required this.count,
    required this.sampleMaterials,
    required this.averageSustainability,
    required this.description,
  });

  factory MaterialCategorySummary.fromJson(Map<String, dynamic> json) {
    return MaterialCategorySummary(
      category: json['category']?.toString() ?? 'Other',
      count: (json['count'] as num?)?.toInt() ?? 0,
      sampleMaterials: (json['sample_materials'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      averageSustainability: (json['average_sustainability'] as num?)?.toDouble() ?? 50.0,
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'count': count,
        'sample_materials': sampleMaterials,
        'average_sustainability': averageSustainability,
        'description': description,
      };
}
