import 'package:flutter/material.dart';
import '../../../models/sustainability_model.dart';
import 'sustainability_metric_pill.dart';

/// Card rendering Life Cycle Assessment (LCA) embodied carbon, water, and PCR abatement.
class LcaCarbonWaterCard extends StatelessWidget {
  final SustainabilityProfile profile;
  final int batchSize;

  const LcaCarbonWaterCard({
    super.key,
    required this.profile,
    required this.batchSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final indicators = profile.environmentalIndicators;
    final unitCarbonGrams = indicators.carbonFootprintKgCo2ePerUnit * 1000.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.public_rounded, color: Color(0xFF0284C7), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Life Cycle Assessment (LCA) Footprint',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (indicators.pcrCarbonReductionPct > 0)
                SustainabilityMetricPill(
                  label: '-${indicators.pcrCarbonReductionPct.toStringAsFixed(1)}% PCR Carbon',
                  color: const Color(0xFF10B981),
                  icon: Icons.trending_down_rounded,
                  fontSize: 10,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 2x2 Metric Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;

              final carbonTile = _buildMetricBox(
                context,
                title: 'Carbon Footprint (GWP)',
                primaryVal: '${unitCarbonGrams.toStringAsFixed(1)} g',
                primaryUnit: 'CO₂e / unit',
                secondaryVal: '${indicators.carbonFootprintKgCo2eTotalBatch.toStringAsFixed(1)} kg CO₂e',
                secondaryLabel: 'Total for $batchSize units',
                icon: Icons.cloud_outlined,
                color: const Color(0xFFF59E0B),
              );

              final waterTile = _buildMetricBox(
                context,
                title: 'Freshwater Footprint',
                primaryVal: '${indicators.waterFootprintLitersPerUnit.toStringAsFixed(2)} L',
                primaryUnit: 'water / unit',
                secondaryVal: '${indicators.waterFootprintLitersTotalBatch.toStringAsFixed(0)} Liters',
                secondaryLabel: 'Total batch water',
                icon: Icons.water_drop_outlined,
                color: const Color(0xFF0284C7),
              );

              final energyTile = _buildMetricBox(
                context,
                title: 'Primary Energy Demand',
                primaryVal: indicators.embodiedEnergyMjPerKg.toStringAsFixed(1),
                primaryUnit: 'MJ / kg resin',
                secondaryVal: '${profile.wastePotential.unitWasteGrams.toStringAsFixed(1)} g',
                secondaryLabel: 'Unit substrate mass',
                icon: Icons.bolt_rounded,
                color: const Color(0xFF8B5CF6),
              );

              final circularityTile = _buildMetricBox(
                context,
                title: 'Landfill Diversion Rate',
                primaryVal: '${profile.wastePotential.diversionPotentialPct.toStringAsFixed(0)}%',
                primaryUnit: 'diverted',
                secondaryVal: 'MCI: ${profile.wastePotential.circularityIndex.toStringAsFixed(2)} / 1.0',
                secondaryLabel: 'Circularity Indicator',
                icon: Icons.published_with_changes_rounded,
                color: const Color(0xFF10B981),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    carbonTile,
                    const SizedBox(height: 10),
                    waterTile,
                    const SizedBox(height: 10),
                    energyTile,
                    const SizedBox(height: 10),
                    circularityTile,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: carbonTile),
                      const SizedBox(width: 12),
                      Expanded(child: waterTile),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: energyTile),
                      const SizedBox(width: 12),
                      Expanded(child: circularityTile),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    BuildContext context, {
    required String title,
    required String primaryVal,
    required String primaryUnit,
    required String secondaryVal,
    required String secondaryLabel,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                primaryVal,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  primaryUnit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  secondaryVal,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  secondaryLabel,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
