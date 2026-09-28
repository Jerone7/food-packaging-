import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_commodity.dart';
import 'package:ai_packaging_recommender/models/storage_condition.dart';
import 'package:ai_packaging_recommender/models/food_analysis_request.dart';

void main() {
  group('FoodCommodity Model Tests', () {
    test('instantiates and serializes FoodCommodity with biochemical traits', () {
      const food = FoodCommodity(
        id: 101,
        name: 'Organic Strawberries',
        category: 'Fruits',
        scientificName: 'Fragaria ananassa',
        moisture: 91.0,
        ph: 3.4,
        waterActivity: 0.99,
        fat: 0.3,
        respirationClass: 'Very High',
        oxygenSensitivity: 'High',
        moistureSensitivity: 'Very High',
        recommendedStorage: 'Refrigerated (0-2°C)',
      );

      expect(food.id, 101);
      expect(food.categoryIcon, Icons.apple_rounded);
      expect(food.categoryColor, const Color(0xFFF97316));

      final json = food.toJson();
      expect(json['name'], 'Organic Strawberries');
      expect(json['moisture'], 91.0);
      expect(json['ph'], 3.4);

      final restored = FoodCommodity.fromJson(json);
      expect(restored.name, food.name);
      expect(restored.scientificName, food.scientificName);
      expect(restored.moisture, 91.0);
    });

    test('correctly maps icons and colors across all 7 categories', () {
      final map = {
        'Fruits': Icons.apple_rounded,
        'Vegetables': Icons.eco_rounded,
        'Grains': Icons.grain_rounded,
        'Dairy': Icons.water_drop_rounded,
        'Meat': Icons.set_meal_rounded,
        'Bakery': Icons.cake_rounded,
        'Other perishables': Icons.fastfood_rounded,
      };

      for (final entry in map.entries) {
        final commodity = FoodCommodity(
          name: 'Sample Item',
          category: entry.key,
          moisture: 10,
          ph: 6,
          waterActivity: 0.5,
          fat: 1,
        );
        expect(commodity.categoryIcon, entry.value, reason: 'Failed for ${entry.key}');
      }
    });

    test('toBiochemicalProfile generates valid BiochemicalProfile', () {
      const food = FoodCommodity(
        name: 'Cheddar Cheese',
        category: 'Dairy',
        moisture: 36.5,
        ph: 5.3,
        waterActivity: 0.88,
        fat: 33.0,
        respirationClass: 'Very Low',
      );

      final profile = food.toBiochemicalProfile();
      expect(profile.moisture, 36.5);
      expect(profile.fat, 33.0);
      expect(profile.ph, 5.3);
      expect(profile.waterActivity, 0.88);
      expect(profile.respirationClass, 'Very Low');
      expect(profile.isCustomOverride, isFalse);

      final modified = profile.copyWith(fat: 35.0, isCustomOverride: true);
      expect(modified.fat, 35.0);
      expect(modified.isCustomOverride, isTrue);
    });
  });

  group('StorageCondition & Logistics Model Tests', () {
    test('QuantityUnit conversions to kilograms', () {
      expect(QuantityUnit.kg.toKilograms(5.0), 5.0);
      expect(QuantityUnit.g.toKilograms(500.0), 0.5);
      expect(QuantityUnit.tonnes.toKilograms(2.5), 2500.0);
      expect(QuantityUnit.units.toKilograms(10.0, unitWeightKg: 0.25), 2.5);
    });

    test('DurationUnit conversions to days', () {
      expect(DurationUnit.days.toDays(14), 14);
      expect(DurationUnit.weeks.toDays(3), 21);
      expect(DurationUnit.months.toDays(6), 180);
      expect(DurationUnit.years.toDays(2), 730);
    });

    test('FoodAnalysisRequest payload compiles cleanly', () {
      const request = FoodAnalysisRequest(
        foodId: 60,
        commodityName: 'Fried Potato Chips',
        category: 'Other perishables',
        biochemicalProfile: BiochemicalProfile(
          moisture: 1.5,
          fat: 32.4,
          ph: 6.0,
          waterActivity: 0.25,
          respirationClass: 'None',
        ),
        quantity: 200.0,
        unit: QuantityUnit.g,
        normalizedQuantityKg: 0.2,
        storageCondition: StorageMode.roomTemperature,
        storageDurationDays: 180,
        transportCondition: TransportCondition(
          mode: TransportMode.ambientRoad,
          transitDays: 3,
          isFragile: true,
        ),
        ecoFriendlyPriority: true,
      );

      final json = request.toJson();
      expect(json['commodity_name'], 'Fried Potato Chips');
      expect(json['unit'], 'g');
      expect(json['normalized_quantity_kg'], 0.2);
      expect(json['storage_condition'], 'room_temperature');
      expect(json['transport_condition']['mode'], 'ambient_road');
      expect(json['transport_condition']['is_fragile'], isTrue);
    });
  });
}
