import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';

void main() {
  group('PrimaryRecommendation Explainable Model Tests', () {
    test('JSON deserialization parses all 9 explainable recommendation fields', () {
      final json = {
        'material_name': 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)',
        'material_type': 'Biodegradable Bio-Polymer',
        'polymer_family': 'BREATHABLE_BIO_EMAP',
        'structure': 'Co-extruded Micro-Perforated PLA/PBAT Blown Film',
        'barrier_profile': {
          'otr': '3500.0 cc/m²/day',
          'wvtr': '45.00 g/m²/day',
          'thickness_microns': 30.0,
          'tensile_strength_mpa': 32.0,
          'puncture_resistance_n': 18.0,
        },
        'sustainability_score': 94.0,
        'estimated_unit_cost_inr': 3.85,
        'suitability_score': 0.96,
        'active_additives': ['Ethylene Scavenger Sachet'],
        'packaging_title': 'Ventilated Food-Grade Packaging',
        'packaging_format': 'Micro-Perforated Hinged Clamshell',
        'recommendation_explanation':
            'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
        'advantages': [
          'Equilibrium modified atmosphere (EMAP) prevents anaerobic souring',
          'Anti-fog coating suppresses condensation water droplets',
        ],
        'limitations': [
          'Not suitable for vacuum packing or retort processing',
          'Storage duration limited to 14–21 days',
        ],
        'suitable_storage_condition': 'Cold Storage: 10°C - 12°C (90-95% RH)',
        'expected_application': 'High-respiration fresh produce, strawberries, cut fruits',
        'important_properties': {
          'OTR (Gas Permeability)': '3500.0 cc/m²/day',
          'WVTR (Moisture Barrier)': '45.00 g/m²/day',
          'Film Thickness': '30.0 µm',
        },
      };

      final rec = PrimaryRecommendation.fromJson(json);

      expect(rec.materialName, 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)');
      expect(rec.packagingTitle, 'Ventilated Food-Grade Packaging');
      expect(rec.packagingFormat, 'Micro-Perforated Hinged Clamshell');
      expect(rec.suitabilityScore, 0.96);
      expect(
        rec.recommendationExplanation,
        'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
      );
      expect(rec.advantages.length, 2);
      expect(rec.advantages.first, contains('EMAP'));
      expect(rec.limitations.length, 2);
      expect(rec.limitations.first, contains('vacuum'));
      expect(rec.suitableStorageCondition, 'Cold Storage: 10°C - 12°C (90-95% RH)');
      expect(rec.expectedApplication, contains('strawberries'));
      expect(rec.importantProperties['OTR (Gas Permeability)'], '3500.0 cc/m²/day');
    });

    test('JSON deserialization provides graceful defaults when explainable fields are omitted', () {
      final legacyJson = {
        'material_name': 'Standard LDPE Pouch',
        'material_type': 'Polymer',
        'polymer_family': 'LDPE',
        'structure': 'Monolayer LDPE',
        'barrier_profile': {
          'otr': '2500.0',
          'wvtr': '15.0',
          'thickness_microns': 50.0,
          'tensile_strength_mpa': 20.0,
          'puncture_resistance_n': 15.0,
        },
        'sustainability_score': 60.0,
        'estimated_unit_cost_inr': 2.0,
        'suitability_score': 0.85,
        'active_additives': [],
      };

      final rec = PrimaryRecommendation.fromJson(legacyJson);

      expect(rec.materialName, 'Standard LDPE Pouch');
      expect(rec.packagingTitle, 'Ventilated Food-Grade Packaging');
      expect(rec.packagingFormat, 'Micro-Perforated Hinged Clamshell');
      expect(rec.recommendationExplanation, isNotEmpty);
      expect(rec.advantages, isNotEmpty);
      expect(rec.limitations, isNotEmpty);
      expect(rec.suitableStorageCondition, isNotEmpty);
      expect(rec.expectedApplication, isNotEmpty);
      expect(rec.importantProperties, isNotEmpty);
    });

    test('toJson outputs all explainable recommendation fields', () {
      const rec = PrimaryRecommendation(
        materialName: 'Test Material',
        materialType: 'Bio-Polymer',
        polymerFamily: 'PLA',
        structure: 'Monolayer',
        barrierProfile: BarrierProfile(
          otr: '100',
          wvtr: '10',
          thicknessMicrons: 25,
          tensileStrengthMpa: 30,
          punctureResistanceN: 20,
        ),
        sustainabilityScore: 90,
        estimatedUnitCostInr: 3.5,
        suitabilityScore: 0.95,
        activeAdditives: ['Additive 1'],
        packagingTitle: 'Ventilated Food-Grade Packaging',
        packagingFormat: 'Micro-Perforated Hinged Clamshell',
        recommendationExplanation: 'Explainable reason.',
        advantages: ['Adv 1'],
        limitations: ['Lim 1'],
        suitableStorageCondition: 'Store cold',
        expectedApplication: 'Fruit',
        importantProperties: {'OTR': '100'},
      );

      final json = rec.toJson();
      expect(json['packaging_title'], 'Ventilated Food-Grade Packaging');
      expect(json['packaging_format'], 'Micro-Perforated Hinged Clamshell');
      expect(json['recommendation_explanation'], 'Explainable reason.');
      expect(json['advantages'], ['Adv 1']);
      expect(json['limitations'], ['Lim 1']);
      expect(json['suitable_storage_condition'], 'Store cold');
      expect(json['expected_application'], 'Fruit');
      expect(json['important_properties'], {'OTR': '100'});
    });
  });

  group('Offline Recommendation Synthesis Explainability Tests', () {
    test('High-respiration produce generates Ventilated Food-Grade Packaging with required narrative', () {
      final input = PackagingInput(
        itemName: 'Strawberries',
        category: 'Fruits',
        length: 20,
        width: 15,
        height: 8,
        weight: 0.5,
        respirationRate20c: 65.0,
        moisture: 91.0,
        isFragile: true,
        ecoFriendly: true,
      );

      final result = ApiService.generateOfflineRecommendation(input);
      final primary = result.primaryRecommendation;

      expect(primary.packagingTitle, 'Ventilated Food-Grade Packaging');
      expect(primary.packagingFormat, 'Micro-Perforated Hinged Clamshell');
      expect(
        primary.recommendationExplanation,
        'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
      );
      expect(primary.advantages, isNotEmpty);
      expect(primary.limitations, isNotEmpty);
      expect(primary.suitableStorageCondition, contains('10°C - 12°C'));
      expect(primary.expectedApplication, contains('High-respiration fresh produce'));
      expect(primary.importantProperties.containsKey('OTR (Oxygen Barrier)'), isTrue);
    });

    test('High-fat snack generates Nitrogen-Flushed High-Barrier Foil Pouch', () {
      final input = PackagingInput(
        itemName: 'Potato Chips',
        category: 'Snacks',
        length: 22,
        width: 14,
        height: 6,
        weight: 0.2,
        fat: 35.0,
        moisture: 2.0,
        isFragile: true,
        ecoFriendly: false,
      );

      final result = ApiService.generateOfflineRecommendation(input);
      final primary = result.primaryRecommendation;

      expect(primary.packagingTitle, 'Nitrogen-Flushed High-Barrier Foil Pouch');
      expect(primary.packagingFormat, 'Multi-Layer Metallized Stand-up Pouch');
      expect(primary.recommendationExplanation, contains('lipid rancidity'));
      expect(primary.advantages.first, contains('oxygen transmission'));
      expect(primary.limitations.first, contains('compostable'));
    });

    test('Dry grain generates Bio-Composite Moisture-Barrier Paper Bag', () {
      final input = PackagingInput(
        itemName: 'Basmati Rice',
        category: 'Grains',
        length: 30,
        width: 20,
        height: 10,
        weight: 5.0,
        moisture: 12.0,
        fat: 0.7,
        isFragile: false,
        ecoFriendly: true,
      );

      final result = ApiService.generateOfflineRecommendation(input);
      final primary = result.primaryRecommendation;

      expect(primary.packagingTitle, 'Bio-Composite Moisture-Barrier Paper Bag');
      expect(primary.packagingFormat, 'Multi-Wall Lined Kraft Paper Bag');
      expect(primary.recommendationExplanation, contains('moderate moisture protection'));
      expect(primary.advantages.first, contains('tensile and puncture strength'));
      expect(primary.suitableStorageCondition, contains('Ambient Dry Storage'));
    });
  });
}
