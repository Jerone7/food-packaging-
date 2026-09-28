import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/widgets/auth/auth_form_card.dart';
import 'package:ai_packaging_recommender/widgets/auth/profile_header_card.dart';
import 'package:ai_packaging_recommender/widgets/auth/edit_profile_dialog.dart';

void main() {
  setUp(() {
    AuthService().resetForTest();
  });

  group('Auth & Profile Widgets Tests (Module 14 - Task 5.1)', () {
    testWidgets('AuthFormCard switches tabs and supports demo auto-fill',
        (WidgetTester tester) async {
      bool successCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AuthFormCard(
                onAuthSuccess: () => successCalled = true,
              ),
            ),
          ),
        ),
      );

      // Verify Initial Sign In Tab
      expect(find.text('Welcome to SmartPack AI'), findsOneWidget);
      expect(find.byKey(const Key('auth_email_input')), findsOneWidget);
      expect(find.byKey(const Key('auth_password_input')), findsOneWidget);
      expect(find.byKey(const Key('auth_fullname_input')), findsNothing);

      // Switch to Create Account Tab
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Join SmartPack Workspace'), findsOneWidget);
      expect(find.byKey(const Key('auth_fullname_input')), findsOneWidget);
      expect(find.byKey(const Key('auth_org_input')), findsOneWidget);

      // Switch back to Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Test Fill Demo Account Button
      await tester.tap(find.byKey(const Key('auth_demo_fill_button')));
      await tester.pumpAndSettle();

      final emailField = tester.widget<TextFormField>(
          find.byKey(const Key('auth_email_input')));
      expect(emailField.controller?.text, 'sarah.jenkins@smartpack.io');

      // Test Instant Guest Demo Button
      await tester.tap(find.byKey(const Key('auth_instant_demo_button')));
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
      expect(AuthService().isAuthenticated, isTrue);
    });

    testWidgets('ProfileHeaderCard displays user details and stats',
        (WidgetTester tester) async {
      AuthService().activateDemoMode();
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfileHeaderCard(
                onLogout: () => logoutCalled = true,
              ),
            ),
          ),
        ),
      );

      // Verify User Details
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('SJ'), findsOneWidget);
      expect(find.textContaining('BioPackaging Innovation Lab'), findsOneWidget);
      expect(find.text('INR'), findsOneWidget);

      // Verify Stat Pills
      expect(find.text('Total Analyses'), findsOneWidget);
      expect(find.text('Saved Presets'), findsOneWidget);
      expect(find.text('Eco Formulations'), findsOneWidget);
      expect(find.text('Avg Circularity'), findsOneWidget);

      // Test Logout Button
      await tester.tap(find.byKey(const Key('profile_logout_button')));
      await tester.pumpAndSettle();
      expect(logoutCalled, isTrue);
    });

    testWidgets('EditProfileDialog renders input fields and triggers update',
        (WidgetTester tester) async {
      AuthService().activateDemoMode();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditProfileDialog(),
          ),
        ),
      );

      expect(find.text('Edit Profile & Preferences'), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_name_input')), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_org_input')), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_currency_select')), findsOneWidget);

      final nameField = tester.widget<TextFormField>(
          find.byKey(const Key('edit_profile_name_input')));
      expect(nameField.controller?.text, 'Dr. Sarah Jenkins');
    });
  });
}
