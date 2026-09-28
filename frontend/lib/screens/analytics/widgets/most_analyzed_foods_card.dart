import 'package:flutter/material.dart';
import '../../../models/analytics_model.dart';
import '../../../theme/app_theme.dart';
import '../painters/horizontal_bar_painter.dart';

/// Chart 1: Most Analyzed Foods Card (Module 17).
/// Displays horizontal Pareto-ranked leaderboard of evaluated food commodities.
class MostAnalyzedFoodsCard extends StatefulWidget {
  final MostAnalyzedFoodsResponseModel data;
  final bool isLoading;
  final ValueChanged<MostAnalyzedFoodItemModel>? onFoodSelected;

  const MostAnalyzedFoodsCard({
    super.key,
    required this.data,
    this.isLoading = false,
    this.onFoodSelected,
  });

  @override
  State<MostAnalyzedFoodsCard> createState() => _MostAnalyzedFoodsCardState();
}

class _MostAnalyzedFoodsCardState extends State<MostAnalyzedFoodsCard> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final items = widget.data.items;
    final maxVolume = items.isNotEmpty
        ? items.map((e) => e.analysisCount).reduce((a, b) => a > b ? a : b)
        : 1;

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isWide = headerConstraints.maxWidth > 400;
              final iconAndTitle = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.leaderboard_rounded,
                      size: 20,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Most Analyzed Foods',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slateDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pareto leaderboard & shelf-life impact',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.slateBody.withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final badge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.data.totalVolume} Total Prescriptions',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.emeraldEco,
                  ),
                ),
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: iconAndTitle),
                    const SizedBox(width: 8),
                    badge,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconAndTitle,
                    const SizedBox(height: 10),
                    badge,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppTheme.borderSubtle),
          const SizedBox(height: 14),

          // Content List
          if (widget.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No food analysis records available for selected period',
                  style: TextStyle(fontSize: 13, color: AppTheme.slateBody),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final food = items[index];
                final progress = maxVolume > 0 ? (food.analysisCount / maxVolume) : 0.0;
                final isTop3 = index < 3;
                final isHovered = _hoveredIndex == index;

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: InkWell(
                    onTap: () => widget.onFoodSelected?.call(food),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHovered ? const Color(0xFFF8FAFC) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Rank badge
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isTop3
                                      ? (index == 0
                                          ? const Color(0xFFFEF3C7) // Gold
                                          : index == 1
                                              ? const Color(0xFFE2E8F0) // Silver
                                              : const Color(0xFFFFEDD5)) // Bronze
                                      : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isTop3
                                        ? (index == 0
                                            ? const Color(0xFFB45309)
                                            : index == 1
                                                ? const Color(0xFF475569)
                                                : const Color(0xFFC2410C))
                                        : AppTheme.slateBody,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Food Name & Category
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      food.foodName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.slateDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      food.foodCategory,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              // Analysis volume & share
                              Text(
                                '${food.analysisCount} (${food.percentageShare}%)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Custom Canvas Progress Bar
                          CustomPaint(
                            size: const Size(double.infinity, 7),
                            painter: HorizontalBarPainter(
                              progress: progress,
                              primaryColor: isTop3
                                  ? AppTheme.primaryTeal
                                  : const Color(0xFF64748B),
                              secondaryColor: isTop3
                                  ? AppTheme.mintAccent
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Footer info: Shelf life extension & Cumulative Pareto
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  '+${food.shelfLifeExtensionDays}d shelf-life extension',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.emeraldEco.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cumulative: ${food.cumulativeParetoPct}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
