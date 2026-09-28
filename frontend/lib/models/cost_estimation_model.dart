import 'package:flutter/material.dart';

/// Packaging Form Factors supported by the Cost Estimation Engine.
enum PackagingFormFactor {
  pillowPouch('Pillow Pouch', 'Form-Fill-Seal 2-side fin seal', Icons.crop_portrait),
  standUpDoypack('Stand-up Doypack', 'Self-standing pouch with bottom gusset', Icons.view_sidebar),
  threeSideSeal('3-Side Seal Pouch', 'Flat pouch with perimeter 3-edge seal', Icons.filter_none),
  fourSideQuadSeal('4-Side Quad Seal', 'Side-gusset block bottom pouch', Icons.view_agenda),
  thermoformedTray('Thermoformed Tray / Clamshell', 'Rigid polymer tray with depth draw', Icons.inbox),
  vacuumRetortPouch('Vacuum / Retort Pouch', 'Hermetic heavy barrier vacuum bag', Icons.layers),
  foldingCarton('Folding Carton Box', 'Paperboard secondary outer carton', Icons.inventory_2);

  final String label;
  final String description;
  final IconData icon;

  const PackagingFormFactor(this.label, this.description, this.icon);

  static PackagingFormFactor fromString(String value) {
    return PackagingFormFactor.values.firstWhere(
      (f) => f.label.toLowerCase() == value.toLowerCase() || f.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PackagingFormFactor.standUpDoypack,
    );
  }
}

/// Functional add-ons with standard unit cost in INR.
enum FunctionalAddOn {
  resealableZipper('Resealable Zipper', 'Press-to-close reseal track', 0.40, Icons.lock_open),
  degassingValve('One-Way Degassing Valve', 'CO2 pressure release valve', 0.85, Icons.air),
  tearNotch('Laser Tear Notch', 'Easy-open clean tear scoring', 0.08, Icons.content_cut),
  antiFogCoating('Anti-Fog Coating', 'Condensation prevention surfactant', 0.20, Icons.water_drop),
  microPerforations('Laser Micro-Perforations', 'Respiration permeability control', 0.18, Icons.grain),
  mapGasFlush('MAP Gas Flush Seal', 'Modified atmosphere hermetic seal', 0.15, Icons.bubble_chart);

  final String label;
  final String description;
  final double defaultUnitPriceInr;
  final IconData icon;

  const FunctionalAddOn(this.label, this.description, this.defaultUnitPriceInr, this.icon);

  static FunctionalAddOn fromString(String value) {
    return FunctionalAddOn.values.firstWhere(
      (a) => a.label.toLowerCase() == value.toLowerCase() || a.name.toLowerCase() == value.toLowerCase(),
      orElse: () => FunctionalAddOn.resealableZipper,
    );
  }
}

/// Physical dimensions of the package.
class PackageDimensions {
  final double lengthCm;
  final double widthCm;
  final double depthOrGussetCm;
  final double? thicknessMicrons;

  const PackageDimensions({
    required this.lengthCm,
    required this.widthCm,
    this.depthOrGussetCm = 0.0,
    this.thicknessMicrons,
  });

  Map<String, dynamic> toJson() => {
    'length_cm': lengthCm,
    'width_cm': widthCm,
    'depth_or_gusset_cm': depthOrGussetCm,
    if (thicknessMicrons != null) 'thickness_microns': thicknessMicrons,
  };

  factory PackageDimensions.fromJson(Map<String, dynamic> json) {
    return PackageDimensions(
      lengthCm: (json['length_cm'] as num?)?.toDouble() ?? 20.0,
      widthCm: (json['width_cm'] as num?)?.toDouble() ?? 14.0,
      depthOrGussetCm: (json['depth_or_gusset_cm'] as num?)?.toDouble() ?? 0.0,
      thicknessMicrons: (json['thickness_microns'] as num?)?.toDouble(),
    );
  }
}

/// Material footprint and mass requirements.
class MaterialRequirementDetail {
  final double surfaceAreaPerUnitSqm;
  final double weightPerUnitGrams;
  final double grossAreaRequiredSqm;
  final double grossWeightRequiredKg;
  final double scrapAllowancePercent;
  final double scrapMaterialWeightKg;

  const MaterialRequirementDetail({
    required this.surfaceAreaPerUnitSqm,
    required this.weightPerUnitGrams,
    required this.grossAreaRequiredSqm,
    required this.grossWeightRequiredKg,
    required this.scrapAllowancePercent,
    required this.scrapMaterialWeightKg,
  });

  Map<String, dynamic> toJson() => {
    'surface_area_per_unit_sqm': surfaceAreaPerUnitSqm,
    'weight_per_unit_grams': weightPerUnitGrams,
    'gross_area_required_sqm': grossAreaRequiredSqm,
    'gross_weight_required_kg': grossWeightRequiredKg,
    'scrap_allowance_percent': scrapAllowancePercent,
    'scrap_material_weight_kg': scrapMaterialWeightKg,
  };

  factory MaterialRequirementDetail.fromJson(Map<String, dynamic> json) {
    return MaterialRequirementDetail(
      surfaceAreaPerUnitSqm: (json['surface_area_per_unit_sqm'] as num?)?.toDouble() ?? 0.0,
      weightPerUnitGrams: (json['weight_per_unit_grams'] as num?)?.toDouble() ?? 0.0,
      grossAreaRequiredSqm: (json['gross_area_required_sqm'] as num?)?.toDouble() ?? 0.0,
      grossWeightRequiredKg: (json['gross_weight_required_kg'] as num?)?.toDouble() ?? 0.0,
      scrapAllowancePercent: (json['scrap_allowance_percent'] as num?)?.toDouble() ?? 6.0,
      scrapMaterialWeightKg: (json['scrap_material_weight_kg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Itemized cost breakdown contribution.
class CostLayerItem {
  final String category; // 'Substrate', 'Converting', 'Add-on', 'Tooling'
  final String itemName;
  final double costPerUnitInr;
  final double totalCostInr;
  final double percentageOfTotal;

  const CostLayerItem({
    required this.category,
    required this.itemName,
    required this.costPerUnitInr,
    required this.totalCostInr,
    required this.percentageOfTotal,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'item_name': itemName,
    'cost_per_unit_inr': costPerUnitInr,
    'total_cost_inr': totalCostInr,
    'percentage_of_total': percentageOfTotal,
  };

  factory CostLayerItem.fromJson(Map<String, dynamic> json) {
    return CostLayerItem(
      category: json['category'] as String? ?? 'General',
      itemName: json['item_name'] as String? ?? '',
      costPerUnitInr: (json['cost_per_unit_inr'] as num?)?.toDouble() ?? 0.0,
      totalCostInr: (json['total_cost_inr'] as num?)?.toDouble() ?? 0.0,
      percentageOfTotal: (json['percentage_of_total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Volume tier scaling milestone point.
class VolumeTierSensitivityPoint {
  final String tierLabel;
  final int orderVolume;
  final double costPerUnitInr;
  final double totalCostInr;
  final double discountPercent;

  const VolumeTierSensitivityPoint({
    required this.tierLabel,
    required this.orderVolume,
    required this.costPerUnitInr,
    required this.totalCostInr,
    required this.discountPercent,
  });

  Map<String, dynamic> toJson() => {
    'tier_label': tierLabel,
    'order_volume': orderVolume,
    'cost_per_unit_inr': costPerUnitInr,
    'total_cost_inr': totalCostInr,
    'discount_percent': discountPercent,
  };

  factory VolumeTierSensitivityPoint.fromJson(Map<String, dynamic> json) {
    return VolumeTierSensitivityPoint(
      tierLabel: json['tier_label'] as String? ?? '',
      orderVolume: (json['order_volume'] as num?)?.toInt() ?? 1000,
      costPerUnitInr: (json['cost_per_unit_inr'] as num?)?.toDouble() ?? 0.0,
      totalCostInr: (json['total_cost_inr'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Input request payload for Cost Estimation.
class CostEstimationRequest {
  final String? materialId;
  final String materialName;
  final PackagingFormFactor packagingType;
  final PackageDimensions dimensions;
  final String productFillQuantity;
  final int numberOfPackages;
  final List<FunctionalAddOn> selectedAddons;
  final double? customMaterialCostPerKg;
  final double customScrapRatePercent;
  final bool includeToolingAmortization;

  const CostEstimationRequest({
    this.materialId,
    required this.materialName,
    required this.packagingType,
    required this.dimensions,
    this.productFillQuantity = '500g',
    required this.numberOfPackages,
    this.selectedAddons = const [],
    this.customMaterialCostPerKg,
    this.customScrapRatePercent = 6.0,
    this.includeToolingAmortization = true,
  });

  Map<String, dynamic> toJson() => {
    if (materialId != null) 'material_id': materialId,
    'material_name': materialName,
    'packaging_type': packagingType.label,
    'dimensions': dimensions.toJson(),
    'product_fill_quantity': productFillQuantity,
    'number_of_packages': numberOfPackages,
    'selected_addons': selectedAddons.map((a) => a.label).toList(),
    if (customMaterialCostPerKg != null) 'custom_material_cost_per_kg': customMaterialCostPerKg,
    'custom_scrap_rate_percent': customScrapRatePercent,
    'include_tooling_amortization': includeToolingAmortization,
  };

  factory CostEstimationRequest.fromJson(Map<String, dynamic> json) {
    final addonsRaw = json['selected_addons'] as List<dynamic>? ?? [];
    return CostEstimationRequest(
      materialId: json['material_id'] as String?,
      materialName: json['material_name'] as String? ?? 'LDPE Polyethylene',
      packagingType: PackagingFormFactor.fromString(json['packaging_type'] as String? ?? 'Stand-up Doypack'),
      dimensions: PackageDimensions.fromJson(json['dimensions'] as Map<String, dynamic>? ?? {}),
      productFillQuantity: json['product_fill_quantity'] as String? ?? '500g',
      numberOfPackages: (json['number_of_packages'] as num?)?.toInt() ?? 10000,
      selectedAddons: addonsRaw.map((a) => FunctionalAddOn.fromString(a.toString())).toList(),
      customMaterialCostPerKg: (json['custom_material_cost_per_kg'] as num?)?.toDouble(),
      customScrapRatePercent: (json['custom_scrap_rate_percent'] as num?)?.toDouble() ?? 6.0,
      includeToolingAmortization: json['include_tooling_amortization'] as bool? ?? true,
    );
  }
}

/// Output response payload from Cost Estimation.
class CostEstimationResponse {
  final String? materialId;
  final String materialName;
  final PackagingFormFactor packagingType;
  final int numberOfPackages;
  final String productFillQuantity;
  final MaterialRequirementDetail materialRequirement;
  final double costPerUnitInr;
  final double totalEstimatedCostInr;
  final List<CostLayerItem> costBreakdown;
  final double substrateCostSubtotalInr;
  final double convertingCostSubtotalInr;
  final double addonsCostSubtotalInr;
  final double toolingCostSubtotalInr;
  final double volumeDiscountAmountInr;
  final double volumeDiscountPercent;
  final List<VolumeTierSensitivityPoint> volumeTierSensitivity;
  final String pricingMode;
  final bool isEstimated;
  final String disclaimerNotice;
  final String? supplierQuoteReferenceId;
  final String currencyCode;

  const CostEstimationResponse({
    this.materialId,
    required this.materialName,
    required this.packagingType,
    required this.numberOfPackages,
    required this.productFillQuantity,
    required this.materialRequirement,
    required this.costPerUnitInr,
    required this.totalEstimatedCostInr,
    required this.costBreakdown,
    required this.substrateCostSubtotalInr,
    required this.convertingCostSubtotalInr,
    required this.addonsCostSubtotalInr,
    required this.toolingCostSubtotalInr,
    required this.volumeDiscountAmountInr,
    required this.volumeDiscountPercent,
    required this.volumeTierSensitivity,
    this.pricingMode = 'Estimated Baseline Model',
    this.isEstimated = true,
    this.disclaimerNotice =
        'ESTIMATED BASELINE: Values are computed using standard industry conversion ratios, empirical polymer densities, and standard finishing margins. Actual commercial prices may vary based on live polymer index fluctuations and converter tooling specifications.',
    this.supplierQuoteReferenceId,
    this.currencyCode = 'INR',
  });

  Map<String, dynamic> toJson() => {
    if (materialId != null) 'material_id': materialId,
    'material_name': materialName,
    'packaging_type': packagingType.label,
    'number_of_packages': numberOfPackages,
    'product_fill_quantity': productFillQuantity,
    'material_requirement': materialRequirement.toJson(),
    'cost_per_unit_inr': costPerUnitInr,
    'total_estimated_cost_inr': totalEstimatedCostInr,
    'cost_breakdown': costBreakdown.map((c) => c.toJson()).toList(),
    'substrate_cost_subtotal_inr': substrateCostSubtotalInr,
    'converting_cost_subtotal_inr': convertingCostSubtotalInr,
    'addons_cost_subtotal_inr': addonsCostSubtotalInr,
    'tooling_cost_subtotal_inr': toolingCostSubtotalInr,
    'volume_discount_amount_inr': volumeDiscountAmountInr,
    'volume_discount_percent': volumeDiscountPercent,
    'volume_tier_sensitivity': volumeTierSensitivity.map((v) => v.toJson()).toList(),
    'pricing_mode': pricingMode,
    'is_estimated': isEstimated,
    'disclaimer_notice': disclaimerNotice,
    if (supplierQuoteReferenceId != null) 'supplier_quote_reference_id': supplierQuoteReferenceId,
    'currency_code': currencyCode,
  };

  factory CostEstimationResponse.fromJson(Map<String, dynamic> json) {
    final breakdownRaw = json['cost_breakdown'] as List<dynamic>? ?? [];
    final sensitivityRaw = json['volume_tier_sensitivity'] as List<dynamic>? ?? [];

    return CostEstimationResponse(
      materialId: json['material_id'] as String?,
      materialName: json['material_name'] as String? ?? 'LDPE Polyethylene',
      packagingType: PackagingFormFactor.fromString(json['packaging_type'] as String? ?? 'Stand-up Doypack'),
      numberOfPackages: (json['number_of_packages'] as num?)?.toInt() ?? 10000,
      productFillQuantity: json['product_fill_quantity'] as String? ?? '500g',
      materialRequirement: MaterialRequirementDetail.fromJson(
        json['material_requirement'] as Map<String, dynamic>? ?? {},
      ),
      costPerUnitInr: (json['cost_per_unit_inr'] as num?)?.toDouble() ?? 0.0,
      totalEstimatedCostInr: (json['total_estimated_cost_inr'] as num?)?.toDouble() ?? 0.0,
      costBreakdown: breakdownRaw.map((c) => CostLayerItem.fromJson(c as Map<String, dynamic>)).toList(),
      substrateCostSubtotalInr: (json['substrate_cost_subtotal_inr'] as num?)?.toDouble() ?? 0.0,
      convertingCostSubtotalInr: (json['converting_cost_subtotal_inr'] as num?)?.toDouble() ?? 0.0,
      addonsCostSubtotalInr: (json['addons_cost_subtotal_inr'] as num?)?.toDouble() ?? 0.0,
      toolingCostSubtotalInr: (json['tooling_cost_subtotal_inr'] as num?)?.toDouble() ?? 0.0,
      volumeDiscountAmountInr: (json['volume_discount_amount_inr'] as num?)?.toDouble() ?? 0.0,
      volumeDiscountPercent: (json['volume_discount_percent'] as num?)?.toDouble() ?? 0.0,
      volumeTierSensitivity: sensitivityRaw
          .map((v) => VolumeTierSensitivityPoint.fromJson(v as Map<String, dynamic>))
          .toList(),
      pricingMode: json['pricing_mode'] as String? ?? 'Estimated Baseline Model',
      isEstimated: json['is_estimated'] as bool? ?? true,
      disclaimerNotice: json['disclaimer_notice'] as String? ??
          'ESTIMATED BASELINE: Values are computed using standard industry conversion ratios, empirical polymer densities, and standard finishing margins.',
      supplierQuoteReferenceId: json['supplier_quote_reference_id'] as String?,
      currencyCode: json['currency_code'] as String? ?? 'INR',
    );
  }
}
