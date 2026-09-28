import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';

void main() {
  group('SuitabilityCategory Enum & Styling', () {
    test('parses suitability categories accurately', () {
      expect(SuitabilityCategory.fromString('Optimal Match'), SuitabilityCategory.optimalMatch);
      expect(SuitabilityCategory.fromString('High Compatibility'), SuitabilityCategory.highCompatibility);
      expect(SuitabilityCategory.fromString('Moderate Compatibility'), SuitabilityCategory.moderateCompatibility);
      expect(SuitabilityCategory.fromString('Conditional Alternative'), SuitabilityCategory.conditionalAlternative);
      expect(SuitabilityCategory.fromString(null), SuitabilityCategory.highCompatibility);
    });

    test('provides formatted display and badge labels', () {
      expect(SuitabilityCategory.optimalMatch.displayName, 'Optimal Match');
      expect(SuitabilityCategory.optimalMatch.badgeLabel, 'Optimal Match (Tier 1)');
      expect(SuitabilityCategory.highCompatibility.badgeLabel, 'High Compatibility (Tier 2)');
      expect(SuitabilityCategory.moderateCompatibility.badgeLabel, 'Moderate Compatibility (Tier 3)');
    });
  });

  group('MaterialCharacteristics Serialization', () {
    test('creates default characteristics with engineering units', () {
      const chars = MaterialCharacteristics();
      expect(chars.otr, '< 1200 cc/m²/day');
      expect(chars.wvtr, '25.0 g/m²/day');
      expect(chars.thicknessMicrons, 25.0);
      expect(chars.tensileStrengthMpa, 30.0);
      expect(chars.thermalRange, '-10°C to 70°C');
      expect(chars.costTier, 'Moderate (₹₹)');
    });

    test('serializes and deserializes correctly', () {
      final json = {
        'otr': '2,800 cc/m²/day',
        'wvtr': '50.0 g/m²/day',
        'thickness_microns': 30.0,
        'tensile_strength_mpa': 45.0,
        'thermal_range': '-5°C to 60°C',
        'sustainability_rating': '100% Home Compostable',
        'estimated_cost_inr': 4.50,
        'cost_tier': 'Moderate (₹₹)',
      };

      final chars = MaterialCharacteristics.fromJson(json);
      expect(chars.otr, '2,800 cc/m²/day');
      expect(chars.wvtr, '50.0 g/m²/day');
      expect(chars.thicknessMicrons, 30.0);
      expect(chars.estimatedCostInr, 4.50);

      final outJson = chars.toJson();
      expect(outJson['otr'], '2,800 cc/m²/day');
      expect(outJson['estimated_cost_inr'], 4.50);
    });
  });

  group('PackagingAlternative Model', () {
    test('parses full candidate payload with star rating and characteristics', () {
      final json = {
        'candidate_id': 'alt_natureflex_01',
        'type': 'ECO_FRIENDLY',
        'material_name': 'Cellulose Breathable Bio-Film (NatureFlex)',
        'packaging_title': 'Heat-Sealed Bio-Pouch',
        'star_rating': 4,
        'star_display': '★★★★☆',
        'suitability_category': 'High Compatibility',
        'model_derived_probability': 0.86,
        'compatibility_confidence': 'High Confidence (0.86)',
        'characteristics': {
          'otr': '2,800 cc/m²/day',
          'wvtr': '50.0 g/m²/day',
          'thickness_microns': 30.0,
          'tensile_strength_mpa': 45.0,
          'thermal_range': '-5°C to 60°C',
          'sustainability_rating': '100% Home Compostable',
          'estimated_cost_inr': 4.50,
          'cost_tier': 'Moderate (₹₹)',
        },
        'trade_off_summary': '100% Home compostable with crystal clarity; +17% unit cost.',
        'advantages': [
          '100% bio-derived and marine degradable',
          'Excellent gas permselectivity',
        ],
        'limitations': [
          'Slightly higher unit cost than fossil LDPE',
          'Moderate moisture barrier',
        ],
        'cost_delta_pct': 16.88,
        'eco_delta_pct': 4.26,
        'shelf_life_delta': 'Equal (21 days)',
        'sustainability_score': 98.0,
        'estimated_unit_cost_inr': 4.50,
      };

      final alt = PackagingAlternative.fromJson(json);
      expect(alt.candidateId, 'alt_natureflex_01');
      expect(alt.type, AlternativeType.ecoFriendly);
      expect(alt.starRating, 4);
      expect(alt.starDisplay, '★★★★☆');
      expect(alt.suitabilityCategory, SuitabilityCategory.highCompatibility);
      expect(alt.modelDerivedProbability, 0.86);
      expect(alt.costDeltaPct, 16.88);
      expect(alt.advantages.length, 2);
      expect(alt.characteristics.otr, '2,800 cc/m²/day');

      final serialized = alt.toJson();
      expect(serialized['candidate_id'], 'alt_natureflex_01');
      expect(serialized['star_display'], '★★★★☆');
    });

    test('parses legacy alternative payload gracefully with null-safe fallbacks', () {
      final legacyJson = {
        'type': 'ECONOMY',
        'material_name': 'Perforated LDPE Bag',
        'sustainability_score': 62.0,
        'estimated_unit_cost_inr': 1.95,
        'trade_off_summary': '49% Cost savings; standard mechanical recycling.',
      };

      final alt = PackagingAlternative.fromJson(legacyJson);
      expect(alt.type, AlternativeType.economy);
      expect(alt.materialName, 'Perforated LDPE Bag');
      expect(alt.starRating, 4);
      expect(alt.sustainabilityScore, 62.0);
      expect(alt.estimatedUnitCostInr, 1.95);
      expect(alt.characteristics.estimatedCostInr, 1.95);
    });
  });

  group('PackagingRecommendationResult with Alternatives', () {
    test('round-trips full result containing alternatives and comparison summary', () {
      final json = {
        'recommendation_id': 'rec_test_strawberries',
        'recommended_box_type': 'Micro-Perforated PLA Bio-Clamshell',
        'recommended_dimensions': '20.0 x 14.0 x 8.0 cm',
        'box_volume_cm3': 2240.0,
        'item_volume_cm3': 1680.0,
        'space_utilization_pct': 75.0,
        'cushioning_material': 'Cellulose Pulp Nest',
        'estimated_cost': 3.85,
        'sustainability_score': 94.0,
        'alternatives': [
          {
            'candidate_id': 'alt_natureflex_01',
            'type': 'ECO_FRIENDLY',
            'material_name': 'Cellulose Breathable Bio-Film (NatureFlex)',
            'star_rating': 4,
            'star_display': '★★★★☆',
            'suitability_category': 'High Compatibility',
            'model_derived_probability': 0.86,
            'trade_off_summary': '100% Home compostable with crystal optical clarity.',
          },
          {
            'candidate_id': 'alt_ldpe_02',
            'type': 'ECONOMY',
            'material_name': 'Macro-Perforated LDPE Poly-Bag',
            'star_rating': 3,
            'star_display': '★★★☆☆',
            'suitability_category': 'Moderate Compatibility',
            'model_derived_probability': 0.72,
            'trade_off_summary': 'Lowest packaging cost for local distribution.',
          }
        ],
        'comparison_summary': {
          'candidate_count': 3,
          'primary_material': 'Micro-Perforated PLA Bio-Clamshell',
          'eco_champion': 'Cellulose Breathable Bio-Film (NatureFlex)',
          'economy_option': 'Macro-Perforated LDPE Poly-Bag',
        }
      };

      final result = PackagingRecommendationResult.fromJson(json);
      expect(result.recommendationId, 'rec_test_strawberries');
      expect(result.alternatives.length, 2);
      expect(result.alternatives[0].starDisplay, '★★★★☆');
      expect(result.alternatives[1].starDisplay, '★★★☆☆');
      expect(result.comparisonSummary?['candidate_count'], 3);
    });
  });

  group('ApiService Offline Alternative Synthesis Tests', () {
    test('synthesizes produce alternative candidates with star ratings and characteristics', () {
      final produceInput = PackagingInput(
        itemName: 'Fresh Strawberries',
        category: 'Fruits',
        weight: 2.0,
        moisture: 91.0,
        fat: 0.3,
        respirationRate20c: 55.0,
        isFragile: true,
        ecoFriendly: true,
      );

      final res = ApiService.generateOfflineRecommendation(produceInput);
      expect(res.alternatives.length, 3);
      
      final eco = res.alternatives.firstWhere((a) => a.type == AlternativeType.ecoFriendly);
      expect(eco.starRating, 4);
      expect(eco.starDisplay, '★★★★☆');
      expect(eco.suitabilityCategory, SuitabilityCategory.highCompatibility);
      expect(eco.characteristics.otr, '2,800 cc/m²/day');
      expect(eco.costDeltaPct, greaterThan(0));

      final econ = res.alternatives.firstWhere((a) => a.type == AlternativeType.economy);
      expect(econ.starRating, 3);
      expect(econ.starDisplay, '★★★☆☆');
      expect(econ.suitabilityCategory, SuitabilityCategory.moderateCompatibility);
      expect(econ.costDeltaPct, lessThan(0));
    });

    test('synthesizes snack alternative candidates with low OTR and paperboard options', () {
      final snackInput = PackagingInput(
        itemName: 'Potato Chips',
        category: 'Snacks',
        weight: 0.5,
        moisture: 1.8,
        fat: 35.0,
        isFragile: true,
        ecoFriendly: false,
      );

      final res = ApiService.generateOfflineRecommendation(snackInput);
      expect(res.alternatives.length, 3);
      
      final paper = res.alternatives.firstWhere((a) => a.type == AlternativeType.ecoFriendly);
      expect(paper.starRating, 4);
      expect(paper.characteristics.sustainabilityRating, contains('Kraft'));
      
      final bopp = res.alternatives.firstWhere((a) => a.type == AlternativeType.economy);
      expect(bopp.starRating, 3);
      expect(bopp.characteristics.costTier, 'Low (₹)');
    });
  });
}
