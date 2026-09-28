import 'package:flutter/material.dart';
import '../../../../models/material_catalog_model.dart';
import '../../../../theme/app_theme.dart';

/// Floating bottom dock displaying selected materials and launching side-by-side comparison.
class PinnedComparisonBar extends StatelessWidget {
  final List<PackagingMaterialDetail> selectedMaterials;
  final ValueChanged<String> onRemoveMaterial;
  final VoidCallback onClearAll;
  final VoidCallback onLaunchComparison;

  const PinnedComparisonBar({
    super.key,
    required this.selectedMaterials,
    required this.onRemoveMaterial,
    required this.onClearAll,
    required this.onLaunchComparison,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedMaterials.isEmpty) return const SizedBox.shrink();

    final count = selectedMaterials.length;
    final canCompare = count >= 2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.slateDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Counter Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.mintAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.mintAccent.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.compare_arrows, size: 16, color: AppTheme.mintAccent),
                const SizedBox(width: 6),
                Text(
                  '$count / 4 Selected',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.mintAccent),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Selected Material Mini Chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedMaterials.map((mat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mat.name,
                            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => onRemoveMaterial(mat.materialId),
                            child: const Icon(Icons.close, size: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Clear All Button
          TextButton(
            onPressed: onClearAll,
            child: const Text(
              'Clear',
              style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),

          // Launch Comparison Action Button
          ElevatedButton.icon(
            onPressed: canCompare ? onLaunchComparison : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mintAccent,
              foregroundColor: AppTheme.slateDark,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white38,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.analytics_outlined, size: 16),
            label: Text(
              canCompare ? 'Compare ($count)' : 'Pick ≥ 2',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
