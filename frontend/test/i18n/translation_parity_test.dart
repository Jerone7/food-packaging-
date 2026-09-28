import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Translation Parity & I18N Catalog Tests (Task 1.1)', () {
    late Map<String, dynamic> enJson;
    late Map<String, dynamic> taJson;
    late Map<String, dynamic> hiJson;

    setUpAll(() {
      final enFile = File('assets/i18n/en.json');
      final taFile = File('assets/i18n/ta.json');
      final hiFile = File('assets/i18n/hi.json');

      expect(enFile.existsSync(), isTrue, reason: 'en.json must exist');
      expect(taFile.existsSync(), isTrue, reason: 'ta.json must exist');
      expect(hiFile.existsSync(), isTrue, reason: 'hi.json must exist');

      enJson = json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;
      taJson = json.decode(taFile.readAsStringSync()) as Map<String, dynamic>;
      hiJson = json.decode(hiFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('All required top-level domain sections exist in en.json', () {
      final requiredSections = [
        'app_title',
        'app_tagline',
        'common',
        'nav',
        'landing',
        'analysis',
        'comparison',
        'cost',
        'sustainability',
        'catalog',
        'reports',
        'analytics',
        'admin',
        'profile',
        'glossary',
      ];

      for (final section in requiredSections) {
        expect(enJson.containsKey(section), isTrue, reason: 'Missing section: $section in en.json');
      }
    });

    Set<String> extractAllLeafKeys(Map<String, dynamic> map, [String prefix = '']) {
      final keys = <String>{};
      map.forEach((k, v) {
        final fullKey = prefix.isEmpty ? k : '$prefix.$k';
        if (v is Map<String, dynamic>) {
          keys.addAll(extractAllLeafKeys(v, fullKey));
        } else {
          keys.add(fullKey);
        }
      });
      return keys;
    }

    test('Tamil (ta.json) has 100% key parity with English (en.json)', () {
      final enKeys = extractAllLeafKeys(enJson);
      final taKeys = extractAllLeafKeys(taJson);

      final missingInTamil = enKeys.difference(taKeys);
      final extraInTamil = taKeys.difference(enKeys);

      expect(
        missingInTamil,
        isEmpty,
        reason: 'Keys present in en.json but missing in ta.json: $missingInTamil',
      );
      expect(
        extraInTamil,
        isEmpty,
        reason: 'Keys present in ta.json but not in en.json: $extraInTamil',
      );
      expect(taKeys.length, equals(enKeys.length));
    });

    test('Hindi (hi.json) has 100% key parity with English (en.json)', () {
      final enKeys = extractAllLeafKeys(enJson);
      final hiKeys = extractAllLeafKeys(hiJson);

      final missingInHindi = enKeys.difference(hiKeys);
      final extraInHindi = hiKeys.difference(enKeys);

      expect(
        missingInHindi,
        isEmpty,
        reason: 'Keys present in en.json but missing in hi.json: $missingInHindi',
      );
      expect(
        extraInHindi,
        isEmpty,
        reason: 'Keys present in hi.json but not in en.json: $extraInHindi',
      );
      expect(hiKeys.length, equals(enKeys.length));
    });

    test('No empty translation values in any language dictionary', () {
      void assertNoEmptyValues(Map<String, dynamic> map, String langCode, [String prefix = '']) {
        map.forEach((k, v) {
          final fullKey = prefix.isEmpty ? k : '$prefix.$k';
          if (v is Map<String, dynamic>) {
            assertNoEmptyValues(v, langCode, fullKey);
          } else if (v is String) {
            expect(
              v.trim().isNotEmpty,
              isTrue,
              reason: 'Empty string value for key "$fullKey" in $langCode.json',
            );
          }
        });
      }

      assertNoEmptyValues(enJson, 'en');
      assertNoEmptyValues(taJson, 'ta');
      assertNoEmptyValues(hiJson, 'hi');
    });

    test('Tamil dictionary contains valid Unicode Indic characters', () {
      // Check for presence of Tamil Unicode characters in ta.json
      final taRaw = File('assets/i18n/ta.json').readAsStringSync();
      // Tamil Unicode block is U+0B80 to U+0BFF
      final hasTamilChars = RegExp(r'[\u0B80-\u0BFF]').hasMatch(taRaw);
      expect(hasTamilChars, isTrue, reason: 'ta.json must contain Tamil Unicode script characters');
    });

    test('Hindi dictionary contains valid Unicode Devanagari characters', () {
      // Check for presence of Devanagari Unicode characters in hi.json
      final hiRaw = File('assets/i18n/hi.json').readAsStringSync();
      // Devanagari Unicode block is U+0900 to U+097F
      final hasHindiChars = RegExp(r'[\u0900-\u097F]').hasMatch(hiRaw);
      expect(hasHindiChars, isTrue, reason: 'hi.json must contain Devanagari Unicode script characters');
    });
  });
}
