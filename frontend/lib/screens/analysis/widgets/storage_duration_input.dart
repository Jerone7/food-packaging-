import 'package:flutter/material.dart';
import '../../../../models/storage_condition.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';

class StorageDurationInput extends StatelessWidget {
  final TextEditingController durationController;
  final DurationUnit durationUnit;
  final ValueChanged<DurationUnit> onUnitChanged;
  final ValueChanged<String>? onChanged;

  const StorageDurationInput({
    super.key,
    required this.durationController,
    required this.durationUnit,
    required this.onUnitChanged,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = int.tryParse(durationController.text) ?? 0;
    final totalDays = durationUnit.toDays(value);

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
              'analysis.storage_duration'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateDark,
              ),
            ),
            if (value > 0 && durationUnit != DurationUnit.days)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.borderTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${'analysis.shelf_life_approx'.tr()} $totalDays ${'analysis.days'.tr()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duration Text Input
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: durationController,
                keyboardType: TextInputType.number,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'e.g., 30, 6, 12',
                  prefixIcon: const Icon(Icons.timer_outlined, color: AppTheme.primaryTeal),
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
                    return 'analysis.duration_required'.tr();
                  }
                  final n = int.tryParse(val.trim());
                  if (n == null || n <= 0) {
                    return 'analysis.duration_positive'.tr();
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),

            // Unit Selector
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
                  child: DropdownButton<DurationUnit>(
                    value: durationUnit,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.slateBody),
                    items: DurationUnit.values.map((u) {
                      return DropdownMenuItem<DurationUnit>(
                        value: u,
                        child: Text(
                          u.label,
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
