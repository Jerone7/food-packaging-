import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/user_model.dart';
import 'package:ai_packaging_recommender/services/auth_service.dart';
import 'package:ai_packaging_recommender/widgets/auth/save_analysis_dialog.dart';
import 'package:ai_packaging_recommender/widgets/auth/saved_analysis_card.dart';
import 'package:ai_packaging_recommender/widgets/auth/saved_analyses_grid.dart';

void main() {
  setUp(() {
    AuthService().resetForTest();
  });

  final samplePreset1 = SavedAnalysisModel(
    id: 101,
    userId: 1,
    title: 'Strawberry MAP Spec',
    notes: 'Optimal for 14-day cold chain transit at 4°C.',
    commodityName: 'Fresh Strawberries',
    recommendedMaterial: 'PLA / Bio-based MAP Film',
    estimatedCost: 4.25,
    sustainabilityScore: 94.0,
    inputPayload: const {'commodity': 'Fresh Strawberries'},
    recommendationResult: const {'material': 'PLA Film'},
    createdAt: DateTime.now(),
  );

  final samplePreset2 = SavedAnalysisModel(
    id: 102,
    userId: 1,
    title: 'Tomato Corrugated Shipper',
    notes: 'Ventilated bulk shipper.',
    commodityName: 'Fresh Tomato',
    recommendedMaterial: 'Recycled Kraft Corrugated',
    estimatedCost: 3.10,
    sustainabilityScore: 96.5,
    inputPayload: const {'commodity': 'Fresh Tomato'},
    recommendationResult: const {'material': 'Kraft Corrugated'},
    createdAt: DateTime.now(),
  );

  group('Saved Analyses Widgets Tests (Module 14 - Task 5.2)', () {
    testWidgets('SaveAnalysisDialog pre-fills data and saves preset',
        (WidgetTester tester) async {
      AuthService().activateDemoMode();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SaveAnalysisDialog(
              commodityName: 'Organic Mango',
              recommendedMaterial: 'Molded Bagasse Tray',
              estimatedCost: 5.20,
              sustainabilityScore: 92.0,
            ),
          ),
        ),
      );

      // Verify title pre-filled
      expect(find.text('Bookmark Analysis Preset'), findsOneWidget);
      expect(find.textContaining('Organic Mango • Molded Bagasse Tray'), findsOneWidget);

      final titleInput = tester.widget<TextFormField>(
          find.byKey(const Key('save_preset_title_input')));
      expect(titleInput.controller?.text, 'Organic Mango Packaging Spec');

      // Click save button
      await tester.tap(find.byKey(const Key('save_preset_submit_button')));
      await tester.pumpAndSettle();

      expect(AuthService().savedAnalyses.any((s) => s.commodityName == 'Organic Mango'), isTrue);
    });

    testWidgets('SavedAnalysisCard displays preset details and triggers callbacks',
        (WidgetTester tester) async {
      SavedAnalysisModel? loadedPreset;
      SavedAnalysisModel? deletedPreset;
      SavedAnalysisModel? exportedPreset;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SavedAnalysisCard(
                analysis: samplePreset1,
                onLoad: (p) => loadedPreset = p,
                onDelete: (p) => deletedPreset = p,
                onExportReport: (p) => exportedPreset = p,
              ),
            ),
          ),
        ),
      );

      // Verify Details
      expect(find.text('Strawberry MAP Spec'), findsOneWidget);
      expect(find.text('PLA / Bio-based MAP Film'), findsOneWidget);
      expect(find.text('₹4.25'), findsOneWidget);
      expect(find.text('94/100'), findsOneWidget);

      // Test Load Button
      await tester.tap(find.byKey(const Key('saved_preset_load_101')));
      await tester.pumpAndSettle();
      expect(loadedPreset?.id, 101);

      // Test Export Button
      await tester.tap(find.byKey(const Key('saved_preset_export_101')));
      await tester.pumpAndSettle();
      expect(exportedPreset?.id, 101);

      // Test Delete Button
      await tester.tap(find.byKey(const Key('saved_preset_delete_101')));
      await tester.pumpAndSettle();
      expect(deletedPreset?.id, 101);
    });

    testWidgets('SavedAnalysesGrid filters presets dynamically and displays empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SavedAnalysesGrid(
                analyses: [samplePreset1, samplePreset2],
              ),
            ),
          ),
        ),
      );

      // Initial state: 2 presets visible
      expect(find.text('Strawberry MAP Spec'), findsOneWidget);
      expect(find.text('Tomato Corrugated Shipper'), findsOneWidget);
      expect(find.text('2 Presets'), findsOneWidget);

      // Search for "Tomato"
      await tester.enterText(
          find.byKey(const Key('saved_presets_search_input')), 'Tomato');
      await tester.pumpAndSettle();

      expect(find.text('Strawberry MAP Spec'), findsNothing);
      expect(find.text('Tomato Corrugated Shipper'), findsOneWidget);
      expect(find.text('1 Presets'), findsOneWidget);

      // Search for non-existent item -> shows empty search state
      await tester.enterText(
          find.byKey(const Key('saved_presets_search_input')), 'NonExistentProduct');
      await tester.pumpAndSettle();

      expect(find.text('No Presets Found for "NonExistentProduct"'), findsOneWidget);
      expect(find.text('0 Presets'), findsOneWidget);
    });
  });
}
