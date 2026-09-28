import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_model.dart';
import 'auth_service.dart';

/// Admin API Service for system-wide governance, analytics, catalog maintenance, and AI rules (Module 15).
class AdminApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/admin';

  final http.Client _client;

  AdminApiService({http.Client? client}) : _client = client ?? http.Client();

  // ==========================================
  // In-Memory Fallback Store (Offline / Demo Admin)
  // ==========================================

  static RuleThresholdConfigModel _mockRules = const RuleThresholdConfigModel();
  static bool _mockMlEnabled = true;

  static final List<AdminFoodDetailModel> _mockFoods = [
    const AdminFoodDetailModel(
      id: 1,
      name: 'Fresh Tomato',
      category: 'Produce',
      scientificName: 'Solanum lycopersicum',
      moisture: 94.5,
      ph: 4.3,
      fat: 0.2,
      waterActivity: 0.99,
      respirationClass: 'High',
      oxygenSensitivity: 'Moderate',
      moistureSensitivity: 'High',
      scientificProperties: {
        'respiration_rate_20c': 32.0,
        'respiration_rate_5c': 8.5,
        'chilling_injury_threshold_c': 10.0,
        'optimum_temp_min_c': 12.0,
        'optimum_temp_max_c': 15.0,
        'ambient_shelf_life_days': 7,
        'refrigerated_shelf_life_days': 21,
      },
    ),
    const AdminFoodDetailModel(
      id: 2,
      name: 'Fresh Apple',
      category: 'Produce',
      scientificName: 'Malus domestica',
      moisture: 85.5,
      ph: 3.6,
      fat: 0.2,
      waterActivity: 0.98,
      respirationClass: 'Moderate',
      oxygenSensitivity: 'Moderate',
      moistureSensitivity: 'Moderate',
      scientificProperties: {
        'respiration_rate_20c': 16.0,
        'respiration_rate_5c': 4.2,
        'chilling_injury_threshold_c': 0.0,
        'optimum_temp_min_c': 0.0,
        'optimum_temp_max_c': 4.0,
        'ambient_shelf_life_days': 14,
        'refrigerated_shelf_life_days': 90,
      },
    ),
    const AdminFoodDetailModel(
      id: 3,
      name: 'Potato Chips',
      category: 'Snacks & Wafers',
      scientificName: 'Solanum tuberosum processed',
      moisture: 2.5,
      ph: 6.2,
      fat: 34.0,
      waterActivity: 0.25,
      respirationClass: 'Non-respiring',
      oxygenSensitivity: 'Critical',
      moistureSensitivity: 'Critical',
      scientificProperties: {
        'respiration_rate_20c': 0.0,
        'optimum_temp_min_c': 15.0,
        'optimum_temp_max_c': 25.0,
        'ambient_shelf_life_days': 180,
      },
    ),
    const AdminFoodDetailModel(
      id: 4,
      name: 'Fresh Paneer',
      category: 'Dairy & Sweets',
      scientificName: 'Dairy curd coagulum',
      moisture: 54.0,
      ph: 5.8,
      fat: 22.0,
      waterActivity: 0.96,
      respirationClass: 'Low',
      oxygenSensitivity: 'High',
      moistureSensitivity: 'High',
      scientificProperties: {
        'respiration_rate_20c': 2.5,
        'optimum_temp_min_c': 0.0,
        'optimum_temp_max_c': 4.0,
        'ambient_shelf_life_days': 2,
        'refrigerated_shelf_life_days': 14,
      },
    ),
    const AdminFoodDetailModel(
      id: 5,
      name: 'Alphonso Mango',
      category: 'Produce',
      scientificName: 'Mangifera indica',
      moisture: 84.0,
      ph: 4.1,
      fat: 0.4,
      waterActivity: 0.98,
      respirationClass: 'High',
      oxygenSensitivity: 'Moderate',
      moistureSensitivity: 'High',
      scientificProperties: {
        'respiration_rate_20c': 35.0,
        'respiration_rate_5c': 10.0,
        'chilling_injury_threshold_c': 12.0,
        'optimum_temp_min_c': 13.0,
        'optimum_temp_max_c': 15.0,
        'ambient_shelf_life_days': 8,
        'refrigerated_shelf_life_days': 24,
      },
    ),
  ];

  static final List<AdminMaterialItemModel> _mockMaterials = [
    const AdminMaterialItemModel(
      id: 1,
      materialId: 'mat_bio_emap_01',
      name: 'Micro-Perforated Bio-Film (PLA/PBAT)',
      category: 'Biodegradable Bio-Polymer',
      polymerFamily: 'BREATHABLE_BIO_EMAP',
      structure: 'Monolayer 30 µm',
      formFactor: 'Flexible Pouch',
      thicknessMicrons: 30.0,
      otr: 4500.0,
      wvtr: 65.0,
      co2Permeability: 18000.0,
      selectivityBeta: 4.0,
      tensileStrengthMpa: 32.0,
      punctureResistanceN: 18.0,
      sustainabilityScore: 96.0,
      recyclabilityScore: 70.0,
      biodegradabilityScore: 100.0,
      estimatedUnitCostInr: 3.85,
      isBreathable: true,
      isBiodegradable: true,
      isRecyclable: false,
      gasFlushCompatible: false,
      isActiveEntry: true,
    ),
    const AdminMaterialItemModel(
      id: 2,
      materialId: 'mat_kraft_corrugated_02',
      name: 'Corrugated Kraft Box (5-Ply)',
      category: 'Paper & Fiber Board',
      polymerFamily: 'CELLULOSE_KRAFT_LINED',
      structure: 'Kraft / Flute / Kraft',
      formFactor: 'Rigid Carton',
      thicknessMicrons: 400.0,
      sustainabilityScore: 96.5,
      recyclabilityScore: 100.0,
      biodegradabilityScore: 95.0,
      estimatedUnitCostInr: 3.10,
      isBreathable: true,
      isBiodegradable: true,
      isRecyclable: true,
      isActiveEntry: true,
    ),
    const AdminMaterialItemModel(
      id: 3,
      materialId: 'mat_barrier_metpet_03',
      name: 'Metallized High-Barrier Bio-PET (Met-PET)',
      category: 'Metallized Film',
      polymerFamily: 'METALLIZED_BARRIER',
      structure: 'PET / Alu-Oxide / PE',
      formFactor: 'Pillow Pouch',
      thicknessMicrons: 25.0,
      otr: 0.65,
      wvtr: 0.85,
      sustainabilityScore: 88.0,
      recyclabilityScore: 60.0,
      biodegradabilityScore: 0.0,
      estimatedUnitCostInr: 2.95,
      gasFlushCompatible: true,
      isActiveEntry: true,
    ),
    const AdminMaterialItemModel(
      id: 4,
      materialId: 'mat_evoh_vsp_04',
      name: 'High-Barrier EVOH Vacuum Skin Film',
      category: 'Multi-Layer Co-Extrusion',
      polymerFamily: 'HIGH_BARRIER_EVOH_VSP',
      structure: 'PE / EVOH / PE',
      formFactor: 'Thermoformed Skin',
      thicknessMicrons: 70.0,
      otr: 0.40,
      wvtr: 1.20,
      sustainabilityScore: 82.0,
      recyclabilityScore: 65.0,
      biodegradabilityScore: 0.0,
      estimatedUnitCostInr: 5.40,
      gasFlushCompatible: true,
      isActiveEntry: true,
    ),
  ];

  static final List<AdminRecommendationAuditModel> _mockAuditLogs = [
    AdminRecommendationAuditModel(
      id: 1,
      userId: 1,
      userEmail: 'engineer@smartpack.io',
      itemName: 'Fresh Tomato',
      length: 12.0,
      width: 10.0,
      height: 15.0,
      weight: 0.45,
      isFragile: true,
      ecoFriendly: true,
      recommendedBoxType: 'Corrugated Kraft Box (5-Ply)',
      recommendedDimensions: '15x12x18 cm',
      cushioningMaterial: 'Honeycomb Kraft Partitions',
      estimatedCost: 3.10,
      sustainabilityScore: 96.5,
      notes: 'Optimal high respiration bio-barrier',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      formattedDate: '27 Sep 2026',
    ),
    AdminRecommendationAuditModel(
      id: 2,
      userId: 2,
      userEmail: 'auditor@packtech.io',
      itemName: 'Fresh Apple',
      length: 8.5,
      width: 8.5,
      height: 9.0,
      weight: 0.20,
      isFragile: false,
      ecoFriendly: true,
      recommendedBoxType: 'Molded Pulp Tray with Bio-Film',
      recommendedDimensions: '10x10x12 cm',
      cushioningMaterial: 'Molded Recycled Fiber Nest',
      estimatedCost: 2.85,
      sustainabilityScore: 94.0,
      notes: 'Cold chain stability preserved',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      formattedDate: '26 Sep 2026',
    ),
  ];

  static void resetMockStore() {
    _mockRules = const RuleThresholdConfigModel();
    _mockMlEnabled = true;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = AuthService().token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ==========================================
  // 1. Analytics & Trends Methods
  // ==========================================

  Future<AdminAnalyticsSummaryModel> getAnalyticsSummary() async {
    try {
      final res = await _client.get(
        Uri.parse('$baseUrl/analytics/summary'),
        headers: _getHeaders(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminAnalyticsSummaryModel.fromJson(data);
      }
    } catch (_) {}

    // Offline / Demo Fallback
    return AdminAnalyticsSummaryModel(
      totalAnalyses: 1420,
      totalUsers: 85,
      totalFoodsCount: _mockFoods.length,
      totalMaterialsCount: _mockMaterials.length,
      ecoPreferencePct: 82.6,
      averageSystemScore: 91.4,
      topFoods: const [
        FoodSearchStatModel(name: 'Fresh Tomato', category: 'Produce', queryCount: 48, sharePct: 33.8),
        FoodSearchStatModel(name: 'Alphonso Mango', category: 'Produce', queryCount: 31, sharePct: 21.8),
        FoodSearchStatModel(name: 'Potato Chips', category: 'Snacks & Wafers', queryCount: 26, sharePct: 18.3),
        FoodSearchStatModel(name: 'Fresh Paneer', category: 'Dairy & Sweets', queryCount: 21, sharePct: 14.8),
        FoodSearchStatModel(name: 'Digestive Biscuit', category: 'Biscuits & Bakery', queryCount: 16, sharePct: 11.3),
      ],
      topMaterials: const [
        MaterialRecommendStatModel(
          materialName: 'Micro-Perforated Bio-Film (PLA/PBAT)',
          polymerFamily: 'BREATHABLE_BIO_EMAP',
          recommendCount: 62,
          sharePct: 43.6,
          averageScore: 95.5,
        ),
        MaterialRecommendStatModel(
          materialName: 'Corrugated Kraft Box (5-Ply)',
          polymerFamily: 'CELLULOSE_KRAFT_LINED',
          recommendCount: 38,
          sharePct: 26.8,
          averageScore: 96.0,
        ),
      ],
      trends: List.generate(7, (i) {
        final day = DateTime.now().subtract(Duration(days: 6 - i));
        final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        return DailyUsageTrendModel(
          date: dayStr,
          totalAnalyses: 35 + (i * 4),
          ecoAnalyses: 28 + (i * 3),
          avgSustainabilityScore: 91.0 + (i * 0.4),
          avgCostInr: 3.10 + (i * 0.05),
        );
      }),
    );
  }

  Future<List<DailyUsageTrendModel>> getAnalyticsTrends() async {
    final summary = await getAnalyticsSummary();
    return summary.trends;
  }

  // ==========================================
  // 2. Food Management Methods
  // ==========================================

  Future<List<AdminFoodItemModel>> listFoods({String? search, String? category}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
        queryParams['category'] = category;
      }
      final uri = Uri.parse('$baseUrl/foods').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final res = await _client.get(uri, headers: _getHeaders());

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((e) => AdminFoodItemModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // Offline / Mock Filter
    return _mockFoods
        .where((f) {
          if (search != null && !f.name.toLowerCase().contains(search.toLowerCase())) return false;
          if (category != null && category.toLowerCase() != 'all' && !f.category.toLowerCase().contains(category.toLowerCase())) {
            return false;
          }
          return true;
        })
        .map((f) => AdminFoodItemModel(
              id: f.id,
              name: f.name,
              category: f.category,
              scientificName: f.scientificName,
              moisture: f.moisture,
              ph: f.ph,
              fat: f.fat,
              waterActivity: f.waterActivity,
              respirationClass: f.respirationClass,
              oxygenSensitivity: f.oxygenSensitivity,
              moistureSensitivity: f.moistureSensitivity,
            ))
        .toList();
  }

  Future<AdminFoodDetailModel?> getFoodById(int foodId) async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/foods/$foodId'), headers: _getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminFoodDetailModel.fromJson(data);
      }
    } catch (_) {}

    return _mockFoods.firstWhere((f) => f.id == foodId, orElse: () => _mockFoods.first);
  }

  Future<AdminFoodDetailModel> createFood(Map<String, dynamic> payload) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/foods'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminFoodDetailModel.fromJson(data);
      }
    } catch (_) {}

    final newId = _mockFoods.length + 10;
    final model = AdminFoodDetailModel(
      id: newId,
      name: payload['name'] as String? ?? 'New Food',
      category: payload['category'] as String? ?? 'Produce',
      scientificName: payload['scientific_name'] as String?,
      moisture: (payload['moisture'] as num? ?? 80.0).toDouble(),
      ph: (payload['ph'] as num? ?? 5.0).toDouble(),
      fat: (payload['fat'] as num? ?? 1.0).toDouble(),
      respirationClass: payload['respiration_class'] as String? ?? 'Moderate',
    );
    _mockFoods.add(model);
    return model;
  }

  Future<AdminFoodDetailModel?> updateFood(int foodId, Map<String, dynamic> payload) async {
    try {
      final res = await _client.put(
        Uri.parse('$baseUrl/foods/$foodId'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminFoodDetailModel.fromJson(data);
      }
    } catch (_) {}

    final index = _mockFoods.indexWhere((f) => f.id == foodId);
    if (index != -1) {
      final old = _mockFoods[index];
      final updated = AdminFoodDetailModel(
        id: old.id,
        name: payload['name'] as String? ?? old.name,
        category: payload['category'] as String? ?? old.category,
        scientificName: payload['scientific_name'] as String? ?? old.scientificName,
        moisture: payload['moisture'] != null ? (payload['moisture'] as num).toDouble() : old.moisture,
        ph: payload['ph'] != null ? (payload['ph'] as num).toDouble() : old.ph,
        fat: payload['fat'] != null ? (payload['fat'] as num).toDouble() : old.fat,
        respirationClass: payload['respiration_class'] as String? ?? old.respirationClass,
        scientificProperties: old.scientificProperties,
      );
      _mockFoods[index] = updated;
      return updated;
    }
    return null;
  }

  Future<AdminFoodDetailModel?> updateFoodScientificProperties(int foodId, Map<String, dynamic> payload) async {
    try {
      final res = await _client.put(
        Uri.parse('$baseUrl/foods/$foodId/scientific-properties'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminFoodDetailModel.fromJson(data);
      }
    } catch (_) {}

    final index = _mockFoods.indexWhere((f) => f.id == foodId);
    if (index != -1) {
      final old = _mockFoods[index];
      final newProps = Map<String, dynamic>.from(old.scientificProperties ?? {});
      payload.forEach((k, v) {
        if (v != null) newProps[k] = v;
      });
      final updated = AdminFoodDetailModel(
        id: old.id,
        name: old.name,
        category: old.category,
        scientificName: old.scientificName,
        moisture: old.moisture,
        ph: old.ph,
        fat: old.fat,
        respirationClass: old.respirationClass,
        scientificProperties: newProps,
      );
      _mockFoods[index] = updated;
      return updated;
    }
    return null;
  }

  Future<bool> deleteFood(int foodId) async {
    try {
      final res = await _client.delete(Uri.parse('$baseUrl/foods/$foodId'), headers: _getHeaders());
      if (res.statusCode == 204) {
        _mockFoods.removeWhere((f) => f.id == foodId);
        return true;
      }
    } catch (_) {}

    _mockFoods.removeWhere((f) => f.id == foodId);
    return true;
  }

  // ==========================================
  // 3. Packaging Material Methods
  // ==========================================

  Future<List<AdminMaterialItemModel>> listMaterials({
    String? search,
    String? category,
    String? polymerFamily,
    bool? activeOnly,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
        queryParams['category'] = category;
      }
      if (polymerFamily != null && polymerFamily.isNotEmpty && polymerFamily.toLowerCase() != 'all') {
        queryParams['polymer_family'] = polymerFamily;
      }
      if (activeOnly != null) queryParams['active_only'] = activeOnly.toString();

      final uri = Uri.parse('$baseUrl/materials').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final res = await _client.get(uri, headers: _getHeaders());

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((e) => AdminMaterialItemModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return _mockMaterials.where((m) {
      if (activeOnly == true && !m.isActiveEntry) return false;
      if (search != null && !m.name.toLowerCase().contains(search.toLowerCase()) && !m.materialId.toLowerCase().contains(search.toLowerCase())) {
        return false;
      }
      if (category != null && category.toLowerCase() != 'all' && !m.category.toLowerCase().contains(category.toLowerCase())) {
        return false;
      }
      if (polymerFamily != null && polymerFamily.toLowerCase() != 'all' && !m.polymerFamily.toLowerCase().contains(polymerFamily.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<AdminMaterialItemModel?> getMaterialById(int matId) async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/materials/$matId'), headers: _getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminMaterialItemModel.fromJson(data);
      }
    } catch (_) {}

    return _mockMaterials.firstWhere((m) => m.id == matId, orElse: () => _mockMaterials.first);
  }

  Future<AdminMaterialItemModel> createMaterial(Map<String, dynamic> payload) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/materials'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminMaterialItemModel.fromJson(data);
      }
    } catch (_) {}

    final newId = _mockMaterials.length + 10;
    final model = AdminMaterialItemModel(
      id: newId,
      materialId: payload['material_id'] as String? ?? 'mat_custom_$newId',
      name: payload['name'] as String? ?? 'New Substrate',
      category: payload['category'] as String? ?? 'Biodegradable Bio-Polymer',
      polymerFamily: payload['polymer_family'] as String? ?? 'BREATHABLE_BIO_EMAP',
      thicknessMicrons: (payload['thickness_microns'] as num? ?? 30.0).toDouble(),
      sustainabilityScore: (payload['sustainability_score'] as num? ?? 90.0).toDouble(),
      estimatedUnitCostInr: (payload['estimated_unit_cost_inr'] as num? ?? 3.50).toDouble(),
      isActiveEntry: payload['is_active_entry'] as bool? ?? true,
    );
    _mockMaterials.add(model);
    return model;
  }

  Future<AdminMaterialItemModel?> updateMaterial(int matId, Map<String, dynamic> payload) async {
    try {
      final res = await _client.put(
        Uri.parse('$baseUrl/materials/$matId'),
        headers: _getHeaders(),
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminMaterialItemModel.fromJson(data);
      }
    } catch (_) {}

    final index = _mockMaterials.indexWhere((m) => m.id == matId);
    if (index != -1) {
      final old = _mockMaterials[index];
      final updated = AdminMaterialItemModel(
        id: old.id,
        materialId: old.materialId,
        name: payload['name'] as String? ?? old.name,
        category: payload['category'] as String? ?? old.category,
        polymerFamily: payload['polymer_family'] as String? ?? old.polymerFamily,
        structure: payload['structure'] as String? ?? old.structure,
        formFactor: payload['form_factor'] as String? ?? old.formFactor,
        thicknessMicrons: payload['thickness_microns'] != null ? (payload['thickness_microns'] as num).toDouble() : old.thicknessMicrons,
        otr: payload['otr_cc_m2_day'] != null ? (payload['otr_cc_m2_day'] as num).toDouble() : old.otr,
        wvtr: payload['wvtr_g_m2_day'] != null ? (payload['wvtr_g_m2_day'] as num).toDouble() : old.wvtr,
        sustainabilityScore: payload['sustainability_score'] != null ? (payload['sustainability_score'] as num).toDouble() : old.sustainabilityScore,
        estimatedUnitCostInr: payload['estimated_unit_cost_inr'] != null ? (payload['estimated_unit_cost_inr'] as num).toDouble() : old.estimatedUnitCostInr,
        isActiveEntry: payload['is_active_entry'] as bool? ?? old.isActiveEntry,
      );
      _mockMaterials[index] = updated;
      return updated;
    }
    return null;
  }

  Future<AdminMaterialItemModel?> toggleMaterialStatus(int matId) async {
    try {
      final res = await _client.patch(
        Uri.parse('$baseUrl/materials/$matId/toggle-status'),
        headers: _getHeaders(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AdminMaterialItemModel.fromJson(data);
      }
    } catch (_) {}

    final index = _mockMaterials.indexWhere((m) => m.id == matId);
    if (index != -1) {
      final old = _mockMaterials[index];
      final updated = AdminMaterialItemModel(
        id: old.id,
        materialId: old.materialId,
        name: old.name,
        category: old.category,
        polymerFamily: old.polymerFamily,
        thicknessMicrons: old.thicknessMicrons,
        sustainabilityScore: old.sustainabilityScore,
        estimatedUnitCostInr: old.estimatedUnitCostInr,
        isActiveEntry: !old.isActiveEntry,
      );
      _mockMaterials[index] = updated;
      return updated;
    }
    return null;
  }

  Future<bool> deleteMaterial(int matId) async {
    try {
      final res = await _client.delete(Uri.parse('$baseUrl/materials/$matId'), headers: _getHeaders());
      if (res.statusCode == 204) {
        _mockMaterials.removeWhere((m) => m.id == matId);
        return true;
      }
    } catch (_) {}

    _mockMaterials.removeWhere((m) => m.id == matId);
    return true;
  }

  // ==========================================
  // 4. Rules & Model Governance Methods
  // ==========================================

  Future<RuleThresholdConfigModel> getRules() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/rules'), headers: _getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _mockRules = RuleThresholdConfigModel.fromJson(data);
        return _mockRules;
      }
    } catch (_) {}

    return _mockRules;
  }

  Future<RuleThresholdConfigModel> updateRules(RuleThresholdConfigModel payload) async {
    try {
      final res = await _client.put(
        Uri.parse('$baseUrl/rules'),
        headers: _getHeaders(),
        body: jsonEncode(payload.toJson()),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _mockRules = RuleThresholdConfigModel.fromJson(data);
        return _mockRules;
      }
    } catch (_) {}

    _mockRules = payload;
    return _mockRules;
  }

  Future<ModelRegistryModel> getModelRegistry() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/models/active'), headers: _getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ModelRegistryModel.fromJson(data);
      }
    } catch (_) {}

    return ModelRegistryModel(
      activeModelName: 'RandomForest-v2.3-18D',
      algorithm: 'Random Forest Ensemble (100 Estimators)',
      featureDimension: 18,
      accuracyScore: 0.984,
      isMlEnabled: _mockMlEnabled,
      isHeuristicFallbackActive: true,
      lastTrainedAt: DateTime.now().subtract(const Duration(days: 7)),
      versionTag: 'v2.3.0-prod',
    );
  }

  Future<ModelRegistryModel> toggleMlMode() async {
    try {
      final res = await _client.patch(Uri.parse('$baseUrl/models/toggle-ml'), headers: _getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ModelRegistryModel.fromJson(data);
      }
    } catch (_) {}

    _mockMlEnabled = !_mockMlEnabled;
    return getModelRegistry();
  }

  // ==========================================
  // 5. Recommendations Audit Method
  // ==========================================

  Future<List<AdminRecommendationAuditModel>> getRecommendationsAudit({int limit = 50, int offset = 0}) async {
    try {
      final res = await _client.get(
        Uri.parse('$baseUrl/recommendations/audit?limit=$limit&offset=$offset'),
        headers: _getHeaders(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((e) => AdminRecommendationAuditModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return _mockAuditLogs;
  }
}
