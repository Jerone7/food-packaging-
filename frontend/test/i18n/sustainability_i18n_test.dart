import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/sustainability/sustainability_analysis_screen.dart';
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

  Widget buildSustainabilityHarness() {
    return const MaterialApp(
      home: SustainabilityAnalysisScreen(
        initialMaterialName: 'PLA / PBAT Bio-Film',
        foodCommodityName: 'Organic Roasted Coffee Beans',
      ),
    );
  }

  group('Sustainability Analysis I18N Tests (Task 4.3)', () {
    testWidgets('SustainabilityAnalysisScreen renders correctly and dynamically translates to Tamil and Hindi', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildSustainabilityHarness());
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectorWidget), findsWidgets);
      expect(find.text(AppTranslations.tr('sustainability.title')), findsOneWidget);

      // Switch to Tamil
      await LocaleService().changeLocale('ta');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppTranslations.tr('sustainability.title')), findsOneWidget);

      // Switch to Hindi
      await LocaleService().changeLocale('hi');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppTranslations.tr('sustainability.title')), findsOneWidget);
    });
  });
}
