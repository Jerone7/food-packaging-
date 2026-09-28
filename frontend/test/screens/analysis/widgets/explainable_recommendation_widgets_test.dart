import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/advantages_limitations_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/explainable_recommendation_banner.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/important_properties_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/packaging_format_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/recommended_packaging_hero_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/storage_application_card.dart';

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
    activeAdditives: ['Ethylene Scavenger Sachet', 'Antifog Coating'],
    packagingTitle: 'Ventilated Food-Grade Packaging',
    packagingFormat: 'Micro-Perforated Hinged Clamshell',
    recommendationExplanation:
        'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
    advantages: [
      'Equilibrium modified atmosphere (EMAP) prevents anaerobic souring',
      'Anti-fog coating suppresses condensation water droplets and mold',
    ],
    limitations: [
      'Not suitable for vacuum packing or high-temperature retort processing',
      'Storage duration limited to 14–21 days under ambient conditions',
    ],
    suitableStorageCondition: 'Cold Storage: 10°C - 12°C (90-95% RH)',
    expectedApplication:
        'High-respiration fresh produce, strawberries, cut fruits, cherry tomatoes',
    importantProperties: {
      'OTR (Oxygen Barrier)': '3500.0 cc/m²/day',
      'WVTR (Moisture Barrier)': '45.00 g/m²/day',
      'Film Thickness': '30.0 µm',
      'Tensile Strength': '32.0 MPa',
      'Puncture Resistance': '18.0 N',
      'Thermal Span': '0°C to 45°C',
    },
  );

  const sampleGeometry = BoxGeometrySpecs(
    lengthCm: 25.0,
    widthCm: 15.0,
    heightCm: 10.0,
    totalVolumeCm3: 3750.0,
    spaceUtilizationPct: 76.5,
    cushioningMaterial: 'Molded Cellulose Pulp Nest Cushioning',
  );

  group('Explainable Recommendation Modular Widgets Suite (Phase 4)', () {
    testWidgets('RecommendedPackagingHeroCard renders headline, title, score, and badges', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendedPackagingHeroCard(recommendation: sampleRec),
            ),
          ),
        ),
      );

      expect(find.text('RECOMMENDED PACKAGING'), findsOneWidget);
      expect(find.text('Ventilated Food-Grade Packaging'), findsOneWidget);
      expect(find.text('96% Match'), findsOneWidget);
      expect(find.text('94/100'), findsOneWidget);
      expect(find.text('₹3.85'), findsOneWidget);
    });

    testWidgets('ExplainableRecommendationBanner renders exact XAI narrative', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExplainableRecommendationBanner(
                explanation: sampleRec.recommendationExplanation,
                keyDrivers: const [
                  'High respiration rate requires gas exchange',
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('RECOMMENDATION EXPLANATION'), findsOneWidget);
      expect(
        find.text(
          'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
        ),
        findsOneWidget,
      );
      expect(find.text('High respiration rate requires gas exchange'), findsOneWidget);
    });

    testWidgets('ImportantPropertiesCard renders all barrier and physical metrics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ImportantPropertiesCard(
                importantProperties: sampleRec.importantProperties,
                barrierProfile: sampleRec.barrierProfile,
              ),
            ),
          ),
        ),
      );

      expect(find.text('IMPORTANT PROPERTIES'), findsOneWidget);
      expect(find.text('OTR (Oxygen Barrier)'), findsOneWidget);
      expect(find.text('3500.0 cc/m²/day'), findsOneWidget);
      expect(find.text('WVTR (Moisture Barrier)'), findsOneWidget);
      expect(find.text('45.00 g/m²/day'), findsOneWidget);
    });

    testWidgets('AdvantagesAndLimitationsCard renders balanced strengths and constraints', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdvantagesAndLimitationsCard(
                advantages: sampleRec.advantages,
                limitations: sampleRec.limitations,
              ),
            ),
          ),
        ),
      );

      expect(find.text('ADVANTAGES'), findsOneWidget);
      expect(find.text('LIMITATIONS'), findsOneWidget);
      expect(find.text(sampleRec.advantages.first), findsOneWidget);
      expect(find.text(sampleRec.limitations.first), findsOneWidget);
    });

    testWidgets('StorageAndApplicationCard & PackagingFormatCard render specifications', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  StorageAndApplicationCard(
                    suitableStorageCondition: sampleRec.suitableStorageCondition,
                    expectedApplication: sampleRec.expectedApplication,
                    chillingInjuryThresholdC: 10.0,
                  ),
                  PackagingFormatCard(
                    packagingFormat: sampleRec.packagingFormat,
                    geometry: sampleGeometry,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('SUITABLE STORAGE & APPLICATION'), findsOneWidget);
      expect(find.text(sampleRec.suitableStorageCondition), findsOneWidget);
      expect(find.text(sampleRec.expectedApplication), findsOneWidget);
      expect(find.text('PACKAGING FORMAT & GEOMETRY'), findsOneWidget);
      expect(find.text('Micro-Perforated Hinged Clamshell'), findsOneWidget);
      expect(find.text('25.0 cm'), findsOneWidget);
    });
  });
}
