import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/packaging_comparison_model.dart';
import 'package:ai_packaging_recommender/models/material_catalog_model.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/comparison_parameter_table.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/material_slot_card.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/material_selector_strip.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/quick_material_picker_modal.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/comparative_radar_view.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/best_in_class_summary_card.dart';
import 'package:ai_packaging_recommender/screens/comparison/widgets/ai_trade_off_banner.dart';

void main() {
  const sampleSlotA = MaterialComparisonSlot(
    slotId: 'material_a',
    materialId: 'mat_bio_emap_01',
    name: 'Micro-Perforated Bio-Film (PLA/PBAT)',
    category: 'Biodegradable Bio-Polymer',
    polymerFamily: 'BREATHABLE_BIO_EMAP',
    structure: 'PLA/PBAT Film',
    colorToken: Color(0xFF0D9488),
    isPrimaryRecommendation: true,
    moistureBarrier: 'High',
    oxygenBarrier: 'Medium',
    gasExchange: 'High',
    strength: 'High',
    recyclability: 'Biodegradable',
    costCategory: 'Medium',
    wvtrValue: 45.0,
    otrValue: 3500.0,
    tensileStrengthMpa: 32.0,
    estimatedCostInr: 3.85,
    sustainabilityScore: 94.0,
  );

  const sampleSlotB = MaterialComparisonSlot(
    slotId: 'material_b',
    materialId: 'mat_al_foil_lam_13',
    name: 'Aluminium Foil Laminate (PET/AL/PE)',
    category: 'High-Barrier Laminate',
    polymerFamily: 'FOIL_LAMINATE',
    structure: '12µm PET / 9µm AL / 50µm PE',
    colorToken: Color(0xFF0284C7),
    isPrimaryRecommendation: false,
    moistureBarrier: 'High',
    oxygenBarrier: 'High',
    gasExchange: 'Low',
    strength: 'High',
    recyclability: 'No',
    costCategory: 'High',
    wvtrValue: 0.05,
    otrValue: 0.05,
    tensileStrengthMpa: 88.0,
    estimatedCostInr: 4.80,
    sustainabilityScore: 28.0,
  );

  const sampleSlotC = MaterialComparisonSlot(
    slotId: 'material_c',
    materialId: 'mat_pp_clamshell_06',
    name: 'Polypropylene (PP) Clamshell',
    category: 'Conventional Polymer',
    polymerFamily: 'PP',
    structure: 'Thermoformed PP',
    colorToken: Color(0xFFD97706),
    isPrimaryRecommendation: false,
    moistureBarrier: 'Medium',
    oxygenBarrier: 'Medium',
    gasExchange: 'Medium',
    strength: 'Medium',
    recyclability: 'Yes',
    costCategory: 'Low',
    wvtrValue: 4.5,
    otrValue: 120.0,
    tensileStrengthMpa: 36.0,
    estimatedCostInr: 2.10,
    sustainabilityScore: 58.0,
  );

  final sampleRows = [
    const ComparisonParameterRowModel(
      parameterKey: 'moisture_barrier',
      parameterLabel: 'Moisture Barrier',
      parameterGroup: 'Barrier Performance',
      unit: 'g/m²·day',
      values: {'material_a': 'High', 'material_b': 'High', 'material_c': 'Medium'},
      rawNumericValues: {'material_a': 45.0, 'material_b': 0.05, 'material_c': 4.5},
      bestSlotId: 'material_b',
      scientificNote: 'Lower WVTR prevents transpiration loss.',
    ),
    const ComparisonParameterRowModel(
      parameterKey: 'oxygen_barrier',
      parameterLabel: 'Oxygen Barrier',
      parameterGroup: 'Barrier Performance',
      unit: 'cc/m²·day',
      values: {'material_a': 'Medium', 'material_b': 'High', 'material_c': 'Medium'},
      rawNumericValues: {'material_a': 3500.0, 'material_b': 0.05, 'material_c': 120.0},
      bestSlotId: 'material_b',
      scientificNote: 'Low OTR inhibits oxidative browning.',
    ),
    const ComparisonParameterRowModel(
      parameterKey: 'recyclability',
      parameterLabel: 'Recyclability',
      parameterGroup: 'Circularity & Eco',
      values: {'material_a': 'Biodegradable', 'material_b': 'No', 'material_c': 'Yes'},
      rawNumericValues: {'material_a': 94.0, 'material_b': 28.0, 'material_c': 58.0},
      bestSlotId: 'material_a',
    ),
    const ComparisonParameterRowModel(
      parameterKey: 'cost_category',
      parameterLabel: 'Cost Category',
      parameterGroup: 'Commercial & Cost',
      unit: '₹',
      values: {'material_a': 'Medium', 'material_b': 'High', 'material_c': 'Low'},
      rawNumericValues: {'material_a': 3.85, 'material_b': 4.80, 'material_c': 2.10},
      bestSlotId: 'material_c',
    ),
  ];

  group('ComparisonParameterTable Widget Tests', () {
    testWidgets('renders table header, parameter labels, values, and best-in-class badges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ComparisonParameterTable(
                slots: const [sampleSlotA, sampleSlotB, sampleSlotC],
                parameterRows: sampleRows,
                showQuantitativeMetrics: true,
              ),
            ),
          ),
        ),
      );

      // Verify Headers
      expect(find.text('Comparison Parameters'), findsOneWidget);
      expect(find.text('Material A'), findsOneWidget);
      expect(find.text('Material B'), findsOneWidget);
      expect(find.text('Material C'), findsOneWidget);

      // Verify Group Headers
      expect(find.text('BARRIER PERFORMANCE'), findsOneWidget);
      expect(find.text('CIRCULARITY & ECO'), findsOneWidget);
      expect(find.text('COMMERCIAL & COST'), findsOneWidget);

      // Verify parameter labels
      expect(find.text('Moisture Barrier'), findsOneWidget);
      expect(find.text('Oxygen Barrier'), findsOneWidget);
      expect(find.text('Recyclability'), findsOneWidget);
      expect(find.text('Cost Category'), findsOneWidget);

      // Verify values
      expect(find.text('Biodegradable'), findsOneWidget);
      expect(find.text('₹2.10 / unit'), findsOneWidget);

      // Best in class badges
      expect(find.text('Best'), findsWidgets);
    });
  });

  group('MaterialSlotCard & SelectorStrip Widget Tests', () {
    testWidgets('MaterialSlotCard renders populated material information', (tester) async {
      bool changeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialSlotCard(
              slotId: ComparisonSlotId.materialA,
              slot: sampleSlotA,
              onSelectOrChange: () => changeTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Material A'), findsOneWidget);
      expect(find.text('AI Top Pick'), findsOneWidget);
      expect(find.text('Micro-Perforated Bio-Film (PLA/PBAT)'), findsOneWidget);
      expect(find.text('₹3.85'), findsOneWidget);
      expect(find.text('Biodegradable'), findsOneWidget);

      // Tap change button
      await tester.tap(find.byTooltip('Swap Material'));
      expect(changeTapped, isTrue);
    });

    testWidgets('MaterialSlotCard renders empty placeholder when slot is null', (tester) async {
      bool addTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialSlotCard(
              slotId: ComparisonSlotId.materialC,
              slot: null,
              onSelectOrChange: () => addTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Material C'), findsOneWidget);
      expect(find.text('Compare up to 3 materials'), findsOneWidget);

      await tester.tap(find.text('Add Material C'));
      expect(addTapped, isTrue);
    });

    testWidgets('MaterialSelectorStrip renders all 3 slots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialSelectorStrip(
              slots: const [sampleSlotA, sampleSlotB],
              onSlotPick: (_) {},
              onSlotRemove: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Material A'), findsOneWidget);
      expect(find.text('Material B'), findsOneWidget);
      expect(find.text('Add Material C'), findsOneWidget);
    });
  });

  group('QuickMaterialPickerModal Tests', () {
    testWidgets('renders search field, categories, and lets user select a material', (tester) async {
      PackagingMaterialDetail? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickMaterialPickerModal(
              targetSlot: ComparisonSlotId.materialB,
              currentlySelectedMaterialIds: const ['mat_bio_emap_01'],
              onMaterialSelected: (mat) => selected = mat,
            ),
          ),
        ),
      );

      expect(find.text('Assign to Material B'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Tap first available Select button
      final selectButtons = find.widgetWithText(ElevatedButton, 'Select');
      expect(selectButtons, findsWidgets);

      await tester.tap(selectButtons.first);
      expect(selected, isNotNull);
    });
  });

  group('ComparativeRadarView & Summary Cards Tests', () {
    testWidgets('ComparativeRadarView renders painter and slot legends', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComparativeRadarView(
              slots: [sampleSlotA, sampleSlotB, sampleSlotC],
            ),
          ),
        ),
      );

      expect(find.text('Comparative Multi-Axis Radar'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Material A: Micro-Perforated Bio-Film (PLA/PBAT)'), findsOneWidget);
    });

    testWidgets('BestInClassSummaryCard renders champions summary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BestInClassSummaryCard(
              bestInClassSummary: {
                'Moisture Barrier': 'Aluminium Foil Laminate',
                'Cost Efficiency': 'PP Clamshell',
              },
            ),
          ),
        ),
      );

      expect(find.text('Category Champions (Best-in-Class)'), findsOneWidget);
      expect(find.text('Moisture Barrier: '), findsOneWidget);
      expect(find.text('Aluminium Foil Laminate'), findsOneWidget);
      expect(find.text('Cost Efficiency: '), findsOneWidget);
      expect(find.text('PP Clamshell'), findsOneWidget);
    });

    testWidgets('AiTradeOffBanner renders synthesis and decision rule', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiTradeOffBanner(
              aiTradeOffSynthesis: 'Material A provides superior gas breathability while Material B maximizes moisture barrier.',
              keyRecommendationRule: 'Opt for Material A for fresh produce shelf-life, and Material B for vacuum-packed items.',
              foodContextName: 'Fresh Strawberries',
            ),
          ),
        ),
      );

      expect(find.text('AI Trade-Off Analysis for Fresh Strawberries'), findsOneWidget);
      expect(find.textContaining('Material A provides superior gas breathability'), findsOneWidget);
      expect(find.textContaining('Opt for Material A for fresh produce shelf-life'), findsOneWidget);
    });
  });
}
