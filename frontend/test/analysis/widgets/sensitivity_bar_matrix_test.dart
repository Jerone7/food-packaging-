import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_scientific_profile.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/critical_vulnerability_banner.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/sensitivity_bar_matrix.dart';

void main() {
  group('SensitivityBarMatrix & CriticalVulnerabilityBanner Widget Tests', () {
    late FoodScientificProfile tomatoProfile;
    late FoodScientificProfile stableGrainProfile;

    setUp(() {
      tomatoProfile = const FoodScientificProfile(
        foodId: 1,
        commodityName: 'Fresh Tomato',
        category: 'Vegetables',
        physicochemical: PhysicochemicalTraits(
          moisturePct: 94.5,
          fatPct: 0.2,
          ph: 4.4,
          waterActivity: 0.99,
          moistureSensitivity: 'High',
        ),
        physiologicalKinetics: PhysiologicalKinetics(
          respirationClass: 'High',
          respirationRate20c: 45.0,
          ethyleneSensitivity: 'High',
        ),
        atmosphereSensitivities: AtmosphereSensitivities(
          oxygenSensitivity: 'Moderate',
          co2Sensitivity: 'Moderate',
        ),
        thermalAndStorage: ThermalAndStorage(
          perishability: 'Highly perishable',
          optimumTempMinC: 12.0,
          optimumTempMaxC: 15.0,
          chillingInjuryThresholdC: 10.0,
          ambientShelfLifeDays: 7,
          refrigeratedShelfLifeDays: 21,
          controlledAtmosphereShelfLifeDays: 42,
        ),
        spoilageAndVulnerabilities: SpoilageAndVulnerabilities(
          lightSensitivity: 'Low',
          aromaSensitivity: 'Low',
          microbialSpoilageVector: 'Botrytis cinerea',
          mechanicalSensitivity: 'High',
        ),
        packagingPrescriptions: PackagingPrescriptions(
          recommendedBarrierType: 'Perforated LDPE',
          requiredOtrRange: '1500 - 3000 cc/m²/day',
          requiredWvtrRange: '< 15 g/m²/day',
        ),
      );

      stableGrainProfile = const FoodScientificProfile(
        foodId: 2,
        commodityName: 'Basmati Rice',
        category: 'Grains',
        physicochemical: PhysicochemicalTraits(
          moisturePct: 12.0,
          fatPct: 0.5,
          ph: 6.8,
          waterActivity: 0.60,
          moistureSensitivity: 'Low',
        ),
        physiologicalKinetics: PhysiologicalKinetics(
          respirationClass: 'Low',
          respirationRate20c: 2.0,
          ethyleneSensitivity: 'Low',
        ),
        atmosphereSensitivities: AtmosphereSensitivities(
          oxygenSensitivity: 'Low',
          co2Sensitivity: 'Tolerant',
        ),
        thermalAndStorage: ThermalAndStorage(
          perishability: 'Low perishability',
          optimumTempMinC: 15.0,
          optimumTempMaxC: 25.0,
          ambientShelfLifeDays: 365,
        ),
        spoilageAndVulnerabilities: SpoilageAndVulnerabilities(
          lightSensitivity: 'Low',
          aromaSensitivity: 'Low',
          microbialSpoilageVector: 'Weevil infestation',
          mechanicalSensitivity: 'Low',
        ),
        packagingPrescriptions: PackagingPrescriptions(
          recommendedBarrierType: 'Woven PP Sack / Multi-layer Pouch',
          requiredOtrRange: 'Standard',
          requiredWvtrRange: '< 5 g/m²/day',
        ),
      );
    });

    testWidgets('CriticalVulnerabilityBanner renders urgent chips on chilling sensitive produce',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CriticalVulnerabilityBanner(profile: tomatoProfile),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Critical Degradation Drivers'), findsOneWidget);
      expect(find.textContaining('CHILLING SENSITIVE'), findsOneWidget);
      expect(find.textContaining('HIGH METABOLIC ACTIVITY'), findsOneWidget);
      expect(find.textContaining('ETHYLENE SENSITIVE'), findsOneWidget);
    });

    testWidgets('CriticalVulnerabilityBanner renders stable notice when no critical flags exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CriticalVulnerabilityBanner(profile: stableGrainProfile),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Optimal Postharvest Stability'), findsOneWidget);
    });

    testWidgets('SensitivityBarMatrix renders all 8 bars with animated progress and values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SensitivityBarMatrix(
                profile: tomatoProfile,
                animate: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sensitivity & Degradation Profile'), findsOneWidget);
      expect(find.text('Moisture Loss / Gain Risk'), findsOneWidget);
      expect(find.text('Respiration Rate (20°C)'), findsOneWidget);
      expect(find.text('Oxygen (O₂) Sensitivity'), findsOneWidget);
      expect(find.text('Overall Perishability Tier'), findsOneWidget);
      expect(find.text('Thermal & Chilling Risk'), findsOneWidget);
      expect(find.text('Ethylene Vulnerability'), findsOneWidget);
      expect(find.text('Mechanical Fragility'), findsOneWidget);
      expect(find.text('Light / Photo-Oxidation'), findsOneWidget);

      expect(find.text('94.5%'), findsOneWidget);
      expect(find.text('45 mg CO₂/kg/h'), findsOneWidget);

      // Tap to expand consequence description
      await tester.tap(find.text('Moisture Loss / Gain Risk'));
      await tester.pumpAndSettle();

      expect(find.textContaining('WVTR'), findsOneWidget);
    });
  });
}
