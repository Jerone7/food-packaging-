import 'package:flutter/material.dart';
import '../../../../models/storage_condition.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';
import '../../../../widgets/modern_card.dart';

class TransportConditionAccordion extends StatefulWidget {
  final TransportMode selectedMode;
  final int transitDays;
  final bool isFragile;
  final ValueChanged<TransportMode> onModeChanged;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<bool> onFragileChanged;

  const TransportConditionAccordion({
    super.key,
    required this.selectedMode,
    required this.transitDays,
    required this.isFragile,
    required this.onModeChanged,
    required this.onDaysChanged,
    required this.onFragileChanged,
  });

  @override
  State<TransportConditionAccordion> createState() => _TransportConditionAccordionState();
}

class _TransportConditionAccordionState extends State<TransportConditionAccordion> {
  bool _isExpanded = false;
  late TextEditingController _daysCtrl;

  @override
  void initState() {
    super.initState();
    _daysCtrl = TextEditingController(text: widget.transitDays.toString());
  }

  @override
  void didUpdateWidget(covariant TransportConditionAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transitDays != widget.transitDays) {
      _daysCtrl.text = widget.transitDays.toString();
    }
  }

  @override
  void dispose() {
    _daysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      backgroundColor: Colors.white,
      borderColor: AppTheme.borderSubtle,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.selectedMode.icon,
                          color: AppTheme.primaryTeal,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'analysis.transport_title'.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.slateDark,
                              ),
                            ),
                            Text(
                              '${widget.selectedMode.displayName} • ${widget.transitDays} ${'analysis.days'.tr()} ${'analysis.transit'.tr()}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.slateBody,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 24),
            Text(
              'analysis.select_logistics'.tr(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TransportMode.values.map((mode) {
                final isSelected = widget.selectedMode == mode;
                return ChoiceChip(
                  avatar: Icon(
                    mode.icon,
                    size: 14,
                    color: isSelected ? Colors.white : AppTheme.primaryTeal,
                  ),
                  label: Text(
                    mode.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppTheme.slateDark,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryTeal,
                  backgroundColor: AppTheme.bgOffWhite,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
                  ),
                  onSelected: (val) {
                    if (val) widget.onModeChanged(mode);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _daysCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'analysis.transit_time_days'.tr(),
                      prefixIcon: const Icon(Icons.schedule_rounded, size: 18),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      final n = int.tryParse(val.trim());
                      if (n != null && n > 0) widget.onDaysChanged(n);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('analysis.fragile_cargo'.tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    subtitle: Text('analysis.fragile_subtitle'.tr(), style: const TextStyle(fontSize: 10)),
                    value: widget.isFragile,
                    activeThumbColor: AppTheme.primaryTeal,
                    onChanged: widget.onFragileChanged,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
