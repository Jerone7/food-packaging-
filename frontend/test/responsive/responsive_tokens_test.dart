import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/theme/responsive_layout.dart';

void main() {
  group('AppBreakpoints & Constants Tests', () {
    test('defines standard breakpoint bounds', () {
      expect(AppBreakpoints.mobileMax, equals(599.9));
      expect(AppBreakpoints.tabletMin, equals(600.0));
      expect(AppBreakpoints.tabletMax, equals(991.9));
      expect(AppBreakpoints.laptopMin, equals(992.0));
      expect(AppBreakpoints.laptopMax, equals(1199.9));
      expect(AppBreakpoints.desktopMin, equals(1200.0));
      expect(AppBreakpoints.maxContentWidth, equals(1440.0));
    });
  });

  group('ResponsiveContext Extension Tests', () {
    Widget buildContextTester({
      required Size size,
      required void Function(BuildContext context) onBuild,
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Builder(
            builder: (context) {
              onBuild(context);
              return const SizedBox();
            },
          ),
        ),
      );
    }

    testWidgets('accurately categorizes Mobile viewport (375x812)', (tester) async {
      late DeviceScreenType detectedType;
      late bool isMobile, isTablet, isLaptop, isDesktop, isDesktopOrLaptop, isTabletOrLarger;

      await tester.pumpWidget(
        buildContextTester(
          size: const Size(375, 812),
          onBuild: (ctx) {
            detectedType = ctx.deviceType;
            isMobile = ctx.isMobile;
            isTablet = ctx.isTablet;
            isLaptop = ctx.isLaptop;
            isDesktop = ctx.isDesktop;
            isDesktopOrLaptop = ctx.isDesktopOrLaptop;
            isTabletOrLarger = ctx.isTabletOrLarger;
          },
        ),
      );

      expect(detectedType, equals(DeviceScreenType.mobile));
      expect(isMobile, isTrue);
      expect(isTablet, isFalse);
      expect(isLaptop, isFalse);
      expect(isDesktop, isFalse);
      expect(isDesktopOrLaptop, isFalse);
      expect(isTabletOrLarger, isFalse);
    });

    testWidgets('accurately categorizes Tablet viewport (768x1024)', (tester) async {
      late DeviceScreenType detectedType;
      late bool isMobile, isTablet, isLaptop, isDesktop, isDesktopOrLaptop, isTabletOrLarger;

      await tester.pumpWidget(
        buildContextTester(
          size: const Size(768, 1024),
          onBuild: (ctx) {
            detectedType = ctx.deviceType;
            isMobile = ctx.isMobile;
            isTablet = ctx.isTablet;
            isLaptop = ctx.isLaptop;
            isDesktop = ctx.isDesktop;
            isDesktopOrLaptop = ctx.isDesktopOrLaptop;
            isTabletOrLarger = ctx.isTabletOrLarger;
          },
        ),
      );

      expect(detectedType, equals(DeviceScreenType.tablet));
      expect(isMobile, isFalse);
      expect(isTablet, isTrue);
      expect(isLaptop, isFalse);
      expect(isDesktop, isFalse);
      expect(isDesktopOrLaptop, isFalse);
      expect(isTabletOrLarger, isTrue);
    });

    testWidgets('accurately categorizes Laptop viewport (1024x768)', (tester) async {
      late DeviceScreenType detectedType;
      late bool isMobile, isTablet, isLaptop, isDesktop, isDesktopOrLaptop, isTabletOrLarger;

      await tester.pumpWidget(
        buildContextTester(
          size: const Size(1024, 768),
          onBuild: (ctx) {
            detectedType = ctx.deviceType;
            isMobile = ctx.isMobile;
            isTablet = ctx.isTablet;
            isLaptop = ctx.isLaptop;
            isDesktop = ctx.isDesktop;
            isDesktopOrLaptop = ctx.isDesktopOrLaptop;
            isTabletOrLarger = ctx.isTabletOrLarger;
          },
        ),
      );

      expect(detectedType, equals(DeviceScreenType.laptop));
      expect(isMobile, isFalse);
      expect(isTablet, isFalse);
      expect(isLaptop, isTrue);
      expect(isDesktop, isFalse);
      expect(isDesktopOrLaptop, isTrue);
      expect(isTabletOrLarger, isTrue);
    });

    testWidgets('accurately categorizes Desktop widescreen viewport (1440x900)', (tester) async {
      late DeviceScreenType detectedType;
      late bool isMobile, isTablet, isLaptop, isDesktop, isDesktopOrLaptop, isTabletOrLarger;

      await tester.pumpWidget(
        buildContextTester(
          size: const Size(1440, 900),
          onBuild: (ctx) {
            detectedType = ctx.deviceType;
            isMobile = ctx.isMobile;
            isTablet = ctx.isTablet;
            isLaptop = ctx.isLaptop;
            isDesktop = ctx.isDesktop;
            isDesktopOrLaptop = ctx.isDesktopOrLaptop;
            isTabletOrLarger = ctx.isTabletOrLarger;
          },
        ),
      );

      expect(detectedType, equals(DeviceScreenType.desktop));
      expect(isMobile, isFalse);
      expect(isTablet, isFalse);
      expect(isLaptop, isFalse);
      expect(isDesktop, isTrue);
      expect(isDesktopOrLaptop, isTrue);
      expect(isTabletOrLarger, isTrue);
    });
  });

  group('ResponsiveTypography & ResponsiveSpacing Scaling Tests', () {
    testWidgets('scales typography and spacing correctly for mobile vs desktop', (tester) async {
      double? mobileH1, desktopH1;
      double? mobileGutter, desktopGutter;

      // Mobile Probe
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (ctx) {
                mobileH1 = ResponsiveTypography.heading1(ctx);
                mobileGutter = ResponsiveSpacing.horizontalGutter(ctx);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Desktop Probe
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)),
            child: Builder(
              builder: (ctx) {
                desktopH1 = ResponsiveTypography.heading1(ctx);
                desktopGutter = ResponsiveSpacing.horizontalGutter(ctx);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(mobileH1, equals(22.0));
      expect(desktopH1, equals(32.0));
      expect(mobileGutter, equals(16.0));
      expect(desktopGutter, equals(40.0));
    });
  });
}
