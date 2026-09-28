import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/gradient_button.dart';

/// Data Table and Management View for Food Commodities & 14 Scientific Traits
class AdminFoodTableView extends StatefulWidget {
  final List<AdminFoodItemModel> foods;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onAddFood;
  final ValueChanged<AdminFoodItemModel> onEditFood;
  final ValueChanged<AdminFoodItemModel> onEditScientificProperties;
  final ValueChanged<AdminFoodItemModel> onDeleteFood;

  const AdminFoodTableView({
    super.key,
    required this.foods,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onAddFood,
    required this.onEditFood,
    required this.onEditScientificProperties,
    required this.onDeleteFood,
  });

  @override
  State<AdminFoodTableView> createState() => _AdminFoodTableViewState();
}

class _AdminFoodTableViewState extends State<AdminFoodTableView> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Produce',
    'Dairy & Sweets',
    'Snacks & Wafers',
    'Biscuits & Bakery',
    'Meat & Poultry',
    'Spices & Seasonings',
    'Grains & Pulses',
    'Beverages',
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
                    hintText: 'Search food commodities...',
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
                    width: 155,
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
                    text: 'Add Commodity',
                    icon: Icons.add_rounded,
                    height: 42,
                    fontSize: 13,
                    onPressed: widget.onAddFood,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),

          // Food Commodities List
          if (widget.foods.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text('No food commodities found', style: TextStyle(fontSize: 14, color: AppTheme.slateBody)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.foods.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final food = widget.foods[index];
                return _buildFoodRow(food);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFoodRow(AdminFoodItemModel food) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 680;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        food.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildCategoryBadge(food.category),
                  ],
                ),
                if (food.scientificName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    food.scientificName!,
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 8),
                _buildMetricsRow(food),
                const SizedBox(height: 10),
                _buildActionButtons(food),
              ],
            );
          }

          return Row(
            children: [
              // Commodity Details
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                    ),
                    if (food.scientificName != null)
                      Text(
                        food.scientificName!,
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade500),
                      ),
                    const SizedBox(height: 4),
                    _buildCategoryBadge(food.category),
                  ],
                ),
              ),

              // Biochemical Metrics
              Expanded(
                flex: 4,
                child: _buildMetricsRow(food),
              ),

              // Action Buttons
              Expanded(
                flex: 4,
                child: _buildActionButtons(food),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
      ),
    );
  }

  Widget _buildMetricsRow(AdminFoodItemModel food) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _metricBadge('M: ${food.moisture.toStringAsFixed(1)}%'),
        _metricBadge('pH: ${food.ph.toStringAsFixed(1)}'),
        _metricBadge('F: ${food.fat.toStringAsFixed(1)}%'),
        if (food.waterActivity != null) _metricBadge('aw: ${food.waterActivity!.toStringAsFixed(2)}'),
        _respirationBadge(food.respirationClass),
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

  Widget _respirationBadge(String respirationClass) {
    Color bg = Colors.grey.shade100;
    Color fg = AppTheme.slateDark;

    if (respirationClass == 'High' || respirationClass == 'Extremely High') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
    } else if (respirationClass == 'Moderate') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Resp: $respirationClass',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildActionButtons(AdminFoodItemModel food) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Scientific Properties Button
        OutlinedButton.icon(
          onPressed: () => widget.onEditScientificProperties(food),
          icon: const Icon(Icons.biotech_rounded, size: 14),
          label: const Text('Traits', style: TextStyle(fontSize: 11)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),

        // Edit Commodity Button
        IconButton(
          onPressed: () => widget.onEditFood(food),
          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.slateBody),
          tooltip: 'Edit Food',
          visualDensity: VisualDensity.compact,
        ),

        // Delete Commodity Button
        IconButton(
          onPressed: () => _confirmDelete(food),
          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFE11D48)),
          tooltip: 'Delete Food',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  void _confirmDelete(AdminFoodItemModel food) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Food Commodity?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Are you sure you want to delete "${food.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDeleteFood(food);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
