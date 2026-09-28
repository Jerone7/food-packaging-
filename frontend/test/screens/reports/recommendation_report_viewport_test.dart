import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_model.dart';
import 'package:ai_packaging_recommender/models/recommendation_report_model.dart';
import 'package:ai_packaging_recommender/screens/reports/recommendation_report_screen.dart';

void main() {
  final sampleInput = PackagingInput(
    itemName: 'Fresh Strawberries',
    category: 'Fresh Produce (Berry Fruit)',
    length: 18.5,
    width: 12.0,
    height: 7.5,
    weight: 500.0,
    isFragile: true,
    ecoFriendly: true,
    moisture: 91.0,
    fat: 0.3,
    storageDurationDays: 14,
  );

  final sampleResult = PackagingRecommendationResult(
    recommendationId: 'rec_strawberries_99',
    recommendedBoxType: 'Micro-Perforated PLA / Bio-PET Clamshell',
    recommendedDimensions: '18.5 x 12.0 x 7.5 cm',
    boxVolumeCm3: 1665.0,
    itemVolumeCm3: 1200.0,
    spaceUtilizationPct: 72.0,
    cushioningMaterial: 'Cellulose Pad Liner',
    estimatedCost: 4.80,
    sustainabilityScore: 92.0,
    primaryRecommendation: const PrimaryRecommendation(
      materialName: 'Micro-Perforated PLA / Bio-PET Clamshell',
      materialType: 'Bio-Polymer Vented Clamshell',
      polymerFamily: 'BIO_POLYMER_PLA',
      structure: 'PLA / Bio-PET Thermoformed Sheet',
      packagingFormat: 'Vented Clamshell with Anti-Fog Base Pad',
      barrierProfile: BarrierProfile(
        otr: '800-1200 cc/m²/day',
        wvtr: '15-25 g/m²/day',
        thicknessMicrons: 250.0,
        tensileStrengthMpa: 55.0,
        punctureResistanceN: 22.0,
      ),
      sustainabilityScore: 92.0,
      estimatedUnitCostInr: 4.80,
      suitabilityScore: 0.94,
      activeAdditives: ['Anti-Fog Coating', 'Ethylene Absorber Pad'],
      recommendationExplanation:
          'Equilibrium modified atmosphere prevents anaerobic fermentation while suppressing mold.',
    ),
    alternatives: const [
      PackagingAlternative(
        candidateId: 'alt_rpet',
        type: AlternativeType.economy,
        typeRaw: 'Economy',
        materialName: 'Recycled PET (rPET) Punnet',
        packagingTitle: 'rPET Punnet',
        starRating: 4,
        starDisplay: '★★★★☆',
        suitabilityCategory: SuitabilityCategory.highCompatibility,
        modelDerivedProbability: 0.88,
        compatibilityConfidence: 'High (88%)',
        characteristics: MaterialCharacteristics(
          otr: '45.0 cc/m²/day',
          wvtr: '8.0 g/m²/day',
          thicknessMicrons: 200.0,
          tensileStrengthMpa: 60.0,
          sustainabilityRating: '100% Recyclable',
          estimatedCostInr: 3.20,
        ),
        tradeOffSummary: 'Cost-effective curbside recyclable option.',
        advantages: ['Lowest unit cost', 'Widely recyclable in curbside streams'],
        limitations: ['Requires macro-perforation to avoid condensation'],
        costDeltaPct: -33.3,
        ecoDeltaPct: -15.2,
        shelfLifeDelta: '-2 days',
        sustainabilityScore: 78.0,
        estimatedUnitCostInr: 3.20,
      ),
    ],
  );

  final testReport = RecommendationReportModel.fromRecommendationResult(
    result: sampleResult,
    input: sampleInput,
    batchSize: 10000,
    pcrPercentage: 30.0,
  );

  Widget buildViewportApp({required Size size, required Widget child}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: child,
        ),
      ),
    );
  }

  group('RecommendationReportScreen Multi-Viewport Responsive Audit (Task 6.3)', () {
    testWidgets('Mobile Viewport (375x812) renders with 0 RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      FlutterErrorDetails? errorDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          errorDetails = details;
        }
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        buildViewportApp(
          size: const Size(375, 812),
          child: RecommendationReportScreen(
            initialReport: testReport,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(errorDetails, isNull, reason: 'Mobile viewport (375x812) must have 0 RenderFlex overflows');
      expect(find.text('Fresh Strawberries'), findsOneWidget);
      expect(find.text('Micro-Perforated PLA / Bio-PET Clamshell'), findsWidgets);
    });

    testWidgets('Tablet Viewport (768x1024) renders with 0 RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      FlutterErrorDetails? errorDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          errorDetails = details;
        }
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        buildViewportApp(
          size: const Size(768, 1024),
          child: RecommendationReportScreen(
            initialReport: testReport,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(errorDetails, isNull, reason: 'Tablet viewport (768x1024) must have 0 RenderFlex overflows');
      expect(find.text('Fresh Strawberries'), findsOneWidget);
    });

    testWidgets('Desktop Viewport (1440x900) renders with 0 RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      FlutterErrorDetails? errorDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) {
          errorDetails = details;
        }
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        buildViewportApp(
          size: const Size(1440, 900),
          child: RecommendationReportScreen(
            initialReport: testReport,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(errorDetails, isNull, reason: 'Desktop viewport (1440x900) must have 0 RenderFlex overflows');
      expect(find.text('Fresh Strawberries'), findsOneWidget);
    });
  });
}
