import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/widgets/navigation/language_selector_widget.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocaleService().initForTesting(languageCode: 'en');
  });

  group('LanguageSelectorWidget Tests (Task 3.2)', () {
    testWidgets('Compact mode renders current English language flag and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LanguageSelectorWidget(
              mode: LanguageSelectorMode.compact,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('language_selector_compact')), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
    });

    testWidgets('Compact mode opens popup menu showing all 3 language options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LanguageSelectorWidget(
                mode: LanguageSelectorMode.compact,
              ),
            ),
          ),
        ),
      );

      // Tap compact button to open menu
      await tester.tap(find.byKey(const ValueKey('language_selector_compact')));
      await tester.pumpAndSettle();

      // Verify all 3 options appear in the popup
      expect(find.byKey(const ValueKey('lang_option_en')), findsOneWidget);
      expect(find.byKey(const ValueKey('lang_option_ta')), findsOneWidget);
      expect(find.byKey(const ValueKey('lang_option_hi')), findsOneWidget);

      // Check native labels
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
    });

    testWidgets('Compact mode selecting Tamil switches locale and invokes callback', (tester) async {
      String? switchedLanguage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LanguageSelectorWidget(
                mode: LanguageSelectorMode.compact,
                onLanguageChanged: (code) {
                  switchedLanguage = code;
                },
              ),
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byKey(const ValueKey('language_selector_compact')));
      await tester.pumpAndSettle();

      // Tap Tamil
      await tester.tap(find.byKey(const ValueKey('lang_option_ta')));
      await tester.pumpAndSettle();

      expect(switchedLanguage, equals('ta'));
      expect(LocaleService().languageCode, equals('ta'));
      expect(LocaleService().isTamil, isTrue);

      // The button should now display Tamil flag and text
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('🇮🇳'), findsOneWidget);
    });

    testWidgets('Card mode renders all 3 language options in full-width format', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LanguageSelectorWidget(
              mode: LanguageSelectorMode.card,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('language_selector_card')), findsOneWidget);
      expect(find.byKey(const ValueKey('lang_card_option_en')), findsOneWidget);
      expect(find.byKey(const ValueKey('lang_card_option_ta')), findsOneWidget);
      expect(find.byKey(const ValueKey('lang_card_option_hi')), findsOneWidget);

      expect(find.text('English'), findsNWidgets(2)); // Title & option
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
    });

    testWidgets('Card mode selecting Hindi updates LocaleService and invokes callback', (tester) async {
      String? changedLang;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelectorWidget(
              mode: LanguageSelectorMode.card,
              onLanguageChanged: (lang) {
                changedLang = lang;
              },
            ),
          ),
        ),
      );

      // Tap Hindi option
      await tester.tap(find.byKey(const ValueKey('lang_card_option_hi')));
      for (int i = 0; i < 20 && changedLang == null; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      expect(changedLang, equals('hi'));
      expect(LocaleService().languageCode, equals('hi'));
      expect(LocaleService().isHindi, isTrue);
    });
  });
}
