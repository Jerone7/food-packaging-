import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/materials/packaging_catalog_screen.dart';
import 'package:ai_packaging_recommender/screens/materials/widgets/material_filter_bar.dart';
import 'package:ai_packaging_recommender/screens/reports/recommendation_report_screen.dart';
import 'package:ai_packaging_recommender/screens/reports/widgets/report_header_card.dart';
import 'package:ai_packaging_recommender/screens/reports/widgets/report_action_toolbar.dart';
import 'package:ai_packaging_recommender/theme/app_theme.dart';

void main() {
  group('Polymer Catalog & Recommendation Report Multi-Viewport Responsive Audit', () {
    // -------------------------------------------------------------------------
    // 1. PackagingCatalogScreen Responsive Audit
    // -------------------------------------------------------------------------
    group('PackagingCatalogScreen Viewport Adaptability', () {
      testWidgets('Desktop Viewport (1440x900) renders multi-column catalog grid without overflow', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
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
        expect(find.byType(MaterialFilterBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Laptop Viewport (1024x768) renders balanced catalog grid cleanly', (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
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
        expect(find.byType(MaterialFilterBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Tablet Viewport (768x1024) renders 2-column catalog layout cleanly', (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
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
        expect(find.byType(MaterialFilterBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Mobile Viewport (375x812) renders single-column catalog without overflow', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
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
        expect(find.byType(MaterialFilterBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // 2. RecommendationReportScreen Responsive Audit
    // -------------------------------------------------------------------------
    group('RecommendationReportScreen Viewport Adaptability', () {
      testWidgets('Desktop Viewport (1440x900) renders full specification report and export toolbar', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
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
        expect(find.byType(ReportActionToolbar), findsOneWidget);
        expect(find.byType(ReportHeaderCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Tablet Viewport (768x1024) renders scrollable report cards cleanly', (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
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
        expect(find.byType(ReportActionToolbar), findsOneWidget);
        expect(find.byType(ReportHeaderCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Mobile Viewport (375x812) renders single-column specification stream without overflow', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
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
        expect(find.byType(ReportActionToolbar), findsOneWidget);
        expect(find.byType(ReportHeaderCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
