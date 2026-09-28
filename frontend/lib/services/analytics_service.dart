import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/analytics_model.dart';
import 'offline_analytics_engine.dart';

/// Analytics API Service (Module 17).
/// Manages remote HTTP calls to /api/v1/analytics with transparent in-memory
/// caching and automatic fallback to OfflineAnalyticsEngine on network disruption.
class AnalyticsService {
  static const String defaultBaseUrl = 'http://127.0.0.1:8000/api/v1/analytics';
  static const Duration timeoutDuration = Duration(seconds: 4);

  final String baseUrl;
  final http.Client _client;

  // In-memory cache for fast tab switching
  final Map<String, AnalyticsDashboardOverviewModel> _overviewCache = {};

  AnalyticsService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  /// Fetches complete dashboard overview with transparent caching and offline fallback.
  Future<AnalyticsDashboardOverviewModel> getDashboardOverview({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
    bool forceRefresh = false,
  }) async {
    final cacheKey = timeFilter.code;

    if (!forceRefresh && _overviewCache.containsKey(cacheKey)) {
      return _overviewCache[cacheKey]!;
    }

    try {
      final uri = Uri.parse('$baseUrl/overview?time_filter=${timeFilter.code}');
      final response = await _client.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final model = AnalyticsDashboardOverviewModel.fromJson(data);
        _overviewCache[cacheKey] = model;
        return model;
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Network fetch failed: $e. Utilizing OfflineAnalyticsEngine.');
    }

    // Graceful offline fallback
    final fallback = OfflineAnalyticsEngine.getOverview(timeFilter: timeFilter);
    _overviewCache[cacheKey] = fallback;
    return fallback;
  }

  /// Fetches standalone KPI metrics.
  Future<KpiSummaryMetricsModel> getKpiMetrics({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/kpis?time_filter=${timeFilter.code}');
      final response = await _client.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return KpiSummaryMetricsModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[AnalyticsService] KPI fetch error: $e');
    }
    return OfflineAnalyticsEngine.getKpis(timeFilter: timeFilter);
  }

  /// Fetches top analyzed foods list.
  Future<MostAnalyzedFoodsResponseModel> getMostAnalyzedFoods({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/most-analyzed-foods?time_filter=${timeFilter.code}&limit=$limit');
      final response = await _client.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return MostAnalyzedFoodsResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Most analyzed foods fetch error: $e');
    }
    return OfflineAnalyticsEngine.getMostAnalyzedFoods(timeFilter: timeFilter, limit: limit);
  }

  /// Fetches packaging polymer distribution.
  Future<PackagingDistributionResponseModel> getPackagingDistribution({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/packaging-distribution?time_filter=${timeFilter.code}');
      final response = await _client.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return PackagingDistributionResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Packaging distribution fetch error: $e');
    }
    return OfflineAnalyticsEngine.getPackagingDistribution(timeFilter: timeFilter);
  }

  /// Fetches food category breakdown.
  Future<FoodCategoryDistributionResponseModel> getFoodCategoryDistribution({
    AnalyticsDateFilter timeFilter = AnalyticsDateFilter.allTime,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/category-distribution?time_filter=${timeFilter.code}');
      final response = await _client.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return FoodCategoryDistributionResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Category distribution fetch error: $e');
    }
    return OfflineAnalyticsEngine.getFoodCategoryDistribution(timeFilter: timeFilter);
  }

  /// Fetches 12-month trend time-series.
  Future<MonthlyTrendResponseModel> getMonthlyTrends({int months = 12}) async {
    try {
      final uri = Uri.parse('$baseUrl/monthly-trends?months=$months');
      final response = await _client.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return MonthlyTrendResponseModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[AnalyticsService] Monthly trends fetch error: $e');
    }
    return OfflineAnalyticsEngine.getMonthlyTrends(months: months);
  }

  /// Clears in-memory dashboard cache.
  void clearCache() {
    _overviewCache.clear();
  }
}
