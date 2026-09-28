import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/admin_model.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/admin_kpi_card.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/admin_trend_chart.dart';
import 'package:ai_packaging_recommender/screens/admin/widgets/top_rankings_card.dart';

void main() {
  Widget createTestWidget(Widget child, {Size size = const Size(1200, 800)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: size.width,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('AdminKpiCard Widget Tests', () {
    testWidgets('renders title, value, subtitle, and trend badge', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AdminKpiCard(
            title: 'Total Packaging Runs',
            value: '1,420',
            subtitle: '+12% from last month',
            icon: Icons.analytics_rounded,
            trendText: '+14.2%',
            isPositiveTrend: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Total Packaging Runs'), findsOneWidget);
      expect(find.text('1,420'), findsOneWidget);
      expect(find.text('+12% from last month'), findsOneWidget);
      expect(find.text('+14.2%'), findsOneWidget);
      expect(find.byIcon(Icons.analytics_rounded), findsOneWidget);

      await tester.tap(find.byType(AdminKpiCard));
      expect(tapped, true);
    });

    testWidgets('renders correctly on small mobile width', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AdminKpiCard(
            title: 'Eco Adoption Rate',
            value: '84.5%',
            icon: Icons.eco_rounded,
          ),
          size: const Size(375, 667),
        ),
      );

      expect(find.text('Eco Adoption Rate'), findsOneWidget);
      expect(find.text('84.5%'), findsOneWidget);
    });
  });

  group('AdminTrendChart Widget Tests', () {
    final sampleTrends = [
      const DailyUsageTrendModel(
        date: '2026-09-25',
        totalAnalyses: 40,
        ecoAnalyses: 32,
        avgSustainabilityScore: 92.5,
        avgCostInr: 3.20,
      ),
      const DailyUsageTrendModel(
        date: '2026-09-26',
        totalAnalyses: 55,
        ecoAnalyses: 48,
        avgSustainabilityScore: 94.0,
        avgCostInr: 3.15,
      ),
      const DailyUsageTrendModel(
        date: '2026-09-27',
        totalAnalyses: 65,
        ecoAnalyses: 58,
        avgSustainabilityScore: 95.2,
        avgCostInr: 3.10,
      ),
    ];

    testWidgets('renders trend chart title, legends, and daily bars', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AdminTrendChart(trends: sampleTrends),
        ),
      );

      expect(find.text('30-Day Analysis & Eco-Optimization Volume'), findsOneWidget);
      expect(find.text('Total Runs'), findsOneWidget);
      expect(find.text('Eco-Friendly'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('55'), findsOneWidget);
      expect(find.text('65'), findsOneWidget);
    });

    testWidgets('handles empty trends list gracefully', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AdminTrendChart(trends: []),
        ),
      );

      expect(find.text('No trend data available for selected period'), findsOneWidget);
    });
  });

  group('TopRankingsCard Widget Tests', () {
    final sampleFoods = [
      const FoodSearchStatModel(name: 'Fresh Tomato', category: 'Produce', queryCount: 48, sharePct: 40.0),
      const FoodSearchStatModel(name: 'Potato Chips', category: 'Snacks & Wafers', queryCount: 24, sharePct: 20.0),
    ];

    final sampleMaterials = [
      const MaterialRecommendStatModel(
        materialName: 'Bio-Film PLA/PBAT',
        polymerFamily: 'BREATHABLE_BIO_EMAP',
        recommendCount: 60,
        sharePct: 50.0,
        averageScore: 96.0,
      ),
      const MaterialRecommendStatModel(
        materialName: 'Corrugated Kraft Box',
        polymerFamily: 'CELLULOSE_KRAFT_LINED',
        recommendCount: 30,
        sharePct: 25.0,
        averageScore: 95.0,
      ),
    ];

    testWidgets('renders top foods and top materials lists', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TopRankingsCard(
            topFoods: sampleFoods,
            topMaterials: sampleMaterials,
          ),
        ),
      );

      expect(find.text('Most Searched Foods'), findsOneWidget);
      expect(find.text('Fresh Tomato'), findsOneWidget);
      expect(find.text('Potato Chips'), findsOneWidget);

      expect(find.text('Top Recommended Materials'), findsOneWidget);
      expect(find.text('Bio-Film PLA/PBAT'), findsOneWidget);
      expect(find.text('Corrugated Kraft Box'), findsOneWidget);
      expect(find.text('96% Eco'), findsOneWidget);
    });

    testWidgets('renders in narrow mobile column mode without overflow', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TopRankingsCard(
            topFoods: sampleFoods,
            topMaterials: sampleMaterials,
          ),
          size: const Size(375, 812),
        ),
      );

      expect(find.text('Most Searched Foods'), findsOneWidget);
      expect(find.text('Top Recommended Materials'), findsOneWidget);
    });
  });
}
