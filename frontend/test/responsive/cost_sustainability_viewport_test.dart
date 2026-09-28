import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/cost_estimation_screen.dart';
import 'package:ai_packaging_recommender/screens/sustainability/sustainability_analysis_screen.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/packaging_type_selector_grid.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/cost_summary_hero_card.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/sustainability_profile_hero_card.dart';
import 'package:ai_packaging_recommender/theme/app_theme.dart';

void main() {
  group('Cost Estimation & Sustainability Analysis Multi-Viewport Responsive Audit', () {
    // -------------------------------------------------------------------------
    // 1. CostEstimationScreen Responsive Audit
    // -------------------------------------------------------------------------
    group('CostEstimationScreen Viewport Adaptability', () {
      testWidgets('Desktop Viewport (1440x900) renders 2-column input + cockpit layout without overflow', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CostEstimationScreen(
              initialMaterialName: 'NatureFlex Regenerated Cellulose',
              initialFillQuantity: '500g',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CostEstimationScreen), findsOneWidget);
        expect(find.byType(PackagingTypeSelectorGrid), findsOneWidget);
        expect(find.byType(CostSummaryHeroCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Laptop Viewport (1024x768) renders balanced side-by-side cockpit without overflow', (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CostEstimationScreen(
              initialMaterialName: 'LDPE Polyethylene',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CostEstimationScreen), findsOneWidget);
        expect(find.byType(PackagingTypeSelectorGrid), findsOneWidget);
        expect(find.byType(CostSummaryHeroCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Tablet Viewport (768x1024) renders stacked calculation cockpit cleanly', (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CostEstimationScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CostEstimationScreen), findsOneWidget);
        expect(find.byType(PackagingTypeSelectorGrid), findsOneWidget);
        expect(find.byType(CostSummaryHeroCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Mobile Viewport (375x812) renders single-column flow without overflow', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CostEstimationScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CostEstimationScreen), findsOneWidget);
        expect(find.byType(PackagingTypeSelectorGrid), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // 2. SustainabilityAnalysisScreen Responsive Audit
    // -------------------------------------------------------------------------
    group('SustainabilityAnalysisScreen Viewport Adaptability', () {
      testWidgets('Desktop Viewport (1440x900) renders side-by-side Eco-Score cockpit cleanly', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SustainabilityAnalysisScreen(
              initialMaterialId: 'mat_cell_natureflex_02',
              foodCommodityName: 'Organic Strawberries',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SustainabilityAnalysisScreen), findsOneWidget);
        expect(find.byType(SustainabilityProfileHeroCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Tablet Viewport (768x1024) renders stacked LCA cards cleanly', (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SustainabilityAnalysisScreen(
              initialMaterialId: 'mat_bio_emap_01',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SustainabilityAnalysisScreen), findsOneWidget);
        expect(find.byType(SustainabilityProfileHeroCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Mobile Viewport (375x812) renders scrollable LCA cards without overflow', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SustainabilityAnalysisScreen(
              initialMaterialId: 'mat_poly_ldpe_01',
              foodCommodityName: 'Potato Chips',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SustainabilityAnalysisScreen), findsOneWidget);
        expect(find.byType(SustainabilityProfileHeroCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
