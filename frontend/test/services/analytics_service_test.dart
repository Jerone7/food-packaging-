import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/models/analytics_model.dart';
import 'package:ai_packaging_recommender/services/analytics_service.dart';
import 'package:ai_packaging_recommender/services/offline_analytics_engine.dart';

void main() {
  group('OfflineAnalyticsEngine Tests', () {
    test('getKpis returns calibrated platform values', () {
      final kpis = OfflineAnalyticsEngine.getKpis(timeFilter: AnalyticsDateFilter.allTime);
      expect(kpis.totalAnalyses, 1245);
      expect(kpis.uniqueFoodCommodities, 42);
      expect(kpis.packagingMaterialsCount, 18);
      expect(kpis.totalRecommendations, 1245);
      expect(kpis.ecoAdoptionRate, 41.2);
    });

    test('getKpis scales with 7D filter', () {
      final kpis7d = OfflineAnalyticsEngine.getKpis(timeFilter: AnalyticsDateFilter.last7Days);
      expect(kpis7d.totalAnalyses, lessThan(1245));
      expect(kpis7d.totalAnalyses, greaterThan(0));
    });

    test('getMostAnalyzedFoods returns sorted Pareto list', () {
      final res = OfflineAnalyticsEngine.getMostAnalyzedFoods(limit: 10);
      expect(res.items.length, 10);
      expect(res.items.first.foodName, 'Alphonso Mango');
      expect(res.items.last.cumulativeParetoPct, closeTo(100.0, 1.0));
      expect(res.pareto80CutoffIndex, isNotNull);
    });

    test('getPackagingDistribution includes all 7 polymer families', () {
      final res = OfflineAnalyticsEngine.getPackagingDistribution();
      expect(res.items.length, 7);
      expect(res.totalRecommendations, greaterThan(0));
      expect(res.ecoFriendlySharePct, greaterThan(0.0));
      expect(res.hhiConcentrationIndex, greaterThan(0.0));

      final families = res.items.map((e) => e.polymerFamily).toSet();
      expect(families.contains('BREATHABLE_BIO_EMAP'), isTrue);
      expect(families.contains('HIGH_BARRIER_EVOH_VSP'), isTrue);
      expect(families.contains('METALLIZED_BARRIER'), isTrue);
    });

    test('getFoodCategoryDistribution includes 6 sectors', () {
      final res = OfflineAnalyticsEngine.getFoodCategoryDistribution();
      expect(res.items.length, 6);
      expect(res.items.first.categoryName, 'Fruits & Berries');
    });

    test('getMonthlyTrends returns 12 months with correct math', () {
      final res = OfflineAnalyticsEngine.getMonthlyTrends(months: 12);
      expect(res.timeSeries.length, 12);
      for (final pt in res.timeSeries) {
        expect(pt.totalAnalyses, pt.ecoFriendlyCount + pt.conventionalCount);
      }
    });

    test('getOverview aggregates complete model', () {
      final overview = OfflineAnalyticsEngine.getOverview();
      expect(overview.kpiMetrics.totalAnalyses, 1245);
      expect(overview.mostAnalyzedFoods.items.isNotEmpty, isTrue);
      expect(overview.packagingDistribution.items.isNotEmpty, isTrue);
      expect(overview.categoryDistribution.items.isNotEmpty, isTrue);
      expect(overview.monthlyTrends.timeSeries.isNotEmpty, isTrue);
    });
  });

  group('AnalyticsService Network & Cache Tests', () {
    test('getDashboardOverview succeeds with remote mock server', () async {
      final mockJson = {
        'kpi_metrics': {
          'total_analyses': 2000,
          'unique_food_commodities': 45,
          'packaging_materials_count': 20,
          'total_recommendations': 2000,
          'eco_adoption_rate': 50.0,
          'avg_shelf_life_extension_pct': 175.0,
          'mom_analysis_growth_pct': 20.0,
        },
        'most_analyzed_foods': {
          'total_volume': 2000,
          'items': [],
        },
        'packaging_distribution': {
          'total_recommendations': 2000,
          'items': [],
        },
        'category_distribution': {
          'total_analyses': 2000,
          'items': [],
        },
        'monthly_trends': {
          'total_period_volume': 2000,
          'avg_monthly_analyses': 166.0,
          'time_series': [],
        },
        'applied_filter': 'ALL',
        'generated_at': '2026-09-27T12:00:00Z',
      };

      final client = MockClient((request) async {
        if (request.url.path.endsWith('/overview')) {
          return http.Response(json.encode(mockJson), 200, headers: {'content-type': 'application/json'});
        }
        return http.Response('Not Found', 404);
      });

      final service = AnalyticsService(client: client);
      final res = await service.getDashboardOverview();
      expect(res.kpiMetrics.totalAnalyses, 2000);

      // Verify cached call returns same object
      final cachedRes = await service.getDashboardOverview();
      expect(cachedRes.kpiMetrics.totalAnalyses, 2000);
    });

    test('getDashboardOverview falls back to OfflineAnalyticsEngine on network failure', () async {
      final client = MockClient((request) async {
        throw Exception('Connection refused');
      });

      final service = AnalyticsService(client: client);
      final res = await service.getDashboardOverview();
      expect(res.kpiMetrics.totalAnalyses, 1245);
      expect(res.mostAnalyzedFoods.items.length, 10);
    });

    test('Individual endpoint methods fall back safely', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = AnalyticsService(client: client);
      final kpis = await service.getKpiMetrics();
      expect(kpis.totalAnalyses, 1245);

      final foods = await service.getMostAnalyzedFoods();
      expect(foods.items.isNotEmpty, isTrue);

      final pkgs = await service.getPackagingDistribution();
      expect(pkgs.items.isNotEmpty, isTrue);

      final cats = await service.getFoodCategoryDistribution();
      expect(cats.items.isNotEmpty, isTrue);

      final trends = await service.getMonthlyTrends();
      expect(trends.timeSeries.isNotEmpty, isTrue);
    });
  });
}
