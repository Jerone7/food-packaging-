import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analysis/food_analysis_screen.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/category_selector.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_search_bar.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_profile_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/quantity_unit_input.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/storage_condition_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/storage_duration_input.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/transport_condition_accordion.dart';
import 'package:ai_packaging_recommender/services/recent_foods_service.dart';

void main() {
  setUp(() async {
    await RecentFoodsService.resetToDefaults();
  });

  group('FoodAnalysisScreen Multi-Viewport Responsive Audit', () {
    testWidgets('renders cleanly on Mobile viewport (375x812) with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
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
      expect(find.byType(QuantityUnitInput), findsOneWidget);
      expect(find.byType(StorageConditionCard), findsOneWidget);
      expect(find.byType(StorageDurationInput), findsOneWidget);
      expect(find.byType(TransportConditionAccordion), findsOneWidget);

      // Scroll down on mobile
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Generate AI Prescription'), findsOneWidget);
    });

    testWidgets('renders cleanly on Tablet viewport (768x1024) with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
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
      expect(find.byType(FoodProfileCard), findsOneWidget);

      // Interact with elements
      await tester.tap(find.text('Vegetables'));
      await tester.pumpAndSettle();

      expect(find.text('Fresh Tomato'), findsWidgets);
    });

    testWidgets('renders cleanly on Desktop viewport (1280x900) in 2-column layout', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodAnalysisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Biochemical Food Analysis & Packaging Prescription'), findsOneWidget);
      expect(find.byType(FoodProfileCard), findsOneWidget);
      expect(find.byType(QuantityUnitInput), findsOneWidget);

      // Switch quantity unit and storage mode
      await tester.tap(find.text('Frozen'));
      await tester.pumpAndSettle();

      // Trigger analysis
      await tester.ensureVisible(find.text('Generate AI Prescription'));
      await tester.tap(find.text('Generate AI Prescription'));
      await tester.pumpAndSettle();

      expect(find.text('AI PACKAGING PRESCRIPTION'), findsOneWidget);
    });
  });
}
