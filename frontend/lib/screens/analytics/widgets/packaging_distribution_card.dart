import 'package:flutter/material.dart';
import '../../../models/analytics_model.dart';
import '../../../theme/app_theme.dart';
import '../painters/donut_chart_painter.dart';

/// Chart 2: Packaging Recommendation Distribution Card (Module 17).
/// Visualizes polymer family market share with interactive Donut chart and legend.
class PackagingDistributionCard extends StatefulWidget {
  final PackagingDistributionResponseModel data;
  final bool isLoading;
  final ValueChanged<PackagingDistributionItemModel>? onPolymerSelected;

  const PackagingDistributionCard({
    super.key,
    required this.data,
    this.isLoading = false,
    this.onPolymerSelected,
  });

  @override
  State<PackagingDistributionCard> createState() => _PackagingDistributionCardState();
}

class _PackagingDistributionCardState extends State<PackagingDistributionCard> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final items = widget.data.items;
    final hoveredItem = (_hoveredIndex != null && _hoveredIndex! < items.length)
        ? items[_hoveredIndex!]
        : null;

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
                      color: AppTheme.emeraldEco.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.pie_chart_rounded,
                      size: 20,
                      color: AppTheme.emeraldEco,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Packaging Distribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slateDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Polymer family prescription shares',
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
                  '${widget.data.ecoFriendlySharePct}% Eco Share',
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
          const SizedBox(height: 16),

          // Content
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
                  'No packaging distribution records available',
                  style: TextStyle(fontSize: 13, color: AppTheme.slateBody),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 640;

                final chartWidget = Center(
                  child: SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(190, 190),
                          painter: DonutChartPainter(
                            items: items,
                            selectedIndex: _hoveredIndex,
                            strokeWidth: 22,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              hoveredItem != null
                                  ? '${hoveredItem.recommendationCount}'
                                  : '${widget.data.totalRecommendations}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.slateDark,
                              ),
                            ),
                            Text(
                              hoveredItem != null
                                  ? '${hoveredItem.percentageShare}%'
                                  : 'Prescriptions',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: hoveredItem != null
                                    ? hoveredItem.colorToken
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                final legendWidget = Column(
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isHovered = _hoveredIndex == index;

                    return MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = null),
                      child: InkWell(
                        onTap: () => widget.onPolymerSelected?.call(item),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: isHovered ? const Color(0xFFF8FAFC) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: item.colorToken,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isHovered ? FontWeight.w700 : FontWeight.w500,
                                    color: isHovered ? AppTheme.slateDark : AppTheme.slateBody,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.isEcoFriendly)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.emeraldLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ECO',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.emeraldEco,
                                    ),
                                  ),
                                ),
                              Text(
                                '${item.recommendationCount} (${item.percentageShare}%)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.slateDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );

                if (isWide) {
                  return Row(
                    children: [
                      chartWidget,
                      const SizedBox(width: 20),
                      Expanded(child: legendWidget),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      chartWidget,
                      const SizedBox(height: 16),
                      legendWidget,
                    ],
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
