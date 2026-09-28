import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/primary_recommendation_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/alternative_materials_matrix.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/box_geometry_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/explainable_ai_rationale_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/recommendation_results_cockpit.dart';

void main() {
  const primaryRec = PrimaryRecommendation(
    materialName: 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)',
    materialType: 'Biodegradable Bio-Polymer',
    polymerFamily: 'BREATHABLE_BIO_EMAP',
    structure: 'Co-extruded Micro-Perforated PLA/PBAT',
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
  );

  const alts = [
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
  ];

  const geom = BoxGeometrySpecs(
    lengthCm: 28.5,
    widthCm: 17.6,
    heightCm: 14.1,
    totalVolumeCm3: 7072.0,
    spaceUtilizationPct: 78.5,
    cushioningMaterial: 'Recycled Kraft Thermal Insulated Pouch + Cold Gel Pack',
  );

  const xai = ExplainableAiRationale(
    summary: 'Fresh Tomato requires Equilibrium Modified Atmosphere (EMAP).',
    keyDrivers: [
      'High respiration rate requires gas-permeable micro-perforations.',
      'High moisture content requires anti-fog surfactant.',
    ],
  );

  final mockResult = PackagingRecommendationResult(
    recommendationId: 'rec_test123',
    primaryRecommendation: primaryRec,
    alternatives: alts,
    boxGeometry: geom,
    scientificRationale: xai,
    recommendedBoxType: 'Optimized PLA/PBAT Carton',
    recommendedDimensions: '28.5 x 17.6 x 14.1 cm',
    boxVolumeCm3: 7072.0,
    itemVolumeCm3: 5500.0,
    spaceUtilizationPct: 78.5,
    cushioningMaterial: 'Recycled Kraft Thermal Insulated Pouch + Cold Gel Pack',
    estimatedCost: 3.85,
    sustainabilityScore: 94.0,
  );

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  group('Recommendation Modular Widgets Tests (Task 4.4)', () {
    testWidgets('PrimaryRecommendationCard renders barrier specs and active additives', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PrimaryRecommendationCard(recommendation: primaryRec),
      ));

      expect(find.text('Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)'), findsOneWidget);
      expect(find.text('96% Match'), findsOneWidget);
      expect(find.text('Eco-Score: 94/100'), findsOneWidget);
      expect(find.text('3500.0 cc/m²/day'), findsOneWidget);
      expect(find.text('45.00 g/m²/day'), findsOneWidget);
      expect(find.text('Potassium Permanganate (KMnO₄) Ethylene Scavenger Sachet'), findsOneWidget);
      expect(find.text('Antifog Surface Surfactant Coating'), findsOneWidget);
    });

    testWidgets('AlternativeMaterialsMatrix renders all alternatives with selection callbacks', (tester) async {
      PackagingAlternative? selectedAlt;

      await tester.pumpWidget(createTestWidget(
        AlternativeMaterialsMatrix(
          alternatives: alts,
          onAlternativeSelected: (alt) => selectedAlt = alt,
        ),
      ));

      expect(find.text('ALTERNATIVE PACKAGING PATHWAYS'), findsOneWidget);
      expect(find.text('Cellulose-Based Breathable Bio-Film (NatureFlex)'), findsOneWidget);
      expect(find.text('Perforated Low-Density Polyethylene (LDPE)'), findsOneWidget);

      await tester.tap(find.text('Select This Option').first);
      expect(selectedAlt?.materialName, contains('NatureFlex'));
    });

    testWidgets('BoxGeometryCard renders dimensions and cushioning matrix', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const BoxGeometryCard(geometry: geom),
      ));

      expect(find.text('VOLUMETRIC BOX GEOMETRY'), findsOneWidget);
      expect(find.text('28.5 cm'), findsOneWidget);
      expect(find.text('17.6 cm'), findsOneWidget);
      expect(find.text('14.1 cm'), findsOneWidget);
      expect(find.text('78.5%'), findsOneWidget);
      expect(find.text('Recycled Kraft Thermal Insulated Pouch + Cold Gel Pack'), findsOneWidget);
    });

    testWidgets('ExplainableAiRationaleCard renders summary and key drivers', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const ExplainableAiRationaleCard(rationale: xai),
      ));

      expect(find.text('EXPLAINABLE AI SCIENTIFIC RATIONALE'), findsOneWidget);
      expect(find.text('Fresh Tomato requires Equilibrium Modified Atmosphere (EMAP).'), findsOneWidget);
      expect(find.text('High respiration rate requires gas-permeable micro-perforations.'), findsOneWidget);
      expect(find.text('High moisture content requires anti-fog surfactant.'), findsOneWidget);
    });

    testWidgets('RecommendationResultsCockpit renders all combined cards', (tester) async {
      await tester.pumpWidget(createTestWidget(
        RecommendationResultsCockpit(result: mockResult),
      ));

      expect(find.text('AI PACKAGING PRESCRIPTION'), findsOneWidget);
      expect(find.text('RECOMMENDED PACKAGING'), findsOneWidget);
      expect(find.text('RECOMMENDATION EXPLANATION'), findsOneWidget);
      expect(find.text('IMPORTANT PROPERTIES'), findsOneWidget);
      expect(find.text('PACKAGING FORMAT & GEOMETRY'), findsOneWidget);
      expect(find.text('ALTERNATIVE PACKAGING PATHWAYS'), findsOneWidget);
    });
  });
}
