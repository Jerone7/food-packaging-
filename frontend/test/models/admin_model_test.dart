import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/admin_model.dart';


void main() {
  group('Admin Models Unit Tests (Module 15 - Task 3.1)', () {
    test('FoodSearchStatModel fromJson and toJson serialization', () {
      final json = {
        'name': 'Fresh Tomato',
        'category': 'Produce',
        'query_count': 48,
        'share_pct': 33.8,
      };
      final model = FoodSearchStatModel.fromJson(json);
      expect(model.name, 'Fresh Tomato');
      expect(model.category, 'Produce');
      expect(model.queryCount, 48);
      expect(model.sharePct, 33.8);

      final encoded = model.toJson();
      expect(encoded['name'], 'Fresh Tomato');
      expect(encoded['query_count'], 48);
    });

    test('MaterialRecommendStatModel serialization', () {
      final json = {
        'material_name': 'Micro-Perforated Bio-Film',
        'polymer_family': 'BREATHABLE_BIO_EMAP',
        'recommend_count': 62,
        'share_pct': 43.6,
        'average_score': 95.5,
      };
      final model = MaterialRecommendStatModel.fromJson(json);
      expect(model.materialName, 'Micro-Perforated Bio-Film');
      expect(model.recommendCount, 62);
      expect(model.averageScore, 95.5);
    });

    test('DailyUsageTrendModel serialization', () {
      final json = {
        'date': '2026-09-27',
        'total_analyses': 45,
        'eco_analyses': 38,
        'avg_sustainability_score': 92.5,
        'avg_cost_inr': 3.15,
      };
      final model = DailyUsageTrendModel.fromJson(json);
      expect(model.date, '2026-09-27');
      expect(model.totalAnalyses, 45);
      expect(model.ecoAnalyses, 38);
      expect(model.avgSustainabilityScore, 92.5);
      expect(model.avgCostInr, 3.15);
    });

    test('AdminAnalyticsSummaryModel complete parsing', () {
      final json = {
        'total_analyses': 1420,
        'total_users': 85,
        'total_foods_count': 38,
        'total_materials_count': 16,
        'eco_preference_pct': 82.6,
        'average_system_score': 91.4,
        'top_foods': [
          {'name': 'Fresh Tomato', 'category': 'Produce', 'query_count': 48, 'share_pct': 33.8},
        ],
        'top_materials': [
          {
            'material_name': 'Bio-Film',
            'polymer_family': 'BREATHABLE_BIO_EMAP',
            'recommend_count': 62,
            'share_pct': 43.6,
            'average_score': 95.5
          }
        ],
        'trends': [
          {
            'date': '2026-09-27',
            'total_analyses': 45,
            'eco_analyses': 38,
            'avg_sustainability_score': 92.5,
            'avg_cost_inr': 3.15
          }
        ]
      };
      final summary = AdminAnalyticsSummaryModel.fromJson(json);
      expect(summary.totalAnalyses, 1420);
      expect(summary.totalUsers, 85);
      expect(summary.topFoods.length, 1);
      expect(summary.topMaterials.length, 1);
      expect(summary.trends.length, 1);
    });

    test('RuleThresholdConfigModel defaults and copyWith', () {
      const config = RuleThresholdConfigModel();
      expect(config.lipidOxidationFatThresholdPct, 18.0);
      expect(config.highRespirationMoistureThresholdPct, 75.0);
      expect(config.acidicCorrosionPhThreshold, 4.6);
      expect(config.chillingInjuryBufferC, 2.0);
      expect(config.ecoPriorityMultiplier, 1.35);

      final modified = config.copyWith(
        lipidOxidationFatThresholdPct: 22.0,
        ecoPriorityMultiplier: 1.8,
      );
      expect(modified.lipidOxidationFatThresholdPct, 22.0);
      expect(modified.ecoPriorityMultiplier, 1.8);
      expect(modified.highRespirationMoistureThresholdPct, 75.0);
    });

    test('ModelRegistryModel fromJson', () {
      final json = {
        'active_model_name': 'RandomForest-v2.3-18D',
        'algorithm': 'Random Forest 100 Trees',
        'feature_dimension': 18,
        'accuracy_score': 0.984,
        'is_ml_enabled': true,
        'is_heuristic_fallback_active': true,
        'last_trained_at': '2026-09-20T10:00:00.000Z',
        'version_tag': 'v2.3.0-prod',
      };
      final model = ModelRegistryModel.fromJson(json);
      expect(model.activeModelName, 'RandomForest-v2.3-18D');
      expect(model.featureDimension, 18);
      expect(model.accuracyScore, 0.984);
      expect(model.isMlEnabled, isTrue);
    });

    test('AdminRecommendationAuditModel fromJson', () {
      final json = {
        'id': 101,
        'user_id': 1,
        'user_email': 'engineer@packtech.io',
        'item_name': 'Fresh Tomato',
        'length': 12.0,
        'width': 10.0,
        'height': 15.0,
        'weight': 0.45,
        'is_fragile': true,
        'eco_friendly': true,
        'recommended_box_type': 'Corrugated Kraft Box',
        'recommended_dimensions': '15x12x18 cm',
        'cushioning_material': 'Honeycomb Kraft',
        'estimated_cost': 3.10,
        'sustainability_score': 96.5,
        'created_at': '2026-09-26T14:30:00.000Z',
        'formatted_date': '26 Sep 2026',
      };
      final audit = AdminRecommendationAuditModel.fromJson(json);
      expect(audit.id, 101);
      expect(audit.itemName, 'Fresh Tomato');
      expect(audit.formattedDate, '26 Sep 2026');
      expect(audit.estimatedCost, 3.10);
    });

    test('AdminFoodItemModel and AdminFoodDetailModel serialization', () {
      final foodJson = {
        'id': 5,
        'name': 'Alphonso Mango',
        'category': 'Produce',
        'moisture': 84.0,
        'ph': 4.1,
        'fat': 0.4,
        'respiration_class': 'High',
        'scientific_properties': {
          'respiration_rate_20c': 35.0,
          'chilling_injury_threshold_c': 12.0,
        }
      };
      final food = AdminFoodDetailModel.fromJson(foodJson);
      expect(food.name, 'Alphonso Mango');
      expect(food.moisture, 84.0);
      expect(food.scientificProperties?['respiration_rate_20c'], 35.0);
    });

    test('AdminMaterialItemModel serialization', () {
      final matJson = {
        'id': 1,
        'material_id': 'mat_bio_emap_01',
        'name': 'Micro-Perforated Bio-Film',
        'category': 'Biodegradable Bio-Polymer',
        'polymer_family': 'BREATHABLE_BIO_EMAP',
        'thickness_microns': 30.0,
        'sustainability_score': 96.0,
        'estimated_unit_cost_inr': 3.85,
        'is_active_entry': true,
      };
      final mat = AdminMaterialItemModel.fromJson(matJson);
      expect(mat.materialId, 'mat_bio_emap_01');
      expect(mat.thicknessMicrons, 30.0);
      expect(mat.isActiveEntry, isTrue);
    });
  });
}
