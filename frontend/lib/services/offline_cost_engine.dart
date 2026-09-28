import 'package:ai_packaging_recommender/models/cost_estimation_model.dart';

/// Offline calculation engine for packaging cost and material requirement estimation.
/// Provides zero-latency reactive feedback in the UI with exact numerical parity to the backend.
class OfflineCostEngine {
  static const double defaultSeamMarginM = 0.010;
  static const double doypackBottomInsertFactor = 1.15;
  static const double trayDrawFlangeFactor = 1.12;
  static const double cartonFlapMultiplier = 1.22;

  static const Map<String, double> polymerDensitiesKgM3 = {
    'ldpe': 920.0,
    'hdpe': 955.0,
    'bopp': 905.0,
    'pp': 905.0,
    'pet': 1380.0,
    'bio-pla': 1250.0,
    'pla': 1250.0,
    'natureflex': 1450.0,
    'cellulose': 1450.0,
    'al-foil': 2700.0,
    'aluminum': 2700.0,
    'evoh': 1170.0,
    'kraft paper': 750.0,
    'paperboard': 750.0,
  };
  static const double defaultPolymerDensityKgM3 = 1000.0;

  static const Map<String, double> defaultPricesInrPerKg = {
    'ldpe': 140.0,
    'hdpe': 150.0,
    'bopp': 175.0,
    'pp': 170.0,
    'pet': 165.0,
    'bio-pla': 320.0,
    'pla': 320.0,
    'natureflex': 420.0,
    'cellulose': 420.0,
    'al-foil': 450.0,
    'aluminum': 450.0,
    'evoh': 520.0,
    'kraft paper': 95.0,
    'paperboard': 90.0,
  };
  static const double defaultPriceInrPerKg = 180.0;

  static const double printingFeePerSqmInr = 0.75;
  static const double laminationFeePerSqmInr = 0.45;
  static const double pouchMakingFeePerUnitInr = 0.35;
  static const double toolingSetupBaseInr = 12000.0;
  static const double defaultThicknessMicrons = 40.0;

  /// Calculates geometric surface area in m²
  static double calculateSurfaceArea(PackagingFormFactor formFactor, PackageDimensions dimensions) {
    final lM = dimensions.lengthCm / 100.0;
    final wM = dimensions.widthCm / 100.0;
    final gM = dimensions.depthOrGussetCm / 100.0;
    const sM = defaultSeamMarginM;

    switch (formFactor) {
      case PackagingFormFactor.pillowPouch:
        return 2.0 * (lM + 2.0 * sM) * (wM + sM);

      case PackagingFormFactor.standUpDoypack:
        final gusset = gM > 0 ? gM : (wM * 0.35);
        final mainPanels = 2.0 * (lM + sM) * (wM + sM);
        final bottomGusset = (wM + sM) * (gusset + sM) * doypackBottomInsertFactor;
        return mainPanels + bottomGusset;

      case PackagingFormFactor.threeSideSeal:
        return 2.0 * (lM + sM) * (wM + 2.0 * sM);

      case PackagingFormFactor.fourSideQuadSeal:
        final gusset = gM > 0 ? gM : (wM * 0.40);
        return 2.0 * (lM + 2.0 * sM) * (wM + 2.0 * gusset + 2.0 * sM);

      case PackagingFormFactor.thermoformedTray:
        final hM = gM > 0 ? gM : 0.04;
        final rawBox = (lM * wM) + 2.0 * (lM * hM) + 2.0 * (wM * hM);
        return rawBox * trayDrawFlangeFactor;

      case PackagingFormFactor.vacuumRetortPouch:
        return 2.0 * (lM + 2.0 * sM) * (wM + 2.0 * sM);

      case PackagingFormFactor.foldingCarton:
        final hM = gM > 0 ? gM : 0.05;
        final sixFaces = 2.0 * ((lM * wM) + (lM * hM) + (wM * hM));
        return sixFaces * cartonFlapMultiplier;
    }
  }

  static double getPolymerDensity(String materialName) {
    final key = materialName.trim().toLowerCase();
    for (final entry in polymerDensitiesKgM3.entries) {
      if (key.contains(entry.key)) {
        return entry.value;
      }
    }
    return defaultPolymerDensityKgM3;
  }

  static double getBasePricePerKg(String materialName, [double? customPrice]) {
    if (customPrice != null && customPrice > 0) return customPrice;
    final key = materialName.trim().toLowerCase();
    for (final entry in defaultPricesInrPerKg.entries) {
      if (key.contains(entry.key)) {
        return entry.value;
      }
    }
    return defaultPriceInrPerKg;
  }

  static (double, String) getVolumeDiscountTier(int volume) {
    if (volume >= 100000) {
      return (24.0, 'Tier 4: Enterprise Scale');
    } else if (volume >= 25000) {
      return (16.0, 'Tier 3: Medium Commercial');
    } else if (volume >= 5000) {
      return (8.0, 'Tier 2: Small Commercial');
    } else {
      return (0.0, 'Tier 1: Pilot / Prototype');
    }
  }

  /// Calculates complete estimation response locally
  static CostEstimationResponse calculateCostEstimate(CostEstimationRequest request) {
    final unitAreaSqm = calculateSurfaceArea(request.packagingType, request.dimensions);
    final thicknessMicrons = request.dimensions.thicknessMicrons ?? defaultThicknessMicrons;
    final thicknessM = thicknessMicrons * 1e-6;
    final density = getPolymerDensity(request.materialName);

    final unitWeightKg = unitAreaSqm * thicknessM * density;
    final unitWeightG = unitWeightKg * 1000.0;

    final scrapFactor = request.customScrapRatePercent / 100.0;
    final netAreaSqm = unitAreaSqm * request.numberOfPackages;
    final grossAreaSqm = netAreaSqm * (1.0 + scrapFactor);

    final netWeightKg = unitWeightKg * request.numberOfPackages;
    final grossWeightKg = netWeightKg * (1.0 + scrapFactor);
    final scrapWeightKg = grossWeightKg - netWeightKg;

    final matReq = MaterialRequirementDetail(
      surfaceAreaPerUnitSqm: double.parse(unitAreaSqm.toStringAsFixed(6)),
      weightPerUnitGrams: double.parse(unitWeightG.toStringAsFixed(4)),
      grossAreaRequiredSqm: double.parse(grossAreaSqm.toStringAsFixed(2)),
      grossWeightRequiredKg: double.parse(grossWeightKg.toStringAsFixed(4)),
      scrapAllowancePercent: request.customScrapRatePercent,
      scrapMaterialWeightKg: double.parse(scrapWeightKg.toStringAsFixed(4)),
    );

    final basePriceKg = getBasePricePerKg(request.materialName, request.customMaterialCostPerKg);
    final totalSubstrateCost = grossWeightKg * basePriceKg;
    final unitSubstrateCost = totalSubstrateCost / request.numberOfPackages;

    const convertingRate = printingFeePerSqmInr + laminationFeePerSqmInr;
    final unitConvertingCost = (unitAreaSqm * convertingRate) + pouchMakingFeePerUnitInr;
    final totalConvertingCost = unitConvertingCost * request.numberOfPackages;

    double unitAddonsCost = 0.0;
    final addonsItems = <CostLayerItem>[];
    for (final addon in request.selectedAddons) {
      unitAddonsCost += addon.defaultUnitPriceInr;
      addonsItems.add(
        CostLayerItem(
          category: 'Add-on',
          itemName: '${addon.label} Treatment',
          costPerUnitInr: addon.defaultUnitPriceInr,
          totalCostInr: addon.defaultUnitPriceInr * request.numberOfPackages,
          percentageOfTotal: 0.0,
        ),
      );
    }
    final totalAddonsCost = unitAddonsCost * request.numberOfPackages;

    final totalToolingCost = request.includeToolingAmortization ? toolingSetupBaseInr : 0.0;
    final unitToolingCost = totalToolingCost / request.numberOfPackages;

    final preDiscountUnitCost = unitSubstrateCost + unitConvertingCost + unitAddonsCost + unitToolingCost;
    final preDiscountTotalCost = totalSubstrateCost + totalConvertingCost + totalAddonsCost + totalToolingCost;

    final (discountPct, _) = getVolumeDiscountTier(request.numberOfPackages);
    final discountAmountTotal = preDiscountTotalCost * (discountPct / 100.0);
    final finalTotalCost = preDiscountTotalCost - discountAmountTotal;
    final finalUnitCost = finalTotalCost / request.numberOfPackages;

    final costBreakdown = <CostLayerItem>[
      CostLayerItem(
        category: 'Substrate',
        itemName: '${request.materialName} Raw Substrate',
        costPerUnitInr: double.parse(unitSubstrateCost.toStringAsFixed(4)),
        totalCostInr: double.parse(totalSubstrateCost.toStringAsFixed(2)),
        percentageOfTotal: preDiscountTotalCost > 0
            ? double.parse(((totalSubstrateCost / preDiscountTotalCost) * 100.0).toStringAsFixed(2))
            : 0.0,
      ),
      CostLayerItem(
        category: 'Converting',
        itemName: 'Printing, Lamination & Pouch Forming',
        costPerUnitInr: double.parse(unitConvertingCost.toStringAsFixed(4)),
        totalCostInr: double.parse(totalConvertingCost.toStringAsFixed(2)),
        percentageOfTotal: preDiscountTotalCost > 0
            ? double.parse(((totalConvertingCost / preDiscountTotalCost) * 100.0).toStringAsFixed(2))
            : 0.0,
      ),
    ];

    for (final item in addonsItems) {
      costBreakdown.add(
        CostLayerItem(
          category: item.category,
          itemName: item.itemName,
          costPerUnitInr: item.costPerUnitInr,
          totalCostInr: item.totalCostInr,
          percentageOfTotal: preDiscountTotalCost > 0
              ? double.parse(((item.totalCostInr / preDiscountTotalCost) * 100.0).toStringAsFixed(2))
              : 0.0,
        ),
      );
    }

    if (totalToolingCost > 0) {
      costBreakdown.add(
        CostLayerItem(
          category: 'Tooling',
          itemName: 'Cylinder & Die Setup Amortization',
          costPerUnitInr: double.parse(unitToolingCost.toStringAsFixed(4)),
          totalCostInr: double.parse(totalToolingCost.toStringAsFixed(2)),
          percentageOfTotal: preDiscountTotalCost > 0
              ? double.parse(((totalToolingCost / preDiscountTotalCost) * 100.0).toStringAsFixed(2))
              : 0.0,
        ),
      );
    }

    final sensitivityVolumes = [1000, 5000, 10000, 25000, 100000];
    final volumeSensitivity = <VolumeTierSensitivityPoint>[];
    for (final vol in sensitivityVolumes) {
      final (tierDiscountPct, tierLabel) = getVolumeDiscountTier(vol);
      final vToolingUnit = request.includeToolingAmortization ? (toolingSetupBaseInr / vol) : 0.0;
      final vPreUnit = unitSubstrateCost + unitConvertingCost + unitAddonsCost + vToolingUnit;
      final vUnit = vPreUnit * (1.0 - (tierDiscountPct / 100.0));
      final vTotal = vUnit * vol;
      volumeSensitivity.add(
        VolumeTierSensitivityPoint(
          tierLabel: '${vol ~/ 1000}k Units (${tierLabel.split(':')[0].trim()})',
          orderVolume: vol,
          costPerUnitInr: double.parse(vUnit.toStringAsFixed(2)),
          totalCostInr: double.parse(vTotal.toStringAsFixed(2)),
          discountPercent: tierDiscountPct,
        ),
      );
    }

    return CostEstimationResponse(
      materialId: request.materialId,
      materialName: request.materialName,
      packagingType: request.packagingType,
      numberOfPackages: request.numberOfPackages,
      productFillQuantity: request.productFillQuantity,
      materialRequirement: matReq,
      costPerUnitInr: double.parse(finalUnitCost.toStringAsFixed(2)),
      totalEstimatedCostInr: double.parse(finalTotalCost.toStringAsFixed(2)),
      costBreakdown: costBreakdown,
      substrateCostSubtotalInr: double.parse(totalSubstrateCost.toStringAsFixed(2)),
      convertingCostSubtotalInr: double.parse(totalConvertingCost.toStringAsFixed(2)),
      addonsCostSubtotalInr: double.parse(totalAddonsCost.toStringAsFixed(2)),
      toolingCostSubtotalInr: double.parse(totalToolingCost.toStringAsFixed(2)),
      volumeDiscountAmountInr: double.parse(discountAmountTotal.toStringAsFixed(2)),
      volumeDiscountPercent: discountPct,
      volumeTierSensitivity: volumeSensitivity,
      pricingMode: 'Estimated Baseline Model',
      isEstimated: true,
      disclaimerNotice:
          'ESTIMATED BASELINE: Values are computed using standard industry conversion ratios, empirical polymer densities, and standard finishing margins. Actual commercial prices may vary based on live polymer index fluctuations and converter tooling specifications.',
    );
  }
}
