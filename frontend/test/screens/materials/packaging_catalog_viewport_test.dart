import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/materials/packaging_catalog_screen.dart';

void main() {
  Widget buildTestableScreen() {
    return const MaterialApp(
      home: PackagingCatalogScreen(),
    );
  }

  group('PackagingCatalogScreen Multi-Viewport Responsive Audit', () {
    testWidgets('Renders cleanly on Mobile Viewport (375x812) with 0 RenderFlex overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('Packaging Material Database'), findsOneWidget);
      expect(find.text('Add Material'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders cleanly on Tablet Viewport (768x1024)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('Packaging Material Database'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders cleanly on Desktop Viewport (1280x900) in both Grid and Table modes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('Packaging Material Database'), findsOneWidget);
      expect(find.text('Empirical Packaging Substrate Matrix'), findsOneWidget);

      // Switch to Table View mode
      final tableModeButton = find.byIcon(Icons.table_rows_rounded);
      expect(tableModeButton, findsOneWidget);
      await tester.tap(tableModeButton);
      await tester.pumpAndSettle();

      expect(find.text('Material & Structure'), findsOneWidget);
      expect(find.text('OTR (cc)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Switch back to Grid View
      final gridModeButton = find.byIcon(Icons.grid_view_rounded);
      expect(gridModeButton, findsOneWidget);
      await tester.tap(gridModeButton);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
