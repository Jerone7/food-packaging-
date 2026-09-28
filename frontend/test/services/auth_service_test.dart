import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
    authService.resetForTest();
  });

  group('AuthService Session State Tests (Module 14 - Task 4.2)', () {
    test('Initial state is unauthenticated guest', () {
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
      expect(authService.accessToken, isNull);
      expect(authService.savedAnalyses, isEmpty);
      expect(authService.isOfflineDemo, isFalse);
      expect(authService.preferences.defaultCurrency, 'INR');
    });

    test('Successful login updates token, user, and fetches presets', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/auth/login')) {
          final sessionJson = {
            'access_token': 'test_mock_jwt_token',
            'token_type': 'bearer',
            'expires_in_seconds': 604800,
            'user': {
              'id': 1,
              'email': 'engineer@smartpack.io',
              'full_name': 'Dr. Sarah Jenkins',
              'organization': 'BioPack Labs',
              'role': 'Chief Packaging Engineer',
              'is_active': true,
              'created_at': '2026-01-01T00:00:00.000Z',
              'preferences': {
                'default_eco_priority': true,
                'default_currency': 'INR',
                'default_batch_size': 10000,
              },
              'stats': {
                'total_analyses_count': 12,
                'saved_presets_count': 1,
                'eco_friendly_count': 10,
                'average_sustainability_score': 92.0,
              },
            },
          };
          return http.Response(jsonEncode(sessionJson), 200);
        } else if (request.url.path.endsWith('/saved-analyses')) {
          final listJson = [
            {
              'id': 101,
              'user_id': 1,
              'title': 'Mock Strawberries Preset',
              'commodity_name': 'Fresh Strawberries',
              'recommended_material': 'PLA Film',
              'estimated_cost': 4.10,
              'sustainability_score': 93.0,
              'input_payload': {},
              'recommendation_result': {},
              'created_at': '2026-09-01T12:00:00.000Z',
            }
          ];
          return http.Response(jsonEncode(listJson), 200);
        }
        return http.Response('Not Found', 404);
      });

      final success = await authService.login(
        'engineer@smartpack.io',
        'SecurePassword123!',
        client: mockClient,
      );

      expect(success, isTrue);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.accessToken, 'test_mock_jwt_token');
      expect(authService.currentUser?.email, 'engineer@smartpack.io');
      expect(authService.currentUser?.initials, 'SJ');
      expect(authService.savedAnalyses.length, 1);
      expect(authService.savedAnalyses.first.title, 'Mock Strawberries Preset');
      expect(authService.authHeaders['Authorization'], 'Bearer test_mock_jwt_token');
    });

    test('Login failure sets error message and leaves session unauthenticated', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Invalid email or password'}),
          401,
        );
      });

      final success = await authService.login(
        'wrong@smartpack.io',
        'wrongpass',
        client: mockClient,
      );

      expect(success, isFalse);
      expect(authService.isAuthenticated, isFalse);
      expect(authService.errorMessage, 'Invalid email or password');
    });

    test('Successful signup populates user and initiates active session', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/auth/signup')) {
          final sessionJson = {
            'access_token': 'signup_jwt_token_123',
            'token_type': 'bearer',
            'expires_in_seconds': 604800,
            'user': {
              'id': 2,
              'email': 'new.user@smartpack.io',
              'full_name': 'Alex Mercer',
              'organization': 'EcoPack Global',
              'role': 'Packaging Specialist',
              'created_at': '2026-09-27T00:00:00.000Z',
              'preferences': {
                'default_eco_priority': true,
                'default_currency': 'EUR',
              },
            },
          };
          return http.Response(jsonEncode(sessionJson), 201);
        }
        return http.Response('Not Found', 404);
      });

      final success = await authService.signup(
        'new.user@smartpack.io',
        'Password123!',
        'Alex Mercer',
        organization: 'EcoPack Global',
        role: 'Packaging Specialist',
        defaultCurrency: 'EUR',
        client: mockClient,
      );

      expect(success, isTrue);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.accessToken, 'signup_jwt_token_123');
      expect(authService.currentUser?.fullName, 'Alex Mercer');
      expect(authService.preferences.defaultCurrency, 'EUR');
    });

    test('Logout clears token, user, saved analyses, and resets session', () {
      authService.activateDemoMode();
      expect(authService.isAuthenticated, isTrue);
      expect(authService.savedAnalyses.isNotEmpty, isTrue);

      authService.logout();

      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
      expect(authService.accessToken, isNull);
      expect(authService.savedAnalyses, isEmpty);
      expect(authService.isOfflineDemo, isFalse);
    });

    test('Update profile modifies user details and preferences', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/users/me') && request.method == 'PUT') {
          final updatedUserJson = {
            'id': 1,
            'email': 'sarah.jenkins@smartpack.io',
            'full_name': 'Dr. Sarah Jenkins, PhD',
            'organization': 'BioPack Advanced Systems',
            'role': 'VP of Sustainable Engineering',
            'is_active': true,
            'created_at': '2026-01-01T00:00:00.000Z',
            'preferences': {
              'default_eco_priority': true,
              'default_currency': 'USD',
              'default_batch_size': 50000,
              'export_organization_header': 'BioPack Advanced Systems',
            },
          };
          return http.Response(jsonEncode(updatedUserJson), 200);
        }
        return http.Response('Not Found', 404);
      });

      // Populate dummy authenticated user
      authService.activateDemoMode();
      final success = await authService.updateProfile(
        fullName: 'Dr. Sarah Jenkins, PhD',
        organization: 'BioPack Advanced Systems',
        role: 'VP of Sustainable Engineering',
        defaultCurrency: 'USD',
        defaultBatchSize: 50000,
        client: mockClient,
      );

      expect(success, isTrue);
      expect(authService.currentUser?.fullName, 'Dr. Sarah Jenkins, PhD');
      expect(authService.preferences.defaultCurrency, 'USD');
      expect(authService.preferences.defaultBatchSize, 50000);
    });

    test('Saved analyses CRUD in demo mode', () async {
      authService.activateDemoMode();
      final initialCount = authService.savedAnalyses.length;

      // 1. Save new preset
      final preset = await authService.saveAnalysisPreset(
        title: 'Mango Export Special Spec',
        commodityName: 'Alphonso Mango',
        recommendedMaterial: 'Coated Corrugated Tray',
        estimatedCost: 5.50,
        sustainabilityScore: 95.0,
      );

      expect(preset, isNotNull);
      expect(authService.savedAnalyses.length, initialCount + 1);
      expect(authService.savedAnalyses.first.title, 'Mango Export Special Spec');

      // 2. Delete preset
      final deleted = await authService.deleteSavedAnalysis(preset!.id);
      expect(deleted, isTrue);
      expect(authService.savedAnalyses.length, initialCount);
    });
  });
}
