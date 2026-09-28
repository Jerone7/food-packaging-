import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/report_export_service.dart';
import 'package:ai_packaging_recommender/models/recommendation_report_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReportExportService Unit & Clipboard Tests (Module 12)', () {
    late RecommendationReportModel sampleReport;
    final List<MethodCall> platformCalls = [];

    setUp(() {
      platformCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        platformCalls.add(methodCall);
        if (methodCall.method == 'Clipboard.setData') {
          return null;
        } else if (methodCall.method == 'Clipboard.getData') {
          return <String, dynamic>{'text': 'mock_clipboard_content'};
        }
        return null;
      });

      sampleReport = RecommendationReportModel(
        reportId: 'SPK-2026-EXPORT-01',
        generatedAt: DateTime.utc(2026, 9, 26, 12, 0, 0),
        engineVersion: 'SmartPack AI Engine v2.4-Hybrid',
        verificationHash: 'abcd1234efgh5678abcd1234efgh5678',
        foodContext: const ReportFoodContext(
          name: 'Roasted Cashews',
          category: 'Snacks & Wafers',
          fillQuantity: '500g',
          batchSizeUnits: 10000,
        ),
        foodProperties: const ReportFoodProperties(
          moisturePct: 3.5,
          fatPct: 45.0,
          oxygenSensitivity: 'High',
        ),
        primaryPrescription: const ReportPrimaryPrescription(
          materialName: 'Met-BOPP Snack Film',
          thicknessMicrons: 40.0,
          otr: '< 1.2 cc/m²/day',
          wvtr: '< 0.8 g/m²/day',
        ),
        explainableRationale: 'High lipid content requires barrier to prevent rancidity.',
        lcaSummary: const ReportLcaSummary(
          carbonFootprintGPerUnit: 12.0,
          carbonFootprintBatchKg: 120.0,
          waterFootprintLPerUnit: 0.18,
          waterFootprintBatchLiters: 1800.0,
          unitWasteGrams: 10.0,
          totalBatchWasteKg: 100.0,
        ),
        costSummary: const ReportCostSummary(
          estimatedCostPerUnitInr: 3.20,
          estimatedBatchCostInr: 32000.0,
          grossMaterialMassGrams: 10.5,
          grossMaterialMassBatchKg: 105.0,
        ),
        shareUrl: 'https://smartpack.ai/reports/SPK-2026-EXPORT-01',
      );
    });

    test('copyMarkdownSpec copies markdown text without context', () async {
      final success = await ReportExportService.copyMarkdownSpec(null, sampleReport);
      expect(success, isTrue);

      final clipboardCall = platformCalls.firstWhere((c) => c.method == 'Clipboard.setData');
      final text = (clipboardCall.arguments as Map)['text'] as String;
      expect(text, contains('# 📄 SmartPack AI Packaging Recommendation Specification Report'));
      expect(text, contains('Roasted Cashews'));
    });

    test('copyJsonPayload copies formatted JSON without context', () async {
      final success = await ReportExportService.copyJsonPayload(null, sampleReport);
      expect(success, isTrue);

      final clipboardCall = platformCalls.firstWhere((c) => c.method == 'Clipboard.setData');
      final text = (clipboardCall.arguments as Map)['text'] as String;
      expect(text, contains('"report_id": "SPK-2026-EXPORT-01"'));
      expect(text, contains('"name": "Roasted Cashews"'));
    });

    test('copyShareUrl copies shareable deep-link URL', () async {
      final success = await ReportExportService.copyShareUrl(null, sampleReport);
      expect(success, isTrue);

      final clipboardCall = platformCalls.firstWhere((c) => c.method == 'Clipboard.setData');
      final text = (clipboardCall.arguments as Map)['text'] as String;
      expect(text, equals('https://smartpack.ai/reports/SPK-2026-EXPORT-01'));
    });

    testWidgets('copyMarkdownSpec displays SnackBar toast when context provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await ReportExportService.copyMarkdownSpec(context, sampleReport);
                },
                child: const Text('Copy Markdown'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Copy Markdown'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('📋 Technical Markdown specification copied to clipboard!'), findsOneWidget);
    });

    testWidgets('copyJsonPayload displays SnackBar toast when context provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await ReportExportService.copyJsonPayload(context, sampleReport);
                },
                child: const Text('Copy JSON'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Copy JSON'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('📦 Structured JSON payload copied to clipboard!'), findsOneWidget);
    });
  });
}
