import 'package:flutter/material.dart';
import '../../../models/sustainability_model.dart';
import 'sustainability_metric_pill.dart';

/// Side-by-side comparison table contrasting alternative materials across sustainability criteria.
class SustainabilityComparisonMatrix extends StatelessWidget {
  final SustainabilityCompareResult compareResult;

  const SustainabilityComparisonMatrix({
    super.key,
    required this.compareResult,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.balance_rounded, color: Color(0xFF0D9488), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Multi-Material Sustainability Benchmark',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Eco Trade-Off Summary Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF0D9488)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    compareResult.ecoTradeoffSummary,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: isDark ? Colors.grey[200] : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Scrollable Comparative Matrix Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: compareResult.materials.map((mat) {
                final isLowestCarbon = mat.materialId == compareResult.lowestCarbonMaterialId;
                final isBestRec = mat.materialId == compareResult.bestRecyclabilityMaterialId;
                final isLowestWaste = mat.materialId == compareResult.lowestWasteMaterialId;

                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLowestCarbon
                          ? const Color(0xFF10B981)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      width: isLowestCarbon ? 1.8 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mat.materialName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mat.resinIdentificationCode,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Badges
                      if (isLowestCarbon)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: SustainabilityMetricPill(
                            label: 'Lowest Carbon 🏆',
                            color: Color(0xFF10B981),
                            fontSize: 10,
                          ),
                        ),
                      if (isBestRec && !isLowestCarbon)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: SustainabilityMetricPill(
                            label: 'Best Recyclability ♻️',
                            color: Color(0xFF0284C7),
                            fontSize: 10,
                          ),
                        ),

                      _buildRow('Recyclability', mat.recyclability.label, mat.recyclability.color, isDark),
                      const SizedBox(height: 4),
                      _buildRow('Biodegradability', mat.biodegradability.label, mat.biodegradability.color, isDark),
                      const SizedBox(height: 4),
                      _buildRow('Reusability', mat.reusability.label, mat.reusability.color, isDark),
                      const SizedBox(height: 8),

                      Divider(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06), height: 1),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Carbon (GWP)',
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(mat.environmentalIndicators.carbonFootprintKgCo2ePerUnit * 1000.0).toStringAsFixed(1)} g',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Solid Waste',
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${mat.wastePotential.unitWasteGrams.toStringAsFixed(1)} g',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String val, Color color, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            val,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
