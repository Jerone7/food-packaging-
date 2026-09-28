import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/packaging_model.dart';

/// Interactive card component representing a single analysis item in "My Analyses".
///
/// Designed to strictly follow Module 13 specification:
/// ```
/// Tomato       26 Sep 2026
/// Apple        25 Sep 2026
/// Potato       23 Sep 2026
/// ```
///
/// Clicking anywhere on the entry opens the previous analysis in 1-click.
class MyAnalysesCard extends StatefulWidget {
  final PackagingRecord record;
  final ValueChanged<PackagingRecord>? onOpenAnalysis;
  final ValueChanged<PackagingRecord>? onViewReport;
  final ValueChanged<PackagingRecord>? onDelete;
  final bool isCompact;

  const MyAnalysesCard({
    super.key,
    required this.record,
    this.onOpenAnalysis,
    this.onViewReport,
    this.onDelete,
    this.isCompact = false,
  });

  @override
  State<MyAnalysesCard> createState() => _MyAnalysesCardState();
}

class _MyAnalysesCardState extends State<MyAnalysesCard> {
  bool _isHovered = false;

  Color _getEcoScoreColor(double score) {
    if (score >= 85) return const Color(0xFF059669); // Emerald
    if (score >= 70) return const Color(0xFF0284C7); // Sky Blue
    if (score >= 50) return const Color(0xFFD97706); // Amber
    return const Color(0xFFE11D48); // Rose
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final ecoColor = _getEcoScoreColor(r.sustainabilityScore);
    final displayDate = r.formattedDisplayDate;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppTheme.primaryTeal.withValues(alpha: 0.03)
              : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AppTheme.primaryTeal.withValues(alpha: 0.6)
                : AppTheme.borderSubtle,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppTheme.primaryTeal.withValues(alpha: 0.09)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 14 : 6,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => widget.onOpenAnalysis?.call(r),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCompact ? 14 : 18,
                vertical: widget.isCompact ? 12 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row: Commodity Name and Formatted Date Stamp (Tomato 26 Sep 2026)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Commodity Name & Icon Badge
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: r.ecoFriendly
                                    ? AppTheme.emeraldLight
                                    : AppTheme.primaryTeal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                r.ecoFriendly
                                    ? Icons.eco_rounded
                                    : Icons.inventory_2_outlined,
                                size: 18,
                                color: r.ecoFriendly
                                    ? AppTheme.emeraldEco
                                    : AppTheme.primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                r.itemName.isNotEmpty ? r.itemName : 'Custom Produce',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.slateDark,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Formatted Date Badge: e.g. "26 Sep 2026"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.bgOffWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.borderSubtle,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: AppTheme.slateBody,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              displayDate,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.slateBody,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Middle Row: Recommended Material & Packaging Type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.recommendedBoxType.isNotEmpty
                              ? r.recommendedBoxType
                              : 'Corrugated Packaging Solution',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.slateBody,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Bottom Row: Metrics & Actions (Responsive Wrap)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Cost Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '₹${r.estimatedCost.toStringAsFixed(2)} / unit',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),

                      // Eco-Score Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ecoColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 13, color: ecoColor),
                            const SizedBox(width: 3),
                            Text(
                              '${r.sustainabilityScore.toStringAsFixed(1)}/100',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ecoColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.onViewReport != null)
                            IconButton(
                              icon: const Icon(
                                Icons.assessment_outlined,
                                size: 19,
                                color: AppTheme.primaryTeal,
                              ),
                              tooltip: 'View Full Report',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              onPressed: () => widget.onViewReport?.call(r),
                            ),
                          if (widget.onDelete != null)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 19,
                                color: Color(0xFF94A3B8),
                              ),
                              tooltip: 'Delete Record',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              onPressed: () => widget.onDelete?.call(r),
                            ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
