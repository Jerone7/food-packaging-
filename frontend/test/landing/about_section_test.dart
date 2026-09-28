import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/about_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    await LocaleService().init();
    await AppTranslations.load('en');
  });

  group('AboutSection Widget Tests', () {
    testWidgets('renders project mission, citations, tech badges, and footer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AboutSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SmartPack AI Mission & Citations'), findsWidgets);
      expect(find.text('Scientific Datasets & Citations'), findsOneWidget);
      expect(find.text('ICMR - National Institute of Nutrition'), findsOneWidget);
      expect(find.text('USDA FoodData Central & FAO'), findsOneWidget);
      expect(find.text('Flutter 3.x'), findsOneWidget);
      expect(find.text('FastAPI Async'), findsOneWidget);
      expect(find.text('PostgreSQL 16'), findsOneWidget);
      expect(find.textContaining('SmartPack AI. Developed for Agricultural & Industrial Packaging Sustainability'), findsOneWidget);
    });
  });
}
