import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';
import 'package:ai_packaging_recommender/models/commodity_model.dart';

void main() {
  group('ApiService - getFeaturedCommodities Tests', () {
    test('returns parsed categories when backend responds with 200 OK', () async {
      final mockData = {
        'source': 'database',
        'total_foods': 120,
        'total_materials': 7,
        'categories': [
          {
            'category': 'Snacks & Wafers',
            'description': 'Crunchy snack items',
            'sample_items': ['Potato Chips', 'Corn Chips'],
            'count': 15,
          },
          {
            'category': 'Dairy Products',
            'description': 'Dairy items',
            'sample_items': ['Paneer', 'Cheese'],
            'count': 10,
          },
        ]
      };

      final client = MockClient((request) async {
        if (request.url.path.endsWith('/categories-summary')) {
          return http.Response(jsonEncode(mockData), 200, headers: {'content-type': 'application/json'});
        }
        return http.Response('Not Found', 404);
      });

      final result = await ApiService.getFeaturedCommodities(client: client);

      expect(result, isA<CommoditySummaryResult>());
      expect(result.source, 'database');
      expect(result.totalFoods, 120);
      expect(result.totalMaterials, 7);
      expect(result.categories.length, 2);
      expect(result.categories[0].category, 'Snacks & Wafers');
      expect(result.categories[0].sampleItems, contains('Potato Chips'));
    });

    test('falls back gracefully to default static categories when backend fails or times out', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final result = await ApiService.getFeaturedCommodities(client: client);

      expect(result, isA<CommoditySummaryResult>());
      expect(result.source, 'offline_fallback');
      expect(result.categories.isNotEmpty, true);
      expect(result.categories.length, greaterThanOrEqualTo(8));
      expect(result.totalFoods, greaterThan(0));

      final firstCategory = result.categories.first;
      expect(firstCategory.category.isNotEmpty, true);
      expect(firstCategory.sampleItems.isNotEmpty, true);
    });
  });
}
