import 'package:flutter/material.dart';
import '../../../models/packaging_comparison_model.dart';

/// Responsive comparison table displaying side-by-side parameters across 2 to 3 materials.
class ComparisonParameterTable extends StatelessWidget {
  final List<MaterialComparisonSlot> slots;
  final List<ComparisonParameterRowModel> parameterRows;
  final bool showQuantitativeMetrics;
  final Function(String slotId)? onSlotHeaderTap;

  static const double parameterColWidth = 240.0;
  static const double slotColWidth = 230.0;
  static const double slotSpacing = 12.0;
  static const double tablePadding = 16.0;

  const ComparisonParameterTable({
    super.key,
    required this.slots,
    required this.parameterRows,
    this.showQuantitativeMetrics = true,
    this.onSlotHeaderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty || parameterRows.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalWidth = (tablePadding * 2) + parameterColWidth + (slots.length * (slotColWidth + slotSpacing));

    // Group rows by parameterGroup
    final Map<String, List<ComparisonParameterRowModel>> groupedRows = {};
    for (final row in parameterRows) {
      final group = row.parameterGroup.isNotEmpty ? row.parameterGroup : 'General Parameters';
      groupedRows.putIfAbsent(group, () => []).add(row);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Table Header (Slots)
              _buildTableHeader(context, isDark),

              // 2. Grouped Parameter Rows
              for (final entry in groupedRows.entries) ...[
                _buildGroupHeader(context, entry.key, isDark),
                for (int i = 0; i < entry.value.length; i++)
                  _buildDataRow(context, entry.value[i], isDark, isEven: i.isEven),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: tablePadding, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left parameter column header
          SizedBox(
            width: parameterColWidth,
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Comparison Parameters',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Slots headers
          for (final slot in slots) ...[
            const SizedBox(width: slotSpacing),
            SizedBox(
              width: slotColWidth,
              child: InkWell(
                onTap: onSlotHeaderTap != null ? () => onSlotHeaderTap!(slot.slotId) : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: slot.colorToken.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: slot.colorToken.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: slot.colorToken,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                slot.slotLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: slot.colorToken,
                                ),
                              ),
                            ],
                          ),
                          if (slot.isPrimaryRecommendation)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Recommended',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slot.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, String groupTitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: tablePadding, vertical: 8),
      color: isDark ? const Color(0xFF162032) : const Color(0xFFF1F5F9),
      child: Row(
        children: [
          Icon(
            _getGroupIcon(groupTitle),
            size: 14,
            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              groupTitle.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    ComparisonParameterRowModel row,
    bool isDark, {
    required bool isEven,
  }) {
    final rowBg = isEven
        ? (isDark ? const Color(0xFF1E293B) : Colors.white)
        : (isDark ? const Color(0xFF182234) : const Color(0xFFFAFAFB));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: tablePadding, vertical: 12),
      decoration: BoxDecoration(
        color: rowBg,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Parameter Label & scientific note tooltip
          SizedBox(
            width: parameterColWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        row.parameterLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (row.scientificNote != null && row.scientificNote!.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Tooltip(
                        message: row.scientificNote!,
                        preferBelow: false,
                        child: Icon(
                          Icons.info_outline,
                          size: 14,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ],
                ),
                if (row.unit != null && row.unit!.isNotEmpty)
                  Text(
                    'Unit: ${row.unit}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
          ),
          // Slots cells
          for (final slot in slots) ...[
            const SizedBox(width: slotSpacing),
            SizedBox(
              width: slotColWidth,
              child: _buildParameterCell(context, row, slot, isDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParameterCell(
    BuildContext context,
    ComparisonParameterRowModel row,
    MaterialComparisonSlot slot,
    bool isDark,
  ) {
    final value = row.values[slot.slotId] ?? '-';
    final isBest = (row.bestSlotId == slot.slotId);
    final rawNum = row.rawNumericValues?[slot.slotId];

    final (badgeBg, badgeText, badgeBorder) = _resolveBadgeColors(value, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isBest
            ? (isDark ? const Color(0xFF451A03).withValues(alpha: 0.3) : const Color(0xFFFEF3C7).withValues(alpha: 0.5))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isBest
            ? Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder, width: 1),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
              if (isBest)
                Tooltip(
                  message: 'Top performer for ${row.parameterLabel}',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded, size: 11, color: Color(0xFFD97706)),
                        SizedBox(width: 2),
                        Text(
                          'Best',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (showQuantitativeMetrics && rawNum != null) ...[
            const SizedBox(height: 3),
            Text(
              _formatQuantitativeValue(row.parameterKey, rawNum, row.unit),
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatQuantitativeValue(String key, double numVal, String? unit) {
    if (key.contains('cost') || unit == '₹' || unit == 'INR') {
      return '₹${numVal.toStringAsFixed(2)} / unit';
    }
    if (key == 'recyclability' || key == 'sustainability_score') {
      return 'Eco-Score: ${numVal.toStringAsFixed(0)}/100';
    }
    if (unit != null && unit.isNotEmpty) {
      return '${numVal.toStringAsFixed(numVal < 1.0 ? 2 : 1)} $unit';
    }
    return numVal.toStringAsFixed(1);
  }

  (Color bg, Color text, Color border) _resolveBadgeColors(String value, bool isDark) {
    final v = value.toLowerCase();

    // Positive / High / Yes / Compostable
    if (v == 'high' ||
        v == 'yes' ||
        v == 'biodegradable' ||
        v == 'home compostable' ||
        v == 'hermetic' ||
        (v == 'low' && v.contains('cost')) ||
        v == 'excellent') {
      return (
        isDark ? const Color(0xFF064E3B).withValues(alpha: 0.6) : const Color(0xFFECFDF5),
        isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
        isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFFA7F3D0),
      );
    }

    // Medium / Good / Controlled / Moderate
    if (v == 'medium' || v == 'good' || v == 'moderate' || v == 'controlled' || v == 'rigid') {
      return (
        isDark ? const Color(0xFF0C4A6E).withValues(alpha: 0.6) : const Color(0xFFF0F9FF),
        isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7),
        isDark ? const Color(0xFF0284C7).withValues(alpha: 0.4) : const Color(0xFFBAE6FD),
      );
    }

    // Low / No / High cost / Poor
    if (v == 'low' || v == 'no' || v == 'high' || v == 'poor' || v == 'premium') {
      return (
        isDark ? const Color(0xFF451A03).withValues(alpha: 0.6) : const Color(0xFFFFFBEB),
        isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706),
        isDark ? const Color(0xFFD97706).withValues(alpha: 0.4) : const Color(0xFFFDE68A),
      );
    }

    // Fallback neutral
    return (
      isDark ? const Color(0xFF334155).withValues(alpha: 0.6) : const Color(0xFFF1F5F9),
      isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
      isDark ? const Color(0xFF475569).withValues(alpha: 0.4) : const Color(0xFFCBD5E1),
    );
  }

  IconData _getGroupIcon(String groupTitle) {
    final g = groupTitle.toLowerCase();
    if (g.contains('barrier')) return Icons.shield_outlined;
    if (g.contains('gas') || g.contains('respiration')) return Icons.air_rounded;
    if (g.contains('strength') || g.contains('mechanical')) return Icons.fitness_center_rounded;
    if (g.contains('circularity') || g.contains('environmental') || g.contains('eco')) return Icons.eco_outlined;
    if (g.contains('cost') || g.contains('commercial')) return Icons.sell_outlined;
    if (g.contains('suitability') || g.contains('food')) return Icons.restaurant_rounded;
    return Icons.layers_outlined;
  }
}
