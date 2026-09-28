import 'package:flutter/material.dart';
import '../../../models/cost_estimation_model.dart';

/// Card showing technical material footprint and mass requirements.
class MaterialFootprintCard extends StatelessWidget {
  final MaterialRequirementDetail materialRequirement;
  final String materialName;

  const MaterialFootprintCard({
    super.key,
    required this.materialRequirement,
    required this.materialName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final areaSqcm = (materialRequirement.surfaceAreaPerUnitSqm * 10000.0).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.architecture, size: 18, color: Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Material Requirement & Technical Footprint',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'Unit Surface Area',
                  value: '$areaSqcm cm²',
                  subValue: '${materialRequirement.surfaceAreaPerUnitSqm.toStringAsFixed(4)} m²',
                  icon: Icons.aspect_ratio,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'Unit Film Mass',
                  value: '${materialRequirement.weightPerUnitGrams.toStringAsFixed(2)} g',
                  subValue: 'Base Gauge Mass',
                  icon: Icons.scale,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'Total Batch Film',
                  value: '${materialRequirement.grossWeightRequiredKg.toStringAsFixed(1)} kg',
                  subValue: '${materialRequirement.grossAreaRequiredSqm.toStringAsFixed(0)} m² Reel',
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'Trim Scrap Margin',
                  value: '${materialRequirement.scrapMaterialWeightKg.toStringAsFixed(1)} kg',
                  subValue: '${materialRequirement.scrapAllowancePercent.toStringAsFixed(0)}% allowance',
                  icon: Icons.content_cut,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required String subValue,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF0D9488)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
