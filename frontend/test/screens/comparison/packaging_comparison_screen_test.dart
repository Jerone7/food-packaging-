import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/comparison/packaging_comparison_screen.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/comparison_parameter_table.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/material_selector_strip.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/comparative_radar_view.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/best_in_class_summary_card.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/ai_trade_off_banner.dart';

void main() {
  testWidgets('PackagingComparisonScreen renders full matrix with food context', (tester) async {
    // Set realistic viewport size
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: PackagingComparisonScreen(
          initialMaterialIds: ['mat_bio_emap_01', 'mat_al_foil_lam_13', 'mat_pp_clamshell_06'],
          foodId: 1,
          foodName: 'Fresh Strawberries',
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    // Allow async comparison synthesis
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Packaging Material Comparison'), findsOneWidget);
    expect(find.text('Side-by-side parametric trade-off evaluation'), findsOneWidget);

    // Verify Food Context Banner and AI Trade-Off
    expect(find.textContaining('Active Food Context:'), findsOneWidget);
    expect(find.text('AI Trade-Off Analysis for Fresh Strawberries'), findsOneWidget);

    // Verify Main Child Widgets exist
    expect(find.byType(MaterialSelectorStrip), findsOneWidget);
    expect(find.byType(ComparisonParameterTable), findsOneWidget);
    expect(find.byType(AiTradeOffBanner), findsOneWidget);
    expect(find.byType(BestInClassSummaryCard), findsOneWidget);
    expect(find.byType(ComparativeRadarView), findsOneWidget);

    // Verify slot names
    expect(find.text('Material A'), findsWidgets);
    expect(find.text('Material B'), findsWidgets);
    expect(find.text('Material C'), findsWidgets);

    // Test clear food context
    final clearContextBtn = find.byTooltip('Clear Food Context');
    expect(clearContextBtn, findsOneWidget);
    await tester.tap(clearContextBtn);
    await tester.pumpAndSettle();

    expect(find.text('Active Food Context: '), findsNothing);
  });

  testWidgets('PackagingComparisonScreen metric toggle and reset work properly', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: PackagingComparisonScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial render
    expect(find.byType(ComparisonParameterTable), findsOneWidget);

    // Tap metrics toggle
    final toggleMetricsBtn = find.byTooltip('Hide Numeric Metrics');
    expect(toggleMetricsBtn, findsOneWidget);
    await tester.tap(toggleMetricsBtn);
    await tester.pumpAndSettle();

    // Tap Reset button
    final resetBtn = find.byTooltip('Reset to Default Comparison');
    expect(resetBtn, findsOneWidget);
    await tester.tap(resetBtn);
    await tester.pumpAndSettle();

    expect(find.byType(MaterialSelectorStrip), findsOneWidget);
  });
}
