import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/material_catalog_model.dart';

void main() {
  group('MaterialCatalogModel Tests', () {
    test('Round-trip JSON serialization for PackagingMaterialDetail', () {
      final json = {
        'id': 1,
        'material_id': 'mat_bio_emap_01',
        'name': 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)',
        'category': 'Biodegradable Bio-Polymer',
        'polymer_family': 'BREATHABLE_BIO_EMAP',
        'structure': 'Co-extruded Micro-Perforated PLA/PBAT Blown Film',
        'form_factor': 'Perforated Film Pouch',
        'barrier_profile': {
          'otr_cc_m2_day': 3500.0,
          'wvtr_g_m2_day': 45.0,
          'co2_permeability': 14000.0,
          'selectivity_beta': 4.0,
          'thickness_microns': 30.0,
          'barrier_tier': 'Breathable EMAP',
          'gas_flush_compatible': true,
        },
        'mechanical_profile': {
          'tensile_strength_mpa': 32.0,
          'puncture_resistance_n': 18.0,
          'elongation_pct': 220.0,
          'form_factor': 'Perforated Film Pouch',
          'durability_rating': 'Moderate',
        },
        'thermal_profile': {
          'temp_min_c': 0.0,
          'temp_max_c': 40.0,
          'thermal_class': 'Refrigerated Stable',
          'is_cryogenic_grade': false,
          'is_retort_grade': false,
        },
        'optical_profile': {
          'uv_transmittance_pct': 15.0,
          'optical_clarity': 'Translucent',
          'light_barrier_rating': 'Moderate',
        },
        'environmental_profile': {
          'sustainability_score': 94.0,
          'recyclability_score': 0.0,
          'biodegradability_score': 98.0,
          'is_biodegradable': true,
          'is_recyclable': false,
          'resin_code': 'OTHER_7',
          'composting_standard': 'EN 13432 / ASTM D6400',
        },
        'economic_profile': {
          'cost_category': 'Commercial Standard',
          'estimated_unit_cost_inr': 3.85,
          'market_scalability': 'Growing Commercial',
        },
        'functional_flags': {
          'is_breathable': true,
          'is_biodegradable': true,
          'is_recyclable': false,
          'is_retort_grade': false,
          'is_cryogenic_grade': false,
          'gas_flush_compatible': true,
        },
        'recommended_applications': ['Fresh vegetables', 'Climacteric fruits'],
        'regulatory_certifications': ['FDA 21 CFR 177', 'EU 10/2011'],
        'radar_scores': {
          'barrier_score': 45.0,
          'mechanical_score': 20.0,
          'sustainability_score': 94.0,
          'thermal_score': 25.0,
          'cost_efficiency_score': 65.0,
          'optical_score': 65.0,
        },
        'notes': 'Tailored laser micro-perforations.',
        'is_active_entry': true,
      };

      final model = PackagingMaterialDetail.fromJson(json);

      expect(model.materialId, 'mat_bio_emap_01');
      expect(model.name, 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)');
      expect(model.barrierProfile.otrCcM2Day, 3500.0);
      expect(model.barrierProfile.selectivityBeta, 4.0);
      expect(model.environmentalProfile.isBiodegradable, isTrue);
      expect(model.radarScores.sustainabilityScore, 94.0);
      expect(model.recommendedApplications.length, 2);

      final outJson = model.toJson();
      expect(outJson['material_id'], 'mat_bio_emap_01');
      expect(outJson['radar_scores']['sustainability_score'], 94.0);
    });

    test('MaterialComparisonResult parses side-by-side matrices', () {
      final compJson = {
        'materials': [
          {
            'material_id': 'mat_1',
            'name': 'Material 1',
            'category': 'Conventional',
            'polymer_family': 'LDPE',
            'structure': 'LDPE Film',
            'barrier_profile': {
              'otr_cc_m2_day': 100.0,
              'wvtr_g_m2_day': 5.0,
              'thickness_microns': 40.0,
              'barrier_tier': 'Moderate',
            },
            'mechanical_profile': {
              'tensile_strength_mpa': 20.0,
              'puncture_resistance_n': 15.0,
              'form_factor': 'Pouch',
            },
            'thermal_profile': {
              'temp_min_c': -20.0,
              'temp_max_c': 60.0,
              'thermal_class': 'Ambient',
            },
            'optical_profile': {
              'optical_clarity': 'Translucent',
            },
            'environmental_profile': {
              'sustainability_score': 45.0,
            },
            'economic_profile': {
              'cost_category': 'Budget',
              'estimated_unit_cost_inr': 1.5,
            },
            'radar_scores': {
              'barrier_score': 50.0,
              'mechanical_score': 40.0,
              'sustainability_score': 45.0,
              'thermal_score': 50.0,
              'cost_efficiency_score': 85.0,
              'optical_score': 60.0,
            },
          }
        ],
        'radar_datasets': {
          'mat_1': {
            'barrier_score': 50.0,
            'mechanical_score': 40.0,
            'sustainability_score': 45.0,
            'thermal_score': 50.0,
            'cost_efficiency_score': 85.0,
            'optical_score': 60.0,
          }
        },
        'trade_off_analysis': ['Mat 1 offers high procurement cost efficiency.'],
        'best_in_class_highlights': {'Lowest Cost / Unit': 'Material 1'},
      };

      final result = MaterialComparisonResult.fromJson(compJson);
      expect(result.materials.length, 1);
      expect(result.radarDatasets.containsKey('mat_1'), isTrue);
      expect(result.radarDatasets['mat_1']!.costEfficiencyScore, 85.0);
      expect(result.tradeOffAnalysis.first, contains('procurement cost efficiency'));
    });

    test('MaterialCategorySummary parses category aggregations', () {
      final catJson = {
        'category': 'Biodegradable Bio-Polymer',
        'count': 6,
        'sample_materials': ['PLA', 'NatureFlex', 'PHA'],
        'average_sustainability': 92.5,
        'description': 'Collection of 6 biodegradable options.',
      };

      final summary = MaterialCategorySummary.fromJson(catJson);
      expect(summary.category, 'Biodegradable Bio-Polymer');
      expect(summary.count, 6);
      expect(summary.sampleMaterials.length, 3);
      expect(summary.averageSustainability, 92.5);
    });
  });
}
