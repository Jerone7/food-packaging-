import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/food_scientific_profile.dart';

void main() {
  group('FoodScientificProfile Model Unit Tests', () {
    test('deserializes complete 14-property scientific profile JSON', () {
      final json = {
        'food_id': 12,
        'commodity_name': 'Fresh Tomato',
        'scientific_name': 'Solanum lycopersicum',
        'category': 'Vegetables',
        'physicochemical': {
          'moisture_pct': 94.5,
          'fat_pct': 0.2,
          'ph': 4.4,
          'water_activity': 0.99,
          'moisture_sensitivity': 'High',
          'equilibrium_rh_target_pct': 90.0,
        },
        'physiological_kinetics': {
          'respiration_class': 'Moderate',
          'respiration_rate_5c': 8.0,
          'respiration_rate_20c': 28.0,
          'respiratory_quotient': 0.98,
          'ethylene_production_class': 'Moderate',
          'ethylene_prod_rate': 4.5,
          'ethylene_sensitivity': 'High',
        },
        'atmosphere_sensitivities': {
          'oxygen_sensitivity': 'Moderate',
          'co2_sensitivity': 'Moderate',
          'max_tolerable_co2_pct': 5.0,
          'target_emap_o2_pct': '3.0 - 5.0%',
          'target_emap_co2_pct': '3.0 - 5.0%',
        },
        'thermal_and_storage': {
          'perishability': 'Highly perishable',
          'optimum_temp_min_c': 12.0,
          'optimum_temp_max_c': 15.0,
          'chilling_injury_threshold_c': 10.0,
          'freezing_point_c': -0.6,
          'ambient_shelf_life_days': 7,
          'refrigerated_shelf_life_days': 21,
          'controlled_atmosphere_shelf_life_days': 35,
        },
        'spoilage_and_vulnerabilities': {
          'light_sensitivity': 'Low',
          'aroma_sensitivity': 'Low',
          'microbial_spoilage_vector': 'Fungal rots (Botrytis cinerea)',
          'mechanical_sensitivity': 'High',
        },
        'packaging_prescriptions': {
          'recommended_barrier_type': 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)',
          'required_otr_range': '3000 - 5000 cc/m²/day',
          'required_wvtr_range': '40 - 80 g/m²/day',
          'ethylene_action_required': true,
          'thermal_warning': 'DO NOT refrigerate below 10°C',
          'cushioning_directive': 'Honeycomb kraft protective sleeving',
        },
        'source': 'ICMR-NIN IFCT 2017 & UC Davis Postharvest Facts',
        'confidence_score': 0.98,
      };

      final profile = FoodScientificProfile.fromJson(json);

      expect(profile.commodityName, 'Fresh Tomato');
      expect(profile.scientificName, 'Solanum lycopersicum');
      expect(profile.category, 'Vegetables');
      expect(profile.physicochemical.moisturePct, 94.5);
      expect(profile.physiologicalKinetics.respirationRate20c, 28.0);
      expect(profile.thermalAndStorage.isChillingSensitive, isTrue);
      expect(profile.thermalAndStorage.chillingInjuryThresholdC, 10.0);
      expect(profile.packagingPrescriptions.ethyleneActionRequired, isTrue);

      // Verify serialization round-trip
      final serialized = profile.toJson();
      expect(serialized['commodity_name'], 'Fresh Tomato');
      expect(serialized['physicochemical']['moisture_pct'], 94.5);
    });

    test('handles null chilling injury threshold correctly', () {
      final json = {
        'commodity_name': 'Fresh Spinach',
        'category': 'Vegetables',
        'physicochemical': {
          'moisture_pct': 91.4,
          'fat_pct': 0.4,
          'ph': 6.8,
          'water_activity': 0.99,
          'moisture_sensitivity': 'Extreme',
        },
        'physiological_kinetics': {
          'respiration_class': 'Extremely High',
        },
        'atmosphere_sensitivities': {
          'oxygen_sensitivity': 'High',
          'co2_sensitivity': 'Moderate',
        },
        'thermal_and_storage': {
          'perishability': 'Ultra-perishable',
          'optimum_temp_min_c': 0.0,
          'optimum_temp_max_c': 2.0,
          'chilling_injury_threshold_c': null,
          'ambient_shelf_life_days': 2,
        },
        'spoilage_and_vulnerabilities': {
          'light_sensitivity': 'Moderate',
          'aroma_sensitivity': 'Low',
          'microbial_spoilage_vector': 'Pectobacterium',
          'mechanical_sensitivity': 'High',
        },
        'packaging_prescriptions': {
          'recommended_barrier_type': 'High-Permeability Laser Micro-Perforated PLA',
          'required_otr_range': '6000 - 9000 cc/m²/day',
          'required_wvtr_range': '50 - 90 g/m²/day',
        },
      };

      final profile = FoodScientificProfile.fromJson(json);
      expect(profile.thermalAndStorage.isChillingSensitive, isFalse);
      expect(profile.thermalAndStorage.chillingInjuryThresholdC, isNull);
    });
  });
}
