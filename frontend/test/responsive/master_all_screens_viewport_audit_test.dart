import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/landing/home_page.dart';
import 'package:ai_packaging_recommender/screens/analysis/food_analysis_screen.dart';
import 'package:ai_packaging_recommender/screens/comparison/packaging_comparison_screen.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/cost_estimation_screen.dart';
import 'package:ai_packaging_recommender/screens/sustainability/sustainability_analysis_screen.dart';
import 'package:ai_packaging_recommender/screens/materials/packaging_catalog_screen.dart';
import 'package:ai_packaging_recommender/screens/reports/recommendation_report_screen.dart';
import 'package:ai_packaging_recommender/screens/analytics/analytics_dashboard_screen.dart';
import 'package:ai_packaging_recommender/screens/admin/admin_dashboard_screen.dart';
import 'package:ai_packaging_recommender/screens/user_profile_screen.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/theme/app_theme.dart';

void main() {
  const viewports = <String, Size>{
    'Widescreen Desktop (1920x1080)': Size(1920, 1080),
    'Standard Desktop (1280x800)': Size(1280, 800),
    'Small Laptop (1024x768)': Size(1024, 768),
    'Tablet (768x1024)': Size(768, 1024),
    'Mobile (375x812)': Size(375, 812),
  };

  group('Master 5-Viewport Multi-Device Responsive Audit (50 Permutations)', () {
    setUp(() {
      AuthService().authenticateAdminPasskey('Admin@2026');
    });

    for (final entry in viewports.entries) {
      final viewportName = entry.key;
      final size = entry.value;

      group('Viewport: $viewportName', () {
        testWidgets('1. HomePage builds cleanly', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: const HomePage(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(HomePage), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('2. FoodAnalysisScreen builds cleanly', (tester) async {
          tester.view.physicalSize = size;
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

        testWidgets('3. PackagingComparisonScreen builds cleanly', (tester) async {
          tester.view.physicalSize = size;
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
                foodName: 'Potato Chips',
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(PackagingComparisonScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('4. CostEstimationScreen builds cleanly', (tester) async {
          tester.view.physicalSize = size;
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
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(CostEstimationScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('5. SustainabilityAnalysisScreen builds cleanly', (tester) async {
          tester.view.physicalSize = size;
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
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(SustainabilityAnalysisScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('6. PackagingCatalogScreen builds cleanly', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: const PackagingCatalogScreen(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(PackagingCatalogScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('7. RecommendationReportScreen builds cleanly', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: const RecommendationReportScreen(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(RecommendationReportScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('8. AnalyticsDashboardScreen builds cleanly', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: const AnalyticsDashboardScreen(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(AnalyticsDashboardScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('9. AdminDashboardScreen builds cleanly', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: const AdminDashboardScreen(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(AdminDashboardScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('10. UserProfileScreen builds cleanly', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: const UserProfileScreen(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(UserProfileScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
