import 'package:flutter/material.dart';
import '../../../../models/food_scientific_profile.dart';
import '../../../../theme/app_theme.dart';

class AtmosphereDynamicsCard extends StatelessWidget {
  final PhysiologicalKinetics kinetics;
  final AtmosphereSensitivities atmosphere;
  final bool ethyleneActionRequired;

  const AtmosphereDynamicsCard({
    super.key,
    required this.kinetics,
    required this.atmosphere,
    this.ethyleneActionRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.air_rounded, size: 16, color: Color(0xFF0284C7)),
                  ),
                  WidgetSpan(child: SizedBox(width: 6)),
                  TextSpan(
                    text: 'Gas Atmosphere & EMAP Kinetics',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                  ),
                ],
              ),
            ),
            if (ethyleneActionRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // Amber Light
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt_rounded, size: 12, color: Color(0xFFD97706)),
                    SizedBox(width: 4),
                    Text(
                      'Ethylene Scavenger',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid of Gas & Metabolic Metrics
        Row(
          children: [
            Expanded(
              child: _metricBox(
                'Respiration Rate (20°C)',
                kinetics.respirationRate20c != null
                    ? '${kinetics.respirationRate20c!.toStringAsFixed(1)} mg CO₂/kg/h'
                    : kinetics.respirationClass,
                'Class: ${kinetics.respirationClass}',
                Icons.speed_rounded,
                const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metricBox(
                'Ethylene Production',
                kinetics.ethyleneProdRate != null
                    ? '${kinetics.ethyleneProdRate!.toStringAsFixed(1)} µL/kg/h'
                    : kinetics.ethyleneProductionClass,
                'Class: ${kinetics.ethyleneProductionClass}',
                Icons.bubble_chart_outlined,
                const Color(0xFF9333EA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _metricBox(
                'Target EMAP Gas Equilibrium',
                atmosphere.targetEmapO2Pct != null
                    ? '${atmosphere.targetEmapO2Pct} O₂ / ${atmosphere.targetEmapCo2Pct ?? "N2"} CO₂'
                    : 'Standard Ambient',
                'O₂ Sensitivity: ${atmosphere.oxygenSensitivity}',
                Icons.science_outlined,
                AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metricBox(
                'CO₂ Injury Threshold',
                atmosphere.maxTolerableCo2Pct != null
                    ? 'Max ${atmosphere.maxTolerableCo2Pct!.toStringAsFixed(0)}% CO₂'
                    : 'Tolerant',
                'Sensitivity: ${atmosphere.co2Sensitivity}',
                Icons.warning_amber_rounded,
                const Color(0xFFEA580C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricBox(String title, String mainVal, String subVal, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            mainVal,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subVal,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
