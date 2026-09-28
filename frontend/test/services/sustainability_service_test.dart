import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/services/offline_sustainability_engine.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';
import 'package:ai_packaging_recommender/models/sustainability_model.dart';

void main() {
  group('OfflineSustainabilityEngine Tests (Module 11 - Task 4.2)', () {
    test('Offline evaluate generates valid LDPE baseline profile', () {
      const input = SustainabilityEvaluateInput(
        materialId: 'mat_poly_ldpe_01',
        packageType: 'Stand-up Doypack (Bottom Gusset)',
        lengthCm: 18.0,
        widthCm: 12.0,
        depthOrGussetCm: 4.0,
        thicknessMicrons: 50.0,
        batchSizeUnits: 10000,
        pcrPercentage: 0.0,
      );

      final profile = OfflineSustainabilityEngine.evaluate(input);
      expect(profile.materialId, 'mat_poly_ldpe_01');
      expect(profile.recyclability, RecyclabilityTier.medium);
      expect(profile.biodegradability, BiodegradabilityTier.nonBiodegradable);
      expect(profile.environmentalIndicators.carbonFootprintKgCo2eTotalBatch, greaterThan(0.0));
      expect(profile.environmentalIndicators.waterFootprintLitersTotalBatch, greaterThan(0.0));
      expect(profile.wastePotential.unitWasteGrams, greaterThan(1.0));
      expect(profile.isEmpiricalVerified, isTrue);
    });

    test('PCR percentage reduces carbon footprint and increases circularity index', () {
      const virginInput = SustainabilityEvaluateInput(
        materialId: 'mat_poly_hdpe_02',
        packageType: 'Stand-up Doypack (Bottom Gusset)',
        lengthCm: 20.0,
        widthCm: 15.0,
        depthOrGussetCm: 5.0,
        thicknessMicrons: 60.0,
        batchSizeUnits: 10000,
        pcrPercentage: 0.0,
      );
      final virginProfile = OfflineSustainabilityEngine.evaluate(virginInput);

      const pcrInput = SustainabilityEvaluateInput(
        materialId: 'mat_poly_hdpe_02',
        packageType: 'Stand-up Doypack (Bottom Gusset)',
        lengthCm: 20.0,
        widthCm: 15.0,
        depthOrGussetCm: 5.0,
        thicknessMicrons: 60.0,
        batchSizeUnits: 10000,
        pcrPercentage: 50.0,
      );
      final pcrProfile = OfflineSustainabilityEngine.evaluate(pcrInput);

      expect(
        pcrProfile.environmentalIndicators.carbonFootprintKgCo2eTotalBatch,
        lessThan(virginProfile.environmentalIndicators.carbonFootprintKgCo2eTotalBatch),
      );
      expect(pcrProfile.environmentalIndicators.pcrCarbonReductionPct, greaterThan(10.0));
      expect(
        pcrProfile.wastePotential.circularityIndex,
        greaterThanOrEqualTo(virginProfile.wastePotential.circularityIndex),
      );
    });

    test('Biodegradable NatureFlex yields home compostable status and low waste', () {
      const input = SustainabilityEvaluateInput(
        materialId: 'mat_cell_natureflex_02',
        packageType: 'Pillow Pouch',
        lengthCm: 15.0,
        widthCm: 10.0,
        depthOrGussetCm: 0.0,
        thicknessMicrons: 28.0,
        batchSizeUnits: 5000,
      );
      final profile = OfflineSustainabilityEngine.evaluate(input);
      expect(profile.biodegradability, BiodegradabilityTier.high);
      expect(profile.wastePotential.wastePotentialLevel, WastePotentialLevel.veryLow);
      expect(profile.wastePotential.diversionPotentialPct, 95.0);
    });

    test('Offline compare synthesizes multi-material trade-offs', () {
      final result = OfflineSustainabilityEngine.compare(
        materialIds: ['mat_poly_ldpe_01', 'mat_bio_emap_01', 'mat_rpet_50_05'],
        packageType: 'Stand-up Doypack (Bottom Gusset)',
        lengthCm: 18.0,
        widthCm: 12.0,
        depthOrGussetCm: 4.0,
        thicknessMicrons: 50.0,
        batchSizeUnits: 10000,
      );

      expect(result.materials.length, 3);
      expect(result.bestRecyclabilityMaterialId, isNotEmpty);
      expect(result.lowestCarbonMaterialId, isNotEmpty);
      expect(result.ecoTradeoffSummary, isNotEmpty);
    });

    test('ApiService getSustainabilityProfile returns valid profile in offline mode', () async {
      final profile = await ApiService.getSustainabilityProfile('mat_poly_ldpe_01');
      expect(profile.materialId, 'mat_poly_ldpe_01');
      expect(profile.recyclability, RecyclabilityTier.medium);
    });
  });
}
