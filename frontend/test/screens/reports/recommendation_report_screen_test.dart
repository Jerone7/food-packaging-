import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/recommendation_report_model.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/reports/recommendation_report_screen.dart';

void main() {
  group('RecommendationReportScreen Master Screen Tests (Module 12 - Task 6.1)', () {
    late RecommendationReportModel sampleReport;
    late PackagingInput sampleInput;
    late PackagingRecommendationResult sampleResult;

    setUp(() {
      sampleInput = PackagingInput(
        itemName: 'Roasted Coffee Beans',
        category: 'Beverages & Dry Powders',
        length: 24.0,
        width: 16.0,
        height: 6.0,
        weight: 1000.0,
        isFragile: false,
        ecoFriendly: true,
        moisture: 2.5,
        fat: 15.0,
        storageDurationDays: 365,
      );

      sampleResult = PackagingRecommendationResult(
        recommendationId: 'rec_coffee_88',
        recommendedBoxType: 'Tri-Layer Aluminium Foil Barrier Pouch',
        recommendedDimensions: '24.0 x 16.0 x 6.0 cm',
        boxVolumeCm3: 2304.0,
        itemVolumeCm3: 1500.0,
        spaceUtilizationPct: 82.0,
        cushioningMaterial: 'None',
        estimatedCost: 5.50,
        sustainabilityScore: 75.0,
        primaryRecommendation: const PrimaryRecommendation(
          materialName: 'Tri-Layer Aluminium Foil Barrier Laminate',
          materialType: 'High-Barrier Laminate',
          polymerFamily: 'METALLIZED_BARRIER',
          structure: 'PET / AL / PE 3-Ply Film',
          packagingFormat: 'Stand-up Doypack (Bottom Gusset)',
          barrierProfile: BarrierProfile(
            otr: '< 0.05 cc/m²/day',
            wvtr: '< 0.01 g/m²/day',
            thicknessMicrons: 70.0,
            tensileStrengthMpa: 85.0,
            punctureResistanceN: 45.0,
          ),
          sustainabilityScore: 75.0,
          estimatedUnitCostInr: 5.50,
          suitabilityScore: 0.98,
          activeAdditives: ['One-Way Degassing Valve'],
        ),
      );

      sampleReport = RecommendationReportModel.fromRecommendationResult(
        result: sampleResult,
        input: sampleInput,
        batchSize: 10000,
        pcrPercentage: 0.0,
      );
    });

    testWidgets('Renders screen with initialReport successfully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecommendationReportScreen(initialReport: sampleReport),
        ),
      );

      expect(find.text('Recommendation Report'), findsOneWidget);
      expect(find.text('Roasted Coffee Beans'), findsOneWidget);
      expect(find.text('Tri-Layer Aluminium Foil Barrier Laminate'), findsWidgets);
      expect(find.text('Download PDF'), findsOneWidget);
      expect(find.text('Print Report'), findsOneWidget);
      expect(find.text('Copy Markdown'), findsOneWidget);
      expect(find.text('Copy JSON'), findsOneWidget);
    });

    testWidgets('Renders screen with recommendationResult and input (live synthesis)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecommendationReportScreen(
            recommendationResult: sampleResult,
            input: sampleInput,
          ),
        ),
      );

      expect(find.text('Recommendation Report'), findsOneWidget);
      expect(find.text('Roasted Coffee Beans'), findsOneWidget);
      expect(find.text('Explainable AI (XAI) Prescription Rationale'), findsOneWidget);
      expect(find.text('Sustainability & LCA Impact'), findsOneWidget);
      expect(find.text('Converter Cost Economics'), findsOneWidget);
    });
  });
}
