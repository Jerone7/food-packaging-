import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';

void main() {
  group('ApiService Scientific Profile Retrieval Tests', () {
    test('getScientificProfile successfully parses online API response', () async {
      final mockResponse = {
        'food_id': 1,
        'commodity_name': 'Fresh Apple',
        'scientific_name': 'Malus domestica',
        'category': 'Fruits',
        'physicochemical': {
          'moisture_pct': 85.5,
          'fat_pct': 0.3,
          'ph': 3.8,
          'water_activity': 0.98,
          'moisture_sensitivity': 'Moderate',
        },
        'physiological_kinetics': {
          'respiration_class': 'Moderate',
          'respiration_rate_20c': 16.0,
          'ethylene_production_class': 'Very High',
          'ethylene_sensitivity': 'High',
        },
        'atmosphere_sensitivities': {
          'oxygen_sensitivity': 'Moderate',
          'co2_sensitivity': 'Moderate',
          'max_tolerable_co2_pct': 3.0,
        },
        'thermal_and_storage': {
          'perishability': 'Semi-perishable',
          'optimum_temp_min_c': 0.0,
          'optimum_temp_max_c': 3.0,
          'ambient_shelf_life_days': 14,
        },
        'spoilage_and_vulnerabilities': {
          'light_sensitivity': 'Low',
          'aroma_sensitivity': 'Moderate',
          'microbial_spoilage_vector': 'Penicillium expansum',
          'mechanical_sensitivity': 'Moderate',
        },
        'packaging_prescriptions': {
          'recommended_barrier_type': 'Selective Gas-Permeable Bio-Film with 1-MCP',
          'required_otr_range': '2000 - 4000 cc/m²/day',
          'required_wvtr_range': '30 - 60 g/m²/day',
          'ethylene_action_required': true,
        },
        'source': 'ICMR-NIN IFCT 2017 & UC Davis Postharvest Facts',
        'confidence_score': 0.98,
      };

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final profile = await ApiService.getScientificProfile(1, client: client);

      expect(profile.commodityName, 'Fresh Apple');
      expect(profile.physicochemical.moisturePct, 85.5);
      expect(profile.packagingPrescriptions.ethyleneActionRequired, isTrue);
    });

    test('lookupScientificProfile falls back to offline catalog gracefully', () async {
      final client = MockClient((request) async {
        throw Exception('Network error');
      });

      final profile = await ApiService.lookupScientificProfile('Tomato', category: 'Vegetables', client: client);

      expect(profile.commodityName, 'Fresh Tomato');
      expect(profile.physicochemical.moisturePct, 94.5);
      expect(profile.thermalAndStorage.chillingInjuryThresholdC, 10.0);
      expect(profile.packagingPrescriptions.recommendedBarrierType, contains('Micro-Perforated'));
    });

    test('getFallbackScientificProfile generates rich profiles for Potato Chips and Chicken', () {
      final chips = ApiService.getFallbackScientificProfile('Potato Chips (fried)', category: 'Other perishables');
      expect(chips.physicochemical.moisturePct, 2.0);
      expect(chips.physicochemical.fatPct, 33.0);
      expect(chips.packagingPrescriptions.recommendedBarrierType, contains('Met-PET'));

      final chicken = ApiService.getFallbackScientificProfile('Fresh Chicken Breast', category: 'Meat');
      expect(chicken.physicochemical.moisturePct, 74.0);
      expect(chicken.atmosphereSensitivities.targetEmapCo2Pct, contains('70.0% CO2'));
    });
  });
}
