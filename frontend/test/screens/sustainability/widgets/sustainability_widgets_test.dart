import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/sustainability_model.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/sustainability_metric_pill.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/sustainability_profile_hero_card.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/lca_carbon_water_card.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/packaging_waste_potential_card.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/environmental_considerations_card.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/verified_data_citation_banner.dart';
import 'package:ai_packaging_recommender/screens/sustainability/widgets/sustainability_comparison_matrix.dart';
import 'package:ai_packaging_recommender/services/offline_sustainability_engine.dart';

void main() {
  final sampleProfile = OfflineSustainabilityEngine.evaluate(
    const SustainabilityEvaluateInput(
      materialId: 'mat_poly_hdpe_02',
      packageType: 'Stand-up Doypack (Bottom Gusset)',
      lengthCm: 18.0,
      widthCm: 12.0,
      depthOrGussetCm: 4.0,
      thicknessMicrons: 50.0,
      batchSizeUnits: 10000,
      pcrPercentage: 30.0,
    ),
  );

  Widget wrapWithApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }

  group('Modular Sustainability Widgets Tests (Module 11 - Tasks 5.1 & 5.2)', () {
    testWidgets('SustainabilityMetricPill renders text and icon', (tester) async {
      await tester.pumpWidget(wrapWithApp(
        const SustainabilityMetricPill(
          label: 'RIC 2 (HDPE)',
          color: Color(0xFF10B981),
          icon: Icons.qr_code_2_rounded,
        ),
      ));

      expect(find.text('RIC 2 (HDPE)'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
    });

    testWidgets('SustainabilityProfileHeroCard renders 3-pillar matrix and material type', (tester) async {
      await tester.pumpWidget(wrapWithApp(
        SustainabilityProfileHeroCard(profile: sampleProfile),
      ));

      expect(find.text(sampleProfile.materialName), findsOneWidget);
      expect(find.text('Recyclability'), findsOneWidget);
      expect(find.text('Biodegradability'), findsOneWidget);
      expect(find.text('Reusability'), findsOneWidget);
      expect(find.text('Material Feedstock & Composition'), findsOneWidget);
    });

    testWidgets('LcaCarbonWaterCard renders carbon, water, energy, and PCR savings', (tester) async {
      await tester.pumpWidget(wrapWithApp(
        LcaCarbonWaterCard(profile: sampleProfile, batchSize: 10000),
      ));

      expect(find.text('Life Cycle Assessment (LCA) Footprint'), findsOneWidget);
      expect(find.text('Carbon Footprint (GWP)'), findsOneWidget);
      expect(find.text('Freshwater Footprint'), findsOneWidget);
      expect(find.text('Primary Energy Demand'), findsOneWidget);
    });

    testWidgets('PackagingWastePotentialCard renders unit waste and diversion progress', (tester) async {
      await tester.pumpWidget(wrapWithApp(
        PackagingWastePotentialCard(
          wasteInfo: sampleProfile.wastePotential,
          batchSize: 10000,
        ),
      ));

      expect(find.text('Packaging Waste Potential & End-of-Life'), findsOneWidget);
      expect(find.text('Unit Packaging Waste'), findsOneWidget);
      expect(find.text('Batch Waste Generation'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('EnvironmentalConsiderationsCard and VerifiedDataCitationBanner render content', (tester) async {
      await tester.pumpWidget(wrapWithApp(
        Column(
          children: [
            EnvironmentalConsiderationsCard(profile: sampleProfile),
            const SizedBox(height: 10),
            VerifiedDataCitationBanner(profile: sampleProfile),
          ],
        ),
      ));

      expect(find.text('Environmental Considerations & Certifications'), findsOneWidget);
      expect(find.text('VERIFIED SCIENTIFIC PROVENANCE'), findsOneWidget);
      expect(find.textContaining('PlasticsEurope'), findsOneWidget);
    });

    testWidgets('SustainabilityComparisonMatrix renders multi-material cards', (tester) async {
      final compareResult = OfflineSustainabilityEngine.compare(
        materialIds: ['mat_poly_ldpe_01', 'mat_bio_emap_01', 'mat_rpet_50_05'],
      );

      await tester.pumpWidget(wrapWithApp(
        SustainabilityComparisonMatrix(compareResult: compareResult),
      ));

      expect(find.text('Multi-Material Sustainability Benchmark'), findsOneWidget);
      expect(find.textContaining('Comparison of 3 packaging formats'), findsOneWidget);
    });
  });
}
