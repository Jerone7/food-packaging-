import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/material_catalog_model.dart';
import 'package:ai_packaging_recommender/screens/materials/widgets/packaging_material_card.dart';
import 'package:ai_packaging_recommender/screens/materials/widgets/mini_radar_thumbnail.dart';
import 'package:ai_packaging_recommender/screens/materials/widgets/material_filter_bar.dart';
import 'package:ai_packaging_recommender/screens/materials/widgets/material_data_table.dart';
import 'package:ai_packaging_recommender/screens/materials/widgets/pinned_comparison_bar.dart';
import 'package:ai_packaging_recommender/screens/materials/widgets/comparative_radar_chart.dart';

void main() {
  const sampleMaterial = PackagingMaterialDetail(
    materialId: 'mat_test_bio_01',
    name: 'Test Bio-Polymer Film',
    category: 'Biodegradable Bio-Polymer',
    polymerFamily: 'PLA',
    structure: 'PLA Blown Film',
    formFactor: 'Flexible Pouch',
    barrierProfile: BarrierProfileDetail(
      otrCcM2Day: 50.0,
      wvtrGM2Day: 10.0,
      thicknessMicrons: 30.0,
      barrierTier: 'Moderate Barrier',
    ),
    mechanicalProfile: MechanicalProfile(
      tensileStrengthMpa: 40.0,
      punctureResistanceN: 25.0,
      formFactor: 'Flexible Pouch',
    ),
    thermalProfile: ThermalProfile(
      tempMinC: 0.0,
      tempMaxC: 60.0,
      thermalClass: 'Ambient',
    ),
    opticalProfile: OpticalProfile(
      opticalClarity: 'Translucent',
    ),
    environmentalProfile: EnvironmentalProfile(
      sustainabilityScore: 95.0,
      isBiodegradable: true,
      isRecyclable: false,
    ),
    economicProfile: EconomicProfile(
      costCategory: 'Commercial Standard',
      estimatedUnitCostInr: 3.20,
    ),
    radarScores: MaterialRadarScores(
      barrierScore: 60.0,
      mechanicalScore: 45.0,
      sustainabilityScore: 95.0,
      thermalScore: 50.0,
      costEfficiencyScore: 70.0,
      opticalScore: 65.0,
    ),
  );

  group('Modular Material Explorer Widgets Tests', () {
    testWidgets('MiniRadarThumbnail renders without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiniRadarThumbnail(
              radarScores: MaterialRadarScores(
                barrierScore: 80,
                mechanicalScore: 70,
                sustainabilityScore: 90,
                thermalScore: 60,
                costEfficiencyScore: 75,
                opticalScore: 85,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MiniRadarThumbnail), findsOneWidget);
    });

    testWidgets('PackagingMaterialCard renders material details and triggers inspection', (WidgetTester tester) async {
      bool inspected = false;
      bool comparisonToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PackagingMaterialCard(
              material: sampleMaterial,
              isSelectedForComparison: false,
              onInspect: () => inspected = true,
              onToggleComparison: (val) => comparisonToggled = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Bio-Polymer Film'), findsOneWidget);
      expect(find.text('Biodegradable Bio-Polymer'), findsOneWidget);
      expect(find.text('95/100'), findsOneWidget);
      expect(find.text('Inspect Specs'), findsOneWidget);

      await tester.tap(find.text('Inspect Specs'));
      await tester.pump();
      expect(inspected, isTrue);

      await tester.tap(find.text('Compare'));
      await tester.pump();
      expect(comparisonToggled, isTrue);
    });

    testWidgets('MaterialFilterBar renders search input and category chips', (WidgetTester tester) async {
      final ctrl = TextEditingController();
      String selectedCat = 'All';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialFilterBar(
              searchController: ctrl,
              selectedCategory: selectedCat,
              categories: const [
                MaterialCategorySummary(
                  category: 'Conventional Polymer',
                  count: 8,
                  sampleMaterials: ['LDPE', 'HDPE'],
                  averageSustainability: 55.0,
                  description: 'Conventional options',
                ),
              ],
              minSustainability: 0,
              isGridView: true,
              sortBy: 'sustainability_score',
              onSearchChanged: (_) {},
              onCategorySelected: (cat) => selectedCat = cat,
              onSustainabilityChanged: (_) {},
              onToggleViewMode: (_) {},
              onSortChanged: (_) {},
              onClearFilters: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All Categories'), findsOneWidget);
      expect(find.text('Conventional Polymer (8)'), findsOneWidget);
    });

    testWidgets('MaterialDataTable renders tabular headers and rows', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialDataTable(
              materials: const [sampleMaterial],
              selectedMaterialIds: const {},
              onInspect: (_) {},
              onToggleComparison: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.text('Material & Structure'), findsOneWidget);
      expect(find.text('Test Bio-Polymer Film'), findsOneWidget);
      expect(find.text('30 µm'), findsOneWidget);
      expect(find.text('95/100'), findsOneWidget);
    });

    testWidgets('PinnedComparisonBar displays selected counter and CTA', (WidgetTester tester) async {
      bool launched = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinnedComparisonBar(
              selectedMaterials: const [sampleMaterial, sampleMaterial],
              onRemoveMaterial: (_) {},
              onClearAll: () {},
              onLaunchComparison: () => launched = true,
            ),
          ),
        ),
      );

      expect(find.text('2 / 4 Selected'), findsOneWidget);
      expect(find.text('Compare (2)'), findsOneWidget);

      await tester.tap(find.text('Compare (2)'));
      await tester.pump();
      expect(launched, isTrue);
    });

    testWidgets('Comparative6AxisRadarChart renders spider canvas', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Comparative6AxisRadarChart(
              materials: const [sampleMaterial],
              radarDatasets: {'mat_test_bio_01': sampleMaterial.radarScores},
            ),
          ),
        ),
      );

      expect(find.byType(Comparative6AxisRadarChart), findsOneWidget);
      expect(find.text('Test Bio-Polymer Film'), findsOneWidget);
    });
  });
}
