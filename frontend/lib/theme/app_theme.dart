import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/locale_service.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primaryTeal = Color(0xFF0F766E);       // Deep Teal
  static const Color primaryDark = Color(0xFF115E59);       // Dark Teal
  static const Color mintAccent = Color(0xFF14B8A6);        // Mint Accent
  static const Color emeraldEco = Color(0xFF059669);        // Emerald Eco
  static const Color emeraldLight = Color(0xFFD1FAE5);      // Soft Eco Pill
  static const Color slateDark = Color(0xFF0F172A);         // Deep Slate Heading
  static const Color slateBody = Color(0xFF475569);         // Slate Body Text
  static const Color bgOffWhite = Color(0xFFF8FAFC);        // Page Background
  static const Color surfaceWhite = Color(0xFFFFFFFF);      // Card Surface
  static const Color borderTeal = Color(0xFFCCFBF1);        // Card Highlight Border
  static const Color borderSubtle = Color(0xFFE2E8F0);      // Soft Card Border

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ecoGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme Configuration
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgOffWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: mintAccent,
        tertiary: emeraldEco,
        surface: surfaceWhite,
        brightness: Brightness.light,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: slateDark,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          color: slateDark,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: slateDark,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: slateDark,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: slateDark,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: slateDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: slateBody,
          height: 1.6,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: slateBody,
          height: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: slateDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: primaryTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Indic Typography & Locale-Aware TextStyle Configuration (Module 22)
  // ---------------------------------------------------------------------------

  /// Injects the appropriate script font family and line height bounds
  /// (1.50 - 1.55 for Indic scripts) to prevent vowel sign and descender clipping.
  static TextStyle getLocalizedTextStyle({
    TextStyle? baseStyle,
    String? languageCode,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final lang = languageCode ??
        (LocaleService().isInitialized ? LocaleService().languageCode : 'en');

    String? targetFontFamily;
    double targetHeight;

    if (lang == 'ta' || (languageCode == null && LocaleService().isTamil)) {
      targetFontFamily = 'NotoSansTamil';
      targetHeight = height ?? 1.55;
    } else if (lang == 'hi' ||
        (languageCode == null && LocaleService().isHindi)) {
      targetFontFamily = 'NotoSansDevanagari';
      targetHeight = height ?? 1.52;
    } else {
      targetFontFamily = null;
      targetHeight = height ?? (baseStyle?.height ?? 1.4);
    }

    final effectiveStyle = baseStyle ?? const TextStyle();
    return effectiveStyle.copyWith(
      fontFamily: targetFontFamily ?? effectiveStyle.fontFamily,
      height: targetHeight,
      fontSize: fontSize ?? effectiveStyle.fontSize,
      fontWeight: fontWeight ?? effectiveStyle.fontWeight,
      color: color ?? effectiveStyle.color,
      letterSpacing: letterSpacing ??
          (lang == 'ta' || lang == 'hi' ? 0.0 : effectiveStyle.letterSpacing),
    );
  }

  /// Builds a localized [TextTheme] applying the target script font family and line height.
  static TextTheme getLocalizedTextTheme([
    String? languageCode,
    TextTheme? base,
  ]) {
    final lang = languageCode ??
        (LocaleService().isInitialized ? LocaleService().languageCode : 'en');
    final baseTheme = base ??
        const TextTheme(
          bodyLarge: TextStyle(fontSize: 16.0),
          bodyMedium: TextStyle(fontSize: 14.0),
          titleMedium: TextStyle(fontSize: 16.0),
          titleLarge: TextStyle(fontSize: 22.0),
        );

    if (lang == 'ta') {
      return baseTheme.apply(fontFamily: 'NotoSansTamil').copyWith(
            bodyLarge: baseTheme.bodyLarge
                ?.copyWith(height: 1.55, fontFamily: 'NotoSansTamil'),
            bodyMedium: baseTheme.bodyMedium
                ?.copyWith(height: 1.55, fontFamily: 'NotoSansTamil'),
            titleMedium: baseTheme.titleMedium
                ?.copyWith(height: 1.50, fontFamily: 'NotoSansTamil'),
            titleLarge: baseTheme.titleLarge
                ?.copyWith(height: 1.45, fontFamily: 'NotoSansTamil'),
          );
    } else if (lang == 'hi') {
      return baseTheme.apply(fontFamily: 'NotoSansDevanagari').copyWith(
            bodyLarge: baseTheme.bodyLarge
                ?.copyWith(height: 1.52, fontFamily: 'NotoSansDevanagari'),
            bodyMedium: baseTheme.bodyMedium
                ?.copyWith(height: 1.52, fontFamily: 'NotoSansDevanagari'),
            titleMedium: baseTheme.titleMedium
                ?.copyWith(height: 1.50, fontFamily: 'NotoSansDevanagari'),
            titleLarge: baseTheme.titleLarge
                ?.copyWith(height: 1.45, fontFamily: 'NotoSansDevanagari'),
          );
    }
    return baseTheme;
  }

  /// Generates a locale-adapted [ThemeData].
  static ThemeData getThemeForLocale([String? languageCode, ThemeData? baseTheme]) {
    final lang = languageCode ??
        (LocaleService().isInitialized ? LocaleService().languageCode : 'en');
    final effectiveBase = baseTheme ??
        ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: bgOffWhite,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryTeal,
            primary: primaryTeal,
            secondary: mintAccent,
            tertiary: emeraldEco,
            surface: surfaceWhite,
            brightness: Brightness.light,
          ),
        );
    final localizedTextTheme = getLocalizedTextTheme(lang, effectiveBase.textTheme);
    return effectiveBase.copyWith(textTheme: localizedTextTheme);
  }
}

/// Convenience extension for applying locale-aware typography directly to any [TextStyle].
extension LocalizedTextStyleExtension on TextStyle {
  TextStyle withLocale([String? languageCode]) {
    return AppTheme.getLocalizedTextStyle(
      baseStyle: this,
      languageCode: languageCode,
    );
  }
}

