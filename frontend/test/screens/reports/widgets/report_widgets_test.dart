import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/recommendation_report_model.dart';
import 'package:ai_packaging_recommender/screens/reports/widgets/report_header_card.dart';
import 'package:ai_packaging_recommender/screens/reports/widgets/report_spec_table.dart';
import 'package:ai_packaging_recommender/screens/reports/widgets/report_alternatives_card.dart';
import 'package:ai_packaging_recommender/screens/reports/widgets/report_summary_cards.dart';
import 'package:ai_packaging_recommender/screens/reports/widgets/report_action_toolbar.dart';

void main() {
  group('Report Modular Widgets Suite (Module 12 - Phase 5)', () {
    late RecommendationReportModel sampleReport;

    setUp(() {
      sampleReport = RecommendationReportModel(
        reportId: 'SPK-2026-TEST-WIDGET',
        generatedAt: DateTime.utc(2026, 9, 26, 12, 0, 0),
        engineVersion: 'SmartPack AI Engine v2.4-Hybrid',
        verificationHash: '9f8a3c2e1b4d0e7a9f8a3c2e1b4d0e7a',
        foodContext: const ReportFoodContext(
          name: 'Fresh Strawberries',
          category: 'Fruits & Berries',
          scientificName: 'Fragaria × ananassa',
          fillQuantity: '250g',
          batchSizeUnits: 15000,
          storageCondition: 'Refrigerated (2°C - 4°C)',
          storageTempC: 4.0,
          storageDurationDays: 14,
        ),
        foodProperties: const ReportFoodProperties(
          moisturePct: 91.0,
          waterActivityAw: 0.98,
          phLevel: 3.5,
          fatPct: 0.3,
          oxygenSensitivity: 'High (Ascorbic acid loss)',
          moistureSensitivity: 'High (Transpiration loss)',
        ),
        primaryPrescription: const ReportPrimaryPrescription(
          materialName: 'Micro-Perforated Equilibrium MAP Bio-Film',
          polymerFamily: 'BREATHABLE_BIO_EMAP',
          structure: 'PLA / PBAT Extruded Film',
          dimensions: '18.0 x 12.0 x 6.0 cm',
          thicknessMicrons: 30.0,
          otr: '3500.0 cc/m²/day',
          wvtr: '45.0 g/m²/day',
          tensileStrengthMpa: 32.0,
          punctureResistanceN: 18.0,
          suitabilityScore: 0.94,
        ),
        explainableRationale: 'Laser micro-perforations match respiration rate to establish 3-5% O2 headspace.',
        alternatives: const [
          ReportAlternativePackaging(
            tierName: 'Eco-Champion',
            materialName: 'NatureFlex Bio-Cellulose',
            keyTradeoff: 'Home compostable; +20% cost.',
            costDeltaPct: 20.0,
            ecoDeltaPct: 8.0,
            shelfLifeDelta: '12 days',
            starRating: 5,
          ),
          ReportAlternativePackaging(
            tierName: 'Economy Option',
            materialName: 'BOPP Monomaterial',
            keyTradeoff: 'Cost effective; strict ambient.',
            costDeltaPct: -25.0,
            ecoDeltaPct: -5.0,
            shelfLifeDelta: '14 days',
            starRating: 4,
          ),
        ],
        lcaSummary: const ReportLcaSummary(
          carbonFootprintGPerUnit: 8.5,
          carbonFootprintBatchKg: 127.5,
          waterFootprintLPerUnit: 0.3,
          waterFootprintBatchLiters: 4500.0,
          unitWasteGrams: 9.0,
          totalBatchWasteKg: 135.0,
          circularityIndexMci: 0.88,
        ),
        costSummary: const ReportCostSummary(
          estimatedCostPerUnitInr: 3.85,
          estimatedBatchCostInr: 57750.0,
          grossMaterialMassGrams: 9.5,
          grossMaterialMassBatchKg: 142.5,
        ),
      );
    });

    testWidgets('ReportHeaderCard renders commodity title and metadata', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReportHeaderCard(report: sampleReport),
            ),
          ),
        ),
      );

      expect(find.text('Fresh Strawberries'), findsOneWidget);
      expect(find.text('Fruits & Berries'), findsOneWidget);
      expect(find.text('SPK-2026-TEST-WIDGET'), findsOneWidget);
      expect(find.textContaining('9f8a3c2e1b4d0e7a'), findsOneWidget);
    });

    testWidgets('ReportSpecTable renders biochemical and prescription metrics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReportSpecTable(report: sampleReport),
            ),
          ),
        ),
      );

      expect(find.text('Biochemical Degradation Profile'), findsOneWidget);
      expect(find.text('91.0%'), findsOneWidget);
      expect(find.text('Micro-Perforated Equilibrium MAP Bio-Film'), findsOneWidget);
    });

    testWidgets('ReportAlternativesCard renders alternatives benchmark tiers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReportAlternativesCard(alternatives: sampleReport.alternatives),
            ),
          ),
        ),
      );

      expect(find.text('3-Way Multi-Material Alternatives Benchmark'), findsOneWidget);
      expect(find.text('Eco-Champion'), findsOneWidget);
      expect(find.text('NatureFlex Bio-Cellulose'), findsOneWidget);
      expect(find.text('Economy Option'), findsOneWidget);
      expect(find.text('BOPP Monomaterial'), findsOneWidget);
    });

    testWidgets('ReportSummaryCards renders LCA indicators and Converter cost economics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReportSummaryCards(report: sampleReport),
            ),
          ),
        ),
      );

      expect(find.text('Sustainability & LCA Impact'), findsOneWidget);
      expect(find.text('8.50 g CO₂e'), findsOneWidget);
      expect(find.text('Converter Cost Economics'), findsOneWidget);
      expect(find.text('₹3.85 / pack'), findsOneWidget);
    });

    testWidgets('ReportActionToolbar renders 4 primary export action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReportActionToolbar(report: sampleReport),
            ),
          ),
        ),
      );

      expect(find.text('Download PDF'), findsOneWidget);
      expect(find.text('Print Report'), findsOneWidget);
      expect(find.text('Copy Markdown'), findsOneWidget);
      expect(find.text('Copy JSON'), findsOneWidget);
    });
  });
}
