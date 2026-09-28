import '../models/analytics_model.dart';

/// Offline Analytics Engine (Module 17).
/// Provides calibrated benchmark data, client-side filtering, and sub-millisecond
/// offline calculations when backend network connectivity is unavailable.
class OfflineAnalyticsEngine {
  static const List<Map<String, dynamic>> _rawTopFoods = [
    {'id': 1, 'name': 'Alphonso Mango', 'category': 'Fruits & Berries', 'count': 184, 'shelf_life': 14.5},
    {'id': 2, 'name': 'Fresh Tomato', 'category': 'Vegetables', 'count': 162, 'shelf_life': 12.0},
    {'id': 3, 'name': 'Strawberries', 'category': 'Fruits & Berries', 'count': 138, 'shelf_life': 8.5},
    {'id': 4, 'name': 'Potato Chips', 'category': 'Snacks & Savory', 'count': 125, 'shelf_life': 120.0},
    {'id': 5, 'name': 'Fresh Paneer', 'category': 'Dairy & Sweets', 'count': 114, 'shelf_life': 18.0},
    {'id': 6, 'name': 'Digestive Biscuits', 'category': 'Grains & Bakery', 'count': 98, 'shelf_life': 90.0},
    {'id': 7, 'name': 'Roasted Cashews', 'category': 'Snacks & Savory', 'count': 86, 'shelf_life': 180.0},
    {'id': 8, 'name': 'Fresh Spinach', 'category': 'Vegetables', 'count': 79, 'shelf_life': 6.5},
    {'id': 9, 'name': 'Cut Apples', 'category': 'Fruits & Berries', 'count': 68, 'shelf_life': 7.0},
    {'id': 10, 'name': 'Button Mushrooms', 'category': 'Vegetables', 'count': 55, 'shelf_life': 5.5},
  ];

  static const List<Map<String, dynamic>> _rawPackaging = [
    {
      'family': 'BREATHABLE_BIO_EMAP',
      'name': 'Breathable Bio-EMAP Film',
      'count': 342,
      'eco': true,
      'app': 'Respiring Fresh Produce & Berries',
    },
    {
      'family': 'METALLIZED_BARRIER',
      'name': 'Metallized Tri-Layer Barrier (MET-PET/Al)',
      'count': 278,
      'eco': false,
      'app': 'Crisps, Snacks & Lipid-Rich Nuts',
    },
    {
      'family': 'HIGH_BARRIER_EVOH_VSP',
      'name': 'High-Barrier EVOH Vacuum Skin (VSP)',
      'count': 215,
      'eco': false,
      'app': 'Fresh Meat, Poultry & Paneer',
    },
    {
      'family': 'CELLULOSE_KRAFT_LINED',
      'name': 'PLA / Cellulose Kraft Bio-Pouch',
      'count': 172,
      'eco': true,
      'app': 'Dry Bakery, Cookies & Organic Grains',
    },
    {
      'family': 'RECYCLABLE_POLYOLEFIN',
      'name': 'Recyclable Mono-PE/PP Pouch',
      'count': 118,
      'eco': true,
      'app': 'General Dry Goods & Pulses',
    },
    {
      'family': 'CRYOGENIC_DEEP_FREEZE',
      'name': 'Cryogenic Multi-Layer Deep Freeze Film',
      'count': 68,
      'eco': false,
      'app': 'Frozen IQF Vegetables & Seafood',
    },
    {
      'family': 'RETORT_ACID_BARRIER',
      'name': 'Retort-Grade High Barrier Pouch',
      'count': 52,
      'eco': false,
      'app': 'Ready-to-Eat Curries & Acidic Sauces',
    },
  ];

  static const List<Map<String, dynamic>> _rawCategories = [
    {
      'name': 'Fruits & Berries',
      'commodities': 14,
      'count': 420,
      'challenge': 'High respiration kinetics, ethylene ripening & transpiration loss',
      'top_polymer': 'BREATHABLE_BIO_EMAP',
    },
    {
      'name': 'Vegetables & Greens',
      'commodities': 12,
      'count': 348,
      'challenge': 'Chilling sensitivity, condensation decay & enzymatic browning',
      'top_polymer': 'BREATHABLE_BIO_EMAP',
    },
    {
      'name': 'Snacks & Savory',
      'commodities': 6,
      'count': 218,
      'challenge': 'Lipid photo-oxidation, rancidity & moisture crispness loss',
      'top_polymer': 'METALLIZED_BARRIER',
    },
    {
      'name': 'Dairy & Proteins',
      'commodities': 4,
      'count': 136,
      'challenge': 'Microbial spoilage, off-flavor development & purge exudation',
      'top_polymer': 'HIGH_BARRIER_EVOH_VSP',
    },
    {
      'name': 'Grains & Bakery',
      'commodities': 4,
      'count': 85,
      'challenge': 'Staling, mold growth & insect infestation in storage',
      'top_polymer': 'CELLULOSE_KRAFT_LINED',
    },
    {
      'name': 'Processed & RTE',
      'commodities': 2,
      'count': 38,
      'challenge': 'Thermal retort stability, acid migration & seal integrity',
      'top_polymer': 'RETORT_ACID_BARRIER',
    },
  ];

  static const List<Map<String, dynamic>> _rawMonthlySeries = [
    {'key': '2025-10', 'label': 'Oct 2025', 'year': 2025, 'total': 65, 'eco': 20, 'conv': 45, 'growth': 8.3},
    {'key': '2025-11', 'label': 'Nov 2025', 'year': 2025, 'total': 72, 'eco': 24, 'conv': 48, 'growth': 10.8},
    {'key': '2025-12', 'label': 'Dec 2025', 'year': 2025, 'total': 84, 'eco': 30, 'conv': 54, 'growth': 16.7},
    {'key': '2026-01', 'label': 'Jan 2026', 'year': 2026, 'total': 92, 'eco': 35, 'conv': 57, 'growth': 9.5},
    {'key': '2026-02', 'label': 'Feb 2026', 'year': 2026, 'total': 104, 'eco': 42, 'conv': 62, 'growth': 13.0},
    {'key': '2026-03', 'label': 'Mar 2026', 'year': 2026, 'total': 115, 'eco': 48, 'conv': 67, 'growth': 10.6},
    {'key': '2026-04', 'label': 'Apr 2026', 'year': 2026, 'total': 110, 'eco': 46, 'conv': 64, 'growth': -4.3},
    {'key': '2026-05', 'label': 'May 2026', 'year': 2026, 'total': 122, 'eco': 52, 'conv': 70, 'growth': 10.9},
    {'key': '2026-06', 'label': 'Jun 2026', 'year': 2026, 'total': 130, 'eco': 56, 'conv': 74, 'growth': 6.6},
    {'key': '2026-07', 'label': 'Jul 2026', 'year': 2026, 'total': 138, 'eco': 62, 'conv': 76, 'growth': 6.2},
    {'key': '2026-08', 'label': 'Aug 2026', 'year': 2026, 'total': 145, 'eco': 68, 'conv': 77, 'growth': 5.1},
    {'key': '2026-09', 'label': 'Sep 2026', 'year': 2026, 'total': 168, 'eco': 79, 'conv': 89, 'growth': 15.9},
  ];

  static double _getScaleFactor(AnalyticsDateFilter filter) {
    switch (filter) {
      case AnalyticsDateFilter.last7Days:
        return 0.06;
      case AnalyticsDateFilter.last30Days:
        return 0.22;
      case AnalyticsDateFilter.last90Days:
        return 0.45;
      case AnalyticsDateFilter.last1Year:
        return 0.90;
      case AnalyticsDateFilter.allTime:
      default:
        return 1.0;
    }
  }

  /// Calculates KPI summary metrics with filter scaling.
  static KpiSummaryMetricsModel getKpis({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
  }) {
    final scale = _getScaleFactor(timeFilter);
    final total = (1245 * scale).round().clamp(1, 1245);

    return KpiSummaryMetricsModel(
      totalAnalyses: total,
      uniqueFoodCommodities: 42,
      packagingMaterialsCount: 18,
      totalRecommendations: total,
      ecoAdoptionRate: 41.2,
      avgShelfLifeExtensionPct: 168.5,
      momAnalysisGrowthPct: 18.4,
    );
  }

  /// Returns Pareto ranked top analyzed foods.
  static MostAnalyzedFoodsResponseModel getMostAnalyzedFoods({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
    int limit = 10,
  }) {
    final scale = _getScaleFactor(timeFilter);
    final foods = _rawTopFoods.take(limit).toList();
    final scaledCounts = foods.map((f) => ((f['count'] as int) * scale).round().clamp(1, 9999)).toList();
    final totalVol = scaledCounts.fold<int>(0, (sum, count) => sum + count);

    double cumPct = 0.0;
    final items = <MostAnalyzedFoodItemModel>[];
    int? cutoffIdx;

    for (int i = 0; i < foods.length; i++) {
      final f = foods[i];
      final count = scaledCounts[i];
      final share = totalVol > 0 ? (count / totalVol * 100.0) : 0.0;
      cumPct += share;

      if (cutoffIdx == null && cumPct >= 80.0) {
        cutoffIdx = i;
      }

      items.add(
        MostAnalyzedFoodItemModel(
          foodId: f['id'] as int,
          foodName: f['name'] as String,
          foodCategory: f['category'] as String,
          analysisCount: count,
          percentageShare: double.parse(share.toStringAsFixed(2)),
          cumulativeParetoPct: double.parse(cumPct.toStringAsFixed(2)),
          shelfLifeExtensionDays: (f['shelf_life'] as num).toDouble(),
        ),
      );
    }

    return MostAnalyzedFoodsResponseModel(
      totalVolume: totalVol,
      items: items,
      pareto80CutoffIndex: cutoffIdx ?? (items.isNotEmpty ? items.length - 1 : null),
    );
  }

  /// Returns polymer packaging distribution across 7 standardized families.
  static PackagingDistributionResponseModel getPackagingDistribution({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
  }) {
    final scale = _getScaleFactor(timeFilter);
    final scaledCounts = _rawPackaging.map((p) => ((p['count'] as int) * scale).round().clamp(1, 9999)).toList();
    final totalRecs = scaledCounts.fold<int>(0, (sum, count) => sum + count);

    int ecoCount = 0;
    double hhi = 0.0;
    final items = <PackagingDistributionItemModel>[];

    for (int i = 0; i < _rawPackaging.length; i++) {
      final p = _rawPackaging[i];
      final count = scaledCounts[i];
      final isEco = p['eco'] as bool;
      final share = totalRecs > 0 ? (count / totalRecs * 100.0) : 0.0;

      if (isEco) {
        ecoCount += count;
      }

      final normalizedShare = share / 100.0;
      hhi += (normalizedShare * normalizedShare);

      items.add(
        PackagingDistributionItemModel(
          polymerFamily: p['family'] as String,
          displayName: p['name'] as String,
          recommendationCount: count,
          percentageShare: double.parse(share.toStringAsFixed(2)),
          isEcoFriendly: isEco,
          dominantApplication: p['app'] as String,
        ),
      );
    }

    // Sort descending by recommendation count
    items.sort((a, b) => b.recommendationCount.compareTo(a.recommendationCount));
    final ecoShare = totalRecs > 0 ? (ecoCount / totalRecs * 100.0) : 0.0;

    return PackagingDistributionResponseModel(
      totalRecommendations: totalRecs,
      items: items,
      ecoFriendlySharePct: double.parse(ecoShare.toStringAsFixed(2)),
      hhiConcentrationIndex: double.parse(hhi.toStringAsFixed(4)),
    );
  }

  /// Returns food category breakdown across 6 taxonomy groups.
  static FoodCategoryDistributionResponseModel getFoodCategoryDistribution({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
  }) {
    final scale = _getScaleFactor(timeFilter);
    final scaledCounts = _rawCategories.map((c) => ((c['count'] as int) * scale).round().clamp(1, 9999)).toList();
    final totalAnalyses = scaledCounts.fold<int>(0, (sum, count) => sum + count);

    final items = <FoodCategoryDistributionItemModel>[];

    for (int i = 0; i < _rawCategories.length; i++) {
      final c = _rawCategories[i];
      final count = scaledCounts[i];
      final share = totalAnalyses > 0 ? (count / totalAnalyses * 100.0) : 0.0;

      items.add(
        FoodCategoryDistributionItemModel(
          categoryName: c['name'] as String,
          commodityCount: c['commodities'] as int,
          analysisCount: count,
          percentageShare: double.parse(share.toStringAsFixed(2)),
          primaryPreservationChallenge: c['challenge'] as String,
          topPrescribedPolymer: c['top_polymer'] as String,
        ),
      );
    }

    items.sort((a, b) => b.analysisCount.compareTo(a.analysisCount));

    return FoodCategoryDistributionResponseModel(
      totalAnalyses: totalAnalyses,
      items: items,
    );
  }

  /// Returns 12-month analysis volume and sustainability trajectory.
  static MonthlyTrendResponseModel getMonthlyTrends({int months = 12}) {
    final series = _rawMonthlySeries.reversed.take(months).toList().reversed.toList();
    final items = <MonthlyTrendDataPointModel>[];
    int totalVol = 0;

    for (final pt in series) {
      final tot = pt['total'] as int;
      totalVol += tot;
      final eco = pt['eco'] as int;
      final conv = pt['conv'] as int;
      final ecoShare = tot > 0 ? (eco / tot * 100.0) : 0.0;

      items.add(
        MonthlyTrendDataPointModel(
          monthKey: pt['key'] as String,
          monthLabel: pt['label'] as String,
          year: pt['year'] as int,
          totalAnalyses: tot,
          ecoFriendlyCount: eco,
          conventionalCount: conv,
          momGrowthPct: (pt['growth'] as num).toDouble(),
          ecoSharePct: double.parse(ecoShare.toStringAsFixed(2)),
        ),
      );
    }

    final avgVol = items.isNotEmpty ? (totalVol / items.length) : 0.0;
    final firstVal = items.isNotEmpty ? items.first.totalAnalyses : 1;
    final lastVal = items.isNotEmpty ? items.last.totalAnalyses : 1;
    final overallGrowth = firstVal > 0 ? ((lastVal - firstVal) / firstVal * 100.0) : 0.0;

    return MonthlyTrendResponseModel(
      timeSeries: items,
      totalPeriodVolume: totalVol,
      avgMonthlyAnalyses: double.parse(avgVol.toStringAsFixed(1)),
      overallGrowthPct: double.parse(overallGrowth.toStringAsFixed(1)),
    );
  }

  /// Returns the complete composite dashboard overview.
  static AnalyticsDashboardOverviewModel getOverview({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
  }) {
    return AnalyticsDashboardOverviewModel(
      kpiMetrics: getKpis(timeFilter: timeFilter),
      mostAnalyzedFoods: getMostAnalyzedFoods(timeFilter: timeFilter),
      packagingDistribution: getPackagingDistribution(timeFilter: timeFilter),
      categoryDistribution: getFoodCategoryDistribution(timeFilter: timeFilter),
      monthlyTrends: getMonthlyTrends(),
      appliedFilter: timeFilter,
      generatedAt: DateTime.now(),
    );
  }
}
