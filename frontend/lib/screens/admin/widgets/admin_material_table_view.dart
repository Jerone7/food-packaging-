import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/gradient_button.dart';

/// Data Table and Management View for Packaging Substrates & Barrier Specifications
class AdminMaterialTableView extends StatefulWidget {
  final List<AdminMaterialItemModel> materials;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onAddMaterial;
  final ValueChanged<AdminMaterialItemModel> onEditMaterial;
  final ValueChanged<AdminMaterialItemModel> onToggleStatus;
  final ValueChanged<AdminMaterialItemModel> onDeleteMaterial;

  const AdminMaterialTableView({
    super.key,
    required this.materials,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onAddMaterial,
    required this.onEditMaterial,
    required this.onToggleStatus,
    required this.onDeleteMaterial,
  });

  @override
  State<AdminMaterialTableView> createState() => _AdminMaterialTableViewState();
}

class _AdminMaterialTableViewState extends State<AdminMaterialTableView> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Biodegradable Bio-Polymer',
    'Paper & Fiber Board',
    'Metallized Film',
    'Multi-Layer Co-Extrusion',
    'Recyclable Polyolefin',
    'Rigid Bio-Plastic',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Action Controls Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              // Search Input
              SizedBox(
                width: isMobile ? double.infinity : 240,
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearchChanged,
                  style: const TextStyle(fontSize: 13, color: AppTheme.slateDark),
                  decoration: InputDecoration(
                    hintText: 'Search substrate or ID...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.slateBody),
                    filled: true,
                    fillColor: AppTheme.bgOffWhite,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                  ),
                ),
              ),

              // Category Selector & Add Button
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgOffWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: const TextStyle(fontSize: 13, color: AppTheme.slateDark),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _selectedCategory = v);
                              widget.onCategoryChanged(v);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  GradientButton(
                    text: 'Add Material',
                    icon: Icons.add_rounded,
                    height: 42,
                    fontSize: 13,
                    onPressed: widget.onAddMaterial,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),

          // Packaging Materials List
          if (widget.materials.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.layers_clear_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text('No packaging materials found', style: TextStyle(fontSize: 14, color: AppTheme.slateBody)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.materials.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final material = widget.materials[index];
                return _buildMaterialRow(material);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(AdminMaterialItemModel mat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 720;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mat.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(mat.isActiveEntry),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${mat.materialId} • ${mat.polymerFamily}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                _buildMetricsRow(mat),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      '₹${mat.estimatedUnitCostInr.toStringAsFixed(2)} / unit',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                    ),
                    _buildActionButtons(mat),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              // Material Name & Polymer Family
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mat.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                    ),
                    Text(
                      '${mat.materialId} • ${mat.polymerFamily}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    if (mat.structure != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        mat.structure!,
                        style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),

              // Barrier & Eco Metrics
              Expanded(
                flex: 4,
                child: _buildMetricsRow(mat),
              ),

              // Pricing & Active Status
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${mat.estimatedUnitCostInr.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusChip(mat.isActiveEntry),
                  ],
                ),
              ),

              // Actions
              Expanded(
                flex: 2,
                child: _buildActionButtons(mat),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.emeraldLight : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Archived',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? AppTheme.emeraldEco : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildMetricsRow(AdminMaterialItemModel mat) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _metricBadge('${mat.thicknessMicrons.toStringAsFixed(0)} µm'),
        if (mat.otr != null) _metricBadge('OTR: ${mat.otr!.toStringAsFixed(1)}'),
        if (mat.wvtr != null) _metricBadge('WVTR: ${mat.wvtr!.toStringAsFixed(1)}'),
        _ecoBadge(mat.sustainabilityScore),
      ],
    );
  }

  Widget _metricBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.slateDark),
      ),
    );
  }

  Widget _ecoBadge(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.emeraldLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${score.toStringAsFixed(0)}% Eco',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.emeraldEco),
      ),
    );
  }

  Widget _buildActionButtons(AdminMaterialItemModel mat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Toggle Active / Inactive Switch Tooltip
        IconButton(
          onPressed: () => widget.onToggleStatus(mat),
          icon: Icon(
            mat.isActiveEntry ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
            size: 26,
            color: mat.isActiveEntry ? AppTheme.emeraldEco : Colors.grey.shade400,
          ),
          tooltip: mat.isActiveEntry ? 'Deactivate Substrate' : 'Activate Substrate',
          visualDensity: VisualDensity.compact,
        ),

        // Edit Material Button
        IconButton(
          onPressed: () => widget.onEditMaterial(mat),
          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.slateBody),
          tooltip: 'Edit Material',
          visualDensity: VisualDensity.compact,
        ),

        // Delete Material Button
        IconButton(
          onPressed: () => _confirmDelete(mat),
          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFE11D48)),
          tooltip: 'Delete Material',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  void _confirmDelete(AdminMaterialItemModel mat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Packaging Material?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Are you sure you want to delete "${mat.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDeleteMaterial(mat);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
