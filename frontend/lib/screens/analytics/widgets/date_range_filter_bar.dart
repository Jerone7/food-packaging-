import 'package:flutter/material.dart';
import '../../../models/analytics_model.dart';
import '../../../theme/app_theme.dart';

/// Date Range Filter Bar with Segmented Time Chips & Export Actions (Module 17).
class DateRangeFilterBar extends StatelessWidget {
  final AnalyticsDateFilter selectedFilter;
  final ValueChanged<AnalyticsDateFilter> onFilterChanged;
  final VoidCallback? onExportCsv;
  final VoidCallback? onExportJson;
  final VoidCallback? onRefresh;
  final bool isExporting;

  const DateRangeFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.onExportCsv,
    this.onExportJson,
    this.onRefresh,
    this.isExporting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Time Segmented Chips
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: AnalyticsDateFilter.values.map((filter) {
                final isSelected = selectedFilter == filter;
                return InkWell(
                  onTap: () => onFilterChanged(filter),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      filter.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.slateBody,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Action Buttons (Refresh, Export CSV, Export JSON)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onRefresh != null)
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 20, color: AppTheme.slateBody),
                tooltip: 'Refresh analytics',
              ),
            const SizedBox(width: 4),
            OutlinedButton.icon(
              onPressed: isExporting ? null : onExportCsv,
              icon: const Icon(Icons.table_chart_outlined, size: 16),
              label: const Text('Export CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: const BorderSide(color: AppTheme.primaryTeal),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: isExporting ? null : onExportJson,
              icon: const Icon(Icons.code_rounded, size: 16),
              label: const Text('JSON', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.slateBody,
                side: const BorderSide(color: AppTheme.borderSubtle),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
