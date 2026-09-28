import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/analytics_model.dart';
import 'package:ai_packaging_recommender/screens/analytics/widgets/most_analyzed_foods_card.dart';

void main() {
  const testData = MostAnalyzedFoodsResponseModel(
    totalVolume: 500,
    items: [
      MostAnalyzedFoodItemModel(
        foodId: 1,
        foodName: 'Alphonso Mango',
        foodCategory: 'Fruits & Berries',
        analysisCount: 184,
        percentageShare: 36.8,
        cumulativeParetoPct: 36.8,
        shelfLifeExtensionDays: 14.5,
      ),
      MostAnalyzedFoodItemModel(
        foodId: 2,
        foodName: 'Fresh Tomato',
        foodCategory: 'Vegetables',
        analysisCount: 162,
        percentageShare: 32.4,
        cumulativeParetoPct: 69.2,
        shelfLifeExtensionDays: 12.0,
      ),
    ],
    pareto80CutoffIndex: 1,
  );

  Widget createTestWidget({
    MostAnalyzedFoodsResponseModel data = testData,
    bool isLoading = false,
    ValueChanged<MostAnalyzedFoodItemModel>? onFoodSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 800,
            child: MostAnalyzedFoodsCard(
              data: data,
              isLoading: isLoading,
              onFoodSelected: onFoodSelected,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('MostAnalyzedFoodsCard renders title, badges and food items', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Most Analyzed Foods'), findsOneWidget);
    expect(find.text('500 Total Prescriptions'), findsOneWidget);
    expect(find.text('Alphonso Mango'), findsOneWidget);
    expect(find.text('Fresh Tomato'), findsOneWidget);
    expect(find.text('184 (36.8%)'), findsOneWidget);
    expect(find.text('+14.5d shelf-life extension'), findsOneWidget);
  });

  testWidgets('MostAnalyzedFoodsCard triggers callback on food tap', (tester) async {
    MostAnalyzedFoodItemModel? tappedFood;
    await tester.pumpWidget(
      createTestWidget(
        onFoodSelected: (food) => tappedFood = food,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alphonso Mango'));
    await tester.pumpAndSettle();

    expect(tappedFood, isNotNull);
    expect(tappedFood?.foodName, 'Alphonso Mango');
  });

  testWidgets('MostAnalyzedFoodsCard renders empty state when items is empty', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        data: const MostAnalyzedFoodsResponseModel(totalVolume: 0, items: []),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No food analysis records available for selected period'), findsOneWidget);
  });
}
