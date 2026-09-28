import 'package:flutter/material.dart';
import '../../../models/packaging_comparison_model.dart';
import 'material_slot_card.dart';

/// Dynamic 3-slot selector strip for comparing Material A, Material B, and Material C.
class MaterialSelectorStrip extends StatelessWidget {
  final List<MaterialComparisonSlot> slots;
  final Function(ComparisonSlotId slotId) onSlotPick;
  final Function(ComparisonSlotId slotId) onSlotRemove;
  final String? activeSlotId;

  const MaterialSelectorStrip({
    super.key,
    required this.slots,
    required this.onSlotPick,
    required this.onSlotRemove,
    this.activeSlotId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;

        // Map current slots by slot_id
        final Map<String, MaterialComparisonSlot> slotMap = {
          for (final s in slots) s.slotId: s,
        };

        final slotACard = MaterialSlotCard(
          slotId: ComparisonSlotId.materialA,
          slot: slotMap['material_a'] ?? (slots.isNotEmpty ? slots[0] : null),
          isSelected: activeSlotId == 'material_a',
          canRemove: false, // Slot A is primary anchor
          onSelectOrChange: () => onSlotPick(ComparisonSlotId.materialA),
        );

        final slotBCard = MaterialSlotCard(
          slotId: ComparisonSlotId.materialB,
          slot: slotMap['material_b'] ?? (slots.length > 1 ? slots[1] : null),
          isSelected: activeSlotId == 'material_b',
          canRemove: false, // Minimal comparison requires at least 2 materials
          onSelectOrChange: () => onSlotPick(ComparisonSlotId.materialB),
        );

        final slotCCard = MaterialSlotCard(
          slotId: ComparisonSlotId.materialC,
          slot: slotMap['material_c'] ?? (slots.length > 2 ? slots[2] : null),
          isSelected: activeSlotId == 'material_c',
          canRemove: slots.length > 2, // Slot C can be removed to revert to 2-way comparison
          onSelectOrChange: () => onSlotPick(ComparisonSlotId.materialC),
          onRemove: () => onSlotRemove(ComparisonSlotId.materialC),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: slotACard),
              const SizedBox(width: 12),
              Expanded(child: slotBCard),
              const SizedBox(width: 12),
              Expanded(child: slotCCard),
            ],
          );
        } else {
          return Column(
            children: [
              slotACard,
              const SizedBox(height: 10),
              slotBCard,
              const SizedBox(height: 10),
              slotCCard,
            ],
          );
        }
      },
    );
  }
}
