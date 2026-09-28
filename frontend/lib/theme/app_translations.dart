import 'dart:convert';
import 'package:flutter/services.dart';

/// AppTranslations — Zero-Latency Offline Translation Engine (Module 22)
///
/// Loads JSON localization dictionaries from `assets/i18n/` and resolves
/// nested dot-separated keys with hierarchical English fallback.
///
/// Usage:
///   await AppTranslations.load('ta');
///   final label = AppTranslations.tr('analysis.moisture_content');
///   final parameterized = AppTranslations.tr('common.items_count', params: {'count': '5'});
///   // Or via String extension:
///   final label2 = 'analysis.moisture_content'.tr();
class AppTranslations {
  static const Map<String, dynamic> _defaultFallbacks = {
    'common': {
      'close': 'Close',
      'save': 'Save',
      'cancel': 'Cancel',
      'retry': 'Retry',
    },
    'nav': {
      'admin': 'Admin',
      'home': 'Home',
      'analysis': 'Food Analysis',
      'materials': 'Materials',
      'compare': 'Comparison',
      'cost': 'Cost Estimator',
      'sustainability': 'Sustainability',
      'analytics': 'Analytics',
      'history': 'History',
      'profile': 'Profile',
    },
    'landing': {
      'cta_start_analysis': 'Launch Analysis',
      'nav_workflow': 'How It Works',
      'nav_benefits': 'Benefits',
      'nav_commodities': 'Commodities',
      'nav_about': 'About',
    },
    'category': {
      'title': 'Food Category',
      'view_all': 'View All',
      'fruits': 'Fruits',
      'vegetables': 'Vegetables',
      'grains': 'Grains',
      'dairy': 'Dairy',
      'meat': 'Meat',
      'bakery': 'Bakery',
      'other': 'Other perishables',
    },
    'analysis': {
      'title': 'Biochemical Food Analysis & Packaging Prescription',
      'btn_calculate': 'Generate AI Prescription',
      'search_title': 'Search Food Commodity',
      'manual_entry': 'Manual Entry',
      'recent_foods': 'Recently Evaluated Foods',
      'metric_moisture': 'Moisture',
      'metric_fat': 'Fat / Oil',
      'metric_ph': 'pH Level',
      'metric_respiration': 'Respiration',
      'batch_quantity': 'Batch / Production Quantity',
      'target_storage_condition': 'Target Storage Condition',
      'expected_storage_duration': 'Expected Storage Duration',
      'eco_priority_title': 'Eco-Friendly Material Prioritization',
      'eco_priority_subtitle': 'Favor recyclable, compostable bio-polymers and unbleached kraft',
      'transport_title': 'Transportation & Logistics (Optional)',
      'vulnerabilities_title': 'Critical Degradation Drivers ({count} Flagged)',
    },
    'cost': {
      'title': 'Packaging Cost & Material Estimator',
      'rfq_title': 'Request Supplier RFQ',
      'rfq_btn': 'Send RFQ to Converters',
    },
    'sustainability': {
      'title': 'Sustainability & Circularity Cockpit',
    },
    'catalog': {
      'title': 'Packaging Material Database',
      'add_material': 'Add Material',
    },
    'reports': {
      'title': 'Recommendation Report',
    },
    'analytics': {
      'title': '📈 Analytics Dashboard',
    },
    'admin': {
      'title': 'Admin Console',
      'subtitle': 'AI Governance & Catalogs',
    },
    'profile': {
      'title': 'Engineering Account & Workspace',
      'language_preference_title': 'Regional Language / மொழி தேர்வு',
      'select_language_hint': 'Select application language for UI, reports, and tooltips',
    },
  };

  static Map<String, dynamic> _localizedStrings = Map<String, dynamic>.from(_defaultFallbacks);
  static Map<String, dynamic> _fallbackStrings = Map<String, dynamic>.from(_defaultFallbacks);
  static String _currentLanguage = 'en';

  static final Map<String, Map<String, dynamic>> _cache = {};

  /// The currently loaded language code.
  static String get currentLanguage => _currentLanguage;

  /// Load a language dictionary from bundled assets or memory cache.
  /// Always loads English as fallback, then overlays the requested locale.
  static Future<void> load(String languageCode) async {
    _currentLanguage = languageCode;

    // Load English fallback (always available)
    if (!_cache.containsKey('en')) {
      try {
        final fallbackJson = await rootBundle.loadString('assets/i18n/en.json');
        _cache['en'] = json.decode(fallbackJson) as Map<String, dynamic>;
      } catch (_) {
        _cache['en'] = _fallbackStrings;
      }
    }
    _fallbackStrings = _cache['en'] ?? _fallbackStrings;

    if (languageCode == 'en') {
      _localizedStrings = _fallbackStrings;
    } else {
      if (!_cache.containsKey(languageCode)) {
        try {
          final currentJson =
              await rootBundle.loadString('assets/i18n/$languageCode.json');
          _cache[languageCode] = json.decode(currentJson) as Map<String, dynamic>;
        } catch (_) {
          // If the requested locale file doesn't exist, fall back to English
          _cache[languageCode] = _fallbackStrings;
        }
      }
      _localizedStrings = _cache[languageCode] ?? _fallbackStrings;
    }
  }

  /// Pre-cache a language dictionary directly into memory.
  static void cacheDictionary(String languageCode, Map<String, dynamic> dict) {
    _cache[languageCode] = dict;
  }

  /// Retrieve a cached language dictionary (returns null if not yet loaded).
  /// Primarily used in tests to get pre-loaded dictionaries without I/O.
  static Map<String, dynamic>? getCached(String languageCode) {
    return _cache[languageCode];
  }

  /// Reset the in-memory cache (primarily for test teardown).
  static void resetCache() {
    _cache.clear();
    _localizedStrings = Map<String, dynamic>.from(_defaultFallbacks);
    _fallbackStrings = Map<String, dynamic>.from(_defaultFallbacks);
    _currentLanguage = 'en';
  }

  /// Load translation dictionaries from raw Map objects (for testing).
  static void loadFromMaps({
    required Map<String, dynamic> primary,
    required Map<String, dynamic> fallback,
    String languageCode = 'en',
  }) {
    _cache[languageCode] = primary;
    if (fallback.isNotEmpty) {
      _cache['en'] = fallback;
      _fallbackStrings = fallback;
    }
    _localizedStrings = primary;
    _currentLanguage = languageCode;
  }

  /// Resolve a dot-separated translation key with optional parameter interpolation.
  ///
  /// Resolution order:
  ///   1. Look up key in the active locale dictionary.
  ///   2. If missing, look up key in the English fallback dictionary.
  ///   3. If still missing, return the raw key string itself (safe fallback).
  ///
  /// Parameter interpolation replaces `{paramName}` placeholders.
  static String tr(String key, {Map<String, String>? params}) {
    String value = _resolveNestedKey(_localizedStrings, key) ??
        _resolveNestedKey(_fallbackStrings, key) ??
        key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }

  /// Walk a dot-separated key path through a nested JSON map.
  /// Returns null if any segment is missing.
  static String? _resolveNestedKey(Map<String, dynamic> map, String key) {
    final segments = key.split('.');
    dynamic current = map;
    for (final segment in segments) {
      if (current is Map<String, dynamic> && current.containsKey(segment)) {
        current = current[segment];
      } else {
        return null;
      }
    }
    return current is String ? current : null;
  }
}

/// Ergonomic String extension for inline translation lookups in widgets.
///
/// Usage:
///   Text('analysis.title'.tr())
///   Text('common.items_count'.tr(params: {'count': '42'}))
extension StringTranslationExtension on String {
  String tr({Map<String, String>? params}) =>
      AppTranslations.tr(this, params: params);
}
