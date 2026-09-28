import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppTheme Token & Configuration Tests', () {
    test('brand color tokens are defined correctly', () {
      expect(AppTheme.primaryTeal, const Color(0xFF0F766E));
      expect(AppTheme.mintAccent, const Color(0xFF14B8A6));
      expect(AppTheme.emeraldEco, const Color(0xFF059669));
      expect(AppTheme.slateDark, const Color(0xFF0F172A));
      expect(AppTheme.bgOffWhite, const Color(0xFFF8FAFC));
    });

    test('gradients initialize with expected color sequences', () {
      expect(AppTheme.heroGradient.colors.length, 2);
      expect(AppTheme.heroGradient.colors.first, AppTheme.primaryTeal);
      expect(AppTheme.heroGradient.colors.last, AppTheme.mintAccent);

      expect(AppTheme.ecoGradient.colors.first, AppTheme.emeraldEco);
    });

    test('lightTheme generates valid Material 3 ThemeData with custom ColorScheme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, AppTheme.bgOffWhite);
      expect(theme.colorScheme.primary, AppTheme.primaryTeal);
      expect(theme.colorScheme.secondary, AppTheme.mintAccent);
      expect(theme.colorScheme.tertiary, AppTheme.emeraldEco);
    });
  });
}
