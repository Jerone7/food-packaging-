import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/packaging_model.dart';
import '../models/commodity_model.dart';
import '../models/food_commodity.dart';
import '../models/food_scientific_profile.dart';
import '../models/material_catalog_model.dart';
import '../models/packaging_comparison_model.dart';
import '../models/cost_estimation_model.dart';
import '../models/sustainability_model.dart';
import '../models/recommendation_report_model.dart';
import 'offline_cost_engine.dart';
import 'offline_sustainability_engine.dart';
import 'report_generator_service.dart';
import 'auth_service.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for Windows/Web, or custom machine IP
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Static built-in fallback categories when backend is offline
  static final List<CommodityCategorySummary> defaultCategories = [
    CommodityCategorySummary(
      category: "Snacks & Wafers",
      description: "Fried & extruded crisps requiring high moisture and oxygen barrier to prevent sogginess & rancidity.",
      sampleItems: ["Potato Chips", "Banana Chips", "Namkeen", "Tortilla Chips"],
      count: 30,
    ),
    CommodityCategorySummary(
      category: "Biscuits & Bakery",
      description: "Dry biscuits, soft breads, and rusks sensitive to staling, moisture gain, and mold growth.",
      sampleItems: ["Marie Biscuit", "Digestive Biscuit", "White Bread", "Croissant"],
      count: 25,
    ),
    CommodityCategorySummary(
      category: "Pickles & Sauces",
      description: "Acidic, high-moisture condiments requiring corrosion-resistant, high-barrier laminates.",
      sampleItems: ["Mango Pickle", "Tomato Ketchup", "Red Chili Sauce", "Mixed Fruit Jam"],
      count: 25,
    ),
    CommodityCategorySummary(
      category: "Spice Powders",
      description: "Fine hygroscopic powders with volatile oleoresins requiring aroma and moisture retention.",
      sampleItems: ["Red Chili Powder", "Turmeric Powder", "Garam Masala", "Cumin Powder"],
      count: 22,
    ),
    CommodityCategorySummary(
      category: "Dairy & Sweets",
      description: "High-fat dairy solids, paneer, and traditional sweets vulnerable to oxidation and microbial growth.",
      sampleItems: ["Paneer", "Butter", "Cheddar Cheese", "Kaju Katli", "Rasgulla"],
      count: 35,
    ),
    CommodityCategorySummary(
      category: "Retort & Ready-to-Eat",
      description: "Thermally sterilized shelf-stable meals in multi-layer barrier retort pouches.",
      sampleItems: ["Dal Makhani", "Paneer Butter Masala", "Veg Biryani", "Rajma Masala"],
      count: 18,
    ),
    CommodityCategorySummary(
      category: "Millets & Flours",
      description: "Nutritious grain flours and snacks susceptible to enzymatic rancidity and insect infestation.",
      sampleItems: ["Ragi Flour", "Jowar Chips", "Bajra Khakhra", "Foxtail Millet"],
      count: 20,
    ),
    CommodityCategorySummary(
      category: "Dry Fruits & Nuts",
      description: "Lipid-dense dormant seeds requiring oxygen barrier to prevent oxidative off-flavors.",
      sampleItems: ["Almonds", "Cashew Nuts", "Walnuts", "Raisins", "Pistachios"],
      count: 16,
    ),
  ];

  static const List<FoodCommodity> defaultCommodities = [
    // Fruits
    FoodCommodity(
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
    FoodCommodity(
      id: 2,
      name: "Fresh Mango",
      category: "Fruits",
      scientificName: "Mangifera indica",
      moisture: 83.0,
      ph: 4.2,
      waterActivity: 0.98,
      fat: 0.4,
      respirationClass: "High",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "High",
      recommendedStorage: "Refrigerated (10-13°C, 85-90% RH)",
    ),
    FoodCommodity(
      id: 3,
      name: "Banana",
      category: "Fruits",
      scientificName: "Musa acuminata",
      moisture: 75.0,
      ph: 5.0,
      waterActivity: 0.97,
      fat: 0.3,
      respirationClass: "High",
      oxygenSensitivity: "High",
      moistureSensitivity: "High",
      recommendedStorage: "Room temperature (13-15°C, 90% RH)",
    ),
    FoodCommodity(
      id: 4,
      name: "Strawberries",
      category: "Fruits",
      scientificName: "Fragaria × ananassa",
      moisture: 91.0,
      ph: 3.4,
      waterActivity: 0.99,
      fat: 0.3,
      respirationClass: "Very High",
      oxygenSensitivity: "High",
      moistureSensitivity: "Very High",
      recommendedStorage: "Refrigerated (0-2°C, 95% RH)",
    ),

    // Vegetables
    FoodCommodity(
      id: 10,
      name: "Fresh Tomato",
      category: "Vegetables",
      scientificName: "Solanum lycopersicum",
      moisture: 94.5,
      ph: 4.4,
      waterActivity: 0.99,
      fat: 0.2,
      respirationClass: "Moderate",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "High",
      recommendedStorage: "Refrigerated (10-12°C, 90% RH)",
    ),
    FoodCommodity(
      id: 11,
      name: "Fresh Spinach",
      category: "Vegetables",
      scientificName: "Spinacia oleracea",
      moisture: 91.4,
      ph: 6.2,
      waterActivity: 0.99,
      fat: 0.4,
      respirationClass: "Extremely High",
      oxygenSensitivity: "High",
      moistureSensitivity: "Very High",
      recommendedStorage: "Refrigerated (0-2°C, 95-100% RH)",
    ),
    FoodCommodity(
      id: 12,
      name: "Potato (Ware)",
      category: "Vegetables",
      scientificName: "Solanum tuberosum",
      moisture: 79.0,
      ph: 5.8,
      waterActivity: 0.98,
      fat: 0.1,
      respirationClass: "Low",
      oxygenSensitivity: "Low",
      moistureSensitivity: "Moderate",
      recommendedStorage: "Room temperature (8-10°C, 90% RH)",
    ),
    FoodCommodity(
      id: 13,
      name: "Carrot",
      category: "Vegetables",
      scientificName: "Daucus carota",
      moisture: 88.0,
      ph: 5.9,
      waterActivity: 0.99,
      fat: 0.2,
      respirationClass: "Moderate",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "High",
      recommendedStorage: "Refrigerated (0-2°C, 95-100% RH)",
    ),

    // Grains
    FoodCommodity(
      id: 20,
      name: "Basmati Rice",
      category: "Grains",
      scientificName: "Oryza sativa",
      moisture: 12.0,
      ph: 6.5,
      waterActivity: 0.55,
      fat: 0.7,
      respirationClass: "Very Low",
      oxygenSensitivity: "Low",
      moistureSensitivity: "High",
      recommendedStorage: "Room temperature (15-25°C, <65% RH)",
    ),
    FoodCommodity(
      id: 21,
      name: "Whole Wheat Flour",
      category: "Grains",
      scientificName: "Triticum aestivum",
      moisture: 11.5,
      ph: 6.2,
      waterActivity: 0.58,
      fat: 1.7,
      respirationClass: "Very Low",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "High",
      recommendedStorage: "Room temperature (15-20°C, dry)",
    ),
    FoodCommodity(
      id: 22,
      name: "Finger Millet (Ragi)",
      category: "Grains",
      scientificName: "Eleusine coracana",
      moisture: 13.1,
      ph: 6.4,
      waterActivity: 0.60,
      fat: 1.3,
      respirationClass: "Very Low",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "High",
      recommendedStorage: "Room temperature (dry airtight)",
    ),
    FoodCommodity(
      id: 23,
      name: "Chickpeas (Kabuli Chana)",
      category: "Grains",
      scientificName: "Cicer arietinum",
      moisture: 9.8,
      ph: 6.3,
      waterActivity: 0.50,
      fat: 5.3,
      respirationClass: "Very Low",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "High",
      recommendedStorage: "Room temperature (dry)",
    ),

    // Dairy
    FoodCommodity(
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
    FoodCommodity(
      id: 31,
      name: "Cheddar Cheese",
      category: "Dairy",
      scientificName: "Ripened curd cheese",
      moisture: 36.5,
      ph: 5.3,
      waterActivity: 0.88,
      fat: 33.0,
      respirationClass: "Very Low",
      oxygenSensitivity: "High",
      moistureSensitivity: "Moderate",
      recommendedStorage: "Refrigerated (2-6°C)",
    ),
    FoodCommodity(
      id: 32,
      name: "Table Butter",
      category: "Dairy",
      scientificName: "Dairy fat emulsion",
      moisture: 15.8,
      ph: 6.4,
      waterActivity: 0.75,
      fat: 81.0,
      respirationClass: "None",
      oxygenSensitivity: "Very High",
      moistureSensitivity: "Low",
      recommendedStorage: "Refrigerated (2-4°C, light-tight)",
    ),
    FoodCommodity(
      id: 33,
      name: "Full Cream Milk Powder",
      category: "Dairy",
      scientificName: "Spray-dried milk",
      moisture: 3.0,
      ph: 6.6,
      waterActivity: 0.20,
      fat: 26.5,
      respirationClass: "None",
      oxygenSensitivity: "High",
      moistureSensitivity: "Very High",
      recommendedStorage: "Room temperature (airtight, dry)",
    ),

    // Meat
    FoodCommodity(
      id: 40,
      name: "Fresh Chicken Breast",
      category: "Meat",
      scientificName: "Gallus gallus domesticus",
      moisture: 74.5,
      ph: 5.9,
      waterActivity: 0.99,
      fat: 2.6,
      respirationClass: "Very Low",
      oxygenSensitivity: "High",
      moistureSensitivity: "High",
      recommendedStorage: "Refrigerated (0-2°C) or Frozen (≤ -18°C)",
    ),
    FoodCommodity(
      id: 41,
      name: "Mutton Curry Cut",
      category: "Meat",
      scientificName: "Capra hircus",
      moisture: 71.0,
      ph: 5.7,
      waterActivity: 0.99,
      fat: 7.5,
      respirationClass: "Very Low",
      oxygenSensitivity: "High",
      moistureSensitivity: "High",
      recommendedStorage: "Refrigerated (0-2°C) or Frozen (≤ -18°C)",
    ),
    FoodCommodity(
      id: 42,
      name: "Salmon Fish Fillet",
      category: "Meat",
      scientificName: "Salmo salar",
      moisture: 68.5,
      ph: 6.3,
      waterActivity: 0.99,
      fat: 13.4,
      respirationClass: "Very Low",
      oxygenSensitivity: "Very High",
      moistureSensitivity: "High",
      recommendedStorage: "Refrigerated (0-2°C, MAP / Vacuum)",
    ),

    // Bakery
    FoodCommodity(
      id: 50,
      name: "White Sliced Bread",
      category: "Bakery",
      scientificName: "Yeast-leavened wheat",
      moisture: 38.0,
      ph: 5.4,
      waterActivity: 0.94,
      fat: 3.2,
      respirationClass: "Low",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "High",
      recommendedStorage: "Room temperature (20-25°C, sealed)",
    ),
    FoodCommodity(
      id: 51,
      name: "Digestive Biscuits",
      category: "Bakery",
      scientificName: "Baked cereal cookie",
      moisture: 3.5,
      ph: 6.5,
      waterActivity: 0.30,
      fat: 18.5,
      respirationClass: "None",
      oxygenSensitivity: "High",
      moistureSensitivity: "Very High",
      recommendedStorage: "Room temperature (airtight moisture barrier)",
    ),
    FoodCommodity(
      id: 52,
      name: "Dry Toast Rusk",
      category: "Bakery",
      scientificName: "Twice-baked bread",
      moisture: 4.0,
      ph: 6.0,
      waterActivity: 0.32,
      fat: 8.0,
      respirationClass: "None",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "Very High",
      recommendedStorage: "Room temperature (dry)",
    ),

    // Other perishables
    FoodCommodity(
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
    FoodCommodity(
      id: 61,
      name: "Mango Pickle (Oil Based)",
      category: "Other perishables",
      scientificName: "Acidic condiment",
      moisture: 42.0,
      ph: 3.2,
      waterActivity: 0.78,
      fat: 22.0,
      respirationClass: "None",
      oxygenSensitivity: "Moderate",
      moistureSensitivity: "Moderate",
      recommendedStorage: "Room temperature (acid-resistant barrier)",
    ),
    FoodCommodity(
      id: 62,
      name: "Tomato Ketchup",
      category: "Other perishables",
      scientificName: "Pasteurized tomato sauce",
      moisture: 68.0,
      ph: 3.7,
      waterActivity: 0.92,
      fat: 0.2,
      respirationClass: "None",
      oxygenSensitivity: "High",
      moistureSensitivity: "Moderate",
      recommendedStorage: "Room temperature / Chilled after opening",
    ),
    FoodCommodity(
      id: 63,
      name: "Ready-to-Eat Dal Makhani",
      category: "Other perishables",
      scientificName: "Retort sterilized meal",
      moisture: 72.0,
      ph: 5.6,
      waterActivity: 0.97,
      fat: 8.5,
      respirationClass: "None",
      oxygenSensitivity: "High",
      moistureSensitivity: "High",
      recommendedStorage: "Room temperature (Retort pouch PET/Al/PP)",
    ),
  ];

  /// Searches food commodities by query string and optional category filter
  static Future<List<FoodCommodity>> searchFoods(
    String query, {
    String? category,
    int limit = 50,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (query.trim().isNotEmpty) {
        queryParams['search'] = query.trim();
      }
      if (category != null && category.trim().isNotEmpty) {
        queryParams['category'] = category.trim();
      }

      final uri = Uri.parse('$baseUrl/data/foods').replace(queryParameters: queryParams);
      final response = await httpClient.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        if (list.isNotEmpty) {
          return list.map((item) => FoodCommodity.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {
      // Graceful offline fallback
    }

    // Local fallback filter with dynamically created custom commodities
    var results = [..._customCommodities, ...defaultCommodities];
    if (category != null && category.trim().isNotEmpty) {
      results = results.where((f) => f.category.toLowerCase().contains(category.trim().toLowerCase())).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((f) {
        return f.name.toLowerCase().contains(q) ||
            (f.scientificName?.toLowerCase().contains(q) ?? false) ||
            f.category.toLowerCase().contains(q);
      }).toList();
    }
    return results.take(limit).toList();
  }

  /// In-memory cache for user-registered custom food commodities
  static final List<FoodCommodity> _customCommodities = [];

  /// Creates and stores a manual entry food product in backend and local catalog
  static Future<FoodCommodity> createFood(
    FoodCommodity food, {
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.parse('$baseUrl/data/foods');
      final response = await httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': food.name,
              'category': food.category,
              'scientific_name': food.scientificName,
              'moisture': food.moisture,
              'ph': food.ph,
              'water_activity': food.waterActivity,
              'fat': food.fat,
              'respiration_class': food.respirationClass,
              'oxygen_sensitivity': food.oxygenSensitivity,
              'moisture_sensitivity': food.moistureSensitivity,
              'recommended_storage': food.recommendedStorage,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final created = FoodCommodity.fromJson(data);
        _customCommodities.removeWhere((f) => f.name.toLowerCase() == created.name.toLowerCase());
        _customCommodities.insert(0, created);
        return created;
      }
    } catch (_) {
      // Graceful offline fallback
    }

    final localCreated = FoodCommodity(
      id: food.id ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      name: food.name,
      category: food.category,
      scientificName: food.scientificName,
      moisture: food.moisture,
      ph: food.ph,
      waterActivity: food.waterActivity,
      fat: food.fat,
      respirationClass: food.respirationClass,
      oxygenSensitivity: food.oxygenSensitivity,
      moistureSensitivity: food.moistureSensitivity,
      recommendedStorage: food.recommendedStorage ?? 'Standard ${food.category} Storage',
    );
    _customCommodities.removeWhere((f) => f.name.toLowerCase() == localCreated.name.toLowerCase());
    _customCommodities.insert(0, localCreated);
    return localCreated;
  }

  /// Fetches category summaries and counts for the Home Page,
  /// falling back gracefully to built-in static categories if offline.
  static Future<CommoditySummaryResult> getFeaturedCommodities({
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/data/categories-summary'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CommoditySummaryResult.fromJson(data);
      }
    } catch (_) {
      // Graceful offline fallback
    }

    return CommoditySummaryResult(
      source: 'offline_fallback',
      totalFoods: defaultCategories.fold(0, (sum, c) => sum + c.count),
      totalMaterials: 7,
      categories: defaultCategories,
    );
  }

  /// Fetches hybrid AI/ML packaging recommendation from backend,
  /// falling back to instant client-side hybrid synthesis if offline.
  /// Automatically stores in user's account history if logged in.
  static Future<PackagingRecommendationResult> getRecommendation(
    PackagingInput input, {
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final auth = AuthService();
    final headers = auth.authHeaders;

    try {
      final response = await httpClient
          .post(
            Uri.parse('$baseUrl/packaging/recommend'),
            headers: headers,
            body: jsonEncode(input.toJson()),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final result = PackagingRecommendationResult.fromJson(
          jsonDecode(response.body),
        );
        _recordHistoryIfAuthenticated(input, result);
        return result;
      }
    } catch (_) {
      // Graceful offline fallback
    }

    final fallbackResult = generateOfflineRecommendation(input);
    _recordHistoryIfAuthenticated(input, fallbackResult);
    return fallbackResult;
  }

  static void _recordHistoryIfAuthenticated(
    PackagingInput input,
    PackagingRecommendationResult result,
  ) {
    final auth = AuthService();
    if (!auth.isAuthenticated) {
      return; // If user does not login, don't save
    }

    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final formatted =
        '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';

    final record = PackagingRecord(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: auth.currentUser?.id,
      itemName: input.itemName,
      length: input.length,
      width: input.width,
      height: input.height,
      weight: input.weight,
      isFragile: input.isFragile,
      ecoFriendly: input.ecoFriendly,
      createdAt: now,
      formattedDate: formatted,
      recommendedBoxType: result.recommendedBoxType,
      recommendedDimensions: result.recommendedDimensions,
      boxVolumeCm3: result.boxVolumeCm3,
      itemVolumeCm3: result.itemVolumeCm3,
      spaceUtilizationPct: result.spaceUtilizationPct,
      cushioningMaterial: result.cushioningMaterial,
      estimatedCost: result.estimatedCost,
      sustainabilityScore: result.sustainabilityScore,
      notes: result.notes,
      primaryRecommendation: result.primaryRecommendation,
      alternatives: result.alternatives,
      comparisonSummary: result.comparisonSummary,
      boxGeometry: result.boxGeometry,
      scientificRationale: result.scientificRationale,
    );

    saveLocalHistoryRecord(record);
  }

  /// Instant client-side hybrid recommendation synthesis for offline environments
  static PackagingRecommendationResult generateOfflineRecommendation(PackagingInput input) {
    final name = input.itemName;
    final nameLower = name.toLowerCase();
    final catLower = (input.category ?? '').toLowerCase();
    final moisture = input.moisture ?? 70.0;
    final fat = input.fat ?? 2.0;
    final r20 = input.respirationRate20c ?? (moisture > 75.0 ? 30.0 : 0.0);
    final isFragile = input.isFragile;
    final temp = input.storageTempC ?? 20.0;
    final qty = input.weight > 0 ? input.weight : 5.0;

    // Density estimation
    double density = 600.0;
    if (catLower.contains('veg')) density = 500.0;
    if (catLower.contains('fruit')) density = 550.0;
    if (catLower.contains('meat') || catLower.contains('dairy')) density = 950.0;
    if (catLower.contains('snack') || nameLower.contains('chip')) density = 150.0;
    if (catLower.contains('grain')) density = 800.0;

    final vNet = (qty / density) * 1000000.0;
    final buffer = isFragile ? 1.45 : 1.25;
    final vGross = vNet * buffer;
    final w = (vGross / 1.2944) > 0 ? (vGross / 1.2944) : 1000.0;
    final widthCm = double.parse((w > 0 ? (w > 0 ? (w < 100 ? 10.0 : (w < 100000 ? 18.0 : 25.0)) : 15.0) : 15.0).toStringAsFixed(1));
    final lengthCm = double.parse((widthCm * 1.618).toStringAsFixed(1));
    final heightCm = double.parse((widthCm * 0.8).toStringAsFixed(1));
    final boxVol = double.parse((lengthCm * widthCm * heightCm).toStringAsFixed(1));
    final itemVol = double.parse((boxVol * 0.76).toStringAsFixed(1));

    String cushioning;
    if (isFragile) {
      cushioning = temp <= 8.0
          ? 'Recycled Kraft Thermal Insulated Pouch + Cold Gel Pack'
          : 'Honeycomb Kraft Paper + Cornstarch Protective Peanuts';
    } else {
      cushioning = temp <= 8.0 ? 'Molded Pulp Insulated Box Liner' : 'Recycled Shredded Kraft Paper Cushioning';
    }

    PrimaryRecommendation primary;
    List<PackagingAlternative> alts = [];
    List<String> additives = [];
    String summary;
    List<String> drivers = [];

    if (r20 >= 20.0 || moisture > 75.0 || catLower.contains('veg') || catLower.contains('fruit')) {
      primary = const PrimaryRecommendation(
        materialName: 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)',
        materialType: 'Biodegradable Bio-Polymer',
        polymerFamily: 'BREATHABLE_BIO_EMAP',
        structure: 'Co-extruded Micro-Perforated PLA/PBAT Blown Film',
        barrierProfile: BarrierProfile(
          otr: '3500.0 cc/m²/day',
          wvtr: '45.00 g/m²/day',
          thicknessMicrons: 30.0,
          tensileStrengthMpa: 32.0,
          punctureResistanceN: 18.0,
        ),
        sustainabilityScore: 94.0,
        estimatedUnitCostInr: 3.85,
        suitabilityScore: 0.96,
        activeAdditives: [
          'Potassium Permanganate (KMnO₄) Ethylene Scavenger Sachet',
          'Antifog Surface Surfactant Coating',
        ],
        packagingTitle: 'Ventilated Food-Grade Packaging',
        packagingFormat: 'Micro-Perforated Hinged Clamshell',
        recommendationExplanation:
            'This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management.',
        advantages: [
          'Equilibrium modified atmosphere (EMAP) prevents anaerobic souring',
          'Anti-fog coating suppresses condensation water droplets and mold',
          'Optimized gas permselectivity maintains cell firmness and freshness',
        ],
        limitations: [
          'Not suitable for vacuum packing or high-temperature retort processing',
          'Storage duration limited to 14–21 days under ambient conditions',
          'Permeable to strong external volatile aromas',
        ],
        suitableStorageCondition: 'Cold Storage: 10°C - 12°C (90-95% RH)',
        expectedApplication:
            'High-respiration fresh produce, strawberries, cut fruits, cherry tomatoes',
        importantProperties: {
          'OTR (Oxygen Barrier)': '3500.0 cc/m²/day',
          'WVTR (Moisture Barrier)': '45.00 g/m²/day',
          'Film Thickness': '30.0 µm',
          'Tensile Strength': '32.0 MPa',
          'Puncture Resistance': '18.0 N',
          'Thermal Span': '0°C to 45°C',
        },
      );
      additives = primary.activeAdditives;
      summary = '$name requires Equilibrium Modified Atmosphere (EMAP) with active ethylene scrubbing and chilling safeguards.';
      drivers = [
        'High respiration rate (${r20.toStringAsFixed(1)} mg CO₂/kg/h) requires gas-permeable micro-perforations to prevent anaerobic souring.',
        'High moisture content (${moisture.toStringAsFixed(1)}%) requires anti-fog surfactant to prevent condensation droplets.',
        'Ethylene sensitivity warrants active KMnO₄ oxidation sachet to delay senescence.',
      ];

      alts = [
        const PackagingAlternative(
          candidateId: 'alt_eco_natureflex_01',
          type: AlternativeType.ecoFriendly,
          typeRaw: 'ECO_FRIENDLY',
          materialName: 'Cellulose-Based Breathable Bio-Film (NatureFlex)',
          packagingTitle: 'Heat-Sealed Bio-Pouch with Micro-Laser Vents',
          starRating: 4,
          starDisplay: '★★★★☆',
          suitabilityCategory: SuitabilityCategory.highCompatibility,
          modelDerivedProbability: 0.86,
          compatibilityConfidence: 'High Confidence (0.86)',
          characteristics: MaterialCharacteristics(
            otr: '2,800 cc/m²/day',
            wvtr: '50.0 g/m²/day',
            thicknessMicrons: 30.0,
            tensileStrengthMpa: 45.0,
            thermalRange: '-5°C to 60°C',
            sustainabilityRating: '100% Home Compostable',
            estimatedCostInr: 4.50,
            costTier: 'Moderate (₹₹)',
          ),
          tradeOffSummary: '100% Home compostable with pristine optical clarity; +17% unit cost.',
          advantages: [
            '100% bio-based marine and soil degradable',
            'Superior optical gloss and clarity for premium retail display',
            'Laser micro-vents prevent anaerobic off-flavor build-up',
          ],
          limitations: [
            '17% higher unit cost than conventional polyolefins',
            'Requires climate-controlled storage under 30°C before conversion',
          ],
          costDeltaPct: 16.9,
          ecoDeltaPct: 4.3,
          shelfLifeDelta: 'Equal (21 days)',
          sustainabilityScore: 98.0,
          estimatedUnitCostInr: 4.50,
        ),
        const PackagingAlternative(
          candidateId: 'alt_econ_ldpe_02',
          type: AlternativeType.economy,
          typeRaw: 'ECONOMY',
          materialName: 'Perforated Low-Density Polyethylene (LDPE)',
          packagingTitle: 'Punched-Hole Flexible Gusseted Bag',
          starRating: 3,
          starDisplay: '★★★☆☆',
          suitabilityCategory: SuitabilityCategory.moderateCompatibility,
          modelDerivedProbability: 0.72,
          compatibilityConfidence: 'Moderate Fit (0.72)',
          characteristics: MaterialCharacteristics(
            otr: '> 5,000 cc/m²/day',
            wvtr: '15.0 g/m²/day',
            thicknessMicrons: 25.0,
            tensileStrengthMpa: 28.0,
            thermalRange: '-20°C to 70°C',
            sustainabilityRating: 'Recyclable (RIC #4)',
            estimatedCostInr: 1.95,
            costTier: 'Low (₹)',
          ),
          tradeOffSummary: 'Lowest unit cost (₹1.95); 49% cost savings for high-volume local logistics.',
          advantages: [
            '49% unit cost reduction compared to bio-clamshell',
            'Standard municipal recyclability (RIC #4)',
            'Tear-resistant flexible substrate for bulk transport',
          ],
          limitations: [
            'Non-biodegradable fossil-based polymer',
            'Macro-perforations offer lower condensation control than laser EMAP',
          ],
          costDeltaPct: -49.4,
          ecoDeltaPct: -34.0,
          shelfLifeDelta: '-3 to -4 days',
          sustainabilityScore: 62.0,
          estimatedUnitCostInr: 1.95,
        ),
        const PackagingAlternative(
          candidateId: 'alt_hb_pp_03',
          type: AlternativeType.highBarrier,
          typeRaw: 'HIGH_BARRIER',
          materialName: 'Polypropylene Macro-Vented Anti-Fog Clamshell',
          packagingTitle: 'Thermoformed Snap-Fit Punched Tub',
          starRating: 3,
          starDisplay: '★★★☆☆',
          suitabilityCategory: SuitabilityCategory.moderateCompatibility,
          modelDerivedProbability: 0.75,
          compatibilityConfidence: 'Moderate Fit (0.75)',
          characteristics: MaterialCharacteristics(
            otr: '1,800 cc/m²/day',
            wvtr: '8.0 g/m²/day',
            thicknessMicrons: 350.0,
            tensileStrengthMpa: 35.0,
            thermalRange: '0°C to 100°C',
            sustainabilityRating: 'Recyclable (RIC #5)',
            estimatedCostInr: 5.20,
            costTier: 'Premium (₹₹₹)',
          ),
          tradeOffSummary: 'Maximum crush and impact protection during rugged multi-tier logistics.',
          advantages: [
            'Rigid sidewalls prevent fruit bruising and compressive stacking damage',
            'Reclosable snap-fit lid allows easy consumer snacking access',
            'High clarity with embedded anti-fog additives',
          ],
          limitations: [
            '35% higher packaging unit cost than bio-clamshell',
            'Non-compostable fossil polymer',
          ],
          costDeltaPct: 35.1,
          ecoDeltaPct: -25.5,
          shelfLifeDelta: '+1 to +2 days',
          sustainabilityScore: 70.0,
          estimatedUnitCostInr: 5.20,
        ),
      ];
    } else if (fat >= 18.0 || nameLower.contains('chip') || catLower.contains('snack')) {
      primary = const PrimaryRecommendation(
        materialName: 'Metallized High-Barrier Bio-PET (Met-BioPET)',
        materialType: 'Biodegradable Barrier Film',
        polymerFamily: 'METALLIZED_BARRIER',
        structure: 'Bio-PET base with vacuum aluminium layer + Bio-PE',
        barrierProfile: BarrierProfile(
          otr: '0.8 cc/m²/day',
          wvtr: '0.90 g/m²/day',
          thicknessMicrons: 25.0,
          tensileStrengthMpa: 120.0,
          punctureResistanceN: 40.0,
        ),
        sustainabilityScore: 88.0,
        estimatedUnitCostInr: 4.20,
        suitabilityScore: 0.95,
        activeAdditives: [
          'Nitrogen (N₂) Gas Flush Inert Headspace (O₂ < 1.0%)',
        ],
        packagingTitle: 'Nitrogen-Flushed High-Barrier Foil Pouch',
        packagingFormat: 'Multi-Layer Metallized Stand-up Pouch',
        recommendationExplanation:
            'This option is recommended because the high fat content requires light and oxygen shielding with nitrogen flushing to avoid lipid rancidity.',
        advantages: [
          'Near-zero oxygen transmission prevents rancidity and off-flavor development',
          'High moisture barrier maintains crispy texture',
          'Opaque metallized layer blocks UV-induced photo-oxidation',
        ],
        limitations: [
          'Not home compostable; requires specialized recycling streams',
          'Sensitive to pinhole punctures during heavy transport',
          'Higher manufacturing footprint than plain unmetallized films',
        ],
        suitableStorageCondition: 'Cool & Dry: 15°C - 22°C (< 65% RH)',
        expectedApplication:
            'Potato chips, roasted nuts, fried snacks, extruded cereals',
        importantProperties: {
          'OTR (Oxygen Barrier)': '0.8 cc/m²/day',
          'WVTR (Moisture Barrier)': '0.90 g/m²/day',
          'Film Thickness': '25.0 µm',
          'Tensile Strength': '120.0 MPa',
          'Puncture Resistance': '40.0 N',
          'Thermal Span': '-10°C to 70°C',
        },
      );
      additives = primary.activeAdditives;
      summary = '$name contains sensitive lipids requiring high-barrier shielding and inert gas flushing.';
      drivers = [
        'Elevated fat content (${fat.toStringAsFixed(1)}%) mandates ultra-low oxygen transmission rate (< 1.5 cc/m²/day).',
        'Low moisture requires high moisture barrier to prevent hygroscopic crispness loss.',
      ];
      alts = [
        const PackagingAlternative(
          candidateId: 'alt_eco_kraft_barrier_01',
          type: AlternativeType.ecoFriendly,
          typeRaw: 'ECO_FRIENDLY',
          materialName: 'Unbleached Recycled Kraft with Bio-Dispersion Barrier',
          packagingTitle: 'Block-Bottom Lined Paper Pouch',
          starRating: 4,
          starDisplay: '★★★★☆',
          suitabilityCategory: SuitabilityCategory.highCompatibility,
          modelDerivedProbability: 0.82,
          compatibilityConfidence: 'High Confidence (0.82)',
          characteristics: MaterialCharacteristics(
            otr: '12.0 cc/m²/day',
            wvtr: '3.5 g/m²/day',
            thicknessMicrons: 85.0,
            tensileStrengthMpa: 60.0,
            thermalRange: '-10°C to 80°C',
            sustainabilityRating: '100% Recyclable FSC Kraft',
            estimatedCostInr: 3.50,
            costTier: 'Moderate (₹₹)',
          ),
          tradeOffSummary: 'Bio-composite renewable paper with compostable water-dispersion barrier.',
          advantages: [
            'Premium tactile paperboard aesthetic for artisanal brands',
            '100% recyclable in standard paper recovery streams',
            '17% lower cost than metallized bio-PET',
          ],
          limitations: [
            'Shorter shelf-life extension (60 days vs 180 days for metallized film)',
            'Higher oxygen transmission rate (12.0 vs 0.8 cc/m²/day)',
          ],
          costDeltaPct: -16.7,
          ecoDeltaPct: 8.0,
          shelfLifeDelta: '-60 days shelf-life',
          sustainabilityScore: 95.0,
          estimatedUnitCostInr: 3.50,
        ),
        const PackagingAlternative(
          candidateId: 'alt_econ_met_bopp_02',
          type: AlternativeType.economy,
          typeRaw: 'ECONOMY',
          materialName: 'Metallized BOPP / CPP Barrier Laminate (Met-BOPP)',
          packagingTitle: 'Standard Center-Seal Flow-Wrap Pouch',
          starRating: 3,
          starDisplay: '★★★☆☆',
          suitabilityCategory: SuitabilityCategory.moderateCompatibility,
          modelDerivedProbability: 0.74,
          compatibilityConfidence: 'Moderate Fit (0.74)',
          characteristics: MaterialCharacteristics(
            otr: '1.5 cc/m²/day',
            wvtr: '1.2 g/m²/day',
            thicknessMicrons: 30.0,
            tensileStrengthMpa: 140.0,
            thermalRange: '-15°C to 90°C',
            sustainabilityRating: 'Recyclable Polyolefin',
            estimatedCostInr: 2.30,
            costTier: 'Low (₹)',
          ),
          tradeOffSummary: 'Standard commercial snack packaging film with 45% cost savings.',
          advantages: [
            '45% cost savings for mass commercial snack packaging',
            'Excellent moisture and oxygen barrier properties',
            'High machine speed form-fill-seal compatibility',
          ],
          limitations: [
            'Non-biodegradable multi-layer laminate',
            'Difficult to separate metallized layer for mechanical recycling',
          ],
          costDeltaPct: -45.2,
          ecoDeltaPct: -37.5,
          shelfLifeDelta: '-15 days',
          sustainabilityScore: 55.0,
          estimatedUnitCostInr: 2.30,
        ),
        const PackagingAlternative(
          candidateId: 'alt_hb_foil_03',
          type: AlternativeType.highBarrier,
          typeRaw: 'HIGH_BARRIER',
          materialName: 'Tri-Layer Aluminium Foil Barrier Laminate (PET/AL/PE)',
          packagingTitle: 'Hermetic Foil Heavy-Duty Retort Pouch',
          starRating: 3,
          starDisplay: '★★★☆☆',
          suitabilityCategory: SuitabilityCategory.moderateCompatibility,
          modelDerivedProbability: 0.78,
          compatibilityConfidence: 'Moderate Fit (0.78)',
          characteristics: MaterialCharacteristics(
            otr: '< 0.1 cc/m²/day',
            wvtr: '< 0.1 g/m²/day',
            thicknessMicrons: 110.0,
            tensileStrengthMpa: 160.0,
            thermalRange: '-30°C to 125°C',
            sustainabilityRating: 'Multi-layer Foil Laminate',
            estimatedCostInr: 5.50,
            costTier: 'Premium (₹₹₹)',
          ),
          tradeOffSummary: 'Absolute zero gas permeation barrier for maximum shelf-life.',
          advantages: [
            'Hermetic zero light and oxygen penetration barrier',
            'Extends shelf-life up to 12+ months without degradation',
            'Retort and autoclave sterilization resistant',
          ],
          limitations: [
            'Highest packaging unit cost (₹5.50 / unit)',
            'Lowest sustainability score due to aluminium foil layer',
          ],
          costDeltaPct: 31.0,
          ecoDeltaPct: -54.5,
          shelfLifeDelta: '+180 days shelf-life',
          sustainabilityScore: 40.0,
          estimatedUnitCostInr: 5.50,
        ),
      ];
    } else {
      primary = const PrimaryRecommendation(
        materialName: 'Unbleached Recycled Kraft with Biodegradable PLA Liner',
        materialType: 'Bio-Composite Sustainable Material',
        polymerFamily: 'CELLULOSE_KRAFT_LINED',
        structure: 'Virgin & Post-consumer Unbleached Kraft Paper + PLA Liner',
        barrierProfile: BarrierProfile(
          otr: '45.0 cc/m²/day',
          wvtr: '4.80 g/m²/day',
          thicknessMicrons: 120.0,
          tensileStrengthMpa: 55.0,
          punctureResistanceN: 30.0,
        ),
        sustainabilityScore: 95.0,
        estimatedUnitCostInr: 3.50,
        suitabilityScore: 0.92,
        activeAdditives: [],
        packagingTitle: 'Bio-Composite Moisture-Barrier Paper Bag',
        packagingFormat: 'Multi-Wall Lined Kraft Paper Bag',
        recommendationExplanation:
            'This option is recommended because the dry commodity requires moderate moisture protection while maximizing bio-based sustainability.',
        advantages: [
          'High tensile and puncture strength for heavy bulk items',
          'Biodegradable PLA liner preserves dry equilibrium moisture',
          '100% Recyclable and eco-friendly footprint',
        ],
        limitations: [
          'Not suitable for high-moisture or liquid-emitting commodities',
          'Lower barrier to volatile atmospheric hydrocarbons over prolonged storage',
          'Water droplet exposure degrades outer paper wall',
        ],
        suitableStorageCondition: 'Ambient Dry Storage: 15°C - 25°C (< 60% RH)',
        expectedApplication:
            'Basmati rice, flour, pulses, dry legumes, whole grains',
        importantProperties: {
          'OTR (Oxygen Barrier)': '45.0 cc/m²/day',
          'WVTR (Moisture Barrier)': '4.80 g/m²/day',
          'Film Thickness': '120.0 µm',
          'Tensile Strength': '55.0 MPa',
          'Puncture Resistance': '30.0 N',
          'Thermal Span': '-15°C to 80°C',
        },
      );
      summary = '$name preservation is optimized with renewable bio-composite packaging.';
      drivers = [
        'Sustainable bio-composite delivers superior eco-score while maintaining dry moisture protection.',
        'Tensile strength (55.0 MPa) ensures tear resistance in distribution.',
      ];
      alts = [
        const PackagingAlternative(
          candidateId: 'alt_eco_bagasse_01',
          type: AlternativeType.ecoFriendly,
          typeRaw: 'ECO_FRIENDLY',
          materialName: 'Molded Cellulose Fiber Pulp Protective Tray',
          packagingTitle: 'Bio-Based Molded Pulp Form',
          starRating: 4,
          starDisplay: '★★★★☆',
          suitabilityCategory: SuitabilityCategory.highCompatibility,
          modelDerivedProbability: 0.88,
          compatibilityConfidence: 'High Confidence (0.88)',
          characteristics: MaterialCharacteristics(
            otr: '80.0 cc/m²/day',
            wvtr: '12.0 g/m²/day',
            thicknessMicrons: 450.0,
            tensileStrengthMpa: 35.0,
            thermalRange: '-10°C to 100°C',
            sustainabilityRating: '100% Home Compostable Sugarcane Bagasse',
            estimatedCostInr: 2.60,
            costTier: 'Moderate (₹₹)',
          ),
          tradeOffSummary: '100% Compostable molded bagasse with outstanding impact cushioning.',
          advantages: [
            '100% zero-plastic renewable agricultural byproduct',
            'Superior compressive nest cushioning for fragile dry goods',
            '26% lower cost than lined kraft bag',
          ],
          limitations: [
            'Higher water vapor absorption in unsealed humid rooms',
            'Requires secondary moisture outer barrier for monsoon storage',
          ],
          costDeltaPct: -25.7,
          ecoDeltaPct: 4.2,
          shelfLifeDelta: 'Equal',
          sustainabilityScore: 99.0,
          estimatedUnitCostInr: 2.60,
        ),
        const PackagingAlternative(
          candidateId: 'alt_econ_hdpe_02',
          type: AlternativeType.economy,
          typeRaw: 'ECONOMY',
          materialName: 'High-Density Polyethylene (HDPE) Moisture Barrier Film',
          packagingTitle: 'Heavy-Duty HDPE Gusseted Liner',
          starRating: 3,
          starDisplay: '★★★☆☆',
          suitabilityCategory: SuitabilityCategory.moderateCompatibility,
          modelDerivedProbability: 0.76,
          compatibilityConfidence: 'Moderate Fit (0.76)',
          characteristics: MaterialCharacteristics(
            otr: '1,200 cc/m²/day',
            wvtr: '3.2 g/m²/day',
            thicknessMicrons: 50.0,
            tensileStrengthMpa: 42.0,
            thermalRange: '-40°C to 90°C',
            sustainabilityRating: 'Recyclable (RIC #2)',
            estimatedCostInr: 2.10,
            costTier: 'Low (₹)',
          ),
          tradeOffSummary: 'Lowest cost recyclable moisture barrier for bulk commodity storage.',
          advantages: [
            '40% cost reduction for high-tonnage agricultural grain storage',
            'Exceptional moisture barrier protects against caking',
            'High puncture strength against sharp grain husks',
          ],
          limitations: [
            'Fossil-based polymer with 68/100 sustainability score',
            'Static buildup requires anti-static additives for fine flours',
          ],
          costDeltaPct: -40.0,
          ecoDeltaPct: -28.4,
          shelfLifeDelta: '+15 days',
          sustainabilityScore: 68.0,
          estimatedUnitCostInr: 2.10,
        ),
        const PackagingAlternative(
          candidateId: 'alt_hb_bopp_03',
          type: AlternativeType.highBarrier,
          typeRaw: 'HIGH_BARRIER',
          materialName: 'Biaxially Oriented Polypropylene (BOPP) Pouch',
          packagingTitle: 'High-Clarity Gloss Woven PP Sack',
          starRating: 3,
          starDisplay: '★★★☆☆',
          suitabilityCategory: SuitabilityCategory.moderateCompatibility,
          modelDerivedProbability: 0.79,
          compatibilityConfidence: 'Moderate Fit (0.79)',
          characteristics: MaterialCharacteristics(
            otr: '1,500 cc/m²/day',
            wvtr: '4.0 g/m²/day',
            thicknessMicrons: 40.0,
            tensileStrengthMpa: 150.0,
            thermalRange: '-10°C to 110°C',
            sustainabilityRating: 'Recyclable (RIC #5)',
            estimatedCostInr: 2.40,
            costTier: 'Low (₹)',
          ),
          tradeOffSummary: 'High tensile strength and pristine retail print surface.',
          advantages: [
            'High tensile burst strength (150 MPa) prevents drop tears',
            'Pristine optical clarity for window packaging',
            '31% lower unit packaging cost',
          ],
          limitations: [
            'Non-biodegradable fossil polymer',
            'Poor tear propagation resistance once punctured',
          ],
          costDeltaPct: -31.4,
          ecoDeltaPct: -31.6,
          shelfLifeDelta: 'Equal',
          sustainabilityScore: 65.0,
          estimatedUnitCostInr: 2.40,
        ),
      ];
    }

    final geom = BoxGeometrySpecs(
      lengthCm: lengthCm,
      widthCm: widthCm,
      heightCm: heightCm,
      totalVolumeCm3: boxVol,
      spaceUtilizationPct: 76.0,
      cushioningMaterial: cushioning,
    );

    final xai = ExplainableAiRationale(
      summary: summary,
      keyDrivers: drivers,
    );

    return PackagingRecommendationResult(
      recommendationId: 'rec_offline_${DateTime.now().millisecondsSinceEpoch}',
      primaryRecommendation: primary,
      alternatives: alts,
      boxGeometry: geom,
      scientificRationale: xai,
      recommendedBoxType: 'Optimized ${primary.materialName} Carton',
      recommendedDimensions: '$lengthCm x $widthCm x $heightCm cm',
      boxVolumeCm3: boxVol,
      itemVolumeCm3: itemVol,
      spaceUtilizationPct: 76.0,
      cushioningMaterial: cushioning,
      estimatedCost: primary.estimatedUnitCostInr,
      sustainabilityScore: primary.sustainabilityScore,
      notes: summary,
    );
  }

  static final List<PackagingRecord> _localSessionHistory = [];

  static final List<PackagingRecord> _fallbackHistoryRecords = [
    PackagingRecord(
      id: 201,
      userId: 1,
      itemName: "Tomato",
      length: 30.0,
      width: 20.0,
      height: 15.0,
      weight: 5.0,
      isFragile: true,
      ecoFriendly: true,
      createdAt: DateTime.parse("2026-09-26T14:30:00.000Z"),
      formattedDate: "26 Sep 2026",
      recommendedBoxType: "Corrugated Kraft Box (5-Ply)",
      recommendedDimensions: "30.0 x 20.0 x 15.0 cm",
      boxVolumeCm3: 9000.0,
      itemVolumeCm3: 7500.0,
      spaceUtilizationPct: 83.3,
      cushioningMaterial: "Kraft Honeycomb Pads",
      estimatedCost: 3.10,
      sustainabilityScore: 96.5,
      notes: "High-humidity export grade ventilated container.",
    ),
    PackagingRecord(
      id: 202,
      userId: 1,
      itemName: "Apple",
      length: 25.0,
      width: 18.0,
      height: 12.0,
      weight: 3.0,
      isFragile: false,
      ecoFriendly: true,
      createdAt: DateTime.parse("2026-09-25T10:15:00.000Z"),
      formattedDate: "25 Sep 2026",
      recommendedBoxType: "Molded Pulp Tray with Bio-Film",
      recommendedDimensions: "25.0 x 18.0 x 12.0 cm",
      boxVolumeCm3: 5400.0,
      itemVolumeCm3: 4200.0,
      spaceUtilizationPct: 77.8,
      cushioningMaterial: "Molded Sugarcane Bagasse Divots",
      estimatedCost: 2.85,
      sustainabilityScore: 94.0,
      notes: "Bruise-preventing molded pulp structure with micro-perforations.",
    ),
    PackagingRecord(
      id: 203,
      userId: 1,
      itemName: "Potato",
      length: 35.0,
      width: 25.0,
      height: 20.0,
      weight: 10.0,
      isFragile: false,
      ecoFriendly: true,
      createdAt: DateTime.parse("2026-09-23T16:45:00.000Z"),
      formattedDate: "23 Sep 2026",
      recommendedBoxType: "Jute-Lined Ventilated Paper Sack",
      recommendedDimensions: "35.0 x 25.0 x 20.0 cm",
      boxVolumeCm3: 17500.0,
      itemVolumeCm3: 14500.0,
      spaceUtilizationPct: 82.9,
      cushioningMaterial: "None (Bulk Aeration Mesh)",
      estimatedCost: 1.75,
      sustainabilityScore: 98.0,
      notes: "Anti-greening breathable light-blocking bio-sack.",
    ),
    PackagingRecord(
      id: 101,
      itemName: "Fresh Strawberries (Export Grade)",
      length: 25.0,
      width: 15.0,
      height: 10.0,
      weight: 0.5,
      isFragile: true,
      ecoFriendly: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      recommendedBoxType: "Micro-Perforated PLA Bio-Clamshell",
      recommendedDimensions: "25.0 x 15.0 x 10.0 cm",
      boxVolumeCm3: 3750.0,
      itemVolumeCm3: 2800.0,
      spaceUtilizationPct: 74.7,
      cushioningMaterial: "Molded Cellulose Pulp Nest",
      estimatedCost: 4.20,
      sustainabilityScore: 88.0,
      notes: "Active equilibrium MAP formulation with antifog coating and 100% bio-based compostable PLA. Prevents botrytis mold and condensation while maintaining optimal 3% O2 / 10% CO2 headspace.",
    ),
    PackagingRecord(
      id: 102,
      itemName: "Alphonso Mango (Export Grade)",
      length: 38.0,
      width: 28.0,
      height: 14.0,
      weight: 3.5,
      isFragile: true,
      ecoFriendly: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 6, minutes: 40)),
      recommendedBoxType: "Corrugated Kraft Master Carton with Active Ethylene Scavenger",
      recommendedDimensions: "38.0 x 28.0 x 14.0 cm",
      boxVolumeCm3: 14896.0,
      itemVolumeCm3: 11500.0,
      spaceUtilizationPct: 77.2,
      cushioningMaterial: "Honeycomb Recycled Paper Dividers",
      estimatedCost: 12.50,
      sustainabilityScore: 92.0,
      notes: "Multi-ply FSC corrugated master carton with ethylene scavengers.",
    ),
    PackagingRecord(
      id: 103,
      itemName: "Fresh Atlantic Salmon Fillet",
      length: 30.0,
      width: 15.0,
      height: 6.0,
      weight: 1.0,
      isFragile: true,
      ecoFriendly: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 18, minutes: 10)),
      recommendedBoxType: "Expanded PLA Insulated Shipper + Recyclable Gel Packs",
      recommendedDimensions: "30.0 x 15.0 x 6.0 cm",
      boxVolumeCm3: 2700.0,
      itemVolumeCm3: 1800.0,
      spaceUtilizationPct: 66.7,
      cushioningMaterial: "Cellulose Insulation Liner",
      estimatedCost: 8.50,
      sustainabilityScore: 86.0,
      notes: "Strict 0-2°C thermal retention envelope with ultra-low oxygen transmission rate (OTR) bio-laminate barrier.",
    ),
  ];

  static void saveLocalHistoryRecord(PackagingRecord record) {
    _localSessionHistory.insert(0, record);
  }

  static Future<List<PackagingRecord>> getHistory({
    http.Client? client,
  }) async {
    final auth = AuthService();
    if (auth.isOfflineDemo) {
      return [..._localSessionHistory, ..._fallbackHistoryRecords];
    }
    final httpClient = client ?? http.Client();
    final endpoint = auth.isAuthenticated
        ? '$baseUrl/users/me/history'
        : '$baseUrl/packaging/history';
    final headers = auth.authHeaders;

    try {
      final response = await httpClient
          .get(Uri.parse(endpoint), headers: headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        if (list.isNotEmpty) {
          final serverRecords = list.map((item) => PackagingRecord.fromJson(item)).toList();
          return [..._localSessionHistory, ...serverRecords];
        }
      }
    } catch (_) {
      // Offline fallback
    }

    return [..._localSessionHistory, ..._fallbackHistoryRecords];
  }

  static Future<PackagingRecord?> getHistoryDetail(
    int id, {
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final auth = AuthService();
    final headers = auth.authHeaders;

    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/packaging/history/$id'), headers: headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return PackagingRecord.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Offline fallback
    }

    final all = [..._localSessionHistory, ..._fallbackHistoryRecords];
    final matching = all.where((r) => r.id == id);
    return matching.isNotEmpty ? matching.first : null;
  }

  static Future<bool> deleteHistoryRecord(
    int id, {
    http.Client? client,
  }) async {
    _localSessionHistory.removeWhere((r) => r.id == id);
    final httpClient = client ?? http.Client();
    final auth = AuthService();
    final headers = auth.authHeaders;

    try {
      final response = await httpClient
          .delete(Uri.parse('$baseUrl/packaging/history/$id'), headers: headers)
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return true;
    }
  }

  static Future<bool> clearHistory({
    http.Client? client,
  }) async {
    _localSessionHistory.clear();
    final httpClient = client ?? http.Client();
    final auth = AuthService();
    if (!auth.isAuthenticated || auth.isOfflineDemo) {
      return true;
    }
    final headers = auth.authHeaders;

    try {
      final response = await httpClient
          .delete(Uri.parse('$baseUrl/users/me/history'), headers: headers)
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return true;
    }
  }

  static Future<FoodScientificProfile> getScientificProfile(
    int foodId, {
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/data/foods/$foodId/scientific-profile'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return FoodScientificProfile.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Offline fallback
    }

    final matching = defaultCommodities.where((f) => f.id == foodId);
    final name = matching.isNotEmpty ? matching.first.name : "Food #$foodId";
    final category = matching.isNotEmpty ? matching.first.category : "General";
    return getFallbackScientificProfile(name, category: category, foodId: foodId);
  }

  static Future<FoodScientificProfile> lookupScientificProfile(
    String name, {
    String? category,
    int? foodId,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final queryParams = {'name': name};
      if (category != null) queryParams['category'] = category;
      if (foodId != null) queryParams['food_id'] = foodId.toString();

      final uri = Uri.parse('$baseUrl/data/foods/scientific-lookup').replace(queryParameters: queryParams);
      final response = await httpClient.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return FoodScientificProfile.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Offline fallback
    }

    return getFallbackScientificProfile(name, category: category, foodId: foodId);
  }

  static FoodScientificProfile getFallbackScientificProfile(
    String name, {
    String? category,
    int? foodId,
  }) {
    final nameLower = name.toLowerCase();

    if (nameLower.contains('tomato')) {
      return FoodScientificProfile(
        foodId: foodId ?? 3,
        commodityName: "Fresh Tomato",
        scientificName: "Solanum lycopersicum",
        category: "Vegetables",
        physicochemical: const PhysicochemicalTraits(
          moisturePct: 94.5,
          fatPct: 0.2,
          ph: 4.4,
          waterActivity: 0.99,
          moistureSensitivity: "High (Rapid weight loss & shriveling risk)",
          equilibriumRhTargetPct: 90.0,
        ),
        physiologicalKinetics: const PhysiologicalKinetics(
          respirationClass: "Moderate",
          respirationRate5c: 8.0,
          respirationRate20c: 28.0,
          respiratoryQuotient: 0.98,
          ethyleneProductionClass: "Moderate",
          ethyleneProdRate: 4.5,
          ethyleneSensitivity: "High (Epinasty, softening & calyx decay)",
        ),
        atmosphereSensitivities: const AtmosphereSensitivities(
          oxygenSensitivity: "Moderate",
          co2Sensitivity: "Moderate (Max tolerable: 5% CO2)",
          maxTolerableCo2Pct: 5.0,
          targetEmapO2Pct: "3.0 - 5.0%",
          targetEmapCo2Pct: "3.0 - 5.0%",
        ),
        thermalAndStorage: const ThermalAndStorage(
          perishability: "Highly perishable",
          optimumTempMinC: 12.0,
          optimumTempMaxC: 15.0,
          chillingInjuryThresholdC: 10.0,
          freezingPointC: -0.6,
          ambientShelfLifeDays: 7,
          refrigeratedShelfLifeDays: 21,
          controlledAtmosphereShelfLifeDays: 35,
        ),
        spoilageAndVulnerabilities: const SpoilageAndVulnerabilities(
          lightSensitivity: "Low",
          aromaSensitivity: "Low",
          microbialSpoilageVector: "Botrytis cinerea (Gray Mold) & Alternaria",
          mechanicalSensitivity: "High (Bruising & compression cracking)",
        ),
        packagingPrescriptions: const PackagingPrescriptions(
          recommendedBarrierType: "Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)",
          requiredOtrRange: "3000 - 5000 cc/m²/day",
          requiredWvtrRange: "40 - 80 g/m²/day (Anti-fog treated)",
          ethyleneActionRequired: true,
          thermalWarning: "DO NOT store below 10°C to avoid chilling injury (pitting & flavor loss)",
          cushioningDirective: "Molded pulp / Honeycomb kraft tray partitions",
        ),
        source: "ICMR-NIN IFCT 2017 & UC Davis Postharvest Produce Facts",
      );
    } else if (nameLower.contains('spinach')) {
      return FoodScientificProfile(
        foodId: foodId ?? 2,
        commodityName: "Fresh Spinach",
        scientificName: "Spinacia oleracea",
        category: "Vegetables",
        physicochemical: const PhysicochemicalTraits(
          moisturePct: 91.4,
          fatPct: 0.4,
          ph: 6.8,
          waterActivity: 0.99,
          moistureSensitivity: "Extreme (Rapid wilting & leaf desiccation)",
          equilibriumRhTargetPct: 95.0,
        ),
        physiologicalKinetics: const PhysiologicalKinetics(
          respirationClass: "Extremely High",
          respirationRate5c: 22.0,
          respirationRate20c: 110.0,
          respiratoryQuotient: 1.05,
          ethyleneProductionClass: "Very Low",
          ethyleneProdRate: 0.1,
          ethyleneSensitivity: "Extreme (Rapid yellowing & chlorophyll loss)",
        ),
        atmosphereSensitivities: const AtmosphereSensitivities(
          oxygenSensitivity: "High (Rapid O2 depletion risk)",
          co2Sensitivity: "Moderate (Beneficial up to 7-10% CO2)",
          maxTolerableCo2Pct: 10.0,
          targetEmapO2Pct: "1.0 - 3.0%",
          targetEmapCo2Pct: "7.0 - 10.0%",
        ),
        thermalAndStorage: const ThermalAndStorage(
          perishability: "Ultra-perishable (1-3 days ambient)",
          optimumTempMinC: 0.0,
          optimumTempMaxC: 2.0,
          chillingInjuryThresholdC: null,
          freezingPointC: -0.3,
          ambientShelfLifeDays: 2,
          refrigeratedShelfLifeDays: 14,
          controlledAtmosphereShelfLifeDays: 28,
        ),
        spoilageAndVulnerabilities: const SpoilageAndVulnerabilities(
          lightSensitivity: "Moderate (Folate photodegradation)",
          aromaSensitivity: "Low",
          microbialSpoilageVector: "Bacterial soft rot (Pectobacterium carotovorum)",
          mechanicalSensitivity: "High (Leaf crushing)",
        ),
        packagingPrescriptions: const PackagingPrescriptions(
          recommendedBarrierType: "High-Permeability Laser Micro-Perforated PLA Anti-Fog Film",
          requiredOtrRange: "6000 - 9000 cc/m²/day",
          requiredWvtrRange: "50 - 90 g/m²/day",
          ethyleneActionRequired: true,
          thermalWarning: "Maintain strict cold-chain at 0-2°C",
          cushioningDirective: "Breathable pillow pouch with nitrogen cushion",
        ),
        source: "ICMR-NIN IFCT 2017 & USDA Handbook 66",
      );
    } else if (nameLower.contains('chip') || nameLower.contains('crisp')) {
      return FoodScientificProfile(
        foodId: foodId ?? 8,
        commodityName: "Potato Chips (fried)",
        scientificName: "Solanum tuberosum (crisps)",
        category: "Other perishables",
        physicochemical: const PhysicochemicalTraits(
          moisturePct: 2.0,
          fatPct: 33.0,
          ph: 5.8,
          waterActivity: 0.25,
          moistureSensitivity: "Extreme (Crispness loss at moisture > 4.5%)",
          equilibriumRhTargetPct: 30.0,
        ),
        physiologicalKinetics: const PhysiologicalKinetics(
          respirationClass: "Non-respiring processed food",
          respirationRate5c: 0.0,
          respirationRate20c: 0.0,
          respiratoryQuotient: 0.0,
          ethyleneProductionClass: "None",
          ethyleneProdRate: 0.0,
          ethyleneSensitivity: "Insensitive",
        ),
        atmosphereSensitivities: const AtmosphereSensitivities(
          oxygenSensitivity: "Critical (Rapid lipid rancidity & off-flavor)",
          co2Sensitivity: "Tolerant",
          maxTolerableCo2Pct: 100.0,
          targetEmapO2Pct: "< 0.5% (99.5% N2 Flush)",
          targetEmapCo2Pct: "0.0% (Pure Nitrogen)",
        ),
        thermalAndStorage: const ThermalAndStorage(
          perishability: "Shelf-stable (6-9 months hermetic)",
          optimumTempMinC: 18.0,
          optimumTempMaxC: 25.0,
          chillingInjuryThresholdC: null,
          freezingPointC: -10.0,
          ambientShelfLifeDays: 180,
          refrigeratedShelfLifeDays: 270,
          controlledAtmosphereShelfLifeDays: 365,
        ),
        spoilageAndVulnerabilities: const SpoilageAndVulnerabilities(
          lightSensitivity: "Critical (Photo-oxidation accelerates lipid rancidity)",
          aromaSensitivity: "High (Loss of fresh frying aroma)",
          microbialSpoilageVector: "None (a_w 0.25 inhibits microbial growth)",
          mechanicalSensitivity: "Extreme (Severe breakage & shattering)",
        ),
        packagingPrescriptions: const PackagingPrescriptions(
          recommendedBarrierType: "Metallized Bio-PET (Met-PET) with 99.5% N2 Gas Flush",
          requiredOtrRange: "< 0.5 cc/m²/day",
          requiredWvtrRange: "< 0.3 g/m²/day",
          ethyleneActionRequired: false,
          thermalWarning: "Protect from direct heat & sunlight",
          cushioningDirective: "Nitrogen gas headspace pillow buffer (40-50% vol)",
        ),
        source: "USDA FoodData Central & Snack Industry Standards",
      );
    } else if (nameLower.contains('banana')) {
      return FoodScientificProfile(
        foodId: foodId ?? 5,
        commodityName: "Fresh Banana",
        scientificName: "Musa acuminata",
        category: "Fruits",
        physicochemical: const PhysicochemicalTraits(
          moisturePct: 74.9,
          fatPct: 0.3,
          ph: 4.8,
          waterActivity: 0.97,
          moistureSensitivity: "High (Crown rot & desiccation)",
          equilibriumRhTargetPct: 90.0,
        ),
        physiologicalKinetics: const PhysiologicalKinetics(
          respirationClass: "High (Climacteric)",
          respirationRate5c: 10.0,
          respirationRate20c: 45.0,
          respiratoryQuotient: 1.05,
          ethyleneProductionClass: "High",
          ethyleneProdRate: 15.0,
          ethyleneSensitivity: "Extreme (Triggers irreversible climacteric ripening)",
        ),
        atmosphereSensitivities: const AtmosphereSensitivities(
          oxygenSensitivity: "High",
          co2Sensitivity: "Moderate (Beneficial up to 5% CO2)",
          maxTolerableCo2Pct: 5.0,
          targetEmapO2Pct: "2.0 - 5.0%",
          targetEmapCo2Pct: "3.0 - 5.0%",
        ),
        thermalAndStorage: const ThermalAndStorage(
          perishability: "Highly perishable",
          optimumTempMinC: 13.0,
          optimumTempMaxC: 14.0,
          chillingInjuryThresholdC: 13.0,
          freezingPointC: -0.8,
          ambientShelfLifeDays: 5,
          refrigeratedShelfLifeDays: 12,
          controlledAtmosphereShelfLifeDays: 35,
        ),
        spoilageAndVulnerabilities: const SpoilageAndVulnerabilities(
          lightSensitivity: "Low",
          aromaSensitivity: "Moderate",
          microbialSpoilageVector: "Crown rot complex (Colletotrichum, Fusarium)",
          mechanicalSensitivity: "Extreme (Peel scuffing & neck snapping)",
        ),
        packagingPrescriptions: const PackagingPrescriptions(
          recommendedBarrierType: "Modified Atmosphere Polybag with Active KMnO4 Scavenger",
          requiredOtrRange: "1500 - 3000 cc/m²/day",
          requiredWvtrRange: "25 - 50 g/m²/day",
          ethyleneActionRequired: true,
          thermalWarning: "CRITICAL: DO NOT cool below 13°C. Severe chilling injury occurs below 13°C",
          cushioningDirective: "Foam end-caps + corrugated telescopic carton",
        ),
        source: "ICMR-NIN IFCT 2017 & FAO Postharvest Compendium",
      );
    } else if (nameLower.contains('chicken') || nameLower.contains('meat')) {
      return FoodScientificProfile(
        foodId: foodId ?? 7,
        commodityName: "Fresh Chicken Breast",
        scientificName: "Gallus gallus",
        category: "Meat",
        physicochemical: const PhysicochemicalTraits(
          moisturePct: 74.0,
          fatPct: 2.5,
          ph: 5.9,
          waterActivity: 0.99,
          moistureSensitivity: "High (Drip loss)",
          equilibriumRhTargetPct: 98.0,
        ),
        physiologicalKinetics: const PhysiologicalKinetics(
          respirationClass: "Non-respiring meat",
          respirationRate5c: 0.0,
          respirationRate20c: 0.0,
          respiratoryQuotient: 0.0,
          ethyleneProductionClass: "None",
          ethyleneProdRate: 0.0,
          ethyleneSensitivity: "Insensitive",
        ),
        atmosphereSensitivities: const AtmosphereSensitivities(
          oxygenSensitivity: "Critical (Aerobic spoilage & myoglobin oxidation)",
          co2Sensitivity: "Tolerant (High CO2 suppresses bacteria)",
          maxTolerableCo2Pct: 100.0,
          targetEmapO2Pct: "< 0.2%",
          targetEmapCo2Pct: "70.0% CO2 / 30.0% N2",
        ),
        thermalAndStorage: const ThermalAndStorage(
          perishability: "Ultra-perishable",
          optimumTempMinC: -1.0,
          optimumTempMaxC: 2.0,
          chillingInjuryThresholdC: null,
          freezingPointC: -1.7,
          ambientShelfLifeDays: 1,
          refrigeratedShelfLifeDays: 10,
          controlledAtmosphereShelfLifeDays: 21,
        ),
        spoilageAndVulnerabilities: const SpoilageAndVulnerabilities(
          lightSensitivity: "High (Color bleaching)",
          aromaSensitivity: "Moderate",
          microbialSpoilageVector: "Pseudomonas spp. & Enterobacteriaceae",
          mechanicalSensitivity: "Moderate",
        ),
        packagingPrescriptions: const PackagingPrescriptions(
          recommendedBarrierType: "EVOH High-Barrier MAP Tray with Absorbent Drip Pad (70% CO2)",
          requiredOtrRange: "< 0.5 cc/m²/day",
          requiredWvtrRange: "< 1.5 g/m²/day",
          ethyleneActionRequired: false,
          thermalWarning: "Maintain deep-chill at -1°C to +2°C",
          cushioningDirective: "Rigid barrier PP/EVOH/PE tray",
        ),
        source: "ICMR-NIN IFCT 2017 & Meat Science Handbook",
      );
    } else if (nameLower.contains('paneer') || nameLower.contains('dairy') || nameLower.contains('cheese')) {
      return FoodScientificProfile(
        foodId: foodId ?? 6,
        commodityName: "Fresh Paneer",
        scientificName: "Indian Cottage Cheese",
        category: "Dairy",
        physicochemical: const PhysicochemicalTraits(
          moisturePct: 55.0,
          fatPct: 22.0,
          ph: 5.8,
          waterActivity: 0.98,
          moistureSensitivity: "High (Syneresis & moisture loss)",
          equilibriumRhTargetPct: 95.0,
        ),
        physiologicalKinetics: const PhysiologicalKinetics(
          respirationClass: "Non-respiring dairy",
          respirationRate5c: 0.0,
          respirationRate20c: 0.0,
          respiratoryQuotient: 0.0,
          ethyleneProductionClass: "None",
          ethyleneProdRate: 0.0,
          ethyleneSensitivity: "Insensitive",
        ),
        atmosphereSensitivities: const AtmosphereSensitivities(
          oxygenSensitivity: "High (Lipid oxidation & mold)",
          co2Sensitivity: "Tolerant (High CO2 MAP)",
          maxTolerableCo2Pct: 100.0,
          targetEmapO2Pct: "< 0.5%",
          targetEmapCo2Pct: "70.0% CO2 / 30.0% N2",
        ),
        thermalAndStorage: const ThermalAndStorage(
          perishability: "Highly perishable",
          optimumTempMinC: 1.0,
          optimumTempMaxC: 4.0,
          chillingInjuryThresholdC: null,
          freezingPointC: -1.5,
          ambientShelfLifeDays: 1,
          refrigeratedShelfLifeDays: 21,
          controlledAtmosphereShelfLifeDays: 45,
        ),
        spoilageAndVulnerabilities: const SpoilageAndVulnerabilities(
          lightSensitivity: "High (Photo-oxidation of dairy fat)",
          aromaSensitivity: "High (Foreign odor absorption)",
          microbialSpoilageVector: "Psychrotrophic bacteria (Pseudomonas) & yeasts",
          mechanicalSensitivity: "Moderate (Block deforming)",
        ),
        packagingPrescriptions: const PackagingPrescriptions(
          recommendedBarrierType: "High-Barrier EVOH Vacuum Skin Film or 70% CO2 MAP Pouch",
          requiredOtrRange: "< 1.0 cc/m²/day",
          requiredWvtrRange: "< 2.0 g/m²/day",
          ethyleneActionRequired: false,
          thermalWarning: "Strict cold-chain (1-4°C) mandatory throughout logistics",
          cushioningDirective: "Rigid thermoformed barrier tray",
        ),
        source: "ICMR-NIN IFCT 2017 & Dairy Processing Handbook",
      );
    }

    // Default generic profile
    return FoodScientificProfile(
      foodId: foodId ?? 1,
      commodityName: name,
      scientificName: "Specimen ($name)",
      category: category ?? "General",
      physicochemical: const PhysicochemicalTraits(
        moisturePct: 85.5,
        fatPct: 0.3,
        ph: 3.8,
        waterActivity: 0.98,
        moistureSensitivity: "Moderate",
        equilibriumRhTargetPct: 90.0,
      ),
      physiologicalKinetics: const PhysiologicalKinetics(
        respirationClass: "Moderate",
        respirationRate5c: 4.0,
        respirationRate20c: 16.0,
        respiratoryQuotient: 1.0,
        ethyleneProductionClass: "High",
        ethyleneProdRate: 20.0,
        ethyleneSensitivity: "High",
      ),
      atmosphereSensitivities: const AtmosphereSensitivities(
        oxygenSensitivity: "Moderate",
        co2Sensitivity: "Moderate",
        maxTolerableCo2Pct: 3.0,
        targetEmapO2Pct: "2.0 - 4.0%",
        targetEmapCo2Pct: "1.0 - 2.0%",
      ),
      thermalAndStorage: const ThermalAndStorage(
        perishability: "Semi-perishable",
        optimumTempMinC: 0.0,
        optimumTempMaxC: 3.0,
        chillingInjuryThresholdC: null,
        freezingPointC: -1.5,
        ambientShelfLifeDays: 14,
        refrigeratedShelfLifeDays: 90,
        controlledAtmosphereShelfLifeDays: 240,
      ),
      spoilageAndVulnerabilities: const SpoilageAndVulnerabilities(
        lightSensitivity: "Low",
        aromaSensitivity: "Moderate",
        microbialSpoilageVector: "Penicillium expansum & ambient molds",
        mechanicalSensitivity: "Moderate",
      ),
      packagingPrescriptions: const PackagingPrescriptions(
        recommendedBarrierType: "Gas-Permeable Bio-Film with Ethylene Scavenger",
        requiredOtrRange: "2000 - 4000 cc/m²/day",
        requiredWvtrRange: "30 - 60 g/m²/day",
        ethyleneActionRequired: true,
        thermalWarning: "Maintain at 0-2°C",
        cushioningDirective: "Molded pulp cellular tray nests",
      ),
      source: "ICMR-NIN IFCT 2017 & UC Davis Postharvest Facts",
    );
  }

  // ==========================================
  // MODULE 6: PACKAGING MATERIAL DATABASE METHODS
  // ==========================================

  static final List<PackagingMaterialDetail> _inMemoryCustomMaterials = [];

  static Future<List<PackagingMaterialDetail>> getMaterials({
    String? search,
    String? category,
    String? polymerFamily,
    double? maxOtr,
    double? maxWvtr,
    double? minSustainability,
    bool? isBiodegradable,
    bool? isRecyclable,
    bool? isCryogenic,
    bool? isRetort,
    String? costTier,
    String sortBy = 'sustainability_score',
    String sortOrder = 'desc',
    int limit = 50,
    int offset = 0,
  }) async {
    if (AuthService().isOfflineDemo) {
      return _filterFallbackMaterials(
        search: search,
        category: category,
        polymerFamily: polymerFamily,
        maxOtr: maxOtr,
        maxWvtr: maxWvtr,
        minSustainability: minSustainability,
        isBiodegradable: isBiodegradable,
        isRecyclable: isRecyclable,
        isCryogenic: isCryogenic,
        isRetort: isRetort,
        costTier: costTier,
        sortBy: sortBy,
        sortOrder: sortOrder,
        limit: limit,
        offset: offset,
      );
    }
    try {
      final queryParams = <String, String>{
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty && category != 'All') queryParams['category'] = category;
      if (polymerFamily != null && polymerFamily.isNotEmpty) queryParams['polymer_family'] = polymerFamily;
      if (maxOtr != null) queryParams['max_otr'] = maxOtr.toString();
      if (maxWvtr != null) queryParams['max_wvtr'] = maxWvtr.toString();
      if (minSustainability != null) queryParams['min_sustainability'] = minSustainability.toString();
      if (isBiodegradable != null) queryParams['is_biodegradable'] = isBiodegradable.toString();
      if (isRecyclable != null) queryParams['is_recyclable'] = isRecyclable.toString();
      if (isCryogenic != null) queryParams['is_cryogenic'] = isCryogenic.toString();
      if (isRetort != null) queryParams['is_retort'] = isRetort.toString();
      if (costTier != null && costTier.isNotEmpty) queryParams['cost_tier'] = costTier;

      final uri = Uri.parse('$baseUrl/materials').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PackagingMaterialDetail.fromJson(json)).toList();
      }
    } catch (_) {
      // Fallback offline
    }

    // Client-side offline filtering fallback
    return _filterFallbackMaterials(
      search: search,
      category: category,
      polymerFamily: polymerFamily,
      maxOtr: maxOtr,
      maxWvtr: maxWvtr,
      minSustainability: minSustainability,
      isBiodegradable: isBiodegradable,
      isRecyclable: isRecyclable,
      isCryogenic: isCryogenic,
      isRetort: isRetort,
      costTier: costTier,
      sortBy: sortBy,
      sortOrder: sortOrder,
      limit: limit,
      offset: offset,
    );
  }

  static Future<PackagingMaterialDetail?> getMaterialById(String materialId) async {
    try {
      final uri = Uri.parse('$baseUrl/materials/$materialId');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return PackagingMaterialDetail.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    final all = [..._inMemoryCustomMaterials, ...defaultMaterials];
    try {
      return all.firstWhere((m) => m.materialId == materialId || m.id.toString() == materialId);
    } catch (_) {
      return null;
    }
  }

  static Future<PackagingMaterialDetail> createMaterial(PackagingMaterialDetail material) async {
    try {
      final uri = Uri.parse('$baseUrl/materials');
      final payload = {
        'material_id': material.materialId,
        'name': material.name,
        'category': material.category,
        'polymer_family': material.polymerFamily,
        'structure': material.structure,
        'form_factor': material.formFactor,
        'thickness_microns': material.barrierProfile.thicknessMicrons,
        'otr_cc_m2_day': material.barrierProfile.otrCcM2Day,
        'wvtr_g_m2_day': material.barrierProfile.wvtrGM2Day,
        'co2_permeability': material.barrierProfile.co2Permeability,
        'selectivity_beta': material.barrierProfile.selectivityBeta,
        'tensile_strength_mpa': material.mechanicalProfile.tensileStrengthMpa,
        'puncture_resistance_n': material.mechanicalProfile.punctureResistanceN,
        'elongation_pct': material.mechanicalProfile.elongationPct,
        'uv_transmittance_pct': material.opticalProfile.uvTransmittancePct,
        'optical_clarity': material.opticalProfile.opticalClarity,
        'temp_min_c': material.thermalProfile.tempMinC,
        'temp_max_c': material.thermalProfile.tempMaxC,
        'thermal_class': material.thermalProfile.thermalClass,
        'sustainability_score': material.environmentalProfile.sustainabilityScore,
        'recyclability_score': material.environmentalProfile.recyclabilityScore,
        'biodegradability_score': material.environmentalProfile.biodegradabilityScore,
        'resin_code': material.environmentalProfile.resinCode,
        'composting_standard': material.environmentalProfile.compostingStandard,
        'cost_category': material.economicProfile.costCategory,
        'estimated_unit_cost_inr': material.economicProfile.estimatedUnitCostInr,
        'is_breathable': material.functionalFlags['is_breathable'] ?? false,
        'is_biodegradable': material.environmentalProfile.isBiodegradable,
        'is_recyclable': material.environmentalProfile.isRecyclable,
        'is_retort_grade': material.thermalProfile.isRetortGrade,
        'is_cryogenic_grade': material.thermalProfile.isCryogenicGrade,
        'gas_flush_compatible': material.barrierProfile.gasFlushCompatible,
        'recommended_applications': material.recommendedApplications,
        'regulatory_certifications': material.regulatoryCertifications,
        'notes': material.notes,
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final created = PackagingMaterialDetail.fromJson(jsonDecode(response.body));
        _inMemoryCustomMaterials.removeWhere((m) => m.materialId == created.materialId);
        _inMemoryCustomMaterials.insert(0, created);
        return created;
      }
    } catch (_) {}

    _inMemoryCustomMaterials.removeWhere((m) => m.materialId == material.materialId);
    _inMemoryCustomMaterials.insert(0, material);
    return material;
  }

  static Future<MaterialComparisonResult> compareMaterials(List<String> materialIds) async {
    try {
      final uri = Uri.parse('$baseUrl/materials/compare');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'material_ids': materialIds}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return MaterialComparisonResult.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    // Offline comparison synthesis
    final all = [..._inMemoryCustomMaterials, ...defaultMaterials];
    final selected = materialIds
        .map((id) => all.firstWhere((m) => m.materialId == id, orElse: () => all.first))
        .toList();

    final radarMap = {for (var m in selected) m.materialId: m.radarScores};
    final highlights = <String, String>{};
    if (selected.isNotEmpty) {
      selected.sort((a, b) => b.radarScores.barrierScore.compareTo(a.radarScores.barrierScore));
      highlights['Highest Barrier'] = selected.first.name;

      selected.sort((a, b) => b.radarScores.sustainabilityScore.compareTo(a.radarScores.sustainabilityScore));
      highlights['Most Eco-Friendly'] = selected.first.name;

      selected.sort((a, b) => a.economicProfile.estimatedUnitCostInr.compareTo(b.economicProfile.estimatedUnitCostInr));
      highlights['Lowest Cost / Unit'] = selected.first.name;
    }

    final tradeOffs = <String>[];
    if (selected.length >= 2) {
      tradeOffs.add('${selected[0].name} provides tailored barrier performance against ${selected[1].name}.');
    }

    return MaterialComparisonResult(
      materials: selected,
      radarDatasets: radarMap,
      tradeOffAnalysis: tradeOffs,
      bestInClassHighlights: highlights,
    );
  }

  static Future<List<MaterialCategorySummary>> getMaterialCategories() async {
    if (AuthService().isOfflineDemo) {
      final all = [..._inMemoryCustomMaterials, ...defaultMaterials];
      final groups = <String, List<PackagingMaterialDetail>>{};
      for (var m in all) {
        groups.putIfAbsent(m.category, () => []).add(m);
      }

      return groups.entries.map((entry) {
        final avgEco = entry.value.map((m) => m.environmentalProfile.sustainabilityScore).reduce((a, b) => a + b) / entry.value.length;
        return MaterialCategorySummary(
          category: entry.key,
          count: entry.value.length,
          sampleMaterials: entry.value.take(4).map((m) => m.name).toList(),
          averageSustainability: double.parse(avgEco.toStringAsFixed(1)),
          description: 'Collection of ${entry.value.length} ${entry.key.toLowerCase()} options.',
        );
      }).toList();
    }
    try {
      final uri = Uri.parse('$baseUrl/materials/categories');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MaterialCategorySummary.fromJson(json)).toList();
      }
    } catch (_) {}

    // Offline category summary calculation
    final all = [..._inMemoryCustomMaterials, ...defaultMaterials];
    final groups = <String, List<PackagingMaterialDetail>>{};
    for (var m in all) {
      groups.putIfAbsent(m.category, () => []).add(m);
    }

    return groups.entries.map((entry) {
      final avgEco = entry.value.map((m) => m.environmentalProfile.sustainabilityScore).reduce((a, b) => a + b) / entry.value.length;
      return MaterialCategorySummary(
        category: entry.key,
        count: entry.value.length,
        sampleMaterials: entry.value.take(4).map((m) => m.name).toList(),
        averageSustainability: double.parse(avgEco.toStringAsFixed(1)),
        description: 'Collection of ${entry.value.length} ${entry.key.toLowerCase()} options.',
      );
    }).toList();
  }

  static List<PackagingMaterialDetail> _filterFallbackMaterials({
    String? search,
    String? category,
    String? polymerFamily,
    double? maxOtr,
    double? maxWvtr,
    double? minSustainability,
    bool? isBiodegradable,
    bool? isRecyclable,
    bool? isCryogenic,
    bool? isRetort,
    String? costTier,
    String sortBy = 'sustainability_score',
    String sortOrder = 'desc',
    int limit = 50,
    int offset = 0,
  }) {
    var list = [..._inMemoryCustomMaterials, ...defaultMaterials];

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((m) =>
        m.name.toLowerCase().contains(q) ||
        m.category.toLowerCase().contains(q) ||
        m.structure.toLowerCase().contains(q) ||
        m.recommendedApplications.any((a) => a.toLowerCase().contains(q))
      ).toList();
    }

    if (category != null && category.isNotEmpty && category != 'All') {
      list = list.where((m) => m.category.toLowerCase().contains(category.toLowerCase())).toList();
    }

    if (polymerFamily != null && polymerFamily.isNotEmpty) {
      list = list.where((m) => m.polymerFamily.toLowerCase().contains(polymerFamily.toLowerCase())).toList();
    }

    if (maxOtr != null) {
      list = list.where((m) => m.barrierProfile.otrCcM2Day <= maxOtr).toList();
    }

    if (maxWvtr != null) {
      list = list.where((m) => m.barrierProfile.wvtrGM2Day <= maxWvtr).toList();
    }

    if (minSustainability != null) {
      list = list.where((m) => m.environmentalProfile.sustainabilityScore >= minSustainability).toList();
    }

    if (isBiodegradable != null) {
      list = list.where((m) => m.environmentalProfile.isBiodegradable == isBiodegradable).toList();
    }

    if (isRecyclable != null) {
      list = list.where((m) => m.environmentalProfile.isRecyclable == isRecyclable).toList();
    }

    if (isCryogenic != null) {
      list = list.where((m) => m.thermalProfile.isCryogenicGrade == isCryogenic).toList();
    }

    if (isRetort != null) {
      list = list.where((m) => m.thermalProfile.isRetortGrade == isRetort).toList();
    }

    if (costTier != null && costTier.isNotEmpty) {
      list = list.where((m) => m.economicProfile.costCategory.toLowerCase().contains(costTier.toLowerCase())).toList();
    }

    // Sorting
    final isDesc = sortOrder.toLowerCase() == 'desc';
    list.sort((a, b) {
      int cmp;
      if (sortBy == 'otr') {
        cmp = a.barrierProfile.otrCcM2Day.compareTo(b.barrierProfile.otrCcM2Day);
      } else if (sortBy == 'wvtr') {
        cmp = a.barrierProfile.wvtrGM2Day.compareTo(b.barrierProfile.wvtrGM2Day);
      } else if (sortBy == 'cost') {
        cmp = a.economicProfile.estimatedUnitCostInr.compareTo(b.economicProfile.estimatedUnitCostInr);
      } else if (sortBy == 'tensile') {
        cmp = a.mechanicalProfile.tensileStrengthMpa.compareTo(b.mechanicalProfile.tensileStrengthMpa);
      } else if (sortBy == 'name') {
        cmp = a.name.compareTo(b.name);
      } else {
        cmp = a.environmentalProfile.sustainabilityScore.compareTo(b.environmentalProfile.sustainabilityScore);
      }
      return isDesc ? -cmp : cmp;
    });

    if (offset >= list.length) return [];
    final end = (offset + limit) > list.length ? list.length : (offset + limit);
    return list.sublist(offset, end);
  }

  // Static Library of Empirical Materials
  static final List<PackagingMaterialDetail> defaultMaterials = [
    const PackagingMaterialDetail(
      materialId: 'mat_bio_emap_01',
      name: 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)',
      category: 'Biodegradable Bio-Polymer',
      polymerFamily: 'BREATHABLE_BIO_EMAP',
      structure: 'Co-extruded Micro-Perforated PLA/PBAT Blown Film',
      formFactor: 'Perforated Film Pouch',
      barrierProfile: BarrierProfileDetail(
        otrCcM2Day: 3500.0,
        wvtrGM2Day: 45.0,
        co2Permeability: 14000.0,
        selectivityBeta: 4.0,
        thicknessMicrons: 30.0,
        barrierTier: 'Breathable EMAP',
        gasFlushCompatible: true,
      ),
      mechanicalProfile: MechanicalProfile(
        tensileStrengthMpa: 32.0,
        punctureResistanceN: 18.0,
        elongationPct: 220.0,
        formFactor: 'Perforated Film Pouch',
        durabilityRating: 'Moderate',
      ),
      thermalProfile: ThermalProfile(
        tempMinC: 0.0,
        tempMaxC: 40.0,
        thermalClass: 'Refrigerated Stable',
        isCryogenicGrade: false,
        isRetortGrade: false,
      ),
      opticalProfile: OpticalProfile(
        uvTransmittancePct: 15.0,
        opticalClarity: 'Translucent',
        lightBarrierRating: 'Moderate',
      ),
      environmentalProfile: EnvironmentalProfile(
        sustainabilityScore: 94.0,
        recyclabilityScore: 0.0,
        biodegradabilityScore: 98.0,
        isBiodegradable: true,
        isRecyclable: false,
        resinCode: 'OTHER_7',
        compostingStandard: 'EN 13432 / ASTM D6400',
      ),
      economicProfile: EconomicProfile(
        costCategory: 'Commercial Standard',
        estimatedUnitCostInr: 3.85,
        marketScalability: 'Growing Commercial',
      ),
      functionalFlags: {
        'is_breathable': true,
        'is_biodegradable': true,
        'is_recyclable': false,
        'is_retort_grade': false,
        'is_cryogenic_grade': false,
        'gas_flush_compatible': true,
      },
      recommendedApplications: ['Fresh vegetables', 'Climacteric fruits', 'Salad greens', 'Berries'],
      regulatoryCertifications: ['FDA 21 CFR 177', 'EU 10/2011', 'FSSAI Compliant'],
      radarScores: MaterialRadarScores(
        barrierScore: 45.0,
        mechanicalScore: 20.0,
        sustainabilityScore: 94.0,
        thermalScore: 25.0,
        costEfficiencyScore: 65.0,
        opticalScore: 65.0,
      ),
      notes: 'Tailored laser micro-perforations match respiration rates.',
    ),
    const PackagingMaterialDetail(
      materialId: 'mat_al_foil_lam_13',
      name: 'Aluminium Foil Barrier Laminate (PET/AL/PE)',
      category: 'High-Barrier Laminate',
      polymerFamily: 'FOIL_LAMINATE',
      structure: '12µm PET / 9µm Aluminium Foil / 50µm PE',
      formFactor: 'Stand-up Barrier Pouch',
      barrierProfile: BarrierProfileDetail(
        otrCcM2Day: 0.05,
        wvtrGM2Day: 0.05,
        thicknessMicrons: 71.0,
        barrierTier: 'Hermetic Zero-Permeation',
        gasFlushCompatible: true,
      ),
      mechanicalProfile: MechanicalProfile(
        tensileStrengthMpa: 88.0,
        punctureResistanceN: 52.0,
        elongationPct: 45.0,
        formFactor: 'Stand-up Barrier Pouch',
        durabilityRating: 'High',
      ),
      thermalProfile: ThermalProfile(
        tempMinC: -20.0,
        tempMaxC: 100.0,
        thermalClass: 'Thermal Fill & Frozen',
        isCryogenicGrade: false,
        isRetortGrade: false,
      ),
      opticalProfile: OpticalProfile(
        uvTransmittancePct: 0.0,
        opticalClarity: 'Opaque Silver',
        lightBarrierRating: 'Total Block',
      ),
      environmentalProfile: EnvironmentalProfile(
        sustainabilityScore: 28.0,
        recyclabilityScore: 10.0,
        biodegradabilityScore: 0.0,
        isBiodegradable: false,
        isRecyclable: false,
        resinCode: 'OTHER_7',
      ),
      economicProfile: EconomicProfile(
        costCategory: 'Premium Barrier',
        estimatedUnitCostInr: 4.80,
        marketScalability: 'High',
      ),
      functionalFlags: {
        'is_breathable': false,
        'is_biodegradable': false,
        'is_recyclable': false,
        'is_retort_grade': false,
        'is_cryogenic_grade': false,
        'gas_flush_compatible': true,
      },
      recommendedApplications: ['Potato chips', 'Milk powder', 'Roasted coffee', 'Spices'],
      regulatoryCertifications: ['FDA 21 CFR 177.1520', 'FSSAI IS 9845'],
      radarScores: MaterialRadarScores(
        barrierScore: 99.0,
        mechanicalScore: 55.0,
        sustainabilityScore: 28.0,
        thermalScore: 75.0,
        costEfficiencyScore: 57.0,
        opticalScore: 95.0,
      ),
      notes: 'Absolute zero gas and moisture permeation barrier.',
    ),
    const PackagingMaterialDetail(
      materialId: 'mat_sbs_paperboard_22',
      name: 'Solid Bleached Sulfate (SBS) Virgin Paperboard',
      category: 'Cellulosic & Fiber Board',
      polymerFamily: 'CELLULOSIC_BOARD',
      structure: '100% Virgin Bleached Chemical Wood Pulp with Clay Coating',
      formFactor: 'Folding Carton Box',
      barrierProfile: BarrierProfileDetail(
        otrCcM2Day: 600.0,
        wvtrGM2Day: 180.0,
        thicknessMicrons: 350.0,
        barrierTier: 'Moderate Barrier',
        gasFlushCompatible: false,
      ),
      mechanicalProfile: MechanicalProfile(
        tensileStrengthMpa: 48.0,
        punctureResistanceN: 92.0,
        elongationPct: 4.0,
        formFactor: 'Folding Carton Box',
        durabilityRating: 'High',
      ),
      thermalProfile: ThermalProfile(
        tempMinC: -25.0,
        tempMaxC: 120.0,
        thermalClass: 'Freezer to Oven Board',
        isCryogenicGrade: true,
        isRetortGrade: false,
      ),
      opticalProfile: OpticalProfile(
        uvTransmittancePct: 0.0,
        opticalClarity: 'Opaque White',
        lightBarrierRating: 'Total Block',
      ),
      environmentalProfile: EnvironmentalProfile(
        sustainabilityScore: 92.0,
        recyclabilityScore: 95.0,
        biodegradabilityScore: 90.0,
        isBiodegradable: true,
        isRecyclable: true,
        resinCode: 'PAP_21',
        compostingStandard: 'EN 13432 / Recyclable Paper',
      ),
      economicProfile: EconomicProfile(
        costCategory: 'Commercial Standard',
        estimatedUnitCostInr: 2.90,
        marketScalability: 'High',
      ),
      functionalFlags: {
        'is_breathable': true,
        'is_biodegradable': true,
        'is_recyclable': true,
        'is_retort_grade': false,
        'is_cryogenic_grade': true,
        'gas_flush_compatible': false,
      },
      recommendedApplications: ['Frozen food outer cartons', 'Bakery boxes', 'Confectionery'],
      regulatoryCertifications: ['FDA 21 CFR 176.170', 'FSSAI Food Contact'],
      radarScores: MaterialRadarScores(
        barrierScore: 15.0,
        mechanicalScore: 62.0,
        sustainabilityScore: 92.0,
        thermalScore: 85.0,
        costEfficiencyScore: 74.0,
        opticalScore: 95.0,
      ),
      notes: 'High stiffness premium board with superior printability.',
    ),
    const PackagingMaterialDetail(
      materialId: 'mat_pp_clamshell_06',
      name: 'Polypropylene (PP) Thermoformed Clamshell',
      category: 'Conventional Polymer',
      polymerFamily: 'PP',
      structure: 'Thermoformed Clarified Homopolymer PP Sheet',
      formFactor: 'Hinged Clamshell Container',
      barrierProfile: BarrierProfileDetail(
        otrCcM2Day: 120.0,
        wvtrGM2Day: 4.5,
        thicknessMicrons: 450.0,
        barrierTier: 'Moderate Barrier',
        gasFlushCompatible: false,
      ),
      mechanicalProfile: MechanicalProfile(
        tensileStrengthMpa: 36.0,
        punctureResistanceN: 68.0,
        elongationPct: 150.0,
        formFactor: 'Hinged Clamshell Container',
        durabilityRating: 'High',
      ),
      thermalProfile: ThermalProfile(
        tempMinC: 0.0,
        tempMaxC: 125.0,
        thermalClass: 'Microwave Safe',
        isCryogenicGrade: false,
        isRetortGrade: false,
      ),
      opticalProfile: OpticalProfile(
        uvTransmittancePct: 35.0,
        opticalClarity: 'Clarified Translucent',
        lightBarrierRating: 'Moderate',
      ),
      environmentalProfile: EnvironmentalProfile(
        sustainabilityScore: 58.0,
        recyclabilityScore: 85.0,
        biodegradabilityScore: 0.0,
        isBiodegradable: false,
        isRecyclable: true,
        resinCode: 'PP_5',
      ),
      economicProfile: EconomicProfile(
        costCategory: 'Budget Economy',
        estimatedUnitCostInr: 2.10,
        marketScalability: 'High',
      ),
      functionalFlags: {
        'is_breathable': false,
        'is_biodegradable': false,
        'is_recyclable': true,
        'is_retort_grade': false,
        'is_cryogenic_grade': false,
        'gas_flush_compatible': false,
      },
      recommendedApplications: ['Hot meal takeout', 'Bakery sweets', 'Fresh produce clamshells'],
      regulatoryCertifications: ['FDA 21 CFR 177.1520', 'FSSAI IS 10910'],
      radarScores: MaterialRadarScores(
        barrierScore: 48.0,
        mechanicalScore: 46.0,
        sustainabilityScore: 58.0,
        thermalScore: 78.0,
        costEfficiencyScore: 81.0,
        opticalScore: 65.0,
      ),
      notes: 'Microwavable and dishwasher safe reusable rigid container.',
    ),
    const PackagingMaterialDetail(
      materialId: 'mat_retort_acid_24',
      name: 'Multi-layer Retort Pouch (PET/AL/PA/CPP)',
      category: 'Retort Barrier',
      polymerFamily: 'RETORT_LAMINATE',
      structure: '12µm PET / 9µm Aluminium Foil / 15µm BOPA / 70µm Retort Cast PP',
      formFactor: 'Four-Layer Retort Stand-up Pouch',
      barrierProfile: BarrierProfileDetail(
        otrCcM2Day: 0.01,
        wvtrGM2Day: 0.01,
        thicknessMicrons: 106.0,
        barrierTier: 'Hermetic Zero-Permeation',
        gasFlushCompatible: true,
      ),
      mechanicalProfile: MechanicalProfile(
        tensileStrengthMpa: 110.0,
        punctureResistanceN: 95.0,
        elongationPct: 65.0,
        formFactor: 'Four-Layer Retort Stand-up Pouch',
        durabilityRating: 'High',
      ),
      thermalProfile: ThermalProfile(
        tempMinC: -20.0,
        tempMaxC: 135.0,
        thermalClass: 'Autoclave Retort Sterilization',
        isCryogenicGrade: false,
        isRetortGrade: true,
      ),
      opticalProfile: OpticalProfile(
        uvTransmittancePct: 0.0,
        opticalClarity: 'Opaque Silver',
        lightBarrierRating: 'Total Block',
      ),
      environmentalProfile: EnvironmentalProfile(
        sustainabilityScore: 22.0,
        recyclabilityScore: 5.0,
        biodegradabilityScore: 0.0,
        isBiodegradable: false,
        isRecyclable: false,
        resinCode: 'OTHER_7',
      ),
      economicProfile: EconomicProfile(
        costCategory: 'High-Tech Specialty',
        estimatedUnitCostInr: 6.20,
        marketScalability: 'High',
      ),
      functionalFlags: {
        'is_breathable': false,
        'is_biodegradable': false,
        'is_recyclable': false,
        'is_retort_grade': true,
        'is_cryogenic_grade': false,
        'gas_flush_compatible': true,
      },
      recommendedApplications: ['Ready-to-eat curries', 'Sterilized gravies', 'MRE field rations'],
      regulatoryCertifications: ['FDA 21 CFR 177.1390', 'FSSAI Retort Compliant'],
      radarScores: MaterialRadarScores(
        barrierScore: 100.0,
        mechanicalScore: 84.0,
        sustainabilityScore: 22.0,
        thermalScore: 100.0,
        costEfficiencyScore: 44.0,
        opticalScore: 95.0,
      ),
      notes: 'Endures 121°C autoclave thermal counter-pressure sterilization.',
    ),
  ];

  // =========================================================================
  // Module 9: 3-Material Packaging Comparison Service Integration
  // =========================================================================

  /// Compares up to 3 packaging materials via HTTP POST /api/v1/packaging/compare
  /// with automatic fallback to offline scientific matrix generation.
  static Future<PackagingComparisonResultModel> comparePackagingMaterials(
    List<String> materialIds, {
    int? foodId,
    String? foodName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/packaging/compare');
      final payload = {
        'material_ids': materialIds.take(3).toList(),
        if (foodId != null) 'food_id': foodId,
        if (foodName != null) 'food_name': foodName,
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PackagingComparisonResultModel.fromJson(data);
      } else {
        print('Notice: /packaging/compare returned status ${response.statusCode}. Using offline fallback.');
        return generateOfflinePackagingComparison(materialIds, foodId: foodId, foodName: foodName);
      }
    } catch (e) {
      print('Notice: Network error on /packaging/compare ($e). Using offline fallback.');
      return generateOfflinePackagingComparison(materialIds, foodId: foodId, foodName: foodName);
    }
  }

  /// Synthesizes a realistic 3-material comparative matrix offline using empirical material specs.
  static PackagingComparisonResultModel generateOfflinePackagingComparison(
    List<String> materialIds, {
    int? foodId,
    String? foodName,
  }) {
    // 1. Resolve material details from default catalog
    final allAvailable = [..._inMemoryCustomMaterials, ...defaultMaterials];
    final List<PackagingMaterialDetail> matchedMaterials = [];

    for (final matId in materialIds.take(3)) {
      PackagingMaterialDetail? found;
      for (final m in allAvailable) {
        if (!matchedMaterials.contains(m) &&
            (m.materialId.toLowerCase() == matId.toLowerCase() ||
             m.name.toLowerCase().contains(matId.toLowerCase()))) {
          found = m;
          break;
        }
      }
      if (found == null) {
        // Find any available material not yet picked
        for (final m in allAvailable) {
          if (!matchedMaterials.contains(m)) {
            found = m;
            break;
          }
        }
      }
      if (found != null && !matchedMaterials.contains(found)) {
        matchedMaterials.add(found);
      }
    }

    // Ensure at least 2 materials are available
    while (matchedMaterials.length < 2 && allAvailable.isNotEmpty) {
      for (final candidate in allAvailable) {
        if (!matchedMaterials.contains(candidate)) {
          matchedMaterials.add(candidate);
          if (matchedMaterials.length >= 2) break;
        }
      }
      if (matchedMaterials.length < 2) break;
    }

    // 2. Build 3 Slots
    final slotIds = ['material_a', 'material_b', 'material_c'];
    final slotColors = [
      const Color(0xFF0D9488), // Teal
      const Color(0xFF0284C7), // Sky
      const Color(0xFFD97706), // Amber
    ];

    final List<MaterialComparisonSlot> slots = [];
    for (int i = 0; i < matchedMaterials.length; i++) {
      final mat = matchedMaterials[i];
      final isPrimary = (i == 0);

      // Qualitative mappings
      final wvtr = mat.barrierProfile.wvtrGM2Day;
      final otr = mat.barrierProfile.otrCcM2Day;
      final isBreathable = mat.functionalFlags['is_breathable'] ?? false;
      final isRecyclable = mat.environmentalProfile.isRecyclable;
      final isBio = mat.environmentalProfile.isBiodegradable;
      final tensile = mat.mechanicalProfile.tensileStrengthMpa;
      final cost = mat.economicProfile.estimatedUnitCostInr;

      final moistureTier = wvtr <= 1.0 ? 'High' : (wvtr <= 35.0 ? 'Medium' : (isBreathable ? 'High' : 'Low'));
      final oxygenTier = otr <= 500.0 ? 'High' : (otr <= 2500.0 ? 'Medium' : (isBreathable ? 'Medium' : 'Low'));
      final gasTier = isBreathable || otr > 2500.0 ? 'High' : (otr >= 100.0 ? 'Medium' : 'Low');
      final strengthTier = tensile >= 30.0 ? 'High' : (tensile >= 18.0 ? 'Medium' : 'Low');
      final recyclabilityTier = isBio ? 'Biodegradable' : (isRecyclable ? 'Yes' : 'No');
      final costTier = cost <= 2.50 ? 'Low' : (cost <= 4.20 ? 'Medium' : 'High');

      slots.add(
        MaterialComparisonSlot(
          slotId: slotIds[i],
          materialId: mat.materialId,
          name: mat.name,
          category: mat.category,
          polymerFamily: mat.polymerFamily,
          structure: mat.structure,
          colorToken: slotColors[i],
          isPrimaryRecommendation: isPrimary,
          moistureBarrier: moistureTier,
          oxygenBarrier: oxygenTier,
          gasExchange: gasTier,
          strength: strengthTier,
          recyclability: recyclabilityTier,
          costCategory: costTier,
          wvtrValue: wvtr,
          otrValue: otr,
          tensileStrengthMpa: tensile,
          estimatedCostInr: cost,
          sustainabilityScore: mat.environmentalProfile.sustainabilityScore,
          suitabilityScore: isPrimary ? 0.94 : (i == 1 ? 0.82 : 0.70),
          suitabilityCategory: isPrimary ? 'Optimal Match' : (i == 1 ? 'High Compatibility' : 'Moderate Compatibility'),
          starRating: isPrimary ? 5 : (i == 1 ? 4 : 3),
        ),
      );
    }

    // 3. Build 6 Parameter Rows
    final List<ComparisonParameterRowModel> parameterRows = [
      ComparisonParameterRowModel(
        parameterKey: 'moisture_barrier',
        parameterLabel: 'Moisture Barrier',
        parameterGroup: 'Barrier Performance',
        unit: 'g/m²/day',
        values: {for (final s in slots) s.slotId: s.moistureBarrier},
        rawNumericValues: {for (final s in slots) s.slotId: s.wvtrValue},
        bestSlotId: slots.reduce((a, b) => a.wvtrValue <= b.wvtrValue ? a : b).slotId,
        scientificNote: 'Lower WVTR prevents product dehydration or moisture-induced sogginess.',
      ),
      ComparisonParameterRowModel(
        parameterKey: 'oxygen_barrier',
        parameterLabel: 'Oxygen Barrier',
        parameterGroup: 'Barrier Performance',
        unit: 'cc/m²/day',
        values: {for (final s in slots) s.slotId: s.oxygenBarrier},
        rawNumericValues: {for (final s in slots) s.slotId: s.otrValue},
        bestSlotId: slots.reduce((a, b) => a.otrValue <= b.otrValue ? a : b).slotId,
        scientificNote: 'Lower OTR prevents oxidative rancidity and enzymatic discoloration.',
      ),
      ComparisonParameterRowModel(
        parameterKey: 'gas_exchange',
        parameterLabel: 'Gas Exchange',
        parameterGroup: 'Respiration & Atmosphere',
        unit: 'Selectivity β',
        values: {for (final s in slots) s.slotId: s.gasExchange},
        bestSlotId: slots.reduce((a, b) => a.otrValue >= b.otrValue ? a : b).slotId,
        scientificNote: 'Permselectivity regulates O2/CO2 balance to prevent anaerobic fermentation.',
      ),
      ComparisonParameterRowModel(
        parameterKey: 'strength',
        parameterLabel: 'Strength',
        parameterGroup: 'Mechanical Performance',
        unit: 'MPa',
        values: {for (final s in slots) s.slotId: s.strength},
        rawNumericValues: {for (final s in slots) s.slotId: s.tensileStrengthMpa},
        bestSlotId: slots.reduce((a, b) => a.tensileStrengthMpa >= b.tensileStrengthMpa ? a : b).slotId,
        scientificNote: 'High tensile strength resists punctures and bursting during transport.',
      ),
      ComparisonParameterRowModel(
        parameterKey: 'recyclability',
        parameterLabel: 'Recyclability',
        parameterGroup: 'Environmental Circularity',
        unit: 'RIC / Standard',
        values: {for (final s in slots) s.slotId: s.recyclability},
        bestSlotId: slots.reduce((a, b) => a.sustainabilityScore >= b.sustainabilityScore ? a : b).slotId,
        scientificNote: 'Identifies curbside mechanical recycling or certified industrial/home compostability.',
      ),
      ComparisonParameterRowModel(
        parameterKey: 'cost_category',
        parameterLabel: 'Cost Category',
        parameterGroup: 'Economic Profile',
        unit: 'INR (₹)',
        values: {for (final s in slots) s.slotId: s.costCategory},
        rawNumericValues: {for (final s in slots) s.slotId: s.estimatedCostInr},
        bestSlotId: slots.reduce((a, b) => a.estimatedCostInr <= b.estimatedCostInr ? a : b).slotId,
        scientificNote: 'Commercial procurement cost per unit package in INR.',
      ),
    ];

    // 4. Best-in-class highlights
    final Map<String, String> bestSummary = {};
    for (final row in parameterRows) {
      if (row.bestSlotId != null) {
        final match = slots.firstWhere((s) => s.slotId == row.bestSlotId);
        bestSummary[row.parameterLabel] = match.name;
      }
    }

    final slotA = slots[0];
    final slotB = slots[1];
    final slotC = slots.length > 2 ? slots[2] : null;

    final foodPrefix = foodName != null ? 'For $foodName, ' : 'In this comparative matrix, ';
    final narrative = '$foodPrefix${slotA.name} provides ${slotA.moistureBarrier.toLowerCase()} moisture barrier and ${slotA.gasExchange.toLowerCase()} gas exchange. ${slotB.name} delivers ${slotB.strength.toLowerCase()} strength at ₹${slotB.estimatedCostInr.toStringAsFixed(2)}/unit.${slotC != null ? ' Meanwhile, ${slotC.name} achieves ${slotC.oxygenBarrier.toLowerCase()} oxygen barrier.' : ''}';

    final rule = 'Choose ${slotA.name} for target preservation fit; Choose ${slotB.name} for cost efficiency.${slotC != null ? ' Choose ${slotC.name} for specialized barrier integrity.' : ''}';

    return PackagingComparisonResultModel(
      comparisonId: 'cmp_offline_${DateTime.now().millisecondsSinceEpoch}',
      foodContextName: foodName,
      slots: slots,
      parameterRows: parameterRows,
      bestInClassSummary: bestSummary,
      aiTradeOffSynthesis: narrative,
      keyRecommendationRule: rule,
    );
  }

  /// Module 10: Calculate Packaging Cost & Material Footprint
  /// Connects to POST /api/v1/packaging/cost-estimate with seamless offline fallback.
  static Future<CostEstimationResponse> calculateCostEstimate(CostEstimationRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/packaging/cost-estimate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CostEstimationResponse.fromJson(data);
      } else {
        debugPrint('Warning: /cost-estimate API error (${response.statusCode}). Using offline calculation engine.');
        return OfflineCostEngine.calculateCostEstimate(request);
      }
    } catch (e) {
      debugPrint('Notice: /cost-estimate network error ($e). Falling back to offline cost calculation engine.');
      return OfflineCostEngine.calculateCostEstimate(request);
    }
  }

  /// Module 11: Get Verified Sustainability Profile
  /// Connects to GET /api/v1/sustainability/materials/{id} with seamless offline fallback.
  static Future<SustainabilityProfile> getSustainabilityProfile(
    String materialId, {
    String packageType = 'Stand-up Doypack (Bottom Gusset)',
    int batchSize = 10000,
    double pcrPercentage = 0.0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/sustainability/materials/$materialId').replace(queryParameters: {
        'package_type': packageType,
        'batch_size': batchSize.toString(),
        'pcr_percentage': pcrPercentage.toString(),
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SustainabilityProfile.fromJson(data);
      } else {
        debugPrint('Warning: /sustainability/materials API error (${response.statusCode}). Using offline engine.');
        return OfflineSustainabilityEngine.evaluate(SustainabilityEvaluateInput(
          materialId: materialId,
          packageType: packageType,
          batchSizeUnits: batchSize,
          pcrPercentage: pcrPercentage,
        ));
      }
    } catch (e) {
      debugPrint('Notice: /sustainability network error ($e). Falling back to offline sustainability engine.');
      return OfflineSustainabilityEngine.evaluate(SustainabilityEvaluateInput(
        materialId: materialId,
        packageType: packageType,
        batchSizeUnits: batchSize,
        pcrPercentage: pcrPercentage,
      ));
    }
  }

  /// Module 11: Parametric Sustainability & LCA Evaluation
  /// Connects to POST /api/v1/sustainability/evaluate with seamless offline fallback.
  static Future<SustainabilityProfile> evaluateSustainability(SustainabilityEvaluateInput input) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/sustainability/evaluate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(input.toJson()),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SustainabilityProfile.fromJson(data);
      } else {
        debugPrint('Warning: /sustainability/evaluate API error (${response.statusCode}). Using offline engine.');
        return OfflineSustainabilityEngine.evaluate(input);
      }
    } catch (e) {
      debugPrint('Notice: /sustainability/evaluate network error ($e). Falling back to offline engine.');
      return OfflineSustainabilityEngine.evaluate(input);
    }
  }

  /// Module 11: Multi-Material Sustainability Comparison
  /// Connects to POST /api/v1/sustainability/compare with seamless offline fallback.
  static Future<SustainabilityCompareResult> compareSustainability({
    required List<String> materialIds,
    String packageType = 'Stand-up Doypack (Bottom Gusset)',
    double lengthCm = 18.0,
    double widthCm = 12.0,
    double depthOrGussetCm = 4.0,
    double thicknessMicrons = 50.0,
    int batchSizeUnits = 10000,
  }) async {
    try {
      final payload = {
        'material_ids': materialIds,
        'package_type': packageType,
        'length_cm': lengthCm,
        'width_cm': widthCm,
        'depth_or_gusset_cm': depthOrGussetCm,
        'thickness_microns': thicknessMicrons,
        'batch_size_units': batchSizeUnits,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/sustainability/compare'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SustainabilityCompareResult.fromJson(data);
      } else {
        debugPrint('Warning: /sustainability/compare API error (${response.statusCode}). Using offline engine.');
        return OfflineSustainabilityEngine.compare(
          materialIds: materialIds,
          packageType: packageType,
          lengthCm: lengthCm,
          widthCm: widthCm,
          depthOrGussetCm: depthOrGussetCm,
          thicknessMicrons: thicknessMicrons,
          batchSizeUnits: batchSizeUnits,
        );
      }
    } catch (e) {
      debugPrint('Notice: /sustainability/compare network error ($e). Falling back to offline engine.');
      return OfflineSustainabilityEngine.compare(
        materialIds: materialIds,
        packageType: packageType,
        lengthCm: lengthCm,
        widthCm: widthCm,
        depthOrGussetCm: depthOrGussetCm,
        thicknessMicrons: thicknessMicrons,
        batchSizeUnits: batchSizeUnits,
      );
    }
  }

  // --------------------------------------------------------------------------
  // MODULE 12: RECOMMENDATION REPORT & EXPORT METHODS
  // --------------------------------------------------------------------------

  /// Generates a complete RecommendationReportModel from backend or fallback client synthesizer.
  static Future<RecommendationReportModel> generateReport({
    required PackagingRecommendationResult result,
    required PackagingInput input,
    SustainabilityProfile? sustainabilityProfile,
    CostEstimationResponse? costResponse,
    int batchSize = 10000,
    double pcrPercentage = 0.0,
  }) async {
    try {
      final payload = {
        'food_name': input.itemName,
        'category': input.category,
        'fill_quantity': '${input.weight.toStringAsFixed(0)}g',
        'batch_size_units': batchSize,
        'length_cm': input.length,
        'width_cm': input.width,
        'depth_or_gusset_cm': input.height,
        'thickness_microns': result.primaryRecommendation.barrierProfile.thicknessMicrons,
        'pcr_percentage': pcrPercentage,
        'target_shelf_life_days': input.storageDurationDays ?? 180,
        'storage_condition': input.storageCondition ?? 'Ambient Standard',
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/reports/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RecommendationReportModel.fromJson(data);
      } else {
        debugPrint('Warning: /reports/generate API error (${response.statusCode}). Using client synthesizer.');
        return ReportGeneratorService.synthesizeReport(
          result: result,
          input: input,
          sustainabilityProfile: sustainabilityProfile,
          costResponse: costResponse,
          batchSize: batchSize,
          pcrPercentage: pcrPercentage,
        );
      }
    } catch (e) {
      debugPrint('Notice: /reports/generate network error ($e). Falling back to client synthesizer.');
      return ReportGeneratorService.synthesizeReport(
        result: result,
        input: input,
        sustainabilityProfile: sustainabilityProfile,
        costResponse: costResponse,
        batchSize: batchSize,
        pcrPercentage: pcrPercentage,
      );
    }
  }

  /// Retrieves a report by unique report ID with fallback.
  static Future<RecommendationReportModel> getReportById(String reportId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/reports/$reportId'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RecommendationReportModel.fromJson(data);
      } else {
        throw Exception('Report not found');
      }
    } catch (e) {
      debugPrint('Notice: /reports/$reportId network error ($e). Returning fallback report.');
      final fallbackInput = PackagingInput(
        itemName: 'Packaged Food Commodity',
        category: 'General Food',
        weight: 500.0,
        isFragile: false,
        ecoFriendly: true,
      );
      final fallbackResult = PackagingRecommendationResult(
        recommendedBoxType: 'Monomaterial Stand-Up Pouch',
        recommendedDimensions: '18.0 x 12.0 x 4.0 cm',
        boxVolumeCm3: 864.0,
        itemVolumeCm3: 500.0,
        spaceUtilizationPct: 80.0,
        cushioningMaterial: 'None',
        estimatedCost: 3.50,
        sustainabilityScore: 85.0,
      );
      return ReportGeneratorService.synthesizeReport(
        result: fallbackResult,
        input: fallbackInput,
        customReportId: reportId,
      );
    }
  }
}



