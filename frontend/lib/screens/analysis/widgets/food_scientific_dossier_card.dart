import 'package:flutter/material.dart';
import '../../../../models/food_scientific_profile.dart';
import '../../../../models/storage_condition.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/modern_card.dart';
import 'sensitivity_radar_badge.dart';
import 'thermal_stability_gauge.dart';
import 'atmosphere_dynamics_card.dart';

class FoodScientificDossierCard extends StatefulWidget {
  final FoodScientificProfile profile;
  final StorageMode? currentStorageMode;
  final bool initialExpanded;

  const FoodScientificDossierCard({
    super.key,
    required this.profile,
    this.currentStorageMode,
    this.initialExpanded = true,
  });

  @override
  State<FoodScientificDossierCard> createState() => _FoodScientificDossierCardState();
}

class _FoodScientificDossierCardState extends State<FoodScientificDossierCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return ModernCard(
      backgroundColor: Colors.white,
      borderColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Accordion Row
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
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
                          child: const Icon(Icons.biotech_rounded, size: 20, color: AppTheme.primaryTeal),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Auto-Retrieved Scientific Dossier',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.slateDark,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.auto_awesome_rounded, size: 14, color: AppTheme.primaryTeal),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.source,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.emeraldEco.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${(p.confidenceScore * 100).toInt()}% Confidence',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.emeraldEco),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.slateBody,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // 1. 6-Vector Vulnerability Radar Badges
            const Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.radar_rounded, size: 15, color: AppTheme.primaryTeal),
                  ),
                  WidgetSpan(child: SizedBox(width: 6)),
                  TextSpan(
                    text: 'Degradation Vulnerability Matrix',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SensitivityRadarBadge(
                  label: 'Oxygen (O₂)',
                  level: p.atmosphereSensitivities.oxygenSensitivity,
                  icon: Icons.grain_rounded,
                ),
                SensitivityRadarBadge(
                  label: 'Ethylene (C₂H₄)',
                  level: p.physiologicalKinetics.ethyleneSensitivity,
                  icon: Icons.bubble_chart_rounded,
                ),
                SensitivityRadarBadge(
                  label: 'Moisture',
                  level: p.physicochemical.moistureSensitivity,
                  icon: Icons.water_drop_outlined,
                ),
                SensitivityRadarBadge(
                  label: 'Mechanical',
                  level: p.spoilageAndVulnerabilities.mechanicalSensitivity,
                  icon: Icons.shield_outlined,
                ),
                SensitivityRadarBadge(
                  label: 'Light / UV',
                  level: p.spoilageAndVulnerabilities.lightSensitivity,
                  icon: Icons.wb_sunny_outlined,
                ),
                SensitivityRadarBadge(
                  label: 'Aroma Scalping',
                  level: p.spoilageAndVulnerabilities.aromaSensitivity,
                  icon: Icons.air_rounded,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // 2. Gas Kinetics & EMAP Card
            AtmosphereDynamicsCard(
              kinetics: p.physiologicalKinetics,
              atmosphere: p.atmosphereSensitivities,
              ethyleneActionRequired: p.packagingPrescriptions.ethyleneActionRequired,
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // 3. Thermal Stability & Chilling Safety Gauge
            ThermalStabilityGauge(
              thermalData: p.thermalAndStorage,
              currentStorageMode: widget.currentStorageMode,
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // 4. Microbial Spoilage Vector & Prescriptions
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.bug_report_outlined, size: 15, color: Color(0xFF9333EA)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 11, color: AppTheme.slateDark),
                            children: [
                              TextSpan(
                                text: 'Spoilage Vector: ',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                              ),
                              TextSpan(
                                text: p.spoilageAndVulnerabilities.microbialSpoilageVector,
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.layers_outlined, size: 15, color: AppTheme.primaryTeal),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Derived Barrier Mandate: ${p.packagingPrescriptions.recommendedBarrierType} (OTR: ${p.packagingPrescriptions.requiredOtrRange}, WVTR: ${p.packagingPrescriptions.requiredWvtrRange})',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
