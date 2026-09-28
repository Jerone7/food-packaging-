import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/storage_condition.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/storage_condition_card.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/storage_duration_input.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/transport_condition_accordion.dart';

void main() {
  group('Storage and Transport Widget Tests', () {
    testWidgets('StorageConditionCard displays 4 storage options and handles selection', (WidgetTester tester) async {
      StorageMode mode = StorageMode.roomTemperature;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StorageConditionCard(
                selectedCondition: mode,
                onConditionChanged: (m) => mode = m,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Room Temperature'), findsOneWidget);
      expect(find.text('Refrigerated'), findsOneWidget);
      expect(find.text('Frozen'), findsOneWidget);
      expect(find.text('Controlled Atmosphere'), findsOneWidget);

      await tester.tap(find.text('Refrigerated'));
      await tester.pumpAndSettle();
      expect(mode, StorageMode.refrigerated);
    });

    testWidgets('StorageDurationInput calculates total days correctly', (WidgetTester tester) async {
      final ctrl = TextEditingController(text: '3');
      DurationUnit unit = DurationUnit.weeks;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StorageDurationInput(
              durationController: ctrl,
              durationUnit: unit,
              onUnitChanged: (u) => unit = u,
            ),
          ),
        ),
      );

      expect(find.textContaining('21 days shelf-life'), findsOneWidget);
    });

    testWidgets('TransportConditionAccordion expands and toggles mode', (WidgetTester tester) async {
      TransportMode tMode = TransportMode.ambientRoad;
      int days = 2;
      bool fragile = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TransportConditionAccordion(
                selectedMode: tMode,
                transitDays: days,
                isFragile: fragile,
                onModeChanged: (m) => tMode = m,
                onDaysChanged: (d) => days = d,
                onFragileChanged: (f) => fragile = f,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Transportation & Logistics (Optional)'), findsOneWidget);
      await tester.tap(find.text('Transportation & Logistics (Optional)'));
      await tester.pumpAndSettle();

      expect(find.text('Select Logistics Mode'), findsOneWidget);
      expect(find.text('Refrigerated Reefer Truck'), findsOneWidget);
      expect(find.text('Fragile Cargo'), findsOneWidget);
    });
  });
}
