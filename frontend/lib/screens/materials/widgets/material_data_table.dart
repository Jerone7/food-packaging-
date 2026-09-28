import 'package:flutter/material.dart';
import '../../../../models/material_catalog_model.dart';
import '../../../../theme/app_theme.dart';

/// Dense engineering data table for rapid cross-material metric comparisons.
class MaterialDataTable extends StatelessWidget {
  final List<PackagingMaterialDetail> materials;
  final Set<String> selectedMaterialIds;
  final ValueChanged<PackagingMaterialDetail> onInspect;
  final Function(String materialId, bool isSelected) onToggleComparison;

  const MaterialDataTable({
    super.key,
    required this.materials,
    required this.selectedMaterialIds,
    required this.onInspect,
    required this.onToggleComparison,
  });

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.layers_clear_outlined, size: 48, color: AppTheme.slateBody.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'No matching packaging materials found.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1050),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppTheme.bgOffWhite),
              dataRowMinHeight: 52,
              dataRowMaxHeight: 60,
              columnSpacing: 20,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: Text('Compare', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Material & Structure', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Gauge', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), numeric: true),
                DataColumn(label: Text('OTR (cc)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), numeric: true),
                DataColumn(label: Text('WVTR (g)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), numeric: true),
                DataColumn(label: Text('Tensile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), numeric: true),
                DataColumn(label: Text('Puncture', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), numeric: true),
                DataColumn(label: Text('Thermal Span', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                DataColumn(label: Text('Eco-Score', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), numeric: true),
                DataColumn(label: Text('Cost', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), numeric: true),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              ],
              rows: materials.map((mat) {
                final isSelected = selectedMaterialIds.contains(mat.materialId);
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (_) => onToggleComparison(mat.materialId, !isSelected),
                  cells: [
                    // Checkbox
                    DataCell(
                      Checkbox(
                        value: isSelected,
                        activeColor: AppTheme.primaryTeal,
                        onChanged: (val) => onToggleComparison(mat.materialId, val ?? false),
                      ),
                    ),
                    // Name & Structure
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mat.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.slateDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            mat.structure,
                            style: TextStyle(fontSize: 11, color: AppTheme.slateBody.withValues(alpha: 0.8)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Category
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.bgOffWhite,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Text(
                          mat.category,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateBody),
                        ),
                      ),
                    ),
                    // Gauge (µm)
                    DataCell(Text('${mat.barrierProfile.thicknessMicrons.toStringAsFixed(0)} µm', style: const TextStyle(fontSize: 12))),
                    // OTR
                    DataCell(
                      Text(
                        mat.barrierProfile.otrCcM2Day < 0.1 ? '<0.1' : mat.barrierProfile.otrCcM2Day.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                      ),
                    ),
                    // WVTR
                    DataCell(
                      Text(
                        mat.barrierProfile.wvtrGM2Day < 0.1 ? '<0.1' : mat.barrierProfile.wvtrGM2Day.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0D9488)),
                      ),
                    ),
                    // Tensile (MPa)
                    DataCell(Text('${mat.mechanicalProfile.tensileStrengthMpa.toStringAsFixed(0)} MPa', style: const TextStyle(fontSize: 12))),
                    // Puncture (N)
                    DataCell(Text('${mat.mechanicalProfile.punctureResistanceN.toStringAsFixed(0)} N', style: const TextStyle(fontSize: 12))),
                    // Thermal Span
                    DataCell(
                      Text(
                        '${mat.thermalProfile.tempMinC.toStringAsFixed(0)}° to ${mat.thermalProfile.tempMaxC.toStringAsFixed(0)}°C',
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                    // Eco-Score
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${mat.environmentalProfile.sustainabilityScore.toStringAsFixed(0)}/100',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                        ),
                      ),
                    ),
                    // Cost (₹)
                    DataCell(
                      Text(
                        '₹${mat.economicProfile.estimatedUnitCostInr.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                      ),
                    ),
                    // Inspect Action
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppTheme.primaryTeal),
                        tooltip: 'Inspect Specifications',
                        onPressed: () => onInspect(mat),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
