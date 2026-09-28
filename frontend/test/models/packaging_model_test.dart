import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';

void main() {
  group('PackagingModel Tests (Task 3.3)', () {
    test('Round-trip JSON serialization for full hybrid result', () {
      final jsonMap = {
        'recommendation_id': 'rec_12345678',
        'primary_recommendation': {
          'material_name': 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)',
          'material_type': 'Biodegradable Bio-Polymer',
          'polymer_family': 'BREATHABLE_BIO_EMAP',
          'structure': 'Co-extruded PLA/PBAT',
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
          'active_additives': [
            'Potassium Permanganate (KMnO₄) Ethylene Scavenger Sachet',
            'Antifog Surface Surfactant Coating',
          ],
        },
        'alternatives': [
          {
            'type': 'ECO_FRIENDLY',
            'material_name': 'Cellulose-Based Breathable Bio-Film (NatureFlex)',
            'sustainability_score': 98.0,
            'estimated_unit_cost_inr': 4.50,
            'trade_off_summary': '100% Home compostable with excellent transparency.',
          },
          {
            'type': 'ECONOMY',
            'material_name': 'Perforated Low-Density Polyethylene (LDPE)',
            'sustainability_score': 62.0,
            'estimated_unit_cost_inr': 1.95,
            'trade_off_summary': 'Lowest unit cost; standard municipal recyclability.',
          },
          {
            'type': 'HIGH_BARRIER',
            'material_name': 'Polypropylene Macro-Vented Anti-Fog Clamshell',
            'sustainability_score': 70.0,
            'estimated_unit_cost_inr': 5.20,
            'trade_off_summary': 'Maximum mechanical puncture protection.',
          },
        ],
        'box_geometry': {
          'length_cm': 28.5,
          'width_cm': 17.6,
          'height_cm': 14.1,
          'total_volume_cm3': 7072.0,
          'space_utilization_pct': 78.5,
          'cushioning_material': 'Recycled Kraft Thermal Insulated Pouch + Cold Gel Pack',
        },
        'scientific_rationale': {
          'summary': 'Fresh Tomato requires Equilibrium Modified Atmosphere (EMAP).',
          'key_drivers': [
            'High respiration requires gas-permeable micro-perforations.',
            'High moisture requires anti-fog surfactant.',
          ],
        },
      };

      final result = PackagingRecommendationResult.fromJson(jsonMap);

      expect(result.recommendationId, 'rec_12345678');
      expect(result.primaryRecommendation.materialName, contains('Micro-Perforated'));
      expect(result.primaryRecommendation.sustainabilityScore, 94.0);
      expect(result.primaryRecommendation.activeAdditives.length, 2);
      expect(result.alternatives.length, 3);
      expect(result.alternatives.first.type, AlternativeType.ecoFriendly);
      expect(result.boxGeometry.lengthCm, 28.5);
      expect(result.boxGeometry.spaceUtilizationPct, 78.5);
      expect(result.scientificRationale.keyDrivers.length, 2);

      // Verify backward-compatibility bridge getters
      expect(result.recommendedBoxType, contains('Micro-Perforated'));
      expect(result.estimatedCost, 3.85);
      expect(result.sustainabilityScore, 94.0);
    });

    test('PackagingInput toJson serialization includes custom overrides', () {
      final input = PackagingInput(
        itemName: 'Fresh Tomato',
        weight: 5.0,
        isFragile: true,
        ecoFriendly: true,
        category: 'Vegetables',
        moisture: 94.5,
        fat: 0.2,
        ph: 4.4,
        respirationClass: 'High',
        respirationRate20c: 45.0,
        ethyleneSensitivity: 'High',
        storageTempC: 12.0,
      );

      final map = input.toJson();
      expect(map['item_name'], 'Fresh Tomato');
      expect(map['weight'], 5.0);
      expect(map['is_fragile'], true);
      expect(map['eco_friendly'], true);
      expect(map['moisture'], 94.5);
      expect(map['respiration_rate_20c'], 45.0);
      expect(map['storage_temp_c'], 12.0);
    });
  });
}
