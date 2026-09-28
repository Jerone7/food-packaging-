import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';

void main() {
  group('Module 7 History Data Layer & ApiService Tests', () {
    test('PackagingRecord.fromJson parses full record correctly', () {
      final json = {
        'id': 42,
        'item_name': 'Organic Blueberries',
        'length': 20.0,
        'width': 12.0,
        'height': 8.0,
        'weight': 0.25,
        'is_fragile': true,
        'eco_friendly': true,
        'created_at': '2026-09-26T14:30:00.000Z',
        'recommended_box_type': 'Vented Bio-PLA Clamshell',
        'recommended_dimensions': '20.0 x 12.0 x 8.0 cm',
        'box_volume_cm3': 1920.0,
        'item_volume_cm3': 1400.0,
        'space_util_pct': 72.9,
        'cushioning_material': 'Molded Fiber Pad',
        'estimated_cost': 3.75,
        'sustainability_score': 90.0,
        'notes': 'Optimum O2/CO2 transmission to prevent fungal rot.',
      };

      final record = PackagingRecord.fromJson(json);
      expect(record.id, 42);
      expect(record.itemName, 'Organic Blueberries');
      expect(record.length, 20.0);
      expect(record.width, 12.0);
      expect(record.height, 8.0);
      expect(record.weight, 0.25);
      expect(record.isFragile, isTrue);
      expect(record.ecoFriendly, isTrue);
      expect(record.recommendedBoxType, 'Vented Bio-PLA Clamshell');
      expect(record.estimatedCost, 3.75);
      expect(record.sustainabilityScore, 90.0);
      expect(record.notes, contains('Optimum O2/CO2'));
    });

    test('ApiService.getHistory returns fallback audit list when server offline or empty', () async {
      final mockClient = MockClient((request) async {
        return http.Response('[]', 200);
      });

      final history = await ApiService.getHistory(client: mockClient);
      expect(history, isNotEmpty);
      expect(history.length, greaterThanOrEqualTo(6));
      expect(history.any((r) => r.itemName.contains('Strawberries')), isTrue);
      expect(history.any((r) => r.itemName.contains('Mango')), isTrue);
      expect(history.any((r) => r.itemName.contains('Salmon')), isTrue);
    });

    test('ApiService.saveLocalHistoryRecord prepends custom records to history stream', () async {
      final customRecord = PackagingRecord(
        id: 999,
        itemName: 'Custom Test Passion Fruit',
        length: 15.0,
        width: 10.0,
        height: 8.0,
        weight: 0.3,
        isFragile: true,
        ecoFriendly: true,
        createdAt: DateTime.now(),
        recommendedBoxType: 'Breathable Eco Carton',
        recommendedDimensions: '15.0 x 10.0 x 8.0 cm',
        boxVolumeCm3: 1200.0,
        itemVolumeCm3: 900.0,
        spaceUtilizationPct: 75.0,
        cushioningMaterial: 'Kraft Nest',
        estimatedCost: 2.50,
        sustainabilityScore: 94.0,
        notes: 'Test note for session persistence.',
      );

      ApiService.saveLocalHistoryRecord(customRecord);

      final mockClient = MockClient((request) async {
        return http.Response('[]', 200);
      });

      final history = await ApiService.getHistory(client: mockClient);
      expect(history.first.itemName, 'Custom Test Passion Fruit');
      expect(history.first.id, 999);
    });

    test('ApiService.getHistory parses server records when available', () async {
      final serverJson = [
        {
          'id': 1,
          'item_name': 'Server Cached Apples',
          'length': 30.0,
          'width': 20.0,
          'height': 15.0,
          'weight': 4.0,
          'is_fragile': true,
          'eco_friendly': false,
          'created_at': '2026-09-26T10:00:00.000Z',
          'recommended_box_type': 'Standard Corrugated Box',
          'recommended_dimensions': '30.0 x 20.0 x 15.0 cm',
          'box_volume_cm3': 9000.0,
          'item_volume_cm3': 7000.0,
          'space_util_pct': 77.7,
          'cushioning_material': 'Paper Shreds',
          'estimated_cost': 5.0,
          'sustainability_score': 75.0,
          'notes': 'Bulk apples packaging.',
        }
      ];

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(serverJson), 200);
      });

      final history = await ApiService.getHistory(client: mockClient);
      expect(history.any((r) => r.itemName == 'Server Cached Apples'), isTrue);
    });
  });
}
