import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/cost_estimation_screen.dart';

void main() {
  group('CostEstimationScreen Integration & Interaction Tests', () {
    testWidgets('CostEstimationScreen renders all panels and handles user interactions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CostEstimationScreen(
            initialMaterialName: 'NatureFlex Regenerated Cellulose',
            initialFillQuantity: '500g',
          ),
        ),
      );

      // Verify title & disclaimer
      expect(find.text('Packaging Cost & Material Estimator'), findsOneWidget);
      expect(find.text('ESTIMATED BASELINE COST'), findsOneWidget);
      expect(find.text('ESTIMATED'), findsOneWidget);

      // Verify input sections
      expect(find.text('1. Form Factor'), findsOneWidget);
      expect(find.text('2. Dimensions & Fill'), findsOneWidget);
      expect(find.text('3. Material Substrate'), findsOneWidget);
      expect(find.text('4. Functional Add-ons'), findsOneWidget);
      expect(find.text('5. Batch Run Size'), findsOneWidget);

      // Verify cockpit cards
      expect(find.text('Total Estimated Batch Cost'), findsOneWidget);
      expect(find.text('Cost Per Unit'), findsOneWidget);
      expect(find.text('Material Requirement & Technical Footprint'), findsOneWidget);
      expect(find.text('Cost Structure & Itemized Contribution'), findsOneWidget);
      expect(find.text('Volume Scaling & Economies of Scale'), findsOneWidget);

      // Interact with form factor
      await tester.tap(find.text('Pillow Pouch'));
      await tester.pumpAndSettle();

      // Interact with capacity preset
      await tester.tap(find.text('1kg'));
      await tester.pumpAndSettle();

      // Ensure 25k is visible before tapping
      await tester.ensureVisible(find.text('25k'));
      await tester.pumpAndSettle();

      // Interact with volume milestone chip (25k)
      await tester.tap(find.text('25k'));
      await tester.pumpAndSettle();

      expect(find.text('25k Units'), findsOneWidget);
    });

    testWidgets('CostEstimationScreen displays RFQ dialog when requested', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CostEstimationScreen(),
        ),
      );

      await tester.tap(find.text('Supplier RFQ'));
      await tester.pumpAndSettle();

      expect(find.text('Request Supplier RFQ'), findsOneWidget);
      expect(find.text('Send RFQ to Converters'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Request Supplier RFQ'), findsNothing);
    });
  });
}
