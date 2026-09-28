import 'package:flutter/material.dart';

/// Identifier and UI styling tokens for the 3 comparison slots.
enum ComparisonSlotId {
  materialA('material_a', 'Material A', Color(0xFF0D9488)), // Teal 600
  materialB('material_b', 'Material B', Color(0xFF0284C7)), // Sky 600
  materialC('material_c', 'Material C', Color(0xFFD97706)); // Amber 600

  final String id;
  final String label;
  final Color accentColor;

  const ComparisonSlotId(this.id, this.label, this.accentColor);

  static ComparisonSlotId fromId(String id) {
    return ComparisonSlotId.values.firstWhere(
      (slot) => slot.id == id.toLowerCase(),
      orElse: () => ComparisonSlotId.materialA,
    );
  }

  static ComparisonSlotId fromIndex(int index) {
    if (index == 0) return ComparisonSlotId.materialA;
    if (index == 1) return ComparisonSlotId.materialB;
    return ComparisonSlotId.materialC;
  }
}

/// Detailed specification for a material placed in a comparison slot.
class MaterialComparisonSlot {
  final String slotId; // 'material_a', 'material_b', 'material_c'
  final String materialId;
  final String name;
  final String category;
  final String polymerFamily;
  final String structure;
  final Color colorToken;
  final bool isPrimaryRecommendation;

  // 6 Standard Qualitative Parameters
  final String moistureBarrier; // 'High', 'Medium', 'Low', 'Hermetic'
  final String oxygenBarrier; // 'High', 'Medium', 'Low', 'Hermetic'
  final String gasExchange; // 'High', 'Medium', 'Low', 'Controlled'
  final String strength; // 'High', 'Medium', 'Low', 'Rigid'
  final String recyclability; // 'Yes', 'No', 'Biodegradable', 'Home Compostable'
  final String costCategory; // 'Low', 'Medium', 'High', 'Premium'

  // Quantitative Metrics
  final double wvtrValue;
  final double otrValue;
  final double tensileStrengthMpa;
  final double estimatedCostInr;
  final double sustainabilityScore;

  // Food Context Preservation Ratings (Optional)
  final double? suitabilityScore;
  final String? suitabilityCategory;
  final int? starRating;

  const MaterialComparisonSlot({
    required this.slotId,
    required this.materialId,
    required this.name,
    required this.category,
    required this.polymerFamily,
    required this.structure,
    required this.colorToken,
    this.isPrimaryRecommendation = false,
    required this.moistureBarrier,
    required this.oxygenBarrier,
    required this.gasExchange,
    required this.strength,
    required this.recyclability,
    required this.costCategory,
    required this.wvtrValue,
    required this.otrValue,
    required this.tensileStrengthMpa,
    required this.estimatedCostInr,
    required this.sustainabilityScore,
    this.suitabilityScore,
    this.suitabilityCategory,
    this.starRating,
  });

  String get slotLabel {
    if (slotId == 'material_a') return 'Material A';
    if (slotId == 'material_b') return 'Material B';
    return 'Material C';
  }

  factory MaterialComparisonSlot.fromJson(Map<String, dynamic> json) {
    final slotId = json['slot_id'] as String? ?? 'material_a';
    final colorHex = json['color_token'] as String?;
    Color color = ComparisonSlotId.fromId(slotId).accentColor;

    if (colorHex != null && colorHex.startsWith('#') && colorHex.length == 7) {
      try {
        final hexValue = int.parse(colorHex.substring(1), radix: 16);
        color = Color(0xFF000000 | hexValue);
      } catch (_) {}
    }

    return MaterialComparisonSlot(
      slotId: slotId,
      materialId: json['material_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Material',
      category: json['category'] as String? ?? 'Packaging Material',
      polymerFamily: json['polymer_family'] as String? ?? 'POLYMERIC',
      structure: json['structure'] as String? ?? 'Film Structure',
      colorToken: color,
      isPrimaryRecommendation: json['is_primary_recommendation'] as bool? ?? false,
      moistureBarrier: json['moisture_barrier'] as String? ?? 'Medium',
      oxygenBarrier: json['oxygen_barrier'] as String? ?? 'Medium',
      gasExchange: json['gas_exchange'] as String? ?? 'Medium',
      strength: json['strength'] as String? ?? 'Medium',
      recyclability: json['recyclability'] as String? ?? 'Yes',
      costCategory: json['cost_category'] as String? ?? 'Medium',
      wvtrValue: (json['wvtr_value'] as num?)?.toDouble() ?? 10.0,
      otrValue: (json['otr_value'] as num?)?.toDouble() ?? 500.0,
      tensileStrengthMpa: (json['tensile_strength_mpa'] as num?)?.toDouble() ?? 25.0,
      estimatedCostInr: (json['estimated_cost_inr'] as num?)?.toDouble() ?? 3.50,
      sustainabilityScore: (json['sustainability_score'] as num?)?.toDouble() ?? 75.0,
      suitabilityScore: (json['suitability_score'] as num?)?.toDouble(),
      suitabilityCategory: json['suitability_category'] as String?,
      starRating: json['star_rating'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slot_id': slotId,
      'material_id': materialId,
      'name': name,
      'category': category,
      'polymer_family': polymerFamily,
      'structure': structure,
      'color_token': '#${colorToken.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      'is_primary_recommendation': isPrimaryRecommendation,
      'moisture_barrier': moistureBarrier,
      'oxygen_barrier': oxygenBarrier,
      'gas_exchange': gasExchange,
      'strength': strength,
      'recyclability': recyclability,
      'cost_category': costCategory,
      'wvtr_value': wvtrValue,
      'otr_value': otrValue,
      'tensile_strength_mpa': tensileStrengthMpa,
      'estimated_cost_inr': estimatedCostInr,
      'sustainability_score': sustainabilityScore,
      'suitability_score': suitabilityScore,
      'suitability_category': suitabilityCategory,
      'star_rating': starRating,
    };
  }
}

/// Structured parameter row for the comparison matrix table.
class ComparisonParameterRowModel {
  final String parameterKey;
  final String parameterLabel;
  final String parameterGroup;
  final String? unit;
  final Map<String, String> values; // slotId -> display value ('High', 'Medium', etc.)
  final Map<String, double>? rawNumericValues; // slotId -> raw numeric
  final String? bestSlotId;
  final String? scientificNote;

  const ComparisonParameterRowModel({
    required this.parameterKey,
    required this.parameterLabel,
    required this.parameterGroup,
    this.unit,
    required this.values,
    this.rawNumericValues,
    this.bestSlotId,
    this.scientificNote,
  });

  factory ComparisonParameterRowModel.fromJson(Map<String, dynamic> json) {
    final valuesRaw = json['values'] as Map<String, dynamic>? ?? {};
    final Map<String, String> values = valuesRaw.map((k, v) => MapEntry(k, v.toString()));

    Map<String, double>? numericMap;
    if (json['raw_numeric_values'] is Map) {
      final rawNums = json['raw_numeric_values'] as Map<String, dynamic>;
      numericMap = rawNums.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }

    return ComparisonParameterRowModel(
      parameterKey: json['parameter_key'] as String? ?? '',
      parameterLabel: json['parameter_label'] as String? ?? '',
      parameterGroup: json['parameter_group'] as String? ?? 'General',
      unit: json['unit'] as String?,
      values: values,
      rawNumericValues: numericMap,
      bestSlotId: json['best_slot_id'] as String?,
      scientificNote: json['scientific_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter_key': parameterKey,
      'parameter_label': parameterLabel,
      'parameter_group': parameterGroup,
      'unit': unit,
      'values': values,
      'raw_numeric_values': rawNumericValues,
      'best_slot_id': bestSlotId,
      'scientific_note': scientificNote,
    };
  }
}

/// Full multi-material packaging comparison response model.
class PackagingComparisonResultModel {
  final String comparisonId;
  final String? foodContextName;
  final List<MaterialComparisonSlot> slots;
  final List<ComparisonParameterRowModel> parameterRows;
  final Map<String, String> bestInClassSummary;
  final String aiTradeOffSynthesis;
  final String keyRecommendationRule;

  const PackagingComparisonResultModel({
    required this.comparisonId,
    this.foodContextName,
    required this.slots,
    required this.parameterRows,
    required this.bestInClassSummary,
    required this.aiTradeOffSynthesis,
    required this.keyRecommendationRule,
  });

  factory PackagingComparisonResultModel.fromJson(Map<String, dynamic> json) {
    final slotsRaw = json['slots'] as List<dynamic>? ?? [];
    final List<MaterialComparisonSlot> slots =
        slotsRaw.map((s) => MaterialComparisonSlot.fromJson(s as Map<String, dynamic>)).toList();

    final rowsRaw = json['parameter_rows'] as List<dynamic>? ?? [];
    final List<ComparisonParameterRowModel> rows =
        rowsRaw.map((r) => ComparisonParameterRowModel.fromJson(r as Map<String, dynamic>)).toList();

    final bestRaw = json['best_in_class_summary'] as Map<String, dynamic>? ?? {};
    final Map<String, String> bestSummary = bestRaw.map((k, v) => MapEntry(k, v.toString()));

    return PackagingComparisonResultModel(
      comparisonId: json['comparison_id'] as String? ?? 'cmp_local',
      foodContextName: json['food_context_name'] as String?,
      slots: slots,
      parameterRows: rows,
      bestInClassSummary: bestSummary,
      aiTradeOffSynthesis: json['ai_trade_off_synthesis'] as String? ??
          'Side-by-side technical evaluation across moisture barrier, gas exchange, strength, and unit cost.',
      keyRecommendationRule: json['key_recommendation_rule'] as String? ??
          'Evaluate trade-offs between barrier protection and unit procurement cost.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comparison_id': comparisonId,
      'food_context_name': foodContextName,
      'slots': slots.map((s) => s.toJson()).toList(),
      'parameter_rows': parameterRows.map((r) => r.toJson()).toList(),
      'best_in_class_summary': bestInClassSummary,
      'ai_trade_off_synthesis': aiTradeOffSynthesis,
      'key_recommendation_rule': keyRecommendationRule,
    };
  }
}
