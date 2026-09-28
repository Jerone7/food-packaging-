import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/cost_estimation_model.dart';

void main() {
  group('CostEstimationModel Tests', () {
    test('PackageDimensions serialization and defaults', () {
      const dims = PackageDimensions(
        lengthCm: 20.0,
        widthCm: 14.0,
        depthOrGussetCm: 6.0,
        thicknessMicrons: 45.0,
      );

      final json = dims.toJson();
      expect(json['length_cm'], 20.0);
      expect(json['width_cm'], 14.0);
      expect(json['depth_or_gusset_cm'], 6.0);
      expect(json['thickness_microns'], 45.0);

      final reconstructed = PackageDimensions.fromJson(json);
      expect(reconstructed.lengthCm, 20.0);
      expect(reconstructed.widthCm, 14.0);
      expect(reconstructed.depthOrGussetCm, 6.0);
      expect(reconstructed.thicknessMicrons, 45.0);
    });

    test('PackagingFormFactor string mapping', () {
      expect(PackagingFormFactor.fromString('Stand-up Doypack'), PackagingFormFactor.standUpDoypack);
      expect(PackagingFormFactor.fromString('Pillow Pouch'), PackagingFormFactor.pillowPouch);
      expect(PackagingFormFactor.fromString('Thermoformed Tray / Clamshell'), PackagingFormFactor.thermoformedTray);
      expect(PackagingFormFactor.fromString('Unknown Pouch'), PackagingFormFactor.standUpDoypack);
    });

    test('FunctionalAddOn unit pricing and string mapping', () {
      expect(FunctionalAddOn.resealableZipper.defaultUnitPriceInr, 0.40);
      expect(FunctionalAddOn.degassingValve.defaultUnitPriceInr, 0.85);
      expect(FunctionalAddOn.fromString('Laser Tear Notch'), FunctionalAddOn.tearNotch);
    });

    test('CostEstimationRequest full JSON round-trip', () {
      const req = CostEstimationRequest(
        materialId: 'MAT_BIO_001',
        materialName: 'NatureFlex Regenerated Cellulose',
        packagingType: PackagingFormFactor.standUpDoypack,
        dimensions: PackageDimensions(lengthCm: 20.0, widthCm: 14.0, depthOrGussetCm: 6.0, thicknessMicrons: 45.0),
        productFillQuantity: '500g',
        numberOfPackages: 10000,
        selectedAddons: [FunctionalAddOn.resealableZipper, FunctionalAddOn.degassingValve],
        customMaterialCostPerKg: 420.0,
        customScrapRatePercent: 6.0,
        includeToolingAmortization: true,
      );

      final json = req.toJson();
      expect(json['material_id'], 'MAT_BIO_001');
      expect(json['material_name'], 'NatureFlex Regenerated Cellulose');
      expect(json['packaging_type'], 'Stand-up Doypack');
      expect((json['selected_addons'] as List).length, 2);

      final reconstructed = CostEstimationRequest.fromJson(json);
      expect(reconstructed.materialId, 'MAT_BIO_001');
      expect(reconstructed.numberOfPackages, 10000);
      expect(reconstructed.selectedAddons.length, 2);
      expect(reconstructed.includeToolingAmortization, isTrue);
    });

    test('CostEstimationResponse full JSON round-trip', () {
      const matReq = MaterialRequirementDetail(
        surfaceAreaPerUnitSqm: 0.075075,
        weightPerUnitGrams: 4.9004,
        grossAreaRequiredSqm: 795.80,
        grossWeightRequiredKg: 51.94,
        scrapAllowancePercent: 6.0,
        scrapMaterialWeightKg: 2.94,
      );

      final layers = [
        const CostLayerItem(
          category: 'Substrate',
          itemName: 'Raw Cellulose',
          costPerUnitInr: 2.18,
          totalCostInr: 21800.0,
          percentageOfTotal: 45.0,
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

      final response = CostEstimationResponse(
        materialId: 'MAT_BIO_001',
        materialName: 'NatureFlex Regenerated Cellulose',
        packagingType: PackagingFormFactor.standUpDoypack,
        numberOfPackages: 10000,
        productFillQuantity: '500g',
        materialRequirement: matReq,
        costPerUnitInr: 4.85,
        totalEstimatedCostInr: 48500.0,
        costBreakdown: layers,
        substrateCostSubtotalInr: 21800.0,
        convertingCostSubtotalInr: 12000.0,
        addonsCostSubtotalInr: 12500.0,
        toolingCostSubtotalInr: 12000.0,
        volumeDiscountAmountInr: 4000.0,
        volumeDiscountPercent: 8.0,
        volumeTierSensitivity: sensitivity,
        pricingMode: 'Estimated Baseline Model',
        isEstimated: true,
      );

      final json = response.toJson();
      final reconstructed = CostEstimationResponse.fromJson(json);

      expect(reconstructed.costPerUnitInr, 4.85);
      expect(reconstructed.totalEstimatedCostInr, 48500.0);
      expect(reconstructed.isEstimated, isTrue);
      expect(reconstructed.disclaimerNotice, contains('ESTIMATED BASELINE'));
      expect(reconstructed.costBreakdown.length, 1);
      expect(reconstructed.volumeTierSensitivity.length, 1);
    });
  });
}
