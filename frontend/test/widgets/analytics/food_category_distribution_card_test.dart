import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/analytics_model.dart';
import 'package:ai_packaging_recommender/screens/analytics/widgets/food_category_distribution_card.dart';

void main() {
  const testData = FoodCategoryDistributionResponseModel(
    totalAnalyses: 420,
    items: [
      FoodCategoryDistributionItemModel(
        categoryName: 'Fruits & Berries',
        commodityCount: 14,
        analysisCount: 220,
        percentageShare: 52.38,
        primaryPreservationChallenge: 'High respiration & ethylene decay',
        topPrescribedPolymer: 'BREATHABLE_BIO_EMAP',
      ),
      FoodCategoryDistributionItemModel(
        categoryName: 'Vegetables & Greens',
        commodityCount: 12,
        analysisCount: 200,
        percentageShare: 47.62,
        primaryPreservationChallenge: 'Chilling sensitivity & condensation',
        topPrescribedPolymer: 'BREATHABLE_BIO_EMAP',
      ),
    ],
  );

  Widget createTestWidget({
    FoodCategoryDistributionResponseModel data = testData,
    bool isLoading = false,
    ValueChanged<FoodCategoryDistributionItemModel>? onCategorySelected,
    Size size = const Size(800, 600),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            child: FoodCategoryDistributionCard(
              data: data,
              isLoading: isLoading,
              onCategorySelected: onCategorySelected,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('FoodCategoryDistributionCard renders title, radial gauge and items', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Food Category Breakdown'), findsOneWidget);
    expect(find.text('2 Categories'), findsOneWidget);
    expect(find.text('Fruits & Berries'), findsOneWidget);
    expect(find.text('14 items'), findsOneWidget);
    expect(find.text('220 (52.38%)'), findsOneWidget);
    expect(find.text('High respiration & ethylene decay'), findsOneWidget);
  });

  testWidgets('FoodCategoryDistributionCard triggers selection on tap', (tester) async {
    FoodCategoryDistributionItemModel? selected;
    await tester.pumpWidget(
      createTestWidget(
        onCategorySelected: (cat) => selected = cat,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fruits & Berries'));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected?.categoryName, 'Fruits & Berries');
  });

  testWidgets('FoodCategoryDistributionCard renders on narrow mobile width without overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(size: const Size(375, 812)));
    await tester.pumpAndSettle();

    expect(find.text('Food Category Breakdown'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
