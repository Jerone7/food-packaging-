import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/analysis/food_analysis_screen.dart';
import 'package:ai_packaging_recommender/widgets/navigation/language_selector_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    final localeService = LocaleService();
    await localeService.init();
    await AppTranslations.load('en');
  });

  tearDown(() {
    AppTranslations.resetCache();
  });

  Widget buildAnalysisHarness() {
    return const MaterialApp(
      home: FoodAnalysisScreen(),
    );
  }

  group('Food Analysis I18N Tests', () {
    testWidgets('FoodAnalysisScreen renders English labels and LanguageSelectorWidget by default', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAnalysisHarness());
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectorWidget), findsWidgets);
      expect(find.text('Biochemical Food Analysis & Packaging Prescription'), findsOneWidget);
      expect(find.text('Generate AI Prescription'), findsOneWidget);
    });

    testWidgets('FoodAnalysisScreen dynamically translates to Tamil and Hindi', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAnalysisHarness());
      await tester.pumpAndSettle();

      // Switch to Tamil
      await LocaleService().changeLocale('ta');
      await tester.pumpAndSettle();

      expect(find.text(AppTranslations.tr('analysis.title')), findsOneWidget);
      expect(find.text(AppTranslations.tr('analysis.btn_calculate')), findsOneWidget);

      // Switch to Hindi
      await LocaleService().changeLocale('hi');
      await tester.pumpAndSettle();

      expect(find.text(AppTranslations.tr('analysis.title')), findsOneWidget);
      expect(find.text(AppTranslations.tr('analysis.btn_calculate')), findsOneWidget);
    });
  });
}
