import 'package:flutter/material.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/theme/app_theme.dart';

/// Characteristics Mini Grid Widget (Module 8).
/// Displays 4 key engineering characteristics (OTR, WVTR, Eco-Rating, Unit Cost) with relative delta badges.
class CharacteristicsMiniGrid extends StatelessWidget {
  final MaterialCharacteristics characteristics;
  final double? costDeltaPct;
  final double? ecoDeltaPct;

  const CharacteristicsMiniGrid({
    super.key,
    required this.characteristics,
    this.costDeltaPct,
    this.ecoDeltaPct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTile(
                icon: Icons.air_rounded,
                label: 'OXYGEN BARRIER (OTR)',
                value: characteristics.otr,
                color: const Color(0xFF0284C7), // Sky Blue
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTile(
                icon: Icons.water_drop_outlined,
                label: 'MOISTURE (WVTR)',
                value: characteristics.wvtr,
                color: const Color(0xFF0D9488), // Teal
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                icon: Icons.eco_rounded,
                label: 'SUSTAINABILITY',
                value: characteristics.sustainabilityRating,
                deltaPct: ecoDeltaPct,
                deltaLabel: 'Eco',
                color: AppTheme.emeraldEco,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTile(
                icon: Icons.currency_rupee_rounded,
                label: 'ESTIMATED COST',
                value: '₹${characteristics.estimatedCostInr.toStringAsFixed(2)}',
                subValue: characteristics.costTier,
                deltaPct: costDeltaPct,
                deltaLabel: 'Cost',
                color: const Color(0xFFD97706), // Amber
                isCost: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    double? deltaPct,
    String? deltaLabel,
    required Color color,
    bool isCost = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (deltaPct != null && deltaPct != 0.0) ...[
                const SizedBox(width: 4),
                _buildDeltaPill(deltaPct, deltaLabel ?? '', isCost: isCost),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          if (subValue != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subValue,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeltaPill(double deltaPct, String label, {bool isCost = false}) {
    final isPositive = deltaPct > 0;
    final sign = isPositive ? '+' : '';
    // For eco: positive is good (emerald), negative is lower (amber/slate)
    // For cost: negative is savings (emerald), positive is higher cost (amber)
    final bool isGood = isCost ? !isPositive : isPositive;
    final bg = isGood ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB);
    final textCol = isGood ? const Color(0xFF059669) : const Color(0xFFB45309);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$sign${deltaPct.toStringAsFixed(0)}% $label',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: textCol,
        ),
      ),
    );
  }
}
