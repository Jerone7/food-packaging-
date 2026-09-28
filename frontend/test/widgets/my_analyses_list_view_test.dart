import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/history/widgets/my_analyses_list_view.dart';
import 'package:ai_packaging_recommender/screens/history/widgets/my_analyses_card.dart';

void main() {
  group('MyAnalysesListView Widget Tests (Module 13 - Task 4.2)', () {
    final sampleRecords = [
      PackagingRecord(
        id: 1,
        userId: 10,
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
        userId: 10,
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
        userId: 10,
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

    testWidgets('renders all empirical history records Tomato, Apple, Potato', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MyAnalysesListView(
                records: sampleRecords,
              ),
            ),
          ),
        ),
      );

      expect(find.text('My Analyses'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Count badge
      expect(find.widgetWithText(MyAnalysesCard, 'Tomato'), findsOneWidget);
      expect(find.text('26 Sep 2026'), findsOneWidget);
      expect(find.widgetWithText(MyAnalysesCard, 'Apple'), findsOneWidget);
      expect(find.text('25 Sep 2026'), findsOneWidget);
      expect(find.widgetWithText(MyAnalysesCard, 'Potato'), findsOneWidget);
      expect(find.text('23 Sep 2026'), findsOneWidget);
      expect(find.byType(MyAnalysesCard), findsNWidgets(3));
    });

    testWidgets('filters list in real-time when typing in search field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MyAnalysesListView(
                records: sampleRecords,
              ),
            ),
          ),
        ),
      );

      // Search for "Apple"
      await tester.enterText(find.byType(TextField), 'Apple');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(MyAnalysesCard, 'Apple'), findsOneWidget);
      expect(find.widgetWithText(MyAnalysesCard, 'Tomato'), findsNothing);
      expect(find.widgetWithText(MyAnalysesCard, 'Potato'), findsNothing);
      expect(find.byType(MyAnalysesCard), findsNWidgets(1));
    });

    testWidgets('filters list by filter chip (Fragile)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MyAnalysesListView(
                records: sampleRecords,
              ),
            ),
          ),
        ),
      );

      // Tap Fragile chip
      await tester.tap(find.text('Fragile'));
      await tester.pumpAndSettle();

      // Only Apple is marked as fragile in sampleRecords
      expect(find.widgetWithText(MyAnalysesCard, 'Apple'), findsOneWidget);
      expect(find.widgetWithText(MyAnalysesCard, 'Tomato'), findsNothing);
      expect(find.widgetWithText(MyAnalysesCard, 'Potato'), findsNothing);
    });

    testWidgets('renders empty state when record list is empty', (tester) async {
      bool startAnalysisClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MyAnalysesListView(
                records: const [],
                onStartNewAnalysis: () => startAnalysisClicked = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('No analyses saved yet'), findsOneWidget);
      final cta = find.text('Start Packaging Analysis');
      expect(cta, findsOneWidget);

      await tester.tap(cta);
      await tester.pumpAndSettle();
      expect(startAnalysisClicked, isTrue);
    });
  });
}
