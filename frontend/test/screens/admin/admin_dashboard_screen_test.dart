import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/screens/admin/admin_dashboard_screen.dart';
import 'package:ai_packaging_recommender/services/admin_api_service.dart';

import 'package:ai_packaging_recommender/services/auth_service.dart';

void main() {
  Widget createTestScreen({AdminApiService? apiService, Size size = const Size(1200, 900)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: AdminDashboardScreen(apiService: apiService),
      ),
    );
  }

  group('AdminDashboardScreen Master Tests', () {
    late AdminApiService mockService;

    setUp(() {
      AdminApiService.resetMockStore();
      final failingClient = MockClient((request) async => http.Response('Not Found', 404));
      mockService = AdminApiService(client: failingClient); // Uses full offline mock fallback
      AuthService().authenticateAdminPasskey('Admin@2026');
    });

    testWidgets('renders top header, role badge, and 4 tabs with initial analytics data', (tester) async {
      await tester.pumpWidget(createTestScreen(apiService: mockService));
      await tester.pumpAndSettle();

      // Top Header
      expect(find.text('Admin Console'), findsOneWidget);
      expect(find.text('SuperAdmin Role'), findsOneWidget);

      // Tabs
      expect(find.text('Analytics & Trends'), findsOneWidget);
      expect(find.text('Food Commodities'), findsOneWidget);
      expect(find.text('Packaging Materials'), findsOneWidget);
      expect(find.text('Rules & AI Governance'), findsOneWidget);

      // Analytics Tab default content
      expect(find.text('Total Analyses Run'), findsOneWidget);
      expect(find.text('Eco Adoption Rate'), findsOneWidget);
      expect(find.text('Active Food Database'), findsOneWidget);
      expect(find.text('Barrier Material Matrix'), findsOneWidget);
      expect(find.text('30-Day Analysis & Eco-Optimization Volume'), findsOneWidget);
      expect(find.text('Most Searched Foods'), findsOneWidget);
    });

    testWidgets('can switch to Food Commodities tab and view table with actions', (tester) async {
      await tester.pumpWidget(createTestScreen(apiService: mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Food Commodities'));
      await tester.pumpAndSettle();

      expect(find.text('Add Commodity'), findsOneWidget);
      expect(find.text('Fresh Tomato'), findsOneWidget);
      expect(find.text('Fresh Apple'), findsOneWidget);
      expect(find.text('Potato Chips'), findsOneWidget);
    });

    testWidgets('can switch to Packaging Materials tab and view substrate entries', (tester) async {
      await tester.pumpWidget(createTestScreen(apiService: mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Packaging Materials'));
      await tester.pumpAndSettle();

      expect(find.text('Add Material'), findsOneWidget);
      expect(find.text('Micro-Perforated Bio-Film (PLA/PBAT)'), findsOneWidget);
      expect(find.text('Corrugated Kraft Box (5-Ply)'), findsOneWidget);
    });

    testWidgets('can switch to Rules & AI Governance tab and view model registry & audit stream', (tester) async {
      await tester.pumpWidget(createTestScreen(apiService: mockService));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Rules & AI Governance'));
      await tester.tap(find.text('Rules & AI Governance'));
      await tester.pumpAndSettle();

      expect(find.text('AI Model Registry & Engine'), findsOneWidget);
      expect(find.text('RandomForest-v2.3-18D'), findsOneWidget);
      expect(find.text('Scientific Rule Thresholds'), findsOneWidget);
      expect(find.text('System Recommendation Audit Stream'), findsOneWidget);
      expect(find.text('Fresh Tomato'), findsOneWidget);
    });

    testWidgets('refresh button reloads datasets smoothly', (tester) async {
      await tester.pumpWidget(createTestScreen(apiService: mockService));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Admin Console'), findsOneWidget);
    });

    testWidgets('unauthorized user sees Admin Security Gate and can unlock with passkey', (tester) async {
      AuthService().activateDemoMode(); // standard non-admin demo user
      await tester.pumpWidget(createTestScreen(apiService: mockService));
      await tester.pumpAndSettle();

      expect(find.text('Administrative Security Gate'), findsOneWidget);
      expect(find.byKey(const Key('admin_lock_passkey_input')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('admin_lock_passkey_input')), 'Admin@2026');
      await tester.tap(find.byKey(const Key('admin_lock_verify_button')));
      await tester.pumpAndSettle();

      expect(find.text('Admin Console'), findsOneWidget);
    });
  });
}
