import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_translations.dart';

/// LocaleService — Reactive Multi-Language State Controller (Module 22)
///
/// Singleton [ChangeNotifier] that manages the application's active locale,
/// persists language preferences to local storage via [SharedPreferences],
/// and triggers reactive UI rebuilds across all listening widgets.
///
/// Usage:
///   // Initialize at app startup
///   await LocaleService().init();
///
///   // Switch language (persists and notifies listeners)
///   await LocaleService().changeLocale('ta');
///
///   // Query active state
///   LocaleService().isTamil;       // true
///   LocaleService().languageCode;  // 'ta'
class LocaleService extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------
  static const String _prefKey = 'user_selected_language';

  /// All locale codes supported in this build.
  static const List<String> supportedLanguageCodes = ['en', 'ta', 'hi'];

  /// Human-readable labels for the language picker UI.
  static const Map<String, String> languageLabels = {
    'en': 'English',
    'ta': 'தமிழ் (Tamil)',
    'hi': 'हिन्दी (Hindi)',
  };

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  Locale _currentLocale = const Locale('en');
  bool _initialized = false;

  /// The active [Locale] object.
  Locale get currentLocale => _currentLocale;

  /// The active ISO 639-1 language code (e.g. `'en'`, `'ta'`, `'hi'`).
  String get languageCode => _currentLocale.languageCode;

  /// Whether the service has been initialized with persisted preferences.
  bool get isInitialized => _initialized;

  // ---------------------------------------------------------------------------
  // Convenience Getters
  // ---------------------------------------------------------------------------
  bool get isEnglish => languageCode == 'en';
  bool get isTamil => languageCode == 'ta';
  bool get isHindi => languageCode == 'hi';

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize the locale service by loading persisted preferences.
  /// Call this once at application startup (e.g. in `main()`).
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefKey) ?? 'en';
    final validCode =
        supportedLanguageCodes.contains(savedCode) ? savedCode : 'en';

    _currentLocale = Locale(validCode);
    await AppTranslations.load(validCode);
    _initialized = true;
    notifyListeners();
  }

  /// Initialize with explicit maps (for testing without SharedPreferences).
  void initForTesting({
    Map<String, dynamic> primaryDict = const {},
    Map<String, dynamic> fallbackDict = const {},
    String languageCode = 'en',
  }) {
    _currentLocale = Locale(languageCode);
    AppTranslations.loadFromMaps(
      primary: primaryDict,
      fallback: fallbackDict,
      languageCode: languageCode,
    );
    _initialized = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Language Switching
  // ---------------------------------------------------------------------------

  /// Change the application language, persist to local storage, reload
  /// translations, and notify all listening widgets.
  Future<void> changeLocale(String newLanguageCode) async {
    if (!supportedLanguageCodes.contains(newLanguageCode)) return;
    if (_currentLocale.languageCode == newLanguageCode) return;

    _currentLocale = Locale(newLanguageCode);
    try {
      await AppTranslations.load(newLanguageCode);
    } catch (_) {
      // Handled gracefully in tests or environments without asset bundle
    }

    try {
      // Persist preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLanguageCode);
    } catch (_) {
      // Handled gracefully in test bindings
    }

    notifyListeners();
  }

  /// Change locale for testing (no SharedPreferences I/O).
  void changeLocaleForTesting({
    required String languageCode,
    Map<String, dynamic> primaryDict = const {},
    Map<String, dynamic> fallbackDict = const {},
  }) {
    if (!supportedLanguageCodes.contains(languageCode)) return;
    _currentLocale = Locale(languageCode);
    AppTranslations.loadFromMaps(
      primary: primaryDict,
      fallback: fallbackDict,
      languageCode: languageCode,
    );
    notifyListeners();
  }
}
