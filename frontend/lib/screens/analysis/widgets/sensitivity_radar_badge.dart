import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class SensitivityRadarBadge extends StatelessWidget {
  final String label;
  final String level;
  final IconData icon;

  const SensitivityRadarBadge({
    super.key,
    required this.label,
    required this.level,
    required this.icon,
  });

  Color _getLevelColor(String lvl) {
    final lower = lvl.toLowerCase();
    if (lower.contains('critical') || lower.contains('extreme')) {
      return const Color(0xFFDC2626); // Crimson Red
    } else if (lower.contains('high')) {
      return const Color(0xFFEA580C); // Dark Orange
    } else if (lower.contains('mod') || lower.contains('medium')) {
      return const Color(0xFFD97706); // Amber Gold
    } else if (lower.contains('low') || lower.contains('insensitive') || lower.contains('none') || lower.contains('tolerant')) {
      return const Color(0xFF059669); // Emerald Green
    }
    return AppTheme.primaryTeal;
  }

  String _getShortLevel(String lvl) {
    final lower = lvl.toLowerCase();
    if (lower.contains('critical')) return 'Critical';
    if (lower.contains('extreme')) return 'Extreme';
    if (lower.contains('high')) return 'High';
    if (lower.contains('mod') || lower.contains('medium')) return 'Moderate';
    if (lower.contains('insensitive') || lower.contains('none')) return 'None';
    if (lower.contains('low')) return 'Low';
    if (lower.contains('tolerant')) return 'Tolerant';
    return lvl.split('(').first.trim();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getLevelColor(level);
    final shortLevel = _getShortLevel(level);

    return Tooltip(
      message: '$label: $level',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 1),
                Text(
                  shortLevel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
