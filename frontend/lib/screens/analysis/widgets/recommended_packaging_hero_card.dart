import 'package:flutter/material.dart';
import '../../../models/packaging_model.dart';
import '../../../theme/app_theme.dart';

/// Hero Recommended Packaging Card (Module 5 Main Result Page).
/// Prominently displays the AI recommendation headline ("Recommended Packaging"),
/// user-friendly packaging title (e.g. "Ventilated Food-Grade Packaging"),
/// polymer structure, quantitative suitability gauge, eco-score, and unit cost.
class RecommendedPackagingHeroCard extends StatelessWidget {
  final PrimaryRecommendation recommendation;
  final VoidCallback? onApplyPressed;

  const RecommendedPackagingHeroCard({
    super.key,
    required this.recommendation,
    this.onApplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final matchPct = (recommendation.suitabilityScore * 100.0).clamp(0.0, 100.0);
    final isHighMatch = matchPct >= 85.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderTeal, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Hero Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'RECOMMENDED PACKAGING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quantitative Suitability Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: isHighMatch ? AppTheme.emeraldEco : AppTheme.primaryTeal,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${matchPct.toStringAsFixed(0)}% Match',
                            style: TextStyle(
                              color: isHighMatch ? AppTheme.emeraldEco : AppTheme.primaryTeal,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title (e.g. Ventilated Food-Grade Packaging)
                Text(
                  recommendation.packagingTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                // Polymer Trade Name & Structure Subtitle
                Text(
                  '${recommendation.materialName} • ${recommendation.structure}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Body Metrics & Badges
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Suitability Linear Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Suitability & Compatibility Score',
                        style: TextStyle(
                          color: AppTheme.slateBody,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isHighMatch ? 'Highly Compatible' : 'Compatible Substrate',
                      style: TextStyle(
                        color: isHighMatch ? AppTheme.emeraldEco : AppTheme.primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (matchPct / 100.0).clamp(0.0, 1.0),
                    backgroundColor: AppTheme.borderTeal.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isHighMatch ? AppTheme.emeraldEco : AppTheme.primaryTeal,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),

                // Key Metric Badges Row
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // Eco-Score Badge
                    _buildMetricChip(
                      icon: Icons.eco_rounded,
                      iconColor: AppTheme.emeraldEco,
                      label: 'Eco-Score',
                      value: '${recommendation.sustainabilityScore.toInt()}/100',
                      badgeColor: AppTheme.emeraldEco.withValues(alpha: 0.1),
                      textColor: AppTheme.emeraldEco,
                    ),
                    // Unit Cost Badge
                    _buildMetricChip(
                      icon: Icons.currency_rupee_rounded,
                      iconColor: const Color(0xFFD97706),
                      label: 'Unit Cost',
                      value: '₹${recommendation.estimatedUnitCostInr.toStringAsFixed(2)}',
                      badgeColor: const Color(0xFFFEF3C7),
                      textColor: const Color(0xFF92400E),
                    ),
                    // Material Classification Badge
                    _buildMetricChip(
                      icon: Icons.category_outlined,
                      iconColor: AppTheme.primaryTeal,
                      label: 'Type',
                      value: recommendation.materialType,
                      badgeColor: AppTheme.primaryTeal.withValues(alpha: 0.08),
                      textColor: AppTheme.primaryTeal,
                    ),
                    // Packaging Format Pill
                    _buildMetricChip(
                      icon: Icons.inventory_2_outlined,
                      iconColor: const Color(0xFF2563EB),
                      label: 'Format',
                      value: recommendation.packagingFormat,
                      badgeColor: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      textColor: const Color(0xFF1D4ED8),
                    ),
                  ],
                ),

                if (onApplyPressed != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onApplyPressed,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text('Adopt Recommended Configuration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color badgeColor,
    required Color textColor,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppTheme.slateBody,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
