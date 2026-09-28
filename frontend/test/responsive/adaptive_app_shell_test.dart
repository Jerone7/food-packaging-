import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/widgets/navigation/adaptive_app_shell.dart';

void main() {
  const destinations = [
    AdaptiveNavDestination(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Analysis',
    ),
    AdaptiveNavDestination(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Materials',
      badge: 'PRO',
    ),
    AdaptiveNavDestination(
      icon: Icons.calculate_outlined,
      selectedIcon: Icons.calculate,
      label: 'Cost',
    ),
  ];

  Widget buildShellHarness({
    required Size size,
    int selectedIndex = 0,
    required ValueChanged<int> onSelect,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: AdaptiveAppShell(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelect,
          destinations: destinations,
          title: const Text('SmartPack AI'),
          actions: const [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: null,
            ),
          ],
          body: const Center(child: Text('ACTIVE_PAGE_BODY')),
        ),
      ),
    );
  }

  group('AdaptiveAppShell Multi-Device Navigation Tests', () {
    testWidgets('Desktop Viewport (1440x900) renders Top Navigation Bar', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int? tappedIndex;

      await tester.pumpWidget(
        buildShellHarness(
          size: const Size(1440, 900),
          onSelect: (idx) => tappedIndex = idx,
        ),
      );

      expect(find.text('SmartPack AI'), findsOneWidget);
      expect(find.text('ACTIVE_PAGE_BODY'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('Materials'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);

      // Verify no NavigationRail or NavigationBar exists on desktop
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);

      // Tap on 'Cost' destination
      await tester.tap(find.text('Cost'));
      await tester.pump();
      expect(tappedIndex, equals(2));
    });

    testWidgets('Tablet Viewport (768x1024) renders NavigationRail', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int? tappedIndex;

      await tester.pumpWidget(
        buildShellHarness(
          size: const Size(768, 1024),
          onSelect: (idx) => tappedIndex = idx,
        ),
      );

      expect(find.text('ACTIVE_PAGE_BODY'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // Tap on destination in rail
      await tester.tap(find.byIcon(Icons.inventory_2_outlined));
      await tester.pump();
      expect(tappedIndex, equals(1));
    });

    testWidgets('Mobile Viewport (375x812) renders Bottom NavigationBar', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int? tappedIndex;

      await tester.pumpWidget(
        buildShellHarness(
          size: const Size(375, 812),
          onSelect: (idx) => tappedIndex = idx,
        ),
      );

      expect(find.text('ACTIVE_PAGE_BODY'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // Tap on destination in bottom bar
      await tester.tap(find.byIcon(Icons.calculate_outlined));
      await tester.pump();
      expect(tappedIndex, equals(2));
    });
  });
}
