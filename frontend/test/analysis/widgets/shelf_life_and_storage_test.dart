import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_scientific_profile.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/shelf_life_matrix_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/storage_requirements_card.dart';

void main() {
  group('ShelfLifeMatrixCard & StorageRequirementsCard Widget Tests', () {
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
          equilibriumRhTargetPct: 92.0,
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

    testWidgets('ShelfLifeMatrixCard renders 4 storage regimes and MAP extension multiplier',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ShelfLifeMatrixCard(profile: tomatoProfile),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Preservation & Shelf-Life Horizon'), findsOneWidget);
      expect(find.textContaining('6.0x MAP Horizon'), findsOneWidget);

      expect(find.text('Ambient (25°C)'), findsOneWidget);
      expect(find.text('7 Days'), findsOneWidget);

      expect(find.text('Refrigerated (4°C)'), findsOneWidget);
      expect(find.text('21 Days'), findsOneWidget);

      expect(find.text('MAP + Cold'), findsOneWidget);
      expect(find.text('42 Days'), findsOneWidget);

      // Tap to toggle Arrhenius simulator
      await tester.tap(find.text('Arrhenius Temperature Shelf-Life Simulator'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Storage Temperature:'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('StorageRequirementsCard renders temperature, RH, ethylene rules, and chilling warning',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StorageRequirementsCard(profile: tomatoProfile),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Storage & Environmental Safeguards'), findsOneWidget);
      expect(find.text('12°C - 15°C'), findsOneWidget);
      expect(find.text('87% - 97% RH'), findsOneWidget);
      expect(find.text('Segregation Mandated'), findsOneWidget);
      expect(find.textContaining('CRITICAL SAFEGUARD: Do NOT store in standard 4°C refrigeration'), findsOneWidget);
    });
  });
}
