import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/screens/admin/admin_dashboard_screen.dart';
import 'package:ai_packaging_recommender/services/admin_api_service.dart';

import 'package:ai_packaging_recommender/services/auth_service.dart';

void main() {
  late AdminApiService mockService;

  setUp(() {
    AdminApiService.resetMockStore();
    final failingClient = MockClient((request) async => http.Response('Not Found', 404));
    mockService = AdminApiService(client: failingClient);
    AuthService().authenticateAdminPasskey('Admin@2026');
  });

  Widget buildViewportHarness({required Size size}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: AdminDashboardScreen(apiService: mockService),
        ),
      ),
    );
  }

  group('Admin Multi-Viewport Responsive Layout Audit (Phase 6, Task 6.1)', () {
    testWidgets('Mobile Viewport (375x812) renders all 4 tabs with 0 RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildViewportHarness(size: const Size(375, 812)));
      await tester.pumpAndSettle();

      // Tab 1: Analytics
      expect(find.text('Admin Console'), findsOneWidget);
      expect(find.text('Total Analyses Run'), findsOneWidget);

      // Tab 2: Food Commodities
      await tester.ensureVisible(find.text('Food Commodities'));
      await tester.tap(find.text('Food Commodities'));
      await tester.pumpAndSettle();
      expect(find.text('Add Commodity'), findsOneWidget);

      // Tab 3: Packaging Materials
      await tester.ensureVisible(find.text('Packaging Materials'));
      await tester.tap(find.text('Packaging Materials'));
      await tester.pumpAndSettle();
      expect(find.text('Add Material'), findsOneWidget);

      // Tab 4: Rules & AI Governance
      await tester.ensureVisible(find.text('Rules & AI Governance'));
      await tester.tap(find.text('Rules & AI Governance'));
      await tester.pumpAndSettle();
      expect(find.text('AI Model Registry & Engine'), findsOneWidget);
    });

    testWidgets('Tablet Viewport (768x1024) renders all 4 tabs with 0 RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildViewportHarness(size: const Size(768, 1024)));
      await tester.pumpAndSettle();

      // Tab 1: Analytics
      expect(find.text('Admin Console'), findsOneWidget);
      expect(find.text('Total Analyses Run'), findsOneWidget);

      // Tab 2: Food Commodities
      await tester.ensureVisible(find.text('Food Commodities'));
      await tester.tap(find.text('Food Commodities'));
      await tester.pumpAndSettle();
      expect(find.text('Add Commodity'), findsOneWidget);

      // Tab 3: Packaging Materials
      await tester.ensureVisible(find.text('Packaging Materials'));
      await tester.tap(find.text('Packaging Materials'));
      await tester.pumpAndSettle();
      expect(find.text('Add Material'), findsOneWidget);

      // Tab 4: Rules & AI Governance
      await tester.ensureVisible(find.text('Rules & AI Governance'));
      await tester.tap(find.text('Rules & AI Governance'));
      await tester.pumpAndSettle();
      expect(find.text('AI Model Registry & Engine'), findsOneWidget);
    });

    testWidgets('Desktop Viewport (1440x900) renders full widescreen cockpit with 0 RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildViewportHarness(size: const Size(1440, 900)));
      await tester.pumpAndSettle();

      // Tab 1: Analytics
      expect(find.text('Admin Console'), findsOneWidget);
      expect(find.text('Total Analyses Run'), findsOneWidget);
      expect(find.text('Eco Adoption Rate'), findsOneWidget);

      // Tab 2: Food Commodities
      await tester.ensureVisible(find.text('Food Commodities'));
      await tester.tap(find.text('Food Commodities'));
      await tester.pumpAndSettle();
      expect(find.text('Add Commodity'), findsOneWidget);

      // Tab 3: Packaging Materials
      await tester.ensureVisible(find.text('Packaging Materials'));
      await tester.tap(find.text('Packaging Materials'));
      await tester.pumpAndSettle();
      expect(find.text('Add Material'), findsOneWidget);

      // Tab 4: Rules & AI Governance
      await tester.ensureVisible(find.text('Rules & AI Governance'));
      await tester.tap(find.text('Rules & AI Governance'));
      await tester.pumpAndSettle();
      expect(find.text('AI Model Registry & Engine'), findsOneWidget);
    });
  });
}
