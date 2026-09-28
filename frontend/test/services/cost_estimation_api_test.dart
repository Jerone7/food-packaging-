import 'package:flutter_test/flutter_test.dart';
import 'package:ai_packaging_recommender/models/cost_estimation_model.dart';
import 'package:ai_packaging_recommender/services/offline_cost_engine.dart';
import 'package:ai_packaging_recommender/services/api_service.dart';

void main() {
  group('OfflineCostEngine & ApiService Cost Tests', () {
    test('Offline surface area calculations for all form factors', () {
      const dims = PackageDimensions(lengthCm: 20.0, widthCm: 14.0, depthOrGussetCm: 6.0);

      final pillowArea = OfflineCostEngine.calculateSurfaceArea(PackagingFormFactor.pillowPouch, dims);
      expect(pillowArea, closeTo(0.0660, 0.001));

      final doypackArea = OfflineCostEngine.calculateSurfaceArea(PackagingFormFactor.standUpDoypack, dims);
      expect(doypackArea, closeTo(0.075075, 0.001));

      final threeSideArea = OfflineCostEngine.calculateSurfaceArea(PackagingFormFactor.threeSideSeal, dims);
      expect(threeSideArea, closeTo(0.0672, 0.001));

      final quadArea = OfflineCostEngine.calculateSurfaceArea(PackagingFormFactor.fourSideQuadSeal, dims);
      expect(quadArea, closeTo(0.1232, 0.001));

      final trayArea = OfflineCostEngine.calculateSurfaceArea(PackagingFormFactor.thermoformedTray, dims);
      expect(trayArea, closeTo(0.077056, 0.001));

      final vacuumArea = OfflineCostEngine.calculateSurfaceArea(PackagingFormFactor.vacuumRetortPouch, dims);
      expect(vacuumArea, closeTo(0.0704, 0.001));

      final cartonArea = OfflineCostEngine.calculateSurfaceArea(PackagingFormFactor.foldingCarton, dims);
      expect(cartonArea, closeTo(0.118096, 0.001));
    });

    test('Offline density lookups and tier discounts', () {
      expect(OfflineCostEngine.getPolymerDensity('NatureFlex Cellulose'), 1450.0);
      expect(OfflineCostEngine.getPolymerDensity('Bio-PLA Film'), 1250.0);
      expect(OfflineCostEngine.getPolymerDensity('Al-Foil Barrier'), 2700.0);

      final (disc1k, _) = OfflineCostEngine.getVolumeDiscountTier(1000);
      expect(disc1k, 0.0);

      final (disc10k, _) = OfflineCostEngine.getVolumeDiscountTier(10000);
      expect(disc10k, 8.0);

      final (disc50k, _) = OfflineCostEngine.getVolumeDiscountTier(50000);
      expect(disc50k, 16.0);

      final (disc100k, _) = OfflineCostEngine.getVolumeDiscountTier(100000);
      expect(disc100k, 24.0);
    });

    test('Full OfflineCostEngine calculation parity', () {
      const req = CostEstimationRequest(
        materialId: 'MAT_BIO_001',
        materialName: 'NatureFlex Cellulose',
        packagingType: PackagingFormFactor.standUpDoypack,
        dimensions: PackageDimensions(lengthCm: 20.0, widthCm: 14.0, depthOrGussetCm: 6.0, thicknessMicrons: 45.0),
        productFillQuantity: '500g',
        numberOfPackages: 10000,
        selectedAddons: [FunctionalAddOn.resealableZipper, FunctionalAddOn.degassingValve],
        customMaterialCostPerKg: 420.0,
        customScrapRatePercent: 6.0,
        includeToolingAmortization: true,
      );

      final response = OfflineCostEngine.calculateCostEstimate(req);

      expect(response.isEstimated, isTrue);
      expect(response.disclaimerNotice, contains('ESTIMATED BASELINE'));
      expect(response.materialRequirement.surfaceAreaPerUnitSqm, closeTo(0.075075, 0.0001));
      expect(response.materialRequirement.weightPerUnitGrams, closeTo(4.9004, 0.01));
      expect(response.materialRequirement.grossWeightRequiredKg, closeTo(51.94, 0.1));
      expect(response.costPerUnitInr, greaterThan(0));
      expect(response.totalEstimatedCostInr, greaterThan(0));
      expect(response.costBreakdown.length, 5);
      expect(response.volumeTierSensitivity.length, 5);
    });

    test('ApiService.calculateCostEstimate offline fallback execution', () async {
      const req = CostEstimationRequest(
        materialName: 'LDPE Polyethylene',
        packagingType: PackagingFormFactor.pillowPouch,
        dimensions: PackageDimensions(lengthCm: 15.0, widthCm: 10.0),
        numberOfPackages: 5000,
      );

      final response = await ApiService.calculateCostEstimate(req);
      expect(response.materialName, 'LDPE Polyethylene');
      expect(response.costPerUnitInr, greaterThan(0));
      expect(response.totalEstimatedCostInr, greaterThan(0));
      expect(response.isEstimated, isTrue);
    });
  });
}
