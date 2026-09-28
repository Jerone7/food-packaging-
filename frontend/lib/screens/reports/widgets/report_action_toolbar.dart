/// Report Action Toolbar Widget (Module 12: Recommendation Report).
/// Provides sticky or inline multi-format export buttons: Download PDF,
/// Print Spooler, Copy Technical Markdown, and Copy ERP JSON.
library;

import 'package:flutter/material.dart';
import '../../../models/recommendation_report_model.dart';
import '../../../services/report_export_service.dart';

class ReportActionToolbar extends StatefulWidget {
  final RecommendationReportModel report;

  const ReportActionToolbar({
    super.key,
    required this.report,
  });

  @override
  State<ReportActionToolbar> createState() => _ReportActionToolbarState();
}

class _ReportActionToolbarState extends State<ReportActionToolbar> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 1. Download PDF Button
          ElevatedButton.icon(
            onPressed: _isExporting ? null : () => _handlePdfDownload(context),
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
            label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669), // Emerald
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),

          // 2. Print Spooler Button
          OutlinedButton.icon(
            onPressed: _isExporting ? null : () => _handlePrint(context),
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text('Print Report', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F766E), // Teal
              side: const BorderSide(color: Color(0xFF0F766E), width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          // 3. Copy Markdown Spec
          TextButton.icon(
            onPressed: _isExporting ? null : () => _handleCopyMarkdown(context),
            icon: const Icon(Icons.content_copy_rounded, size: 15),
            label: const Text('Copy Markdown', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              backgroundColor: const Color(0xFFF1F5F9),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          // 4. Copy JSON Payload
          TextButton.icon(
            onPressed: _isExporting ? null : () => _handleCopyJson(context),
            icon: const Icon(Icons.data_object_rounded, size: 15),
            label: const Text('Copy JSON', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              backgroundColor: const Color(0xFFF1F5F9),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePdfDownload(BuildContext context) async {
    setState(() => _isExporting = true);
    await ReportExportService.downloadPdf(context, widget.report);
    if (mounted) setState(() => _isExporting = false);
  }

  Future<void> _handlePrint(BuildContext context) async {
    setState(() => _isExporting = true);
    await ReportExportService.printReport(context, widget.report);
    if (mounted) setState(() => _isExporting = false);
  }

  Future<void> _handleCopyMarkdown(BuildContext context) async {
    await ReportExportService.copyMarkdownSpec(context, widget.report);
  }

  Future<void> _handleCopyJson(BuildContext context) async {
    await ReportExportService.copyJsonPayload(context, widget.report);
  }
}
