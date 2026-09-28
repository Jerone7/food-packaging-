import 'package:flutter/material.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/theme/app_theme.dart';
import 'star_rating_widget.dart';
import 'suitability_badge.dart';
import 'characteristics_mini_grid.dart';
import 'trade_off_card.dart';

/// Alternative Packaging Candidate Card (Module 8).
/// Comprehensive card presenting star rating, suitability tier, model probability,
/// characteristics grid, trade-offs, and interactive selection.
class AlternativeCandidateCard extends StatelessWidget {
  final PackagingAlternative alternative;
  final bool isSelected;
  final VoidCallback? onSelect;
  final int? optionIndex;

  const AlternativeCandidateCard({
    super.key,
    required this.alternative,
    this.isSelected = false,
    this.onSelect,
    this.optionIndex,
  });

  @override
  Widget build(BuildContext context) {
    Color roleColor;
    switch (alternative.type) {
      case AlternativeType.ecoFriendly:
        roleColor = AppTheme.emeraldEco;
        break;
      case AlternativeType.economy:
        roleColor = const Color(0xFFD97706); // Amber 600
        break;
      case AlternativeType.highBarrier:
        roleColor = const Color(0xFF0284C7); // Sky 600
        break;
    }

    final optionTag = optionIndex != null
        ? 'OPTION $optionIndex: ${alternative.type.displayName.toUpperCase()}'
        : alternative.type.displayName.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryTeal : const Color(0xFFE2E8F0),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Bar: Option Tag + Star Rating
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryTeal.withValues(alpha: 0.08)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        alternative.type.iconEmoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          optionTag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: roleColor,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StarRatingWidget(
                  rating: alternative.starRating,
                  size: 14,
                  compact: true,
                ),
              ],
            ),
          ),

          // 2. Main Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Polymer Subtitle
                Text(
                  alternative.packagingTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slateDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  alternative.materialName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.slateBody,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // Suitability Badge + Model Probability Chip
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SuitabilityBadge(
                      category: alternative.suitabilityCategory,
                      fontSize: 11,
                    ),
                    ModelConfidenceChip(
                      probability: alternative.modelDerivedProbability,
                      confidenceLabel: alternative.compatibilityConfidence,
                      fontSize: 11,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Characteristics Mini Grid (OTR, WVTR, Eco, Cost)
                CharacteristicsMiniGrid(
                  characteristics: alternative.characteristics,
                  costDeltaPct: alternative.costDeltaPct,
                  ecoDeltaPct: alternative.ecoDeltaPct,
                ),
                const SizedBox(height: 12),

                // Trade-Off Card
                TradeOffCard(
                  tradeOffSummary: alternative.tradeOffSummary,
                  advantages: alternative.advantages,
                  limitations: alternative.limitations,
                  shelfLifeDelta: alternative.shelfLifeDelta,
                ),
                const SizedBox(height: 14),

                // Selection Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? AppTheme.primaryTeal
                          : AppTheme.surfaceWhite,
                      foregroundColor: isSelected
                          ? Colors.white
                          : AppTheme.primaryTeal,
                      elevation: 0,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryTeal
                            : AppTheme.primaryTeal.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.touch_app_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSelected
                              ? 'Currently Selected'
                              : 'Select This Option',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
