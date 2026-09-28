import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/comparison/packaging_comparison_screen.dart';
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

  Widget buildComparisonHarness() {
    return const MaterialApp(
      home: PackagingComparisonScreen(
        initialMaterialIds: ['mat_bio_emap_01', 'mat_al_foil_lam_13', 'mat_pp_clamshell_06'],
        foodId: 1,
        foodName: 'Fresh Strawberries',
      ),
    );
  }

  group('Packaging Comparison I18N Tests', () {
    testWidgets('PackagingComparisonScreen renders correctly and dynamically translates to Tamil and Hindi', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildComparisonHarness());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectorWidget), findsWidgets);
      expect(find.text(AppTranslations.tr('comparison.title')), findsOneWidget);

      // Switch to Tamil
      await LocaleService().changeLocale('ta');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppTranslations.tr('comparison.title')), findsOneWidget);

      // Switch to Hindi
      await LocaleService().changeLocale('hi');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppTranslations.tr('comparison.title')), findsOneWidget);
    });
  });
}
