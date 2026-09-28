import 'package:flutter/material.dart';
import '../../../models/analytics_model.dart';
import '../../../theme/app_theme.dart';

/// Responsive Grid displaying the 4 Primary Platform KPIs (Module 17).
class KpiMetricsGrid extends StatelessWidget {
  final KpiSummaryMetricsModel kpis;
  final bool isLoading;

  const KpiMetricsGrid({
    super.key,
    required this.kpis,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 4;
        double childAspectRatio = 1.6;

        if (width < 640) {
          crossAxisCount = 1;
          childAspectRatio = 2.1;
        } else if (width < 1024) {
          crossAxisCount = 2;
          childAspectRatio = 1.7;
        }

        final items = [
          _KpiCardData(
            title: 'Total Analyses',
            value: kpis.formattedTotalAnalyses,
            badge: kpis.formattedGrowth,
            badgeIsPositive: kpis.momAnalysisGrowthPct >= 0,
            badgeLabel: 'MoM Growth',
            icon: Icons.analytics_outlined,
            accentColor: AppTheme.primaryTeal,
            gradient: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
          ),
          _KpiCardData(
            title: 'Food Commodities',
            value: kpis.formattedCommodities,
            badge: 'Active Profile',
            badgeIsPositive: true,
            badgeLabel: 'IFCT Biochemical',
            icon: Icons.restaurant_menu_rounded,
            accentColor: const Color(0xFF6366F1),
            gradient: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
          ),
          _KpiCardData(
            title: 'Packaging Materials',
            value: kpis.formattedMaterials,
            badge: '${kpis.formattedEcoRate} Eco',
            badgeIsPositive: true,
            badgeLabel: 'Polymer Diversity',
            icon: Icons.layers_rounded,
            accentColor: AppTheme.emeraldEco,
            gradient: const [Color(0xFF059669), Color(0xFF10B981)],
          ),
          _KpiCardData(
            title: 'Recommendations',
            value: kpis.formattedRecommendations,
            badge: '100% Match',
            badgeIsPositive: true,
            badgeLabel: 'Prescriptions',
            icon: Icons.verified_rounded,
            accentColor: const Color(0xFFF59E0B),
            gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildKpiCard(context, items[index]);
          },
        );
      },
    );
  }

  Widget _buildKpiCard(BuildContext context, _KpiCardData data) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slateBody,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      data.accentColor.withValues(alpha: 0.12),
                      data.accentColor.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  data.icon,
                  size: 20,
                  color: data.accentColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              else
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slateDark,
                    letterSpacing: -0.5,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: data.badgeIsPositive
                          ? AppTheme.emeraldLight
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.badge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: data.badgeIsPositive
                            ? AppTheme.emeraldEco
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      data.badgeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCardData {
  final String title;
  final String value;
  final String badge;
  final bool badgeIsPositive;
  final String badgeLabel;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradient;

  const _KpiCardData({
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeIsPositive,
    required this.badgeLabel,
    required this.icon,
    required this.accentColor,
    required this.gradient,
  });
}
