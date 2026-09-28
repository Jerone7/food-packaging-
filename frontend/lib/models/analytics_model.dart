import 'package:flutter/material.dart';

// ==========================================
// 1. Enums & Date Range Filter
// ==========================================

enum AnalyticsDateFilter {
  last7Days('7D', '7 Days'),
  last30Days('30D', '30 Days'),
  last90Days('90D', '90 Days'),
  last1Year('1Y', '1 Year'),
  allTime('ALL', 'All Time');

  final String code;
  final String label;

  const AnalyticsDateFilter(this.code, this.label);

  static AnalyticsDateFilter fromCode(String? code) {
    switch (code) {
      case '7D':
        return AnalyticsDateFilter.last7Days;
      case '30D':
        return AnalyticsDateFilter.last30Days;
      case '90D':
        return AnalyticsDateFilter.last90Days;
      case '1Y':
        return AnalyticsDateFilter.last1Year;
      case 'ALL':
      default:
        return AnalyticsDateFilter.allTime;
    }
  }
}

// ==========================================
// 2. Key Performance Indicators (KPIs)
// ==========================================

@immutable
class KpiSummaryMetricsModel {
  final int totalAnalyses;
  final int uniqueFoodCommodities;
  final int packagingMaterialsCount;
  final int totalRecommendations;
  final double ecoAdoptionRate;
  final double avgShelfLifeExtensionPct;
  final double momAnalysisGrowthPct;

  const KpiSummaryMetricsModel({
    this.totalAnalyses = 1245,
    this.uniqueFoodCommodities = 42,
    this.packagingMaterialsCount = 18,
    this.totalRecommendations = 1245,
    this.ecoAdoptionRate = 41.2,
    this.avgShelfLifeExtensionPct = 168.5,
    this.momAnalysisGrowthPct = 18.4,
  });

  String get formattedTotalAnalyses => _formatNumber(totalAnalyses);
  String get formattedCommodities => uniqueFoodCommodities.toString();
  String get formattedMaterials => packagingMaterialsCount.toString();
  String get formattedRecommendations => _formatNumber(totalRecommendations);
  String get formattedEcoRate => '${ecoAdoptionRate.toStringAsFixed(1)}%';
  String get formattedShelfLifeExt => '+${avgShelfLifeExtensionPct.toStringAsFixed(0)}%';
  String get formattedGrowth => '${momAnalysisGrowthPct >= 0 ? '+' : ''}${momAnalysisGrowthPct.toStringAsFixed(1)}%';

  static String _formatNumber(int number) {
    if (number >= 1000) {
      final whole = number ~/ 1000;
      final remainder = (number % 1000).toString().padLeft(3, '0');
      return '$whole,$remainder';
    }
    return number.toString();
  }

  factory KpiSummaryMetricsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KpiSummaryMetricsModel();
    return KpiSummaryMetricsModel(
      totalAnalyses: json['total_analyses'] as int? ?? json['totalAnalyses'] as int? ?? 1245,
      uniqueFoodCommodities: json['unique_food_commodities'] as int? ?? json['uniqueFoodCommodities'] as int? ?? 42,
      packagingMaterialsCount: json['packaging_materials_count'] as int? ?? json['packagingMaterialsCount'] as int? ?? 18,
      totalRecommendations: json['total_recommendations'] as int? ?? json['totalRecommendations'] as int? ?? 1245,
      ecoAdoptionRate: (json['eco_adoption_rate'] as num? ?? json['ecoAdoptionRate'] as num? ?? 41.2).toDouble(),
      avgShelfLifeExtensionPct: (json['avg_shelf_life_extension_pct'] as num? ?? json['avgShelfLifeExtensionPct'] as num? ?? 168.5).toDouble(),
      momAnalysisGrowthPct: (json['mom_analysis_growth_pct'] as num? ?? json['momAnalysisGrowthPct'] as num? ?? 18.4).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_analyses': totalAnalyses,
        'unique_food_commodities': uniqueFoodCommodities,
        'packaging_materials_count': packagingMaterialsCount,
        'total_recommendations': totalRecommendations,
        'eco_adoption_rate': ecoAdoptionRate,
        'avg_shelf_life_extension_pct': avgShelfLifeExtensionPct,
        'mom_analysis_growth_pct': momAnalysisGrowthPct,
      };
}

// ==========================================
// 3. Chart 1: Most Analyzed Foods
// ==========================================

@immutable
class MostAnalyzedFoodItemModel {
  final int foodId;
  final String foodName;
  final String foodCategory;
  final int analysisCount;
  final double percentageShare;
  final double cumulativeParetoPct;
  final double shelfLifeExtensionDays;

  const MostAnalyzedFoodItemModel({
    required this.foodId,
    required this.foodName,
    required this.foodCategory,
    required this.analysisCount,
    required this.percentageShare,
    this.cumulativeParetoPct = 0.0,
    this.shelfLifeExtensionDays = 0.0,
  });

  factory MostAnalyzedFoodItemModel.fromJson(Map<String, dynamic> json) {
    return MostAnalyzedFoodItemModel(
      foodId: json['food_id'] as int? ?? json['foodId'] as int? ?? 0,
      foodName: json['food_name'] as String? ?? json['foodName'] as String? ?? 'Unknown Food',
      foodCategory: json['food_category'] as String? ?? json['foodCategory'] as String? ?? 'Produce',
      analysisCount: json['analysis_count'] as int? ?? json['analysisCount'] as int? ?? 0,
      percentageShare: (json['percentage_share'] as num? ?? json['percentageShare'] as num? ?? 0.0).toDouble(),
      cumulativeParetoPct: (json['cumulative_pareto_pct'] as num? ?? json['cumulativeParetoPct'] as num? ?? 0.0).toDouble(),
      shelfLifeExtensionDays: (json['shelf_life_extension_days'] as num? ?? json['shelfLifeExtensionDays'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'food_id': foodId,
        'food_name': foodName,
        'food_category': foodCategory,
        'analysis_count': analysisCount,
        'percentage_share': percentageShare,
        'cumulative_pareto_pct': cumulativeParetoPct,
        'shelf_life_extension_days': shelfLifeExtensionDays,
      };
}

@immutable
class MostAnalyzedFoodsResponseModel {
  final int totalVolume;
  final List<MostAnalyzedFoodItemModel> items;
  final int? pareto80CutoffIndex;

  const MostAnalyzedFoodsResponseModel({
    required this.totalVolume,
    required this.items,
    this.pareto80CutoffIndex,
  });

  factory MostAnalyzedFoodsResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MostAnalyzedFoodsResponseModel(totalVolume: 0, items: []);
    }
    final rawList = json['items'] as List<dynamic>? ?? [];
    final parsed = rawList
        .map((e) => MostAnalyzedFoodItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MostAnalyzedFoodsResponseModel(
      totalVolume: json['total_volume'] as int? ?? json['totalVolume'] as int? ?? 0,
      items: parsed,
      pareto80CutoffIndex: json['pareto_80_cutoff_index'] as int? ?? json['pareto80CutoffIndex'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_volume': totalVolume,
        'items': items.map((e) => e.toJson()).toList(),
        'pareto_80_cutoff_index': pareto80CutoffIndex,
      };
}

// ==========================================
// 4. Chart 2: Packaging Distribution
// ==========================================

@immutable
class PackagingDistributionItemModel {
  final String polymerFamily;
  final String displayName;
  final int recommendationCount;
  final double percentageShare;
  final bool isEcoFriendly;
  final String dominantApplication;

  const PackagingDistributionItemModel({
    required this.polymerFamily,
    required this.displayName,
    required this.recommendationCount,
    required this.percentageShare,
    this.isEcoFriendly = false,
    this.dominantApplication = '',
  });

  Color get colorToken {
    switch (polymerFamily) {
      case 'BREATHABLE_BIO_EMAP':
        return const Color(0xFF10B981); // Emerald
      case 'METALLIZED_BARRIER':
        return const Color(0xFFF59E0B); // Amber
      case 'HIGH_BARRIER_EVOH_VSP':
        return const Color(0xFF6366F1); // Indigo
      case 'CELLULOSE_KRAFT_LINED':
        return const Color(0xFF84CC16); // Lime
      case 'RECYCLABLE_POLYOLEFIN':
        return const Color(0xFF06B6D4); // Cyan
      case 'CRYOGENIC_DEEP_FREEZE':
        return const Color(0xFF3B82F6); // Blue
      case 'RETORT_ACID_BARRIER':
        return const Color(0xFFEC4899); // Pink
      default:
        return const Color(0xFF94A3B8); // Slate
    }
  }

  factory PackagingDistributionItemModel.fromJson(Map<String, dynamic> json) {
    return PackagingDistributionItemModel(
      polymerFamily: json['polymer_family'] as String? ?? json['polymerFamily'] as String? ?? 'UNKNOWN',
      displayName: json['display_name'] as String? ?? json['displayName'] as String? ?? 'Polymer Substrate',
      recommendationCount: json['recommendation_count'] as int? ?? json['recommendationCount'] as int? ?? 0,
      percentageShare: (json['percentage_share'] as num? ?? json['percentageShare'] as num? ?? 0.0).toDouble(),
      isEcoFriendly: json['is_eco_friendly'] as bool? ?? json['isEcoFriendly'] as bool? ?? false,
      dominantApplication: json['dominant_application'] as String? ?? json['dominantApplication'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'polymer_family': polymerFamily,
        'display_name': displayName,
        'recommendation_count': recommendationCount,
        'percentage_share': percentageShare,
        'is_eco_friendly': isEcoFriendly,
        'dominant_application': dominantApplication,
      };
}

@immutable
class PackagingDistributionResponseModel {
  final int totalRecommendations;
  final List<PackagingDistributionItemModel> items;
  final double ecoFriendlySharePct;
  final double hhiConcentrationIndex;

  const PackagingDistributionResponseModel({
    required this.totalRecommendations,
    required this.items,
    this.ecoFriendlySharePct = 0.0,
    this.hhiConcentrationIndex = 0.0,
  });

  factory PackagingDistributionResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PackagingDistributionResponseModel(totalRecommendations: 0, items: []);
    }
    final rawList = json['items'] as List<dynamic>? ?? [];
    final parsed = rawList
        .map((e) => PackagingDistributionItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PackagingDistributionResponseModel(
      totalRecommendations: json['total_recommendations'] as int? ?? json['totalRecommendations'] as int? ?? 0,
      items: parsed,
      ecoFriendlySharePct: (json['eco_friendly_share_pct'] as num? ?? json['ecoFriendlySharePct'] as num? ?? 0.0).toDouble(),
      hhiConcentrationIndex: (json['hhi_concentration_index'] as num? ?? json['hhiConcentrationIndex'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_recommendations': totalRecommendations,
        'items': items.map((e) => e.toJson()).toList(),
        'eco_friendly_share_pct': ecoFriendlySharePct,
        'hhi_concentration_index': hhiConcentrationIndex,
      };
}

// ==========================================
// 5. Chart 3: Food Category Distribution
// ==========================================

@immutable
class FoodCategoryDistributionItemModel {
  final String categoryName;
  final int commodityCount;
  final int analysisCount;
  final double percentageShare;
  final String primaryPreservationChallenge;
  final String topPrescribedPolymer;

  const FoodCategoryDistributionItemModel({
    required this.categoryName,
    required this.commodityCount,
    required this.analysisCount,
    required this.percentageShare,
    this.primaryPreservationChallenge = '',
    this.topPrescribedPolymer = '',
  });

  factory FoodCategoryDistributionItemModel.fromJson(Map<String, dynamic> json) {
    return FoodCategoryDistributionItemModel(
      categoryName: json['category_name'] as String? ?? json['categoryName'] as String? ?? 'Category',
      commodityCount: json['commodity_count'] as int? ?? json['commodityCount'] as int? ?? 0,
      analysisCount: json['analysis_count'] as int? ?? json['analysisCount'] as int? ?? 0,
      percentageShare: (json['percentage_share'] as num? ?? json['percentageShare'] as num? ?? 0.0).toDouble(),
      primaryPreservationChallenge: json['primary_preservation_challenge'] as String? ?? json['primaryPreservationChallenge'] as String? ?? '',
      topPrescribedPolymer: json['top_prescribed_polymer'] as String? ?? json['topPrescribedPolymer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'category_name': categoryName,
        'commodity_count': commodityCount,
        'analysis_count': analysisCount,
        'percentage_share': percentageShare,
        'primary_preservation_challenge': primaryPreservationChallenge,
        'top_prescribed_polymer': topPrescribedPolymer,
      };
}

@immutable
class FoodCategoryDistributionResponseModel {
  final int totalAnalyses;
  final List<FoodCategoryDistributionItemModel> items;

  const FoodCategoryDistributionResponseModel({
    required this.totalAnalyses,
    required this.items,
  });

  factory FoodCategoryDistributionResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const FoodCategoryDistributionResponseModel(totalAnalyses: 0, items: []);
    }
    final rawList = json['items'] as List<dynamic>? ?? [];
    final parsed = rawList
        .map((e) => FoodCategoryDistributionItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return FoodCategoryDistributionResponseModel(
      totalAnalyses: json['total_analyses'] as int? ?? json['totalAnalyses'] as int? ?? 0,
      items: parsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_analyses': totalAnalyses,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

// ==========================================
// 6. Chart 4: Monthly Trend Data
// ==========================================

@immutable
class MonthlyTrendDataPointModel {
  final String monthKey;
  final String monthLabel;
  final int year;
  final int totalAnalyses;
  final int ecoFriendlyCount;
  final int conventionalCount;
  final double momGrowthPct;
  final double ecoSharePct;

  const MonthlyTrendDataPointModel({
    required this.monthKey,
    required this.monthLabel,
    required this.year,
    required this.totalAnalyses,
    required this.ecoFriendlyCount,
    required this.conventionalCount,
    this.momGrowthPct = 0.0,
    this.ecoSharePct = 0.0,
  });

  factory MonthlyTrendDataPointModel.fromJson(Map<String, dynamic> json) {
    return MonthlyTrendDataPointModel(
      monthKey: json['month_key'] as String? ?? json['monthKey'] as String? ?? '',
      monthLabel: json['month_label'] as String? ?? json['monthLabel'] as String? ?? '',
      year: json['year'] as int? ?? 2026,
      totalAnalyses: json['total_analyses'] as int? ?? json['totalAnalyses'] as int? ?? 0,
      ecoFriendlyCount: json['eco_friendly_count'] as int? ?? json['ecoFriendlyCount'] as int? ?? 0,
      conventionalCount: json['conventional_count'] as int? ?? json['conventionalCount'] as int? ?? 0,
      momGrowthPct: (json['mom_growth_pct'] as num? ?? json['momGrowthPct'] as num? ?? 0.0).toDouble(),
      ecoSharePct: (json['eco_share_pct'] as num? ?? json['ecoSharePct'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'month_key': monthKey,
        'month_label': monthLabel,
        'year': year,
        'total_analyses': totalAnalyses,
        'eco_friendly_count': ecoFriendlyCount,
        'conventional_count': conventionalCount,
        'mom_growth_pct': momGrowthPct,
        'eco_share_pct': ecoSharePct,
      };
}

@immutable
class MonthlyTrendResponseModel {
  final List<MonthlyTrendDataPointModel> timeSeries;
  final int totalPeriodVolume;
  final double avgMonthlyAnalyses;
  final double overallGrowthPct;

  const MonthlyTrendResponseModel({
    required this.timeSeries,
    required this.totalPeriodVolume,
    required this.avgMonthlyAnalyses,
    this.overallGrowthPct = 0.0,
  });

  factory MonthlyTrendResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MonthlyTrendResponseModel(
        timeSeries: [],
        totalPeriodVolume: 0,
        avgMonthlyAnalyses: 0.0,
      );
    }
    final rawList = json['time_series'] as List<dynamic>? ?? json['timeSeries'] as List<dynamic>? ?? [];
    final parsed = rawList
        .map((e) => MonthlyTrendDataPointModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MonthlyTrendResponseModel(
      timeSeries: parsed,
      totalPeriodVolume: json['total_period_volume'] as int? ?? json['totalPeriodVolume'] as int? ?? 0,
      avgMonthlyAnalyses: (json['avg_monthly_analyses'] as num? ?? json['avgMonthlyAnalyses'] as num? ?? 0.0).toDouble(),
      overallGrowthPct: (json['overall_growth_pct'] as num? ?? json['overallGrowthPct'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'time_series': timeSeries.map((e) => e.toJson()).toList(),
        'total_period_volume': totalPeriodVolume,
        'avg_monthly_analyses': avgMonthlyAnalyses,
        'overall_growth_pct': overallGrowthPct,
      };
}

// ==========================================
// 7. Composite Dashboard Overview Model
// ==========================================

@immutable
class AnalyticsDashboardOverviewModel {
  final KpiSummaryMetricsModel kpiMetrics;
  final MostAnalyzedFoodsResponseModel mostAnalyzedFoods;
  final PackagingDistributionResponseModel packagingDistribution;
  final FoodCategoryDistributionResponseModel categoryDistribution;
  final MonthlyTrendResponseModel monthlyTrends;
  final AnalyticsDateFilter appliedFilter;
  final DateTime generatedAt;

  const AnalyticsDashboardOverviewModel({
    required this.kpiMetrics,
    required this.mostAnalyzedFoods,
    required this.packagingDistribution,
    required this.categoryDistribution,
    required this.monthlyTrends,
    this.appliedFilter = AnalyticsDateFilter.allTime,
    required this.generatedAt,
  });

  factory AnalyticsDashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsDashboardOverviewModel(
      kpiMetrics: KpiSummaryMetricsModel.fromJson(json['kpi_metrics'] as Map<String, dynamic>?),
      mostAnalyzedFoods: MostAnalyzedFoodsResponseModel.fromJson(json['most_analyzed_foods'] as Map<String, dynamic>?),
      packagingDistribution: PackagingDistributionResponseModel.fromJson(json['packaging_distribution'] as Map<String, dynamic>?),
      categoryDistribution: FoodCategoryDistributionResponseModel.fromJson(json['category_distribution'] as Map<String, dynamic>?),
      monthlyTrends: MonthlyTrendResponseModel.fromJson(json['monthly_trends'] as Map<String, dynamic>?),
      appliedFilter: AnalyticsDateFilter.fromCode(json['applied_filter'] as String?),
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'kpi_metrics': kpiMetrics.toJson(),
        'most_analyzed_foods': mostAnalyzedFoods.toJson(),
        'packaging_distribution': packagingDistribution.toJson(),
        'category_distribution': categoryDistribution.toJson(),
        'monthly_trends': monthlyTrends.toJson(),
        'applied_filter': appliedFilter.code,
        'generated_at': generatedAt.toIso8601String(),
      };
}
