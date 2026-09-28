import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';

void main() {
  group('Analysis History Saving Policy (Auth-Gated)', () {
    late PackagingInput sampleInput;

    setUp(() {
      sampleInput = PackagingInput(
        itemName: 'Organic Papaya',
        length: 26.0,
        width: 18.0,
        height: 12.0,
        weight: 2.0,
        isFragile: true,
        ecoFriendly: true,
        category: 'Fruits',
        moisture: 88.0,
      );
    });

    test('When user is authenticated, completed analysis is saved to registered account history', () async {
      AuthService().activateDemoMode();
      final initialHistory = await ApiService.getHistory();
      final initialCount = initialHistory.length;

      final mockClient = MockClient((request) async {
        final authHeader = request.headers['Authorization'];
        expect(authHeader, isNotNull);
        expect(authHeader, contains('Bearer'));

        return http.Response(
          jsonEncode({
            'recommended_box_type': 'Ventilated Corrugated Box',
            'recommended_dimensions': '26.0 x 18.0 x 12.0 cm',
            'box_volume_cm3': 5616.0,
            'item_volume_cm3': 4200.0,
            'space_utilization_pct': 74.8,
            'cushioning_material': 'Recycled Kraft Honeycomb',
            'estimated_cost': 3.20,
            'sustainability_score': 95.0,
            'notes': 'Optimal fruit ventilation.',
          }),
          200,
        );
      });

      final result = await ApiService.getRecommendation(sampleInput, client: mockClient);
      expect(result, isNotNull);

      // Verify that analysis was saved to user history
      final updatedHistory = await ApiService.getHistory();
      expect(updatedHistory.length, equals(initialCount + 1));
      expect(updatedHistory.first.itemName, equals('Organic Papaya'));
      expect(updatedHistory.first.formattedDisplayDate, isNotEmpty);
    });

    test('When user is NOT authenticated, completed analysis is NOT saved to history', () async {
      AuthService().logout();
      final initialHistory = await ApiService.getHistory();
      final initialCount = initialHistory.length;

      final guestInput = PackagingInput(
        itemName: 'Guest Blueberry Box',
        length: 15.0,
        width: 10.0,
        height: 6.0,
        weight: 0.5,
        isFragile: true,
        ecoFriendly: false,
      );

      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], isNull);

        return http.Response(
          jsonEncode({
            'recommended_box_type': 'PET Clamshell',
            'recommended_dimensions': '15.0 x 10.0 x 6.0 cm',
            'box_volume_cm3': 900.0,
            'item_volume_cm3': 600.0,
            'space_utilization_pct': 66.7,
            'cushioning_material': 'Bubble Wrap',
            'estimated_cost': 1.80,
            'sustainability_score': 60.0,
          }),
          200,
        );
      });

      final result = await ApiService.getRecommendation(guestInput, client: mockClient);
      expect(result, isNotNull);

      // Verify that guest analysis was NOT saved to history
      final updatedHistory = await ApiService.getHistory();
      expect(updatedHistory.length, equals(initialCount));
      expect(updatedHistory.any((r) => r.itemName == 'Guest Blueberry Box'), isFalse);
    });
  });
}
