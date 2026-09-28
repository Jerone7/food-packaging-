import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/sustainability_model.dart';

void main() {
  group('Sustainability Models & Enums Tests (Module 11 - Task 4.1)', () {
    test('Enums parse strings and provide valid colors and icons', () {
      expect(RecyclabilityTier.fromString('High'), RecyclabilityTier.high);
      expect(RecyclabilityTier.fromString('Medium'), RecyclabilityTier.medium);
      expect(RecyclabilityTier.fromString('Non-Recyclable'), RecyclabilityTier.nonRecyclable);

      expect(BiodegradabilityTier.fromString('High'), BiodegradabilityTier.high);
      expect(BiodegradabilityTier.fromString('Non-Biodegradable'), BiodegradabilityTier.nonBiodegradable);

      expect(ReusabilityTier.fromString('High'), ReusabilityTier.high);
      expect(ReusabilityTier.fromString('Single-Use'), ReusabilityTier.singleUse);

      expect(WastePotentialLevel.fromString('Very Low'), WastePotentialLevel.veryLow);
      expect(WastePotentialLevel.fromString('High'), WastePotentialLevel.high);

      // Colors and icons exist
      for (final r in RecyclabilityTier.values) {
        expect(r.color, isNotNull);
        expect(r.icon, isNotNull);
      }
      for (final b in BiodegradabilityTier.values) {
        expect(b.color, isNotNull);
        expect(b.icon, isNotNull);
      }
      for (final u in ReusabilityTier.values) {
        expect(u.color, isNotNull);
        expect(u.icon, isNotNull);
      }
    });

    test('SustainabilityProfile deserialization from JSON', () {
      final json = {
        'material_id': 'mat_poly_hdpe_02',
        'material_name': 'High-Density Polyethylene (HDPE)',
        'category': 'Conventional Polymer',
        'polymer_family': 'RIGID_POLYMER',
        'resin_identification_code': 'RIC 2',
        'recyclability': 'High',
        'recyclability_notes': 'Curbside stream #2',
        'biodegradability': 'Non-Biodegradable',
        'biodegradability_standard': null,
        'biodegradability_notes': 'Non-bio',
        'reusability': 'High',
        'reusability_cycles': 35,
        'material_type_description': 'HDPE thermoplastic',
        'pcr_content_pct': 30.0,
        'bio_based_content_pct': 0.0,
        'environmental_considerations': ['Avoid carbon black'],
        'regulatory_certifications': ['FDA 21 CFR 177.1520'],
        'environmental_indicators': {
          'carbon_footprint_kg_co2e_per_unit': 0.0192,
          'carbon_footprint_kg_co2e_total_batch': 192.0,
          'water_footprint_liters_per_unit': 0.65,
          'water_footprint_liters_total_batch': 6500.0,
          'pcr_carbon_reduction_pct': 22.5,
          'embodied_energy_mj_per_kg': 76.2,
        },
        'waste_potential': {
          'unit_waste_grams': 10.0,
          'total_batch_waste_kg': 100.0,
          'waste_potential_level': 'Low',
          'landfill_burden_kg': 15.0,
          'diversion_potential_pct': 85.0,
          'circularity_index': 0.82,
          'primary_disposal_pathway': 'Curbside Rigid Bin #2',
        },
        'verified_data_source': 'PlasticsEurope',
        'source_doi_or_standard': '10.1016/j.jclepro.2020.124500',
        'is_empirical_verified': true,
      };

      final profile = SustainabilityProfile.fromJson(json);
      expect(profile.materialId, 'mat_poly_hdpe_02');
      expect(profile.recyclability, RecyclabilityTier.high);
      expect(profile.biodegradability, BiodegradabilityTier.nonBiodegradable);
      expect(profile.reusability, ReusabilityTier.high);
      expect(profile.reusabilityCycles, 35);
      expect(profile.environmentalIndicators.pcrCarbonReductionPct, 22.5);
      expect(profile.wastePotential.circularityIndex, 0.82);
      expect(profile.isEmpiricalVerified, isTrue);

      final encoded = profile.toJson();
      expect(encoded['material_id'], 'mat_poly_hdpe_02');
      expect(encoded['recyclability'], 'High');
    });

    test('SustainabilityEvaluateInput converts to JSON', () {
      const input = SustainabilityEvaluateInput(
        materialId: 'mat_cell_natureflex_02',
        packageType: 'Pillow Pouch',
        lengthCm: 15.0,
        widthCm: 10.0,
        depthOrGussetCm: 0.0,
        thicknessMicrons: 28.0,
        batchSizeUnits: 5000,
        pcrPercentage: 0.0,
      );

      final json = input.toJson();
      expect(json['material_id'], 'mat_cell_natureflex_02');
      expect(json['package_type'], 'Pillow Pouch');
      expect(json['batch_size_units'], 5000);
    });

    test('SustainabilityCompareResult deserializes valid response', () {
      final json = {
        'materials': [
          {
            'material_id': 'mat_poly_ldpe_01',
            'material_name': 'LDPE',
            'category': 'Polymer',
            'polymer_family': 'FLEXIBLE',
            'resin_identification_code': 'RIC 4',
            'recyclability': 'Medium',
            'recyclability_notes': 'Store drop-off',
            'biodegradability': 'Non-Biodegradable',
            'biodegradability_standard': null,
            'biodegradability_notes': 'Non-bio',
            'reusability': 'Low',
            'reusability_cycles': 2,
            'material_type_description': 'PE film',
            'pcr_content_pct': 0.0,
            'bio_based_content_pct': 0.0,
            'environmental_considerations': [],
            'regulatory_certifications': [],
            'environmental_indicators': {
              'carbon_footprint_kg_co2e_per_unit': 0.02,
              'carbon_footprint_kg_co2e_total_batch': 200.0,
              'water_footprint_liters_per_unit': 0.8,
              'water_footprint_liters_total_batch': 8000.0,
              'pcr_carbon_reduction_pct': 0.0,
              'embodied_energy_mj_per_kg': 78.0,
            },
            'waste_potential': {
              'unit_waste_grams': 10.0,
              'total_batch_waste_kg': 100.0,
              'waste_potential_level': 'Moderate',
              'landfill_burden_kg': 35.0,
              'diversion_potential_pct': 65.0,
              'circularity_index': 0.68,
              'primary_disposal_pathway': 'PE Film Recycling',
            },
            'verified_data_source': 'Sphera',
            'source_doi_or_standard': 'ISO 14040',
            'is_empirical_verified': true,
          }
        ],
        'best_recyclability_material_id': 'mat_poly_ldpe_01',
        'lowest_carbon_material_id': 'mat_poly_ldpe_01',
        'lowest_waste_material_id': 'mat_poly_ldpe_01',
        'eco_tradeoff_summary': 'LDPE provides standard performance.',
      };

      final result = SustainabilityCompareResult.fromJson(json);
      expect(result.materials.length, 1);
      expect(result.bestRecyclabilityMaterialId, 'mat_poly_ldpe_01');
      expect(result.ecoTradeoffSummary, contains('LDPE'));
    });
  });
}
