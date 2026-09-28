import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/recommendation_results_cockpit.dart';

void main() {
  final sampleResult = PackagingRecommendationResult(
    recommendationId: 'rec_test_101',
    primaryRecommendation: const PrimaryRecommendation(
      materialName: 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)',
      materialType: 'Biodegradable Bio-Polymer',
      polymerFamily: 'BREATHABLE_BIO_EMAP',
      structure: 'Co-extruded Micro-Perforated PLA/PBAT Blown Film',
      barrierProfile: BarrierProfile(
        otr: '3500.0 cc/m²/day',
        wvtr: '45.00 g/m²/day',
        thicknessMicrons: 30.0,
        tensileStrengthMpa: 32.0,
        punctureResistanceN: 18.0,
      ),
      sustainabilityScore: 94.0,
      estimatedUnitCostInr: 3.85,
      suitabilityScore: 0.96,
      activeAdditives: ['Ethylene Scavenger Sachet'],
      packagingTitle: 'Ventilated Food-Grade Packaging',
      packagingFormat: 'Micro-Perforated Hinged Clamshell',
      recommendationExplanation:
          'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
      advantages: [
        'Equilibrium modified atmosphere (EMAP) prevents anaerobic souring',
      ],
      limitations: [
        'Not suitable for vacuum packing or high-temperature retort processing',
      ],
      suitableStorageCondition: 'Cold Storage: 10°C - 12°C (90-95% RH)',
      expectedApplication: 'High-respiration fresh produce, strawberries, cut fruits',
      importantProperties: {
        'OTR (Oxygen Barrier)': '3500.0 cc/m²/day',
        'WVTR (Moisture Barrier)': '45.00 g/m²/day',
      },
    ),
    alternatives: const [
      PackagingAlternative(
        type: AlternativeType.ecoFriendly,
        typeRaw: 'ECO_FRIENDLY',
        materialName: 'Cellulose-Based Breathable Bio-Film',
        sustainabilityScore: 98.0,
        estimatedUnitCostInr: 4.50,
        tradeOffSummary: '100% Home compostable with excellent transparency.',
      ),
    ],
    boxGeometry: const BoxGeometrySpecs(
      lengthCm: 25.0,
      widthCm: 15.0,
      heightCm: 10.0,
      totalVolumeCm3: 3750.0,
      spaceUtilizationPct: 76.5,
      cushioningMaterial: 'Molded Cellulose Pulp Nest Cushioning',
    ),
    scientificRationale: const ExplainableAiRationale(
      summary: 'High respiration and moisture sensitivity require EMAP.',
      keyDrivers: ['High respiration rate mandates gas-permeable film.'],
    ),
    recommendedBoxType: 'Optimized Micro-Perforated Clamshell',
    recommendedDimensions: '25.0 x 15.0 x 10.0 cm',
    boxVolumeCm3: 3750.0,
    itemVolumeCm3: 2800.0,
    spaceUtilizationPct: 76.5,
    cushioningMaterial: 'Molded Cellulose Pulp Nest Cushioning',
    estimatedCost: 3.85,
    sustainabilityScore: 94.0,
  );

  Widget createTestWidget({VoidCallback? onReset}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RecommendationResultsCockpit(
              result: sampleResult,
              onResetAnalysis: onReset,
            ),
          ),
        ),
      ),
    );
  }

  group('RecommendationResultsCockpit Master Assembly Tests (Task 5.1)', () {
    testWidgets('renders all modular components in cohesive cockpit', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // 1. Hero Card
      expect(find.text('RECOMMENDED PACKAGING'), findsOneWidget);
      expect(find.text('Ventilated Food-Grade Packaging'), findsOneWidget);

      // 2. Explainable Banner
      expect(find.text('RECOMMENDATION EXPLANATION'), findsOneWidget);
      expect(
        find.text(
          'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
        ),
        findsOneWidget,
      );

      // 3. Technical Cards
      expect(find.text('IMPORTANT PROPERTIES'), findsOneWidget);
      expect(find.text('ADVANTAGES'), findsOneWidget);
      expect(find.text('LIMITATIONS'), findsOneWidget);
      expect(find.text('SUITABLE STORAGE & APPLICATION'), findsOneWidget);
      expect(find.text('PACKAGING FORMAT & GEOMETRY'), findsOneWidget);

      // 4. Alternatives Matrix
      expect(find.text('ALTERNATIVE PACKAGING PATHWAYS'), findsOneWidget);
      expect(find.text('Cellulose-Based Breathable Bio-Film'), findsOneWidget);
    });

    testWidgets('triggers onResetAnalysis callback when reset button clicked', (tester) async {
      bool resetTriggered = false;
      await tester.pumpWidget(createTestWidget(onReset: () => resetTriggered = true));

      expect(find.text('New Analysis'), findsOneWidget);
      await tester.tap(find.text('New Analysis'));
      await tester.pumpAndSettle();

      expect(resetTriggered, isTrue);
    });
  });
}
