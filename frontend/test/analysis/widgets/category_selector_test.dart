import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/category_selector.dart';

void main() {
  group('CategorySelector Widget Tests', () {
    testWidgets('renders all 7 categories and triggers selection callback', (WidgetTester tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: null,
              onSelectCategory: (cat) => selected = cat,
            ),
          ),
        ),
      );

      // Verify all 7 categories exist
      expect(find.text('Fruits'), findsOneWidget);
      expect(find.text('Vegetables'), findsOneWidget);
      expect(find.text('Grains'), findsOneWidget);
      expect(find.text('Dairy'), findsOneWidget);
      expect(find.text('Meat'), findsOneWidget);
      expect(find.text('Bakery'), findsOneWidget);
      expect(find.text('Other perishables'), findsOneWidget);

      // Tap on 'Fruits'
      await tester.tap(find.text('Fruits'));
      await tester.pumpAndSettle();
      expect(selected, 'Fruits');
    });

    testWidgets('displays "View All" button when category is selected', (WidgetTester tester) async {
      String? selected = 'Dairy';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: selected,
              onSelectCategory: (cat) => selected = cat,
            ),
          ),
        ),
      );

      expect(find.text('View All'), findsOneWidget);
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();
      expect(selected, isNull);
    });
  });
}
