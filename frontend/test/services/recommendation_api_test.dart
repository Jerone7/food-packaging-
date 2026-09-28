import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';

void main() {
  group('ApiService Recommendation & Offline Fallback Tests (Task 3.3)', () {
    test('getRecommendation successfully parses online HTTP mock response', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/packaging/recommend')) {
          final mockResponse = {
            'recommendation_id': 'rec_mock1234',
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
              ],
            },
          };
          return http.Response(jsonEncode(mockResponse), 200, headers: {'content-type': 'application/json'});
        }
        return http.Response('Not Found', 404);
      });

      final input = PackagingInput(
        itemName: 'Fresh Tomato',
        weight: 5.0,
        isFragile: true,
        ecoFriendly: true,
      );

      final result = await ApiService.getRecommendation(input, client: mockClient);
      expect(result.recommendationId, 'rec_mock1234');
      expect(result.primaryRecommendation.materialName, contains('Micro-Perforated'));
      expect(result.alternatives.length, 1);
    });

    test('getRecommendation seamlessly resolves client-side offline fallback when network fails', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network connection refused');
      });

      final input = PackagingInput(
        itemName: 'Fresh Tomato',
        category: 'Vegetables',
        weight: 5.0,
        isFragile: true,
        ecoFriendly: true,
        moisture: 94.5,
        respirationRate20c: 45.0,
      );

      final result = await ApiService.getRecommendation(input, client: mockClient);
      expect(result.recommendationId, startsWith('rec_offline_'));
      expect(result.primaryRecommendation.materialName, contains('Micro-Perforated'));
      expect(result.primaryRecommendation.activeAdditives.isNotEmpty, true);
      expect(result.alternatives.length, 3);
      expect(result.boxGeometry.lengthCm, greaterThan(0));
      expect(result.scientificRationale.keyDrivers.isNotEmpty, true);
    });

    test('generateOfflineRecommendation handles high-fat snacks correctly', () {
      final input = PackagingInput(
        itemName: 'Crispy Potato Chips',
        category: 'Snacks',
        weight: 0.5,
        isFragile: true,
        ecoFriendly: false,
        fat: 35.0,
        moisture: 1.8,
      );

      final result = ApiService.generateOfflineRecommendation(input);
      expect(result.primaryRecommendation.materialName, contains('Metallized'));
      expect(result.primaryRecommendation.activeAdditives.any((a) => a.contains('Nitrogen')), true);
      expect(result.alternatives.length, 3);
    });
  });
}
