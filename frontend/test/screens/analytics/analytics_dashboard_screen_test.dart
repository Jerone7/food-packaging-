import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analytics/analytics_dashboard_screen.dart';

void main() {
  Widget createTestScreen({Size size = const Size(1200, 900)}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: const AnalyticsDashboardScreen(),
        ),
      ),
    );
  }

  testWidgets('AnalyticsDashboardScreen renders all sections and 4 charts', (tester) async {
    await tester.pumpWidget(createTestScreen());
    await tester.pumpAndSettle();

    // Header & Filter Bar
    expect(find.text('📈 Analytics Dashboard'), findsOneWidget);
    expect(find.text('Live Engine'), findsOneWidget);
    expect(find.text('7 Days'), findsOneWidget);
    expect(find.text('All Time'), findsOneWidget);
    expect(find.text('Export CSV'), findsOneWidget);

    // 4 KPI Cards
    expect(find.text('Total Analyses'), findsOneWidget);
    expect(find.text('Food Commodities'), findsOneWidget);
    expect(find.text('Packaging Materials'), findsOneWidget);
    expect(find.text('Recommendations'), findsOneWidget);

    // 4 Charts
    expect(find.text('Most Analyzed Foods'), findsOneWidget);
    expect(find.text('Packaging Distribution'), findsOneWidget);
    expect(find.text('Food Category Breakdown'), findsOneWidget);
    expect(find.text('Monthly Analysis Count'), findsOneWidget);
  });

  testWidgets('AnalyticsDashboardScreen switches date filters on tap', (tester) async {
    await tester.pumpWidget(createTestScreen());
    await tester.pumpAndSettle();

    // Tap 30 Days filter
    await tester.tap(find.text('30 Days'));
    await tester.pumpAndSettle();

    expect(find.text('30 Days'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AnalyticsDashboardScreen triggers CSV export with feedback snackbar', (tester) async {
    await tester.pumpWidget(createTestScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export CSV'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Analytics dataset exported successfully as CSV'), findsOneWidget);
  });
}
