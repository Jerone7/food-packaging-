import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/theme/app_theme.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocaleService().initForTesting(languageCode: 'en');
  });

  group('Indic Typography & Locale-Aware TextStyle (Task 3.1)', () {
    test('English locale defaults to standard font and compact line height', () {
      final style = AppTheme.getLocalizedTextStyle(
        languageCode: 'en',
        fontSize: 16.0,
      );

      expect(style.fontFamily, isNull);
      expect(style.height, equals(1.4));
      expect(style.fontSize, equals(16.0));
    });

    test('Tamil locale injects NotoSansTamil and expanded line height (1.55)', () {
      final style = AppTheme.getLocalizedTextStyle(
        languageCode: 'ta',
        fontSize: 14.0,
      );

      expect(style.fontFamily, equals('NotoSansTamil'));
      expect(style.height, greaterThanOrEqualTo(1.50));
      expect(style.height, lessThanOrEqualTo(1.55));
      expect(style.letterSpacing, equals(0.0));
    });

    test('Hindi locale injects NotoSansDevanagari and expanded line height (1.52)', () {
      final style = AppTheme.getLocalizedTextStyle(
        languageCode: 'hi',
        fontSize: 14.0,
      );

      expect(style.fontFamily, equals('NotoSansDevanagari'));
      expect(style.height, greaterThanOrEqualTo(1.50));
      expect(style.height, lessThanOrEqualTo(1.55));
      expect(style.letterSpacing, equals(0.0));
    });

    test('Custom parameters are preserved through getLocalizedTextStyle', () {
      const base = TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      );

      final localized = AppTheme.getLocalizedTextStyle(
        baseStyle: base,
        languageCode: 'ta',
      );

      expect(localized.fontSize, equals(18.0));
      expect(localized.fontWeight, equals(FontWeight.bold));
      expect(localized.color, equals(Colors.teal));
      expect(localized.fontFamily, equals('NotoSansTamil'));
      expect(localized.height, equals(1.55));
    });

    test('Explicit height override is respected over default script height', () {
      final style = AppTheme.getLocalizedTextStyle(
        languageCode: 'ta',
        height: 1.65,
      );

      expect(style.fontFamily, equals('NotoSansTamil'));
      expect(style.height, equals(1.65));
    });

    test('LocalizedTextStyleExtension withLocale works seamlessly', () {
      const base = TextStyle(fontSize: 15.0);

      final taStyle = base.withLocale('ta');
      expect(taStyle.fontFamily, equals('NotoSansTamil'));
      expect(taStyle.height, equals(1.55));

      final hiStyle = base.withLocale('hi');
      expect(hiStyle.fontFamily, equals('NotoSansDevanagari'));
      expect(hiStyle.height, equals(1.52));
    });

    test('getLocalizedTextTheme creates script-appropriate TextTheme', () {
      final taTheme = AppTheme.getLocalizedTextTheme('ta');
      expect(taTheme.bodyLarge?.fontFamily, equals('NotoSansTamil'));
      expect(taTheme.bodyLarge?.height, equals(1.55));

      final hiTheme = AppTheme.getLocalizedTextTheme('hi');
      expect(hiTheme.bodyLarge?.fontFamily, equals('NotoSansDevanagari'));
      expect(hiTheme.bodyLarge?.height, equals(1.52));
    });

    test('Automatically uses active LocaleService when languageCode is omitted', () {
      LocaleService().changeLocaleForTesting(languageCode: 'ta');
      final taStyle = AppTheme.getLocalizedTextStyle();
      expect(taStyle.fontFamily, equals('NotoSansTamil'));
      expect(taStyle.height, equals(1.55));

      LocaleService().changeLocaleForTesting(languageCode: 'hi');
      final hiStyle = AppTheme.getLocalizedTextStyle();
      expect(hiStyle.fontFamily, equals('NotoSansDevanagari'));
      expect(hiStyle.height, equals(1.52));
    });

    test('getThemeForLocale produces complete valid ThemeData', () {
      final themeTa = AppTheme.getThemeForLocale('ta');
      expect(themeTa.useMaterial3, isTrue);
      expect(themeTa.textTheme.bodyLarge?.fontFamily, equals('NotoSansTamil'));
      expect(themeTa.scaffoldBackgroundColor, equals(AppTheme.bgOffWhite));
    });
  });
}
