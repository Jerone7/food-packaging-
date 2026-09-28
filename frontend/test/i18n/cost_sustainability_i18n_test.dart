import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/cost_estimation_screen.dart';
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

  Widget buildCostHarness() {
    return const MaterialApp(
      home: CostEstimationScreen(
        initialMaterialName: 'NatureFlex Regenerated Cellulose',
        initialFillQuantity: '500g',
      ),
    );
  }

  group('Cost Estimation I18N Tests (Task 4.3)', () {
    testWidgets('CostEstimationScreen renders English labels and LanguageSelectorWidget by default', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildCostHarness());
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSelectorWidget), findsWidgets);
      expect(find.text(AppTranslations.tr('cost.title')), findsOneWidget);
    });

    testWidgets('CostEstimationScreen dynamically translates title and RFQ dialog to Tamil and Hindi', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildCostHarness());
      await tester.pumpAndSettle();

      // Switch to Tamil
      await LocaleService().changeLocale('ta');
      await tester.pumpAndSettle();

      expect(find.text(AppTranslations.tr('cost.title')), findsOneWidget);

      // Verify Tamil RFQ modal
      await tester.tap(find.text('Supplier RFQ'));
      await tester.pumpAndSettle();

      expect(find.text(AppTranslations.tr('cost.rfq_title')), findsOneWidget);
      expect(find.text(AppTranslations.tr('cost.rfq_btn')), findsOneWidget);

      await tester.tap(find.text(AppTranslations.tr('common.close')));
      await tester.pumpAndSettle();

      // Switch to Hindi
      await LocaleService().changeLocale('hi');
      await tester.pumpAndSettle();

      expect(find.text(AppTranslations.tr('cost.title')), findsOneWidget);

      // Verify Hindi RFQ modal
      await tester.tap(find.text('Supplier RFQ'));
      await tester.pumpAndSettle();

      expect(find.text(AppTranslations.tr('cost.rfq_title')), findsOneWidget);
      expect(find.text(AppTranslations.tr('cost.rfq_btn')), findsOneWidget);

      await tester.tap(find.text(AppTranslations.tr('common.close')));
      await tester.pumpAndSettle();
    });
  });
}
