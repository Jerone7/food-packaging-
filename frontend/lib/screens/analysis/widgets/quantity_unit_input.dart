import 'package:flutter/material.dart';
import '../../../../models/storage_condition.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';

class QuantityUnitInput extends StatelessWidget {
  final TextEditingController quantityController;
  final QuantityUnit selectedUnit;
  final ValueChanged<QuantityUnit> onUnitChanged;
  final ValueChanged<String>? onChanged;

  const QuantityUnitInput({
    super.key,
    required this.quantityController,
    required this.selectedUnit,
    required this.onUnitChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse(quantityController.text) ?? 0.0;
    final normalizedKg = selectedUnit.toKilograms(qty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'analysis.batch_quantity'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateDark,
              ),
            ),
            if (qty > 0 && selectedUnit != QuantityUnit.kg)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '≈ ${normalizedKg.toStringAsFixed(2)} kg total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.emeraldEco,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number Input
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'e.g., 500, 2.5, 1000',
                  prefixIcon: const Icon(Icons.scale_rounded, color: AppTheme.primaryTeal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'analysis.quantity_required'.tr();
                  }
                  final n = double.tryParse(val.trim());
                  if (n == null || n <= 0) {
                    return 'analysis.quantity_positive'.tr();
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),

            // Unit Dropdown / Segment
            Expanded(
              flex: 4,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<QuantityUnit>(
                    value: selectedUnit,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.slateBody),
                    items: QuantityUnit.values.map((unit) {
                      return DropdownMenuItem<QuantityUnit>(
                        value: unit,
                        child: Text(
                          unit.fullName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.slateDark,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (u) {
                      if (u != null) onUnitChanged(u);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
