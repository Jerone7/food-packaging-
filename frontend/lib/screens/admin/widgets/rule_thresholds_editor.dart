import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/gradient_button.dart';

/// Interactive Scientific Rules & Heuristic Thresholds Editor (Module 15)
class RuleThresholdsEditor extends StatefulWidget {
  final RuleThresholdConfigModel initialRules;
  final Future<void> Function(RuleThresholdConfigModel rules) onSave;

  const RuleThresholdsEditor({
    super.key,
    required this.initialRules,
    required this.onSave,
  });

  @override
  State<RuleThresholdsEditor> createState() => _RuleThresholdsEditorState();
}

class _RuleThresholdsEditorState extends State<RuleThresholdsEditor> {
  late double _lipidFat;
  late double _respirationMoisture;
  late double _acidicPh;
  late double _chillingBuffer;
  late double _headspaceMin;
  late double _headspaceMax;
  late double _ecoMultiplier;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFromModel(widget.initialRules);
  }

  @override
  void didUpdateWidget(covariant RuleThresholdsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRules != widget.initialRules) {
      _loadFromModel(widget.initialRules);
    }
  }

  void _loadFromModel(RuleThresholdConfigModel rules) {
    _lipidFat = rules.lipidOxidationFatThresholdPct;
    _respirationMoisture = rules.highRespirationMoistureThresholdPct;
    _acidicPh = rules.acidicCorrosionPhThreshold;
    _chillingBuffer = rules.chillingInjuryBufferC;
    _headspaceMin = rules.gasCushionHeadspaceMinPct;
    _headspaceMax = rules.gasCushionHeadspaceMaxPct;
    _ecoMultiplier = rules.ecoPriorityMultiplier;
  }

  void _resetDefaults() {
    setState(() {
      _loadFromModel(const RuleThresholdConfigModel());
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updated = RuleThresholdConfigModel(
        lipidOxidationFatThresholdPct: double.parse(_lipidFat.toStringAsFixed(1)),
        highRespirationMoistureThresholdPct: double.parse(_respirationMoisture.toStringAsFixed(1)),
        acidicCorrosionPhThreshold: double.parse(_acidicPh.toStringAsFixed(2)),
        chillingInjuryBufferC: double.parse(_chillingBuffer.toStringAsFixed(1)),
        gasCushionHeadspaceMinPct: double.parse(_headspaceMin.toStringAsFixed(1)),
        gasCushionHeadspaceMaxPct: double.parse(_headspaceMax.toStringAsFixed(1)),
        ecoPriorityMultiplier: double.parse(_ecoMultiplier.toStringAsFixed(2)),
      );
      await widget.onSave(updated);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.rule_folder_rounded, color: AppTheme.primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Scientific Rule Thresholds',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Runtime tuning for biochemical recommendation heuristics',
                          style: TextStyle(fontSize: 12, color: AppTheme.slateBody),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _resetDefaults,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset Defaults', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          // Sliders Grid / Column
          _buildSliderTile(
            title: 'Lipid Oxidation Fat Threshold',
            subtitle: 'Enforces metallized high-barrier film (OTR < 1.5) when fat % exceeds this value.',
            valueText: '${_lipidFat.toStringAsFixed(1)}%',
            value: _lipidFat,
            min: 5.0,
            max: 50.0,
            onChanged: (v) => setState(() => _lipidFat = v),
          ),
          const SizedBox(height: 16),

          _buildSliderTile(
            title: 'High Respiration Moisture Threshold',
            subtitle: 'Requires micro-perforated bio-film (EMAP) or breathable kraft boxes above this moisture %.',
            valueText: '${_respirationMoisture.toStringAsFixed(1)}%',
            value: _respirationMoisture,
            min: 50.0,
            max: 95.0,
            onChanged: (v) => setState(() => _respirationMoisture = v),
          ),
          const SizedBox(height: 16),

          _buildSliderTile(
            title: 'Acidic Corrosion pH Threshold',
            subtitle: 'Mandates anti-corrosion barrier coatings and non-reactive food-grade liners below this pH.',
            valueText: 'pH ${_acidicPh.toStringAsFixed(2)}',
            value: _acidicPh,
            min: 2.5,
            max: 6.5,
            onChanged: (v) => setState(() => _acidicPh = v),
          ),
          const SizedBox(height: 16),

          _buildSliderTile(
            title: 'Chilling Injury Thermal Buffer',
            subtitle: 'Safety delta (°C) added to commodity chilling limit in cold-chain recommendations.',
            valueText: '+${_chillingBuffer.toStringAsFixed(1)} °C',
            value: _chillingBuffer,
            min: 0.5,
            max: 5.0,
            onChanged: (v) => setState(() => _chillingBuffer = v),
          ),
          const SizedBox(height: 16),

          _buildSliderTile(
            title: 'Gas-Cushion Headspace Target (Min)',
            subtitle: 'Minimum % inert gas volume required for fragile snack cushions.',
            valueText: '${_headspaceMin.toStringAsFixed(0)}%',
            value: _headspaceMin,
            min: 10.0,
            max: 50.0,
            onChanged: (v) => setState(() => _headspaceMin = v),
          ),
          const SizedBox(height: 16),

          _buildSliderTile(
            title: 'Eco-Friendly Score Multiplier',
            subtitle: 'Bonus weight applied to compostable and 100% recyclable substrates in ranking algorithms.',
            valueText: '${_ecoMultiplier.toStringAsFixed(2)}x',
            value: _ecoMultiplier,
            min: 1.0,
            max: 2.5,
            onChanged: (v) => setState(() => _ecoMultiplier = v),
          ),
          const SizedBox(height: 24),

          // Save Button
          Align(
            alignment: Alignment.centerRight,
            child: GradientButton(
              text: 'Save Rule Thresholds',
              icon: Icons.save_rounded,
              isLoading: _isSaving,
              height: 44,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgOffWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  valueText,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryTeal,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: AppTheme.primaryTeal,
              overlayColor: AppTheme.primaryTeal.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
