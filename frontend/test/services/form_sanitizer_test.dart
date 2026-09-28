import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/form_sanitizer.dart';

void main() {
  group('FormSanitizer - String & Payload Sanitization', () {
    test('strips HTML tags and JavaScript injection vectors', () {
      const malicious = '<script>alert("pwned")</script>Fresh <b>Organic</b> Tomato';
      final cleaned = FormSanitizer.sanitizeString(malicious);
      expect(cleaned, equals('Fresh Organic Tomato'));
    });

    test('strips event handler injection vectors', () {
      const payload = '<img src="x" onerror=alert(1)>Red Apple';
      final cleaned = FormSanitizer.sanitizeString(payload);
      expect(cleaned, equals('Red Apple'));
    });

    test('strips null bytes and collapses excessive spaces', () {
      const raw = '   Alphonso\x00   Mango     Batch  #42   ';
      final cleaned = FormSanitizer.sanitizeString(raw);
      expect(cleaned, equals('Alphonso Mango Batch #42'));
    });

    test('enforces max length truncation', () {
      final longString = 'A' * 300;
      final cleaned = FormSanitizer.sanitizeString(longString, maxLength: 50);
      expect(cleaned.length, equals(50));
    });

    test('recursively sanitizes nested maps and lists', () {
      final input = {
        'food_name': '<b>Spinach</b>',
        'tags': ['<script>evil()</script>Fresh', 'Green '],
        'details': {
          'notes': '<i>Organic harvest</i>',
          'rating': 5,
        }
      };

      final sanitized = FormSanitizer.sanitizeMap(input);
      expect(sanitized['food_name'], equals('Spinach'));
      expect(sanitized['tags'], equals(['Fresh', 'Green']));
      expect(sanitized['details']['notes'], equals('Organic harvest'));
      expect(sanitized['details']['rating'], equals(5));
    });
  });

  group('FormSanitizer - Boundary Limit Validations', () {
    test('validateStorageTemp validates range [-10.0, 45.0] °C', () {
      expect(FormSanitizer.validateStorageTemp(4.0), isNull);
      expect(FormSanitizer.validateStorageTemp(-10.0), isNull);
      expect(FormSanitizer.validateStorageTemp(45.0), isNull);

      expect(FormSanitizer.validateStorageTemp(-10.1), contains('must be between -10.0°C and 45.0°C'));
      expect(FormSanitizer.validateStorageTemp(45.1), contains('must be between -10.0°C and 45.0°C'));
      expect(FormSanitizer.validateStorageTemp(null), contains('required'));
      expect(FormSanitizer.validateStorageTemp(double.nan), contains('Invalid'));
    });

    test('validateRelativeHumidity validates range [10.0, 100.0] %', () {
      expect(FormSanitizer.validateRelativeHumidity(85.0), isNull);
      expect(FormSanitizer.validateRelativeHumidity(10.0), isNull);
      expect(FormSanitizer.validateRelativeHumidity(100.0), isNull);

      expect(FormSanitizer.validateRelativeHumidity(9.9), contains('must be between 10.0% and 100.0%'));
      expect(FormSanitizer.validateRelativeHumidity(100.1), contains('must be between 10.0% and 100.0%'));
      expect(FormSanitizer.validateRelativeHumidity(null), contains('required'));
    });

    test('validateTargetShelfLife validates range [1, 365] days', () {
      expect(FormSanitizer.validateTargetShelfLife(1), isNull);
      expect(FormSanitizer.validateTargetShelfLife(14), isNull);
      expect(FormSanitizer.validateTargetShelfLife(365), isNull);

      expect(FormSanitizer.validateTargetShelfLife(0), contains('must be between 1 and 365 days'));
      expect(FormSanitizer.validateTargetShelfLife(366), contains('must be between 1 and 365 days'));
      expect(FormSanitizer.validateTargetShelfLife(null), contains('required'));
    });

    test('validateFoodWeight validates range [0.01, 100.0] kg', () {
      expect(FormSanitizer.validateFoodWeight(0.5), isNull);
      expect(FormSanitizer.validateFoodWeight(0.01), isNull);
      expect(FormSanitizer.validateFoodWeight(100.0), isNull);

      expect(FormSanitizer.validateFoodWeight(0.005), contains('must be between 0.01 kg and 100.0 kg'));
      expect(FormSanitizer.validateFoodWeight(100.5), contains('must be between 0.01 kg and 100.0 kg'));
      expect(FormSanitizer.validateFoodWeight(null), contains('required'));
    });
  });

  group('FormSanitizer - Authentication & Credentials Validation', () {
    test('validateEmail validates RFC 5322 formatted emails', () {
      expect(FormSanitizer.validateEmail('user@smartpack.com'), isNull);
      expect(FormSanitizer.validateEmail('admin.dev+test@packaging.org'), isNull);

      expect(FormSanitizer.validateEmail(null), contains('required'));
      expect(FormSanitizer.validateEmail(''), contains('required'));
      expect(FormSanitizer.validateEmail('not-an-email'), contains('valid email'));
      expect(FormSanitizer.validateEmail('missing@domain'), contains('valid email'));
    });

    test('validatePassword enforces strong complexity rules', () {
      // Prohibited common passwords
      expect(FormSanitizer.validatePassword('admin'), contains('too common'));
      expect(FormSanitizer.validatePassword('password'), contains('too common'));
      expect(FormSanitizer.validatePassword('12345678'), contains('too common'));

      // Length rules
      expect(FormSanitizer.validatePassword('Short1!'), contains('at least 8 characters'));

      // Complexity components
      expect(FormSanitizer.validatePassword('nouppercase1!'), contains('uppercase letter'));
      expect(FormSanitizer.validatePassword('NOLOWERCASE1!'), contains('lowercase letter'));
      expect(FormSanitizer.validatePassword('NoDigitsHere!'), contains('number'));
      expect(FormSanitizer.validatePassword('NoSpecialChar1'), contains('special character'));

      // Valid strong passwords
      expect(FormSanitizer.validatePassword('SecurePass123!'), isNull);
      expect(FormSanitizer.validatePassword('SmartPack#2026!A'), isNull);
    });
  });
}
