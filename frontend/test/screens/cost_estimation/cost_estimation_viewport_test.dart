import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/cost_estimation_screen.dart';

void main() {
  group('CostEstimationScreen Multi-Viewport Responsive Tests', () {
    testWidgets('Mobile Viewport (375x812) renders with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: CostEstimationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Packaging Cost & Material Estimator'), findsOneWidget);
      expect(find.text('Total Estimated Batch Cost'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tablet Viewport (768x1024) renders with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: CostEstimationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Packaging Cost & Material Estimator'), findsOneWidget);
      expect(find.text('Total Estimated Batch Cost'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Desktop Viewport (1440x900) renders with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: CostEstimationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Packaging Cost & Material Estimator'), findsOneWidget);
      expect(find.text('Total Estimated Batch Cost'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
