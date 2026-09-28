import 'package:flutter/material.dart';

/// Recyclability classification tier for packaging materials.
enum RecyclabilityTier {
  high('High'),
  medium('Medium'),
  low('Low'),
  nonRecyclable('Non-Recyclable');

  final String label;
  const RecyclabilityTier(this.label);

  static RecyclabilityTier fromString(String? val) {
    if (val == null) return RecyclabilityTier.medium;
    final lower = val.toLowerCase();
    if (lower.contains('non') || lower.contains('not')) return RecyclabilityTier.nonRecyclable;
    if (lower.contains('high')) return RecyclabilityTier.high;
    if (lower.contains('med')) return RecyclabilityTier.medium;
    if (lower.contains('low')) return RecyclabilityTier.low;
    return RecyclabilityTier.medium;
  }

  Color get color {
    switch (this) {
      case RecyclabilityTier.high:
        return const Color(0xFF10B981); // Emerald
      case RecyclabilityTier.medium:
        return const Color(0xFFF59E0B); // Amber
      case RecyclabilityTier.low:
        return const Color(0xFFF97316); // Orange
      case RecyclabilityTier.nonRecyclable:
        return const Color(0xFFEF4444); // Rose
    }
  }

  IconData get icon {
    switch (this) {
      case RecyclabilityTier.high:
        return Icons.recycling_rounded;
      case RecyclabilityTier.medium:
        return Icons.change_circle_outlined;
      case RecyclabilityTier.low:
        return Icons.remove_circle_outline;
      case RecyclabilityTier.nonRecyclable:
        return Icons.cancel_outlined;
    }
  }
}

/// Biodegradability and industrial/home composting classification tier.
enum BiodegradabilityTier {
  high('High'),
  medium('Medium'),
  low('Low'),
  nonBiodegradable('Non-Biodegradable');

  final String label;
  const BiodegradabilityTier(this.label);

  static BiodegradabilityTier fromString(String? val) {
    if (val == null) return BiodegradabilityTier.nonBiodegradable;
    final lower = val.toLowerCase();
    if (lower.contains('non') || lower.contains('not') || lower.contains('inert')) {
      return BiodegradabilityTier.nonBiodegradable;
    }
    if (lower.contains('high') || lower.contains('home')) return BiodegradabilityTier.high;
    if (lower.contains('med') || lower.contains('indus')) return BiodegradabilityTier.medium;
    if (lower.contains('low') || lower.contains('oxo')) return BiodegradabilityTier.low;
    return BiodegradabilityTier.nonBiodegradable;
  }

  Color get color {
    switch (this) {
      case BiodegradabilityTier.high:
        return const Color(0xFF059669); // Forest Emerald
      case BiodegradabilityTier.medium:
        return const Color(0xFF10B981); // Teal/Emerald
      case BiodegradabilityTier.low:
        return const Color(0xFFF59E0B); // Amber
      case BiodegradabilityTier.nonBiodegradable:
        return const Color(0xFF64748B); // Slate
    }
  }

  IconData get icon {
    switch (this) {
      case BiodegradabilityTier.high:
        return Icons.eco_rounded;
      case BiodegradabilityTier.medium:
        return Icons.compost_rounded;
      case BiodegradabilityTier.low:
        return Icons.nature_people_outlined;
      case BiodegradabilityTier.nonBiodegradable:
        return Icons.block_flipped;
    }
  }
}

/// Reusability and multi-trip structural durability tier.
enum ReusabilityTier {
  high('High'),
  medium('Medium'),
  low('Low'),
  singleUse('Single-Use');

  final String label;
  const ReusabilityTier(this.label);

  static ReusabilityTier fromString(String? val) {
    if (val == null) return ReusabilityTier.low;
    final lower = val.toLowerCase();
    if (lower.contains('single') || lower.contains('1')) return ReusabilityTier.singleUse;
    if (lower.contains('high') || lower.contains('rigid') || lower.contains('multi')) {
      return ReusabilityTier.high;
    }
    if (lower.contains('med')) return ReusabilityTier.medium;
    if (lower.contains('low')) return ReusabilityTier.low;
    return ReusabilityTier.low;
  }

  Color get color {
    switch (this) {
      case ReusabilityTier.high:
        return const Color(0xFF0284C7); // Sky Blue
      case ReusabilityTier.medium:
        return const Color(0xFF0D9488); // Teal
      case ReusabilityTier.low:
        return const Color(0xFFF59E0B); // Amber
      case ReusabilityTier.singleUse:
        return const Color(0xFF94A3B8); // Slate Light
    }
  }

  IconData get icon {
    switch (this) {
      case ReusabilityTier.high:
        return Icons.all_inclusive_rounded;
      case ReusabilityTier.medium:
        return Icons.loop_rounded;
      case ReusabilityTier.low:
        return Icons.autorenew_rounded;
      case ReusabilityTier.singleUse:
        return Icons.flash_on_outlined;
    }
  }
}

/// Waste potential categorical severity rating.
enum WastePotentialLevel {
  veryLow('Very Low'),
  low('Low'),
  moderate('Moderate'),
  high('High'),
  veryHigh('Very High');

  final String label;
  const WastePotentialLevel(this.label);

  static WastePotentialLevel fromString(String? val) {
    if (val == null) return WastePotentialLevel.moderate;
    final lower = val.toLowerCase();
    if (lower.contains('very low')) return WastePotentialLevel.veryLow;
    if (lower.contains('very high')) return WastePotentialLevel.veryHigh;
    if (lower.contains('low')) return WastePotentialLevel.low;
    if (lower.contains('high')) return WastePotentialLevel.high;
    return WastePotentialLevel.moderate;
  }

  Color get color {
    switch (this) {
      case WastePotentialLevel.veryLow:
        return const Color(0xFF10B981);
      case WastePotentialLevel.low:
        return const Color(0xFF34D399);
      case WastePotentialLevel.moderate:
        return const Color(0xFFF59E0B);
      case WastePotentialLevel.high:
        return const Color(0xFFF97316);
      case WastePotentialLevel.veryHigh:
        return const Color(0xFFEF4444);
    }
  }
}

/// Life Cycle Assessment (LCA) environmental indicators.
class EnvironmentalIndicators {
  final double carbonFootprintKgCo2ePerUnit;
  final double carbonFootprintKgCo2eTotalBatch;
  final double waterFootprintLitersPerUnit;
  final double waterFootprintLitersTotalBatch;
  final double pcrCarbonReductionPct;
  final double embodiedEnergyMjPerKg;

  const EnvironmentalIndicators({
    required this.carbonFootprintKgCo2ePerUnit,
    required this.carbonFootprintKgCo2eTotalBatch,
    required this.waterFootprintLitersPerUnit,
    required this.waterFootprintLitersTotalBatch,
    required this.pcrCarbonReductionPct,
    required this.embodiedEnergyMjPerKg,
  });

  factory EnvironmentalIndicators.fromJson(Map<String, dynamic> json) {
    return EnvironmentalIndicators(
      carbonFootprintKgCo2ePerUnit: (json['carbon_footprint_kg_co2e_per_unit'] as num?)?.toDouble() ?? 0.0,
      carbonFootprintKgCo2eTotalBatch: (json['carbon_footprint_kg_co2e_total_batch'] as num?)?.toDouble() ?? 0.0,
      waterFootprintLitersPerUnit: (json['water_footprint_liters_per_unit'] as num?)?.toDouble() ?? 0.0,
      waterFootprintLitersTotalBatch: (json['water_footprint_liters_total_batch'] as num?)?.toDouble() ?? 0.0,
      pcrCarbonReductionPct: (json['pcr_carbon_reduction_pct'] as num?)?.toDouble() ?? 0.0,
      embodiedEnergyMjPerKg: (json['embodied_energy_mj_per_kg'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'carbon_footprint_kg_co2e_per_unit': carbonFootprintKgCo2ePerUnit,
    'carbon_footprint_kg_co2e_total_batch': carbonFootprintKgCo2eTotalBatch,
    'water_footprint_liters_per_unit': waterFootprintLitersPerUnit,
    'water_footprint_liters_total_batch': waterFootprintLitersTotalBatch,
    'pcr_carbon_reduction_pct': pcrCarbonReductionPct,
    'embodied_energy_mj_per_kg': embodiedEnergyMjPerKg,
  };
}

/// Packaging waste potential and circularity metrics.
class PackagingWasteInfo {
  final double unitWasteGrams;
  final double totalBatchWasteKg;
  final WastePotentialLevel wastePotentialLevel;
  final double landfillBurdenKg;
  final double diversionPotentialPct;
  final double circularityIndex;
  final String primaryDisposalPathway;

  const PackagingWasteInfo({
    required this.unitWasteGrams,
    required this.totalBatchWasteKg,
    required this.wastePotentialLevel,
    required this.landfillBurdenKg,
    required this.diversionPotentialPct,
    required this.circularityIndex,
    required this.primaryDisposalPathway,
  });

  factory PackagingWasteInfo.fromJson(Map<String, dynamic> json) {
    return PackagingWasteInfo(
      unitWasteGrams: (json['unit_waste_grams'] as num?)?.toDouble() ?? 0.0,
      totalBatchWasteKg: (json['total_batch_waste_kg'] as num?)?.toDouble() ?? 0.0,
      wastePotentialLevel: WastePotentialLevel.fromString(json['waste_potential_level'] as String?),
      landfillBurdenKg: (json['landfill_burden_kg'] as num?)?.toDouble() ?? 0.0,
      diversionPotentialPct: (json['diversion_potential_pct'] as num?)?.toDouble() ?? 0.0,
      circularityIndex: (json['circularity_index'] as num?)?.toDouble() ?? 0.5,
      primaryDisposalPathway: json['primary_disposal_pathway'] as String? ?? 'Mechanical Recycling',
    );
  }

  Map<String, dynamic> toJson() => {
    'unit_waste_grams': unitWasteGrams,
    'total_batch_waste_kg': totalBatchWasteKg,
    'waste_potential_level': wastePotentialLevel.label,
    'landfill_burden_kg': landfillBurdenKg,
    'diversion_potential_pct': diversionPotentialPct,
    'circularity_index': circularityIndex,
    'primary_disposal_pathway': primaryDisposalPathway,
  };
}

/// Master Sustainability Profile model with verified empirical data.
class SustainabilityProfile {
  final String materialId;
  final String materialName;
  final String category;
  final String polymerFamily;
  final String resinIdentificationCode;
  final RecyclabilityTier recyclability;
  final String recyclabilityNotes;
  final BiodegradabilityTier biodegradability;
  final String? biodegradabilityStandard;
  final String biodegradabilityNotes;
  final ReusabilityTier reusability;
  final int reusabilityCycles;
  final String materialTypeDescription;
  final double pcrContentPct;
  final double bioBasedContentPct;
  final List<String> environmentalConsiderations;
  final List<String> regulatoryCertifications;
  final EnvironmentalIndicators environmentalIndicators;
  final PackagingWasteInfo wastePotential;
  final String verifiedDataSource;
  final String sourceDoiOrStandard;
  final bool isEmpiricalVerified;

  const SustainabilityProfile({
    required this.materialId,
    required this.materialName,
    required this.category,
    required this.polymerFamily,
    required this.resinIdentificationCode,
    required this.recyclability,
    required this.recyclabilityNotes,
    required this.biodegradability,
    this.biodegradabilityStandard,
    required this.biodegradabilityNotes,
    required this.reusability,
    required this.reusabilityCycles,
    required this.materialTypeDescription,
    required this.pcrContentPct,
    required this.bioBasedContentPct,
    required this.environmentalConsiderations,
    required this.regulatoryCertifications,
    required this.environmentalIndicators,
    required this.wastePotential,
    required this.verifiedDataSource,
    required this.sourceDoiOrStandard,
    this.isEmpiricalVerified = true,
  });

  factory SustainabilityProfile.fromJson(Map<String, dynamic> json) {
    return SustainabilityProfile(
      materialId: json['material_id'] as String? ?? 'unknown',
      materialName: json['material_name'] as String? ?? 'Packaging Material',
      category: json['category'] as String? ?? 'Commercial Polymer',
      polymerFamily: json['polymer_family'] as String? ?? 'POLYOLEFIN',
      resinIdentificationCode: json['resin_identification_code'] as String? ?? 'RIC 7',
      recyclability: RecyclabilityTier.fromString(json['recyclability'] as String?),
      recyclabilityNotes: json['recyclability_notes'] as String? ?? '',
      biodegradability: BiodegradabilityTier.fromString(json['biodegradability'] as String?),
      biodegradabilityStandard: json['biodegradability_standard'] as String?,
      biodegradabilityNotes: json['biodegradability_notes'] as String? ?? '',
      reusability: ReusabilityTier.fromString(json['reusability'] as String?),
      reusabilityCycles: (json['reusability_cycles'] as num?)?.toInt() ?? 1,
      materialTypeDescription: json['material_type_description'] as String? ?? '',
      pcrContentPct: (json['pcr_content_pct'] as num?)?.toDouble() ?? 0.0,
      bioBasedContentPct: (json['bio_based_content_pct'] as num?)?.toDouble() ?? 0.0,
      environmentalConsiderations: (json['environmental_considerations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      regulatoryCertifications: (json['regulatory_certifications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      environmentalIndicators: EnvironmentalIndicators.fromJson(
        json['environmental_indicators'] as Map<String, dynamic>? ?? {},
      ),
      wastePotential: PackagingWasteInfo.fromJson(
        json['waste_potential'] as Map<String, dynamic>? ?? {},
      ),
      verifiedDataSource: json['verified_data_source'] as String? ?? 'Verified Empirical LCI',
      sourceDoiOrStandard: json['source_doi_or_standard'] as String? ?? 'ISO 14040/14044',
      isEmpiricalVerified: json['is_empirical_verified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'material_id': materialId,
    'material_name': materialName,
    'category': category,
    'polymer_family': polymerFamily,
    'resin_identification_code': resinIdentificationCode,
    'recyclability': recyclability.label,
    'recyclability_notes': recyclabilityNotes,
    'biodegradability': biodegradability.label,
    'biodegradability_standard': biodegradabilityStandard,
    'biodegradability_notes': biodegradabilityNotes,
    'reusability': reusability.label,
    'reusability_cycles': reusabilityCycles,
    'material_type_description': materialTypeDescription,
    'pcr_content_pct': pcrContentPct,
    'bio_based_content_pct': bioBasedContentPct,
    'environmental_considerations': environmentalConsiderations,
    'regulatory_certifications': regulatoryCertifications,
    'environmental_indicators': environmentalIndicators.toJson(),
    'waste_potential': wastePotential.toJson(),
    'verified_data_source': verifiedDataSource,
    'source_doi_or_standard': sourceDoiOrStandard,
    'is_empirical_verified': isEmpiricalVerified,
  };
}

/// Request parameters for evaluating sustainability.
class SustainabilityEvaluateInput {
  final String materialId;
  final String? materialName;
  final String packageType;
  final double lengthCm;
  final double widthCm;
  final double depthOrGussetCm;
  final double thicknessMicrons;
  final int batchSizeUnits;
  final double pcrPercentage;

  const SustainabilityEvaluateInput({
    required this.materialId,
    this.materialName,
    this.packageType = 'Stand-up Doypack (Bottom Gusset)',
    this.lengthCm = 18.0,
    this.widthCm = 12.0,
    this.depthOrGussetCm = 4.0,
    this.thicknessMicrons = 50.0,
    this.batchSizeUnits = 10000,
    this.pcrPercentage = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'material_id': materialId,
    if (materialName != null) 'material_name': materialName,
    'package_type': packageType,
    'length_cm': lengthCm,
    'width_cm': widthCm,
    'depth_or_gusset_cm': depthOrGussetCm,
    'thickness_microns': thicknessMicrons,
    'batch_size_units': batchSizeUnits,
    'pcr_percentage': pcrPercentage,
  };
}

/// Response model for comparing multiple packaging materials.
class SustainabilityCompareResult {
  final List<SustainabilityProfile> materials;
  final String bestRecyclabilityMaterialId;
  final String lowestCarbonMaterialId;
  final String lowestWasteMaterialId;
  final String ecoTradeoffSummary;

  const SustainabilityCompareResult({
    required this.materials,
    required this.bestRecyclabilityMaterialId,
    required this.lowestCarbonMaterialId,
    required this.lowestWasteMaterialId,
    required this.ecoTradeoffSummary,
  });

  factory SustainabilityCompareResult.fromJson(Map<String, dynamic> json) {
    return SustainabilityCompareResult(
      materials: (json['materials'] as List<dynamic>?)
              ?.map((m) => SustainabilityProfile.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      bestRecyclabilityMaterialId: json['best_recyclability_material_id'] as String? ?? '',
      lowestCarbonMaterialId: json['lowest_carbon_material_id'] as String? ?? '',
      lowestWasteMaterialId: json['lowest_waste_material_id'] as String? ?? '',
      ecoTradeoffSummary: json['eco_tradeoff_summary'] as String? ?? '',
    );
  }
}
