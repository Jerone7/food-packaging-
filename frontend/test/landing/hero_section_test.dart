import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/hero_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    await LocaleService().init();
    await AppTranslations.load('en');
  });

  group('HeroSection Widget Tests', () {
    testWidgets('renders headline, feature badges, and sample recommendation card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HeroSection(
                onStartAnalysis: () {},
                onExploreCommodities: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Smart, Sustainable'), findsOneWidget);
      expect(find.text('Eco-Friendly Polymer Matching'), findsOneWidget);
      expect(find.text('540+ IFCT 2017 Food Database'), findsOneWidget);
      expect(find.text('Launch Analysis'), findsOneWidget);
      expect(find.text('Explore Polymer Catalog'), findsOneWidget);
      expect(find.text('Live Analysis Sample'), findsOneWidget);
      expect(find.text('Score: 94/100'), findsOneWidget);
    });

    testWidgets('executes onStartAnalysis and onExploreCommodities callbacks', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool startTapped = false;
      bool exploreTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HeroSection(
                onStartAnalysis: () => startTapped = true,
                onExploreCommodities: () => exploreTapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Launch Analysis'));
      await tester.tap(find.text('Launch Analysis'));
      await tester.pumpAndSettle();
      expect(startTapped, isTrue);

      await tester.ensureVisible(find.text('Explore Polymer Catalog'));
      await tester.tap(find.text('Explore Polymer Catalog'));
      await tester.pumpAndSettle();
      expect(exploreTapped, isTrue);
    });
  });
}
