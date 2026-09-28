import '../models/food_commodity.dart';

class RecentFoodsService {
  static const int maxRecentItems = 5;

  // Default initial recommendations for instant 1-click access
  static final List<FoodCommodity> _defaultInitialFoods = [
    const FoodCommodity(
      id: 60,
      name: "Fried Potato Chips",
      category: "Other perishables",
      scientificName: "Solanum tuberosum snack",
      moisture: 1.5,
      ph: 6.0,
      waterActivity: 0.25,
      fat: 32.4,
      respirationClass: "None",
      oxygenSensitivity: "Very High",
      moistureSensitivity: "Very High",
      recommendedStorage: "Room temperature (Nitrogen flushed / Met-PET)",
    ),
    const FoodCommodity(
      id: 1,
      name: "Fresh Apple",
      category: "Fruits",
      scientificName: "Malus domestica",
      moisture: 85.5,
      ph: 3.6,
      waterActivity: 0.98,
      fat: 0.2,
      respirationClass: "Moderate",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "High",
      recommendedStorage: "Refrigerated (2-4°C, 90-95% RH)",
    ),
    const FoodCommodity(
      id: 30,
      name: "Fresh Paneer",
      category: "Dairy",
      scientificName: "Dairy coagulum",
      moisture: 54.0,
      ph: 5.8,
      waterActivity: 0.95,
      fat: 24.0,
      respirationClass: "Very Low",
      oxygenSensitivity: "High",
      moistureSensitivity: "High",
      recommendedStorage: "Refrigerated (2-4°C)",
    ),
  ];

  // In-memory LRU cache
  static List<FoodCommodity> _cache = List.from(_defaultInitialFoods);

  /// Retrieves the list of recently selected commodities
  static Future<List<FoodCommodity>> getRecentFoods() async {
    return List.unmodifiable(_cache);
  }

  /// Adds a food to the top of the recent list (LRU order)
  static Future<void> addFood(FoodCommodity food) async {
    // Remove if already present (deduplicate by id or name)
    _cache.removeWhere(
      (item) =>
          item.id == food.id ||
          item.name.trim().toLowerCase() == food.name.trim().toLowerCase(),
    );

    // Insert at front
    _cache.insert(0, food);

    // Enforce max item limit
    if (_cache.length > maxRecentItems) {
      _cache = _cache.sublist(0, maxRecentItems);
    }
  }

  /// Clears recent food history
  static Future<void> clearHistory() async {
    _cache.clear();
  }

  /// Resets recent foods to default recommendations
  static Future<void> resetToDefaults() async {
    _cache = List.from(_defaultInitialFoods);
  }
}
