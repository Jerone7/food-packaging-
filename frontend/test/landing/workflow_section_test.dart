import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_packaging_recommender/services/locale_service.dart';
import 'package:ai_packaging_recommender/theme/app_translations.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/workflow_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_selected_language': 'en'});
    await LocaleService().init();
    await AppTranslations.load('en');
  });

  group('WorkflowSection Widget Tests', () {
    testWidgets('renders section title and all steps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WorkflowSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scientific Packaging Prescription in 4 Steps'), findsWidgets);
      expect(find.text('1. Commodity Biochemistry'), findsOneWidget);
      expect(find.text('2. AI Barrier Matching'), findsOneWidget);
      expect(find.text('3. Converter Economics & LCA'), findsOneWidget);
      expect(find.text('01'), findsOneWidget);
      expect(find.text('02'), findsOneWidget);
      expect(find.text('03'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
      expect(find.byIcon(Icons.science_rounded), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    });
  });
}
