/// Recommendation Report Viewer Screen (Module 12: Recommendation Report).
/// Master screen delivering comprehensive packaging specification sheets,
/// multi-format export toolbars, and instant zero-latency report synthesis.
library;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/recommendation_report_model.dart';
import '../../models/packaging_model.dart';
import '../../models/sustainability_model.dart';
import '../../models/cost_estimation_model.dart';
import '../../services/report_generator_service.dart';
import '../../services/report_export_service.dart';
import '../../services/api_service.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_translations.dart';
import '../../widgets/navigation/language_selector_widget.dart';
import 'widgets/report_header_card.dart';
import 'widgets/report_spec_table.dart';
import 'widgets/report_alternatives_card.dart';
import 'widgets/report_summary_cards.dart';
import 'widgets/report_action_toolbar.dart';

class RecommendationReportScreen extends StatefulWidget {
  final RecommendationReportModel? initialReport;
  final PackagingRecommendationResult? recommendationResult;
  final PackagingInput? input;
  final SustainabilityProfile? sustainabilityProfile;
  final CostEstimationResponse? costResponse;
  final String? reportId;
  final int batchSize;
  final double pcrPercentage;

  const RecommendationReportScreen({
    super.key,
    this.initialReport,
    this.recommendationResult,
    this.input,
    this.sustainabilityProfile,
    this.costResponse,
    this.reportId,
    this.batchSize = 10000,
    this.pcrPercentage = 0.0,
  });

  @override
  State<RecommendationReportScreen> createState() => _RecommendationReportScreenState();
}

class _RecommendationReportScreenState extends State<RecommendationReportScreen> {
  RecommendationReportModel? _report;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeReport();
  }

  void _initializeReport() {
    // 1. If explicit report already passed, use directly
    if (widget.initialReport != null) {
      _report = widget.initialReport;
      return;
    }

    // 2. If recommendation state is provided, synthesize immediately for zero UI latency
    if (widget.recommendationResult != null && widget.input != null) {
      _report = ReportGeneratorService.synthesizeReport(
        result: widget.recommendationResult!,
        input: widget.input!,
        sustainabilityProfile: widget.sustainabilityProfile,
        costResponse: widget.costResponse,
        batchSize: widget.batchSize,
        pcrPercentage: widget.pcrPercentage,
      );
      // Asynchronously attempt to sync with backend
      _fetchBackendReportAsync();
      return;
    }

    // 3. If only reportId is passed, fetch from API
    if (widget.reportId != null) {
      _fetchReportById(widget.reportId!);
      return;
    }

    // Fallback: minimal demo report
    _report = RecommendationReportModel(
      reportId: 'SPK-DEMO-001',
      generatedAt: DateTime.now().toUtc(),
      verificationHash: '9f8a3c2e1b4d0e7a9f8a3c2e1b4d0e7a',
      foodContext: const ReportFoodContext(name: 'Fresh Packaged Item'),
      foodProperties: const ReportFoodProperties(),
      primaryPrescription: const ReportPrimaryPrescription(materialName: 'High-Barrier Flexible Film'),
      explainableRationale: 'Balanced barrier formulation optimized for extended freshness.',
      lcaSummary: const ReportLcaSummary(
        carbonFootprintGPerUnit: 12.0,
        carbonFootprintBatchKg: 120.0,
        waterFootprintLPerUnit: 0.2,
        waterFootprintBatchLiters: 2000.0,
        unitWasteGrams: 10.0,
        totalBatchWasteKg: 100.0,
      ),
      costSummary: const ReportCostSummary(
        estimatedCostPerUnitInr: 3.50,
        estimatedBatchCostInr: 35000.0,
        grossMaterialMassGrams: 10.0,
        grossMaterialMassBatchKg: 100.0,
      ),
    );
  }

  Future<void> _fetchBackendReportAsync() async {
    if (widget.recommendationResult == null || widget.input == null) return;
    try {
      final backendReport = await ApiService.generateReport(
        result: widget.recommendationResult!,
        input: widget.input!,
        sustainabilityProfile: widget.sustainabilityProfile,
        costResponse: widget.costResponse,
        batchSize: widget.batchSize,
        pcrPercentage: widget.pcrPercentage,
      );
      if (mounted) {
        setState(() => _report = backendReport);
      }
    } catch (_) {
      // Keep using locally synthesized report seamlessly
    }
  }

  Future<void> _fetchReportById(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final report = await ApiService.getReportById(id);
      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load report: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.slateDark),
              tooltip: 'Back to Results',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(
              'reports.title'.tr(),
              style: const TextStyle(
                color: AppTheme.slateDark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Center(
                  child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
                ),
              ),
              if (_report != null) ...[
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: AppTheme.slateDark, size: 20),
                  tooltip: 'Share Link',
                  onPressed: () => ReportExportService.copyShareUrl(context, _report!),
                ),
                IconButton(
                  icon: const Icon(Icons.print_rounded, color: Color(0xFF0F766E), size: 20),
                  tooltip: 'Print Report',
                  onPressed: () => ReportExportService.printReport(context, _report!),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCube(color: Color(0xFF0F766E), size: 36),
            SizedBox(height: 16),
            Text(
              'Compiling specification report...',
              style: TextStyle(color: AppTheme.slateBody, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.slateDark, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _initializeReport(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_report == null) {
      return const Center(child: Text('No report data available'));
    }

    final report = _report!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Export Action Toolbar (Top)
              ReportActionToolbar(report: report),
              const SizedBox(height: 16),

              // 2. Report Header Banner
              ReportHeaderCard(report: report),
              const SizedBox(height: 16),

              // 3. Biochemical & Prescribed Specification 2-Column Table
              ReportSpecTable(report: report),
              const SizedBox(height: 16),

              // 4. Explainable AI Rationale Card
              _buildXaiCard(report),
              const SizedBox(height: 16),

              // 5. 3-Way Alternatives Benchmarking Card
              ReportAlternativesCard(alternatives: report.alternatives),
              const SizedBox(height: 16),

              // 6. Sustainability LCA & Converter Cost Economics Cards
              ReportSummaryCards(report: report),
              const SizedBox(height: 16),

              // 7. Standards & Regulatory Citations Footer Banner
              _buildCitationsCard(report),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildXaiCard(RecommendationReportModel report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Emerald 50
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_rounded, size: 16, color: Color(0xFF059669)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Explainable AI (XAI) Prescription Rationale',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF064E3B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.explainableRationale,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.slateDark,
              height: 1.45,
            ),
          ),
          if (report.keyDrivers.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFBBF7D0), height: 1),
            const SizedBox(height: 10),
            const Text(
              'Primary Technical Decision Drivers:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF064E3B),
              ),
            ),
            const SizedBox(height: 6),
            ...report.keyDrivers.map(
              (driver) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right_rounded, size: 16, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        driver,
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.slateBody),
                      ),
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

  Widget _buildCitationsCard(RecommendationReportModel report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_outlined, size: 14, color: AppTheme.slateBody),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Regulatory Compliance, Test Standards & LCI Citations',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slateDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.standardsAndCitations.join(' • '),
            style: const TextStyle(
              fontSize: 10.5,
              color: AppTheme.slateBody,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
