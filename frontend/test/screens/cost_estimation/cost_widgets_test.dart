import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/cost_estimation_model.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/packaging_type_selector_grid.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/package_dimension_inputs.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/addon_feature_checklist.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/cost_summary_hero_card.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/material_footprint_card.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/cost_breakdown_chart.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/volume_sensitivity_chart.dart';
import 'package:ai_packaging_recommender/screens/cost_estimation/widgets/supplier_quote_disclaimer_banner.dart';

void main() {
  group('Cost Estimation Modular Widgets Tests', () {
    testWidgets('PackagingTypeSelectorGrid renders and responds to taps', (tester) async {
      PackagingFormFactor selected = PackagingFormFactor.standUpDoypack;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PackagingTypeSelectorGrid(
                  selectedType: selected,
                  onTypeSelected: (type) {
                    setState(() => selected = type);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('1. Form Factor'), findsOneWidget);
      expect(find.text('Stand-up Doypack'), findsOneWidget);
      expect(find.text('Pillow Pouch'), findsOneWidget);

      await tester.tap(find.text('Pillow Pouch'));
      await tester.pumpAndSettle();

      expect(selected, PackagingFormFactor.pillowPouch);
    });

    testWidgets('PackageDimensionInputs renders steppers and presets', (tester) async {
      PackageDimensions dims = const PackageDimensions(lengthCm: 20.0, widthCm: 14.0, depthOrGussetCm: 6.0);
      String fill = '500g';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PackageDimensionInputs(
                  dimensions: dims,
                  productFillQuantity: fill,
                  packagingType: PackagingFormFactor.standUpDoypack,
                  onDimensionsChanged: (d) => setState(() => dims = d),
                  onFillQuantityChanged: (f) => setState(() => fill = f),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('2. Dimensions & Fill'), findsOneWidget);
      expect(find.text('Length'), findsOneWidget);
      expect(find.text('Width'), findsOneWidget);
      expect(find.text('Gusset'), findsOneWidget);
      expect(find.text('500g'), findsWidgets);

      // Tap 1kg preset
      await tester.tap(find.text('1kg'));
      await tester.pumpAndSettle();

      expect(fill, '1kg');
      expect(dims.lengthCm, 26.0);
    });

    testWidgets('AddOnFeatureChecklist toggles items', (tester) async {
      List<FunctionalAddOn> addons = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AddOnFeatureChecklist(
                  selectedAddons: addons,
                  onAddonsChanged: (a) => setState(() => addons = a),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('4. Functional Add-ons'), findsOneWidget);
      expect(find.text('Resealable Zipper'), findsOneWidget);

      await tester.tap(find.text('Resealable Zipper'));
      await tester.pumpAndSettle();

      expect(addons.contains(FunctionalAddOn.resealableZipper), isTrue);
    });

    testWidgets('CostSummaryHeroCard renders KPIs and ESTIMATED badge', (tester) async {
      const response = CostEstimationResponse(
        materialName: 'NatureFlex Cellulose',
        packagingType: PackagingFormFactor.standUpDoypack,
        numberOfPackages: 10000,
        productFillQuantity: '500g',
        materialRequirement: MaterialRequirementDetail(
          surfaceAreaPerUnitSqm: 0.075,
          weightPerUnitGrams: 4.9,
          grossAreaRequiredSqm: 795.0,
          grossWeightRequiredKg: 51.9,
          scrapAllowancePercent: 6.0,
          scrapMaterialWeightKg: 2.9,
        ),
        costPerUnitInr: 4.85,
        totalEstimatedCostInr: 48500.0,
        costBreakdown: [],
        substrateCostSubtotalInr: 21000.0,
        convertingCostSubtotalInr: 12000.0,
        addonsCostSubtotalInr: 12500.0,
        toolingCostSubtotalInr: 3000.0,
        volumeDiscountAmountInr: 4000.0,
        volumeDiscountPercent: 8.0,
        volumeTierSensitivity: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostSummaryHeroCard(response: response),
          ),
        ),
      );

      expect(find.text('ESTIMATED BASELINE COST'), findsOneWidget);
      expect(find.text('ESTIMATED'), findsOneWidget);
      expect(find.text('₹48,500'), findsOneWidget);
      expect(find.text('₹4.85'), findsOneWidget);
      expect(find.textContaining('Volume savings of'), findsOneWidget);
    });

    testWidgets('MaterialFootprintCard, CostBreakdownChart, and VolumeSensitivityChart render smoothly',
        (tester) async {
      const matReq = MaterialRequirementDetail(
        surfaceAreaPerUnitSqm: 0.075,
        weightPerUnitGrams: 4.9,
        grossAreaRequiredSqm: 795.0,
        grossWeightRequiredKg: 51.9,
        scrapAllowancePercent: 6.0,
        scrapMaterialWeightKg: 2.9,
      );

      final breakdown = [
        const CostLayerItem(
          category: 'Substrate',
          itemName: 'Raw Polymer',
          costPerUnitInr: 2.10,
          totalCostInr: 21000.0,
          percentageOfTotal: 50.0,
        ),
        const CostLayerItem(
          category: 'Converting',
          itemName: 'Printing & Pouching',
          costPerUnitInr: 1.50,
          totalCostInr: 15000.0,
          percentageOfTotal: 35.0,
        ),
      ];

      final sensitivity = [
        const VolumeTierSensitivityPoint(
          tierLabel: '10k Units',
          orderVolume: 10000,
          costPerUnitInr: 4.85,
          totalCostInr: 48500.0,
          discountPercent: 8.0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const MaterialFootprintCard(materialRequirement: matReq, materialName: 'NatureFlex'),
                  CostBreakdownChart(costBreakdown: breakdown, totalEstimatedCostInr: 36000.0),
                  VolumeSensitivityChart(
                    volumeTierSensitivity: sensitivity,
                    currentOrderVolume: 10000,
                    onSelectVolume: (_) {},
                  ),
                  SupplierQuoteDisclaimerBanner(
                    disclaimerNotice: 'Test disclaimer message',
                    onRequestRfq: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Material Requirement & Technical Footprint'), findsOneWidget);
      expect(find.text('Cost Structure & Itemized Contribution'), findsOneWidget);
      expect(find.text('Volume Scaling & Economies of Scale'), findsOneWidget);
      expect(find.text('Test disclaimer message'), findsOneWidget);
    });
  });
}
