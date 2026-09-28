import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/widgets/responsive/adaptive_layout_widgets.dart';

void main() {
  Widget buildTestHarness({required Size size, required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );
  }

  group('ResponsiveLayout Tests (Screen Width Mode)', () {
    testWidgets('renders mobile layout on width < 600', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(375, 812),
          child: ResponsiveLayout(
            mobile: (_) => const Text('MOBILE_VIEW'),
            tablet: (_) => const Text('TABLET_VIEW'),
            laptop: (_) => const Text('LAPTOP_VIEW'),
            desktop: (_) => const Text('DESKTOP_VIEW'),
          ),
        ),
      );

      expect(find.text('MOBILE_VIEW'), findsOneWidget);
      expect(find.text('DESKTOP_VIEW'), findsNothing);
    });

    testWidgets('renders tablet layout on width 768', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(768, 1024),
          child: ResponsiveLayout(
            mobile: (_) => const Text('MOBILE_VIEW'),
            tablet: (_) => const Text('TABLET_VIEW'),
            laptop: (_) => const Text('LAPTOP_VIEW'),
            desktop: (_) => const Text('DESKTOP_VIEW'),
          ),
        ),
      );

      expect(find.text('TABLET_VIEW'), findsOneWidget);
    });

    testWidgets('renders laptop layout on width 1024', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(1024, 768),
          child: ResponsiveLayout(
            mobile: (_) => const Text('MOBILE_VIEW'),
            tablet: (_) => const Text('TABLET_VIEW'),
            laptop: (_) => const Text('LAPTOP_VIEW'),
            desktop: (_) => const Text('DESKTOP_VIEW'),
          ),
        ),
      );

      expect(find.text('LAPTOP_VIEW'), findsOneWidget);
    });

    testWidgets('renders desktop layout on width 1440', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(1440, 900),
          child: ResponsiveLayout(
            mobile: (_) => const Text('MOBILE_VIEW'),
            tablet: (_) => const Text('TABLET_VIEW'),
            laptop: (_) => const Text('LAPTOP_VIEW'),
            desktop: (_) => const Text('DESKTOP_VIEW'),
          ),
        ),
      );

      expect(find.text('DESKTOP_VIEW'), findsOneWidget);
    });

    testWidgets('falls back gracefully to desktop if mobile/tablet omitted', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(375, 812),
          child: ResponsiveLayout(
            desktop: (_) => const Text('FALLBACK_DESKTOP'),
          ),
        ),
      );

      expect(find.text('FALLBACK_DESKTOP'), findsOneWidget);
    });
  });

  group('ResponsiveLayout Tests (Container Constraints Mode)', () {
    testWidgets('renders mobile layout inside constrained SizedBox width 400', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: ResponsiveLayout(
                useParentConstraints: true,
                mobile: (_) => const Text('BOX_MOBILE'),
                desktop: (_) => const Text('BOX_DESKTOP'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('BOX_MOBILE'), findsOneWidget);
      expect(find.text('BOX_DESKTOP'), findsNothing);
    });
  });

  group('AdaptiveContainer Tests', () {
    testWidgets('constrains child width on widescreen display', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(2560, 1440),
          child: const AdaptiveContainer(
            maxWidth: 1200.0,
            child: Text('ADAPTIVE_CHILD'),
          ),
        ),
      );

      expect(find.text('ADAPTIVE_CHILD'), findsOneWidget);
      final adaptiveContainerFinder = find.byType(AdaptiveContainer);
      expect(adaptiveContainerFinder, findsOneWidget);

      final constrainedBoxFinder = find.descendant(
        of: adaptiveContainerFinder,
        matching: find.byType(ConstrainedBox),
      );
      expect(constrainedBoxFinder, findsOneWidget);
      final constrainedBox = tester.widget<ConstrainedBox>(constrainedBoxFinder);
      expect(constrainedBox.constraints.maxWidth, equals(1200.0));
    });
  });

  group('AdaptiveRowColumn Tests', () {
    testWidgets('renders Column on mobile viewport', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(375, 812),
          child: const AdaptiveRowColumn(
            children: [
              Text('ITEM_1'),
              Text('ITEM_2'),
            ],
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);
      expect(find.text('ITEM_1'), findsOneWidget);
      expect(find.text('ITEM_2'), findsOneWidget);
    });

    testWidgets('renders Row on desktop viewport', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(1440, 900),
          child: const AdaptiveRowColumn(
            children: [
              Text('ITEM_1'),
              Text('ITEM_2'),
            ],
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsNothing);
    });

    testWidgets('respects forceRow parameter regardless of viewport', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(375, 812),
          child: const AdaptiveRowColumn(
            forceRow: true,
            children: [
              Text('ITEM_1'),
              Text('ITEM_2'),
            ],
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('ResponsiveWrapGrid Tests', () {
    testWidgets('distributes child widgets in fluid grid without error', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(
          size: const Size(800, 600),
          child: ResponsiveWrapGrid(
            itemMinWidth: 200,
            children: List.generate(4, (i) => Card(child: Text('CARD_$i'))),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.text('CARD_0'), findsOneWidget);
      expect(find.text('CARD_3'), findsOneWidget);
    });
  });
}
