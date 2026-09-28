import 'package:flutter/material.dart';
import '../../../../models/food_commodity.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';
import '../../../../widgets/modern_card.dart';

class FoodProfileCard extends StatefulWidget {
  final FoodCommodity food;
  final BiochemicalProfile currentProfile;
  final ValueChanged<BiochemicalProfile> onProfileChanged;

  const FoodProfileCard({
    super.key,
    required this.food,
    required this.currentProfile,
    required this.onProfileChanged,
  });

  @override
  State<FoodProfileCard> createState() => _FoodProfileCardState();
}

class _FoodProfileCardState extends State<FoodProfileCard> {
  bool _isCustomizing = false;
  late TextEditingController _moistureCtrl;
  late TextEditingController _fatCtrl;
  late TextEditingController _phCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant FoodProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.food != widget.food) {
      _updateControllers();
      if (!widget.currentProfile.isCustomOverride) {
        setState(() => _isCustomizing = false);
      }
    } else if (oldWidget.currentProfile != widget.currentProfile) {
      _updateControllers();
    }
  }

  void _initControllers() {
    _moistureCtrl = TextEditingController(text: widget.currentProfile.moisture.toStringAsFixed(1));
    _fatCtrl = TextEditingController(text: widget.currentProfile.fat.toStringAsFixed(1));
    _phCtrl = TextEditingController(text: widget.currentProfile.ph.toStringAsFixed(1));
  }

  void _updateControllers() {
    _moistureCtrl.text = widget.currentProfile.moisture.toStringAsFixed(1);
    _fatCtrl.text = widget.currentProfile.fat.toStringAsFixed(1);
    _phCtrl.text = widget.currentProfile.ph.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _moistureCtrl.dispose();
    _fatCtrl.dispose();
    _phCtrl.dispose();
    super.dispose();
  }

  void _applyOverrides() {
    final m = double.tryParse(_moistureCtrl.text) ?? widget.food.moisture;
    final f = double.tryParse(_fatCtrl.text) ?? widget.food.fat;
    final p = double.tryParse(_phCtrl.text) ?? widget.food.ph;

    widget.onProfileChanged(
      widget.currentProfile.copyWith(
        moisture: m,
        fat: f,
        ph: p,
        isCustomOverride: true,
      ),
    );
  }

  void _resetOverrides() {
    widget.onProfileChanged(widget.food.toBiochemicalProfile());
    _initControllers();
    setState(() => _isCustomizing = false);
  }

  String _localizeCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return 'category.fruits'.tr();
      case 'vegetables':
        return 'category.vegetables'.tr();
      case 'grains':
        return 'category.grains'.tr();
      case 'dairy':
        return 'category.dairy'.tr();
      case 'meat':
        return 'category.meat'.tr();
      case 'bakery':
        return 'category.bakery'.tr();
      case 'other perishables':
      case 'other':
        return 'category.other'.tr();
      default:
        return category;
    }
  }

  String _localizeRespiration(String respClass) {
    switch (respClass.toLowerCase()) {
      case 'low':
        return 'analysis.resp_low'.tr();
      case 'moderate':
        return 'analysis.resp_moderate'.tr();
      case 'high':
        return 'analysis.resp_high'.tr();
      case 'very high':
      case 'very_high':
        return 'analysis.resp_very_high'.tr();
      default:
        return respClass;
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final profile = widget.currentProfile;

    return ModernCard(
      backgroundColor: Colors.white,
      borderColor: AppTheme.borderTeal,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name & Category Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: food.categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(food.categoryIcon, color: food.categoryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slateDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: food.categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: food.categoryColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _localizeCategory(food.category),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: food.categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (food.scientificName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        food.scientificName!,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Biochemical Trait Badges / Metrics
          Row(
            children: [
              _metricTile('analysis.metric_moisture'.tr(), '${profile.moisture.toStringAsFixed(1)}%', Icons.water_drop_outlined, AppTheme.primaryTeal),
              const SizedBox(width: 8),
              _metricTile('analysis.metric_fat'.tr(), '${profile.fat.toStringAsFixed(1)}%', Icons.opacity_rounded, const Color(0xFFD97706)),
              const SizedBox(width: 8),
              _metricTile('analysis.metric_ph'.tr(), profile.ph.toStringAsFixed(1), Icons.science_outlined, const Color(0xFF9333EA)),
              const SizedBox(width: 8),
              _metricTile('analysis.metric_respiration'.tr(), _localizeRespiration(profile.respirationClass), Icons.air_rounded, const Color(0xFF0284C7)),
            ],
          ),

          if (food.recommendedStorage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.bgOffWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.slateBody),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${'analysis.baseline_storage'.tr()} ${food.recommendedStorage!}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.slateBody),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Custom Override Accordion
          InkWell(
            onTap: () => setState(() => _isCustomizing = !_isCustomizing),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _isCustomizing ? Icons.tune_rounded : Icons.tune_outlined,
                          size: 14,
                          color: profile.isCustomOverride ? AppTheme.primaryTeal : AppTheme.slateBody,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            profile.isCustomOverride
                                ? 'analysis.customize_applied'.tr()
                                : 'analysis.customize_params'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: profile.isCustomOverride ? AppTheme.primaryTeal : AppTheme.slateBody,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isCustomizing ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppTheme.slateBody,
                  ),
                ],
              ),
            ),
          ),

          if (_isCustomizing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgOffWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _moistureCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Moisture (%)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _applyOverrides(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fatCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Fat (%)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _applyOverrides(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _phCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'pH',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _applyOverrides(),
                        ),
                      ),
                    ],
                  ),
                  if (profile.isCustomOverride) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: const Text('Reset to Baseline', style: TextStyle(fontSize: 11)),
                        onPressed: _resetOverrides,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
