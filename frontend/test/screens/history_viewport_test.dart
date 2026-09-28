import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/history/widgets/my_analyses_list_view.dart';

void main() {
  group('Module 13 Multi-Viewport Layout Tests (Task 6.1)', () {
    final sampleRecords = [
      PackagingRecord(
        id: 1,
        userId: 1,
        itemName: 'Tomato',
        length: 280.0,
        width: 200.0,
        height: 140.0,
        weight: 1.2,
        isFragile: false,
        ecoFriendly: true,
        recommendedBoxType: 'Corrugated Kraft Box 5-Ply',
        recommendedDimensions: '280 x 200 x 140 mm',
        boxVolumeCm3: 7840.0,
        itemVolumeCm3: 6500.0,
        spaceUtilizationPct: 82.9,
        cushioningMaterial: 'Bio-Degradable Molded Pulp Inserts',
        estimatedCost: 3.10,
        sustainabilityScore: 96.5,
        createdAt: DateTime(2026, 9, 26),
        formattedDate: '26 Sep 2026',
      ),
      PackagingRecord(
        id: 2,
        userId: 1,
        itemName: 'Apple',
        length: 300.0,
        width: 220.0,
        height: 150.0,
        weight: 2.0,
        isFragile: true,
        ecoFriendly: true,
        recommendedBoxType: 'Molded Pulp Tray + Bio-Film',
        recommendedDimensions: '300 x 220 x 150 mm',
        boxVolumeCm3: 9900.0,
        itemVolumeCm3: 8200.0,
        spaceUtilizationPct: 82.8,
        cushioningMaterial: 'Shredded Recycled Paper Pad',
        estimatedCost: 2.85,
        sustainabilityScore: 94.0,
        createdAt: DateTime(2026, 9, 25),
        formattedDate: '25 Sep 2026',
      ),
      PackagingRecord(
        id: 3,
        userId: 1,
        itemName: 'Potato',
        length: 400.0,
        width: 300.0,
        height: 250.0,
        weight: 5.0,
        isFragile: false,
        ecoFriendly: false,
        recommendedBoxType: 'Jute-Lined Ventilated Sack',
        recommendedDimensions: '400 x 300 x 250 mm',
        boxVolumeCm3: 30000.0,
        itemVolumeCm3: 25000.0,
        spaceUtilizationPct: 83.3,
        cushioningMaterial: 'Organic Straw Layering',
        estimatedCost: 1.75,
        sustainabilityScore: 98.0,
        createdAt: DateTime(2026, 9, 23),
        formattedDate: '23 Sep 2026',
      ),
    ];

    testWidgets('renders cleanly on Mobile Viewport (375x812) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: MyAnalysesListView(
                records: sampleRecords,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Analyses'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('26 Sep 2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on Tablet Viewport (768x1024) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MyAnalysesListView(
                records: sampleRecords,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Analyses'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('25 Sep 2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on Desktop Viewport (1440x900) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: MyAnalysesListView(
                records: sampleRecords,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Analyses'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('23 Sep 2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
