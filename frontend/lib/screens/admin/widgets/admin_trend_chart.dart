import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';

/// Responsive Trend Visualizer for Admin 30-Day Analysis Volume & Eco Adoption
class AdminTrendChart extends StatelessWidget {
  final List<DailyUsageTrendModel> trends;
  final String title;

  const AdminTrendChart({
    super.key,
    required this.trends,
    this.title = '30-Day Analysis & Eco-Optimization Volume',
  });

  @override
  Widget build(BuildContext context) {
    final maxTotal = trends.fold<int>(1, (max, t) => math.max(max, t.totalAnalyses));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Legend Row (Wrap-based for zero-overflow guarantee)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: AppTheme.primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.slateDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _legendItem('Total Runs', AppTheme.primaryTeal),
                  _legendItem('Eco-Friendly', AppTheme.emeraldEco),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Display Area
          if (trends.isEmpty)
            Container(
              height: 180,
              alignment: Alignment.center,
              child: const Text(
                'No trend data available for selected period',
                style: TextStyle(color: AppTheme.slateBody, fontSize: 13),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final chartBarMaxHeight = math.max(20.0, constraints.maxHeight - 56.0);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: trends.map((dayTrend) {
                      final totalHeightPct = (dayTrend.totalAnalyses / maxTotal).clamp(0.08, 1.0);
                      final ecoHeightPct = dayTrend.totalAnalyses > 0
                          ? (dayTrend.ecoAnalyses / dayTrend.totalAnalyses).clamp(0.0, 1.0)
                          : 0.0;

                      final barHeight = chartBarMaxHeight * totalHeightPct;
                      final ecoBarHeight = barHeight * ecoHeightPct;

                      // Format short date (e.g., '09/27')
                      final parts = dayTrend.date.split('-');
                      final shortDate = parts.length == 3 ? '${parts[1]}/${parts[2]}' : dayTrend.date;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Value on top of bar
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${dayTrend.totalAnalyses}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.slateDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Stacked Bar Container
                              Container(
                                height: barHeight,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      height: ecoBarHeight,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppTheme.emeraldEco,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Date label
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  shortDate,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.slateBody,
          ),
        ),
      ],
    );
  }
}
