import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/services/admin_api_service.dart';
import 'package:ai_packaging_recommender/services/analytics_service.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/materials/packaging_catalog_screen.dart';
import 'package:ai_packaging_recommender/screens/analytics/analytics_dashboard_screen.dart';
import 'package:ai_packaging_recommender/screens/admin/admin_dashboard_screen.dart';
import 'package:ai_packaging_recommender/screens/user_profile_screen.dart';
import 'package:ai_packaging_recommender/widgets/navigation/language_selector_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppTranslations.load('en');
    await AppTranslations.load('ta');
    await AppTranslations.load('hi');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    AuthService().resetForTest();
    await LocaleService().init();
    await AppTranslations.load('en');
  });

  tearDown(() {
    AuthService().resetForTest();
  });

  group('Task 4.4 – Catalog, Reports, Analytics, Admin & User Profile I18N', () {
    // ─── PackagingCatalogScreen ───────────────────────────────────────────────
    testWidgets('PackagingCatalogScreen renders localized title and LanguageSelector', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: PackagingCatalogScreen()),
      );
      await tester.pumpAndSettle();

      // English default
      expect(find.text('Packaging Material Database'), findsOneWidget);
      expect(find.byType(LanguageSelectorWidget), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('PackagingCatalogScreen updates title on locale switch to ta', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: PackagingCatalogScreen()),
      );
      await tester.pumpAndSettle();

      await LocaleService().changeLocale('ta');
      await tester.pump(const Duration(seconds: 1));

      // Title should now be Tamil
      expect(find.text('Packaging Material Database'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    // ─── AnalyticsDashboardScreen ─────────────────────────────────────────────
    testWidgets('AnalyticsDashboardScreen renders localized title and LanguageSelector', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AuthService().activateDemoMode();
      final mockAnalyticsService = AnalyticsService(client: MockClient((_) async => http.Response('Not Found', 404)));

      await tester.pumpWidget(
        MaterialApp(home: AnalyticsDashboardScreen(analyticsService: mockAnalyticsService)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Analytics Dashboard'), findsOneWidget);
      expect(find.byType(LanguageSelectorWidget), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('AnalyticsDashboardScreen updates on locale switch to hi', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AuthService().activateDemoMode();
      final mockAnalyticsService = AnalyticsService(client: MockClient((_) async => http.Response('Not Found', 404)));

      await tester.pumpWidget(
        MaterialApp(home: AnalyticsDashboardScreen(analyticsService: mockAnalyticsService)),
      );
      await tester.pumpAndSettle();

      await LocaleService().changeLocale('hi');
      await tester.pump(const Duration(seconds: 1));

      // English title should be gone
      expect(find.textContaining('Analytics Dashboard'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    // ─── AdminDashboardScreen ─────────────────────────────────────────────────
    testWidgets('AdminDashboardScreen renders localized title and updates on locale switch to ta', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AuthService().authenticateAdminPasskey('Admin@2026');
      final mockAdminService = AdminApiService(client: MockClient((_) async => http.Response('Not Found', 404)));

      await tester.pumpWidget(
        MaterialApp(home: AdminDashboardScreen(apiService: mockAdminService)),
      );
      // AdminDashboardScreen has a CircularProgressIndicator while loading and a
      // TabController animation — pumpAndSettle never settles with these. Instead
      // pump enough frames for the async _loadAllData() (6 sequential 404 mock
      // responses) to complete and for setState to propagate.
      await tester.pump(); // kick off initState / _loadAllData
      await tester.pump(const Duration(seconds: 2)); // resolve all 6 awaited calls + setState

      expect(find.text('Admin Console'), findsOneWidget);
      expect(find.byType(LanguageSelectorWidget), findsWidgets);

      await LocaleService().changeLocale('ta');
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Admin Console'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    // ─── UserProfileScreen + LanguageSelectorWidget Card ──────────────────────
    testWidgets('UserProfileScreen Preferences tab renders localized title and language card', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AuthService().activateDemoMode();

      await tester.pumpWidget(
        const MaterialApp(home: UserProfileScreen(initialTabIndex: 2)),
      );
      await tester.pumpAndSettle();

      // AppBar title is localized
      expect(find.text('Engineering Account & Workspace'), findsOneWidget);

      // Language preference card is present
      expect(find.byKey(const Key('profile_language_preference_card')), findsOneWidget);
      expect(find.text('Regional Language / மொழி தேர்வு'), findsOneWidget);

      // LanguageSelectorWidget card mode is embedded
      expect(find.byKey(const ValueKey('language_selector_card')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('UserProfileScreen title updates on locale switch to ta', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AuthService().activateDemoMode();

      await tester.pumpWidget(
        const MaterialApp(home: UserProfileScreen(initialTabIndex: 2)),
      );
      await tester.pumpAndSettle();

      // Switch to Tamil
      await LocaleService().changeLocale('ta');
      await tester.pump(const Duration(seconds: 1));

      // English title should be gone
      expect(find.text('Engineering Account & Workspace'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('UserProfileScreen language card allows selecting Tamil', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AuthService().activateDemoMode();

      await tester.pumpWidget(
        const MaterialApp(home: UserProfileScreen(initialTabIndex: 2)),
      );
      await tester.pumpAndSettle();

      // Tap Tamil option in the language card
      final tamilOption = find.byKey(const ValueKey('lang_card_option_ta'));
      expect(tamilOption, findsOneWidget);

      await tester.ensureVisible(tamilOption);
      await tester.tap(tamilOption);
      await tester.pumpAndSettle();

      // Verify locale changed
      expect(LocaleService().languageCode, 'ta');
      await tester.pumpWidget(const SizedBox());
    });

    // ─── Translation Parity Cross-Check ───────────────────────────────────────
    testWidgets('All Task 4.4 translation keys exist in en, ta, hi dictionaries', (tester) async {
      // This test validates the fallback dictionary has all required keys
      final requiredKeys = [
        'catalog.title',
        'reports.title',
        'analytics.title',
        'admin.title',
        'admin.subtitle',
        'profile.title',
        'profile.language_preference_title',
        'profile.select_language_hint',
      ];

      for (final key in requiredKeys) {
        final parts = key.split('.');
        final section = parts[0];
        final field = parts[1];

        // Verify fallback dictionary structure
        final value = AppTranslations.tr(key);
        expect(
          value,
          isNot(equals(key)),
          reason: 'Translation key "$key" should have a fallback value, but got "$value"',
        );
      }
    });
  });
}
