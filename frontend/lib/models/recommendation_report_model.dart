/// Recommendation Report & Multi-Format Export Dart Models (Module 12).
/// Provides strongly-typed models, JSON serialization, Markdown exporter,
/// and live client-side synthesis from active recommendation state.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'packaging_model.dart';
import 'sustainability_model.dart';
import 'cost_estimation_model.dart';

class ReportFoodContext {
  final String name;
  final String category;
  final String? scientificName;
  final String fillQuantity;
  final int batchSizeUnits;
  final String storageCondition;
  final double? storageTempC;
  final int storageDurationDays;
  final String transportMode;

  const ReportFoodContext({
    required this.name,
    this.category = 'General Food',
    this.scientificName,
    this.fillQuantity = '500g',
    this.batchSizeUnits = 10000,
    this.storageCondition = 'Ambient Standard',
    this.storageTempC,
    this.storageDurationDays = 180,
    this.transportMode = 'Ambient Standard Logistics',
  });

  factory ReportFoodContext.fromJson(Map<String, dynamic> json) {
    return ReportFoodContext(
      name: json['name']?.toString() ?? 'Food Commodity',
      category: json['category']?.toString() ?? 'General Food',
      scientificName: json['scientific_name']?.toString(),
      fillQuantity: json['fill_quantity']?.toString() ?? '500g',
      batchSizeUnits: (json['batch_size_units'] as num?)?.toInt() ?? 10000,
      storageCondition: json['storage_condition']?.toString() ?? 'Ambient Standard',
      storageTempC: (json['storage_temp_c'] as num?)?.toDouble(),
      storageDurationDays: (json['storage_duration_days'] as num?)?.toInt() ?? 180,
      transportMode: json['transport_mode']?.toString() ?? 'Ambient Standard Logistics',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        if (scientificName != null) 'scientific_name': scientificName,
        'fill_quantity': fillQuantity,
        'batch_size_units': batchSizeUnits,
        'storage_condition': storageCondition,
        if (storageTempC != null) 'storage_temp_c': storageTempC,
        'storage_duration_days': storageDurationDays,
        'transport_mode': transportMode,
      };
}

class ReportFoodProperties {
  final double? moisturePct;
  final double? waterActivityAw;
  final double? phLevel;
  final double? fatPct;
  final String? respirationClass;
  final double? respirationRate20c;
  final String oxygenSensitivity;
  final String moistureSensitivity;
  final String? ethyleneSensitivity;
  final double? chillingInjuryThresholdC;

  const ReportFoodProperties({
    this.moisturePct,
    this.waterActivityAw,
    this.phLevel,
    this.fatPct,
    this.respirationClass,
    this.respirationRate20c,
    this.oxygenSensitivity = 'Moderate',
    this.moistureSensitivity = 'Moderate',
    this.ethyleneSensitivity,
    this.chillingInjuryThresholdC,
  });

  factory ReportFoodProperties.fromJson(Map<String, dynamic> json) {
    return ReportFoodProperties(
      moisturePct: (json['moisture_pct'] as num?)?.toDouble(),
      waterActivityAw: (json['water_activity_aw'] as num?)?.toDouble(),
      phLevel: (json['ph_level'] as num?)?.toDouble(),
      fatPct: (json['fat_pct'] as num?)?.toDouble(),
      respirationClass: json['respiration_class']?.toString(),
      respirationRate20c: (json['respiration_rate_20c'] as num?)?.toDouble(),
      oxygenSensitivity: json['oxygen_sensitivity']?.toString() ?? 'Moderate',
      moistureSensitivity: json['moisture_sensitivity']?.toString() ?? 'Moderate',
      ethyleneSensitivity: json['ethylene_sensitivity']?.toString(),
      chillingInjuryThresholdC: (json['chilling_injury_threshold_c'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (moisturePct != null) 'moisture_pct': moisturePct,
        if (waterActivityAw != null) 'water_activity_aw': waterActivityAw,
        if (phLevel != null) 'ph_level': phLevel,
        if (fatPct != null) 'fat_pct': fatPct,
        if (respirationClass != null) 'respiration_class': respirationClass,
        if (respirationRate20c != null) 'respiration_rate_20c': respirationRate20c,
        'oxygen_sensitivity': oxygenSensitivity,
        'moisture_sensitivity': moistureSensitivity,
        if (ethyleneSensitivity != null) 'ethylene_sensitivity': ethyleneSensitivity,
        if (chillingInjuryThresholdC != null) 'chilling_injury_threshold_c': chillingInjuryThresholdC,
      };
}

class ReportPrimaryPrescription {
  final String materialName;
  final String materialType;
  final String polymerFamily;
  final String structure;
  final String packageFormat;
  final String dimensions;
  final double thicknessMicrons;
  final String otr;
  final String wvtr;
  final double tensileStrengthMpa;
  final double punctureResistanceN;
  final double suitabilityScore;
  final double sustainabilityScore;
  final double estimatedUnitCostInr;
  final List<String> advantages;
  final List<String> limitations;
  final Map<String, String> importantProperties;

  const ReportPrimaryPrescription({
    required this.materialName,
    this.materialType = 'Polymer Substrate',
    this.polymerFamily = 'MULTILAYER_BARRIER_COEX',
    this.structure = 'Monomaterial / Barrier Coex',
    this.packageFormat = 'Stand-up Doypack (Bottom Gusset)',
    this.dimensions = '18.0 x 12.0 x 4.0 cm',
    this.thicknessMicrons = 50.0,
    this.otr = '< 10.0 cc/m²/day',
    this.wvtr = '< 3.0 g/m²/day',
    this.tensileStrengthMpa = 35.0,
    this.punctureResistanceN = 22.0,
    this.suitabilityScore = 0.90,
    this.sustainabilityScore = 85.0,
    this.estimatedUnitCostInr = 3.50,
    this.advantages = const [],
    this.limitations = const [],
    this.importantProperties = const {},
  });

  factory ReportPrimaryPrescription.fromJson(Map<String, dynamic> json) {
    return ReportPrimaryPrescription(
      materialName: json['material_name']?.toString() ?? 'Packaging Substrate',
      materialType: json['material_type']?.toString() ?? 'Polymer Substrate',
      polymerFamily: json['polymer_family']?.toString() ?? 'MULTILAYER_BARRIER_COEX',
      structure: json['structure']?.toString() ?? 'Monomaterial / Barrier Coex',
      packageFormat: json['package_format']?.toString() ?? 'Stand-up Doypack (Bottom Gusset)',
      dimensions: json['dimensions']?.toString() ?? '18.0 x 12.0 x 4.0 cm',
      thicknessMicrons: (json['thickness_microns'] as num?)?.toDouble() ?? 50.0,
      otr: json['otr']?.toString() ?? '< 10.0 cc/m²/day',
      wvtr: json['wvtr']?.toString() ?? '< 3.0 g/m²/day',
      tensileStrengthMpa: (json['tensile_strength_mpa'] as num?)?.toDouble() ?? 35.0,
      punctureResistanceN: (json['puncture_resistance_n'] as num?)?.toDouble() ?? 22.0,
      suitabilityScore: (json['suitability_score'] as num?)?.toDouble() ?? 0.90,
      sustainabilityScore: (json['sustainability_score'] as num?)?.toDouble() ?? 85.0,
      estimatedUnitCostInr: (json['estimated_unit_cost_inr'] as num?)?.toDouble() ?? 3.50,
      advantages: (json['advantages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      limitations: (json['limitations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      importantProperties: json['important_properties'] != null
          ? Map<String, String>.from(json['important_properties'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'material_name': materialName,
        'material_type': materialType,
        'polymer_family': polymerFamily,
        'structure': structure,
        'package_format': packageFormat,
        'dimensions': dimensions,
        'thickness_microns': thicknessMicrons,
        'otr': otr,
        'wvtr': wvtr,
        'tensile_strength_mpa': tensileStrengthMpa,
        'puncture_resistance_n': punctureResistanceN,
        'suitability_score': suitabilityScore,
        'sustainability_score': sustainabilityScore,
        'estimated_unit_cost_inr': estimatedUnitCostInr,
        'advantages': advantages,
        'limitations': limitations,
        'important_properties': importantProperties,
      };
}

class ReportAlternativePackaging {
  final String tierName;
  final String materialName;
  final String packagingTitle;
  final String keyTradeoff;
  final double costDeltaPct;
  final double ecoDeltaPct;
  final String shelfLifeDelta;
  final int starRating;

  const ReportAlternativePackaging({
    required this.tierName,
    required this.materialName,
    this.packagingTitle = 'Alternative Formulation',
    required this.keyTradeoff,
    this.costDeltaPct = 0.0,
    this.ecoDeltaPct = 0.0,
    this.shelfLifeDelta = 'Comparable shelf life',
    this.starRating = 4,
  });

  factory ReportAlternativePackaging.fromJson(Map<String, dynamic> json) {
    return ReportAlternativePackaging(
      tierName: json['tier_name']?.toString() ?? 'Alternative',
      materialName: json['material_name']?.toString() ?? 'Alternative Material',
      packagingTitle: json['packaging_title']?.toString() ?? 'Alternative Formulation',
      keyTradeoff: json['key_tradeoff']?.toString() ?? 'Trade-off comparison',
      costDeltaPct: (json['cost_delta_pct'] as num?)?.toDouble() ?? 0.0,
      ecoDeltaPct: (json['eco_delta_pct'] as num?)?.toDouble() ?? 0.0,
      shelfLifeDelta: json['shelf_life_delta']?.toString() ?? 'Comparable shelf life',
      starRating: (json['star_rating'] as num?)?.toInt() ?? 4,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier_name': tierName,
        'material_name': materialName,
        'packaging_title': packagingTitle,
        'key_tradeoff': keyTradeoff,
        'cost_delta_pct': costDeltaPct,
        'eco_delta_pct': ecoDeltaPct,
        'shelf_life_delta': shelfLifeDelta,
        'star_rating': starRating,
      };
}

class ReportLcaSummary {
  final String recyclabilityTier;
  final String resinIdentificationCode;
  final String? biodegradabilityStandard;
  final int reusabilityCycles;
  final double carbonFootprintGPerUnit;
  final double carbonFootprintBatchKg;
  final double pcrPercentage;
  final double pcrCarbonReductionPct;
  final double waterFootprintLPerUnit;
  final double waterFootprintBatchLiters;
  final double unitWasteGrams;
  final double totalBatchWasteKg;
  final double landfillDiversionPct;
  final double circularityIndexMci;
  final String primaryDisposalPathway;

  const ReportLcaSummary({
    this.recyclabilityTier = 'High',
    this.resinIdentificationCode = 'RIC 4 (LDPE)',
    this.biodegradabilityStandard,
    this.reusabilityCycles = 1,
    required this.carbonFootprintGPerUnit,
    required this.carbonFootprintBatchKg,
    this.pcrPercentage = 0.0,
    this.pcrCarbonReductionPct = 0.0,
    required this.waterFootprintLPerUnit,
    required this.waterFootprintBatchLiters,
    required this.unitWasteGrams,
    required this.totalBatchWasteKg,
    this.landfillDiversionPct = 80.0,
    this.circularityIndexMci = 0.80,
    this.primaryDisposalPathway = 'Curbside Mechanical Recycling',
  });

  factory ReportLcaSummary.fromJson(Map<String, dynamic> json) {
    return ReportLcaSummary(
      recyclabilityTier: json['recyclability_tier']?.toString() ?? 'High',
      resinIdentificationCode: json['resin_identification_code']?.toString() ?? 'RIC 4 (LDPE)',
      biodegradabilityStandard: json['biodegradability_standard']?.toString(),
      reusabilityCycles: (json['reusability_cycles'] as num?)?.toInt() ?? 1,
      carbonFootprintGPerUnit: (json['carbon_footprint_g_per_unit'] as num?)?.toDouble() ?? 14.5,
      carbonFootprintBatchKg: (json['carbon_footprint_batch_kg'] as num?)?.toDouble() ?? 145.0,
      pcrPercentage: (json['pcr_percentage'] as num?)?.toDouble() ?? 0.0,
      pcrCarbonReductionPct: (json['pcr_carbon_reduction_pct'] as num?)?.toDouble() ?? 0.0,
      waterFootprintLPerUnit: (json['water_footprint_l_per_unit'] as num?)?.toDouble() ?? 0.22,
      waterFootprintBatchLiters: (json['water_footprint_batch_liters'] as num?)?.toDouble() ?? 2200.0,
      unitWasteGrams: (json['unit_waste_grams'] as num?)?.toDouble() ?? 12.0,
      totalBatchWasteKg: (json['total_batch_waste_kg'] as num?)?.toDouble() ?? 120.0,
      landfillDiversionPct: (json['landfill_diversion_pct'] as num?)?.toDouble() ?? 80.0,
      circularityIndexMci: (json['circularity_index_mci'] as num?)?.toDouble() ?? 0.80,
      primaryDisposalPathway: json['primary_disposal_pathway']?.toString() ?? 'Curbside Mechanical Recycling',
    );
  }

  Map<String, dynamic> toJson() => {
        'recyclability_tier': recyclabilityTier,
        'resin_identification_code': resinIdentificationCode,
        if (biodegradabilityStandard != null) 'biodegradability_standard': biodegradabilityStandard,
        'reusability_cycles': reusabilityCycles,
        'carbon_footprint_g_per_unit': carbonFootprintGPerUnit,
        'carbon_footprint_batch_kg': carbonFootprintBatchKg,
        'pcr_percentage': pcrPercentage,
        'pcr_carbon_reduction_pct': pcrCarbonReductionPct,
        'water_footprint_l_per_unit': waterFootprintLPerUnit,
        'water_footprint_batch_liters': waterFootprintBatchLiters,
        'unit_waste_grams': unitWasteGrams,
        'total_batch_waste_kg': totalBatchWasteKg,
        'landfill_diversion_pct': landfillDiversionPct,
        'circularity_index_mci': circularityIndexMci,
        'primary_disposal_pathway': primaryDisposalPathway,
      };
}

class ReportCostSummary {
  final double estimatedCostPerUnitInr;
  final double estimatedBatchCostInr;
  final double grossMaterialMassGrams;
  final double grossMaterialMassBatchKg;
  final double filmSurfaceAreaSqm;
  final String currency;

  const ReportCostSummary({
    required this.estimatedCostPerUnitInr,
    required this.estimatedBatchCostInr,
    required this.grossMaterialMassGrams,
    required this.grossMaterialMassBatchKg,
    this.filmSurfaceAreaSqm = 0.06,
    this.currency = 'INR',
  });

  factory ReportCostSummary.fromJson(Map<String, dynamic> json) {
    return ReportCostSummary(
      estimatedCostPerUnitInr: (json['estimated_cost_per_unit_inr'] as num?)?.toDouble() ?? 3.50,
      estimatedBatchCostInr: (json['estimated_batch_cost_inr'] as num?)?.toDouble() ?? 35000.0,
      grossMaterialMassGrams: (json['gross_material_mass_grams'] as num?)?.toDouble() ?? 12.5,
      grossMaterialMassBatchKg: (json['gross_material_mass_batch_kg'] as num?)?.toDouble() ?? 125.0,
      filmSurfaceAreaSqm: (json['film_surface_area_sqm'] as num?)?.toDouble() ?? 0.06,
      currency: json['currency']?.toString() ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() => {
        'estimated_cost_per_unit_inr': estimatedCostPerUnitInr,
        'estimated_batch_cost_inr': estimatedBatchCostInr,
        'gross_material_mass_grams': grossMaterialMassGrams,
        'gross_material_mass_batch_kg': grossMaterialMassBatchKg,
        'film_surface_area_sqm': filmSurfaceAreaSqm,
        'currency': currency,
      };
}

class RecommendationReportModel {
  final String reportId;
  final DateTime generatedAt;
  final String engineVersion;
  final String verificationHash;
  final ReportFoodContext foodContext;
  final ReportFoodProperties foodProperties;
  final ReportPrimaryPrescription primaryPrescription;
  final String explainableRationale;
  final List<String> keyDrivers;
  final List<ReportAlternativePackaging> alternatives;
  final ReportLcaSummary lcaSummary;
  final ReportCostSummary costSummary;
  final List<String> standardsAndCitations;
  final String? shareUrl;

  const RecommendationReportModel({
    required this.reportId,
    required this.generatedAt,
    this.engineVersion = 'SmartPack AI Engine v2.4-Hybrid',
    required this.verificationHash,
    required this.foodContext,
    required this.foodProperties,
    required this.primaryPrescription,
    required this.explainableRationale,
    this.keyDrivers = const [],
    this.alternatives = const [],
    required this.lcaSummary,
    required this.costSummary,
    this.standardsAndCitations = const [
      'ASTM F1927 (Determination of Oxygen Gas Transmission Rate)',
      'ASTM F1249 (Standard Test Method for Water Vapor Transmission Rate)',
      'ISO 14040/14044 (Environmental Management - Life Cycle Assessment)',
      'Sphera GaBi Life Cycle Inventory Database (2023)',
    ],
    this.shareUrl,
  });

  factory RecommendationReportModel.fromJson(Map<String, dynamic> json) {
    return RecommendationReportModel(
      reportId: json['report_id']?.toString() ?? 'SPK-REPORT',
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'].toString())?.toUtc() ?? DateTime.now().toUtc()
          : DateTime.now().toUtc(),
      engineVersion: json['engine_version']?.toString() ?? 'SmartPack AI Engine v2.4-Hybrid',
      verificationHash: json['verification_hash']?.toString() ?? '',
      foodContext: ReportFoodContext.fromJson(Map<String, dynamic>.from(json['food_context'] ?? {})),
      foodProperties: ReportFoodProperties.fromJson(Map<String, dynamic>.from(json['food_properties'] ?? {})),
      primaryPrescription: ReportPrimaryPrescription.fromJson(Map<String, dynamic>.from(json['primary_prescription'] ?? {})),
      explainableRationale: json['explainable_rationale']?.toString() ?? 'Optimized barrier packaging prescription.',
      keyDrivers: (json['key_drivers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      alternatives: (json['alternatives'] as List<dynamic>?)
              ?.map((e) => ReportAlternativePackaging.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      lcaSummary: ReportLcaSummary.fromJson(Map<String, dynamic>.from(json['lca_summary'] ?? {})),
      costSummary: ReportCostSummary.fromJson(Map<String, dynamic>.from(json['cost_summary'] ?? {})),
      standardsAndCitations: (json['standards_and_citations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      shareUrl: json['share_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'report_id': reportId,
        'generated_at': generatedAt.toIso8601String(),
        'engine_version': engineVersion,
        'verification_hash': verificationHash,
        'food_context': foodContext.toJson(),
        'food_properties': foodProperties.toJson(),
        'primary_prescription': primaryPrescription.toJson(),
        'explainable_rationale': explainableRationale,
        'key_drivers': keyDrivers,
        'alternatives': alternatives.map((e) => e.toJson()).toList(),
        'lca_summary': lcaSummary.toJson(),
        'cost_summary': costSummary.toJson(),
        'standards_and_citations': standardsAndCitations,
        if (shareUrl != null) 'share_url': shareUrl,
      };

  /// Factory constructor to synthesize report directly from client-side recommendation result and input state.
  factory RecommendationReportModel.fromRecommendationResult({
    required PackagingRecommendationResult result,
    required PackagingInput input,
    SustainabilityProfile? sustainabilityProfile,
    CostEstimationResponse? costResponse,
    String? customReportId,
    int batchSize = 10000,
    double pcrPercentage = 0.0,
  }) {
    final now = DateTime.now().toUtc();
    final repId = customReportId ?? 'SPK-${DateFormat('yyyyMMdd').format(now)}-${result.recommendationId.replaceAll('rec_', '').toUpperCase()}';
    final primary = result.primaryRecommendation;

    final foodContext = ReportFoodContext(
      name: input.itemName,
      category: input.category ?? 'General Food',
      fillQuantity: '${input.weight.toStringAsFixed(0)}g',
      batchSizeUnits: batchSize,
      storageCondition: input.storageCondition ?? 'Ambient Standard',
      storageTempC: input.storageTempC ?? 20.0,
      storageDurationDays: input.storageDurationDays ?? 180,
      transportMode: input.transportMode ?? ((input.storageTempC ?? 20.0) <= 8.0 ? 'Refrigerated Cold Chain' : 'Ambient Standard Logistics'),
    );

    final foodProps = ReportFoodProperties(
      moisturePct: input.moisture,
      waterActivityAw: input.waterActivity,
      phLevel: input.ph,
      fatPct: input.fat,
      respirationClass: input.respirationClass,
      respirationRate20c: input.respirationRate20c,
      oxygenSensitivity: (input.fat ?? 0.0) > 10.0 ? 'High (Rancidity risk)' : 'Moderate',
      moistureSensitivity: (input.moisture ?? 0.0) < 15.0 ? 'High (Crispness loss)' : 'Moderate',
      ethyleneSensitivity: input.ethyleneSensitivity,
      chillingInjuryThresholdC: input.chillingInjuryThresholdC,
    );

    final dimsStr = '${input.length.toStringAsFixed(1)} x ${input.width.toStringAsFixed(1)} x ${input.height.toStringAsFixed(1)} cm';
    final prescription = ReportPrimaryPrescription(
      materialName: primary.materialName,
      materialType: primary.materialType,
      polymerFamily: primary.polymerFamily,
      structure: primary.structure,
      packageFormat: primary.packagingFormat,
      dimensions: dimsStr,
      thicknessMicrons: primary.barrierProfile.thicknessMicrons,
      otr: primary.barrierProfile.otr,
      wvtr: primary.barrierProfile.wvtr,
      tensileStrengthMpa: primary.barrierProfile.tensileStrengthMpa,
      punctureResistanceN: primary.barrierProfile.punctureResistanceN,
      suitabilityScore: primary.suitabilityScore,
      sustainabilityScore: primary.sustainabilityScore,
      estimatedUnitCostInr: primary.estimatedUnitCostInr,
      advantages: primary.advantages,
      limitations: primary.limitations,
      importantProperties: primary.importantProperties,
    );

    // Map 3-way alternatives
    final altModels = <ReportAlternativePackaging>[];
    for (final alt in result.alternatives) {
      altModels.add(
        ReportAlternativePackaging(
          tierName: alt.type.displayName,
          materialName: alt.materialName,
          packagingTitle: alt.packagingTitle,
          keyTradeoff: alt.tradeOffSummary,
          costDeltaPct: alt.costDeltaPct,
          ecoDeltaPct: alt.ecoDeltaPct,
          shelfLifeDelta: alt.shelfLifeDelta,
          starRating: alt.starRating,
        ),
      );
    }

    // Default fallback alternatives if empty
    if (altModels.isEmpty) {
      altModels.addAll([
        const ReportAlternativePackaging(
          tierName: 'Eco-Champion',
          materialName: 'NatureFlex™ Bio-Cellulose Film',
          packagingTitle: 'Compostable Plant-Based Substrate',
          keyTradeoff: '100% Home compostable with moderate oxygen barrier; +18% unit cost.',
          costDeltaPct: 18.5,
          ecoDeltaPct: 24.0,
          shelfLifeDelta: '~85% standard shelf life',
          starRating: 4,
        ),
        const ReportAlternativePackaging(
          tierName: 'Economy Option',
          materialName: 'Monomaterial BOPP / CPP Coex Pouch',
          packagingTitle: 'High-Yield Converter Monomaterial',
          keyTradeoff: 'Maximum cost reduction with high recyclability; requires dry ambient storage.',
          costDeltaPct: -22.0,
          ecoDeltaPct: 8.0,
          shelfLifeDelta: '~90% standard shelf life',
          starRating: 4,
        ),
        const ReportAlternativePackaging(
          tierName: 'High-Barrier Preservation',
          materialName: 'PET / Aluminum Foil / PE 3-Ply Laminate',
          packagingTitle: 'Hermetic Ultra-Barrier Foil Laminate',
          keyTradeoff: 'Near-zero gas and moisture transmission; non-recyclable multi-material.',
          costDeltaPct: 32.0,
          ecoDeltaPct: -35.0,
          shelfLifeDelta: '+150% extended shelf life (up to 24+ months)',
          starRating: 5,
        ),
      ]);
    }

    // Compute LCA Summary
    final unitCarbonG = sustainabilityProfile != null
        ? (sustainabilityProfile.environmentalIndicators.carbonFootprintKgCo2ePerUnit * 1000.0)
        : 14.20;
    final batchCarbonKg = sustainabilityProfile?.environmentalIndicators.carbonFootprintKgCo2eTotalBatch ?? ((unitCarbonG * batchSize) / 1000.0);
    final unitWaterL = sustainabilityProfile?.environmentalIndicators.waterFootprintLitersPerUnit ?? 0.22;
    final batchWaterL = sustainabilityProfile?.environmentalIndicators.waterFootprintLitersTotalBatch ?? (unitWaterL * batchSize);
    final unitWasteG = sustainabilityProfile?.wastePotential.unitWasteGrams ?? 12.5;
    final batchWasteKg = sustainabilityProfile?.wastePotential.totalBatchWasteKg ?? ((unitWasteG * batchSize) / 1000.0);
    final diversionPct = sustainabilityProfile?.wastePotential.diversionPotentialPct ?? 85.0;
    final circularityIndex = sustainabilityProfile?.wastePotential.circularityIndex ?? 0.82;
    final disposalPath = sustainabilityProfile?.wastePotential.primaryDisposalPathway ?? 'Curbside Mechanical Recycling';

    final lca = ReportLcaSummary(
      recyclabilityTier: sustainabilityProfile?.recyclability.label ?? (primary.sustainabilityScore >= 80 ? 'High' : 'Medium'),
      resinIdentificationCode: sustainabilityProfile?.resinIdentificationCode ?? 'RIC 4 (LDPE)',
      biodegradabilityStandard: sustainabilityProfile?.biodegradabilityStandard,
      reusabilityCycles: 1,
      carbonFootprintGPerUnit: unitCarbonG,
      carbonFootprintBatchKg: batchCarbonKg,
      pcrPercentage: pcrPercentage,
      pcrCarbonReductionPct: sustainabilityProfile?.environmentalIndicators.pcrCarbonReductionPct ?? (pcrPercentage * 0.45),
      waterFootprintLPerUnit: unitWaterL,
      waterFootprintBatchLiters: batchWaterL,
      unitWasteGrams: unitWasteG,
      totalBatchWasteKg: batchWasteKg,
      landfillDiversionPct: diversionPct,
      circularityIndexMci: circularityIndex,
      primaryDisposalPathway: disposalPath,
    );

    // Compute Cost Summary
    final unitCost = costResponse?.costPerUnitInr ?? primary.estimatedUnitCostInr;
    final batchCost = costResponse?.totalEstimatedCostInr ?? (unitCost * batchSize);
    final grossMass = costResponse?.materialRequirement.weightPerUnitGrams ?? 12.5;
    final batchMass = costResponse?.materialRequirement.grossWeightRequiredKg ?? ((grossMass * batchSize) / 1000.0);
    final surfArea = costResponse?.materialRequirement.surfaceAreaPerUnitSqm ?? 0.06;

    final cost = ReportCostSummary(
      estimatedCostPerUnitInr: unitCost,
      estimatedBatchCostInr: batchCost,
      grossMaterialMassGrams: grossMass,
      grossMaterialMassBatchKg: batchMass,
      filmSurfaceAreaSqm: surfArea,
      currency: costResponse?.currencyCode ?? 'INR',
    );

    // Compute deterministic verification hash
    final rawHashString = '${input.itemName}|${primary.materialName}|${primary.barrierProfile.thicknessMicrons.toStringAsFixed(1)}|${primary.barrierProfile.otr}|${primary.barrierProfile.wvtr}|${now.toIso8601String()}|SmartPack AI Engine v2.4-Hybrid';
    final hashBytes = sha256.convert(utf8.encode(rawHashString)).toString();

    final drivers = result.scientificRationale.keyDrivers.isNotEmpty
        ? result.scientificRationale.keyDrivers
        : [
            'Barrier Protection: OTR ${primary.barrierProfile.otr} and WVTR ${primary.barrierProfile.wvtr} target primary degradation pathways.',
            'Mechanical Strength: ${primary.barrierProfile.tensileStrengthMpa} MPa tensile rating with ${primary.barrierProfile.punctureResistanceN} N puncture resistance.',
            'Environmental Score: ${primary.sustainabilityScore.toStringAsFixed(0)}/100 sustainability index.',
          ];

    return RecommendationReportModel(
      reportId: repId,
      generatedAt: now,
      engineVersion: 'SmartPack AI Engine v2.4-Hybrid',
      verificationHash: hashBytes,
      foodContext: foodContext,
      foodProperties: foodProps,
      primaryPrescription: prescription,
      explainableRationale: result.scientificRationale.summary,
      keyDrivers: drivers,
      alternatives: altModels,
      lcaSummary: lca,
      costSummary: cost,
      standardsAndCitations: const [
        'ASTM F1927 (Determination of Oxygen Gas Transmission Rate by Coulometric Sensor)',
        'ASTM F1249 (Water Vapor Transmission Rate Through Plastic Film and Sheeting)',
        'ISO 14040/14044 (Environmental Management - Life Cycle Assessment)',
        'ASTM D882 / ISO 527-3 (Tensile Properties of Thin Plastic Sheeting)',
        'Sphera GaBi Life Cycle Inventory Database (2023)',
      ],
      shareUrl: 'https://smartpack.ai/reports/$repId',
    );
  }

  /// Exports formatted GitHub Flavored Markdown specification sheet.
  String toMarkdownString() {
    final fc = foodContext;
    final fp = foodProperties;
    final rx = primaryPrescription;
    final lca = lcaSummary;
    final cost = costSummary;

    final driversMd = keyDrivers.map((d) => '- $d').join('\n');

    final altRows = alternatives.map((alt) {
      final costSign = alt.costDeltaPct > 0 ? '+' : '';
      final ecoSign = alt.ecoDeltaPct > 0 ? '+' : '';
      return '| **${alt.tierName}** | ${alt.materialName} | ${alt.keyTradeoff} | $costSign${alt.costDeltaPct.toStringAsFixed(1)}% | $ecoSign${alt.ecoDeltaPct.toStringAsFixed(1)}% | ${alt.shelfLifeDelta} | ${'★' * alt.starRating} |';
    }).join('\n');

    final citationsMd = standardsAndCitations.map((c) => '- $c').join('\n');

    return '''# 📄 SmartPack AI Packaging Recommendation Specification Report

**Report ID:** `$reportId`  
**Generated At:** `${DateFormat('yyyy-MM-dd HH:mm:ss').format(generatedAt)} UTC`  
**Engine Version:** `$engineVersion`  
**Provenance Verification Hash:** `$verificationHash`  

---

## 1. Food Commodity Context & Operational Parameters
| Parameter | Specification Value |
| :--- | :--- |
| **Commodity Name** | **${fc.name}** |
| **Category** | ${fc.category} |
| **Scientific Taxonomy** | *${fc.scientificName ?? 'N/A'}* |
| **Target Fill Weight / Unit** | ${fc.fillQuantity} |
| **Target Production Batch Size** | ${NumberFormat('#,###').format(fc.batchSizeUnits)} units |
| **Storage Regimen** | ${fc.storageCondition} (${fc.storageTempC != null ? '${fc.storageTempC!.toStringAsFixed(1)}°C' : 'Ambient'}) |
| **Design Shelf Life** | **${fc.storageDurationDays} days** |
| **Supply Chain Transport Mode** | ${fc.transportMode} |

---

## 2. Biochemical Food Degradation Profile
| Degradation Vector | Property Value | Critical Packaging Implication |
| :--- | :--- | :--- |
| **Moisture Content (%)** | ${fp.moisturePct != null ? '${fp.moisturePct!.toStringAsFixed(1)}%' : 'N/A'} | Dictates WVTR barrier threshold to prevent staling / caking |
| **Water Activity (\$a_w\$)** | ${fp.waterActivityAw != null ? fp.waterActivityAw!.toStringAsFixed(2) : 'N/A'} | Microbial growth boundary & moisture equilibrium control |
| **pH Level** | ${fp.phLevel != null ? fp.phLevel!.toStringAsFixed(2) : 'N/A'} | Chemical corrosion risk & acid barrier requirements |
| **Fat / Lipid Content (%)** | ${fp.fatPct != null ? '${fp.fatPct!.toStringAsFixed(1)}%' : 'N/A'} | Rancidity susceptibility & grease resistance necessity |
| **Respiration Dynamics** | ${fp.respirationClass ?? 'Non-respiring'} (${fp.respirationRate20c != null ? '${fp.respirationRate20c} mg CO₂/kg-h' : '0'}) | EMAP gas transmission equilibrium requirements |
| **Oxygen Sensitivity** | **${fp.oxygenSensitivity}** | Target OTR barrier tier |
| **Moisture Sensitivity** | **${fp.moistureSensitivity}** | Target WVTR barrier tier |
| **Ethylene Sensitivity** | ${fp.ethyleneSensitivity ?? 'Not applicable'} | Ripening regulation & scavenger requirement |
| **Chilling Sensitivity Threshold** | ${fp.chillingInjuryThresholdC != null ? '${fp.chillingInjuryThresholdC}°C' : 'N/A'} | Cold chain lower temperature boundary |

---

## 3. Primary Prescribed Packaging Formulation & Barrier Specifications
| Technical Parameter | Engineering Specification | Standard / Reference |
| :--- | :--- | :--- |
| **Prescribed Substrate** | **${rx.materialName}** | Commercial Grade Packaging Substrate |
| **Polymer Family** | `${rx.polymerFamily}` | ASTM D883 Classification |
| **Film Layer Structure** | ${rx.structure} | Cross-sectional morphology |
| **Package Format & Dims** | ${rx.packageFormat} (${rx.dimensions}) | Geometric fill layout |
| **Gauge Thickness** | **${rx.thicknessMicrons.toStringAsFixed(1)} µm** | ASTM D6988 Micrometer Gauge |
| **Oxygen Transmission Rate (OTR)** | **${rx.otr}** | ASTM F1927 (23°C, 0% RH) |
| **Water Vapor Trans. Rate (WVTR)** | **${rx.wvtr}** | ASTM F1249 (38°C, 90% RH) |
| **Tensile Strength** | ${rx.tensileStrengthMpa.toStringAsFixed(1)} MPa | ASTM D882 / ISO 527-3 |
| **Puncture Resistance** | ${rx.punctureResistanceN.toStringAsFixed(1)} N | ASTM F1306 |
| **Prescription Suitability Score** | **${(rx.suitabilityScore * 100.0).toStringAsFixed(1)}%** | Multi-Criteria TOPSIS Engine |
| **Sustainability Rating** | **${rx.sustainabilityScore.toStringAsFixed(1)} / 100** | Life Cycle Assessment Profile |

---

## 4. Explainable AI (XAI) Prescription Rationale & Key Drivers
> $explainableRationale

### Primary Technical Decision Drivers
$driversMd

---

## 5. Multi-Material Comparative Benchmarking Matrix
| Tier | Alternative Material | Key Strategic Trade-Off | Cost Delta | Eco Delta | Shelf-Life Impact | Rating |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
$altRows

---

## 6. Environmental Sustainability & Life Cycle Assessment (LCA) Impact
| LCA Metric Indicator | Unit Result (1 Pack) | Total Batch (${NumberFormat('#,###').format(fc.batchSizeUnits)} Units) | Benchmark Reference |
| :--- | :--- | :--- | :--- |
| **Embodied Carbon Footprint** | **${lca.carbonFootprintGPerUnit.toStringAsFixed(2)} g CO₂e** | **${lca.carbonFootprintBatchKg.toStringAsFixed(2)} kg CO₂e** | Sphera GaBi LCI Database |
| **Post-Consumer Recycled (PCR)** | ${lca.pcrPercentage.toStringAsFixed(1)}% PCR Content | ${lca.pcrCarbonReductionPct.toStringAsFixed(1)}% Carbon Abatement | Circular Economy Initiative |
| **Freshwater Consumption** | **${lca.waterFootprintLPerUnit.toStringAsFixed(2)} Liters** | **${lca.waterFootprintBatchLiters.toStringAsFixed(1)} Liters** | ISO 14046 Water Footprint |
| **Solid Packaging Waste** | **${lca.unitWasteGrams.toStringAsFixed(2)} g** | **${lca.totalBatchWasteKg.toStringAsFixed(2)} kg** | End-of-Life Mass Balance |
| **Material Circularity Index (MCI)** | **${lca.circularityIndexMci.toStringAsFixed(2)} / 1.00** | — | Ellen MacArthur Foundation |
| **Landfill Diversion Potential** | **${lca.landfillDiversionPct.toStringAsFixed(1)}%** | — | Recovery & Composting Potential |
| **Recyclability & RIC Code** | ${lca.recyclabilityTier} (${lca.resinIdentificationCode}) | — | APR Design® Guide |

---

## 7. Converter Cost Economics Baseline
| Economic Parameter | Cost Breakdown (${cost.currency}) | Converter Notes |
| :--- | :--- | :--- |
| **Estimated Unit Packaging Cost** | **₹${cost.estimatedCostPerUnitInr.toStringAsFixed(2)} / pack** | Substrate + Conversion + Scrap |
| **Estimated Batch Production Cost** | **₹${NumberFormat('#,##0.00').format(cost.estimatedBatchCostInr)} INR** | Base volume of ${NumberFormat('#,###').format(fc.batchSizeUnits)} units |
| **Gross Material Mass per Pack** | ${cost.grossMaterialMassGrams.toStringAsFixed(2)} grams | Including pouch gussets & seal seams |
| **Total Batch Substrate Required** | ${cost.grossMaterialMassBatchKg.toStringAsFixed(2)} kg film | Ready for converter extrusion/slitting |
| **Pouch Blank Surface Area** | ${cost.filmSurfaceAreaSqm.toStringAsFixed(4)} m² | Web width calculation basis |

---

## 8. Regulatory Compliance, Standards & Citations
$citationsMd
''';
  }
}
