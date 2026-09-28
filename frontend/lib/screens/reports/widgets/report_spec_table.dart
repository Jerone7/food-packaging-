/// Report Spec Table Widget (Module 12: Recommendation Report).
/// Presents side-by-side or stacked metric grids for food biochemical degradation vectors
/// and prescribed primary barrier physical specifications.
library;

import 'package:flutter/material.dart';
import '../../../models/recommendation_report_model.dart';
import '../../../theme/app_theme.dart';

class ReportSpecTable extends StatelessWidget {
  final RecommendationReportModel report;

  const ReportSpecTable({
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
              Expanded(child: _buildBiochemCard(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildPrescriptionCard(context)),
            ],
          );
        }

        return Column(
          children: [
            _buildBiochemCard(context),
            const SizedBox(height: 16),
            _buildPrescriptionCard(context),
          ],
        );
      },
    );
  }

  Widget _buildBiochemCard(BuildContext context) {
    final fp = report.foodProperties;

    return Container(
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
                  color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science_outlined, size: 16, color: Color(0xFF0F766E)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Biochemical Degradation Profile',
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
          _buildMetricRow('Moisture Content', fp.moisturePct != null ? '${fp.moisturePct!.toStringAsFixed(1)}%' : 'N/A'),
          _buildMetricRow('Water Activity (aw)', fp.waterActivityAw != null ? fp.waterActivityAw!.toStringAsFixed(2) : 'N/A'),
          _buildMetricRow('pH Acidity', fp.phLevel != null ? fp.phLevel!.toStringAsFixed(2) : 'N/A'),
          _buildMetricRow('Lipid / Fat Content', fp.fatPct != null ? '${fp.fatPct!.toStringAsFixed(1)}%' : 'N/A'),
          _buildMetricRow('Respiration Rate', fp.respirationClass ?? 'Non-respiring'),
          _buildMetricRow('Oxygen Sensitivity', fp.oxygenSensitivity, isHighlight: true),
          _buildMetricRow('Moisture Sensitivity', fp.moistureSensitivity, isHighlight: true, isLast: true),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(BuildContext context) {
    final rx = report.primaryPrescription;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCFBF1)), // Mint border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.06),
            blurRadius: 12,
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
                child: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF059669)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rx.materialName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.slateDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      rx.structure,
                      style: const TextStyle(fontSize: 11, color: AppTheme.slateBody),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMetricRow('Gauge Thickness', '${rx.thicknessMicrons.toStringAsFixed(1)} µm (ASTM D6988)', isHighlight: true),
          _buildMetricRow('Oxygen Transmission (OTR)', rx.otr),
          _buildMetricRow('Water Vapor Trans. (WVTR)', rx.wvtr),
          _buildMetricRow('Tensile Strength', '${rx.tensileStrengthMpa.toStringAsFixed(1)} MPa (ISO 527-3)'),
          _buildMetricRow('Puncture Resistance', '${rx.punctureResistanceN.toStringAsFixed(1)} N (ASTM F1306)'),
          _buildMetricRow('Package Dimensions', rx.dimensions),
          _buildMetricRow('Prescription Suitability', '${(rx.suitabilityScore * 100.0).toStringAsFixed(1)}%', isHighlight: true, isLast: true),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value, {
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
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                color: isHighlight ? const Color(0xFF0F766E) : AppTheme.slateDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
