import 'package:flutter/material.dart';
import '../../../models/analytics_model.dart';
import '../../../theme/app_theme.dart';
import '../painters/radial_gauge_painter.dart';

/// Chart 3: Food Category Distribution Card (Module 17).
/// Visualizes commodity volume shares and shelf-life degradation challenges across food sectors.
class FoodCategoryDistributionCard extends StatefulWidget {
  final FoodCategoryDistributionResponseModel data;
  final bool isLoading;
  final ValueChanged<FoodCategoryDistributionItemModel>? onCategorySelected;

  const FoodCategoryDistributionCard({
    super.key,
    required this.data,
    this.isLoading = false,
    this.onCategorySelected,
  });

  @override
  State<FoodCategoryDistributionCard> createState() => _FoodCategoryDistributionCardState();
}

class _FoodCategoryDistributionCardState extends State<FoodCategoryDistributionCard> {
  int? _hoveredIndex;

  static const List<Color> _categoryColors = [
    Color(0xFF0F766E), // Deep Teal
    Color(0xFF059669), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
  ];

  @override
  Widget build(BuildContext context) {
    final items = widget.data.items;

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
                       color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: const Icon(
                       Icons.category_rounded,
                       size: 20,
                       color: Color(0xFF6366F1),
                     ),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text(
                           'Food Category Breakdown',
                           style: TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.w700,
                             color: AppTheme.slateDark,
                           ),
                           overflow: TextOverflow.ellipsis,
                         ),
                         const SizedBox(height: 2),
                         Text(
                           'Preservation taxonomy & demand shares',
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
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${items.length} Categories',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
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
                  'No category analysis records available',
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
                          painter: RadialGaugePainter(
                            items: items,
                            selectedIndex: _hoveredIndex,
                            strokeWidth: 9,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.data.totalAnalyses}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.slateDark,
                              ),
                            ),
                            const Text(
                              'Total Items',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                final categoryListWidget = Column(
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final color = _categoryColors[index % _categoryColors.length];
                    final isHovered = _hoveredIndex == index;

                    return MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = null),
                      child: InkWell(
                        onTap: () => widget.onCategorySelected?.call(item),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isHovered ? const Color(0xFFF8FAFC) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.categoryName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isHovered ? FontWeight.w700 : FontWeight.w600,
                                        color: AppTheme.slateDark,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${item.commodityCount} items',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.slateBody,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${item.analysisCount} (${item.percentageShare}%)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.slateDark,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.primaryPreservationChallenge.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 18, top: 2),
                                  child: Text(
                                    item.primaryPreservationChallenge,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF94A3B8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                      Expanded(child: categoryListWidget),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      chartWidget,
                      const SizedBox(height: 16),
                      categoryListWidget,
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
