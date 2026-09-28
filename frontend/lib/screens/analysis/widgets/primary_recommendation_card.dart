import 'package:flutter/material.dart';
import '../../../models/packaging_model.dart';
import '../../../theme/app_theme.dart';

/// Hero Primary Packaging Recommendation Card (Module 5).
/// Displays the top-ranked AI/ML packaging polymer with quantitative barrier profile,
/// eco-score, suitability gauge, and active packaging additives.
class PrimaryRecommendationCard extends StatelessWidget {
  final PrimaryRecommendation recommendation;
  final VoidCallback? onApplyPressed;

  const PrimaryRecommendationCard({
    super.key,
    required this.recommendation,
    this.onApplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final matchPct = (recommendation.suitabilityScore * 100.0).clamp(0.0, 100.0);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderTeal, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Hero Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRIMARY AI RECOMMENDATION',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        recommendation.materialName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Suitability Gauge Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: AppTheme.primaryTeal,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${matchPct.toStringAsFixed(0)}% Match',
                        style: const TextStyle(
                          color: AppTheme.primaryTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta Pills (Type, Eco-Score, Unit Cost)
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildPill(
                      icon: Icons.science_outlined,
                      label: recommendation.materialType,
                      bgColor: const Color(0xFFF1F5F9),
                      textColor: AppTheme.slateDark,
                    ),
                    _buildPill(
                      icon: Icons.eco_rounded,
                      label: 'Eco-Score: ${recommendation.sustainabilityScore.toStringAsFixed(0)}/100',
                      bgColor: AppTheme.emeraldLight,
                      textColor: AppTheme.emeraldEco,
                      isBold: true,
                    ),
                    _buildPill(
                      icon: Icons.currency_rupee_rounded,
                      label: '₹${recommendation.estimatedUnitCostInr.toStringAsFixed(2)} / unit',
                      bgColor: const Color(0xFFFEF3C7),
                      textColor: const Color(0xFFB45309),
                      isBold: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.borderSubtle),
                const SizedBox(height: 16),

                // Quantitative Barrier Profile Grid
                const Text(
                  'QUANTITATIVE BARRIER & MECHANICAL SPECS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.slateBody,
                  ),
                ),
                const SizedBox(height: 10),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 450;
                    final itemWidth = isNarrow ? (constraints.maxWidth - 10) / 2 : (constraints.maxWidth - 30) / 4;

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildMetricBox(
                          label: 'Oxygen Rate (OTR)',
                          value: recommendation.barrierProfile.otr,
                          icon: Icons.air_rounded,
                          width: itemWidth,
                        ),
                        _buildMetricBox(
                          label: 'Moisture Rate (WVTR)',
                          value: recommendation.barrierProfile.wvtr,
                          icon: Icons.water_drop_outlined,
                          width: itemWidth,
                        ),
                        _buildMetricBox(
                          label: 'Film Thickness',
                          value: '${recommendation.barrierProfile.thicknessMicrons.toStringAsFixed(0)} µm',
                          icon: Icons.layers_outlined,
                          width: itemWidth,
                        ),
                        _buildMetricBox(
                          label: 'Puncture Strength',
                          value: '${recommendation.barrierProfile.punctureResistanceN.toStringAsFixed(0)} N',
                          icon: Icons.shield_outlined,
                          width: itemWidth,
                        ),
                      ],
                    );
                  },
                ),

                // Active Additives Inclusions
                if (recommendation.activeAdditives.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'ACTIVE PACKAGING ADDITIVES & DIRECTIVES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppTheme.slateBody,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recommendation.activeAdditives.map(
                    (additive) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppTheme.emeraldLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: AppTheme.emeraldEco,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              additive,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.slateDark,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    bool isBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required IconData icon,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.primaryTeal),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slateBody,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.slateDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
