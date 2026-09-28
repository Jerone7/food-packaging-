/// Report Summary Cards Widget (Module 12: Recommendation Report).
/// Displays side-by-side or stacked cards for Life Cycle Assessment (LCA)
/// environmental indicators and converter cost economics.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/recommendation_report_model.dart';
import '../../../theme/app_theme.dart';

class ReportSummaryCards extends StatelessWidget {
  final RecommendationReportModel report;

  const ReportSummaryCards({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLcaCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildCostCard()),
            ],
          );
        }

        return Column(
          children: [
            _buildLcaCard(),
            const SizedBox(height: 16),
            _buildCostCard(),
          ],
        );
      },
    );
  }

  Widget _buildLcaCard() {
    final lca = report.lcaSummary;
    final fc = report.foodContext;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1FAE5)), // Soft emerald border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.04),
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
                  color: const Color(0xFF059669).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF059669)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Sustainability & LCA Impact',
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
          _buildRow('Embodied Carbon (Unit)', '${lca.carbonFootprintGPerUnit.toStringAsFixed(2)} g CO₂e', isBold: true),
          _buildRow('Total Batch Carbon', '${lca.carbonFootprintBatchKg.toStringAsFixed(2)} kg CO₂e (${NumberFormat('#,###').format(fc.batchSizeUnits)} units)'),
          _buildRow('PCR Recycled Content', '${lca.pcrPercentage.toStringAsFixed(0)}% (${lca.pcrCarbonReductionPct.toStringAsFixed(1)}% carbon reduction)'),
          _buildRow('Freshwater Footprint', '${lca.waterFootprintLPerUnit.toStringAsFixed(2)} L / pack (${lca.waterFootprintBatchLiters.toStringAsFixed(0)} L batch)'),
          _buildRow('Solid Waste Burden', '${lca.unitWasteGrams.toStringAsFixed(2)} g / pack (${lca.totalBatchWasteKg.toStringAsFixed(1)} kg batch)'),
          _buildRow('Circularity Index (MCI)', '${lca.circularityIndexMci.toStringAsFixed(2)} / 1.00', isHighlight: true),
          _buildRow('Landfill Diversion', '${lca.landfillDiversionPct.toStringAsFixed(1)}% potential'),
          _buildRow('Recyclability Tier', '${lca.recyclabilityTier} (${lca.resinIdentificationCode})', isLast: true),
        ],
      ),
    );
  }

  Widget _buildCostCard() {
    final cost = report.costSummary;
    final fc = report.foodContext;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCFBF1)), // Teal border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.04),
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
                  color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.currency_rupee_rounded, size: 16, color: Color(0xFF0F766E)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Converter Cost Economics',
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
          _buildRow('Estimated Unit Cost', '₹${cost.estimatedCostPerUnitInr.toStringAsFixed(2)} / pack', isBold: true, isHighlight: true),
          _buildRow('Total Batch Cost', '₹${NumberFormat('#,##0.00').format(cost.estimatedBatchCostInr)} INR', isBold: true),
          _buildRow('Batch Production Volume', '${NumberFormat('#,###').format(fc.batchSizeUnits)} units'),
          _buildRow('Gross Mass per Pack', '${cost.grossMaterialMassGrams.toStringAsFixed(2)} grams (incl. seams)'),
          _buildRow('Total Film Required', '${cost.grossMaterialMassBatchKg.toStringAsFixed(2)} kg gross substrate'),
          _buildRow('Pouch Blank Surface Area', '${cost.filmSurfaceAreaSqm.toStringAsFixed(4)} m² / pouch'),
          _buildRow('Currency Baseline', cost.currency, isLast: true),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    bool isHighlight = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.5),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.slateBody,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: (isBold || isHighlight) ? FontWeight.w700 : FontWeight.w600,
                color: isHighlight ? const Color(0xFF0F766E) : AppTheme.slateDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
