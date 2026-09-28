import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/recommendation_results_cockpit.dart';

void main() {
  final richResult = PackagingRecommendationResult(
    recommendationId: 'rec_audit_900',
    primaryRecommendation: const PrimaryRecommendation(
      materialName: 'Polylactic Acid (PLA) Bio-Film',
      materialType: 'Biodegradable Aliphatic Polyester',
      polymerFamily: 'BIO_PLA',
      structure: 'Bio-based Extruded Film',
      barrierProfile: BarrierProfile(
        otr: '3200.0 cc/m²/day',
        wvtr: '48.0 g/m²/day',
        thicknessMicrons: 35.0,
        tensileStrengthMpa: 42.0,
        punctureResistanceN: 22.0,
      ),
      sustainabilityScore: 92.0,
      estimatedUnitCostInr: 3.85,
      suitabilityScore: 0.94,
      activeAdditives: ['Ethylene Absorber'],
      packagingTitle: 'Equilibrium Modified Atmosphere Bio-Clamshell',
      packagingFormat: 'Hinged Clamshell with Laser Micro-Perforations',
      recommendationExplanation:
          'High respiration rate and moisture management requires permeable PLA structure.',
      advantages: [
        'Naturally compostable under industrial conditions',
        'Balanced gas permeability prevents fermentation',
      ],
      limitations: [
        'Brittle under freezing conditions below -5°C',
      ],
      suitableStorageCondition: 'Cool dry store (12-15°C, 65% RH)',
      expectedApplication: 'Fresh Strawberries, High-Respiring Soft Fruits',
      importantProperties: {
        'OTR': '3200.0 cc/m²/day',
        'WVTR': '48.0 g/m²/day',
      },
    ),
    alternatives: const [
      PackagingAlternative(
        type: AlternativeType.ecoFriendly,
        typeRaw: 'ECO_FRIENDLY',
        packagingTitle: 'Cellulose Bio-Film (NatureFlex)',
        materialName: 'Cellulose Acetate Bio-Film',
        starRating: 4,
        starDisplay: '★★★★☆',
        suitabilityCategory: SuitabilityCategory.highCompatibility,
        modelDerivedProbability: 0.86,
        compatibilityConfidence: 'Model-Derived Probability: 86%',
        costDeltaPct: 16.9,
        ecoDeltaPct: 4.3,
        sustainabilityScore: 96.0,
        estimatedUnitCostInr: 4.50,
        characteristics: MaterialCharacteristics(
          otr: '2,800 cc/m²/day',
          wvtr: '50.0 g/m²/day',
          sustainabilityRating: '100% Home Compostable',
          estimatedCostInr: 4.50,
          costTier: 'Moderate (₹₹)',
        ),
        tradeOffSummary: '100% Home compostable with crystal clarity; +17% cost premium.',
        shelfLifeDelta: 'Equal (21 days)',
        advantages: ['100% home compostable and marine safe'],
        limitations: ['17% cost premium over fossil plastics'],
      ),
      PackagingAlternative(
        type: AlternativeType.economy,
        typeRaw: 'ECONOMY',
        packagingTitle: 'Perforated LDPE Breathable Liner',
        materialName: 'Low-Density Polyethylene',
        starRating: 3,
        starDisplay: '★★★☆☆',
        suitabilityCategory: SuitabilityCategory.moderateCompatibility,
        modelDerivedProbability: 0.74,
        compatibilityConfidence: 'Model-Derived Probability: 74%',
        costDeltaPct: -49.4,
        ecoDeltaPct: -41.3,
        sustainabilityScore: 54.0,
        estimatedUnitCostInr: 1.95,
        characteristics: MaterialCharacteristics(
          otr: '3,800 cc/m²/day',
          wvtr: '18.0 g/m²/day',
          sustainabilityRating: 'Fossil Synthetic / Recyclable #4',
          estimatedCostInr: 1.95,
          costTier: 'Economy (₹)',
        ),
        tradeOffSummary: 'Maximum commercial cost savings (49% cheaper); lower sustainability score.',
        shelfLifeDelta: '-2 days (19 days)',
        advantages: ['49% cheaper than bio-derived packaging'],
        limitations: ['Fossil-derived with lower sustainability score'],
      ),
      PackagingAlternative(
        type: AlternativeType.highBarrier,
        typeRaw: 'HIGH_BARRIER',
        packagingTitle: 'High-Integrity Punched PP Clamshell',
        materialName: 'Polypropylene Rigid Container',
        starRating: 3,
        starDisplay: '★★★☆☆',
        suitabilityCategory: SuitabilityCategory.moderateCompatibility,
        modelDerivedProbability: 0.71,
        compatibilityConfidence: 'Model-Derived Probability: 71%',
        costDeltaPct: -16.9,
        ecoDeltaPct: -32.6,
        sustainabilityScore: 62.0,
        estimatedUnitCostInr: 3.20,
        characteristics: MaterialCharacteristics(
          otr: '1,500 cc/m²/day',
          wvtr: '5.0 g/m²/day',
          sustainabilityRating: 'Technical Recyclable #5',
          estimatedCostInr: 3.20,
          costTier: 'Moderate (₹₹)',
        ),
        tradeOffSummary: 'Superior mechanical crush resistance for heavy palletization.',
        shelfLifeDelta: 'Equal (21 days)',
        advantages: ['High structural strength prevents transit bruising'],
        limitations: ['Requires ventilation punching to prevent condensation'],
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
      summary: 'Strawberries have high respiration requiring permeable bio-film.',
      keyDrivers: ['High respiration rate requires balanced gas permeation.'],
    ),
    recommendedBoxType: 'Optimized Micro-Perforated Clamshell',
    recommendedDimensions: '25.0 x 15.0 x 10.0 cm',
    boxVolumeCm3: 3750.0,
    itemVolumeCm3: 2800.0,
    spaceUtilizationPct: 76.5,
    cushioningMaterial: 'Molded Cellulose Pulp Nest Cushioning',
    estimatedCost: 3.85,
    sustainabilityScore: 92.0,
  );

  Widget createAuditWidget(Size size) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: size),
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RecommendationResultsCockpit(
                  result: richResult,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('Multi-Viewport Responsive Layout Audit (Task 5.2)', () {
    testWidgets('renders cleanly on Mobile Viewport (375 x 812) with 0 RenderFlex overflow',
        (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createAuditWidget(const Size(375, 812)));
      await tester.pumpAndSettle();

      expect(find.text('ALTERNATIVE PACKAGING PATHWAYS'), findsOneWidget);
      expect(find.text('Cellulose Bio-Film (NatureFlex)'), findsOneWidget);
      expect(find.text('Perforated LDPE Breathable Liner'), findsOneWidget);
      expect(find.text('High-Integrity Punched PP Clamshell'), findsOneWidget);

      // Verify no exceptions were thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on Tablet Viewport (768 x 1024) with 0 RenderFlex overflow',
        (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createAuditWidget(const Size(768, 1024)));
      await tester.pumpAndSettle();

      expect(find.text('ALTERNATIVE PACKAGING PATHWAYS'), findsOneWidget);
      expect(find.text('Cellulose Bio-Film (NatureFlex)'), findsOneWidget);
      expect(find.text('Perforated LDPE Breathable Liner'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on Desktop Viewport (1280 x 900) with 0 RenderFlex overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createAuditWidget(const Size(1280, 900)));
      await tester.pumpAndSettle();

      expect(find.text('ALTERNATIVE PACKAGING PATHWAYS'), findsOneWidget);
      expect(find.text('Cellulose Bio-Film (NatureFlex)'), findsOneWidget);
      expect(find.text('Perforated LDPE Breathable Liner'), findsOneWidget);
      expect(find.text('High-Integrity Punched PP Clamshell'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
