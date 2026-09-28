import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/analytics_model.dart';

void main() {
  group('AnalyticsDateFilter Enum Tests', () {
    test('Verify filter codes and fallback parsing', () {
      expect(AnalyticsDateFilter.fromCode('7D'), AnalyticsDateFilter.last7Days);
      expect(AnalyticsDateFilter.fromCode('30D'), AnalyticsDateFilter.last30Days);
      expect(AnalyticsDateFilter.fromCode('90D'), AnalyticsDateFilter.last90Days);
      expect(AnalyticsDateFilter.fromCode('1Y'), AnalyticsDateFilter.last1Year);
      expect(AnalyticsDateFilter.fromCode('ALL'), AnalyticsDateFilter.allTime);
      expect(AnalyticsDateFilter.fromCode(null), AnalyticsDateFilter.allTime);
      expect(AnalyticsDateFilter.fromCode('INVALID'), AnalyticsDateFilter.allTime);
    });
  });

  group('KpiSummaryMetricsModel Tests', () {
    test('Default values match platform benchmark specifications', () {
      const kpis = KpiSummaryMetricsModel();
      expect(kpis.totalAnalyses, 1245);
      expect(kpis.uniqueFoodCommodities, 42);
      expect(kpis.packagingMaterialsCount, 18);
      expect(kpis.totalRecommendations, 1245);
      expect(kpis.ecoAdoptionRate, 41.2);
      expect(kpis.avgShelfLifeExtensionPct, 168.5);
      expect(kpis.momAnalysisGrowthPct, 18.4);

      expect(kpis.formattedTotalAnalyses, '1,245');
      expect(kpis.formattedCommodities, '42');
      expect(kpis.formattedMaterials, '18');
      expect(kpis.formattedRecommendations, '1,245');
      expect(kpis.formattedEcoRate, '41.2%');
      expect(kpis.formattedShelfLifeExt, '+169%');
      expect(kpis.formattedGrowth, '+18.4%');
    });

    test('Json roundtrip serialization', () {
      final json = {
        'total_analyses': 3500,
        'unique_food_commodities': 50,
        'packaging_materials_count': 22,
        'total_recommendations': 3500,
        'eco_adoption_rate': 62.5,
        'avg_shelf_life_extension_pct': 195.0,
        'mom_analysis_growth_pct': -2.5,
      };

      final model = KpiSummaryMetricsModel.fromJson(json);
      expect(model.totalAnalyses, 3500);
      expect(model.formattedTotalAnalyses, '3,500');
      expect(model.formattedGrowth, '-2.5%');

      final exported = model.toJson();
      expect(exported['total_analyses'], 3500);
      expect(exported['eco_adoption_rate'], 62.5);
    });
  });

  group('MostAnalyzedFoods Models Tests', () {
    test('Item and Response deserialization', () {
      final json = {
        'total_volume': 500,
        'items': [
          {
            'food_id': 1,
            'food_name': 'Alphonso Mango',
            'food_category': 'Fruits & Berries',
            'analysis_count': 184,
            'percentage_share': 36.8,
            'cumulative_pareto_pct': 36.8,
            'shelf_life_extension_days': 14.5,
          }
        ],
        'pareto_80_cutoff_index': 0,
      };

      final response = MostAnalyzedFoodsResponseModel.fromJson(json);
      expect(response.totalVolume, 500);
      expect(response.items.length, 1);
      expect(response.items.first.foodName, 'Alphonso Mango');
      expect(response.items.first.percentageShare, 36.8);
      expect(response.pareto80CutoffIndex, 0);

      final exported = response.toJson();
      expect(exported['total_volume'], 500);
    });
  });

  group('PackagingDistribution Models Tests', () {
    test('Polymer item color resolution and response parsing', () {
      final json = {
        'total_recommendations': 1245,
        'items': [
          {
            'polymer_family': 'BREATHABLE_BIO_EMAP',
            'display_name': 'Breathable Bio-EMAP Film',
            'recommendation_count': 342,
            'percentage_share': 27.47,
            'is_eco_friendly': true,
            'dominant_application': 'Respiring Fresh Produce',
          },
          {
            'polymer_family': 'METALLIZED_BARRIER',
            'display_name': 'Metallized Barrier',
            'recommendation_count': 278,
            'percentage_share': 22.33,
            'is_eco_friendly': false,
            'dominant_application': 'Crisps & Snacks',
          }
        ],
        'eco_friendly_share_pct': 27.47,
        'hhi_concentration_index': 0.185,
      };

      final response = PackagingDistributionResponseModel.fromJson(json);
      expect(response.totalRecommendations, 1245);
      expect(response.items.length, 2);

      final bioItem = response.items[0];
      expect(bioItem.colorToken, const Color(0xFF10B981)); // Emerald
      expect(bioItem.isEcoFriendly, true);

      final metItem = response.items[1];
      expect(metItem.colorToken, const Color(0xFFF59E0B)); // Amber
      expect(metItem.isEcoFriendly, false);
    });
  });

  group('FoodCategoryDistribution Models Tests', () {
    test('Category item deserialization', () {
      final json = {
        'total_analyses': 420,
        'items': [
          {
            'category_name': 'Fruits & Berries',
            'commodity_count': 14,
            'analysis_count': 420,
            'percentage_share': 100.0,
            'primary_preservation_challenge': 'Ethylene decay',
            'top_prescribed_polymer': 'BREATHABLE_BIO_EMAP',
          }
        ]
      };

      final response = FoodCategoryDistributionResponseModel.fromJson(json);
      expect(response.totalAnalyses, 420);
      expect(response.items.first.categoryName, 'Fruits & Berries');
      expect(response.items.first.commodityCount, 14);
    });
  });

  group('MonthlyTrend Models Tests', () {
    test('Monthly data point and trajectory response', () {
      final json = {
        'total_period_volume': 1200,
        'avg_monthly_analyses': 100.0,
        'overall_growth_pct': 15.9,
        'time_series': [
          {
            'month_key': '2026-03',
            'month_label': 'Mar 2026',
            'year': 2026,
            'total_analyses': 115,
            'eco_friendly_count': 48,
            'conventional_count': 67,
            'mom_growth_pct': 10.6,
            'eco_share_pct': 41.74,
          }
        ]
      };

      final response = MonthlyTrendResponseModel.fromJson(json);
      expect(response.totalPeriodVolume, 1200);
      expect(response.timeSeries.length, 1);
      expect(response.timeSeries.first.monthKey, '2026-03');
      expect(response.timeSeries.first.totalAnalyses, 115);
      expect(response.timeSeries.first.ecoSharePct, 41.74);
    });
  });

  group('AnalyticsDashboardOverviewModel Composite Tests', () {
    test('Composite overview deserializes properly', () {
      final json = {
        'kpi_metrics': {
          'total_analyses': 1245,
          'unique_food_commodities': 42,
          'packaging_materials_count': 18,
          'total_recommendations': 1245,
          'eco_adoption_rate': 41.2,
          'avg_shelf_life_extension_pct': 168.5,
          'mom_analysis_growth_pct': 18.4,
        },
        'most_analyzed_foods': {
          'total_volume': 100,
          'items': [],
        },
        'packaging_distribution': {
          'total_recommendations': 100,
          'items': [],
        },
        'category_distribution': {
          'total_analyses': 100,
          'items': [],
        },
        'monthly_trends': {
          'total_period_volume': 100,
          'avg_monthly_analyses': 10.0,
          'time_series': [],
        },
        'applied_filter': 'ALL',
        'generated_at': '2026-09-27T12:00:00.000Z',
      };

      final overview = AnalyticsDashboardOverviewModel.fromJson(json);
      expect(overview.kpiMetrics.totalAnalyses, 1245);
      expect(overview.appliedFilter, AnalyticsDateFilter.allTime);
      expect(overview.generatedAt.year, 2026);

      final exported = overview.toJson();
      expect(exported['applied_filter'], 'ALL');
    });
  });
}
