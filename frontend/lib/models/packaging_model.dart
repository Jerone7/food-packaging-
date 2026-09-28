/// Packaging Recommendation & Multi-Material Alternative Dart Models (Module 5).
/// Strongly-typed, immutable models representing the full hybrid AI/ML recommendation payload.
library;

class BarrierProfile {
  final String otr;
  final String wvtr;
  final double thicknessMicrons;
  final double tensileStrengthMpa;
  final double punctureResistanceN;

  const BarrierProfile({
    required this.otr,
    required this.wvtr,
    required this.thicknessMicrons,
    required this.tensileStrengthMpa,
    required this.punctureResistanceN,
  });

  factory BarrierProfile.fromJson(Map<String, dynamic> json) {
    return BarrierProfile(
      otr: json['otr']?.toString() ?? 'N/A',
      wvtr: json['wvtr']?.toString() ?? 'N/A',
      thicknessMicrons: (json['thickness_microns'] as num?)?.toDouble() ?? 25.0,
      tensileStrengthMpa: (json['tensile_strength_mpa'] as num?)?.toDouble() ?? 25.0,
      punctureResistanceN: (json['puncture_resistance_n'] as num?)?.toDouble() ?? 20.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'otr': otr,
        'wvtr': wvtr,
        'thickness_microns': thicknessMicrons,
        'tensile_strength_mpa': tensileStrengthMpa,
        'puncture_resistance_n': punctureResistanceN,
      };
}

class PrimaryRecommendation {
  final String materialName;
  final String materialType;
  final String polymerFamily;
  final String structure;
  final BarrierProfile barrierProfile;
  final double sustainabilityScore;
  final double estimatedUnitCostInr;
  final double suitabilityScore;
  final List<String> activeAdditives;

  // Explainable Recommendation Fields (Module 5 Result Page)
  final String packagingTitle;
  final String packagingFormat;
  final String recommendationExplanation;
  final List<String> advantages;
  final List<String> limitations;
  final String suitableStorageCondition;
  final String expectedApplication;
  final Map<String, String> importantProperties;

  const PrimaryRecommendation({
    required this.materialName,
    required this.materialType,
    required this.polymerFamily,
    required this.structure,
    required this.barrierProfile,
    required this.sustainabilityScore,
    required this.estimatedUnitCostInr,
    required this.suitabilityScore,
    required this.activeAdditives,
    this.packagingTitle = 'Ventilated Food-Grade Packaging',
    this.packagingFormat = 'Micro-Perforated Hinged Clamshell',
    this.recommendationExplanation =
        'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
    this.advantages = const [
      'Equilibrium modified atmosphere (EMAP) prevents anaerobic souring',
      'Anti-fog coating suppresses condensation water droplets and mold',
      'Optimized gas permselectivity maintains cell firmness and freshness',
    ],
    this.limitations = const [
      'Not suitable for vacuum packing or high-temperature retort processing',
      'Storage duration limited to 14–21 days under ambient conditions',
      'Permeable to strong external volatile aromas',
    ],
    this.suitableStorageCondition = 'Cold Storage: 10°C - 12°C (90-95% RH)',
    this.expectedApplication = 'High-respiration fresh produce, strawberries, cut fruits, cherry tomatoes',
    this.importantProperties = const {
      'OTR (Oxygen Barrier)': '< 1200 cc/m²/day',
      'WVTR (Moisture Barrier)': '25.0 g/m²/day',
      'Film Thickness': '30 µm',
      'Tensile Strength': '32.0 MPa',
      'Puncture Resistance': '22 N',
      'Thermal Span': '0°C to 45°C',
    },
  });

  factory PrimaryRecommendation.fromJson(Map<String, dynamic> json) {
    final barrier = json['barrier_profile'] != null
        ? BarrierProfile.fromJson(Map<String, dynamic>.from(json['barrier_profile']))
        : const BarrierProfile(
            otr: '< 1200 cc/m²/day',
            wvtr: '25.0 g/m²/day',
            thicknessMicrons: 30.0,
            tensileStrengthMpa: 32.0,
            punctureResistanceN: 22.0,
          );

    final advs = (json['advantages'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [
          'Equilibrium modified atmosphere (EMAP) prevents anaerobic souring',
          'Anti-fog coating suppresses condensation water droplets and mold',
        ];

    final lims = (json['limitations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [
          'Not suitable for vacuum packing or high-temperature retort processing',
          'Storage duration limited under ambient conditions',
        ];

    final props = json['important_properties'] != null
        ? Map<String, String>.from(json['important_properties'] as Map)
        : <String, String>{
            'OTR (Oxygen Barrier)': barrier.otr,
            'WVTR (Moisture Barrier)': barrier.wvtr,
            'Film Thickness': '${barrier.thicknessMicrons.toStringAsFixed(0)} µm',
            'Tensile Strength': '${barrier.tensileStrengthMpa.toStringAsFixed(1)} MPa',
            'Puncture Resistance': '${barrier.punctureResistanceN.toStringAsFixed(0)} N',
          };

    return PrimaryRecommendation(
      materialName: json['material_name'] ?? 'Optimized Barrier Film',
      materialType: json['material_type'] ?? 'Bio-Polymer',
      polymerFamily: json['polymer_family'] ?? 'BREATHABLE_BIO_EMAP',
      structure: json['structure'] ?? 'Monolayer / Laminate',
      barrierProfile: barrier,
      sustainabilityScore: (json['sustainability_score'] as num?)?.toDouble() ?? 85.0,
      estimatedUnitCostInr: (json['estimated_unit_cost_inr'] as num?)?.toDouble() ?? 3.50,
      suitabilityScore: (json['suitability_score'] as num?)?.toDouble() ?? 0.90,
      activeAdditives: (json['active_additives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      packagingTitle: json['packaging_title'] ?? 'Ventilated Food-Grade Packaging',
      packagingFormat: json['packaging_format'] ?? 'Micro-Perforated Hinged Clamshell',
      recommendationExplanation: json['recommendation_explanation'] ??
          'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
      advantages: advs,
      limitations: lims,
      suitableStorageCondition: json['suitable_storage_condition'] ?? 'Cold Storage: 10°C - 12°C (90-95% RH)',
      expectedApplication: json['expected_application'] ??
          'High-respiration fresh produce, strawberries, cut fruits, cherry tomatoes',
      importantProperties: props,
    );
  }

  Map<String, dynamic> toJson() => {
        'material_name': materialName,
        'material_type': materialType,
        'polymer_family': polymerFamily,
        'structure': structure,
        'barrier_profile': barrierProfile.toJson(),
        'sustainability_score': sustainabilityScore,
        'estimated_unit_cost_inr': estimatedUnitCostInr,
        'suitability_score': suitabilityScore,
        'active_additives': activeAdditives,
        'packaging_title': packagingTitle,
        'packaging_format': packagingFormat,
        'recommendation_explanation': recommendationExplanation,
        'advantages': advantages,
        'limitations': limitations,
        'suitable_storage_condition': suitableStorageCondition,
        'expected_application': expectedApplication,
        'important_properties': importantProperties,
      };
}

enum SuitabilityCategory {
  optimalMatch,
  highCompatibility,
  moderateCompatibility,
  conditionalAlternative;

  static SuitabilityCategory fromString(String? val) {
    if (val == null) return SuitabilityCategory.highCompatibility;
    final lower = val.toLowerCase();
    if (lower.contains('optimal')) return SuitabilityCategory.optimalMatch;
    if (lower.contains('high')) return SuitabilityCategory.highCompatibility;
    if (lower.contains('moderate')) return SuitabilityCategory.moderateCompatibility;
    if (lower.contains('conditional')) return SuitabilityCategory.conditionalAlternative;
    return SuitabilityCategory.highCompatibility;
  }

  String get displayName {
    switch (this) {
      case SuitabilityCategory.optimalMatch:
        return 'Optimal Match';
      case SuitabilityCategory.highCompatibility:
        return 'High Compatibility';
      case SuitabilityCategory.moderateCompatibility:
        return 'Moderate Compatibility';
      case SuitabilityCategory.conditionalAlternative:
        return 'Conditional Alternative';
    }
  }

  String get badgeLabel {
    switch (this) {
      case SuitabilityCategory.optimalMatch:
        return 'Optimal Match (Tier 1)';
      case SuitabilityCategory.highCompatibility:
        return 'High Compatibility (Tier 2)';
      case SuitabilityCategory.moderateCompatibility:
        return 'Moderate Compatibility (Tier 3)';
      case SuitabilityCategory.conditionalAlternative:
        return 'Conditional Alternative (Tier 4)';
    }
  }
}

class MaterialCharacteristics {
  final String otr;
  final String wvtr;
  final double thicknessMicrons;
  final double tensileStrengthMpa;
  final String thermalRange;
  final String sustainabilityRating;
  final double estimatedCostInr;
  final String costTier;

  const MaterialCharacteristics({
    this.otr = '< 1200 cc/m²/day',
    this.wvtr = '25.0 g/m²/day',
    this.thicknessMicrons = 25.0,
    this.tensileStrengthMpa = 30.0,
    this.thermalRange = '-10°C to 70°C',
    this.sustainabilityRating = '100% Home Compostable',
    this.estimatedCostInr = 3.50,
    this.costTier = 'Moderate (₹₹)',
  });

  factory MaterialCharacteristics.fromJson(Map<String, dynamic> json) {
    return MaterialCharacteristics(
      otr: json['otr']?.toString() ?? '< 1200 cc/m²/day',
      wvtr: json['wvtr']?.toString() ?? '25.0 g/m²/day',
      thicknessMicrons: (json['thickness_microns'] as num?)?.toDouble() ?? 25.0,
      tensileStrengthMpa: (json['tensile_strength_mpa'] as num?)?.toDouble() ?? 30.0,
      thermalRange: json['thermal_range']?.toString() ?? '-10°C to 70°C',
      sustainabilityRating: json['sustainability_rating']?.toString() ?? '100% Home Compostable',
      estimatedCostInr: (json['estimated_cost_inr'] as num?)?.toDouble() ?? 3.50,
      costTier: json['cost_tier']?.toString() ?? 'Moderate (₹₹)',
    );
  }

  Map<String, dynamic> toJson() => {
        'otr': otr,
        'wvtr': wvtr,
        'thickness_microns': thicknessMicrons,
        'tensile_strength_mpa': tensileStrengthMpa,
        'thermal_range': thermalRange,
        'sustainability_rating': sustainabilityRating,
        'estimated_cost_inr': estimatedCostInr,
        'cost_tier': costTier,
      };
}

enum AlternativeType {
  ecoFriendly,
  economy,
  highBarrier;

  static AlternativeType fromString(String val) {
    final lower = val.toLowerCase();
    if (lower.contains('econ')) return AlternativeType.economy;
    if (lower.contains('barrier') || lower.contains('hb')) return AlternativeType.highBarrier;
    if (lower.contains('eco') || lower.contains('bio')) return AlternativeType.ecoFriendly;
    return AlternativeType.ecoFriendly;
  }

  String get displayName {
    switch (this) {
      case AlternativeType.ecoFriendly:
        return 'Eco-Champion';
      case AlternativeType.economy:
        return 'Economy Option';
      case AlternativeType.highBarrier:
        return 'High-Barrier Preservation';
    }
  }

  String get iconEmoji {
    switch (this) {
      case AlternativeType.ecoFriendly:
        return '🌿';
      case AlternativeType.economy:
        return '💰';
      case AlternativeType.highBarrier:
        return '🛡️';
    }
  }
}

class PackagingAlternative {
  final String candidateId;
  final AlternativeType type;
  final String typeRaw;
  final String materialName;
  final String packagingTitle;
  
  final int starRating;
  final String starDisplay;
  final SuitabilityCategory suitabilityCategory;
  
  final double modelDerivedProbability;
  final String compatibilityConfidence;
  
  final MaterialCharacteristics characteristics;
  final String tradeOffSummary;
  final List<String> advantages;
  final List<String> limitations;
  
  final double costDeltaPct;
  final double ecoDeltaPct;
  final String shelfLifeDelta;

  // Backward compatibility fields
  final double sustainabilityScore;
  final double estimatedUnitCostInr;

  const PackagingAlternative({
    this.candidateId = 'mat_alt_candidate',
    required this.type,
    required this.typeRaw,
    required this.materialName,
    this.packagingTitle = 'Alternative Packaging Format',
    this.starRating = 4,
    this.starDisplay = '★★★★☆',
    this.suitabilityCategory = SuitabilityCategory.highCompatibility,
    this.modelDerivedProbability = 0.85,
    this.compatibilityConfidence = 'High Confidence (0.85)',
    this.characteristics = const MaterialCharacteristics(),
    required this.tradeOffSummary,
    this.advantages = const [],
    this.limitations = const [],
    this.costDeltaPct = 0.0,
    this.ecoDeltaPct = 0.0,
    this.shelfLifeDelta = 'Equal',
    this.sustainabilityScore = 75.0,
    this.estimatedUnitCostInr = 3.50,
  });

  factory PackagingAlternative.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString() ?? 'ECO_FRIENDLY';
    final parsedType = AlternativeType.fromString(rawType);
    final rating = (json['star_rating'] as num?)?.toInt() ?? 4;
    final starDisp = json['star_display']?.toString() ?? (rating == 5 ? '★★★★★' : rating == 4 ? '★★★★☆' : '★★★☆☆');
    final suitCat = SuitabilityCategory.fromString(json['suitability_category']?.toString());
    final prob = (json['model_derived_probability'] as num?)?.toDouble() ?? 0.85;
    final conf = json['compatibility_confidence']?.toString() ?? 'High Confidence (${prob.toStringAsFixed(2)})';
    
    final chars = json['characteristics'] != null
        ? MaterialCharacteristics.fromJson(Map<String, dynamic>.from(json['characteristics']))
        : MaterialCharacteristics(
            sustainabilityRating: (json['sustainability_score'] != null)
                ? '${json['sustainability_score']}/100 Eco Score'
                : 'Eco-Friendly Substrate',
            estimatedCostInr: (json['estimated_unit_cost_inr'] as num?)?.toDouble() ?? 3.50,
          );

    final advs = (json['advantages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];
    final lims = (json['limitations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [];
    
    final costDelta = (json['cost_delta_pct'] as num?)?.toDouble() ?? 0.0;
    final ecoDelta = (json['eco_delta_pct'] as num?)?.toDouble() ?? 0.0;
    final shelfDelta = json['shelf_life_delta']?.toString() ?? 'Equal';

    final sustScore = (json['sustainability_score'] as num?)?.toDouble() ?? 75.0;
    final costInr = (json['estimated_unit_cost_inr'] as num?)?.toDouble() ?? chars.estimatedCostInr;

    return PackagingAlternative(
      candidateId: json['candidate_id']?.toString() ?? 'alt_${rawType.toLowerCase()}',
      type: parsedType,
      typeRaw: rawType,
      materialName: json['material_name'] ?? 'Alternative Material',
      packagingTitle: json['packaging_title'] ?? parsedType.displayName,
      starRating: rating,
      starDisplay: starDisp,
      suitabilityCategory: suitCat,
      modelDerivedProbability: prob,
      compatibilityConfidence: conf,
      characteristics: chars,
      tradeOffSummary: json['trade_off_summary'] ?? 'Alternative formulation trade-off.',
      advantages: advs,
      limitations: lims,
      costDeltaPct: costDelta,
      ecoDeltaPct: ecoDelta,
      shelfLifeDelta: shelfDelta,
      sustainabilityScore: sustScore,
      estimatedUnitCostInr: costInr,
    );
  }

  Map<String, dynamic> toJson() => {
        'candidate_id': candidateId,
        'type': typeRaw,
        'material_name': materialName,
        'packaging_title': packagingTitle,
        'star_rating': starRating,
        'star_display': starDisplay,
        'suitability_category': suitabilityCategory.displayName,
        'model_derived_probability': modelDerivedProbability,
        'compatibility_confidence': compatibilityConfidence,
        'characteristics': characteristics.toJson(),
        'trade_off_summary': tradeOffSummary,
        'advantages': advantages,
        'limitations': limitations,
        'cost_delta_pct': costDeltaPct,
        'eco_delta_pct': ecoDeltaPct,
        'shelf_life_delta': shelfLifeDelta,
        'sustainability_score': sustainabilityScore,
        'estimated_unit_cost_inr': estimatedUnitCostInr,
      };
}

class BoxGeometrySpecs {
  final double lengthCm;
  final double widthCm;
  final double heightCm;
  final double totalVolumeCm3;
  final double spaceUtilizationPct;
  final String cushioningMaterial;

  const BoxGeometrySpecs({
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    required this.totalVolumeCm3,
    required this.spaceUtilizationPct,
    required this.cushioningMaterial,
  });

  factory BoxGeometrySpecs.fromJson(Map<String, dynamic> json) {
    return BoxGeometrySpecs(
      lengthCm: (json['length_cm'] as num?)?.toDouble() ?? 25.0,
      widthCm: (json['width_cm'] as num?)?.toDouble() ?? 15.0,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 12.0,
      totalVolumeCm3: (json['total_volume_cm3'] as num?)?.toDouble() ?? 4500.0,
      spaceUtilizationPct: (json['space_utilization_pct'] as num?)?.toDouble() ?? 75.0,
      cushioningMaterial: json['cushioning_material'] ?? 'Recycled Shredded Kraft Paper',
    );
  }

  Map<String, dynamic> toJson() => {
        'length_cm': lengthCm,
        'width_cm': widthCm,
        'height_cm': heightCm,
        'total_volume_cm3': totalVolumeCm3,
        'space_utilization_pct': spaceUtilizationPct,
        'cushioning_material': cushioningMaterial,
      };
}

class ExplainableAiRationale {
  final String summary;
  final List<String> keyDrivers;

  const ExplainableAiRationale({
    required this.summary,
    required this.keyDrivers,
  });

  factory ExplainableAiRationale.fromJson(Map<String, dynamic> json) {
    return ExplainableAiRationale(
      summary: json['summary'] ?? 'Optimized packaging recommendation.',
      keyDrivers: (json['key_drivers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'key_drivers': keyDrivers,
      };
}

class PackagingInput {
  final String itemName;
  final double length;
  final double width;
  final double height;
  final double weight;
  final bool isFragile;
  final bool ecoFriendly;
  final String? category;
  final double? moisture;
  final double? fat;
  final double? ph;
  final double? waterActivity;
  final String? respirationClass;
  final double? respirationRate20c;
  final String? ethyleneSensitivity;
  final double? chillingInjuryThresholdC;
  final String? storageCondition;
  final double? storageTempC;
  final int? storageDurationDays;
  final String? transportMode;

  PackagingInput({
    required this.itemName,
    this.length = 20.0,
    this.width = 15.0,
    this.height = 10.0,
    required this.weight,
    required this.isFragile,
    required this.ecoFriendly,
    this.category,
    this.moisture,
    this.fat,
    this.ph,
    this.waterActivity,
    this.respirationClass,
    this.respirationRate20c,
    this.ethyleneSensitivity,
    this.chillingInjuryThresholdC,
    this.storageCondition,
    this.storageTempC,
    this.storageDurationDays,
    this.transportMode,
  });

  Map<String, dynamic> toJson() => {
        'item_name': itemName,
        'food_name': itemName,
        'length': length,
        'width': width,
        'height': height,
        'weight': weight,
        'quantity': weight,
        'is_fragile': isFragile,
        'eco_friendly': ecoFriendly,
        'eco_friendly_priority': ecoFriendly,
        if (category != null) 'category': category,
        if (moisture != null) 'moisture': moisture,
        if (fat != null) 'fat': fat,
        if (ph != null) 'ph': ph,
        if (waterActivity != null) 'water_activity': waterActivity,
        if (respirationClass != null) 'respiration_class': respirationClass,
        if (respirationRate20c != null) 'respiration_rate_20c': respirationRate20c,
        if (ethyleneSensitivity != null) 'ethylene_sensitivity': ethyleneSensitivity,
        if (chillingInjuryThresholdC != null) 'chilling_injury_threshold_c': chillingInjuryThresholdC,
        if (storageCondition != null) 'storage_condition': storageCondition,
        if (storageTempC != null) 'storage_temp_c': storageTempC,
        if (storageDurationDays != null) 'storage_duration_days': storageDurationDays,
        if (transportMode != null) 'transport_mode': transportMode,
      };
}

class PackagingRecommendationResult {
  final String recommendationId;
  final PrimaryRecommendation primaryRecommendation;
  final List<PackagingAlternative> alternatives;
  final BoxGeometrySpecs boxGeometry;
  final ExplainableAiRationale scientificRationale;
  final Map<String, dynamic>? comparisonSummary;

  // Legacy compatibility fields
  final String recommendedBoxType;
  final String recommendedDimensions;
  final double boxVolumeCm3;
  final double itemVolumeCm3;
  final double spaceUtilizationPct;
  final String cushioningMaterial;
  final double estimatedCost;
  final double sustainabilityScore;
  final String? notes;

  PackagingRecommendationResult({
    String? recommendationId,
    PrimaryRecommendation? primaryRecommendation,
    List<PackagingAlternative>? alternatives,
    BoxGeometrySpecs? boxGeometry,
    ExplainableAiRationale? scientificRationale,
    this.comparisonSummary,
    required this.recommendedBoxType,
    required this.recommendedDimensions,
    required this.boxVolumeCm3,
    required this.itemVolumeCm3,
    required this.spaceUtilizationPct,
    required this.cushioningMaterial,
    required this.estimatedCost,
    required this.sustainabilityScore,
    this.notes,
  })  : recommendationId = recommendationId ?? 'rec_legacy',
        primaryRecommendation = primaryRecommendation ??
            PrimaryRecommendation(
              materialName: recommendedBoxType,
              materialType: 'Optimized Polymer',
              polymerFamily: 'RECYCLABLE_POLYOLEFIN',
              structure: 'Standard Structure',
              barrierProfile: const BarrierProfile(
                otr: '< 10 cc/m²/day',
                wvtr: '< 3.0 g/m²/day',
                thicknessMicrons: 25.0,
                tensileStrengthMpa: 30.0,
                punctureResistanceN: 20.0,
              ),
              sustainabilityScore: sustainabilityScore,
              estimatedUnitCostInr: estimatedCost,
              suitabilityScore: 0.90,
              activeAdditives: const [],
            ),
        alternatives = alternatives ?? const [],
        boxGeometry = boxGeometry ??
            BoxGeometrySpecs(
              lengthCm: 25.0,
              widthCm: 15.0,
              heightCm: 12.0,
              totalVolumeCm3: boxVolumeCm3,
              spaceUtilizationPct: spaceUtilizationPct,
              cushioningMaterial: cushioningMaterial,
            ),
        scientificRationale = scientificRationale ??
            ExplainableAiRationale(
              summary: notes ?? 'Optimized packaging recommendation.',
              keyDrivers: const [],
            );

  factory PackagingRecommendationResult.fromJson(Map<String, dynamic> json) {
    PrimaryRecommendation? primary;
    if (json['primary_recommendation'] != null) {
      primary = PrimaryRecommendation.fromJson(Map<String, dynamic>.from(json['primary_recommendation']));
    }

    List<PackagingAlternative> alts = [];
    if (json['alternatives'] is List) {
      alts = (json['alternatives'] as List)
          .map((e) => PackagingAlternative.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    BoxGeometrySpecs? geom;
    if (json['box_geometry'] != null) {
      geom = BoxGeometrySpecs.fromJson(Map<String, dynamic>.from(json['box_geometry']));
    }

    ExplainableAiRationale? xai;
    if (json['scientific_rationale'] != null) {
      xai = ExplainableAiRationale.fromJson(Map<String, dynamic>.from(json['scientific_rationale']));
    }

    final boxType = json['recommended_box_type'] ?? (primary?.materialName ?? 'Optimized Packaging');
    final dims = json['recommended_dimensions'] ??
        (geom != null ? '${geom.lengthCm} x ${geom.widthCm} x ${geom.heightCm} cm' : '25.0 x 15.0 x 12.0 cm');
    final boxVol = (json['box_volume_cm3'] as num?)?.toDouble() ?? (geom?.totalVolumeCm3 ?? 4500.0);
    final itemVol = (json['item_volume_cm3'] as num?)?.toDouble() ?? (boxVol * 0.75);
    final util = (json['space_utilization_pct'] as num?)?.toDouble() ?? (geom?.spaceUtilizationPct ?? 75.0);
    final cushion = json['cushioning_material'] ?? (geom?.cushioningMaterial ?? 'Recycled Kraft Paper');
    final cost = (json['estimated_cost'] as num?)?.toDouble() ?? (primary?.estimatedUnitCostInr ?? 3.50);
    final eco = (json['sustainability_score'] as num?)?.toDouble() ?? (primary?.sustainabilityScore ?? 85.0);
    final comparison = json['comparison_summary'] != null
        ? Map<String, dynamic>.from(json['comparison_summary'] as Map)
        : null;

    return PackagingRecommendationResult(
      recommendationId: json['recommendation_id']?.toString(),
      primaryRecommendation: primary,
      alternatives: alts,
      boxGeometry: geom,
      scientificRationale: xai,
      comparisonSummary: comparison,
      recommendedBoxType: boxType,
      recommendedDimensions: dims,
      boxVolumeCm3: boxVol,
      itemVolumeCm3: itemVol,
      spaceUtilizationPct: util,
      cushioningMaterial: cushion,
      estimatedCost: cost,
      sustainabilityScore: eco,
      notes: json['notes'] ?? xai?.summary,
    );
  }
}

class PackagingRecord extends PackagingRecommendationResult {
  final int id;
  final int? userId;
  final String itemName;
  final double length;
  final double width;
  final double height;
  final double weight;
  final bool isFragile;
  final bool ecoFriendly;
  final DateTime createdAt;
  final String? formattedDate;

  PackagingRecord({
    required this.id,
    this.userId,
    required this.itemName,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    required this.isFragile,
    required this.ecoFriendly,
    required this.createdAt,
    this.formattedDate,
    required super.recommendedBoxType,
    required super.recommendedDimensions,
    required super.boxVolumeCm3,
    required super.itemVolumeCm3,
    required super.spaceUtilizationPct,
    required super.cushioningMaterial,
    required super.estimatedCost,
    required super.sustainabilityScore,
    super.notes,
    super.primaryRecommendation,
    super.alternatives,
    super.comparisonSummary,
    super.boxGeometry,
    super.scientificRationale,
  });

  /// Formatted date string matching "26 Sep 2026"
  String get formattedDisplayDate {
    if (formattedDate != null && formattedDate!.trim().isNotEmpty) {
      return formattedDate!.trim();
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = months[createdAt.month - 1];
    final year = createdAt.year.toString();
    return '$day $month $year';
  }

  /// Converts record back to PackagingInput for 1-click cockpit reload
  PackagingInput toPackagingInput() {
    return PackagingInput(
      itemName: itemName,
      length: length,
      width: width,
      height: height,
      weight: weight,
      isFragile: isFragile,
      ecoFriendly: ecoFriendly,
    );
  }

  /// Converts record to PackagingRecommendationResult for report viewing
  PackagingRecommendationResult toRecommendationResult() {
    return this;
  }

  factory PackagingRecord.fromJson(Map<String, dynamic> json) {
    return PackagingRecord(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt(),
      itemName: json['item_name']?.toString() ?? '',
      length: (json['length'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      isFragile: json['is_fragile'] as bool? ?? false,
      ecoFriendly: json['eco_friendly'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      formattedDate: json['formatted_date']?.toString(),
      recommendedBoxType: json['recommended_box_type']?.toString() ?? '',
      recommendedDimensions: json['recommended_dimensions']?.toString() ?? '',
      boxVolumeCm3: (json['box_volume_cm3'] as num?)?.toDouble() ?? 0.0,
      itemVolumeCm3: (json['item_volume_cm3'] as num?)?.toDouble() ?? 0.0,
      spaceUtilizationPct: (json['space_util_pct'] as num?)?.toDouble() ??
          (json['space_utilization_pct'] as num?)?.toDouble() ??
          0.0,
      cushioningMaterial: json['cushioning_material']?.toString() ?? '',
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0.0,
      sustainabilityScore: (json['sustainability_score'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'item_name': itemName,
        'length': length,
        'width': width,
        'height': height,
        'weight': weight,
        'is_fragile': isFragile,
        'eco_friendly': ecoFriendly,
        'created_at': createdAt.toIso8601String(),
        'formatted_date': formattedDisplayDate,
        'recommended_box_type': recommendedBoxType,
        'recommended_dimensions': recommendedDimensions,
        'box_volume_cm3': boxVolumeCm3,
        'item_volume_cm3': itemVolumeCm3,
        'space_utilization_pct': spaceUtilizationPct,
        'cushioning_material': cushioningMaterial,
        'estimated_cost': estimatedCost,
        'sustainability_score': sustainabilityScore,
        'notes': notes,
      };
}
