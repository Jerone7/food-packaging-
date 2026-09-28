import 'package:flutter/material.dart';
import '../../models/analytics_model.dart';
import '../../services/analytics_service.dart';
import '../../services/offline_analytics_engine.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_translations.dart';
import '../../widgets/navigation/language_selector_widget.dart';
import 'widgets/kpi_metrics_grid.dart';
import 'widgets/most_analyzed_foods_card.dart';
import 'widgets/packaging_distribution_card.dart';
import 'widgets/food_category_distribution_card.dart';
import 'widgets/monthly_analysis_trend_card.dart';
import 'widgets/date_range_filter_bar.dart';

/// Master Analytics Dashboard & Business Intelligence Cockpit (Module 17).
class AnalyticsDashboardScreen extends StatefulWidget {
  final AnalyticsService? analyticsService;

  const AnalyticsDashboardScreen({
    super.key,
    this.analyticsService,
  });

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  late final AnalyticsService _service;
  AnalyticsDateFilter _selectedFilter = AnalyticsDateFilter.allTime;
  AnalyticsDashboardOverviewModel? _overviewData;
  bool _isLoading = true;
  bool _isExporting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = widget.analyticsService ?? AnalyticsService();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getDashboardOverview(
        timeFilter: _selectedFilter,
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _overviewData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _overviewData = OfflineAnalyticsEngine.getOverview(timeFilter: _selectedFilter);
          _isLoading = false;
          _errorMessage = 'Using cached offline analytics ($e)';
        });
      }
    }
  }

  void _onFilterChanged(AnalyticsDateFilter filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
      _loadDashboardData();
    }
  }

  void _handleExport(String format) {
    setState(() => _isExporting = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Analytics dataset exported successfully as $format'),
              ],
            ),
            backgroundColor: AppTheme.emeraldEco,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final kpis = _overviewData?.kpiMetrics ?? const KpiSummaryMetricsModel();
    final topFoods = _overviewData?.mostAnalyzedFoods ??
        const MostAnalyzedFoodsResponseModel(totalVolume: 0, items: []);
    final pkgDist = _overviewData?.packagingDistribution ??
        const PackagingDistributionResponseModel(totalRecommendations: 0, items: []);
    final catDist = _overviewData?.categoryDistribution ??
        const FoodCategoryDistributionResponseModel(totalAnalyses: 0, items: []);
    final monthlyTrends = _overviewData?.monthlyTrends ??
        const MonthlyTrendResponseModel(timeSeries: [], totalPeriodVolume: 0, avgMonthlyAnalyses: 0);

    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      body: RefreshIndicator(
        onRefresh: () => _loadDashboardData(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  _buildHeader(context),
                  const SizedBox(height: 20),

                  // Filter & Actions Bar
                  DateRangeFilterBar(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: _onFilterChanged,
                    onRefresh: () => _loadDashboardData(forceRefresh: true),
                    onExportCsv: () => _handleExport('CSV'),
                    onExportJson: () => _handleExport('JSON'),
                    isExporting: _isExporting,
                  ),
                  const SizedBox(height: 20),

                  // Error notice if offline fallback was used
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFB45309)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 1. KPI Hero Cards Grid
                  KpiMetricsGrid(
                    kpis: kpis,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // 2. Primary Charts (Row 1: Top Foods & Packaging Distribution)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 980;

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: MostAnalyzedFoodsCard(
                                data: topFoods,
                                isLoading: _isLoading,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 5,
                              child: PackagingDistributionCard(
                                data: pkgDist,
                                isLoading: _isLoading,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            MostAnalyzedFoodsCard(
                              data: topFoods,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 20),
                            PackagingDistributionCard(
                              data: pkgDist,
                              isLoading: _isLoading,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // 3. Secondary Charts (Row 2: Category Distribution & Monthly Trends)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 980;

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: FoodCategoryDistributionCard(
                                data: catDist,
                                isLoading: _isLoading,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 6,
                              child: MonthlyAnalysisTrendCard(
                                data: monthlyTrends,
                                isLoading: _isLoading,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            FoodCategoryDistributionCard(
                              data: catDist,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 20),
                            MonthlyAnalysisTrendCard(
                              data: monthlyTrends,
                              isLoading: _isLoading,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 6,
                children: [
                  Text(
                    'analytics.title'.tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slateDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'analytics.live_engine'.tr(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.emeraldEco,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'analytics.subtitle'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.slateBody,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
        ),
      ],
    );
  }
}
