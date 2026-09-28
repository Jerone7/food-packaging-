/// Report Export, Native Print & Clipboard Orchestration Service (Module 12).
/// Provides unified distribution handlers for vector PDF downloads,
/// OS/browser print spooling, Markdown specification copying, and ERP JSON interchange.
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../models/recommendation_report_model.dart';
import 'pdf_report_builder.dart';

class ReportExportService {
  /// Invokes browser or OS native print spooler with vector rendering.
  static Future<bool> printReport(
    BuildContext? context,
    RecommendationReportModel report,
  ) async {
    try {
      final success = await Printing.layoutPdf(
        onLayout: (pageFormat) => PdfReportBuilder.buildPdf(report, pageFormat: pageFormat),
        name: 'SmartPack_Report_${report.reportId}.pdf',
      );

      if (context != null && context.mounted) {
        _showSuccessToast(context, '🖨️ Opening print spooler for ${report.reportId}...');
      }
      return success;
    } catch (e) {
      if (context != null && context.mounted) {
        _showErrorToast(context, 'Failed to launch print spooler: $e');
      }
      return false;
    }
  }

  /// Triggers client file download or OS sharing of vector PDF document.
  static Future<bool> downloadPdf(
    BuildContext? context,
    RecommendationReportModel report, {
    String? filename,
  }) async {
    try {
      final pdfBytes = await PdfReportBuilder.buildPdf(report);
      final targetName = filename ?? 'SmartPack_Report_${report.reportId}.pdf';

      final success = await Printing.sharePdf(
        bytes: pdfBytes,
        filename: targetName,
      );

      if (context != null && context.mounted) {
        _showSuccessToast(context, '📄 Downloaded PDF: $targetName');
      }
      return success;
    } catch (e) {
      if (context != null && context.mounted) {
        _showErrorToast(context, 'Failed to download PDF: $e');
      }
      return false;
    }
  }

  /// Copies formatted GitHub Flavored Markdown specification document to clipboard.
  static Future<bool> copyMarkdownSpec(
    BuildContext? context,
    RecommendationReportModel report,
  ) async {
    try {
      final markdown = report.toMarkdownString();
      await Clipboard.setData(ClipboardData(text: markdown));

      if (context != null && context.mounted) {
        _showSuccessToast(context, '📋 Technical Markdown specification copied to clipboard!');
      }
      return true;
    } catch (e) {
      if (context != null && context.mounted) {
        _showErrorToast(context, 'Failed to copy Markdown: $e');
      }
      return false;
    }
  }

  /// Copies formatted JSON data payload to clipboard for converter/ERP systems.
  static Future<bool> copyJsonPayload(
    BuildContext? context,
    RecommendationReportModel report,
  ) async {
    try {
      final jsonPayload = const JsonEncoder.withIndent('  ').convert(report.toJson());
      await Clipboard.setData(ClipboardData(text: jsonPayload));

      if (context != null && context.mounted) {
        _showSuccessToast(context, '📦 Structured JSON payload copied to clipboard!');
      }
      return true;
    } catch (e) {
      if (context != null && context.mounted) {
        _showErrorToast(context, 'Failed to copy JSON: $e');
      }
      return false;
    }
  }

  /// Copies shareable deep-link URL to clipboard.
  static Future<bool> copyShareUrl(
    BuildContext? context,
    RecommendationReportModel report,
  ) async {
    try {
      final url = report.shareUrl ?? 'https://smartpack.ai/reports/${report.reportId}';
      await Clipboard.setData(ClipboardData(text: url));

      if (context != null && context.mounted) {
        _showSuccessToast(context, '🔗 Shareable link copied to clipboard!');
      }
      return true;
    } catch (e) {
      if (context != null && context.mounted) {
        _showErrorToast(context, 'Failed to copy link: $e');
      }
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // Private UI Feedback Helpers
  // --------------------------------------------------------------------------

  static void _showSuccessToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D9488), // Emerald Teal
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFDC2626), // Rose Red
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
