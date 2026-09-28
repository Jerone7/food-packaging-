import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_comparison_model.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';

void main() {
  group('ComparisonSlotId Enum Tests', () {
    test('resolves fromId correctly for all 3 slots', () {
      expect(ComparisonSlotId.fromId('material_a'), equals(ComparisonSlotId.materialA));
      expect(ComparisonSlotId.fromId('MATERIAL_B'), equals(ComparisonSlotId.materialB));
      expect(ComparisonSlotId.fromId('material_c'), equals(ComparisonSlotId.materialC));
      expect(ComparisonSlotId.fromId('unknown'), equals(ComparisonSlotId.materialA));
    });

    test('resolves fromIndex correctly', () {
      expect(ComparisonSlotId.fromIndex(0), equals(ComparisonSlotId.materialA));
      expect(ComparisonSlotId.fromIndex(1), equals(ComparisonSlotId.materialB));
      expect(ComparisonSlotId.fromIndex(2), equals(ComparisonSlotId.materialC));
    });
  });

  group('MaterialComparisonSlot JSON Serialization Tests', () {
    test('parses and serializes full material slot model', () {
      final json = {
        'slot_id': 'material_a',
        'material_id': 'mat_bio_emap_01',
        'name': 'Micro-Perforated Bio-PLA Film',
        'category': 'Biodegradable Bio-Polymer',
        'polymer_family': 'BIO_PLA',
        'structure': 'Co-extruded Film',
        'color_token': '#0D9488',
        'is_primary_recommendation': true,
        'moisture_barrier': 'High',
        'oxygen_barrier': 'Medium',
        'gas_exchange': 'High',
        'strength': 'High',
        'recyclability': 'Biodegradable',
        'cost_category': 'Medium',
        'wvtr_value': 45.0,
        'otr_value': 3500.0,
        'tensile_strength_mpa': 32.0,
        'estimated_cost_inr': 3.85,
        'sustainability_score': 94.0,
        'suitability_score': 0.96,
        'suitability_category': 'Optimal Match',
        'star_rating': 5,
      };

      final slot = MaterialComparisonSlot.fromJson(json);

      expect(slot.slotId, equals('material_a'));
      expect(slot.name, equals('Micro-Perforated Bio-PLA Film'));
      expect(slot.isPrimaryRecommendation, isTrue);
      expect(slot.moistureBarrier, equals('High'));
      expect(slot.oxygenBarrier, equals('Medium'));
      expect(slot.gasExchange, equals('High'));
      expect(slot.strength, equals('High'));
      expect(slot.recyclability, equals('Biodegradable'));
      expect(slot.costCategory, equals('Medium'));
      expect(slot.starRating, equals(5));

      final serialized = slot.toJson();
      expect(serialized['slot_id'], equals('material_a'));
      expect(serialized['name'], equals('Micro-Perforated Bio-PLA Film'));
      expect(serialized['moisture_barrier'], equals('High'));
      expect(serialized['star_rating'], equals(5));
    });

    test('handles missing or malformed JSON fields safely', () {
      final slot = MaterialComparisonSlot.fromJson({});

      expect(slot.slotId, equals('material_a'));
      expect(slot.name, equals('Unknown Material'));
      expect(slot.moistureBarrier, equals('Medium'));
      expect(slot.costCategory, equals('Medium'));
      expect(slot.wvtrValue, equals(10.0));
      expect(slot.otrValue, equals(500.0));
    });
  });

  group('ComparisonParameterRowModel & PackagingComparisonResultModel Tests', () {
    test('parses and serializes full matrix response', () {
      final json = {
        'comparison_id': 'cmp_test_100',
        'food_context_name': 'Fresh Strawberries',
        'slots': [
          {
            'slot_id': 'material_a',
            'material_id': 'mat_bio_emap_01',
            'name': 'Bio-PLA Film',
            'category': 'Biodegradable',
            'polymer_family': 'BIO_PLA',
            'structure': 'Blown Film',
            'color_token': '#0D9488',
            'is_primary_recommendation': true,
            'moisture_barrier': 'High',
            'oxygen_barrier': 'Medium',
            'gas_exchange': 'High',
            'strength': 'High',
            'recyclability': 'Yes',
            'cost_category': 'Medium',
            'wvtr_value': 45.0,
            'otr_value': 3500.0,
            'tensile_strength_mpa': 32.0,
            'estimated_cost_inr': 3.85,
            'sustainability_score': 94.0,
          },
          {
            'slot_id': 'material_b',
            'material_id': 'mat_conv_hdpe_01',
            'name': 'HDPE Film',
            'category': 'Conventional',
            'polymer_family': 'HDPE',
            'structure': 'Film',
            'color_token': '#0284C7',
            'is_primary_recommendation': false,
            'moisture_barrier': 'Medium',
            'oxygen_barrier': 'High',
            'gas_exchange': 'Low',
            'strength': 'Medium',
            'recyclability': 'Yes',
            'cost_category': 'High',
            'wvtr_value': 3.7,
            'otr_value': 1600.0,
            'tensile_strength_mpa': 27.9,
            'estimated_cost_inr': 2.20,
            'sustainability_score': 58.0,
          },
        ],
        'parameter_rows': [
          {
            'parameter_key': 'moisture_barrier',
            'parameter_label': 'Moisture Barrier',
            'parameter_group': 'Barrier Performance',
            'unit': 'g/m²/day',
            'values': {'material_a': 'High', 'material_b': 'Medium'},
            'raw_numeric_values': {'material_a': 45.0, 'material_b': 3.7},
            'best_slot_id': 'material_b',
          },
          {
            'parameter_key': 'oxygen_barrier',
            'parameter_label': 'Oxygen Barrier',
            'parameter_group': 'Barrier Performance',
            'unit': 'cc/m²/day',
            'values': {'material_a': 'Medium', 'material_b': 'High'},
            'raw_numeric_values': {'material_a': 3500.0, 'material_b': 1600.0},
            'best_slot_id': 'material_b',
          },
        ],
        'best_in_class_summary': {
          'Moisture Barrier': 'HDPE Film',
          'Oxygen Barrier': 'HDPE Film',
        },
        'ai_trade_off_synthesis': 'Material A offers superior gas exchange while Material B lowers unit cost.',
        'key_recommendation_rule': 'Choose Material A for shelf life, Material B for cost.',
      };

      final result = PackagingComparisonResultModel.fromJson(json);

      expect(result.comparisonId, equals('cmp_test_100'));
      expect(result.foodContextName, equals('Fresh Strawberries'));
      expect(result.slots.length, equals(2));
      expect(result.parameterRows.length, equals(2));
      expect(result.bestInClassSummary['Moisture Barrier'], equals('HDPE Film'));
      expect(result.aiTradeOffSynthesis, contains('Material A'));

      final serialized = result.toJson();
      expect(serialized['comparison_id'], equals('cmp_test_100'));
      expect((serialized['slots'] as List).length, equals(2));
    });
  });

  group('ApiService Offline Comparison Generator Tests', () {
    test('generateOfflinePackagingComparison produces 3 valid slots and 6 parameter rows', () {
      final result = ApiService.generateOfflinePackagingComparison(
        ['mat_bio_emap_01', 'mat_conv_hdpe_01', 'mat_lam_pet_alu_01'],
        foodId: 1,
        foodName: 'Fresh Strawberries',
      );

      expect(result.slots.length, equals(3));
      expect(result.slots[0].slotId, equals('material_a'));
      expect(result.slots[1].slotId, equals('material_b'));
      expect(result.slots[2].slotId, equals('material_c'));

      // 6 core parameters
      expect(result.parameterRows.length, equals(6));
      final keys = result.parameterRows.map((r) => r.parameterKey).toList();
      expect(keys, contains('moisture_barrier'));
      expect(keys, contains('oxygen_barrier'));
      expect(keys, contains('gas_exchange'));
      expect(keys, contains('strength'));
      expect(keys, contains('recyclability'));
      expect(keys, contains('cost_category'));

      // Check best in class highlights
      expect(result.bestInClassSummary, isNotEmpty);
      expect(result.aiTradeOffSynthesis, contains('Fresh Strawberries'));
      expect(result.keyRecommendationRule, isNotEmpty);
    });

    test('generateOfflinePackagingComparison gracefully generates comparison for minimal 2 materials', () {
      final result = ApiService.generateOfflinePackagingComparison(
        ['mat_conv_ldpe_01', 'mat_conv_pet_01'],
      );

      expect(result.slots.length, equals(2));
      expect(result.parameterRows.length, equals(6));
      expect(result.foodContextName, isNull);
    });
  });
}
