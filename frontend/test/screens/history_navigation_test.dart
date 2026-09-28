import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/screens/landing/widgets/home_header.dart';
import 'package:ai_packaging_recommender/screens/analysis/widgets/recommendation_results_cockpit.dart';
import 'package:ai_packaging_recommender/screens/history/history_screen.dart';

void main() {
  group('History Quick Navigation Shortcuts (Module 13 - Task 5.2)', () {
    testWidgets('HomeHeader triggers onOpenHistory callback', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool historyOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeHeader(
              onStartAnalysis: () {},
              onOpenHistory: () => historyOpened = true,
            ),
          ),
        ),
      );

      final historyBtn = find.byKey(const Key('home_header_history_button'));
      expect(historyBtn, findsOneWidget);
      await tester.tap(historyBtn);
      await tester.pumpAndSettle();

      expect(historyOpened, isTrue);
    });

    testWidgets('RecommendationResultsCockpit has My Analyses button that navigates to HistoryScreen', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final dummyResult = PackagingRecommendationResult(
        recommendedBoxType: 'Corrugated Kraft Box (5-Ply)',
        recommendedDimensions: '280 x 200 x 140 mm',
        boxVolumeCm3: 7840.0,
        itemVolumeCm3: 6500.0,
        spaceUtilizationPct: 82.9,
        cushioningMaterial: 'Bio-Degradable Molded Pulp Inserts',
        estimatedCost: 3.10,
        sustainabilityScore: 96.5,
        primaryRecommendation: const PrimaryRecommendation(
          materialName: 'Corrugated Kraft Box 5-Ply',
          materialType: 'Cellulose Bio-Composite',
          polymerFamily: 'PAPER_KRAFT',
          structure: '5-Ply Fluted Board',
          barrierProfile: BarrierProfile(
            otr: 'Low',
            wvtr: 'Medium',
            thicknessMicrons: 120.0,
            tensileStrengthMpa: 45.0,
            punctureResistanceN: 80.0,
          ),
          sustainabilityScore: 96.5,
          estimatedUnitCostInr: 3.10,
          suitabilityScore: 0.95,
          activeAdditives: [],
          packagingTitle: 'High-Strength Kraft Box',
          packagingFormat: 'Foldable Regular Slotted Container',
          recommendationExplanation: 'Optimal strength for transit protection.',
          advantages: ['Recyclable', 'High Compression Strength'],
          limitations: ['Moisture sensitivity if unsealed'],
          suitableStorageCondition: 'Ambient Dry (20°C)',
          expectedApplication: 'Fresh Produce Cartons',
          importantProperties: {'Burst Strength': '14 kg/cm²'},
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendationResultsCockpit(
                result: dummyResult,
              ),
            ),
          ),
        ),
      );

      final myAnalysesBtn = find.text('My Analyses');
      expect(myAnalysesBtn, findsOneWidget);

      await tester.tap(myAnalysesBtn);
      await tester.pumpAndSettle();

      expect(find.byType(HistoryScreen), findsOneWidget);
    });
  });
}
