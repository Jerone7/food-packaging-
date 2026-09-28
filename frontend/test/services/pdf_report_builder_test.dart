import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:ai_packaging_recommender/services/pdf_report_builder.dart';
import 'package:ai_packaging_recommender/models/recommendation_report_model.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';

void main() {
  group('PdfReportBuilder Unit Tests (Module 12)', () {
    late RecommendationReportModel sampleReport;

    setUp(() {
      final input = PackagingInput(
        itemName: 'Alphonso Mangoes',
        category: 'Produce & Fruits',
        length: 24.0,
        width: 16.0,
        height: 8.0,
        weight: 1000.0,
        isFragile: true,
        ecoFriendly: true,
        moisture: 84.0,
        storageCondition: 'Cool Storage (12°C - 14°C)',
        storageTempC: 12.0,
        storageDurationDays: 21,
      );

      final result = PackagingRecommendationResult(
        recommendationId: 'rec_mango_77',
        recommendedBoxType: 'Micro-Perforated Equilibrium MAP Bio-Film',
        recommendedDimensions: '24.0 x 16.0 x 8.0 cm',
        boxVolumeCm3: 3072.0,
        itemVolumeCm3: 1800.0,
        spaceUtilizationPct: 75.0,
        cushioningMaterial: 'Molded Fiber Partition',
        estimatedCost: 4.80,
        sustainabilityScore: 92.0,
        primaryRecommendation: const PrimaryRecommendation(
          materialName: 'Micro-Perforated Equilibrium MAP Bio-Film',
          materialType: 'Biodegradable Bio-Polymer',
          polymerFamily: 'BREATHABLE_BIO_EMAP',
          structure: 'Co-extruded Micro-Perforated PLA/PBAT Blown Film',
          packagingFormat: 'Hinged Clamshell with Laser Perforations',
          barrierProfile: BarrierProfile(
            otr: '3200.0 cc/m²/day',
            wvtr: '38.0 g/m²/day',
            thicknessMicrons: 35.0,
            tensileStrengthMpa: 30.0,
            punctureResistanceN: 20.0,
          ),
          sustainabilityScore: 92.0,
          estimatedUnitCostInr: 4.80,
          suitabilityScore: 0.95,
          activeAdditives: ['Anti-Fog Surfactant', 'Ethylene Scavenger Ready'],
        ),
      );

      sampleReport = RecommendationReportModel.fromRecommendationResult(
        result: result,
        input: input,
        batchSize: 10000,
        pcrPercentage: 15.0,
      );
    });

    test('buildPdf produces valid binary PDF byte array with %PDF magic header', () async {
      final pdfBytes = await PdfReportBuilder.buildPdf(sampleReport, pageFormat: PdfPageFormat.a4);

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000)); // Non-trivial document size

      // Check standard PDF magic header (%PDF-)
      final header = utf8.decode(pdfBytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('buildPdf renders successfully on Letter format', () async {
      final letterBytes = await PdfReportBuilder.buildPdf(sampleReport, pageFormat: PdfPageFormat.letter);

      expect(letterBytes, isNotEmpty);
      final header = utf8.decode(letterBytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('buildPdf handles minimal report without errors', () async {
      final minimalReport = RecommendationReportModel(
        reportId: 'SPK-MINIMAL-01',
        generatedAt: DateTime.utc(2026, 9, 26, 12, 0, 0),
        verificationHash: '1234567890abcdef1234567890abcdef',
        foodContext: const ReportFoodContext(name: 'Dry Spices'),
        foodProperties: const ReportFoodProperties(),
        primaryPrescription: const ReportPrimaryPrescription(materialName: 'BOPP Film'),
        explainableRationale: 'Basic barrier protection for dry powder.',
        lcaSummary: const ReportLcaSummary(
          carbonFootprintGPerUnit: 10.0,
          carbonFootprintBatchKg: 100.0,
          waterFootprintLPerUnit: 0.1,
          waterFootprintBatchLiters: 1000.0,
          unitWasteGrams: 8.0,
          totalBatchWasteKg: 80.0,
        ),
        costSummary: const ReportCostSummary(
          estimatedCostPerUnitInr: 2.50,
          estimatedBatchCostInr: 25000.0,
          grossMaterialMassGrams: 8.0,
          grossMaterialMassBatchKg: 80.0,
        ),
      );

      final pdfBytes = await PdfReportBuilder.buildPdf(minimalReport);
      expect(pdfBytes, isNotEmpty);
      expect(utf8.decode(pdfBytes.sublist(0, 5)), equals('%PDF-'));
    });
  });
}
