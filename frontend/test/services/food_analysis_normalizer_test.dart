import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_scientific_profile.dart';
import 'package:ai_packaging_recommender/services/food_analysis_normalizer.dart';

void main() {
  group('FoodAnalysisNormalizer Tests', () {
    late FoodScientificProfile tomatoProfile;
    late FoodScientificProfile potatoChipsProfile;

    setUp(() {
      tomatoProfile = const FoodScientificProfile(
        foodId: 1,
        commodityName: 'Fresh Tomato',
        scientificName: 'Solanum lycopersicum',
        category: 'Vegetables',
        physicochemical: PhysicochemicalTraits(
          moisturePct: 94.5,
          fatPct: 0.2,
          ph: 4.4,
          waterActivity: 0.99,
          moistureSensitivity: 'High',
        ),
        physiologicalKinetics: PhysiologicalKinetics(
          respirationClass: 'Moderate to High',
          respirationRate5c: 10.0,
          respirationRate20c: 45.0,
          ethyleneProductionClass: 'Moderate',
          ethyleneProdRate: 5.0,
          ethyleneSensitivity: 'High',
        ),
        atmosphereSensitivities: AtmosphereSensitivities(
          oxygenSensitivity: 'Moderate',
          co2Sensitivity: 'Moderate',
          maxTolerableCo2Pct: 5.0,
          targetEmapO2Pct: '3-5%',
          targetEmapCo2Pct: '3-5%',
        ),
        thermalAndStorage: ThermalAndStorage(
          perishability: 'Highly perishable',
          optimumTempMinC: 12.0,
          optimumTempMaxC: 15.0,
          chillingInjuryThresholdC: 10.0,
          freezingPointC: -0.5,
          ambientShelfLifeDays: 7,
          refrigeratedShelfLifeDays: 21,
          controlledAtmosphereShelfLifeDays: 42,
        ),
        spoilageAndVulnerabilities: SpoilageAndVulnerabilities(
          lightSensitivity: 'Low',
          aromaSensitivity: 'Low',
          microbialSpoilageVector: 'Botrytis cinerea (Grey Mold), Alternaria rot',
          mechanicalSensitivity: 'High',
        ),
        packagingPrescriptions: PackagingPrescriptions(
          recommendedBarrierType: 'Perforated LDPE / PP Antifog Film',
          requiredOtrRange: '1500 - 3000 cc/m²/day',
          requiredWvtrRange: '< 15 g/m²/day',
          ethyleneActionRequired: true,
          thermalWarning: 'Do NOT store below 10°C (Chilling Injury Risk)',
          cushioningDirective: 'Rigid thermoformed clamshell or pulp tray required',
        ),
      );

      potatoChipsProfile = const FoodScientificProfile(
        foodId: 2,
        commodityName: 'Potato Chips',
        scientificName: 'Solanum tuberosum snack',
        category: 'Other Perishables',
        physicochemical: PhysicochemicalTraits(
          moisturePct: 1.8,
          fatPct: 35.0,
          ph: 6.2,
          waterActivity: 0.20,
          moistureSensitivity: 'Critical',
        ),
        physiologicalKinetics: PhysiologicalKinetics(
          respirationClass: 'None',
          respirationRate5c: 0.0,
          respirationRate20c: 0.0,
          ethyleneSensitivity: 'Low',
        ),
        atmosphereSensitivities: AtmosphereSensitivities(
          oxygenSensitivity: 'High',
          co2Sensitivity: 'Tolerant',
        ),
        thermalAndStorage: ThermalAndStorage(
          perishability: 'Low perishability',
          optimumTempMinC: 15.0,
          optimumTempMaxC: 25.0,
          ambientShelfLifeDays: 180,
        ),
        spoilageAndVulnerabilities: SpoilageAndVulnerabilities(
          lightSensitivity: 'High',
          aromaSensitivity: 'Moderate',
          microbialSpoilageVector: 'Lipid rancidity / photo-oxidation',
          mechanicalSensitivity: 'Critical',
        ),
        packagingPrescriptions: PackagingPrescriptions(
          recommendedBarrierType: 'Metallized BOPP / Nitrogen Flush Pouch',
          requiredOtrRange: '< 1.0 cc/m²/day',
          requiredWvtrRange: '< 0.5 g/m²/day',
        ),
      );
    });

    test('normalizeMoisture correctly clamps values', () {
      expect(FoodAnalysisNormalizer.normalizeMoisture(94.5), closeTo(0.945, 0.001));
      expect(FoodAnalysisNormalizer.normalizeMoisture(1.8), closeTo(0.05, 0.01));
      expect(FoodAnalysisNormalizer.normalizeMoisture(120.0), equals(1.0));
      expect(FoodAnalysisNormalizer.normalizeMoisture(double.nan), equals(0.5));
    });

    test('normalizeRespiration handles rates and fallbacks', () {
      expect(FoodAnalysisNormalizer.normalizeRespiration(45.0), closeTo(0.45, 0.01));
      expect(FoodAnalysisNormalizer.normalizeRespiration(120.0), equals(1.0));
      expect(FoodAnalysisNormalizer.normalizeRespiration(null, respirationClass: 'High'), equals(0.70));
      expect(FoodAnalysisNormalizer.normalizeRespiration(0.0, respirationClass: 'None'), equals(0.30));
    });

    test('normalizeSensitivity maps qualitative enums accurately', () {
      expect(FoodAnalysisNormalizer.normalizeSensitivity('Critical'), equals(1.0));
      expect(FoodAnalysisNormalizer.normalizeSensitivity('High'), equals(0.80));
      expect(FoodAnalysisNormalizer.normalizeSensitivity('Moderate'), equals(0.50));
      expect(FoodAnalysisNormalizer.normalizeSensitivity('Low'), equals(0.20));
      expect(FoodAnalysisNormalizer.normalizeSensitivity('None'), equals(0.10));
    });

    test('computeRadarAxes returns exactly 6 valid axes', () {
      final axes = FoodAnalysisNormalizer.computeRadarAxes(tomatoProfile);
      expect(axes.length, equals(6));
      
      final keys = axes.map((a) => a.key).toList();
      expect(keys, containsAll(['moisture', 'respiration', 'thermal', 'ethylene', 'mechanical', 'gas']));
      
      for (final axis in axes) {
        expect(axis.score, greaterThanOrEqualTo(0.05));
        expect(axis.score, lessThanOrEqualTo(1.0));
        expect(axis.rawValue.isNotEmpty, isTrue);
      }
    });

    test('computeSensitivityBars returns 8 structured sensitivity items', () {
      final bars = FoodAnalysisNormalizer.computeSensitivityBars(tomatoProfile);
      expect(bars.length, equals(8));
      
      final moistureBar = bars.firstWhere((b) => b.key == 'moisture');
      expect(moistureBar.level, equals(SensitivityLevel.critical));
      expect(moistureBar.formattedValue, equals('94.5%'));
      expect(moistureBar.consequence, contains('WVTR'));

      final tempBar = bars.firstWhere((b) => b.key == 'temperature');
      expect(tempBar.formattedValue, contains('Chilling'));
    });

    test('evaluateCriticalVulnerabilities detects chilling injury and high respiration', () {
      final tomatoAlerts = FoodAnalysisNormalizer.evaluateCriticalVulnerabilities(tomatoProfile);
      expect(tomatoAlerts.isNotEmpty, isTrue);
      
      final hasChilling = tomatoAlerts.any((a) => a.tag.contains('CHILLING'));
      expect(hasChilling, isTrue);

      final hasResp = tomatoAlerts.any((a) => a.tag.contains('METABOLIC') || a.title.contains('Respiration'));
      expect(hasResp, isTrue);

      final hasEthylene = tomatoAlerts.any((a) => a.tag.contains('ETHYLENE'));
      expect(hasEthylene, isTrue);
    });

    test('evaluateCriticalVulnerabilities detects hygroscopic caking on dry snacks', () {
      final chipAlerts = FoodAnalysisNormalizer.evaluateCriticalVulnerabilities(potatoChipsProfile);
      final hasCaking = chipAlerts.any((a) => a.tag.contains('CAKING'));
      expect(hasCaking, isTrue);

      final hasOxygen = chipAlerts.any((a) => a.tag.contains('OXYGEN'));
      expect(hasOxygen, isTrue);
    });

    test('computeExtensionMultiplier calculates accurate factor', () {
      expect(FoodAnalysisNormalizer.computeExtensionMultiplier(7, 42), equals(6.0));
      expect(FoodAnalysisNormalizer.computeExtensionMultiplier(10, 25), equals(2.5));
      expect(FoodAnalysisNormalizer.computeExtensionMultiplier(0, 42), equals(1.0));
      expect(FoodAnalysisNormalizer.computeExtensionMultiplier(7, null), equals(1.0));
    });

    test('estimateArrheniusShelfLife computes temperature decay curve', () {
      final at25c = FoodAnalysisNormalizer.estimateArrheniusShelfLife(7, 25.0, 25.0);
      expect(at25c, equals(7.0));

      final at15c = FoodAnalysisNormalizer.estimateArrheniusShelfLife(7, 25.0, 15.0);
      expect(at15c, greaterThan(7.0));

      final at35c = FoodAnalysisNormalizer.estimateArrheniusShelfLife(7, 25.0, 35.0);
      expect(at35c, lessThan(7.0));
    });
  });
}
