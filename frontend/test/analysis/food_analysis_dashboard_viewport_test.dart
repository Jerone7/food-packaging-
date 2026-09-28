import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_scientific_profile.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_analysis_dashboard.dart';
import 'package:ai_packaging_recommender/screens/analysis/food_analysis_screen.dart';

void main() {
  group('FoodAnalysisDashboard Multi-Viewport Responsive Layout Audit', () {
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

    testWidgets('renders cleanly on Mobile Viewport (375x812) with zero overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodAnalysisDashboard(
                profile: tomatoProfile,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Critical Degradation Drivers'), findsOneWidget);
      expect(find.text('Sensitivity & Degradation Profile'), findsOneWidget);
      expect(find.text('Characteristics Radar'), findsOneWidget);
      expect(find.text('Preservation & Shelf-Life Horizon'), findsOneWidget);
      expect(find.text('Storage & Environmental Safeguards'), findsOneWidget);
      expect(find.text('Auto-Retrieved Scientific Dossier'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on Tablet Viewport (768x1024) with zero overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodAnalysisDashboard(
                profile: tomatoProfile,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Critical Degradation Drivers'), findsOneWidget);
      expect(find.text('Sensitivity & Degradation Profile'), findsOneWidget);
      expect(find.text('Characteristics Radar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on Desktop Viewport (1280x900) 2-column cockpit with zero overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodAnalysisDashboard(
                profile: tomatoProfile,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Critical Degradation Drivers'), findsOneWidget);
      expect(find.text('Sensitivity & Degradation Profile'), findsOneWidget);
      expect(find.text('Characteristics Radar'), findsOneWidget);
      expect(find.text('Preservation & Shelf-Life Horizon'), findsOneWidget);
      expect(find.text('Storage & Environmental Safeguards'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FoodAnalysisScreen master screen integrates dashboard seamlessly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodAnalysisScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FoodAnalysisDashboard), findsOneWidget);
      expect(find.text('Sensitivity & Degradation Profile'), findsOneWidget);
      expect(find.text('Characteristics Radar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
