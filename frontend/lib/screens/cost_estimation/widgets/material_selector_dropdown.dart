import 'package:flutter/material.dart';

/// Searchable/selectable Material substrate dropdown with density and base price per kg.
class MaterialSelectorDropdown extends StatelessWidget {
  final String selectedMaterial;
  final double? customPricePerKg;
  final ValueChanged<String> onMaterialChanged;
  final ValueChanged<double?> onCustomPriceChanged;

  const MaterialSelectorDropdown({
    super.key,
    required this.selectedMaterial,
    this.customPricePerKg,
    required this.onMaterialChanged,
    required this.onCustomPriceChanged,
  });

  static const List<Map<String, dynamic>> materialsCatalog = [
    {'name': 'NatureFlex Regenerated Cellulose', 'family': 'Bio-Cellulose', 'density': 1.45, 'price': 420.0},
    {'name': 'Bio-PLA Compostable Film', 'family': 'Bio-Polymer', 'density': 1.25, 'price': 320.0},
    {'name': 'LDPE Polyethylene Film', 'family': 'Polyolefin', 'density': 0.92, 'price': 140.0},
    {'name': 'HDPE High-Density Polyethylene', 'family': 'Polyolefin', 'density': 0.955, 'price': 150.0},
    {'name': 'BOPP Biaxially Oriented PP', 'family': 'Polypropylene', 'density': 0.905, 'price': 175.0},
    {'name': 'PET Polyester Film', 'family': 'Polyester', 'density': 1.38, 'price': 165.0},
    {'name': 'Aluminum Foil Barrier Laminate', 'family': 'Foil Composite', 'density': 2.70, 'price': 450.0},
    {'name': 'EVOH High-Barrier Co-extrusion', 'family': 'Barrier Polymer', 'density': 1.17, 'price': 520.0},
    {'name': 'Kraft Paper Eco-Barrier Sack', 'family': 'Paperboard', 'density': 0.75, 'price': 95.0},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMat = materialsCatalog.firstWhere(
      (m) => (m['name'] as String).toLowerCase().contains(selectedMaterial.toLowerCase()),
      orElse: () => materialsCatalog[0],
    );

    final density = (currentMat['density'] as num).toDouble();
    final basePrice = (currentMat['price'] as num).toDouble();
    final effectivePrice = customPricePerKg ?? basePrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.layers_outlined, size: 18, color: Color(0xFF0D9488)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '3. Material Substrate',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'ρ=${density.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D9488),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: materialsCatalog.any((m) => m['name'] == selectedMaterial)
                  ? selectedMaterial
                  : (currentMat['name'] as String),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D9488)),
              items: materialsCatalog.map((mat) {
                final name = mat['name'] as String;
                final family = mat['family'] as String;
                final price = (mat['price'] as num).toDouble();

                return DropdownMenuItem<String>(
                  value: name,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              family,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.grey[400] : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${price.toStringAsFixed(0)}/kg',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  onMaterialChanged(val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
