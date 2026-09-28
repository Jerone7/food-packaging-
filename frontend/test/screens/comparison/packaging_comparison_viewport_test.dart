import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/comparison/packaging_comparison_screen.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/comparison_parameter_table.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/material_selector_strip.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/comparative_radar_view.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/best_in_class_summary_card.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/ai_trade_off_banner.dart';

void main() {
  group('Multi-Viewport Responsive Layout Audit (0 RenderFlex Overflow)', () {
    testWidgets('Mobile Viewport (375x812) renders without any overflow errors', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
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

      await tester.pumpAndSettle();

      expect(find.byType(PackagingComparisonScreen), findsOneWidget);
      expect(find.byType(MaterialSelectorStrip), findsOneWidget);
      expect(find.byType(ComparisonParameterTable), findsOneWidget);
      expect(find.byType(AiTradeOffBanner), findsOneWidget);
      expect(find.byType(BestInClassSummaryCard), findsOneWidget);
      expect(find.byType(ComparativeRadarView), findsOneWidget);
    });

    testWidgets('Tablet Viewport (768x1024) renders without any overflow errors', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PackagingComparisonScreen(
            initialMaterialIds: ['mat_bio_emap_01', 'mat_al_foil_lam_13'],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PackagingComparisonScreen), findsOneWidget);
      expect(find.byType(MaterialSelectorStrip), findsOneWidget);
      expect(find.byType(ComparisonParameterTable), findsOneWidget);
      expect(find.byType(ComparativeRadarView), findsOneWidget);
    });

    testWidgets('Desktop Viewport (1280x900) 2-column layout renders without any overflow errors', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PackagingComparisonScreen(
            initialMaterialIds: ['mat_bio_emap_01', 'mat_al_foil_lam_13', 'mat_pp_clamshell_06'],
            foodName: 'Crisp Potato Chips',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PackagingComparisonScreen), findsOneWidget);
      expect(find.byType(MaterialSelectorStrip), findsOneWidget);
      expect(find.byType(ComparisonParameterTable), findsOneWidget);
      expect(find.byType(AiTradeOffBanner), findsOneWidget);
      expect(find.byType(BestInClassSummaryCard), findsOneWidget);
      expect(find.byType(ComparativeRadarView), findsOneWidget);
    });
  });
}
