import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_commodity.dart';
import 'package:ai_packaging_recommender/services/recent_foods_service.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';

void main() {
  setUp(() async {
    await RecentFoodsService.resetToDefaults();
  });

  group('RecentFoodsService Tests', () {
    test('fetches default recent foods on first load', () async {
      final recents = await RecentFoodsService.getRecentFoods();
      expect(recents.isNotEmpty, isTrue);
      expect(recents.length, lessThanOrEqualTo(RecentFoodsService.maxRecentItems));
      expect(recents.first.name, 'Fried Potato Chips');
    });

    test('adds food to top of recent list without duplicate names', () async {
      await RecentFoodsService.clearHistory();

      const food1 = FoodCommodity(
        id: 10,
        name: 'Fresh Tomato',
        category: 'Vegetables',
        moisture: 94.5,
        ph: 4.4,
        waterActivity: 0.99,
        fat: 0.2,
      );

      const food2 = FoodCommodity(
        id: 20,
        name: 'Basmati Rice',
        category: 'Grains',
        moisture: 12.0,
        ph: 6.5,
        waterActivity: 0.55,
        fat: 0.7,
      );

      await RecentFoodsService.addFood(food1);
      await RecentFoodsService.addFood(food2);

      var recents = await RecentFoodsService.getRecentFoods();
      expect(recents.first.name, 'Basmati Rice');
      expect(recents[1].name, 'Fresh Tomato');

      // Add food1 again - it should move to the top
      await RecentFoodsService.addFood(food1);
      recents = await RecentFoodsService.getRecentFoods();
      expect(recents.first.name, 'Fresh Tomato');
      expect(recents[1].name, 'Basmati Rice');
      expect(recents.length, 2);
    });

    test('enforces maxRecentItems ceiling', () async {
      await RecentFoodsService.clearHistory();

      for (int i = 1; i <= 8; i++) {
        await RecentFoodsService.addFood(
          FoodCommodity(
            id: i,
            name: 'Food Item $i',
            category: 'Grains',
            moisture: 10.0,
            ph: 6.0,
            waterActivity: 0.5,
            fat: 1.0,
          ),
        );
      }

      final recents = await RecentFoodsService.getRecentFoods();
      expect(recents.length, RecentFoodsService.maxRecentItems);
      expect(recents.first.name, 'Food Item 8');
    });
  });

  group('ApiService Search Tests', () {
    test('searchFoods returns filtered results in offline mode', () async {
      final fruits = await ApiService.searchFoods('', category: 'Fruits');
      expect(fruits.isNotEmpty, isTrue);
      for (final f in fruits) {
        expect(f.category, 'Fruits');
      }

      final chips = await ApiService.searchFoods('chips');
      expect(chips.isNotEmpty, isTrue);
      expect(chips.any((c) => c.name.toLowerCase().contains('chips')), isTrue);
    });
  });
}
