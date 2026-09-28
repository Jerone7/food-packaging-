import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/recommendation_report_model.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';

void main() {
  group('RecommendationReportModel Unit Tests (Module 12)', () {
    test('JSON serialization & deserialization round-trip', () {
      final report = RecommendationReportModel(
        reportId: 'SPK-20260926-TEST01',
        generatedAt: DateTime.utc(2026, 9, 26, 12, 0, 0),
        engineVersion: 'SmartPack AI Engine v2.4-Hybrid',
        verificationHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        foodContext: const ReportFoodContext(
          name: 'Fresh Strawberries',
          category: 'Fruits & Berries',
          scientificName: 'Fragaria × ananassa',
          fillQuantity: '250g',
          batchSizeUnits: 15000,
          storageCondition: 'Refrigerated (2°C - 4°C)',
          storageTempC: 4.0,
          storageDurationDays: 14,
          transportMode: 'Refrigerated Cold Chain',
        ),
        foodProperties: const ReportFoodProperties(
          moisturePct: 91.0,
          waterActivityAw: 0.98,
          phLevel: 3.5,
          fatPct: 0.3,
          respirationClass: 'High',
          respirationRate20c: 45.0,
          oxygenSensitivity: 'High',
          moistureSensitivity: 'High',
        ),
        primaryPrescription: const ReportPrimaryPrescription(
          materialName: 'Micro-Perforated Equilibrium MAP Bio-Film',
          materialType: 'Biodegradable Bio-Polymer',
          polymerFamily: 'BREATHABLE_BIO_EMAP',
          structure: 'Co-extruded Micro-Perforated PLA/PBAT Blown Film',
          packageFormat: 'Perforated Hinged Clamshell',
          dimensions: '18.0 x 12.0 x 6.0 cm',
          thicknessMicrons: 30.0,
          otr: '3500.0 cc/m²/day',
          wvtr: '45.0 g/m²/day',
          tensileStrengthMpa: 32.0,
          punctureResistanceN: 18.0,
          suitabilityScore: 0.94,
          sustainabilityScore: 94.0,
          estimatedUnitCostInr: 3.85,
        ),
        explainableRationale: 'Laser micro-perforated film maintains 3-5% O2 and 5-8% CO2 headspace to arrest fungal growth.',
        keyDrivers: const [
          'High respiration rate requires active gas transmission.',
          'Condensation mitigation prevents Botrytis cinerea gray mold.',
        ],
        alternatives: const [
          ReportAlternativePackaging(
            tierName: 'Eco-Champion',
            materialName: 'Cellulose NatureFlex Film',
            keyTradeoff: 'Home compostable bio-film; +22% cost.',
            costDeltaPct: 22.0,
            ecoDeltaPct: 6.0,
            shelfLifeDelta: '12-14 days',
            starRating: 5,
          ),
        ],
        lcaSummary: const ReportLcaSummary(
          recyclabilityTier: 'Biodegradable',
          resinIdentificationCode: 'RIC 7 (PLA/PBAT)',
          carbonFootprintGPerUnit: 8.50,
          carbonFootprintBatchKg: 127.5,
          waterFootprintLPerUnit: 0.35,
          waterFootprintBatchLiters: 5250.0,
          unitWasteGrams: 9.2,
          totalBatchWasteKg: 138.0,
        ),
        costSummary: const ReportCostSummary(
          estimatedCostPerUnitInr: 3.85,
          estimatedBatchCostInr: 57750.0,
          grossMaterialMassGrams: 9.8,
          grossMaterialMassBatchKg: 147.0,
          filmSurfaceAreaSqm: 0.055,
        ),
      );

      final jsonMap = report.toJson();
      final fromJsonModel = RecommendationReportModel.fromJson(jsonMap);

      expect(fromJsonModel.reportId, equals('SPK-20260926-TEST01'));
      expect(fromJsonModel.foodContext.name, equals('Fresh Strawberries'));
      expect(fromJsonModel.foodProperties.moisturePct, equals(91.0));
      expect(fromJsonModel.primaryPrescription.thicknessMicrons, equals(30.0));
      expect(fromJsonModel.alternatives.length, equals(1));
      expect(fromJsonModel.lcaSummary.carbonFootprintGPerUnit, equals(8.50));
      expect(fromJsonModel.costSummary.estimatedBatchCostInr, equals(57750.0));
    });

    test('fromRecommendationResult synthesizes report with full offline parity', () {
      final input = PackagingInput(
        itemName: 'Roasted Cashews',
        category: 'Snacks & Wafers',
        length: 20.0,
        width: 14.0,
        height: 5.0,
        weight: 500.0,
        isFragile: false,
        ecoFriendly: true,
        moisture: 3.5,
        fat: 46.0,
        storageDurationDays: 180,
      );

      final result = PackagingRecommendationResult(
        recommendationId: 'rec_cashew_99',
        recommendedBoxType: 'Monomaterial Met-BOPP Pouch',
        recommendedDimensions: '20.0 x 14.0 x 5.0 cm',
        boxVolumeCm3: 1400.0,
        itemVolumeCm3: 800.0,
        spaceUtilizationPct: 82.0,
        cushioningMaterial: 'None required',
        estimatedCost: 3.20,
        sustainabilityScore: 78.0,
        primaryRecommendation: const PrimaryRecommendation(
          materialName: 'Metallized High-Barrier BOPP Pouch',
          materialType: 'Recyclable Polymer',
          polymerFamily: 'RECYCLABLE_POLYOLEFIN',
          structure: 'BOPP / Met-BOPP / PE Sealant',
          barrierProfile: BarrierProfile(
            otr: '< 1.5 cc/m²/day',
            wvtr: '< 0.8 g/m²/day',
            thicknessMicrons: 45.0,
            tensileStrengthMpa: 85.0,
            punctureResistanceN: 30.0,
          ),
          sustainabilityScore: 78.0,
          estimatedUnitCostInr: 3.20,
          suitabilityScore: 0.95,
          activeAdditives: ['Nitrogen Gas Flush Ready'],
        ),
      );

      final report = RecommendationReportModel.fromRecommendationResult(
        result: result,
        input: input,
        batchSize: 20000,
        pcrPercentage: 30.0,
      );

      expect(report.foodContext.name, equals('Roasted Cashews'));
      expect(report.foodContext.batchSizeUnits, equals(20000));
      expect(report.foodProperties.fatPct, equals(46.0));
      expect(report.primaryPrescription.thicknessMicrons, equals(45.0));
      expect(report.lcaSummary.pcrPercentage, equals(30.0));
      expect(report.verificationHash.length, equals(64));
      expect(report.alternatives.length, greaterThanOrEqualTo(3));
    });

    test('toMarkdownString outputs valid specification document', () {
      final input = PackagingInput(
        itemName: 'Organic Mango Pickle',
        category: 'Pickles & Sauces',
        length: 16.0,
        width: 10.0,
        height: 4.0,
        weight: 350.0,
        isFragile: false,
        ecoFriendly: false,
        moisture: 65.0,
        ph: 3.2,
      );

      final result = PackagingRecommendationResult(
        recommendationId: 'rec_pickle_01',
        recommendedBoxType: 'Chemical-Resistant Barrier Pouch',
        recommendedDimensions: '16.0 x 10.0 x 4.0 cm',
        boxVolumeCm3: 640.0,
        itemVolumeCm3: 400.0,
        spaceUtilizationPct: 80.0,
        cushioningMaterial: 'None',
        estimatedCost: 4.10,
        sustainabilityScore: 70.0,
      );

      final report = RecommendationReportModel.fromRecommendationResult(
        result: result,
        input: input,
      );

      final md = report.toMarkdownString();

      expect(md, contains('# 📄 SmartPack AI Packaging Recommendation Specification Report'));
      expect(md, contains('Organic Mango Pickle'));
      expect(md, contains('## 1. Food Commodity Context & Operational Parameters'));
      expect(md, contains('## 2. Biochemical Food Degradation Profile'));
      expect(md, contains('## 3. Primary Prescribed Packaging Formulation & Barrier Specifications'));
      expect(md, contains('## 4. Explainable AI (XAI) Prescription Rationale & Key Drivers'));
      expect(md, contains('## 5. Multi-Material Comparative Benchmarking Matrix'));
      expect(md, contains('## 6. Environmental Sustainability & Life Cycle Assessment (LCA) Impact'));
      expect(md, contains('## 7. Converter Cost Economics Baseline'));
      expect(md, contains('## 8. Regulatory Compliance, Standards & Citations'));
      expect(md, contains(report.verificationHash));
    });
  });
}
