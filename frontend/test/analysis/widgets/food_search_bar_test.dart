import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_commodity.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/food_search_bar.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/add_food_dialog.dart';

void main() {
  group('FoodSearchBar Widget Tests', () {
    testWidgets('renders search input and triggers autocomplete on text entry', (WidgetTester tester) async {
      FoodCommodity? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodSearchBar(
              onSelectFood: (f) => selected = f,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.text('Manual Entry'), findsOneWidget);

      // Tap and enter search query
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Chips');
      await tester.pumpAndSettle();

      // Tap on search suggestion
      expect(find.text('Fried Potato Chips'), findsOneWidget);
      await tester.tap(find.text('Fried Potato Chips'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.name, 'Fried Potato Chips');
    });

    testWidgets('displays manual entry prompt when query does not match any commodity', (WidgetTester tester) async {
      FoodCommodity? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodSearchBar(
              onSelectFood: (f) => selected = f,
            ),
          ),
        ),
      );

      // Enter unknown food query
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Exotic Dragonfruit');
      await tester.pumpAndSettle();

      expect(find.textContaining('No food commodity found matching "Exotic Dragonfruit"'), findsOneWidget);
      expect(find.text('Add "Exotic Dragonfruit" as Manual Entry'), findsOneWidget);

      // Tap to open manual entry dialog
      await tester.tap(find.text('Add "Exotic Dragonfruit" as Manual Entry'));
      await tester.pumpAndSettle();

      expect(find.byType(AddFoodDialog), findsOneWidget);
      expect(find.text('Add Manual Food Commodity'), findsOneWidget);
      expect(find.text('Exotic Dragonfruit'), findsWidgets);

      // Tap Save & Select Product
      await tester.tap(find.text('Save & Select Product'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.name, 'Exotic Dragonfruit');
    });

    testWidgets('tapping header Manual Entry button opens AddFoodDialog directly', (WidgetTester tester) async {
      FoodCommodity? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodSearchBar(
              onSelectFood: (f) => selected = f,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Manual Entry'));
      await tester.pumpAndSettle();

      expect(find.byType(AddFoodDialog), findsOneWidget);
    });
  });
}
