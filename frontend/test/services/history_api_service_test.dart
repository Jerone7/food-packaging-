import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';

void main() {
  setUp(() {
    AuthService().resetForTest();
  });

  group('ApiService History Endpoints & Offline Handlers (Module 13 - Task 3.2)', () {
    test('getHistory returns fallback empirical records when offline', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network unreachable');
      });

      final history = await ApiService.getHistory(client: mockClient);

      expect(history.length, greaterThanOrEqualTo(3));
      expect(history[0].itemName, 'Tomato');
      expect(history[0].formattedDisplayDate, '26 Sep 2026');
      expect(history[1].itemName, 'Apple');
      expect(history[1].formattedDisplayDate, '25 Sep 2026');
      expect(history[2].itemName, 'Potato');
      expect(history[2].formattedDisplayDate, '23 Sep 2026');
    });

    test('getHistory parses server JSON response successfully', () async {
      final mockResponse = [
        {
          'id': 301,
          'user_id': 1,
          'item_name': 'Organic Strawberries',
          'length': 20.0,
          'width': 15.0,
          'height': 8.0,
          'weight': 0.5,
          'is_fragile': true,
          'eco_friendly': true,
          'recommended_box_type': 'Bio-PLA Ventilated Clamshell',
          'recommended_dimensions': '20x15x8 cm',
          'estimated_cost': 4.10,
          'sustainability_score': 95.0,
          'created_at': '2026-09-26T09:00:00.000Z',
          'formatted_date': '26 Sep 2026',
        }
      ];

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final history = await ApiService.getHistory(client: mockClient);

      expect(history.length, 1);
      expect(history[0].id, 301);
      expect(history[0].itemName, 'Organic Strawberries');
      expect(history[0].formattedDisplayDate, '26 Sep 2026');
    });

    test('getHistory attaches Bearer token when user is authenticated', () async {
      AuthService().activateDemoMode();
      bool headerChecked = false;

      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], contains('Bearer '));
        headerChecked = true;
        return http.Response(jsonEncode([]), 200);
      });

      await ApiService.getHistory(client: mockClient);
      expect(headerChecked, isTrue);
    });

    test('getHistoryDetail returns matching record or fallback', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/history/201')) {
          return http.Response(
            jsonEncode({
              'id': 201,
              'item_name': 'Tomato',
              'length': 30.0,
              'width': 20.0,
              'height': 15.0,
              'weight': 5.0,
              'recommended_box_type': 'Corrugated Kraft Box (5-Ply)',
              'recommended_dimensions': '30x20x15 cm',
              'estimated_cost': 3.10,
              'sustainability_score': 96.5,
              'created_at': '2026-09-26T14:30:00.000Z',
              'formatted_date': '26 Sep 2026',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final item = await ApiService.getHistoryDetail(201, client: mockClient);

      expect(item, isNotNull);
      expect(item!.itemName, 'Tomato');
      expect(item.formattedDisplayDate, '26 Sep 2026');
    });

    test('deleteHistoryRecord and clearHistory execute without throwing', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });

      final deleted = await ApiService.deleteHistoryRecord(201, client: mockClient);
      expect(deleted, isTrue);

      final cleared = await ApiService.clearHistory(client: mockClient);
      expect(cleared, isTrue);
    });
  });
}
