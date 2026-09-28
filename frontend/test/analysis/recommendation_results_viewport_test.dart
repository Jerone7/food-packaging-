import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/recommendation_results_cockpit.dart';

void main() {
  final mockResult = PackagingRecommendationResult(
    recommendationId: 'rec_audit_123',
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
      activeAdditives: [
        'Potassium Permanganate (KMnO₄) Ethylene Scavenger Sachet',
        'Antifog Surface Surfactant Coating',
      ],
      packagingTitle: 'Ventilated Food-Grade Packaging',
      packagingFormat: 'Micro-Perforated Hinged Clamshell',
      recommendationExplanation:
          'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
      advantages: [
        'Equilibrium modified atmosphere (EMAP) prevents anaerobic souring',
        'Anti-fog coating suppresses condensation water droplets',
      ],
      limitations: [
        'Not suitable for vacuum packing or high-temperature retort processing',
      ],
      suitableStorageCondition: 'Cold Storage: 10°C - 12°C (90-95% RH)',
      expectedApplication:
          'High-respiration fresh produce, strawberries, cut fruits, cherry tomatoes',
      importantProperties: {
        'OTR (Oxygen Barrier)': '3500.0 cc/m²/day',
        'WVTR (Moisture Barrier)': '45.00 g/m²/day',
        'Film Thickness': '30.0 µm',
        'Tensile Strength': '32.0 MPa',
      },
    ),
    alternatives: const [
      PackagingAlternative(
        type: AlternativeType.ecoFriendly,
        typeRaw: 'ECO_FRIENDLY',
        materialName: 'Cellulose-Based Breathable Bio-Film (NatureFlex)',
        sustainabilityScore: 98.0,
        estimatedUnitCostInr: 4.50,
        tradeOffSummary: '100% Home compostable with excellent transparency.',
      ),
      PackagingAlternative(
        type: AlternativeType.economy,
        typeRaw: 'ECONOMY',
        materialName: 'Perforated Low-Density Polyethylene (LDPE)',
        sustainabilityScore: 62.0,
        estimatedUnitCostInr: 1.95,
        tradeOffSummary: 'Lowest unit cost; standard municipal recyclability.',
      ),
    ],
    boxGeometry: const BoxGeometrySpecs(
      lengthCm: 28.5,
      widthCm: 17.6,
      heightCm: 14.1,
      totalVolumeCm3: 7072.0,
      spaceUtilizationPct: 78.5,
      cushioningMaterial: 'Recycled Kraft Thermal Insulated Pouch + Cold Gel Pack',
    ),
    scientificRationale: const ExplainableAiRationale(
      summary: 'Fresh Produce requires Equilibrium Modified Atmosphere (EMAP).',
      keyDrivers: [
        'High respiration rate requires gas-permeable micro-perforations.',
      ],
    ),
    recommendedBoxType: 'Optimized PLA/PBAT Carton',
    recommendedDimensions: '28.5 x 17.6 x 14.1 cm',
    boxVolumeCm3: 7072.0,
    itemVolumeCm3: 5500.0,
    spaceUtilizationPct: 78.5,
    cushioningMaterial: 'Recycled Kraft Thermal Insulated Pouch + Cold Gel Pack',
    estimatedCost: 3.85,
    sustainabilityScore: 94.0,
  );

  Widget createAuditWidget() {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RecommendationResultsCockpit(result: mockResult),
          ),
        ),
      ),
    );
  }

  group('Explainable Recommendation Results Multi-Viewport Responsive Audit (Task 5.3)', () {
    testWidgets('Mobile Viewport (375x812) renders with 0 RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createAuditWidget());
      await tester.pumpAndSettle();

      expect(find.text('RECOMMENDED PACKAGING'), findsOneWidget);
      expect(find.text('Ventilated Food-Grade Packaging'), findsOneWidget);
      expect(find.text('RECOMMENDATION EXPLANATION'), findsOneWidget);
      expect(find.text('IMPORTANT PROPERTIES'), findsOneWidget);
      expect(find.text('ADVANTAGES'), findsOneWidget);
      expect(find.text('LIMITATIONS'), findsOneWidget);
      expect(find.text('SUITABLE STORAGE & APPLICATION'), findsOneWidget);
      expect(find.text('PACKAGING FORMAT & GEOMETRY'), findsOneWidget);
      expect(find.text('ALTERNATIVE PACKAGING PATHWAYS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tablet Viewport (768x1024) renders with 0 RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createAuditWidget());
      await tester.pumpAndSettle();

      expect(find.text('RECOMMENDED PACKAGING'), findsOneWidget);
      expect(find.text('Ventilated Food-Grade Packaging'), findsOneWidget);
      expect(find.text('RECOMMENDATION EXPLANATION'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Desktop Viewport (1280x900) renders with 0 RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createAuditWidget());
      await tester.pumpAndSettle();

      expect(find.text('RECOMMENDED PACKAGING'), findsOneWidget);
      expect(find.text('Ventilated Food-Grade Packaging'), findsOneWidget);
      expect(find.text('RECOMMENDATION EXPLANATION'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
