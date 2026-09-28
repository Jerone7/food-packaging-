import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_commodity.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_profile_card.dart';

void main() {
  group('FoodProfileCard Widget Tests', () {
    const testFood = FoodCommodity(
      id: 1,
      name: 'Fresh Apple',
      category: 'Fruits',
      scientificName: 'Malus domestica',
      moisture: 85.5,
      ph: 3.6,
      waterActivity: 0.98,
      fat: 0.2,
      respirationClass: 'Moderate',
      recommendedStorage: 'Refrigerated (2-4°C, 90-95% RH)',
    );

    testWidgets('renders food traits, category badge, and baseline gauges', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodProfileCard(
                food: testFood,
                currentProfile: testFood.toBiochemicalProfile(),
                onProfileChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Fresh Apple'), findsOneWidget);
      expect(find.text('Malus domestica'), findsOneWidget);
      expect(find.text('Fruits'), findsOneWidget);
      expect(find.text('85.5%'), findsOneWidget); // Moisture
      expect(find.text('3.6'), findsOneWidget);   // pH
      expect(find.text('Moderate'), findsOneWidget); // Respiration
    });

    testWidgets('expands customization accordion on click', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FoodProfileCard(
                food: testFood,
                currentProfile: testFood.toBiochemicalProfile(),
                onProfileChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Customize Biochemical Parameters (Optional)'), findsOneWidget);
      await tester.tap(find.text('Customize Biochemical Parameters (Optional)'));
      await tester.pumpAndSettle();

      expect(find.text('Moisture (%)'), findsOneWidget);
      expect(find.text('Fat (%)'), findsOneWidget);
      expect(find.text('pH'), findsOneWidget);
    });
  });
}
