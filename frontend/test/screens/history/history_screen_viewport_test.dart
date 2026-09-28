import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/history/history_screen.dart';

void main() {
  Widget buildTestableScreen() {
    return const MaterialApp(
      home: HistoryScreen(),
    );
  }

  group('HistoryScreen Multi-Viewport Responsive Audit', () {
    testWidgets('Renders cleanly on Mobile Viewport (375x812) with 0 RenderFlex overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('Recommendation History & Audit Log'), findsOneWidget);
      expect(find.text('Historical AI Packaging Prescriptions'), findsOneWidget);
      expect(find.text('Fresh Strawberries (Export Grade)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders cleanly on Tablet Viewport (768x1024)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('Recommendation History & Audit Log'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Alphonso Mango (Export Grade)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders cleanly on Desktop Viewport (1280x900) with 2-Column Grid and Modal Inspection', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('Recommendation History & Audit Log'), findsOneWidget);
      expect(find.text('Fresh Atlantic Salmon Fillet'), findsOneWidget);

      // Search for Mango
      await tester.enterText(find.byType(TextField), 'Mango');
      await tester.pumpAndSettle();

      expect(find.text('Alphonso Mango (Export Grade)'), findsOneWidget);
      expect(find.text('Fresh Atlantic Salmon Fillet'), findsNothing);

      // Inspect Audit Modal
      final inspectButtons = find.text('Inspect Audit');
      expect(inspectButtons, findsOneWidget);
      await tester.tap(inspectButtons);
      await tester.pumpAndSettle();

      expect(find.text('Blueprint & Geometry'), findsOneWidget);
      expect(find.text('Preservation & Eco'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Blueprint & Geometry'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
