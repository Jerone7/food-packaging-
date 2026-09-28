import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/analytics_model.dart';
import 'package:ai_packaging_recommender/screens/analytics/widgets/monthly_analysis_trend_card.dart';

void main() {
  const testData = MonthlyTrendResponseModel(
    totalPeriodVolume: 235,
    avgMonthlyAnalyses: 117.5,
    overallGrowthPct: 15.9,
    timeSeries: [
      MonthlyTrendDataPointModel(
        monthKey: '2026-02',
        monthLabel: 'Feb 2026',
        year: 2026,
        totalAnalyses: 104,
        ecoFriendlyCount: 42,
        conventionalCount: 62,
        momGrowthPct: 13.0,
        ecoSharePct: 40.38,
      ),
      MonthlyTrendDataPointModel(
        monthKey: '2026-03',
        monthLabel: 'Mar 2026',
        year: 2026,
        totalAnalyses: 131,
        ecoFriendlyCount: 58,
        conventionalCount: 73,
        momGrowthPct: 25.9,
        ecoSharePct: 44.27,
      ),
    ],
  );

  Widget createTestWidget({
    MonthlyTrendResponseModel data = testData,
    bool isLoading = false,
    ValueChanged<MonthlyTrendDataPointModel>? onMonthSelected,
    Size size = const Size(800, 600),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            child: MonthlyAnalysisTrendCard(
              data: data,
              isLoading: isLoading,
              onMonthSelected: onMonthSelected,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('MonthlyAnalysisTrendCard renders title, badge, legend and stats', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Monthly Analysis Count'), findsOneWidget);
    expect(find.text('+15.9% Overall Growth'), findsOneWidget);
    expect(find.text('Mar 2026'), findsOneWidget);
    expect(find.text('Total Trend'), findsOneWidget);
    expect(find.text('Eco-Friendly'), findsOneWidget);
    expect(find.text('Conventional'), findsOneWidget);
    expect(find.text('Total Volume: 235'), findsOneWidget);
    expect(find.text('Avg: 117.5/mo'), findsOneWidget);
  });

  testWidgets('MonthlyAnalysisTrendCard triggers month selection on tap/scrub', (tester) async {
    MonthlyTrendDataPointModel? selected;
    await tester.pumpWidget(
      createTestWidget(
        onMonthSelected: (pt) => selected = pt,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CustomPaint).first);
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
  });

  testWidgets('MonthlyAnalysisTrendCard renders on narrow mobile width without overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(size: const Size(375, 812)));
    await tester.pumpAndSettle();

    expect(find.text('Monthly Analysis Count'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
