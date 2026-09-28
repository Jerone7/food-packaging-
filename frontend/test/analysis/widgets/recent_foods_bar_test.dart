import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_commodity.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/recent_foods_bar.dart';
import 'package:ai_packaging_recommender/services/recent_foods_service.dart';

void main() {
  setUp(() async {
    await RecentFoodsService.resetToDefaults();
  });

  group('RecentFoodsBar Widget Tests', () {
    testWidgets('renders recent food action chips and triggers selection', (WidgetTester tester) async {
      FoodCommodity? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentFoodsBar(
              onSelectRecent: (f) => selected = f,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recently Evaluated Foods'), findsOneWidget);
      expect(find.text('Fried Potato Chips'), findsOneWidget);

      await tester.tap(find.text('Fried Potato Chips'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.name, 'Fried Potato Chips');
    });
  });
}
