import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/history/widgets/historical_record_card.dart';
import 'package:ai_packaging_recommender/screens/history/widgets/audit_detail_modal.dart';
import 'package:ai_packaging_recommender/screens/history/widgets/history_filter_bar.dart';

void main() {
  final sampleRecord = PackagingRecord(
    id: 101,
    itemName: 'Fresh Strawberries',
    length: 25.0,
    width: 15.0,
    height: 10.0,
    weight: 0.5,
    isFragile: true,
    ecoFriendly: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    recommendedBoxType: 'Micro-Perforated PLA Bio-Clamshell',
    recommendedDimensions: '25.0 x 15.0 x 10.0 cm',
    boxVolumeCm3: 3750.0,
    itemVolumeCm3: 2800.0,
    spaceUtilizationPct: 74.7,
    cushioningMaterial: 'Molded Cellulose Pulp Nest',
    estimatedCost: 4.20,
    sustainabilityScore: 88.0,
    notes: 'Active equilibrium MAP formulation with antifog coating and 100% bio-based compostable PLA.',
  );

  group('Module 7 Modular History Widgets Tests', () {
    testWidgets('HistoricalRecordCard renders metrics and triggers callbacks', (WidgetTester tester) async {
      bool inspected = false;
      bool reRan = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoricalRecordCard(
              record: sampleRecord,
              onInspect: () => inspected = true,
              onReRun: () => reRan = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fresh Strawberries'), findsOneWidget);
      expect(find.text('Micro-Perforated PLA Bio-Clamshell'), findsOneWidget);
      expect(find.text('₹4.20'), findsOneWidget);
      expect(find.text('🌱 88/100 Eco'), findsOneWidget);
      expect(find.text('🛡️ Molded Cellulose Pulp Nest'), findsOneWidget);
      expect(find.text('⚠️ Fragile Commodity'), findsOneWidget);

      // Tap Inspect Audit
      await tester.tap(find.text('Inspect Audit'));
      await tester.pumpAndSettle();
      expect(inspected, isTrue);

      // Tap Re-run Analysis
      await tester.tap(find.text('Re-run Analysis'));
      await tester.pumpAndSettle();
      expect(reRan, isTrue);
    });

    testWidgets('AuditDetailModal renders 3 tabs and specs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AuditDetailModal.show(context, sampleRecord),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Fresh Strawberries'), findsOneWidget);
      expect(find.text('Audit #101 • ', skipOffstage: false), findsNothing); // prefix check
      expect(find.text('Blueprint & Geometry'), findsOneWidget);
      expect(find.text('Preservation & Eco'), findsOneWidget);
      expect(find.text('Scientific Rationale'), findsOneWidget);

      // Verify Tab 1 Blueprint content
      expect(find.text('3750 cm³'), findsOneWidget);
      expect(find.text('74.7%'), findsOneWidget);

      // Switch to Preservation & Eco Tab
      await tester.tap(find.text('Preservation & Eco'));
      await tester.pumpAndSettle();
      expect(find.text('₹4.20'), findsOneWidget);
      expect(find.text('88 / 100'), findsOneWidget);

      // Switch to Scientific Rationale Tab
      await tester.tap(find.text('Scientific Rationale'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Active equilibrium MAP formulation'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Blueprint & Geometry'), findsNothing);
    });

    testWidgets('HistoryFilterBar renders search and filter controls correctly', (WidgetTester tester) async {
      final controller = TextEditingController();
      String selectedFilter = 'all';
      String sortBy = 'newest';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return HistoryFilterBar(
                  searchController: controller,
                  selectedFilter: selectedFilter,
                  sortBy: sortBy,
                  onSearchChanged: (val) {},
                  onFilterChanged: (f) => setState(() => selectedFilter = f),
                  onSortChanged: (s) => setState(() => sortBy = s),
                  onClearFilters: () => setState(() {
                    controller.clear();
                    selectedFilter = 'all';
                  }),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All Audits'), findsOneWidget);
      expect(find.text('🌿 Eco-Optimized'), findsOneWidget);
      expect(find.text('⚠️ Fragile Handling'), findsOneWidget);
      expect(find.text('⚙️ Standard Industrial'), findsOneWidget);

      // Tap Eco Filter Chip
      await tester.tap(find.text('🌿 Eco-Optimized'));
      await tester.pumpAndSettle();
      expect(selectedFilter, 'eco');
      expect(find.text('Reset Filters'), findsOneWidget);

      // Ensure Reset Filters is scrolled into view and tap
      await tester.ensureVisible(find.text('Reset Filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset Filters'));
      await tester.pumpAndSettle();
      expect(selectedFilter, 'all');
    });
  });
}
