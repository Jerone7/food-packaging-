import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_scientific_profile.dart';
import 'package:ai_packaging_recommender/models/storage_condition.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/sensitivity_radar_badge.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/thermal_stability_gauge.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/atmosphere_dynamics_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_scientific_dossier_card.dart';

void main() {
  const sampleProfile = FoodScientificProfile(
    foodId: 2,
    commodityName: 'Fresh Tomato',
    scientificName: 'Solanum lycopersicum',
    category: 'Vegetables',
    source: 'ICMR-NIN IFCT 2017 & UC Davis Postharvest Facts',
    confidenceScore: 0.96,
    physicochemical: PhysicochemicalTraits(
      moisturePct: 94.5,
      waterActivity: 0.99,
      ph: 4.4,
      fatPct: 0.2,
      moistureSensitivity: 'High (Critical)',
    ),
    physiologicalKinetics: PhysiologicalKinetics(
      respirationClass: 'Moderate to High (Climacteric)',
      respirationRate5c: 8.0,
      respirationRate20c: 28.0,
      ethyleneProdRate: 5.5,
      ethyleneProductionClass: 'Moderate',
      ethyleneSensitivity: 'High',
    ),
    atmosphereSensitivities: AtmosphereSensitivities(
      oxygenSensitivity: 'High',
      co2Sensitivity: 'High (Injury > 5%)',
      targetEmapO2Pct: '3-5%',
      targetEmapCo2Pct: '3-5%',
      maxTolerableCo2Pct: 5.0,
    ),
    thermalAndStorage: ThermalAndStorage(
      perishability: 'Highly Perishable',
      optimumTempMinC: 10.0,
      optimumTempMaxC: 13.0,
      freezingPointC: -0.5,
      chillingInjuryThresholdC: 10.0,
      ambientShelfLifeDays: 7,
      refrigeratedShelfLifeDays: 14,
      controlledAtmosphereShelfLifeDays: 28,
    ),
    spoilageAndVulnerabilities: SpoilageAndVulnerabilities(
      lightSensitivity: 'Moderate',
      aromaSensitivity: 'Low',
      microbialSpoilageVector: 'Botrytis cinerea (Grey Mold), Alternaria rot',
      mechanicalSensitivity: 'High',
    ),
    packagingPrescriptions: PackagingPrescriptions(
      recommendedBarrierType: 'Micro-perforated Equilibrium MAP (EMAP)',
      requiredOtrRange: 'High (Micro-perforated or 3000-8000 cc/m2/day)',
      requiredWvtrRange: 'Medium-High (Anti-fog coated)',
      ethyleneActionRequired: true,
    ),
  );

  group('SensitivityRadarBadge Widget Tests', () {
    testWidgets('renders badge with label and level text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SensitivityRadarBadge(
              label: 'Oxygen (O₂)',
              level: 'High',
              icon: Icons.grain_rounded,
            ),
          ),
        ),
      );

      expect(find.text('Oxygen (O₂)'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.byIcon(Icons.grain_rounded), findsOneWidget);
    });

    testWidgets('formats critical, moderate, and low sensitivity levels correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SensitivityRadarBadge(
                  label: 'Moisture',
                  level: 'High (Critical)',
                  icon: Icons.water_drop,
                ),
                SensitivityRadarBadge(
                  label: 'Light',
                  level: 'Moderate',
                  icon: Icons.wb_sunny,
                ),
                SensitivityRadarBadge(
                  label: 'Aroma',
                  level: 'Low',
                  icon: Icons.air,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Critical'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
    });
  });

  group('ThermalStabilityGauge Widget Tests', () {
    testWidgets('displays temperature spectrum and shelf life metrics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalStabilityGauge(
              thermalData: sampleProfile.thermalAndStorage,
              currentStorageMode: StorageMode.roomTemperature,
            ),
          ),
        ),
      );

      expect(find.textContaining('Thermal & Storage Boundaries'), findsOneWidget);
      expect(find.text('Highly Perishable'), findsOneWidget);
      expect(find.text('10°C to 13°C'), findsOneWidget);
      expect(find.text('< 10°C'), findsOneWidget);
      expect(find.text('-0.5°C'), findsOneWidget);
      expect(find.text('7 Days'), findsOneWidget);
      expect(find.text('14 Days'), findsOneWidget);
      expect(find.text('28 Days'), findsOneWidget);

      // No chilling conflict in room temperature mode
      expect(find.textContaining('PHYSIOLOGICAL CHILLING WARNING'), findsNothing);
    });

    testWidgets('triggers Chilling Injury alert when refrigerated storage mode conflicts with chilling limit', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalStabilityGauge(
              thermalData: sampleProfile.thermalAndStorage,
              currentStorageMode: StorageMode.refrigerated,
            ),
          ),
        ),
      );

      expect(find.textContaining('PHYSIOLOGICAL CHILLING WARNING'), findsOneWidget);
    });

    testWidgets('triggers Chilling Injury alert when frozen storage mode is selected for chilling sensitive commodity', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThermalStabilityGauge(
              thermalData: sampleProfile.thermalAndStorage,
              currentStorageMode: StorageMode.frozen,
            ),
          ),
        ),
      );

      expect(find.textContaining('PHYSIOLOGICAL CHILLING WARNING'), findsOneWidget);
    });
  });

  group('AtmosphereDynamicsCard Widget Tests', () {
    testWidgets('renders respiration, ethylene, and EMAP gas thresholds', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AtmosphereDynamicsCard(
              kinetics: sampleProfile.physiologicalKinetics,
              atmosphere: sampleProfile.atmosphereSensitivities,
              ethyleneActionRequired: true,
            ),
          ),
        ),
      );

      expect(find.textContaining('Gas Atmosphere & EMAP Kinetics'), findsOneWidget);
      expect(find.text('28.0 mg CO₂/kg/h'), findsOneWidget);
      expect(find.text('5.5 µL/kg/h'), findsOneWidget);
      expect(find.text('3-5% O₂ / 3-5% CO₂'), findsOneWidget);
      expect(find.text('Max 5% CO₂'), findsOneWidget);
      expect(find.text('Ethylene Scavenger'), findsOneWidget);
    });
  });

  group('FoodScientificDossierCard Master Widget Tests', () {
    testWidgets('renders dossier header, provenance, and confidence score', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodScientificDossierCard(
                profile: sampleProfile,
                currentStorageMode: StorageMode.roomTemperature,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Auto-Retrieved Scientific Dossier'), findsOneWidget);
      expect(find.text('ICMR-NIN IFCT 2017 & UC Davis Postharvest Facts'), findsOneWidget);
      expect(find.text('96% Confidence'), findsOneWidget);
      expect(find.textContaining('Degradation Vulnerability Matrix'), findsOneWidget);
      expect(find.textContaining('Botrytis cinerea'), findsOneWidget);
    });

    testWidgets('collapses and expands on header tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodScientificDossierCard(
                profile: sampleProfile,
                currentStorageMode: StorageMode.roomTemperature,
                initialExpanded: true,
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Degradation Vulnerability Matrix'), findsOneWidget);

      // Tap header to collapse
      await tester.tap(find.text('Auto-Retrieved Scientific Dossier'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Degradation Vulnerability Matrix'), findsNothing);

      // Tap header to expand again
      await tester.tap(find.text('Auto-Retrieved Scientific Dossier'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Degradation Vulnerability Matrix'), findsOneWidget);
    });
  });
}
