import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/recommended_packaging_hero_card.dart';

void main() {
  const sampleRec = PrimaryRecommendation(
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
      'OTR (Gas Permeability)': '3500.0 cc/m²/day',
    },
  );

  Widget createTestWidget({VoidCallback? onApply}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RecommendedPackagingHeroCard(
              recommendation: sampleRec,
              onApplyPressed: onApply,
            ),
          ),
        ),
      ),
    );
  }

  group('RecommendedPackagingHeroCard Widget Tests (Task 4.1)', () {
    testWidgets('renders headline badge, packaging title, and material subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('RECOMMENDED PACKAGING'), findsOneWidget);
      expect(find.text('Ventilated Food-Grade Packaging'), findsOneWidget);
      expect(
        find.text('Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT) • Co-extruded Micro-Perforated PLA/PBAT Blown Film'),
        findsOneWidget,
      );
    });

    testWidgets('renders suitability score gauge, eco-score, and unit cost', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('96% Match'), findsOneWidget);
      expect(find.text('Highly Compatible'), findsOneWidget);
      expect(find.text('94/100'), findsOneWidget);
      expect(find.text('₹3.85'), findsOneWidget);
      expect(find.text('Micro-Perforated Hinged Clamshell'), findsOneWidget);
    });

    testWidgets('triggers onApplyPressed callback when button is clicked', (tester) async {
      bool applied = false;
      await tester.pumpWidget(createTestWidget(onApply: () => applied = true));

      expect(find.text('Adopt Recommended Configuration'), findsOneWidget);
      await tester.tap(find.text('Adopt Recommended Configuration'));
      await tester.pumpAndSettle();

      expect(applied, isTrue);
    });
  });
}
