/// Vector PDF Report Builder (Module 12: Recommendation Report).
/// Generates enterprise-grade A4 / Letter PDF specification sheets with
/// emerald branding, structured metric grids, 3-way benchmark matrices,
/// and cryptographic provenance verification.
library;

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/recommendation_report_model.dart';

class PdfReportBuilder {
  // Brand Color Tokens for PDF Canvas
  static const PdfColor primaryDark = PdfColor.fromInt(0xFF064E3B); // Deep Emerald
  static const PdfColor primaryTeal = PdfColor.fromInt(0xFF0D9488); // Teal
  static const PdfColor accentGreen = PdfColor.fromInt(0xFF10B981); // Emerald Green
  static const PdfColor charcoal = PdfColor.fromInt(0xFF0F172A); // Slate 900
  static const PdfColor slateGrey = PdfColor.fromInt(0xFF475569); // Slate 600
  static const PdfColor lightGreyBg = PdfColor.fromInt(0xFFF8FAFC); // Slate 50
  static const PdfColor borderGrey = PdfColor.fromInt(0xFFE2E8F0); // Slate 200

  /// Compiles a complete RecommendationReportModel into raw binary vector PDF bytes.
  static Future<Uint8List> buildPdf(
    RecommendationReportModel report, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final doc = pw.Document(
      title: 'SmartPack AI Specification Report - ${report.reportId}',
      author: 'SmartPack AI Enterprise Engine',
    );

    // Multi-page layout
    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(report, context),
        footer: (context) => _buildFooter(report, context),
        build: (context) => [
          _buildCommodityAndBiochemSection(report),
          pw.SizedBox(height: 12),
          _buildPrescriptionSection(report),
          pw.SizedBox(height: 12),
          _buildXaiSection(report),
          pw.SizedBox(height: 12),
          _buildAlternativesBenchmarkSection(report),
          pw.SizedBox(height: 12),
          _buildLcaAndCostSection(report),
          pw.SizedBox(height: 12),
          _buildComplianceAndCitations(report),
        ],
      ),
    );

    return doc.save();
  }

  // --------------------------------------------------------------------------
  // Header & Footer Builders
  // --------------------------------------------------------------------------

  static pw.Widget _buildHeader(RecommendationReportModel report, pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: primaryDark,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SMARTPACK AI - ENTERPRISE SPECIFICATION REPORT',
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Commodity: ${report.foodContext.name} | Batch: ${NumberFormat('#,###').format(report.foodContext.batchSizeUnits)} units',
                style: const pw.TextStyle(
                  color: PdfColor.fromInt(0xFF99F6E4), // Teal 200
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const pw.BoxDecoration(
                  color: primaryTeal,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  report.reportId,
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '${DateFormat('yyyy-MM-dd HH:mm').format(report.generatedAt)} UTC',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 7.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(RecommendationReportModel report, pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderGrey, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Verification SHA-256: ${report.verificationHash.length >= 16 ? report.verificationHash.substring(0, 16) : report.verificationHash}... | ${report.engineVersion}',
            style: const pw.TextStyle(color: slateGrey, fontSize: 6.5),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(color: slateGrey, fontSize: 6.5, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Body Content Sections
  // --------------------------------------------------------------------------

  static pw.Widget _buildCommodityAndBiochemSection(RecommendationReportModel report) {
    final fc = report.foodContext;
    final fp = report.foodProperties;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: lightGreyBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderGrey, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(width: 3, height: 12, color: primaryTeal),
              pw.SizedBox(width: 6),
              pw.Text(
                '1. FOOD COMMODITY & BIOCHEMICAL PROFILE',
                style: const pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: charcoal),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Column 1: Operational context
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildMetaRow('Commodity Name', fc.name, isBold: true),
                    _buildMetaRow('Category', fc.category),
                    _buildMetaRow('Unit Fill Quantity', fc.fillQuantity),
                    _buildMetaRow('Target Shelf Life', '${fc.storageDurationDays} days', isBold: true),
                    _buildMetaRow('Storage Regimen', '${fc.storageCondition} (${fc.storageTempC != null ? "${fc.storageTempC!.toStringAsFixed(1)}°C" : "Ambient"})'),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              // Column 2: Biochemical characteristics
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildMetaRow('Moisture Content', fp.moisturePct != null ? '${fp.moisturePct!.toStringAsFixed(1)}%' : 'N/A'),
                    _buildMetaRow('Water Activity (aw)', fp.waterActivityAw != null ? fp.waterActivityAw!.toStringAsFixed(2) : 'N/A'),
                    _buildMetaRow('pH / Acid Level', fp.phLevel != null ? fp.phLevel!.toStringAsFixed(2) : 'N/A'),
                    _buildMetaRow('Fat / Lipid Content', fp.fatPct != null ? '${fp.fatPct!.toStringAsFixed(1)}%' : 'N/A'),
                    _buildMetaRow('Oxygen Sensitivity', fp.oxygenSensitivity, isBold: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPrescriptionSection(RecommendationReportModel report) {
    final rx = report.primaryPrescription;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: lightGreyBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderGrey, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(width: 3, height: 12, color: accentGreen),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    '2. PRIMARY PRESCRIBED PACKAGING SPECIFICATION',
                    style: const pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: charcoal),
                  ),
                ],
              ),
              pw.Text(
                'Suitability Score: ${(rx.suitabilityScore * 100.0).toStringAsFixed(1)}%',
                style: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: primaryDark),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              border: pw.Border.all(color: borderGrey, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  rx.materialName.replaceAll('™', '(TM)'),
                  style: const pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: charcoal),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Polymer Family: ${rx.polymerFamily} | Structure: ${rx.structure} | Format: ${rx.packageFormat}',
                  style: const pw.TextStyle(fontSize: 7.5, color: slateGrey),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          // 4-Column barrier grid
          pw.Row(
            children: [
              _buildBarrierMetricBox('THICKNESS GAUGE', '${rx.thicknessMicrons.toStringAsFixed(1)} um', 'ASTM D6988'),
              pw.SizedBox(width: 6),
              _buildBarrierMetricBox('OXYGEN TRANSMISSION', rx.otr, 'ASTM F1927'),
              pw.SizedBox(width: 6),
              _buildBarrierMetricBox('WATER VAPOR TRANS.', rx.wvtr, 'ASTM F1249'),
              pw.SizedBox(width: 6),
              _buildBarrierMetricBox('TENSILE STRENGTH', '${rx.tensileStrengthMpa.toStringAsFixed(1)} MPa', 'ISO 527-3'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildXaiSection(RecommendationReportModel report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF0FDF4), // Emerald 50
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFBBF7D0), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '3. EXPLAINABLE AI (XAI) PRESCRIPTION RATIONALE',
            style: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: primaryDark),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            report.explainableRationale.replaceAll('•', '-'),
            style: const pw.TextStyle(fontSize: 7.5, color: charcoal, lineSpacing: 1.3),
          ),
          if (report.keyDrivers.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            ...report.keyDrivers.map(
              (d) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('- ', style: const pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryTeal)),
                    pw.Expanded(
                      child: pw.Text(d.replaceAll('•', '-'), style: const pw.TextStyle(fontSize: 7.5, color: slateGrey)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildAlternativesBenchmarkSection(RecommendationReportModel report) {
    if (report.alternatives.isEmpty) return pw.SizedBox.shrink();

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: lightGreyBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderGrey, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(width: 3, height: 12, color: const PdfColor.fromInt(0xFFD97706)), // Amber
              pw.SizedBox(width: 6),
              pw.Text(
                '4. 3-WAY MULTI-MATERIAL COMPARATIVE BENCHMARK',
                style: const pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: charcoal),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: borderGrey, width: 0.5),
            children: [
              // Table Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
                children: [
                  _buildTableCell('Tier', isHeader: true, flex: 2),
                  _buildTableCell('Alternative Substrate', isHeader: true, flex: 3),
                  _buildTableCell('Strategic Trade-off', isHeader: true, flex: 4),
                  _buildTableCell('Cost Delta', isHeader: true, flex: 2),
                  _buildTableCell('Eco Delta', isHeader: true, flex: 2),
                ],
              ),
              // Data Rows
              ...report.alternatives.map((alt) {
                final costSign = alt.costDeltaPct > 0 ? '+' : '';
                final ecoSign = alt.ecoDeltaPct > 0 ? '+' : '';
                return pw.TableRow(
                  children: [
                    _buildTableCell(alt.tierName, isBold: true, flex: 2),
                    _buildTableCell(alt.materialName.replaceAll('™', '(TM)'), flex: 3),
                    _buildTableCell(alt.keyTradeoff.replaceAll('•', '-'), flex: 4),
                    _buildTableCell('$costSign${alt.costDeltaPct.toStringAsFixed(1)}%', flex: 2),
                    _buildTableCell('$ecoSign${alt.ecoDeltaPct.toStringAsFixed(1)}%', flex: 2),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildLcaAndCostSection(RecommendationReportModel report) {
    final lca = report.lcaSummary;
    final cost = report.costSummary;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Sustainability & LCA Card
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: lightGreyBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: borderGrey, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(width: 3, height: 10, color: accentGreen),
                    pw.SizedBox(width: 4),
                    pw.Text('5. SUSTAINABILITY & LCA IMPACT', style: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: charcoal)),
                  ],
                ),
                pw.SizedBox(height: 6),
                _buildMetaRow('Carbon (Unit)', '${lca.carbonFootprintGPerUnit.toStringAsFixed(2)} g CO2e', isBold: true),
                _buildMetaRow('Carbon (Batch)', '${lca.carbonFootprintBatchKg.toStringAsFixed(2)} kg CO2e'),
                _buildMetaRow('PCR Recycled Content', '${lca.pcrPercentage.toStringAsFixed(0)}% (${lca.pcrCarbonReductionPct.toStringAsFixed(1)}% reduction)'),
                _buildMetaRow('Freshwater Footprint', '${lca.waterFootprintLPerUnit.toStringAsFixed(2)} L / pack'),
                _buildMetaRow('Circularity Index (MCI)', '${lca.circularityIndexMci.toStringAsFixed(2)} / 1.00', isBold: true),
                _buildMetaRow('Recyclability Tier', '${lca.recyclabilityTier} (${lca.resinIdentificationCode})'),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        // Converter Cost Economics Card
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: lightGreyBg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: borderGrey, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(width: 3, height: 10, color: primaryTeal),
                    pw.SizedBox(width: 4),
                    pw.Text('6. CONVERTER COST ECONOMICS', style: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: charcoal)),
                  ],
                ),
                pw.SizedBox(height: 6),
                _buildMetaRow('Estimated Unit Cost', 'INR ${cost.estimatedCostPerUnitInr.toStringAsFixed(2)} / pack', isBold: true),
                _buildMetaRow('Total Batch Cost', 'INR ${NumberFormat('#,##0.00').format(cost.estimatedBatchCostInr)}', isBold: true),
                _buildMetaRow('Gross Mass per Pack', '${cost.grossMaterialMassGrams.toStringAsFixed(2)} grams'),
                _buildMetaRow('Batch Substrate Reqd', '${cost.grossMaterialMassBatchKg.toStringAsFixed(2)} kg film'),
                _buildMetaRow('Pouch Surface Area', '${cost.filmSurfaceAreaSqm.toStringAsFixed(4)} m2'),
                _buildMetaRow('Currency Baseline', cost.currency),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildComplianceAndCitations(RecommendationReportModel report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderGrey, width: 0.5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'REGULATORY COMPLIANCE, TEST STANDARDS & PEER-REVIEWED CITATIONS',
            style: const pw.TextStyle(fontSize: 7.0, fontWeight: pw.FontWeight.bold, color: slateGrey),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            report.standardsAndCitations.join(' | '),
            style: const pw.TextStyle(fontSize: 6.5, color: slateGrey, lineSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Reusable Helper Widgets
  // --------------------------------------------------------------------------

  static pw.Widget _buildMetaRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: slateGrey)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: charcoal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBarrierMetricBox(String title, String value, String standard) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          border: pw.Border.all(color: borderGrey, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: const pw.TextStyle(fontSize: 5.5, color: slateGrey)),
            pw.SizedBox(height: 2),
            pw.Text(value, style: const pw.TextStyle(fontSize: 8.0, fontWeight: pw.FontWeight.bold, color: charcoal)),
            pw.SizedBox(height: 1),
            pw.Text(standard, style: const pw.TextStyle(fontSize: 5.0, color: slateGrey)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false, int flex = 1}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 7.0 : 6.5,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? charcoal : slateGrey,
        ),
      ),
    );
  }
}
