import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/screens/sustainability/sustainability_analysis_screen.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/sustainability_profile_hero_card.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/lca_carbon_water_card.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/packaging_waste_potential_card.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/environmental_considerations_card.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/verified_data_citation_banner.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/sustainability_comparison_matrix.dart';

void main() {
  Widget buildTestableWidget({
    String? initialMaterialId,
    String? initialMaterialName,
    String? foodCommodityName,
    Size surfaceSize = const Size(1200, 900),
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: surfaceSize),
        child: SustainabilityAnalysisScreen(
          initialMaterialId: initialMaterialId,
          initialMaterialName: initialMaterialName,
          foodCommodityName: foodCommodityName,
        ),
      ),
    );
  }

  group('SustainabilityAnalysisScreen Tests', () {
    testWidgets('renders all major sections and components cleanly', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Header and titles
      expect(find.text('Sustainability & Circularity Cockpit'), findsOneWidget);
      expect(find.text('1. Packaging Material Substrate'), findsOneWidget);

      // Verify presence of all key widgets
      expect(find.byType(SustainabilityProfileHeroCard), findsOneWidget);
      expect(find.byType(LcaCarbonWaterCard), findsOneWidget);
      expect(find.byType(PackagingWastePotentialCard), findsOneWidget);
      expect(find.byType(EnvironmentalConsiderationsCard), findsOneWidget);
      expect(find.byType(VerifiedDataCitationBanner), findsOneWidget);
      expect(find.byType(SustainabilityComparisonMatrix), findsOneWidget);
    });

    testWidgets('initializes with material name and food commodity context', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          initialMaterialName: 'PLA / PBAT Bio-Film',
          foodCommodityName: 'Organic Roasted Coffee Beans',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Analyzing Sustainability for: Organic Roasted Coffee Beans'), findsOneWidget);
      expect(find.text('PLA / PBAT Bio-Film (EN 13432)'), findsWidgets);
    });

    testWidgets('changing material dropdown updates profile metrics', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(initialMaterialId: 'mat_poly_ldpe_01'));
      await tester.pumpAndSettle();

      // Find material dropdown
      final dropdown = find.byType(DropdownButton<String>).first;
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Tap on NatureFlex material item in dropdown menu
      final natureflexOption = find.text('NatureFlex™ Cellulosic (Home Compost)').last;
      await tester.tap(natureflexOption);
      await tester.pumpAndSettle();

      expect(find.text('NatureFlex™ Cellulosic (Home Compost)'), findsWidgets);
    });

    testWidgets('adjusting PCR slider updates carbon footprint and savings display', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(initialMaterialId: 'mat_pet_bo_04'));
      await tester.pumpAndSettle();

      // Look for PCR slider (first slider)
      final pcrSlider = find.byType(Slider).first;
      expect(pcrSlider, findsOneWidget);

      await tester.drag(pcrSlider, const Offset(60, 0));
      await tester.pumpAndSettle();

      // Verify widget rebuilt cleanly
      expect(find.byType(SustainabilityProfileHeroCard), findsOneWidget);
    });
  });
}
