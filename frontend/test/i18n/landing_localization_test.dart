import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/landing/home_page.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/home_header.dart';
import 'package:ai_packaging_recommender/widgets/navigation/language_selector_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    final localeService = LocaleService();
    await localeService.init();
    await AppTranslations.load('en');
  });

  tearDown(() {
    AppTranslations.resetCache();
  });

  Widget buildLandingHarness({Size size = const Size(1280, 900)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: const HomePage(),
      ),
    );
  }

  group('Landing Hub Dynamic Localization Tests (Task 4.1)', () {
    testWidgets('Renders HomeHeader with embedded LanguageSelectorWidget', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildLandingHarness());
      await tester.pumpAndSettle();

      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.byType(LanguageSelectorWidget), findsWidgets);
    });

    testWidgets('Header navigation links render in English by default', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildLandingHarness());
      await tester.pumpAndSettle();

      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Benefits'), findsOneWidget);
      expect(find.text('Launch Analysis'), findsWidgets);
    });

    testWidgets('Dynamic switch to Tamil (ta) updates Landing Hub in real-time', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildLandingHarness());
      await tester.pumpAndSettle();

      // Switch to Tamil
      await LocaleService().changeLocale('ta');
      await tester.pumpAndSettle();

      // Navigation links should now display Tamil
      expect(find.text('செயல்முறை'), findsOneWidget);
      expect(find.text('நன்மைகள்'), findsOneWidget);
      expect(find.text('ஆய்வைத் தொடங்கு'), findsWidgets);
    });

    testWidgets('Dynamic switch to Hindi (hi) updates Landing Hub in real-time', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildLandingHarness());
      await tester.pumpAndSettle();

      // Switch to Hindi
      await LocaleService().changeLocale('hi');
      await tester.pumpAndSettle();

      // Navigation links and CTA buttons should now display Hindi
      expect(find.text('कार्यप्रणाली'), findsOneWidget);
      expect(find.text('लाभ'), findsOneWidget);
      expect(find.text('विश्लेषण शुरू करें'), findsWidgets);
    });
  });
}
