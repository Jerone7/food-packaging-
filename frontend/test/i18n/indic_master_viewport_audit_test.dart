/// Master Indic 5-Viewport Multi-Device Layout Audit (Task 5.1)
///
/// 10 core screens × 2 Indic languages (ta, hi) × 5 viewports = 100 permutations.
/// Asserts exact 0 RenderFlex overflow errors despite Indic character length
/// expansions (+15%–25%).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';

// ── Screen imports ──────────────────────────────────────────────────────────
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

// ── Viewport definitions ────────────────────────────────────────────────────
const _viewports = <String, Size>{
  'Widescreen Desktop (1920×1080)': Size(1920, 1080),
  'Standard Desktop (1280×800)': Size(1280, 800),
  'Small Laptop (1024×768)': Size(1024, 768),
  'Tablet (768×1024)': Size(768, 1024),
  'Mobile (375×812)': Size(375, 812),
};

// ── Language codes under test ───────────────────────────────────────────────
const _languages = <String, String>{
  'ta': 'Tamil',
  'hi': 'Hindi',
};

// ── Screen builder definitions ──────────────────────────────────────────────
/// Each entry: [screenName, widgetBuilder, requiresAuth]
final _screens = <_ScreenEntry>[
  _ScreenEntry('HomePage (Landing)', () => const HomePage(), false),
  _ScreenEntry('FoodAnalysisScreen', () => const FoodAnalysisScreen(), false),
  _ScreenEntry('PackagingComparisonScreen', () => const PackagingComparisonScreen(), false),
  _ScreenEntry('CostEstimationScreen', () => const CostEstimationScreen(), false),
  _ScreenEntry('SustainabilityAnalysisScreen', () => const SustainabilityAnalysisScreen(), false),
  _ScreenEntry('PackagingCatalogScreen', () => const PackagingCatalogScreen(), false),
  _ScreenEntry('RecommendationReportScreen', () => const RecommendationReportScreen(), false),
  _ScreenEntry('AnalyticsDashboardScreen', () => const AnalyticsDashboardScreen(), true),
  _ScreenEntry('AdminDashboardScreen', () => const AdminDashboardScreen(), true),
  _ScreenEntry('UserProfileScreen', () => const UserProfileScreen(), true),
];

class _ScreenEntry {
  final String name;
  final Widget Function() builder;
  final bool requiresAuth;
  const _ScreenEntry(this.name, this.builder, this.requiresAuth);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    await AppTranslations.load('en');
    await AppTranslations.load('ta');
    await AppTranslations.load('hi');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    AuthService().activateDemoMode();
    await LocaleService().changeLocale('en');
  });

  // Generate tests for each language × screen × viewport
  for (final langEntry in _languages.entries) {
    final langCode = langEntry.key;
    final langName = langEntry.value;

    group('Indic Viewport Audit – $langName ($langCode)', () {
      for (final screen in _screens) {
        for (final vpEntry in _viewports.entries) {
          final vpLabel = vpEntry.key;
          final vpSize = vpEntry.value;

          testWidgets(
            '${screen.name} @ $vpLabel – zero overflow',
            (tester) async {
              // Configure viewport
              tester.view.physicalSize = vpSize;
              tester.view.devicePixelRatio = 1.0;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);

              // Auth setup for screens that require it
              if (screen.requiresAuth) {
                AuthService().activateDemoMode();
              }

              // Switch locale before rendering. Use changeLocaleForTesting to
              // bypass SharedPreferences I/O (which hangs in widget test env).
              // Translations are pre-cached in setUpAll so this is instant.
              LocaleService().changeLocaleForTesting(
                languageCode: langCode,
                primaryDict: AppTranslations.getCached(langCode) ?? {},
                fallbackDict: AppTranslations.getCached('en') ?? {},
              );

              // Build widget
              await tester.pumpWidget(
                MaterialApp(home: screen.builder()),
              );
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 250));
              await tester.pump(const Duration(milliseconds: 250));

              // Assert zero overflow errors
              expect(tester.takeException(), isNull,
                reason: '${screen.name} overflowed at $vpLabel in $langName ($langCode)');

              await tester.pumpWidget(const SizedBox());
            },
          );
        }
      }
    });
  }
}
