import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/report_generator_service.dart';
import 'package:ai_packaging_recommender/models/recommendation_report_model.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';

void main() {
  group('ReportGeneratorService Unit & Integration Tests (Module 12)', () {
    late PackagingInput sampleInput;
    late PackagingRecommendationResult sampleResult;

    setUp(() {
      sampleInput = PackagingInput(
        itemName: 'Organic Green Peas',
        category: 'Frozen & Fresh Vegetables',
        length: 22.0,
        width: 15.0,
        height: 4.0,
        weight: 500.0,
        isFragile: false,
        ecoFriendly: true,
        moisture: 78.0,
        storageCondition: 'Frozen Storage (-18°C)',
        storageTempC: -18.0,
        storageDurationDays: 365,
      );

      sampleResult = PackagingRecommendationResult(
        recommendationId: 'rec_peas_55',
        recommendedBoxType: 'High-Barrier Flexible Frozen Pouch',
        recommendedDimensions: '22.0 x 15.0 x 4.0 cm',
        boxVolumeCm3: 1320.0,
        itemVolumeCm3: 800.0,
        spaceUtilizationPct: 85.0,
        cushioningMaterial: 'None',
        estimatedCost: 3.60,
        sustainabilityScore: 88.0,
        primaryRecommendation: const PrimaryRecommendation(
          materialName: 'Bio-Based EMAP Frozen Barrier Film',
          materialType: 'Biodegradable Polymer',
          polymerFamily: 'BREATHABLE_BIO_EMAP',
          structure: 'PLA / PBAT Extruded Cryogenic Film',
          packagingFormat: 'Stand-up Doypack (Bottom Gusset)',
          barrierProfile: BarrierProfile(
            otr: '850.0 cc/m²/day',
            wvtr: '12.0 g/m²/day',
            thicknessMicrons: 40.0,
            tensileStrengthMpa: 35.0,
            punctureResistanceN: 24.0,
          ),
          sustainabilityScore: 88.0,
          estimatedUnitCostInr: 3.60,
          suitabilityScore: 0.93,
          activeAdditives: ['Cryogenic Cold-Crack Resistant'],
        ),
      );
    });

    test('synthesizeReport auto-resolves missing LCA and Cost profiles offline', () {
      final report = ReportGeneratorService.synthesizeReport(
        result: sampleResult,
        input: sampleInput,
        batchSize: 15000,
        pcrPercentage: 20.0,
      );

      expect(report, isA<RecommendationReportModel>());
      expect(report.foodContext.name, equals('Organic Green Peas'));
      expect(report.foodContext.batchSizeUnits, equals(15000));
      expect(report.foodContext.storageTempC, equals(-18.0));
      expect(report.foodContext.transportMode, equals('Refrigerated Cold Chain'));

      // Check auto-resolved LCA profile
      expect(report.lcaSummary.carbonFootprintGPerUnit, greaterThan(0.0));
      expect(report.lcaSummary.carbonFootprintBatchKg, greaterThan(0.0));
      expect(report.lcaSummary.waterFootprintLPerUnit, greaterThan(0.0));
      expect(report.lcaSummary.pcrPercentage, equals(20.0));
      expect(report.lcaSummary.circularityIndexMci, greaterThan(0.0));

      // Check auto-resolved Cost profile
      expect(report.costSummary.estimatedCostPerUnitInr, greaterThan(0.0));
      expect(report.costSummary.estimatedBatchCostInr, greaterThan(0.0));
      expect(report.costSummary.grossMaterialMassGrams, greaterThan(0.0));
      expect(report.costSummary.filmSurfaceAreaSqm, greaterThan(0.0));

      // Check hash & alternatives
      expect(report.verificationHash.length, equals(64));
      expect(report.alternatives.length, greaterThanOrEqualTo(3));
    });

    test('generateMarkdown compiles full specification text', () {
      final report = ReportGeneratorService.synthesizeReport(
        result: sampleResult,
        input: sampleInput,
      );

      final md = ReportGeneratorService.generateMarkdown(report);

      expect(md, contains('# 📄 SmartPack AI Packaging Recommendation Specification Report'));
      expect(md, contains('Organic Green Peas'));
      expect(md, contains('Bio-Based EMAP Frozen Barrier Film'));
      expect(md, contains('## 1. Food Commodity Context & Operational Parameters'));
      expect(md, contains('## 6. Environmental Sustainability & Life Cycle Assessment (LCA) Impact'));
      expect(md, contains('## 7. Converter Cost Economics Baseline'));
    });

    test('ApiService.generateReport returns valid report with fallback resilience', () async {
      final report = await ApiService.generateReport(
        result: sampleResult,
        input: sampleInput,
        batchSize: 5000,
        pcrPercentage: 10.0,
      );

      expect(report, isA<RecommendationReportModel>());
      expect(report.foodContext.name, equals('Organic Green Peas'));
      expect(report.foodContext.batchSizeUnits, equals(5000));
      expect(report.primaryPrescription.materialName, isNotEmpty);
      expect(report.verificationHash, isNotEmpty);
    });

    test('ApiService.getReportById returns report model with fallback resilience', () async {
      final report = await ApiService.getReportById('SPK-TEST-OFFLINE-99');

      expect(report, isA<RecommendationReportModel>());
      expect(report.reportId, equals('SPK-TEST-OFFLINE-99'));
      expect(report.primaryPrescription.materialName, isNotEmpty);
    });
  });
}
