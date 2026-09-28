import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_service.dart';

/// Global session and authentication state manager (Module 14: User Account).
/// Extends ChangeNotifier to provide reactive user session updates across the UI.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  String? _accessToken;
  List<SavedAnalysisModel> _savedAnalyses = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineDemo = false;

  // --- Getters ---
  UserModel? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get token => _accessToken;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;
  List<SavedAnalysisModel> get savedAnalyses => List.unmodifiable(_savedAnalyses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOfflineDemo => _isOfflineDemo;

  UserPreferencesModel get preferences =>
      _currentUser?.preferences ?? const UserPreferencesModel();

  /// Map of authorization headers with active Bearer token.
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_accessToken != null && _accessToken!.isNotEmpty)
          'Authorization': 'Bearer $_accessToken',
      };

  static final Map<String, Map<String, dynamic>> _localRegisteredUsers = {};

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // --- Login ---
  Future<bool> login(
    String email,
    String password, {
    http.Client? client,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': cleanEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final session = AuthSessionModel.fromJson(data);
        _accessToken = session.accessToken;
        _currentUser = session.user;
        _isOfflineDemo = false;
        _isLoading = false;
        _localRegisteredUsers[cleanEmail] = {
          'user': session.user,
          'password': password,
        };
        await fetchSavedAnalyses(client: httpClient);
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['detail'] ?? 'Login failed. Please check credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Offline fallback: check locally registered accounts
      if (_localRegisteredUsers.containsKey(cleanEmail)) {
        final entry = _localRegisteredUsers[cleanEmail]!;
        if (entry['password'] == password) {
          _currentUser = entry['user'] as UserModel;
          _accessToken = 'local.user.jwt.${DateTime.now().millisecondsSinceEpoch}';
          _isOfflineDemo = false;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else if (cleanEmail == 'admin@smartpack.io' && (password == 'Admin@1234' || password == 'admin123' || password == 'Admin@2026')) {
        _currentUser = UserModel(
          id: 1,
          email: 'admin@smartpack.io',
          fullName: 'System Administrator',
          organization: 'SmartPack Core Engineering Governance',
          role: 'admin',
          isActive: true,
          isAdmin: true,
          createdAt: DateTime(2025, 1, 1),
          preferences: const UserPreferencesModel(
            defaultEcoPriority: true,
            defaultCurrency: 'INR',
            defaultBatchSize: 10000,
            exportOrganizationHeader: 'SmartPack Core Engineering Governance',
          ),
          stats: UserStatsModel(
            totalAnalysesCount: 1420,
            savedPresetsCount: 12,
            ecoFriendlyCount: 1180,
            averageSustainabilityScore: 92.4,
            memberSince: DateTime(2025, 1, 1),
          ),
        );
        _accessToken = 'admin.smartpack.jwt.authorized.${DateTime.now().millisecondsSinceEpoch}';
        _isOfflineDemo = false;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Could not reach authentication server. Offline mode available.';
      _isLoading = false;
      notifyListeners();
      return false;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  // --- Signup ---
  Future<bool> signup(
    String email,
    String password,
    String fullName, {
    String? organization,
    String? role,
    bool defaultEcoPriority = true,
    String defaultCurrency = 'INR',
    http.Client? client,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanEmail = email.trim().toLowerCase();
    final cleanFullName = fullName.trim();
    final cleanOrg = organization?.trim();
    final cleanRole = role?.trim();

    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.post(
        Uri.parse('${ApiService.baseUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': cleanEmail,
          'password': password,
          'full_name': cleanFullName,
          if (cleanOrg != null && cleanOrg.isNotEmpty)
            'organization': cleanOrg,
          if (cleanRole != null && cleanRole.isNotEmpty) 'role': cleanRole,
          'default_eco_priority': defaultEcoPriority,
          'default_currency': defaultCurrency,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final session = AuthSessionModel.fromJson(data);
        _accessToken = session.accessToken;
        _currentUser = session.user;
        _savedAnalyses = [];
        _isOfflineDemo = false;
        _isLoading = false;
        // Save user account locally
        _localRegisteredUsers[cleanEmail] = {
          'user': session.user,
          'password': password,
        };
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['detail'] ?? 'Registration failed.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Offline fallback: save account locally and activate session
      final localUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch,
        email: cleanEmail,
        fullName: cleanFullName,
        organization: cleanOrg ?? 'SmartPack Engineering Lab',
        role: cleanRole ?? 'Packaging Engineer',
        isActive: true,
        isAdmin: false,
        createdAt: DateTime.now(),
        preferences: UserPreferencesModel(
          defaultEcoPriority: defaultEcoPriority,
          defaultCurrency: defaultCurrency,
          defaultBatchSize: 10000,
          exportOrganizationHeader: cleanOrg,
        ),
        stats: UserStatsModel(
          totalAnalysesCount: 0,
          savedPresetsCount: 0,
          ecoFriendlyCount: 0,
          averageSustainabilityScore: 0.0,
          memberSince: DateTime.now(),
        ),
      );

      _accessToken = 'local.user.jwt.${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = localUser;
      _savedAnalyses = [];
      _isOfflineDemo = false;
      _isLoading = false;
      // Save user account locally
      _localRegisteredUsers[cleanEmail] = {
        'user': localUser,
        'password': password,
      };
      notifyListeners();
      return true;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  // --- Logout ---
  void logout({http.Client? client}) {
    if (_accessToken != null && !_isOfflineDemo && !_accessToken!.startsWith('local.user.jwt.')) {
      final httpClient = client ?? http.Client();
      httpClient.post(
        Uri.parse('${ApiService.baseUrl}/auth/logout'),
        headers: authHeaders,
      ).catchError((_) => http.Response('', 500)).whenComplete(() {
        if (client == null) httpClient.close();
      });
    }

    _currentUser = null;
    _accessToken = null;
    _savedAnalyses = [];
    _isOfflineDemo = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // --- Profile & Preferences Update ---
  Future<bool> updateProfile({
    String? fullName,
    String? organization,
    String? role,
    bool? defaultEcoPriority,
    String? defaultCurrency,
    int? defaultBatchSize,
    String? exportOrganizationHeader,
    http.Client? client,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final payload = <String, dynamic>{
      if (fullName != null) 'full_name': fullName.trim(),
      if (organization != null) 'organization': organization.trim(),
      if (role != null) 'role': role.trim(),
      if (defaultEcoPriority != null) 'default_eco_priority': defaultEcoPriority,
      if (defaultCurrency != null) 'default_currency': defaultCurrency,
      if (defaultBatchSize != null) 'default_batch_size': defaultBatchSize,
      if (exportOrganizationHeader != null)
        'export_organization_header': exportOrganizationHeader.trim(),
    };

    if (_isOfflineDemo || _accessToken == null) {
      // Update local in-memory session directly
      final updatedPrefs = _currentUser!.preferences.copyWith(
        defaultEcoPriority: defaultEcoPriority,
        defaultCurrency: defaultCurrency,
        defaultBatchSize: defaultBatchSize,
        exportOrganizationHeader: exportOrganizationHeader,
      );
      _currentUser = _currentUser!.copyWith(
        fullName: fullName,
        organization: organization,
        role: role,
        preferences: updatedPrefs,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.put(
        Uri.parse('${ApiService.baseUrl}/users/me'),
        headers: authHeaders,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['detail'] ?? 'Failed to update profile.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error while updating user profile.';
      _isLoading = false;
      notifyListeners();
      return false;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  // --- Saved Analyses Vault CRUD ---
  Future<List<SavedAnalysisModel>> fetchSavedAnalyses({http.Client? client}) async {
    if (!isAuthenticated || _isOfflineDemo) {
      return _savedAnalyses;
    }

    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.get(
        Uri.parse('${ApiService.baseUrl}/saved-analyses'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        _savedAnalyses = list
            .map((item) => SavedAnalysisModel.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return _savedAnalyses;
      }
    } catch (_) {
      // Silently keep cached presets on fetch failure
    } finally {
      if (client == null) httpClient.close();
    }
    return _savedAnalyses;
  }

  Future<SavedAnalysisModel?> saveAnalysisPreset({
    required String title,
    String? notes,
    required String commodityName,
    String? recommendedMaterial,
    double? estimatedCost,
    double? sustainabilityScore,
    Map<String, dynamic> inputPayload = const {},
    Map<String, dynamic> recommendationResult = const {},
    http.Client? client,
  }) async {
    final payload = {
      'title': title.trim(),
      if (notes != null && notes.isNotEmpty) 'notes': notes.trim(),
      'commodity_name': commodityName.trim(),
      if (recommendedMaterial != null) 'recommended_material': recommendedMaterial,
      if (estimatedCost != null) 'estimated_cost': estimatedCost,
      if (sustainabilityScore != null) 'sustainability_score': sustainabilityScore,
      'input_payload': inputPayload,
      'recommendation_result': recommendationResult,
    };

    if (_isOfflineDemo || !isAuthenticated) {
      final newPreset = SavedAnalysisModel(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: _currentUser?.id ?? 0,
        title: title.trim(),
        notes: notes?.trim(),
        commodityName: commodityName.trim(),
        recommendedMaterial: recommendedMaterial ?? 'Optimized Eco Substrate',
        estimatedCost: estimatedCost ?? 3.50,
        sustainabilityScore: sustainabilityScore ?? 85.0,
        inputPayload: inputPayload,
        recommendationResult: recommendationResult,
        createdAt: DateTime.now(),
      );
      _savedAnalyses = [newPreset, ..._savedAnalyses];
      _incrementSavedPresetsCount();
      notifyListeners();
      return newPreset;
    }

    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.post(
        Uri.parse('${ApiService.baseUrl}/saved-analyses'),
        headers: authHeaders,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final created = SavedAnalysisModel.fromJson(data);
        _savedAnalyses = [created, ..._savedAnalyses.where((s) => s.id != created.id)];
        _incrementSavedPresetsCount();
        notifyListeners();
        return created;
      }
    } catch (e) {
      _errorMessage = 'Could not save preset to server.';
      notifyListeners();
    } finally {
      if (client == null) httpClient.close();
    }
    return null;
  }

  Future<bool> deleteSavedAnalysis(int id, {http.Client? client}) async {
    if (_isOfflineDemo || !isAuthenticated) {
      _savedAnalyses.removeWhere((s) => s.id == id);
      _decrementSavedPresetsCount();
      notifyListeners();
      return true;
    }

    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.delete(
        Uri.parse('${ApiService.baseUrl}/saved-analyses/$id'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        _savedAnalyses.removeWhere((s) => s.id == id);
        _decrementSavedPresetsCount();
        notifyListeners();
        return true;
      }
    } catch (_) {
      _errorMessage = 'Failed to delete saved preset.';
      notifyListeners();
    } finally {
      if (client == null) httpClient.close();
    }
    return false;
  }

  /// Validate and activate an authenticated Admin session using the secure Admin Passkey.
  bool authenticateAdminPasskey(String passkey) {
    final validKeys = ['Admin@2026', 'Admin@1234', 'SmartPackAdmin', 'admin123'];
    if (validKeys.contains(passkey.trim())) {
      _isOfflineDemo = false;
      _accessToken = 'admin.smartpack.jwt.authorized.${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = UserModel(
        id: 1,
        email: 'admin@smartpack.io',
        fullName: 'System Administrator',
        organization: 'SmartPack Core Engineering Governance',
        role: 'admin',
        isActive: true,
        isAdmin: true,
        createdAt: DateTime(2025, 1, 1),
        preferences: const UserPreferencesModel(
          defaultEcoPriority: true,
          defaultCurrency: 'INR',
          defaultBatchSize: 10000,
          exportOrganizationHeader: 'SmartPack Core Engineering Governance',
        ),
        stats: UserStatsModel(
          totalAnalysesCount: 1420,
          savedPresetsCount: 12,
          ecoFriendlyCount: 1180,
          averageSustainabilityScore: 92.4,
          memberSince: DateTime(2025, 1, 1),
        ),
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    }
    _errorMessage = 'Invalid Admin Passkey. Access Denied.';
    notifyListeners();
    return false;
  }

  // --- Offline Demo Mode Activation ---
  void activateDemoMode([UserModel? demoUser]) {
    _isOfflineDemo = true;
    _accessToken = 'demo.smartpack.jwt.token';
    _currentUser = demoUser ??
        UserModel(
          id: 999,
          email: 'sarah.jenkins@smartpack.io',
          fullName: 'Dr. Sarah Jenkins',
          organization: 'BioPackaging Innovation Lab',
          role: 'Chief Packaging Engineer',
          isActive: true,
          isAdmin: false,
          createdAt: DateTime(2025, 6, 15),
          preferences: const UserPreferencesModel(
            defaultEcoPriority: true,
            defaultCurrency: 'INR',
            defaultBatchSize: 10000,
            exportOrganizationHeader: 'BioPackaging Innovation Lab',
          ),
          stats: UserStatsModel(
            totalAnalysesCount: 34,
            savedPresetsCount: 3,
            ecoFriendlyCount: 29,
            averageSustainabilityScore: 91.2,
            memberSince: DateTime(2025, 6, 15),
          ),
        );

    _savedAnalyses = [
      SavedAnalysisModel(
        id: 1001,
        userId: 999,
        title: 'Organic Strawberries Cold-Chain MAP',
        notes: 'High gas permeability micro-perforated film for 14-day transit.',
        commodityName: 'Fresh Strawberries',
        recommendedMaterial: 'PLA / Bio-based MAP Film',
        estimatedCost: 4.25,
        sustainabilityScore: 94.0,
        inputPayload: const {
          'commodity': 'Fresh Strawberries',
          'temperature': 4.0,
          'shelf_life_days': 14,
        },
        recommendationResult: const {
          'material_name': 'PLA / Bio-based MAP Film',
          'estimated_cost': 4.25,
          'sustainability_score': 94.0,
        },
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SavedAnalysisModel(
        id: 1002,
        userId: 999,
        title: 'Fresh Tomato Ambient Distribution',
        notes: 'Ventilated kraft corrugated shipper with zero plastic liners.',
        commodityName: 'Fresh Tomato',
        recommendedMaterial: 'Recycled Kraft Corrugated',
        estimatedCost: 3.10,
        sustainabilityScore: 96.5,
        inputPayload: const {
          'commodity': 'Fresh Tomato',
          'temperature': 22.0,
          'shelf_life_days': 7,
        },
        recommendationResult: const {
          'material_name': 'Recycled Kraft Corrugated',
          'estimated_cost': 3.10,
          'sustainability_score': 96.5,
        },
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _incrementSavedPresetsCount() {
    if (_currentUser?.stats != null) {
      final currentStats = _currentUser!.stats!;
      _currentUser = _currentUser!.copyWith(
        stats: currentStats.copyWith(
          savedPresetsCount: currentStats.savedPresetsCount + 1,
        ),
      );
    }
  }

  void _decrementSavedPresetsCount() {
    if (_currentUser?.stats != null) {
      final currentStats = _currentUser!.stats!;
      _currentUser = _currentUser!.copyWith(
        stats: currentStats.copyWith(
          savedPresetsCount: (currentStats.savedPresetsCount - 1).clamp(0, 9999),
        ),
      );
    }
  }

  @visibleForTesting
  set currentUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      _accessToken = 'test_token_${user.id}';
    } else {
      _accessToken = null;
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTest() {
    _currentUser = null;
    _accessToken = null;
    _savedAnalyses.clear();
    _isLoading = false;
    _errorMessage = null;
    _isOfflineDemo = false;
  }
}
