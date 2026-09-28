import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';

void main() {
  group('AppTranslations Engine Tests (Task 1.2)', () {
    // Simulated English dictionary
    final enDict = <String, dynamic>{
      'app_title': 'SmartPack AI',
      'common': {
        'save': 'Save',
        'cancel': 'Cancel',
        'loading': 'Loading...',
        'items_count': '{count} items found',
        'range_label': '{min} to {max} units',
      },
      'nav': {
        'home': 'Home',
        'analysis': 'Food Analysis',
      },
      'analysis': {
        'title': 'Biochemical Food Analysis',
        'moisture_content': 'Moisture Content (%)',
      },
    };

    // Simulated Tamil dictionary (intentionally missing some keys for fallback testing)
    final taDict = <String, dynamic>{
      'app_title': 'ஸ்மார்ட்பேக் AI',
      'common': {
        'save': 'சேமிக்கவும்',
        'cancel': 'ரத்து செய்',
        'loading': 'ஏற்றுகிறது...',
        'items_count': '{count} பொருட்கள் கிடைத்தன',
        'range_label': '{min} முதல் {max} அலகுகள்',
      },
      'nav': {
        'home': 'முகப்பு',
        'analysis': 'உணவு ஆய்வு',
      },
      // 'analysis' section intentionally omitted to test fallback
    };

    setUp(() {
      // Reset state before each test
      AppTranslations.loadFromMaps(
        primary: enDict,
        fallback: enDict,
        languageCode: 'en',
      );
    });

    test('resolves top-level keys correctly', () {
      expect(AppTranslations.tr('app_title'), equals('SmartPack AI'));
    });

    test('resolves nested dot-separated keys correctly', () {
      expect(AppTranslations.tr('common.save'), equals('Save'));
      expect(AppTranslations.tr('nav.home'), equals('Home'));
      expect(
        AppTranslations.tr('analysis.moisture_content'),
        equals('Moisture Content (%)'),
      );
    });

    test('returns raw key string for completely missing keys (safe fallback)', () {
      expect(
        AppTranslations.tr('nonexistent.deep.key'),
        equals('nonexistent.deep.key'),
      );
    });

    test('interpolates single parameter correctly', () {
      expect(
        AppTranslations.tr('common.items_count', params: {'count': '42'}),
        equals('42 items found'),
      );
    });

    test('interpolates multiple parameters correctly', () {
      expect(
        AppTranslations.tr('common.range_label', params: {'min': '10', 'max': '50'}),
        equals('10 to 50 units'),
      );
    });

    test('String.tr() extension resolves keys identically to static method', () {
      expect('app_title'.tr(), equals('SmartPack AI'));
      expect('common.save'.tr(), equals('Save'));
      expect('nav.analysis'.tr(), equals('Food Analysis'));
    });

    test('String.tr() extension supports parameter interpolation', () {
      expect(
        'common.items_count'.tr(params: {'count': '7'}),
        equals('7 items found'),
      );
    });

    test('falls back to English when Tamil dictionary is missing a section', () {
      AppTranslations.loadFromMaps(
        primary: taDict,
        fallback: enDict,
        languageCode: 'ta',
      );

      // Present in Tamil
      expect(AppTranslations.tr('app_title'), equals('ஸ்மார்ட்பேக் AI'));
      expect(AppTranslations.tr('common.save'), equals('சேமிக்கவும்'));
      expect(AppTranslations.tr('nav.home'), equals('முகப்பு'));

      // Missing in Tamil — should fall back to English
      expect(
        AppTranslations.tr('analysis.title'),
        equals('Biochemical Food Analysis'),
      );
      expect(
        AppTranslations.tr('analysis.moisture_content'),
        equals('Moisture Content (%)'),
      );
    });

    test('falls back to English for missing individual keys within present sections', () {
      // Tamil has 'common' section but let's add a scenario with partial keys
      final partialTaDict = <String, dynamic>{
        'common': {
          'save': 'சேமிக்கவும்',
          // 'cancel' intentionally omitted
        },
      };

      AppTranslations.loadFromMaps(
        primary: partialTaDict,
        fallback: enDict,
        languageCode: 'ta',
      );

      expect(AppTranslations.tr('common.save'), equals('சேமிக்கவும்'));
      expect(AppTranslations.tr('common.cancel'), equals('Cancel')); // English fallback
    });

    test('parameter interpolation works with Tamil localized strings', () {
      AppTranslations.loadFromMaps(
        primary: taDict,
        fallback: enDict,
        languageCode: 'ta',
      );

      expect(
        AppTranslations.tr('common.items_count', params: {'count': '15'}),
        equals('15 பொருட்கள் கிடைத்தன'),
      );
    });

    test('currentLanguage reflects the loaded language code', () {
      expect(AppTranslations.currentLanguage, equals('en'));

      AppTranslations.loadFromMaps(
        primary: taDict,
        fallback: enDict,
        languageCode: 'ta',
      );
      expect(AppTranslations.currentLanguage, equals('ta'));
    });

    test('handles deeply nested keys that resolve to non-string values gracefully', () {
      // 'common' resolves to a Map, not a String
      expect(AppTranslations.tr('common'), equals('common'));
    });
  });
}
