import 'package:flutter/material.dart';

class BiochemicalProfile {
  final double moisture;
  final double fat;
  final double ph;
  final double waterActivity;
  final String respirationClass;
  final bool isCustomOverride;

  const BiochemicalProfile({
    required this.moisture,
    required this.fat,
    required this.ph,
    required this.waterActivity,
    required this.respirationClass,
    this.isCustomOverride = false,
  });

  factory BiochemicalProfile.fromJson(Map<String, dynamic> json) {
    return BiochemicalProfile(
      moisture: (json['moisture_pct'] ?? json['moisture'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat_pct'] ?? json['fat'] as num?)?.toDouble() ?? 0.0,
      ph: (json['ph'] as num?)?.toDouble() ?? 7.0,
      waterActivity: (json['water_activity'] as num?)?.toDouble() ?? 0.70,
      respirationClass: json['respiration_class']?.toString() ?? 'Very Low',
      isCustomOverride: json['is_custom_override'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'moisture_pct': moisture,
        'fat_pct': fat,
        'ph': ph,
        'water_activity': waterActivity,
        'respiration_class': respirationClass,
        'is_custom_override': isCustomOverride,
      };

  BiochemicalProfile copyWith({
    double? moisture,
    double? fat,
    double? ph,
    double? waterActivity,
    String? respirationClass,
    bool? isCustomOverride,
  }) {
    return BiochemicalProfile(
      moisture: moisture ?? this.moisture,
      fat: fat ?? this.fat,
      ph: ph ?? this.ph,
      waterActivity: waterActivity ?? this.waterActivity,
      respirationClass: respirationClass ?? this.respirationClass,
      isCustomOverride: isCustomOverride ?? this.isCustomOverride,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiochemicalProfile &&
          runtimeType == other.runtimeType &&
          moisture == other.moisture &&
          fat == other.fat &&
          ph == other.ph &&
          waterActivity == other.waterActivity &&
          respirationClass == other.respirationClass &&
          isCustomOverride == other.isCustomOverride;

  @override
  int get hashCode =>
      moisture.hashCode ^
      fat.hashCode ^
      ph.hashCode ^
      waterActivity.hashCode ^
      respirationClass.hashCode ^
      isCustomOverride.hashCode;
}

class FoodCommodity {
  final int? id;
  final String name;
  final String category;
  final String? scientificName;
  final double moisture;
  final double ph;
  final double waterActivity;
  final double fat;
  final String respirationClass;
  final String oxygenSensitivity;
  final String moistureSensitivity;
  final String? recommendedStorage;

  const FoodCommodity({
    this.id,
    required this.name,
    required this.category,
    this.scientificName,
    required this.moisture,
    required this.ph,
    required this.waterActivity,
    required this.fat,
    this.respirationClass = 'Low',
    this.oxygenSensitivity = 'Moderate',
    this.moistureSensitivity = 'Moderate',
    this.recommendedStorage,
  });

  BiochemicalProfile toBiochemicalProfile() {
    return BiochemicalProfile(
      moisture: moisture,
      fat: fat,
      ph: ph,
      waterActivity: waterActivity,
      respirationClass: respirationClass,
    );
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Icons.apple_rounded;
      case 'vegetables':
        return Icons.eco_rounded;
      case 'grains':
        return Icons.grain_rounded;
      case 'dairy':
        return Icons.water_drop_rounded;
      case 'meat':
        return Icons.set_meal_rounded;
      case 'bakery':
        return Icons.cake_rounded;
      case 'other perishables':
      default:
        return Icons.fastfood_rounded;
    }
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'fruits':
        return const Color(0xFFF97316); // Coral Orange
      case 'vegetables':
        return const Color(0xFF059669); // Emerald Green
      case 'grains':
        return const Color(0xFFD97706); // Amber Gold
      case 'dairy':
        return const Color(0xFF0284C7); // Sky Blue
      case 'meat':
        return const Color(0xFFE11D48); // Crimson Red
      case 'bakery':
        return const Color(0xFF9333EA); // Rose Violet
      case 'other perishables':
      default:
        return const Color(0xFF0F766E); // Deep Teal
    }
  }

  factory FoodCommodity.fromJson(Map<String, dynamic> json) {
    return FoodCommodity(
      id: json['id'] as int?,
      name: json['name']?.toString() ?? 'Unnamed Commodity',
      category: json['category']?.toString() ?? 'Other perishables',
      scientificName: json['scientific_name']?.toString() ?? json['sc_name']?.toString(),
      moisture: (json['moisture'] ?? json['water_g'] as num?)?.toDouble() ?? 0.0,
      ph: (json['ph'] as num?)?.toDouble() ?? 6.0,
      waterActivity: (json['water_activity'] as num?)?.toDouble() ?? 0.65,
      fat: (json['fat'] ?? json['fat_g'] as num?)?.toDouble() ?? 0.0,
      respirationClass: json['respiration_class']?.toString() ?? 'Low',
      oxygenSensitivity: json['oxygen_sensitivity']?.toString() ?? 'Moderate',
      moistureSensitivity: json['moisture_sensitivity']?.toString() ?? 'Moderate',
      recommendedStorage: json['recommended_storage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'scientific_name': scientificName,
        'moisture': moisture,
        'ph': ph,
        'water_activity': waterActivity,
        'fat': fat,
        'respiration_class': respirationClass,
        'oxygen_sensitivity': oxygenSensitivity,
        'moisture_sensitivity': moistureSensitivity,
        'recommended_storage': recommendedStorage,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodCommodity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name.toLowerCase() == other.name.toLowerCase();

  @override
  int get hashCode => id.hashCode ^ name.toLowerCase().hashCode;
}
