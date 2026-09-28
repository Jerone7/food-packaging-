import 'package:flutter/material.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';

/// Descriptive Suitability Badge Widget (Module 8).
/// Renders standardized descriptive suitability categories with semantic color tokens.
class SuitabilityBadge extends StatelessWidget {
  final SuitabilityCategory category;
  final bool showTier;
  final double fontSize;

  const SuitabilityBadge({
    super.key,
    required this.category,
    this.showTier = false,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    IconData icon;

    switch (category) {
      case SuitabilityCategory.optimalMatch:
        bg = const Color(0xFFECFDF5);
        border = const Color(0xFFA7F3D0);
        text = const Color(0xFF059669);
        icon = Icons.verified_rounded;
        break;
      case SuitabilityCategory.highCompatibility:
        bg = const Color(0xFFF0F9FF);
        border = const Color(0xFFBAE6FD);
        text = const Color(0xFF0284C7);
        icon = Icons.stars_rounded;
        break;
      case SuitabilityCategory.moderateCompatibility:
        bg = const Color(0xFFFFFBEB);
        border = const Color(0xFFFDE68A);
        text = const Color(0xFFB45309);
        icon = Icons.info_outline_rounded;
        break;
      case SuitabilityCategory.conditionalAlternative:
        bg = const Color(0xFFFAF5FF);
        border = const Color(0xFFE9D5FF);
        text = const Color(0xFF7E22CE);
        icon = Icons.tune_rounded;
        break;
    }

    final label = showTier ? category.badgeLabel : category.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: fontSize + 2, color: text),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: text,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Model-Derived Match Probability Chip (Module 8).
/// Explicitly labels algorithmic TOPSIS closeness probability without arbitrary numerical claims.
class ModelConfidenceChip extends StatelessWidget {
  final double probability;
  final String? confidenceLabel;
  final double fontSize;

  const ModelConfidenceChip({
    super.key,
    required this.probability,
    this.confidenceLabel,
    this.fontSize = 11.5,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (probability.clamp(0.0, 1.0) * 100).toStringAsFixed(0);
    final label = confidenceLabel ?? 'Model Probability: $pct%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate 100
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_graph_rounded,
            size: 13,
            color: Color(0xFF475569),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
