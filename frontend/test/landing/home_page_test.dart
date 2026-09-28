import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/landing/home_page.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/home_header.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/hero_section.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/workflow_section.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/benefits_section.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/food_preview_section.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/about_section.dart';
import 'package:ai_packaging_recommender/screens/analysis/food_analysis_screen.dart';
import 'package:ai_packaging_recommender/screens/history/history_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    await LocaleService().init();
    await AppTranslations.load('en');
  });

  group('HomePage Master Screen & Navigation Integration Tests', () {
    testWidgets('renders all 6 consecutive sections without errors', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all sections exist in the widget tree
      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.byType(HeroSection), findsOneWidget);
      expect(find.byType(WorkflowSection), findsOneWidget);
      expect(find.byType(BenefitsSection), findsOneWidget);
      expect(find.byType(FoodPreviewSection), findsOneWidget);
      expect(find.byType(AboutSection), findsOneWidget);
    });

    testWidgets('tapping "Launch Analysis" navigates to FoodAnalysisScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch Analysis').first);
      await tester.pumpAndSettle();

      // Verify FoodAnalysisScreen is pushed
      expect(find.byType(FoodAnalysisScreen), findsOneWidget);

      // Pop back to home
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('tapping History icon navigates to HistoryScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.tap(find.byIcon(Icons.history_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.textContaining('Recommendation History'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
