/// Responsive Design System Tokens & Context Extensions
/// (Module 20: 📱 Responsive Design)
///
/// Defines platform standard breakpoint constants, screen type classifications,
/// context-aware geometric extensions, dynamic fluid typography, and adaptive spacing tokens.
library responsive_layout;

import 'package:flutter/material.dart';

/// Standard Viewport Breakpoint Thresholds in Logical Pixels (dp).
class AppBreakpoints {
  AppBreakpoints._();

  // Screen Width Breakpoints
  static const double mobileMax = 599.9;
  static const double tabletMin = 600.0;
  static const double tabletMax = 991.9;
  static const double laptopMin = 992.0;
  static const double laptopMax = 1199.9;
  static const double desktopMin = 1200.0;

  // Maximum content boundary on ultra-wide / 4K displays
  static const double maxContentWidth = 1440.0;
  static const double maxModalWidth = 680.0;
  static const double maxDialogWidth = 540.0;
}

/// Device Form Factor Classification Enum
enum DeviceScreenType {
  mobile,
  tablet,
  laptop,
  desktop,
}

/// Dynamic BuildContext Extensions for Responsive Layout Queries
extension ResponsiveContext on BuildContext {
  /// Total width of the current window or screen viewport
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Total height of the current window or screen viewport
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Current device orientation
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Form factor category based on viewport width
  DeviceScreenType get deviceType {
    final w = screenWidth;
    if (w >= AppBreakpoints.desktopMin) return DeviceScreenType.desktop;
    if (w >= AppBreakpoints.laptopMin) return DeviceScreenType.laptop;
    if (w >= AppBreakpoints.tabletMin) return DeviceScreenType.tablet;
    return DeviceScreenType.mobile;
  }

  /// Whether current screen is a mobile handset (< 600px)
  bool get isMobile => screenWidth < AppBreakpoints.tabletMin;

  /// Whether current screen is a tablet slate (600px - 991px)
  bool get isTablet =>
      screenWidth >= AppBreakpoints.tabletMin && screenWidth < AppBreakpoints.laptopMin;

  /// Whether current screen is a laptop / compact desktop (992px - 1199px)
  bool get isLaptop =>
      screenWidth >= AppBreakpoints.laptopMin && screenWidth < AppBreakpoints.desktopMin;

  /// Whether current screen is a full desktop / monitor (≥ 1200px)
  bool get isDesktop => screenWidth >= AppBreakpoints.desktopMin;

  /// Whether current screen is laptop or larger (≥ 992px)
  bool get isDesktopOrLaptop => screenWidth >= AppBreakpoints.laptopMin;

  /// Whether current screen is tablet or larger (≥ 600px)
  bool get isTabletOrLarger => screenWidth >= AppBreakpoints.tabletMin;
}

/// Fluid Typography Scaling Token Helper
class ResponsiveTypography {
  ResponsiveTypography._();

  static double heading1(BuildContext context) {
    if (context.isDesktop) return 32.0;
    if (context.isTabletOrLarger) return 26.0;
    return 22.0;
  }

  static double heading2(BuildContext context) {
    if (context.isDesktop) return 24.0;
    if (context.isTabletOrLarger) return 20.0;
    return 18.0;
  }

  static double heading3(BuildContext context) {
    if (context.isDesktop) return 18.0;
    if (context.isTabletOrLarger) return 16.0;
    return 15.0;
  }

  static double body(BuildContext context) {
    if (context.isDesktop) return 15.0;
    return 14.0;
  }

  static double caption(BuildContext context) {
    if (context.isDesktop) return 13.0;
    return 12.0;
  }
}

/// Adaptive Spacing & Gutter Tokens
class ResponsiveSpacing {
  ResponsiveSpacing._();

  /// Horizontal page gutter padding
  static double horizontalGutter(BuildContext context) {
    if (context.isDesktop) return 40.0;
    if (context.isLaptop) return 32.0;
    if (context.isTablet) return 24.0;
    return 16.0;
  }

  /// Inner card padding
  static double cardPadding(BuildContext context) {
    if (context.isDesktop) return 24.0;
    if (context.isTabletOrLarger) return 18.0;
    return 14.0;
  }

  /// Spacing between grid tiles
  static double gridSpacing(BuildContext context) {
    if (context.isDesktop) return 20.0;
    if (context.isTabletOrLarger) return 16.0;
    return 12.0;
  }

  /// Standard vertical section spacing
  static double sectionGap(BuildContext context) {
    if (context.isDesktop) return 32.0;
    if (context.isTabletOrLarger) return 24.0;
    return 16.0;
  }
}
