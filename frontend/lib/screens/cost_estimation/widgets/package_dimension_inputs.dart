import 'package:flutter/material.dart';
import '../../../models/cost_estimation_model.dart';

/// Dimension inputs for Length, Width, Depth/Gusset, and Gauge Thickness with capacity presets.
class PackageDimensionInputs extends StatelessWidget {
  final PackageDimensions dimensions;
  final String productFillQuantity;
  final PackagingFormFactor packagingType;
  final ValueChanged<PackageDimensions> onDimensionsChanged;
  final ValueChanged<String> onFillQuantityChanged;

  const PackageDimensionInputs({
    super.key,
    required this.dimensions,
    required this.productFillQuantity,
    required this.packagingType,
    required this.onDimensionsChanged,
    required this.onFillQuantityChanged,
  });

  static const List<String> standardCapacities = [
    '50g',
    '100g',
    '250g',
    '500g',
    '1kg',
    '5kg',
  ];

  void _applyCapacityPreset(String capacity) {
    onFillQuantityChanged(capacity);
    // Apply sensible standard dimensions based on capacity
    switch (capacity) {
      case '50g':
        onDimensionsChanged(PackageDimensions(
          lengthCm: 12.0,
          widthCm: 8.0,
          depthOrGussetCm: 3.0,
          thicknessMicrons: dimensions.thicknessMicrons ?? 35.0,
        ));
        break;
      case '100g':
        onDimensionsChanged(PackageDimensions(
          lengthCm: 15.0,
          widthCm: 10.0,
          depthOrGussetCm: 4.0,
          thicknessMicrons: dimensions.thicknessMicrons ?? 40.0,
        ));
        break;
      case '250g':
        onDimensionsChanged(PackageDimensions(
          lengthCm: 18.0,
          widthCm: 12.0,
          depthOrGussetCm: 5.0,
          thicknessMicrons: dimensions.thicknessMicrons ?? 40.0,
        ));
        break;
      case '500g':
        onDimensionsChanged(PackageDimensions(
          lengthCm: 20.0,
          widthCm: 14.0,
          depthOrGussetCm: 6.0,
          thicknessMicrons: dimensions.thicknessMicrons ?? 45.0,
        ));
        break;
      case '1kg':
        onDimensionsChanged(PackageDimensions(
          lengthCm: 26.0,
          widthCm: 18.0,
          depthOrGussetCm: 8.0,
          thicknessMicrons: dimensions.thicknessMicrons ?? 55.0,
        ));
        break;
      case '5kg':
        onDimensionsChanged(PackageDimensions(
          lengthCm: 45.0,
          widthCm: 32.0,
          depthOrGussetCm: 12.0,
          thicknessMicrons: dimensions.thicknessMicrons ?? 80.0,
        ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF0D9488);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.straighten, size: 18, color: Color(0xFF0D9488)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '2. Dimensions & Fill',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Quick preset chips
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: standardCapacities.map((cap) {
            final isSelected = productFillQuantity == cap;
            return InkWell(
              onTap: () => _applyCapacityPreset(cap),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.2)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Text(
                  cap,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // 4 Input fields with responsive layout
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 450;

            final lengthInput = _buildNumberInput(
              context,
              label: 'Length',
              unit: 'cm',
              value: dimensions.lengthCm,
              onChanged: (val) {
                onDimensionsChanged(PackageDimensions(
                  lengthCm: val > 0 ? val : 1.0,
                  widthCm: dimensions.widthCm,
                  depthOrGussetCm: dimensions.depthOrGussetCm,
                  thicknessMicrons: dimensions.thicknessMicrons,
                ));
              },
            );

            final widthInput = _buildNumberInput(
              context,
              label: 'Width',
              unit: 'cm',
              value: dimensions.widthCm,
              onChanged: (val) {
                onDimensionsChanged(PackageDimensions(
                  lengthCm: dimensions.lengthCm,
                  widthCm: val > 0 ? val : 1.0,
                  depthOrGussetCm: dimensions.depthOrGussetCm,
                  thicknessMicrons: dimensions.thicknessMicrons,
                ));
              },
            );

            final depthLabel = packagingType == PackagingFormFactor.thermoformedTray
                ? 'Depth'
                : (packagingType == PackagingFormFactor.foldingCarton ? 'Height' : 'Gusset');

            final depthInput = _buildNumberInput(
              context,
              label: depthLabel,
              unit: 'cm',
              value: dimensions.depthOrGussetCm,
              onChanged: (val) {
                onDimensionsChanged(PackageDimensions(
                  lengthCm: dimensions.lengthCm,
                  widthCm: dimensions.widthCm,
                  depthOrGussetCm: val >= 0 ? val : 0.0,
                  thicknessMicrons: dimensions.thicknessMicrons,
                ));
              },
            );

            final gaugeInput = _buildNumberInput(
              context,
              label: 'Gauge',
              unit: 'µm',
              value: dimensions.thicknessMicrons ?? 40.0,
              onChanged: (val) {
                onDimensionsChanged(PackageDimensions(
                  lengthCm: dimensions.lengthCm,
                  widthCm: dimensions.widthCm,
                  depthOrGussetCm: dimensions.depthOrGussetCm,
                  thicknessMicrons: val > 0 ? val : 10.0,
                ));
              },
            );

            if (isNarrow) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: lengthInput),
                      const SizedBox(width: 8),
                      Expanded(child: widthInput),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: depthInput),
                      const SizedBox(width: 8),
                      Expanded(child: gaugeInput),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: lengthInput),
                const SizedBox(width: 8),
                Expanded(child: widthInput),
                const SizedBox(width: 8),
                Expanded(child: depthInput),
                const SizedBox(width: 8),
                Expanded(child: gaugeInput),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNumberInput(
    BuildContext context, {
    required String label,
    required String unit,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D9488),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              InkWell(
                onTap: () => onChanged(value > 1.0 ? value - 1.0 : value),
                child: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.grey),
              ),
              Expanded(
                child: Text(
                  value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              InkWell(
                onTap: () => onChanged(value + 1.0),
                child: const Icon(Icons.add_circle_outline, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
