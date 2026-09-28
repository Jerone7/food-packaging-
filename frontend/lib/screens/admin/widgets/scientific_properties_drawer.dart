import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/gradient_button.dart';

/// Modal dialog / drawer for configuring the 14 deep postharvest scientific properties
class ScientificPropertiesDrawer extends StatefulWidget {
  final AdminFoodDetailModel food;
  final Future<void> Function(Map<String, dynamic> payload) onSave;

  const ScientificPropertiesDrawer({
    super.key,
    required this.food,
    required this.onSave,
  });

  @override
  State<ScientificPropertiesDrawer> createState() => _ScientificPropertiesDrawerState();
}

class _ScientificPropertiesDrawerState extends State<ScientificPropertiesDrawer> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _rr20Controller;
  late TextEditingController _rr5Controller;
  late TextEditingController _chillingThresholdController;
  late TextEditingController _optTempMinController;
  late TextEditingController _optTempMaxController;
  late TextEditingController _optRhMinController;
  late TextEditingController _optRhMaxController;
  late TextEditingController _targetO2MinController;
  late TextEditingController _targetCo2MaxController;
  late TextEditingController _ambientShelfLifeController;
  late TextEditingController _refrigShelfLifeController;

  bool _chillingSusceptible = true;
  String _ethyleneProduction = 'Moderate';
  String _ethyleneSensitivity = 'Moderate';
  bool _isSaving = false;

  final List<String> _ethyleneLevels = ['Low', 'Moderate', 'High', 'Very High'];

  @override
  void initState() {
    super.initState();
    final props = widget.food.scientificProperties ?? {};

    _rr20Controller = TextEditingController(text: props['respiration_rate_20c']?.toString() ?? '25.0');
    _rr5Controller = TextEditingController(text: props['respiration_rate_5c']?.toString() ?? '6.5');
    _chillingThresholdController = TextEditingController(text: props['chilling_injury_threshold_c']?.toString() ?? '10.0');
    _optTempMinController = TextEditingController(text: props['optimum_temp_min_c']?.toString() ?? '10.0');
    _optTempMaxController = TextEditingController(text: props['optimum_temp_max_c']?.toString() ?? '13.0');
    _optRhMinController = TextEditingController(text: props['optimum_rh_min_pct']?.toString() ?? '85.0');
    _optRhMaxController = TextEditingController(text: props['optimum_rh_max_pct']?.toString() ?? '95.0');
    _targetO2MinController = TextEditingController(text: props['target_o2_min_pct']?.toString() ?? '3.0');
    _targetCo2MaxController = TextEditingController(text: props['target_co2_max_pct']?.toString() ?? '5.0');
    _ambientShelfLifeController = TextEditingController(text: props['ambient_shelf_life_days']?.toString() ?? '7');
    _refrigShelfLifeController = TextEditingController(text: props['refrigerated_shelf_life_days']?.toString() ?? '21');

    _chillingSusceptible = props['chilling_injury_susceptible'] as bool? ?? true;
    _ethyleneProduction = props['ethylene_production_rate'] as String? ?? 'Moderate';
    _ethyleneSensitivity = props['ethylene_sensitivity'] as String? ?? 'Moderate';
  }

  @override
  void dispose() {
    _rr20Controller.dispose();
    _rr5Controller.dispose();
    _chillingThresholdController.dispose();
    _optTempMinController.dispose();
    _optTempMaxController.dispose();
    _optRhMinController.dispose();
    _optRhMaxController.dispose();
    _targetO2MinController.dispose();
    _targetCo2MaxController.dispose();
    _ambientShelfLifeController.dispose();
    _refrigShelfLifeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final payload = {
        'respiration_rate_20c': double.tryParse(_rr20Controller.text),
        'respiration_rate_5c': double.tryParse(_rr5Controller.text),
        'chilling_injury_threshold_c': double.tryParse(_chillingThresholdController.text),
        'chilling_injury_susceptible': _chillingSusceptible,
        'optimum_temp_min_c': double.tryParse(_optTempMinController.text),
        'optimum_temp_max_c': double.tryParse(_optTempMaxController.text),
        'optimum_rh_min_pct': double.tryParse(_optRhMinController.text),
        'optimum_rh_max_pct': double.tryParse(_optRhMaxController.text),
        'ethylene_production_rate': _ethyleneProduction,
        'ethylene_sensitivity': _ethyleneSensitivity,
        'target_o2_min_pct': double.tryParse(_targetO2MinController.text),
        'target_co2_max_pct': double.tryParse(_targetCo2MaxController.text),
        'ambient_shelf_life_days': int.tryParse(_ambientShelfLifeController.text),
        'refrigerated_shelf_life_days': int.tryParse(_refrigShelfLifeController.text),
      };

      await widget.onSave(payload);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 800),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.biotech_rounded, color: AppTheme.emeraldEco, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Postharvest Scientific Traits',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                          ),
                          Text(
                            widget.food.name,
                            style: const TextStyle(fontSize: 13, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.slateBody),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Respiration & Chilling
                        _buildSectionHeader('Respiration & Chilling Susceptibility', Icons.air_rounded),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumField(
                                controller: _rr20Controller,
                                label: 'RR at 20°C (mg CO2/kg·h)',
                                hint: '32.0',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNumField(
                                controller: _rr5Controller,
                                label: 'RR at 5°C (mg CO2/kg·h)',
                                hint: '8.5',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumField(
                                controller: _chillingThresholdController,
                                label: 'Chilling Injury Threshold (°C)',
                                hint: '10.0',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Chilling Susceptible', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                value: _chillingSusceptible,
                                activeThumbColor: AppTheme.primaryTeal,
                                onChanged: (v) => setState(() => _chillingSusceptible = v ?? true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 2: Optimum Thermal & RH Range
                        _buildSectionHeader('Optimum Temperature & RH Window', Icons.thermostat_rounded),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildNumField(controller: _optTempMinController, label: 'Min Temp (°C)', hint: '10.0')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildNumField(controller: _optTempMaxController, label: 'Max Temp (°C)', hint: '15.0')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildNumField(controller: _optRhMinController, label: 'Min RH (%)', hint: '85.0')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildNumField(controller: _optRhMaxController, label: 'Max RH (%)', hint: '95.0')),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 3: Gas & Atmosphere Targets
                        _buildSectionHeader('Gas Dynamics & Modified Atmosphere (MAP)', Icons.cloud_sync_rounded),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: 'Ethylene Production',
                                value: _ethyleneProduction,
                                items: _ethyleneLevels,
                                onChanged: (v) {
                                  if (v != null) setState(() => _ethyleneProduction = v);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: 'Ethylene Sensitivity',
                                value: _ethyleneSensitivity,
                                items: const ['Low', 'Moderate', 'High'],
                                onChanged: (v) {
                                  if (v != null) setState(() => _ethyleneSensitivity = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildNumField(controller: _targetO2MinController, label: 'Target Min O2 (%)', hint: '3.0')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildNumField(controller: _targetCo2MaxController, label: 'Target Max CO2 (%)', hint: '5.0')),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 4: Shelf Life Expectations
                        _buildSectionHeader('Shelf Life Benchmarks', Icons.timelapse_rounded),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumField(
                                controller: _ambientShelfLifeController,
                                label: 'Ambient Shelf Life (Days)',
                                hint: '7',
                                isInt: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNumField(
                                controller: _refrigShelfLifeController,
                                label: 'Refrigerated Shelf Life (Days)',
                                hint: '21',
                                isInt: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    text: 'Save Scientific Traits',
                    icon: Icons.save_rounded,
                    isLoading: _isSaving,
                    height: 48,
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
        ),
      ],
    );
  }

  Widget _buildNumField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isInt = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateBody),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13, color: AppTheme.slateDark),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.bgOffWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateBody),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: items.contains(value) ? value : items.first,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppTheme.slateDark),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.bgOffWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
