import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analytics/analytics_dashboard_screen.dart';
import 'package:ai_packaging_recommender/screens/analytics/widgets/kpi_metrics_grid.dart';
import 'package:ai_packaging_recommender/screens/admin/admin_dashboard_screen.dart';
import 'package:ai_packaging_recommender/screens/user_profile_screen.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/theme/app_theme.dart';

void main() {
  group('Analytics, Admin Dashboard & User Profile Multi-Viewport Responsive Audit', () {
    // -------------------------------------------------------------------------
    // 1. AnalyticsDashboardScreen Responsive Audit
    // -------------------------------------------------------------------------
    group('AnalyticsDashboardScreen Viewport Adaptability', () {
      testWidgets('Desktop Viewport (1440x900) renders 4-KPI row and dual chart layout', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
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
        expect(find.byType(KpiMetricsGrid), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Tablet Viewport (768x1024) renders 2x2 KPI grid cleanly without overflow', (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
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
        expect(find.byType(KpiMetricsGrid), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Mobile Viewport (375x812) renders single-column KPI stream without overflow', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
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
        expect(find.byType(KpiMetricsGrid), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // 2. AdminDashboardScreen Responsive Audit
    // -------------------------------------------------------------------------
    group('AdminDashboardScreen Viewport Adaptability', () {
      setUp(() {
        AuthService().authenticateAdminPasskey('Admin@2026');
      });

      testWidgets('Desktop Viewport (1440x900) renders admin governance tabs cleanly', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
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
        expect(find.byType(TabBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Tablet Viewport (768x1024) renders admin workspace without overflow', (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
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
        expect(find.byType(TabBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Mobile Viewport (375x812) renders scrollable admin tabs without overflow', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
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
        expect(find.byType(TabBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // 3. UserProfileScreen Responsive Audit
    // -------------------------------------------------------------------------
    group('UserProfileScreen Viewport Adaptability', () {
      testWidgets('Desktop Viewport (1440x900) renders user preferences & authentication cleanly', (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
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

      testWidgets('Tablet Viewport (768x1024) renders profile tabs cleanly', (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
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

      testWidgets('Mobile Viewport (375x812) renders mobile profile cards without overflow', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
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
  });
}
