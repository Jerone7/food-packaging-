import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeatureBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double fontSize;

  const FeatureBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = AppTheme.borderTeal,
    this.foregroundColor = AppTheme.primaryTeal,
    this.borderColor,
    this.fontSize = 12,
  });

  factory FeatureBadge.eco({required String label, IconData? icon}) {
    return FeatureBadge(
      label: label,
      icon: icon ?? Icons.eco_rounded,
      backgroundColor: AppTheme.emeraldLight,
      foregroundColor: AppTheme.emeraldEco,
      borderColor: AppTheme.emeraldEco.withValues(alpha: 0.3),
    );
  }

  factory FeatureBadge.barrier({required String label, IconData? icon}) {
    return FeatureBadge(
      label: label,
      icon: icon ?? Icons.shield_outlined,
      backgroundColor: const Color(0xFFEFF6FF), // Soft Blue
      foregroundColor: const Color(0xFF2563EB), // Blue Accent
      borderColor: const Color(0xFFBFDBFE),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? foregroundColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: foregroundColor,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
