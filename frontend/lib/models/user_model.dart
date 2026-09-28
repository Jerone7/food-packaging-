import 'package:flutter/foundation.dart';

/// Engineering and application preferences for authenticated users.
@immutable
class UserPreferencesModel {
  final bool defaultEcoPriority;
  final String defaultCurrency;
  final int defaultBatchSize;
  final String? exportOrganizationHeader;

  const UserPreferencesModel({
    this.defaultEcoPriority = true,
    this.defaultCurrency = 'INR',
    this.defaultBatchSize = 10000,
    this.exportOrganizationHeader,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserPreferencesModel();
    return UserPreferencesModel(
      defaultEcoPriority: json['default_eco_priority'] as bool? ??
          json['defaultEcoPriority'] as bool? ??
          true,
      defaultCurrency: json['default_currency'] as String? ??
          json['defaultCurrency'] as String? ??
          'INR',
      defaultBatchSize: json['default_batch_size'] as int? ??
          json['defaultBatchSize'] as int? ??
          10000,
      exportOrganizationHeader: json['export_organization_header'] as String? ??
          json['exportOrganizationHeader'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'default_eco_priority': defaultEcoPriority,
        'default_currency': defaultCurrency,
        'default_batch_size': defaultBatchSize,
        if (exportOrganizationHeader != null)
          'export_organization_header': exportOrganizationHeader,
      };

  UserPreferencesModel copyWith({
    bool? defaultEcoPriority,
    String? defaultCurrency,
    int? defaultBatchSize,
    String? exportOrganizationHeader,
  }) {
    return UserPreferencesModel(
      defaultEcoPriority: defaultEcoPriority ?? this.defaultEcoPriority,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultBatchSize: defaultBatchSize ?? this.defaultBatchSize,
      exportOrganizationHeader:
          exportOrganizationHeader ?? this.exportOrganizationHeader,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModel &&
          runtimeType == other.runtimeType &&
          defaultEcoPriority == other.defaultEcoPriority &&
          defaultCurrency == other.defaultCurrency &&
          defaultBatchSize == other.defaultBatchSize &&
          exportOrganizationHeader == other.exportOrganizationHeader;

  @override
  int get hashCode =>
      defaultEcoPriority.hashCode ^
      defaultCurrency.hashCode ^
      defaultBatchSize.hashCode ^
      exportOrganizationHeader.hashCode;
}

/// Aggregate usage and circularity statistics for user profile dashboard.
@immutable
class UserStatsModel {
  final int totalAnalysesCount;
  final int savedPresetsCount;
  final int ecoFriendlyCount;
  final double averageSustainabilityScore;
  final DateTime? memberSince;

  const UserStatsModel({
    this.totalAnalysesCount = 0,
    this.savedPresetsCount = 0,
    this.ecoFriendlyCount = 0,
    this.averageSustainabilityScore = 85.0,
    this.memberSince,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserStatsModel();
    return UserStatsModel(
      totalAnalysesCount: json['total_analyses_count'] as int? ??
          json['totalAnalysesCount'] as int? ??
          0,
      savedPresetsCount: json['saved_presets_count'] as int? ??
          json['savedPresetsCount'] as int? ??
          0,
      ecoFriendlyCount: json['eco_friendly_count'] as int? ??
          json['ecoFriendlyCount'] as int? ??
          0,
      averageSustainabilityScore: (json['average_sustainability_score'] as num? ??
              json['averageSustainabilityScore'] as num? ??
              85.0)
          .toDouble(),
      memberSince: json['member_since'] != null
          ? DateTime.tryParse(json['member_since'].toString())
          : (json['memberSince'] != null
              ? DateTime.tryParse(json['memberSince'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_analyses_count': totalAnalysesCount,
        'saved_presets_count': savedPresetsCount,
        'eco_friendly_count': ecoFriendlyCount,
        'average_sustainability_score': averageSustainabilityScore,
        if (memberSince != null) 'member_since': memberSince!.toIso8601String(),
      };

  UserStatsModel copyWith({
    int? totalAnalysesCount,
    int? savedPresetsCount,
    int? ecoFriendlyCount,
    double? averageSustainabilityScore,
    DateTime? memberSince,
  }) {
    return UserStatsModel(
      totalAnalysesCount: totalAnalysesCount ?? this.totalAnalysesCount,
      savedPresetsCount: savedPresetsCount ?? this.savedPresetsCount,
      ecoFriendlyCount: ecoFriendlyCount ?? this.ecoFriendlyCount,
      averageSustainabilityScore:
          averageSustainabilityScore ?? this.averageSustainabilityScore,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}

/// Core User Account entity model.
@immutable
class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String? organization;
  final String role;
  final bool isActive;
  final bool isAdmin;
  final DateTime createdAt;
  final UserPreferencesModel preferences;
  final UserStatsModel? stats;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.organization,
    this.role = 'Packaging Engineer',
    this.isActive = true,
    this.isAdmin = false,
    required this.createdAt,
    this.preferences = const UserPreferencesModel(),
    this.stats,
  });

  /// Derives capitalized 2-letter initials for user avatar badge.
  String get initials {
    var parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    final titles = {'dr.', 'dr', 'prof.', 'prof', 'mr.', 'mr', 'ms.', 'ms', 'mrs.', 'mrs'};
    if (parts.length >= 3 && titles.contains(parts.first.toLowerCase())) {
      parts = parts.sublist(1);
    }
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  /// Formatted display title (Full Name + Organization).
  String get displayName =>
      organization != null && organization!.isNotEmpty
          ? '$fullName ($organization)'
          : fullName;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ??
          json['fullName'] as String? ??
          'Packaging Engineer',
      organization: json['organization'] as String?,
      role: json['role'] as String? ?? 'Packaging Engineer',
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      isAdmin: json['is_admin'] as bool? ?? json['isAdmin'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      preferences: UserPreferencesModel.fromJson(
          json['preferences'] as Map<String, dynamic>?),
      stats: json['stats'] != null
          ? UserStatsModel.fromJson(json['stats'] as Map<String, dynamic>?)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        if (organization != null) 'organization': organization,
        'role': role,
        'is_active': isActive,
        'is_admin': isAdmin,
        'created_at': createdAt.toIso8601String(),
        'preferences': preferences.toJson(),
        if (stats != null) 'stats': stats!.toJson(),
      };

  UserModel copyWith({
    int? id,
    String? email,
    String? fullName,
    String? organization,
    String? role,
    bool? isActive,
    bool? isAdmin,
    DateTime? createdAt,
    UserPreferencesModel? preferences,
    UserStatsModel? stats,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      organization: organization ?? this.organization,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
}

/// Authentication Session envelope with JWT token and user profile.
@immutable
class AuthSessionModel {
  final String accessToken;
  final String tokenType;
  final int expiresInSeconds;
  final UserModel user;

  const AuthSessionModel({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.expiresInSeconds,
    required this.user,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? json['tokenType'] as String? ?? 'bearer',
      expiresInSeconds: json['expires_in_seconds'] as int? ?? json['expiresInSeconds'] as int? ?? 604800,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in_seconds': expiresInSeconds,
        'user': user.toJson(),
      };
}

/// Pinned or saved packaging recommendation preset model.
@immutable
class SavedAnalysisModel {
  final int id;
  final int userId;
  final String title;
  final String? notes;
  final String commodityName;
  final String recommendedMaterial;
  final double estimatedCost;
  final double sustainabilityScore;
  final Map<String, dynamic> inputPayload;
  final Map<String, dynamic> recommendationResult;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SavedAnalysisModel({
    required this.id,
    required this.userId,
    required this.title,
    this.notes,
    required this.commodityName,
    required this.recommendedMaterial,
    required this.estimatedCost,
    required this.sustainabilityScore,
    this.inputPayload = const {},
    this.recommendationResult = const {},
    required this.createdAt,
    this.updatedAt,
  });

  String get formattedCost => '₹${estimatedCost.toStringAsFixed(2)}';
  String get formattedScore => '${sustainabilityScore.toStringAsFixed(0)}/100';

  factory SavedAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SavedAnalysisModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? json['userId'] as int? ?? 0,
      title: json['title'] as String? ?? 'Saved Analysis',
      notes: json['notes'] as String?,
      commodityName: json['commodity_name'] as String? ??
          json['commodityName'] as String? ??
          'Food Commodity',
      recommendedMaterial: json['recommended_material'] as String? ??
          json['recommendedMaterial'] as String? ??
          'Recommended Material',
      estimatedCost: (json['estimated_cost'] as num? ??
              json['estimatedCost'] as num? ??
              0.0)
          .toDouble(),
      sustainabilityScore: (json['sustainability_score'] as num? ??
              json['sustainabilityScore'] as num? ??
              80.0)
          .toDouble(),
      inputPayload: json['input_payload'] as Map<String, dynamic>? ??
          json['inputPayload'] as Map<String, dynamic>? ??
          const {},
      recommendationResult: json['recommendation_result'] as Map<String, dynamic>? ??
          json['recommendationResult'] as Map<String, dynamic>? ??
          const {},
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        if (notes != null) 'notes': notes,
        'commodity_name': commodityName,
        'recommended_material': recommendedMaterial,
        'estimated_cost': estimatedCost,
        'sustainability_score': sustainabilityScore,
        'input_payload': inputPayload,
        'recommendation_result': recommendationResult,
        'created_at': createdAt.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  SavedAnalysisModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? notes,
    String? commodityName,
    String? recommendedMaterial,
    double? estimatedCost,
    double? sustainabilityScore,
    Map<String, dynamic>? inputPayload,
    Map<String, dynamic>? recommendationResult,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedAnalysisModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      commodityName: commodityName ?? this.commodityName,
      recommendedMaterial: recommendedMaterial ?? this.recommendedMaterial,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      inputPayload: inputPayload ?? this.inputPayload,
      recommendationResult: recommendationResult ?? this.recommendationResult,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
