import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_scientific_profile.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/characteristics_radar_chart.dart';

void main() {
  group('CharacteristicsRadarChart Widget Tests', () {
    late FoodScientificProfile tomatoProfile;

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
    });

    testWidgets('renders Radar Chart header, canvas, and 6 dimension chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CharacteristicsRadarChart(
                profile: tomatoProfile,
                animate: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Characteristics Radar'), findsOneWidget);
      expect(find.text('6-Axis Polygon'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Verify all 6 dimension chip labels are rendered
      expect(find.text('Moisture'), findsWidgets);
      expect(find.text('Respiration'), findsWidgets);
      expect(find.text('Thermal Risk'), findsWidgets);
      expect(find.text('Ethylene'), findsWidgets);
      expect(find.text('Mechanical'), findsWidgets);
      expect(find.text('Gas Barrier'), findsWidgets);
    });

    testWidgets('tapping a dimension chip displays the interactive HUD details card',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CharacteristicsRadarChart(
                profile: tomatoProfile,
                animate: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Respiration chip
      await tester.tap(find.text('Respiration').last);
      await tester.pumpAndSettle();

      // Check that HUD readout appears
      expect(find.textContaining('Normalized Score:'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Close HUD readout
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });
}
