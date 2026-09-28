import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analysis/food_analysis_screen.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/category_selector.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_search_bar.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_profile_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_scientific_dossier_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/quantity_unit_input.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/storage_condition_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/storage_duration_input.dart';
import 'package:ai_packaging_recommender/services/recent_foods_service.dart';

void main() {
  setUp(() async {
    await RecentFoodsService.resetToDefaults();
  });

  group('FoodAnalysisScreen End-to-End Integration Tests', () {
    testWidgets('renders all selection and parameter widgets on desktop viewport', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodAnalysisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Biochemical Food Analysis & Packaging Prescription'), findsOneWidget);
      expect(find.byType(CategorySelector), findsOneWidget);
      expect(find.byType(FoodSearchBar), findsOneWidget);
      expect(find.byType(FoodProfileCard), findsOneWidget);
      expect(find.byType(FoodScientificDossierCard), findsOneWidget);
      expect(find.byType(QuantityUnitInput), findsOneWidget);
      expect(find.byType(StorageConditionCard), findsOneWidget);
      expect(find.byType(StorageDurationInput), findsOneWidget);
      expect(find.text('Generate AI Prescription'), findsOneWidget);
    });

    testWidgets('pre-selects category and sample food when initialCategory is passed', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodAnalysisScreen(initialCategory: 'Fruits'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fresh Apple'), findsWidgets);
      expect(find.text('Fruits'), findsWidgets);
    });

    testWidgets('completes full analysis submission and renders recommendation card', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodAnalysisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Refrigerated storage mode
      await tester.tap(find.text('Refrigerated'));
      await tester.pumpAndSettle();

      // Tap on Analyze Food Commodity CTA
      await tester.ensureVisible(find.text('Generate AI Prescription'));
      await tester.tap(find.text('Generate AI Prescription'));
      await tester.pumpAndSettle();

      // Verify recommendation card is displayed
      expect(find.text('AI PACKAGING PRESCRIPTION'), findsOneWidget);
      expect(find.text('RECOMMENDED PACKAGING'), findsOneWidget);
      expect(find.text('RECOMMENDATION EXPLANATION'), findsOneWidget);
    });
  });
}
