import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/analytics_model.dart';
import 'package:ai_packaging_recommender/screens/analytics/widgets/packaging_distribution_card.dart';

void main() {
  const testData = PackagingDistributionResponseModel(
    totalRecommendations: 1245,
    items: [
      PackagingDistributionItemModel(
        polymerFamily: 'BREATHABLE_BIO_EMAP',
        displayName: 'Breathable Bio-EMAP Film',
        recommendationCount: 342,
        percentageShare: 27.47,
        isEcoFriendly: true,
        dominantApplication: 'Respiring Fresh Produce',
      ),
      PackagingDistributionItemModel(
        polymerFamily: 'METALLIZED_BARRIER',
        displayName: 'Metallized Tri-Layer Barrier',
        recommendationCount: 278,
        percentageShare: 22.33,
        isEcoFriendly: false,
        dominantApplication: 'Crisps & Snacks',
      ),
    ],
    ecoFriendlySharePct: 27.47,
    hhiConcentrationIndex: 0.185,
  );

  Widget createTestWidget({
    PackagingDistributionResponseModel data = testData,
    bool isLoading = false,
    ValueChanged<PackagingDistributionItemModel>? onPolymerSelected,
    Size size = const Size(800, 600),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            child: PackagingDistributionCard(
              data: data,
              isLoading: isLoading,
              onPolymerSelected: onPolymerSelected,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('PackagingDistributionCard renders title, donut and legend', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Packaging Distribution'), findsOneWidget);
    expect(find.text('27.47% Eco Share'), findsOneWidget);
    expect(find.text('1245'), findsOneWidget);
    expect(find.text('Breathable Bio-EMAP Film'), findsOneWidget);
    expect(find.text('Metallized Tri-Layer Barrier'), findsOneWidget);
    expect(find.text('ECO'), findsOneWidget);
  });

  testWidgets('PackagingDistributionCard triggers callback on polymer tap', (tester) async {
    PackagingDistributionItemModel? tapped;
    await tester.pumpWidget(
      createTestWidget(
        onPolymerSelected: (p) => tapped = p,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Breathable Bio-EMAP Film'));
    await tester.pumpAndSettle();

    expect(tapped, isNotNull);
    expect(tapped?.polymerFamily, 'BREATHABLE_BIO_EMAP');
  });

  testWidgets('PackagingDistributionCard renders on narrow mobile width without overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(size: const Size(375, 812)));
    await tester.pumpAndSettle();

    expect(find.text('Packaging Distribution'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
