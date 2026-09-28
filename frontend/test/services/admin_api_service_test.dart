import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/services/admin_api_service.dart';

void main() {
  setUp(() {
    AdminApiService.resetMockStore();
  });
  group('AdminApiService Online HTTP Tests', () {
    test('getAnalyticsSummary returns parsed model on 200 response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/admin/analytics/summary');
        return http.Response(
          jsonEncode({
            'total_analyses': 500,
            'total_users': 45,
            'total_foods_count': 12,
            'total_materials_count': 8,
            'eco_preference_pct': 75.5,
            'average_system_score': 92.3,
            'top_foods': [
              {'name': 'Tomato', 'category': 'Produce', 'query_count': 20, 'share_pct': 40.0}
            ],
            'top_materials': [
              {
                'material_name': 'Bio-Film',
                'polymer_family': 'BIO_EMAP',
                'recommend_count': 30,
                'share_pct': 60.0,
                'average_score': 95.0
              }
            ],
            'trends': [
              {
                'date': '2026-09-27',
                'total_analyses': 50,
                'eco_analyses': 40,
                'avg_sustainability_score': 93.0,
                'avg_cost_inr': 3.20
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AdminApiService(client: mockClient);
      final summary = await service.getAnalyticsSummary();

      expect(summary.totalAnalyses, 500);
      expect(summary.totalUsers, 45);
      expect(summary.ecoPreferencePct, 75.5);
      expect(summary.topFoods.length, 1);
      expect(summary.topFoods.first.name, 'Tomato');
      expect(summary.topMaterials.first.materialName, 'Bio-Film');
      expect(summary.trends.first.totalAnalyses, 50);
    });

    test('listFoods sends search & category query params and returns list', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/admin/foods');
        expect(request.url.queryParameters['search'], 'apple');
        expect(request.url.queryParameters['category'], 'Produce');
        return http.Response(
          jsonEncode({
            'total': 1,
            'items': [
              {
                'id': 2,
                'name': 'Fresh Apple',
                'category': 'Produce',
                'moisture': 85.5,
                'ph': 3.6,
                'fat': 0.2,
                'water_activity': 0.98,
                'respiration_class': 'Moderate'
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AdminApiService(client: mockClient);
      final foods = await service.listFoods(search: 'apple', category: 'Produce');

      expect(foods.length, 1);
      expect(foods.first.name, 'Fresh Apple');
      expect(foods.first.respirationClass, 'Moderate');
    });

    test('createFood creates and returns new food item', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/admin/foods');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body);
        expect(body['name'], 'Organic Dragonfruit');
        return http.Response(
          jsonEncode({
            'id': 101,
            'name': 'Organic Dragonfruit',
            'category': 'Produce',
            'moisture': 87.0,
            'ph': 4.8,
            'fat': 0.4,
            'respiration_class': 'Moderate',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AdminApiService(client: mockClient);
      final result = await service.createFood({
        'name': 'Organic Dragonfruit',
        'category': 'Produce',
        'moisture': 87.0,
        'ph': 4.8,
        'fat': 0.4,
      });

      expect(result.id, 101);
      expect(result.name, 'Organic Dragonfruit');
    });

    test('updateFoodScientificProperties updates 14-property scientific fields', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/admin/foods/5/scientific-properties');
        expect(request.method, 'PUT');
        return http.Response(
          jsonEncode({
            'id': 5,
            'name': 'Alphonso Mango',
            'category': 'Produce',
            'moisture': 84.0,
            'ph': 4.1,
            'fat': 0.4,
            'respiration_class': 'High',
            'scientific_properties': {
              'respiration_rate_20c': 42.0,
              'chilling_injury_threshold_c': 11.5,
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AdminApiService(client: mockClient);
      final result = await service.updateFoodScientificProperties(5, {
        'respiration_rate_20c': 42.0,
        'chilling_injury_threshold_c': 11.5,
      });

      expect(result?.scientificProperties?['respiration_rate_20c'], 42.0);
      expect(result?.scientificProperties?['chilling_injury_threshold_c'], 11.5);
    });

    test('listMaterials & toggleMaterialStatus work as expected', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/admin/materials') {
          return http.Response(
            jsonEncode({
              'total': 1,
              'items': [
                {
                  'id': 1,
                  'material_id': 'mat_01',
                  'name': 'Bio Pouch',
                  'category': 'Bio-Film',
                  'polymer_family': 'PLA',
                  'thickness_microns': 30.0,
                  'sustainability_score': 95.0,
                  'estimated_unit_cost_inr': 3.5,
                  'is_active_entry': true,
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/api/v1/admin/materials/1/toggle-status') {
          return http.Response(
            jsonEncode({
              'id': 1,
              'material_id': 'mat_01',
              'name': 'Bio Pouch',
              'category': 'Bio-Film',
              'polymer_family': 'PLA',
              'thickness_microns': 30.0,
              'sustainability_score': 95.0,
              'estimated_unit_cost_inr': 3.5,
              'is_active_entry': false,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = AdminApiService(client: mockClient);
      final list = await service.listMaterials();
      expect(list.length, 1);
      expect(list.first.isActiveEntry, true);

      final toggled = await service.toggleMaterialStatus(1);
      expect(toggled?.isActiveEntry, false);
    });

    test('getRules and updateRules interact with rule config', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'lipid_oxidation_fat_threshold_pct': 20.0,
              'high_respiration_moisture_threshold_pct': 78.0,
              'acidic_corrosion_ph_threshold': 4.5,
              'chilling_injury_buffer_c': 2.5,
              'gas_cushion_headspace_min_pct': 35.0,
              'gas_cushion_headspace_max_pct': 55.0,
              'eco_priority_multiplier': 1.4,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else {
          final body = jsonDecode(request.body);
          return http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
        }
      });

      final service = AdminApiService(client: mockClient);
      final rules = await service.getRules();
      expect(rules.lipidOxidationFatThresholdPct, 20.0);
      expect(rules.highRespirationMoistureThresholdPct, 78.0);

      final updated = await service.updateRules(rules.copyWith(lipidOxidationFatThresholdPct: 22.0));
      expect(updated.lipidOxidationFatThresholdPct, 22.0);
    });

    test('getModelRegistry and toggleMlMode manage ML model status', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'active_model_name': 'RandomForest-v2.3',
              'algorithm': 'Random Forest',
              'feature_dimension': 18,
              'accuracy_score': 0.985,
              'is_ml_enabled': true,
              'is_heuristic_fallback_active': true,
              'version_tag': 'v2.3.0',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else {
          return http.Response(
            jsonEncode({
              'active_model_name': 'RandomForest-v2.3',
              'algorithm': 'Random Forest',
              'feature_dimension': 18,
              'accuracy_score': 0.985,
              'is_ml_enabled': false,
              'is_heuristic_fallback_active': true,
              'version_tag': 'v2.3.0',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
      });

      final service = AdminApiService(client: mockClient);
      final model = await service.getModelRegistry();
      expect(model.isMlEnabled, true);
      expect(model.activeModelName, 'RandomForest-v2.3');

      final toggled = await service.toggleMlMode();
      expect(toggled.isMlEnabled, false);
    });

    test('getRecommendationsAudit returns audit log records', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'total': 1,
            'items': [
              {
                'id': 1,
                'user_id': 10,
                'user_email': 'test@org.io',
                'item_name': 'Tomato',
                'length': 10.0,
                'width': 10.0,
                'height': 10.0,
                'weight': 0.5,
                'is_fragile': true,
                'eco_friendly': true,
                'recommended_box_type': 'Kraft Box',
                'recommended_dimensions': '12x12x12 cm',
                'cushioning_material': 'Paper',
                'estimated_cost': 3.5,
                'sustainability_score': 95.0,
                'formatted_date': '27 Sep 2026',
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AdminApiService(client: mockClient);
      final logs = await service.getRecommendationsAudit();

      expect(logs.length, 1);
      expect(logs.first.userEmail, 'test@org.io');
      expect(logs.first.recommendedBoxType, 'Kraft Box');
    });
  });

  group('AdminApiService Offline Fallback Tests', () {
    test('Offline fallback returns populated summary, foods, and materials', () async {
      final failingClient = MockClient((request) async => http.Response('Server error', 500));
      final service = AdminApiService(client: failingClient);

      final summary = await service.getAnalyticsSummary();
      expect(summary.totalAnalyses, greaterThan(0));
      expect(summary.topFoods.isNotEmpty, true);

      final foods = await service.listFoods(search: 'Tomato');
      expect(foods.any((f) => f.name.contains('Tomato')), true);

      final materials = await service.listMaterials();
      expect(materials.isNotEmpty, true);

      final rules = await service.getRules();
      expect(rules.lipidOxidationFatThresholdPct, 18.0);

      final model = await service.getModelRegistry();
      expect(model.activeModelName.isNotEmpty, true);

      final audit = await service.getRecommendationsAudit();
      expect(audit.isNotEmpty, true);
    });
  });
}
