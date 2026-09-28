import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/screens/user_profile_screen.dart';

void main() {
  setUp(() {
    AuthService().resetForTest();
    LocaleService().initForTesting(languageCode: 'en');
  });

  group('UserProfileScreen Screen Tests (Module 14 - Task 6.1)', () {
    testWidgets('Renders unauthenticated prompt and login card when logged out',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );

      expect(find.text('SmartPack Engineering Workspace'), findsOneWidget);
      expect(find.text('Welcome to SmartPack AI'), findsOneWidget);
      expect(find.byKey(const Key('auth_email_input')), findsOneWidget);
      expect(find.byKey(const Key('auth_password_input')), findsOneWidget);
    });

    testWidgets('Renders full profile dashboard and tabs when authenticated',
        (WidgetTester tester) async {
      AuthService().activateDemoMode();

      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header and Demo Mode tag
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('Demo Mode'), findsOneWidget);

      // Verify Navigation Tabs
      expect(find.text('Saved Presets (2)'), findsOneWidget);
      expect(find.textContaining('Analysis History'), findsWidgets);
      expect(find.text('Preferences'), findsOneWidget);

      // Tab 0: Saved Presets are visible
      expect(find.text('Organic Strawberries Cold-Chain MAP'), findsOneWidget);
      expect(find.text('Fresh Tomato Ambient Distribution'), findsOneWidget);

      // Switch to Tab 1: Analysis History
      await tester.tap(find.textContaining('Analysis History'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Fresh Strawberries'), findsOneWidget);

      // Switch to Tab 2: Preferences
      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();

      expect(find.text('Engineering Defaults & Workspace Bias'), findsOneWidget);
      expect(find.byKey(const Key('workspace_pref_currency_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('workspace_pref_batch_input')), findsOneWidget);
      expect(find.byKey(const Key('workspace_pref_eco_switch')), findsOneWidget);
      expect(find.byKey(const Key('workspace_pref_save_button')), findsOneWidget);

      // Test Saving Preferences
      await tester.ensureVisible(find.byKey(const Key('workspace_pref_save_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('workspace_pref_save_button')));
      await tester.pumpAndSettle();

      expect(find.text('Workspace preferences updated successfully!'), findsOneWidget);
    });
  });
}
