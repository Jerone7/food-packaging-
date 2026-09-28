import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/history/widgets/my_analyses_card.dart';

void main() {
  group('MyAnalysesCard Widget Tests (Module 13 - Task 4.1)', () {
    final sampleTomato = PackagingRecord(
      id: 101,
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
      createdAt: DateTime(2026, 9, 26, 10, 30),
      formattedDate: '26 Sep 2026',
    );

    testWidgets('renders commodity name Tomato and formatted date 26 Sep 2026', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyAnalysesCard(
              record: sampleTomato,
            ),
          ),
        ),
      );

      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('26 Sep 2026'), findsOneWidget);
      expect(find.text('Corrugated Kraft Box 5-Ply'), findsOneWidget);
      expect(find.text('₹3.10 / unit'), findsOneWidget);
      expect(find.text('96.5/100'), findsOneWidget);
    });

    testWidgets('triggers onOpenAnalysis callback when card is tapped', (tester) async {
      PackagingRecord? openedRecord;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyAnalysesCard(
              record: sampleTomato,
              onOpenAnalysis: (record) {
                openedRecord = record;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MyAnalysesCard));
      await tester.pumpAndSettle();

      expect(openedRecord, isNotNull);
      expect(openedRecord!.itemName, equals('Tomato'));
      expect(openedRecord!.formattedDisplayDate, equals('26 Sep 2026'));
    });

    testWidgets('triggers onViewReport and onDelete action callbacks', (tester) async {
      PackagingRecord? viewedReportRecord;
      PackagingRecord? deletedRecord;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyAnalysesCard(
              record: sampleTomato,
              onViewReport: (r) => viewedReportRecord = r,
              onDelete: (r) => deletedRecord = r,
            ),
          ),
        ),
      );

      final reportBtn = find.byIcon(Icons.assessment_outlined);
      expect(reportBtn, findsOneWidget);
      await tester.tap(reportBtn);
      await tester.pumpAndSettle();
      expect(viewedReportRecord?.itemName, equals('Tomato'));

      final deleteBtn = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();
      expect(deletedRecord?.itemName, equals('Tomato'));
    });
  });
}
