import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analytics/analytics_dashboard_screen.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: AnalyticsDashboardScreen(),
      ),
    );
  }

  group('AnalyticsDashboardScreen Multi-Viewport Zero-Overflow Audits', () {
    testWidgets('Mobile Viewport (375x812) - iPhone 13 / Android Phone', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('📈 Analytics Dashboard'), findsOneWidget);
      expect(find.text('Total Analyses'), findsOneWidget);
      expect(find.text('Most Analyzed Foods'), findsOneWidget);
      expect(find.text('Packaging Distribution'), findsOneWidget);
      expect(find.text('Food Category Breakdown'), findsOneWidget);
      expect(find.text('Monthly Analysis Count'), findsOneWidget);

      final ex = tester.takeException();
      if (ex != null) {
        debugPrint('Mobile exception: $ex');
      }
      expect(ex, isNull);
    });

    testWidgets('Tablet Viewport (768x1024) - iPad / Tablet', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('📈 Analytics Dashboard'), findsOneWidget);
      expect(find.text('Food Commodities'), findsOneWidget);
      expect(find.text('Packaging Materials'), findsOneWidget);

      final ex = tester.takeException();
      if (ex != null) {
        debugPrint('Tablet exception: $ex');
      }
      expect(ex, isNull);
    });

    testWidgets('Desktop Viewport (1440x900) - High-Res Web Monitor', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('📈 Analytics Dashboard'), findsOneWidget);
      expect(find.text('Recommendations'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
