import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/analytics_model.dart';
import 'package:ai_packaging_recommender/screens/analytics/widgets/kpi_metrics_grid.dart';

void main() {
  const testKpis = KpiSummaryMetricsModel(
    totalAnalyses: 1245,
    uniqueFoodCommodities: 42,
    packagingMaterialsCount: 18,
    totalRecommendations: 1245,
    ecoAdoptionRate: 41.2,
    avgShelfLifeExtensionPct: 168.5,
    momAnalysisGrowthPct: 18.4,
  );

  Widget createTestWidget({Size size = const Size(1200, 800), bool isLoading = false}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: SingleChildScrollView(
              child: KpiMetricsGrid(
                kpis: testKpis,
                isLoading: isLoading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('KpiMetricsGrid renders 4 KPI metric cards with correct text', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Total Analyses'), findsOneWidget);
    expect(find.text('Food Commodities'), findsOneWidget);
    expect(find.text('Packaging Materials'), findsOneWidget);
    expect(find.text('Recommendations'), findsOneWidget);

    // Formatted counts (1,245 appears twice: Total Analyses & Recommendations)
    expect(find.text('1,245'), findsNWidgets(2));
    expect(find.text('42'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('+18.4%'), findsOneWidget);
  });

  testWidgets('KpiMetricsGrid renders cleanly on mobile viewport without overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(size: const Size(375, 812)));
    await tester.pumpAndSettle();

    expect(find.text('Total Analyses'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('KpiMetricsGrid renders cleanly on tablet viewport without overflow', (tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(size: const Size(768, 1024)));
    await tester.pumpAndSettle();

    expect(find.text('Food Commodities'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
