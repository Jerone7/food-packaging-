import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';

void main() {
  group('User Account Creation & Persistence Tests', () {
    late AuthService auth;

    setUp(() {
      auth = AuthService();
      auth.logout();
    });

    test('Saving user account when created via signup (online)', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/auth/signup')) {
          final body = jsonDecode(request.body);
          return http.Response(
            jsonEncode({
              'access_token': 'jwt.token.created.123',
              'token_type': 'bearer',
              'user': {
                'id': 505,
                'email': body['email'],
                'full_name': body['full_name'],
                'organization': body['organization'] ?? 'Eco Packaging Labs',
                'role': 'Packaging Scientist',
                'is_active': true,
                'is_admin': false,
                'created_at': DateTime.now().toIso8601String(),
                'preferences': {
                  'default_eco_priority': true,
                  'default_currency': 'INR',
                  'default_batch_size': 10000,
                },
                'stats': {
                  'total_analyses_count': 0,
                  'saved_presets_count': 0,
                  'eco_friendly_count': 0,
                  'average_sustainability_score': 0.0,
                }
              }
            }),
            201,
          );
        }
        return http.Response('{"error": "not found"}', 404);
      });

      final success = await auth.signup(
        'alex.green@biopack.io',
        'SecurePassword!123',
        'Alex Green',
        organization: 'Eco Packaging Labs',
        role: 'Packaging Scientist',
        client: mockClient,
      );

      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.email, equals('alex.green@biopack.io'));
      expect(auth.currentUser!.fullName, equals('Alex Green'));
      expect(auth.currentUser!.organization, equals('Eco Packaging Labs'));
    });

    test('Saving user account when created offline and logging in with saved account', () async {
      final mockFailingClient = MockClient((request) async {
        throw http.ClientException('Offline network test');
      });

      // 1. Create account offline
      final success = await auth.signup(
        'offline.user@biopack.io',
        'MySecretPass!999',
        'Offline Engineer',
        organization: 'Field Research Co',
        client: mockFailingClient,
      );

      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser!.email, equals('offline.user@biopack.io'));
      expect(auth.currentUser!.fullName, equals('Offline Engineer'));

      // 2. Logout
      auth.logout();
      expect(auth.isAuthenticated, isFalse);

      // 3. Log back in with the saved account while offline
      final loginSuccess = await auth.login(
        'offline.user@biopack.io',
        'MySecretPass!999',
        client: mockFailingClient,
      );

      expect(loginSuccess, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser!.fullName, equals('Offline Engineer'));
    });

    test('Created registered user can execute analysis and have it saved in history', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/auth/signup')) {
          return http.Response(
            jsonEncode({
              'access_token': 'jwt.token.created.test',
              'token_type': 'bearer',
              'user': {
                'id': 506,
                'email': 'registered.tester@smartpack.io',
                'full_name': 'Registered Tester',
                'organization': 'BioPack Tester',
                'role': 'Packaging Engineer',
                'is_active': true,
                'is_admin': false,
                'created_at': DateTime.now().toIso8601String(),
                'preferences': const {},
                'stats': const {},
              }
            }),
            201,
          );
        }
        if (request.url.path.contains('/packaging/recommend')) {
          return http.Response(
            jsonEncode({
              'recommended_box_type': 'Bio-Pouch',
              'recommended_dimensions': '20 x 15 x 10 cm',
              'box_volume_cm3': 3000.0,
              'item_volume_cm3': 2200.0,
              'space_utilization_pct': 73.3,
              'cushioning_material': 'Molded Fiber',
              'estimated_cost': 2.40,
              'sustainability_score': 97.0,
            }),
            200,
          );
        }
        return http.Response('{}', 200);
      });

      // User created & active
      await auth.signup(
        'registered.tester@smartpack.io',
        'Pass@123',
        'Registered Tester',
        client: mockClient,
      );

      final initialHistory = await ApiService.getHistory();
      final initialCount = initialHistory.length;

      final input = PackagingInput(
        itemName: 'Registered Mango',
        length: 20.0,
        width: 15.0,
        height: 10.0,
        weight: 1.0,
        isFragile: true,
        ecoFriendly: true,
      );

      await ApiService.getRecommendation(input, client: mockClient);

      final updatedHistory = await ApiService.getHistory();
      expect(updatedHistory.length, equals(initialCount + 1));
      expect(updatedHistory.first.itemName, equals('Registered Mango'));
    });
  });
}
