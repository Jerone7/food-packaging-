import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analysis/food_analysis_screen.dart';
import 'package:ai_packaging_recommender/screens/comparison/packaging_comparison_screen.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/comparison_parameter_table.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/material_selector_strip.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/comparative_radar_view.dart';
import 'package:ai_packaging_recommender/theme/app_theme.dart';

void main() {
  group('Food Analysis & Packaging Comparison Multi-Viewport Responsive Audit', () {
    // -------------------------------------------------------------------------
    // 1. FoodAnalysisScreen Responsive Audit
    // -------------------------------------------------------------------------
    group('FoodAnalysisScreen Viewport Adaptability', () {
      testWidgets('Desktop Viewport (1440x900) renders 2-column layout without overflow', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FoodAnalysisScreen(
              initialFoodName: 'Fresh Strawberries',
              initialCategory: 'Fruits & Berries',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FoodAnalysisScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Laptop Viewport (1024x768) renders cleanly without overflow', (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FoodAnalysisScreen(
              initialFoodName: 'Potato Chips',
              initialCategory: 'Snack Foods',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FoodAnalysisScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Tablet Viewport (768x1024) renders single-column stacked layout cleanly', (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FoodAnalysisScreen(
              initialFoodName: 'Fresh Strawberries',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FoodAnalysisScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Mobile Viewport (375x812) renders scrollable single-column layout without overflow', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FoodAnalysisScreen(
              initialFoodName: 'Fresh Strawberries',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FoodAnalysisScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // 2. PackagingComparisonScreen Responsive Audit
    // -------------------------------------------------------------------------
    group('PackagingComparisonScreen Viewport Adaptability', () {
      testWidgets('Desktop Viewport (1440x900) renders side-by-side workspace and radar chart', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PackagingComparisonScreen(
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
        expect(find.byType(ComparativeRadarView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Tablet Viewport (768x1024) renders stacked comparison table and radar cleanly', (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PackagingComparisonScreen(
              initialMaterialIds: ['mat_bio_emap_01', 'mat_al_foil_lam_13'],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PackagingComparisonScreen), findsOneWidget);
        expect(find.byType(MaterialSelectorStrip), findsOneWidget);
        expect(find.byType(ComparisonParameterTable), findsOneWidget);
        expect(find.byType(ComparativeRadarView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Mobile Viewport (375x812) renders responsive card layouts with horizontal table scrolling', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PackagingComparisonScreen(
              initialMaterialIds: ['mat_bio_emap_01', 'mat_al_foil_lam_13', 'mat_pp_clamshell_06'],
              foodName: 'Crisp Potato Chips',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PackagingComparisonScreen), findsOneWidget);
        expect(find.byType(MaterialSelectorStrip), findsOneWidget);
        expect(find.byType(ComparisonParameterTable), findsOneWidget);
        expect(find.byType(ComparativeRadarView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
