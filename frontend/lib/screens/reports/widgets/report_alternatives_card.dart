/// Report Alternatives Card Widget (Module 12: Recommendation Report).
/// Renders 3-way multi-material benchmark table (Eco-Champion, Economy, High-Barrier)
/// with cost and eco deltas, strategic trade-offs, and star ratings.
library;

import 'package:flutter/material.dart';
import '../../../models/recommendation_report_model.dart';
import '../../../theme/app_theme.dart';

class ReportAlternativesCard extends StatelessWidget {
  final List<ReportAlternativePackaging> alternatives;

  const ReportAlternativesCard({
    super.key,
    required this.alternatives,
  });

  @override
  Widget build(BuildContext context) {
    if (alternatives.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1), // Amber
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.compare_arrows_rounded, size: 16, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '3-Way Multi-Material Alternatives Benchmark',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slateDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...alternatives.map((alt) => _buildAlternativeItem(alt)),
        ],
      ),
    );
  }

  Widget _buildAlternativeItem(ReportAlternativePackaging alt) {
    final costSign = alt.costDeltaPct > 0 ? '+' : '';
    final ecoSign = alt.ecoDeltaPct > 0 ? '+' : '';

    final isEco = alt.tierName.toLowerCase().contains('eco');
    final isEcon = alt.tierName.toLowerCase().contains('econ');

    final tierColor = isEco
        ? const Color(0xFF059669)
        : (isEcon ? const Color(0xFF0284C7) : const Color(0xFF7C3AED));

    final tierBg = tierColor.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
              // Tier Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tierBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alt.tierName,
                  style: TextStyle(
                    color: tierColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < alt.starRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14,
                    color: index < alt.starRating ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            alt.materialName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.slateDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            alt.keyTradeoff,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppTheme.slateBody,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildDeltaChip(
                'Cost Delta: $costSign${alt.costDeltaPct.toStringAsFixed(1)}%',
                alt.costDeltaPct <= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
              _buildDeltaChip(
                'Eco Delta: $ecoSign${alt.ecoDeltaPct.toStringAsFixed(1)}%',
                alt.ecoDeltaPct >= 0 ? const Color(0xFF059669) : const Color(0xFFD97706),
              ),
              _buildDeltaChip(
                alt.shelfLifeDelta,
                AppTheme.slateBody,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeltaChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
