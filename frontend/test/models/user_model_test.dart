import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/user_model.dart';

void main() {
  group('UserModel & Auth Models Tests (Module 14 - Task 4.1)', () {
    test('UserPreferencesModel serialization and deserialization', () {
      final json = {
        'default_eco_priority': true,
        'default_currency': 'EUR',
        'default_batch_size': 25000,
        'export_organization_header': 'BioPack Solutions Corp',
      };

      final prefs = UserPreferencesModel.fromJson(json);
      expect(prefs.defaultEcoPriority, isTrue);
      expect(prefs.defaultCurrency, 'EUR');
      expect(prefs.defaultBatchSize, 25000);
      expect(prefs.exportOrganizationHeader, 'BioPack Solutions Corp');

      final serialized = prefs.toJson();
      expect(serialized['default_currency'], 'EUR');
      expect(serialized['default_batch_size'], 25000);

      final copy = prefs.copyWith(defaultCurrency: 'USD');
      expect(copy.defaultCurrency, 'USD');
      expect(copy.defaultBatchSize, 25000);
    });

    test('UserPreferencesModel fallback defaults on null input', () {
      final prefs = UserPreferencesModel.fromJson(null);
      expect(prefs.defaultEcoPriority, isTrue);
      expect(prefs.defaultCurrency, 'INR');
      expect(prefs.defaultBatchSize, 10000);
      expect(prefs.exportOrganizationHeader, isNull);
    });

    test('UserStatsModel serialization, defaults, and copyWith', () {
      final json = {
        'total_analyses_count': 42,
        'saved_presets_count': 7,
        'eco_friendly_count': 38,
        'average_sustainability_score': 91.4,
        'member_since': '2026-01-15T08:30:00.000Z',
      };

      final stats = UserStatsModel.fromJson(json);
      expect(stats.totalAnalysesCount, 42);
      expect(stats.savedPresetsCount, 7);
      expect(stats.ecoFriendlyCount, 38);
      expect(stats.averageSustainabilityScore, 91.4);
      expect(stats.memberSince, isNotNull);

      final serialized = stats.toJson();
      expect(serialized['total_analyses_count'], 42);
      expect(serialized['saved_presets_count'], 7);

      final copy = stats.copyWith(savedPresetsCount: 8);
      expect(copy.savedPresetsCount, 8);
      expect(copy.totalAnalysesCount, 42);
    });

    test('UserModel initials and display name derivation', () {
      final user1 = UserModel(
        id: 1,
        email: 'sarah.jenkins@biopack.com',
        fullName: 'Sarah Jenkins',
        organization: 'BioPack Labs',
        createdAt: DateTime.now(),
      );
      expect(user1.initials, 'SJ');
      expect(user1.displayName, 'Sarah Jenkins (BioPack Labs)');

      final user2 = UserModel(
        id: 2,
        email: 'alex@smartpack.io',
        fullName: 'Alex',
        organization: null,
        createdAt: DateTime.now(),
      );
      expect(user2.initials, 'A');
      expect(user2.displayName, 'Alex');

      final user3 = UserModel(
        id: 3,
        email: 'single@smartpack.io',
        fullName: '',
        createdAt: DateTime.now(),
      );
      expect(user3.initials, 'U');
    });

    test('UserModel complete JSON deserialization and serialization round-trip', () {
      final json = {
        'id': 101,
        'email': 'lead.engineer@packaging.org',
        'full_name': 'Dr. Elena Rostova',
        'organization': 'Sustainable Packaging Institute',
        'role': 'Director of Materials Research',
        'is_active': true,
        'is_admin': false,
        'created_at': '2026-03-01T12:00:00.000Z',
        'preferences': {
          'default_eco_priority': true,
          'default_currency': 'INR',
          'default_batch_size': 15000,
          'export_organization_header': 'SPI',
        },
        'stats': {
          'total_analyses_count': 18,
          'saved_presets_count': 4,
          'eco_friendly_count': 16,
          'average_sustainability_score': 88.5,
        },
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 101);
      expect(user.email, 'lead.engineer@packaging.org');
      expect(user.fullName, 'Dr. Elena Rostova');
      expect(user.role, 'Director of Materials Research');
      expect(user.preferences.defaultBatchSize, 15000);
      expect(user.stats?.totalAnalysesCount, 18);

      final reserialized = user.toJson();
      expect(reserialized['id'], 101);
      expect(reserialized['email'], 'lead.engineer@packaging.org');
      expect(reserialized['preferences']['default_batch_size'], 15000);
    });

    test('AuthSessionModel parses token and user', () {
      final json = {
        'access_token': 'jwt.token.string',
        'token_type': 'bearer',
        'expires_in_seconds': 604800,
        'user': {
          'id': 1,
          'email': 'test@smartpack.io',
          'full_name': 'Test User',
          'created_at': '2026-01-01T00:00:00.000Z',
        },
      };

      final session = AuthSessionModel.fromJson(json);
      expect(session.accessToken, 'jwt.token.string');
      expect(session.tokenType, 'bearer');
      expect(session.expiresInSeconds, 604800);
      expect(session.user.email, 'test@smartpack.io');
    });

    test('SavedAnalysisModel serialization, getters, and copyWith', () {
      final json = {
        'id': 12,
        'user_id': 101,
        'title': 'Tomato Export Spec',
        'notes': 'Optimal moisture buffer for Mediterranean transit.',
        'commodity_name': 'Fresh Tomato',
        'recommended_material': 'Bio-based PLA Film',
        'estimated_cost': 3.75,
        'sustainability_score': 94.0,
        'input_payload': {'commodity': 'Fresh Tomato', 'weight_kg': 500},
        'recommendation_result': {'material': 'Bio-based PLA Film'},
        'created_at': '2026-09-20T10:00:00.000Z',
      };

      final preset = SavedAnalysisModel.fromJson(json);
      expect(preset.id, 12);
      expect(preset.userId, 101);
      expect(preset.title, 'Tomato Export Spec');
      expect(preset.formattedCost, '₹3.75');
      expect(preset.formattedScore, '94/100');
      expect(preset.inputPayload['weight_kg'], 500);

      final copy = preset.copyWith(title: 'Updated Tomato Spec', estimatedCost: 3.90);
      expect(copy.title, 'Updated Tomato Spec');
      expect(copy.estimatedCost, 3.90);
      expect(copy.formattedCost, '₹3.90');
    });
  });
}
