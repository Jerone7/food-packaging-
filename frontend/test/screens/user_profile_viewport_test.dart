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

  group('UserProfileScreen Multi-Viewport Responsiveness & Zero-Overflow Audits (Module 14 - Task 6.3)', () {
    testWidgets('Mobile Viewport (375x812) - Unauthenticated & Authenticated Tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Unauthenticated mobile
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SmartPack Engineering Workspace'), findsOneWidget);
      expect(find.text('Welcome to SmartPack AI'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. Authenticated mobile
      AuthService().activateDemoMode();
      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 1: History on Mobile
      await tester.ensureVisible(find.textContaining('Analysis History'));
      await tester.tap(find.textContaining('Analysis History'));
      await tester.pumpAndSettle();
      expect(find.text('My Analyses'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 2: Preferences on Mobile
      await tester.ensureVisible(find.text('Preferences'));
      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();
      expect(find.text('Engineering Defaults & Workspace Bias'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tablet Viewport (768x1024) - Authenticated Workspace & Presets Grid',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthService().activateDemoMode();

      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('Organic Strawberries Cold-Chain MAP'), findsOneWidget);
      expect(find.text('Fresh Tomato Ambient Distribution'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Switch to Preferences
      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('workspace_pref_save_button')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Desktop Viewport (1440x900) - Full Widescreen Layout',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthService().activateDemoMode();

      await tester.pumpWidget(
        const MaterialApp(
          home: UserProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('Demo Mode'), findsOneWidget);
      expect(find.text('Saved Presets (2)'), findsOneWidget);
      expect(find.text('Total Analyses'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
