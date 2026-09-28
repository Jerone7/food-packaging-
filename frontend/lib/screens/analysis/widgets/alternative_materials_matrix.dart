import 'package:flutter/material.dart';
import '../../../models/packaging_model.dart';
import '../../../theme/app_theme.dart';
import 'alternative_candidate_card.dart';

/// Alternative Materials Comparison Matrix (Module 8).
/// Displays distinct alternative packaging pathways (Eco-Champion, Economy, High-Barrier)
/// with star ratings, suitability categories, characteristics mini-grids, trade-offs, and interactive selection.
class AlternativeMaterialsMatrix extends StatelessWidget {
  final List<PackagingAlternative> alternatives;
  final ValueChanged<PackagingAlternative>? onAlternativeSelected;
  final String? selectedMaterialName;

  const AlternativeMaterialsMatrix({
    super.key,
    required this.alternatives,
    this.onAlternativeSelected,
    this.selectedMaterialName,
  });

  @override
  Widget build(BuildContext context) {
    if (alternatives.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.mintAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.compare_arrows_rounded,
                color: AppTheme.primaryTeal,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ALTERNATIVE PACKAGING PATHWAYS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.slateDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;

            if (isMobile) {
              return Column(
                children: alternatives.asMap().entries.map((entry) {
                  final index = entry.key + 2; // Primary is Option 1, alternatives are Option 2, 3...
                  final alt = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AlternativeCandidateCard(
                      alternative: alt,
                      isSelected: selectedMaterialName == alt.materialName,
                      optionIndex: index,
                      onSelect: () => onAlternativeSelected?.call(alt),
                    ),
                  );
                }).toList(),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: alternatives.asMap().entries.map((entry) {
                final index = entry.key + 2;
                final alt = entry.value;
                final isLast = entry.key == alternatives.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 12),
                    child: AlternativeCandidateCard(
                      alternative: alt,
                      isSelected: selectedMaterialName == alt.materialName,
                      optionIndex: index,
                      onSelect: () => onAlternativeSelected?.call(alt),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
