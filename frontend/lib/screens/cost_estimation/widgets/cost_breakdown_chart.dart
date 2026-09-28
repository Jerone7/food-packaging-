import 'package:flutter/material.dart';
import '../../../models/cost_estimation_model.dart';

/// Segmented breakdown chart and itemized cost contributors.
class CostBreakdownChart extends StatelessWidget {
  final List<CostLayerItem> costBreakdown;
  final double totalEstimatedCostInr;

  const CostBreakdownChart({
    super.key,
    required this.costBreakdown,
    required this.totalEstimatedCostInr,
  });

  static const Map<String, Color> categoryColors = {
    'Substrate': Color(0xFF0D9488), // Teal
    'Converting': Color(0xFF0284C7), // Sky
    'Add-on': Color(0xFF8B5CF6), // Purple
    'Tooling': Color(0xFFF59E0B), // Amber
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_outline, size: 18, color: Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cost Structure & Itemized Contribution',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Multi-segment progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: costBreakdown.map((item) {
                  final color = categoryColors[item.category] ?? Colors.grey;
                  final flex = (item.percentageOfTotal * 10).round().clamp(1, 1000);
                  return Flexible(
                    flex: flex,
                    child: Container(color: color),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Breakdown rows
          ...costBreakdown.map((item) {
            final color = categoryColors[item.category] ?? Colors.grey;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[200] : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${item.costPerUnitInr.toStringAsFixed(2)}/unit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${item.percentageOfTotal.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
