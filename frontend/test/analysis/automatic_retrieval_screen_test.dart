import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analysis/food_analysis_screen.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_scientific_dossier_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_profile_card.dart';
import 'package:ai_packaging_recommender/services/recent_foods_service.dart';

void main() {
  setUp(() async {
    await RecentFoodsService.resetToDefaults();
  });

  group('Module 3: Automatic Scientific Retrieval E2E & Multi-Viewport Audit', () {
    testWidgets('Desktop Viewport (1280x900): Automatically retrieves scientific dossier and updates on commodity selection', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodAnalysisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Initial Food is loaded with scientific dossier
      expect(find.byType(FoodScientificDossierCard), findsOneWidget);
      expect(find.text('Auto-Retrieved Scientific Dossier'), findsOneWidget);
      expect(find.textContaining('Degradation Vulnerability Matrix'), findsOneWidget);

      // Select Vegetables Category -> Select Tomato
      await tester.tap(find.text('Vegetables'));
      await tester.pumpAndSettle();

      expect(find.text('Fresh Tomato'), findsWidgets);
      expect(find.textContaining('Gas Atmosphere & EMAP Kinetics'), findsOneWidget);

      // Switch Storage Condition to Refrigerated -> Chilling Warning should appear in dossier
      await tester.tap(find.text('Refrigerated'));
      await tester.pumpAndSettle();

      expect(find.textContaining('PHYSIOLOGICAL CHILLING WARNING'), findsOneWidget);

      // Submit Packaging Analysis
      await tester.ensureVisible(find.text('Analyze Food Commodity'));
      await tester.tap(find.text('Analyze Food Commodity'));
      await tester.pumpAndSettle();

      // Verify recommendation incorporates EMAP barrier and chilling rules
      expect(find.text('AI PACKAGING PRESCRIPTION'), findsOneWidget);
      expect(find.textContaining('Micro-Perforated'), findsWidgets);
    });

    testWidgets('Tablet Viewport (768x1024): Clean responsive layout with zero overflow on accordion toggle', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodAnalysisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FoodProfileCard), findsOneWidget);
      expect(find.byType(FoodScientificDossierCard), findsOneWidget);

      // Toggle Dossier Accordion to collapse
      await tester.ensureVisible(find.text('Auto-Retrieved Scientific Dossier'));
      await tester.tap(find.text('Auto-Retrieved Scientific Dossier'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Degradation Vulnerability Matrix'), findsNothing);

      // Toggle Dossier Accordion to re-expand
      await tester.ensureVisible(find.text('Auto-Retrieved Scientific Dossier'));
      await tester.tap(find.text('Auto-Retrieved Scientific Dossier'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Degradation Vulnerability Matrix'), findsOneWidget);
    });

    testWidgets('Mobile Viewport (375x812): Zero RenderFlex overflow with all 14 scientific metrics expanded', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: FoodAnalysisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Food Commodity Selection'), findsOneWidget);
      expect(find.byType(FoodScientificDossierCard), findsOneWidget);

      // Scroll smoothly down the full dossier on mobile
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.textContaining('Thermal & Storage Boundaries'), findsOneWidget);
      expect(find.textContaining('Spoilage Vector:'), findsOneWidget);

      // Scroll to CTA button and tap
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Analyze Food Commodity'));
      await tester.tap(find.text('Analyze Food Commodity'));
      await tester.pumpAndSettle();

      expect(find.text('AI PACKAGING PRESCRIPTION'), findsOneWidget);
    });
  });
}
