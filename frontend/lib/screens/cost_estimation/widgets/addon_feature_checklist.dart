import 'package:flutter/material.dart';
import '../../../models/cost_estimation_model.dart';

/// Multi-select checklist for functional finishes and treatments with itemized prices.
class AddOnFeatureChecklist extends StatelessWidget {
  final List<FunctionalAddOn> selectedAddons;
  final ValueChanged<List<FunctionalAddOn>> onAddonsChanged;

  const AddOnFeatureChecklist({
    super.key,
    required this.selectedAddons,
    required this.onAddonsChanged,
  });

  void _toggleAddon(FunctionalAddOn addon) {
    final updated = List<FunctionalAddOn>.from(selectedAddons);
    if (updated.contains(addon)) {
      updated.remove(addon);
    } else {
      updated.add(addon);
    }
    onAddonsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.add_task, size: 18, color: Color(0xFF0D9488)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '4. Functional Add-ons',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FunctionalAddOn.values.map((addon) {
            final isSelected = selectedAddons.contains(addon);
            const accentColor = Color(0xFF0284C7);

            return InkWell(
              onTap: () => _toggleAddon(addon),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: isDark ? 0.25 : 0.12)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 14,
                      color: isSelected ? accentColor : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        addon.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1))
                              : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '+₹${addon.defaultUnitPriceInr.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
