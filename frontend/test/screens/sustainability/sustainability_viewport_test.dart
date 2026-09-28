import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/sustainability/sustainability_analysis_screen.dart';

void main() {
  Widget buildTestableWidget({Size surfaceSize = const Size(1200, 900)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: surfaceSize),
        child: const SustainabilityAnalysisScreen(
          initialMaterialId: 'mat_poly_ldpe_01',
          foodCommodityName: 'Ground Roast Coffee',
        ),
      ),
    );
  }

  group('SustainabilityAnalysisScreen Multi-Viewport Audit', () {
    testWidgets('renders perfectly on Mobile viewport (375x812) with 0 overflows', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(surfaceSize: const Size(375, 812)));
      await tester.pumpAndSettle();

      expect(find.text('Sustainability & Circularity Cockpit'), findsOneWidget);
      expect(find.textContaining('Ground Roast Coffee'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders perfectly on Tablet viewport (768x1024) with 0 overflows', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(surfaceSize: const Size(768, 1024)));
      await tester.pumpAndSettle();

      expect(find.text('Sustainability & Circularity Cockpit'), findsOneWidget);
      expect(find.textContaining('Ground Roast Coffee'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders perfectly on Desktop viewport (1440x900) with 0 overflows', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(surfaceSize: const Size(1440, 900)));
      await tester.pumpAndSettle();

      expect(find.text('Sustainability & Circularity Cockpit'), findsOneWidget);
      expect(find.textContaining('Ground Roast Coffee'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
