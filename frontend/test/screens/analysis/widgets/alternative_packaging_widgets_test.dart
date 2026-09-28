import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/suitability_badge.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/characteristics_mini_grid.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/trade_off_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/alternative_candidate_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/alternative_materials_matrix.dart';

void main() {
  group('SuitabilityBadge Component Tests', () {
    testWidgets('renders Optimal Match with emerald styling and verified icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SuitabilityBadge(
                category: SuitabilityCategory.optimalMatch,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Optimal Match'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    });

    testWidgets('renders High Compatibility with sky blue styling and star icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SuitabilityBadge(
                category: SuitabilityCategory.highCompatibility,
                showTier: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('High Compatibility (Tier 2)'), findsOneWidget);
      expect(find.byIcon(Icons.stars_rounded), findsOneWidget);
    });

    testWidgets('renders Moderate Compatibility with amber styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SuitabilityBadge(
                category: SuitabilityCategory.moderateCompatibility,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Moderate Compatibility'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });
  });

  group('ModelConfidenceChip Component Tests', () {
    testWidgets('renders formatted percentage and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ModelConfidenceChip(
                probability: 0.864,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Model Probability: 86%'), findsOneWidget);
      expect(find.byIcon(Icons.auto_graph_rounded), findsOneWidget);
    });

    testWidgets('renders custom confidence label when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ModelConfidenceChip(
                probability: 0.92,
                confidenceLabel: 'High Confidence (0.92)',
              ),
            ),
          ),
        ),
      );

      expect(find.text('High Confidence (0.92)'), findsOneWidget);
    });
  });

  group('CharacteristicsMiniGrid Component Tests', () {
    testWidgets('renders all 4 tiles with values and delta pills', (tester) async {
      const chars = MaterialCharacteristics(
        otr: '2,800 cc/m²/day',
        wvtr: '50.0 g/m²/day',
        sustainabilityRating: '100% Home Compostable',
        estimatedCostInr: 4.50,
        costTier: 'Moderate (₹₹)',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CharacteristicsMiniGrid(
                characteristics: chars,
                costDeltaPct: 16.9,
                ecoDeltaPct: 4.3,
              ),
            ),
          ),
        ),
      );

      expect(find.text('OXYGEN BARRIER (OTR)'), findsOneWidget);
      expect(find.text('2,800 cc/m²/day'), findsOneWidget);
      expect(find.text('MOISTURE (WVTR)'), findsOneWidget);
      expect(find.text('50.0 g/m²/day'), findsOneWidget);
      expect(find.text('100% Home Compostable'), findsOneWidget);
      expect(find.text('₹4.50'), findsOneWidget);
      expect(find.text('+4% Eco'), findsOneWidget);
      expect(find.text('+17% Cost'), findsOneWidget);
    });
  });

  group('TradeOffCard Component Tests', () {
    testWidgets('renders trade-off summary, advantages, and shelf life impact badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TradeOffCard(
                tradeOffSummary: '100% Home compostable with crystal clarity; +17% unit cost.',
                shelfLifeDelta: 'Equal (21 days)',
                advantages: [
                  '100% bio-derived and marine degradable',
                  'Excellent gas permselectivity',
                ],
                limitations: [
                  'Slightly higher unit cost than fossil LDPE',
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('100% Home compostable with crystal clarity; +17% unit cost.'), findsOneWidget);
      expect(find.text('Shelf Life Impact: Equal (21 days)'), findsOneWidget);
      expect(find.text('Key Advantages:'), findsOneWidget);
      expect(find.text('100% bio-derived and marine degradable'), findsOneWidget);
      expect(find.text('Operational Boundaries:'), findsOneWidget);
      expect(find.text('Slightly higher unit cost than fossil LDPE'), findsOneWidget);
    });
  });

  group('AlternativeCandidateCard Component Tests', () {
    const sampleAlt = PackagingAlternative(
      type: AlternativeType.ecoFriendly,
      typeRaw: 'eco_friendly',
      packagingTitle: 'Bio-PLA High-Clarity Film',
      materialName: 'Polylactic Acid (Bio-PLA)',
      starRating: 4,
      suitabilityCategory: SuitabilityCategory.highCompatibility,
      modelDerivedProbability: 0.86,
      compatibilityConfidence: 'Model-Derived Probability: 86%',
      costDeltaPct: 16.9,
      ecoDeltaPct: 4.3,
      sustainabilityScore: 92.0,
      estimatedUnitCostInr: 4.50,
      characteristics: MaterialCharacteristics(
        otr: '2,800 cc/m²/day',
        wvtr: '50.0 g/m²/day',
        sustainabilityRating: '100% Bio-compostable',
        estimatedCostInr: 4.50,
        costTier: 'Moderate (₹₹)',
      ),
      tradeOffSummary: 'Premium eco-profile with 100% compostability; 17% cost premium.',
      shelfLifeDelta: 'Equal (21 days)',
      advantages: ['100% home compostable', 'High transparency'],
      limitations: ['Higher unit cost'],
    );

    testWidgets('renders all details, badges, and triggers selection callback', (tester) async {
      bool selected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AlternativeCandidateCard(
                alternative: sampleAlt,
                optionIndex: 2,
                isSelected: false,
                onSelect: () => selected = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('OPTION 2: ECO-CHAMPION'), findsOneWidget);
      expect(find.text('Bio-PLA High-Clarity Film'), findsOneWidget);
      expect(find.text('Polylactic Acid (Bio-PLA)'), findsOneWidget);
      expect(find.text('High Compatibility'), findsOneWidget);
      expect(find.text('Model-Derived Probability: 86%'), findsOneWidget);
      expect(find.text('Select This Option'), findsOneWidget);

      await tester.tap(find.text('Select This Option'));
      await tester.pump();

      expect(selected, isTrue);
    });

    testWidgets('renders Currently Selected state when isSelected is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AlternativeCandidateCard(
                alternative: sampleAlt,
                optionIndex: 2,
                isSelected: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Currently Selected'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    });
  });

  group('AlternativeMaterialsMatrix Component Tests', () {
    final List<PackagingAlternative> sampleAlternatives = [
      const PackagingAlternative(
        type: AlternativeType.ecoFriendly,
        typeRaw: 'eco_friendly',
        packagingTitle: 'Bio-PLA Eco Film',
        materialName: 'Polylactic Acid',
        starRating: 4,
        suitabilityCategory: SuitabilityCategory.highCompatibility,
        modelDerivedProbability: 0.86,
        costDeltaPct: 15.0,
        ecoDeltaPct: 5.0,
        sustainabilityScore: 90.0,
        estimatedUnitCostInr: 4.20,
        tradeOffSummary: 'Eco champion option.',
      ),
      const PackagingAlternative(
        type: AlternativeType.economy,
        typeRaw: 'economy',
        packagingTitle: 'Recycled Polyolefin Film',
        materialName: 'rHDPE Film',
        starRating: 3,
        suitabilityCategory: SuitabilityCategory.moderateCompatibility,
        modelDerivedProbability: 0.74,
        costDeltaPct: -22.0,
        ecoDeltaPct: -10.0,
        sustainabilityScore: 78.0,
        estimatedUnitCostInr: 2.80,
        tradeOffSummary: 'Cost-optimized option.',
      ),
    ];

    testWidgets('renders candidate cards and allows selection', (tester) async {
      PackagingAlternative? chosen;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AlternativeMaterialsMatrix(
                alternatives: sampleAlternatives,
                selectedMaterialName: 'Polylactic Acid',
                onAlternativeSelected: (alt) => chosen = alt,
              ),
            ),
          ),
        ),
      );

      expect(find.text('ALTERNATIVE PACKAGING PATHWAYS'), findsOneWidget);
      expect(find.text('Bio-PLA Eco Film'), findsOneWidget);
      expect(find.text('Recycled Polyolefin Film'), findsOneWidget);
      expect(find.text('Currently Selected'), findsOneWidget);
      expect(find.text('Select This Option'), findsOneWidget);

      await tester.tap(find.text('Select This Option'));
      await tester.pump();

      expect(chosen?.materialName, equals('rHDPE Film'));
    });
  });
}
