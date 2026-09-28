import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/user_model.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/home_header.dart';
import 'package:ai_packaging_recommender/screens/user_profile_screen.dart';
import 'package:ai_packaging_recommender/screens/admin/admin_dashboard_screen.dart';

void main() {
  setUp(() {
    AuthService().resetForTest();
  });

  group('Admin Navigation Flow Tests (Task 5.2)', () {
    testWidgets('HomeHeader shows Admin button for Admin user and triggers navigation', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool adminNavigated = false;

      // Simulate logged-in Admin user
      final auth = AuthService();
      auth.currentUser = UserModel(
        id: 1,
        email: 'admin@smartpack.io',
        fullName: 'Chief Scientist',
        role: 'admin',
        isAdmin: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Scaffold(
              appBar: HomeHeader(
                onStartAnalysis: () {},
                onOpenHistory: () {},
                onOpenAdmin: () => adminNavigated = true,
              ),
              body: const SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_header_admin_button')), findsOneWidget);
      expect(find.text('Admin ⚙️'), findsOneWidget);

      await tester.tap(find.byKey(const Key('home_header_admin_button')));
      expect(adminNavigated, true);
    });

    testWidgets('HomeHeader hides Admin button for non-admin regular user', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = AuthService();
      auth.currentUser = UserModel(
        id: 2,
        email: 'client@company.com',
        fullName: 'Packaging Engineer',
        role: 'user',
        isAdmin: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Scaffold(
              appBar: HomeHeader(
                onStartAnalysis: () {},
                onOpenHistory: () {},
                onOpenAdmin: () {},
              ),
              body: const SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_header_admin_button')), findsNothing);
    });

    testWidgets('UserProfileScreen displays Admin Console banner and opens AdminDashboardScreen', (tester) async {
      final auth = AuthService();
      auth.currentUser = UserModel(
        id: 1,
        email: 'admin@smartpack.io',
        fullName: 'Dr. Admin',
        role: 'admin',
        isAdmin: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('System Administration Console'), findsOneWidget);
      expect(find.byKey(const Key('user_profile_admin_console_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('user_profile_admin_console_button')));
      await tester.pumpAndSettle();

      // Verified transition to AdminDashboardScreen
      expect(find.byType(AdminDashboardScreen), findsOneWidget);
      expect(find.text('SuperAdmin Role'), findsOneWidget);
    });
  });
}
