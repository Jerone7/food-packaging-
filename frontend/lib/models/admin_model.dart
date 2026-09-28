import 'package:flutter/foundation.dart';

// ==========================================
// 1. Analytics & Trends Models
// ==========================================

@immutable
class FoodSearchStatModel {
  final String name;
  final String category;
  final int queryCount;
  final double sharePct;

  const FoodSearchStatModel({
    required this.name,
    required this.category,
    required this.queryCount,
    required this.sharePct,
  });

  factory FoodSearchStatModel.fromJson(Map<String, dynamic> json) {
    return FoodSearchStatModel(
      name: json['name'] as String? ?? 'Food Commodity',
      category: json['category'] as String? ?? 'Produce',
      queryCount: json['query_count'] as int? ?? json['queryCount'] as int? ?? 0,
      sharePct: (json['share_pct'] as num? ?? json['sharePct'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'query_count': queryCount,
        'share_pct': sharePct,
      };
}

@immutable
class MaterialRecommendStatModel {
  final String materialName;
  final String polymerFamily;
  final int recommendCount;
  final double sharePct;
  final double averageScore;

  const MaterialRecommendStatModel({
    required this.materialName,
    required this.polymerFamily,
    required this.recommendCount,
    required this.sharePct,
    required this.averageScore,
  });

  factory MaterialRecommendStatModel.fromJson(Map<String, dynamic> json) {
    return MaterialRecommendStatModel(
      materialName: json['material_name'] as String? ?? json['materialName'] as String? ?? 'Packaging Material',
      polymerFamily: json['polymer_family'] as String? ?? json['polymerFamily'] as String? ?? 'BREATHABLE_BIO_EMAP',
      recommendCount: json['recommend_count'] as int? ?? json['recommendCount'] as int? ?? 0,
      sharePct: (json['share_pct'] as num? ?? json['sharePct'] as num? ?? 0.0).toDouble(),
      averageScore: (json['average_score'] as num? ?? json['averageScore'] as num? ?? 90.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'material_name': materialName,
        'polymer_family': polymerFamily,
        'recommend_count': recommendCount,
        'share_pct': sharePct,
        'average_score': averageScore,
      };
}

@immutable
class DailyUsageTrendModel {
  final String date; // YYYY-MM-DD
  final int totalAnalyses;
  final int ecoAnalyses;
  final double avgSustainabilityScore;
  final double avgCostInr;

  const DailyUsageTrendModel({
    required this.date,
    required this.totalAnalyses,
    required this.ecoAnalyses,
    required this.avgSustainabilityScore,
    required this.avgCostInr,
  });

  factory DailyUsageTrendModel.fromJson(Map<String, dynamic> json) {
    return DailyUsageTrendModel(
      date: json['date'] as String? ?? '',
      totalAnalyses: json['total_analyses'] as int? ?? json['totalAnalyses'] as int? ?? 0,
      ecoAnalyses: json['eco_analyses'] as int? ?? json['ecoAnalyses'] as int? ?? 0,
      avgSustainabilityScore: (json['avg_sustainability_score'] as num? ??
              json['avgSustainabilityScore'] as num? ??
              90.0)
          .toDouble(),
      avgCostInr: (json['avg_cost_inr'] as num? ?? json['avgCostInr'] as num? ?? 3.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'total_analyses': totalAnalyses,
        'eco_analyses': ecoAnalyses,
        'avg_sustainability_score': avgSustainabilityScore,
        'avg_cost_inr': avgCostInr,
      };
}

@immutable
class AdminAnalyticsSummaryModel {
  final int totalAnalyses;
  final int totalUsers;
  final int totalFoodsCount;
  final int totalMaterialsCount;
  final double ecoPreferencePct;
  final double averageSystemScore;
  final List<FoodSearchStatModel> topFoods;
  final List<MaterialRecommendStatModel> topMaterials;
  final List<DailyUsageTrendModel> trends;

  const AdminAnalyticsSummaryModel({
    required this.totalAnalyses,
    required this.totalUsers,
    required this.totalFoodsCount,
    required this.totalMaterialsCount,
    required this.ecoPreferencePct,
    required this.averageSystemScore,
    this.topFoods = const [],
    this.topMaterials = const [],
    this.trends = const [],
  });

  factory AdminAnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsSummaryModel(
      totalAnalyses: json['total_analyses'] as int? ?? json['totalAnalyses'] as int? ?? 0,
      totalUsers: json['total_users'] as int? ?? json['totalUsers'] as int? ?? 0,
      totalFoodsCount: json['total_foods_count'] as int? ?? json['totalFoodsCount'] as int? ?? 0,
      totalMaterialsCount: json['total_materials_count'] as int? ?? json['totalMaterialsCount'] as int? ?? 0,
      ecoPreferencePct: (json['eco_preference_pct'] as num? ?? json['ecoPreferencePct'] as num? ?? 80.0).toDouble(),
      averageSystemScore: (json['average_system_score'] as num? ?? json['averageSystemScore'] as num? ?? 90.0).toDouble(),
      topFoods: (json['top_foods'] as List<dynamic>? ?? json['topFoods'] as List<dynamic>? ?? [])
          .map((e) => FoodSearchStatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topMaterials: (json['top_materials'] as List<dynamic>? ?? json['topMaterials'] as List<dynamic>? ?? [])
          .map((e) => MaterialRecommendStatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      trends: (json['trends'] as List<dynamic>? ?? [])
          .map((e) => DailyUsageTrendModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_analyses': totalAnalyses,
        'total_users': totalUsers,
        'total_foods_count': totalFoodsCount,
        'total_materials_count': totalMaterialsCount,
        'eco_preference_pct': ecoPreferencePct,
        'average_system_score': averageSystemScore,
        'top_foods': topFoods.map((e) => e.toJson()).toList(),
        'top_materials': topMaterials.map((e) => e.toJson()).toList(),
        'trends': trends.map((e) => e.toJson()).toList(),
      };
}

// ==========================================
// 2. Rules & Model Registry Models
// ==========================================

@immutable
class RuleThresholdConfigModel {
  final double lipidOxidationFatThresholdPct;
  final double highRespirationMoistureThresholdPct;
  final double acidicCorrosionPhThreshold;
  final double chillingInjuryBufferC;
  final double gasCushionHeadspaceMinPct;
  final double gasCushionHeadspaceMaxPct;
  final double ecoPriorityMultiplier;

  const RuleThresholdConfigModel({
    this.lipidOxidationFatThresholdPct = 18.0,
    this.highRespirationMoistureThresholdPct = 75.0,
    this.acidicCorrosionPhThreshold = 4.6,
    this.chillingInjuryBufferC = 2.0,
    this.gasCushionHeadspaceMinPct = 40.0,
    this.gasCushionHeadspaceMaxPct = 50.0,
    this.ecoPriorityMultiplier = 1.35,
  });

  factory RuleThresholdConfigModel.fromJson(Map<String, dynamic> json) {
    return RuleThresholdConfigModel(
      lipidOxidationFatThresholdPct: (json['lipid_oxidation_fat_threshold_pct'] as num? ??
              json['lipidOxidationFatThresholdPct'] as num? ??
              18.0)
          .toDouble(),
      highRespirationMoistureThresholdPct: (json['high_respiration_moisture_threshold_pct'] as num? ??
              json['highRespirationMoistureThresholdPct'] as num? ??
              75.0)
          .toDouble(),
      acidicCorrosionPhThreshold: (json['acidic_corrosion_ph_threshold'] as num? ??
              json['acidicCorrosionPhThreshold'] as num? ??
              4.6)
          .toDouble(),
      chillingInjuryBufferC: (json['chilling_injury_buffer_c'] as num? ??
              json['chillingInjuryBufferC'] as num? ??
              2.0)
          .toDouble(),
      gasCushionHeadspaceMinPct: (json['gas_cushion_headspace_min_pct'] as num? ??
              json['gasCushionHeadspaceMinPct'] as num? ??
              40.0)
          .toDouble(),
      gasCushionHeadspaceMaxPct: (json['gas_cushion_headspace_max_pct'] as num? ??
              json['gasCushionHeadspaceMaxPct'] as num? ??
              50.0)
          .toDouble(),
      ecoPriorityMultiplier: (json['eco_priority_multiplier'] as num? ??
              json['ecoPriorityMultiplier'] as num? ??
              1.35)
          .toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lipid_oxidation_fat_threshold_pct': lipidOxidationFatThresholdPct,
        'high_respiration_moisture_threshold_pct': highRespirationMoistureThresholdPct,
        'acidic_corrosion_ph_threshold': acidicCorrosionPhThreshold,
        'chilling_injury_buffer_c': chillingInjuryBufferC,
        'gas_cushion_headspace_min_pct': gasCushionHeadspaceMinPct,
        'gas_cushion_headspace_max_pct': gasCushionHeadspaceMaxPct,
        'eco_priority_multiplier': ecoPriorityMultiplier,
      };

  RuleThresholdConfigModel copyWith({
    double? lipidOxidationFatThresholdPct,
    double? highRespirationMoistureThresholdPct,
    double? acidicCorrosionPhThreshold,
    double? chillingInjuryBufferC,
    double? gasCushionHeadspaceMinPct,
    double? gasCushionHeadspaceMaxPct,
    double? ecoPriorityMultiplier,
  }) {
    return RuleThresholdConfigModel(
      lipidOxidationFatThresholdPct:
          lipidOxidationFatThresholdPct ?? this.lipidOxidationFatThresholdPct,
      highRespirationMoistureThresholdPct:
          highRespirationMoistureThresholdPct ?? this.highRespirationMoistureThresholdPct,
      acidicCorrosionPhThreshold:
          acidicCorrosionPhThreshold ?? this.acidicCorrosionPhThreshold,
      chillingInjuryBufferC:
          chillingInjuryBufferC ?? this.chillingInjuryBufferC,
      gasCushionHeadspaceMinPct:
          gasCushionHeadspaceMinPct ?? this.gasCushionHeadspaceMinPct,
      gasCushionHeadspaceMaxPct:
          gasCushionHeadspaceMaxPct ?? this.gasCushionHeadspaceMaxPct,
      ecoPriorityMultiplier:
          ecoPriorityMultiplier ?? this.ecoPriorityMultiplier,
    );
  }
}

@immutable
class ModelRegistryModel {
  final String activeModelName;
  final String algorithm;
  final int featureDimension;
  final double accuracyScore;
  final bool isMlEnabled;
  final bool isHeuristicFallbackActive;
  final DateTime lastTrainedAt;
  final String versionTag;

  const ModelRegistryModel({
    required this.activeModelName,
    required this.algorithm,
    required this.featureDimension,
    required this.accuracyScore,
    required this.isMlEnabled,
    required this.isHeuristicFallbackActive,
    required this.lastTrainedAt,
    required this.versionTag,
  });

  factory ModelRegistryModel.fromJson(Map<String, dynamic> json) {
    return ModelRegistryModel(
      activeModelName: json['active_model_name'] as String? ?? json['activeModelName'] as String? ?? 'RandomForest-v2.3-18D',
      algorithm: json['algorithm'] as String? ?? 'Random Forest Ensemble',
      featureDimension: json['feature_dimension'] as int? ?? json['featureDimension'] as int? ?? 18,
      accuracyScore: (json['accuracy_score'] as num? ?? json['accuracyScore'] as num? ?? 0.984).toDouble(),
      isMlEnabled: json['is_ml_enabled'] as bool? ?? json['isMlEnabled'] as bool? ?? true,
      isHeuristicFallbackActive: json['is_heuristic_fallback_active'] as bool? ?? json['isHeuristicFallbackActive'] as bool? ?? true,
      lastTrainedAt: json['last_trained_at'] != null
          ? DateTime.tryParse(json['last_trained_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      versionTag: json['version_tag'] as String? ?? json['versionTag'] as String? ?? 'v2.3.0-prod',
    );
  }

  Map<String, dynamic> toJson() => {
        'active_model_name': activeModelName,
        'algorithm': algorithm,
        'feature_dimension': featureDimension,
        'accuracy_score': accuracyScore,
        'is_ml_enabled': isMlEnabled,
        'is_heuristic_fallback_active': isHeuristicFallbackActive,
        'last_trained_at': lastTrainedAt.toIso8601String(),
        'version_tag': versionTag,
      };
}

// ==========================================
// 3. Recommendations Audit Models
// ==========================================

@immutable
class AdminRecommendationAuditModel {
  final int id;
  final int? userId;
  final String? userEmail;
  final String itemName;
  final double length;
  final double width;
  final double height;
  final double weight;
  final bool isFragile;
  final bool ecoFriendly;
  final String recommendedBoxType;
  final String recommendedDimensions;
  final String? cushioningMaterial;
  final double estimatedCost;
  final double sustainabilityScore;
  final String? notes;
  final DateTime createdAt;
  final String formattedDate;

  const AdminRecommendationAuditModel({
    required this.id,
    this.userId,
    this.userEmail,
    required this.itemName,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    required this.isFragile,
    required this.ecoFriendly,
    required this.recommendedBoxType,
    required this.recommendedDimensions,
    this.cushioningMaterial,
    required this.estimatedCost,
    required this.sustainabilityScore,
    this.notes,
    required this.createdAt,
    required this.formattedDate,
  });

  factory AdminRecommendationAuditModel.fromJson(Map<String, dynamic> json) {
    return AdminRecommendationAuditModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? json['userId'] as int?,
      userEmail: json['user_email'] as String? ?? json['userEmail'] as String? ?? 'Guest / Anonymous',
      itemName: json['item_name'] as String? ?? json['itemName'] as String? ?? 'Commodity',
      length: (json['length'] as num? ?? 10.0).toDouble(),
      width: (json['width'] as num? ?? 10.0).toDouble(),
      height: (json['height'] as num? ?? 10.0).toDouble(),
      weight: (json['weight'] as num? ?? 0.5).toDouble(),
      isFragile: json['is_fragile'] as bool? ?? json['isFragile'] as bool? ?? false,
      ecoFriendly: json['eco_friendly'] as bool? ?? json['ecoFriendly'] as bool? ?? true,
      recommendedBoxType: json['recommended_box_type'] as String? ?? json['recommendedBoxType'] as String? ?? 'Kraft Box',
      recommendedDimensions: json['recommended_dimensions'] as String? ?? json['recommendedDimensions'] as String? ?? '12x12x12 cm',
      cushioningMaterial: json['cushioning_material'] as String? ?? json['cushioningMaterial'] as String?,
      estimatedCost: (json['estimated_cost'] as num? ?? json['estimatedCost'] as num? ?? 3.0).toDouble(),
      sustainabilityScore: (json['sustainability_score'] as num? ?? json['sustainabilityScore'] as num? ?? 90.0).toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      formattedDate: json['formatted_date'] as String? ?? json['formattedDate'] as String? ?? '27 Sep 2026',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_email': userEmail,
        'item_name': itemName,
        'length': length,
        'width': width,
        'height': height,
        'weight': weight,
        'is_fragile': isFragile,
        'eco_friendly': ecoFriendly,
        'recommended_box_type': recommendedBoxType,
        'recommended_dimensions': recommendedDimensions,
        if (cushioningMaterial != null) 'cushioning_material': cushioningMaterial,
        'estimated_cost': estimatedCost,
        'sustainability_score': sustainabilityScore,
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'formatted_date': formattedDate,
      };
}

// ==========================================
// 4. Food Management Models
// ==========================================

@immutable
class AdminFoodItemModel {
  final int id;
  final String name;
  final String category;
  final String? scientificName;
  final double moisture;
  final double ph;
  final double fat;
  final double? waterActivity;
  final String respirationClass;
  final String oxygenSensitivity;
  final String moistureSensitivity;

  const AdminFoodItemModel({
    required this.id,
    required this.name,
    required this.category,
    this.scientificName,
    this.moisture = 80.0,
    this.ph = 5.0,
    this.fat = 1.0,
    this.waterActivity,
    this.respirationClass = 'Moderate',
    this.oxygenSensitivity = 'Moderate',
    this.moistureSensitivity = 'Moderate',
  });

  factory AdminFoodItemModel.fromJson(Map<String, dynamic> json) {
    return AdminFoodItemModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Food',
      category: json['category'] as String? ?? 'Produce',
      scientificName: json['scientific_name'] as String? ?? json['scientificName'] as String?,
      moisture: (json['moisture'] as num? ?? 80.0).toDouble(),
      ph: (json['ph'] as num? ?? 5.0).toDouble(),
      fat: (json['fat'] as num? ?? 1.0).toDouble(),
      waterActivity: json['water_activity'] != null ? (json['water_activity'] as num).toDouble() : null,
      respirationClass: json['respiration_class'] as String? ?? json['respirationClass'] as String? ?? 'Moderate',
      oxygenSensitivity: json['oxygen_sensitivity'] as String? ?? json['oxygenSensitivity'] as String? ?? 'Moderate',
      moistureSensitivity: json['moisture_sensitivity'] as String? ?? json['moistureSensitivity'] as String? ?? 'Moderate',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        if (scientificName != null) 'scientific_name': scientificName,
        'moisture': moisture,
        'ph': ph,
        'fat': fat,
        if (waterActivity != null) 'water_activity': waterActivity,
        'respiration_class': respirationClass,
        'oxygen_sensitivity': oxygenSensitivity,
        'moisture_sensitivity': moistureSensitivity,
      };
}

@immutable
class AdminFoodDetailModel {
  final int id;
  final String name;
  final String category;
  final String? scientificName;
  final double moisture;
  final double ph;
  final double fat;
  final double? waterActivity;
  final String respirationClass;
  final String oxygenSensitivity;
  final String moistureSensitivity;
  final Map<String, dynamic>? scientificProperties;

  const AdminFoodDetailModel({
    required this.id,
    required this.name,
    required this.category,
    this.scientificName,
    this.moisture = 80.0,
    this.ph = 5.0,
    this.fat = 1.0,
    this.waterActivity,
    this.respirationClass = 'Moderate',
    this.oxygenSensitivity = 'Moderate',
    this.moistureSensitivity = 'Moderate',
    this.scientificProperties,
  });

  factory AdminFoodDetailModel.fromJson(Map<String, dynamic> json) {
    return AdminFoodDetailModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Food',
      category: json['category'] as String? ?? 'Produce',
      scientificName: json['scientific_name'] as String? ?? json['scientificName'] as String?,
      moisture: (json['moisture'] as num? ?? 80.0).toDouble(),
      ph: (json['ph'] as num? ?? 5.0).toDouble(),
      fat: (json['fat'] as num? ?? 1.0).toDouble(),
      waterActivity: json['water_activity'] != null ? (json['water_activity'] as num).toDouble() : null,
      respirationClass: json['respiration_class'] as String? ?? json['respirationClass'] as String? ?? 'Moderate',
      oxygenSensitivity: json['oxygen_sensitivity'] as String? ?? json['oxygenSensitivity'] as String? ?? 'Moderate',
      moistureSensitivity: json['moisture_sensitivity'] as String? ?? json['moistureSensitivity'] as String? ?? 'Moderate',
      scientificProperties: json['scientific_properties'] as Map<String, dynamic>? ??
          json['scientificProperties'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        if (scientificName != null) 'scientific_name': scientificName,
        'moisture': moisture,
        'ph': ph,
        'fat': fat,
        if (waterActivity != null) 'water_activity': waterActivity,
        'respiration_class': respirationClass,
        'oxygen_sensitivity': oxygenSensitivity,
        'moisture_sensitivity': moistureSensitivity,
        if (scientificProperties != null) 'scientific_properties': scientificProperties,
      };
}

// ==========================================
// 5. Packaging Material Management Models
// ==========================================

@immutable
class AdminMaterialItemModel {
  final int id;
  final String materialId;
  final String name;
  final String category;
  final String polymerFamily;
  final String? structure;
  final String formFactor;
  final double thicknessMicrons;
  final double? otr;
  final double? wvtr;
  final double? co2Permeability;
  final double? selectivityBeta;
  final double? tensileStrengthMpa;
  final double? punctureResistanceN;
  final double sustainabilityScore;
  final double recyclabilityScore;
  final double biodegradabilityScore;
  final double estimatedUnitCostInr;
  final bool isBreathable;
  final bool isBiodegradable;
  final bool isRecyclable;
  final bool gasFlushCompatible;
  final bool isActiveEntry;

  const AdminMaterialItemModel({
    required this.id,
    required this.materialId,
    required this.name,
    required this.category,
    required this.polymerFamily,
    this.structure,
    this.formFactor = 'Flexible Pouch',
    this.thicknessMicrons = 30.0,
    this.otr,
    this.wvtr,
    this.co2Permeability,
    this.selectivityBeta,
    this.tensileStrengthMpa,
    this.punctureResistanceN,
    this.sustainabilityScore = 90.0,
    this.recyclabilityScore = 80.0,
    this.biodegradabilityScore = 0.0,
    this.estimatedUnitCostInr = 3.50,
    this.isBreathable = false,
    this.isBiodegradable = false,
    this.isRecyclable = true,
    this.gasFlushCompatible = false,
    this.isActiveEntry = true,
  });

  factory AdminMaterialItemModel.fromJson(Map<String, dynamic> json) {
    return AdminMaterialItemModel(
      id: json['id'] as int? ?? 0,
      materialId: json['material_id'] as String? ?? json['materialId'] as String? ?? 'mat_01',
      name: json['name'] as String? ?? 'Material',
      category: json['category'] as String? ?? 'Polymer',
      polymerFamily: json['polymer_family'] as String? ?? json['polymerFamily'] as String? ?? 'RECYCLABLE_POLYOLEFIN',
      structure: json['structure'] as String?,
      formFactor: json['form_factor'] as String? ?? json['formFactor'] as String? ?? 'Flexible Pouch',
      thicknessMicrons: (json['thickness_microns'] as num? ?? json['thicknessMicrons'] as num? ?? 30.0).toDouble(),
      otr: json['otr_cc_m2_day'] != null
          ? (json['otr_cc_m2_day'] as num).toDouble()
          : (json['otr'] != null ? (json['otr'] as num).toDouble() : null),
      wvtr: json['wvtr_g_m2_day'] != null
          ? (json['wvtr_g_m2_day'] as num).toDouble()
          : (json['wvtr'] != null ? (json['wvtr'] as num).toDouble() : null),
      co2Permeability: json['co2_permeability'] != null ? (json['co2_permeability'] as num).toDouble() : null,
      selectivityBeta: json['selectivity_beta'] != null ? (json['selectivity_beta'] as num).toDouble() : null,
      tensileStrengthMpa: json['tensile_strength_mpa'] != null ? (json['tensile_strength_mpa'] as num).toDouble() : null,
      punctureResistanceN: json['puncture_resistance_n'] != null ? (json['puncture_resistance_n'] as num).toDouble() : null,
      sustainabilityScore: (json['sustainability_score'] as num? ?? json['sustainabilityScore'] as num? ?? 90.0).toDouble(),
      recyclabilityScore: (json['recyclability_score'] as num? ?? json['recyclabilityScore'] as num? ?? 80.0).toDouble(),
      biodegradabilityScore: (json['biodegradability_score'] as num? ?? json['biodegradabilityScore'] as num? ?? 0.0).toDouble(),
      estimatedUnitCostInr: (json['estimated_unit_cost_inr'] as num? ?? json['estimatedUnitCostInr'] as num? ?? 3.50).toDouble(),
      isBreathable: json['is_breathable'] as bool? ?? json['isBreathable'] as bool? ?? false,
      isBiodegradable: json['is_biodegradable'] as bool? ?? json['isBiodegradable'] as bool? ?? false,
      isRecyclable: json['is_recyclable'] as bool? ?? json['isRecyclable'] as bool? ?? false,
      gasFlushCompatible: json['gas_flush_compatible'] as bool? ?? json['gasFlushCompatible'] as bool? ?? false,
      isActiveEntry: json['is_active_entry'] as bool? ?? json['isActiveEntry'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'material_id': materialId,
        'name': name,
        'category': category,
        'polymer_family': polymerFamily,
        if (structure != null) 'structure': structure,
        'form_factor': formFactor,
        'thickness_microns': thicknessMicrons,
        if (otr != null) 'otr_cc_m2_day': otr,
        if (wvtr != null) 'wvtr_g_m2_day': wvtr,
        if (co2Permeability != null) 'co2_permeability': co2Permeability,
        if (selectivityBeta != null) 'selectivity_beta': selectivityBeta,
        if (tensileStrengthMpa != null) 'tensile_strength_mpa': tensileStrengthMpa,
        if (punctureResistanceN != null) 'puncture_resistance_n': punctureResistanceN,
        'sustainability_score': sustainabilityScore,
        'recyclability_score': recyclabilityScore,
        'biodegradability_score': biodegradabilityScore,
        'estimated_unit_cost_inr': estimatedUnitCostInr,
        'is_breathable': isBreathable,
        'is_biodegradable': isBiodegradable,
        'is_recyclable': isRecyclable,
        'gas_flush_compatible': gasFlushCompatible,
        'is_active_entry': isActiveEntry,
      };
}
