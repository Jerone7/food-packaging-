import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/benefits_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    await LocaleService().init();
    await AppTranslations.load('en');
  });

  group('BenefitsSection Widget Tests', () {
    testWidgets('renders all 4 benefit cards and section header', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BenefitsSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Engineered for the Entire Packaging Supply Chain'), findsWidgets);
      expect(find.text('Zero Spoilage & Extended Shelf-Life'), findsOneWidget);
      expect(find.text('Verified Carbon & Water Footprints'), findsOneWidget);
      expect(find.text('Converter-Level Unit Economics'), findsOneWidget);
      expect(find.text('Zero-Latency Offline Parity'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.byIcon(Icons.compost_rounded), findsOneWidget);
      expect(find.byIcon(Icons.aspect_ratio_rounded), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });
  });
}
