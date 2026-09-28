import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/food_preview_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    await LocaleService().init();
    await AppTranslations.load('en');
  });

  group('FoodPreviewSection Widget Tests', () {
    testWidgets('renders category preview section title and default categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodPreviewSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify section header and categories
      expect(find.text('Supported Food Commodity Presets'), findsWidgets);
      expect(find.text('Snacks & Wafers'), findsOneWidget);
      expect(find.text('Biscuits & Bakery'), findsOneWidget);
    });

    testWidgets('executes onSelectCategory callback on card tap', (WidgetTester tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodPreviewSection(
                onSelectCategory: (cat) => selected = cat,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Snacks & Wafers'));
      await tester.pumpAndSettle();
      expect(selected, 'Snacks & Wafers');
    });
  });
}
