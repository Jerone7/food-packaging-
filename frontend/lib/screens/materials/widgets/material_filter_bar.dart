import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/material_catalog_model.dart';

/// Filter & search control cockpit for the Material Database.
class MaterialFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final List<MaterialCategorySummary> categories;
  final double minSustainability;
  final bool isGridView;
  final String sortBy;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<double> onSustainabilityChanged;
  final ValueChanged<bool> onToggleViewMode;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onClearFilters;

  const MaterialFilterBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.categories,
    required this.minSustainability,
    required this.isGridView,
    required this.sortBy,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onSustainabilityChanged,
    required this.onToggleViewMode,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Controls: Responsive Search, Sorting, and View Mode Toggle
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              final searchField = Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.bgOffWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: const TextStyle(fontSize: 14, color: AppTheme.slateDark),
                  decoration: InputDecoration(
                    hintText: 'Search polymer, barrier, food application...',
                    hintStyle: TextStyle(fontSize: 13, color: AppTheme.slateBody.withValues(alpha: 0.7)),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.slateBody),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppTheme.slateBody),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              );

              final controls = Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgOffWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: sortBy,
                          isExpanded: true,
                          icon: const Icon(Icons.sort, size: 18, color: AppTheme.primaryTeal),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                          onChanged: (val) {
                            if (val != null) onSortChanged(val);
                          },
                          items: const [
                            DropdownMenuItem(value: 'sustainability_score', child: Text('Highest Eco-Score')),
                            DropdownMenuItem(value: 'otr', child: Text('Lowest OTR Barrier')),
                            DropdownMenuItem(value: 'wvtr', child: Text('Lowest WVTR Moisture')),
                            DropdownMenuItem(value: 'cost', child: Text('Lowest Unit Cost')),
                            DropdownMenuItem(value: 'tensile', child: Text('Highest Tensile Strength')),
                            DropdownMenuItem(value: 'name', child: Text('Material Name (A-Z)')),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.bgOffWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.grid_view_rounded,
                            size: 20,
                            color: isGridView ? AppTheme.primaryTeal : AppTheme.slateBody,
                          ),
                          tooltip: 'Card Grid View',
                          onPressed: () => onToggleViewMode(true),
                        ),
                        Container(width: 1, height: 24, color: AppTheme.borderSubtle),
                        IconButton(
                          icon: Icon(
                            Icons.table_rows_rounded,
                            size: 20,
                            color: !isGridView ? AppTheme.primaryTeal : AppTheme.slateBody,
                          ),
                          tooltip: 'Engineering Data Table',
                          onPressed: () => onToggleViewMode(false),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  children: [
                    searchField,
                    const SizedBox(height: 10),
                    controls,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  SizedBox(width: 320, child: controls),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Category Chips Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All', 'All Categories', selectedCategory == 'All'),
                ...categories.map((c) => _buildCategoryChip(
                      c.category,
                      '${c.category} (${c.count})',
                      selectedCategory == c.category,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Secondary Filter Strip: Eco Score Threshold & Clear Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Min Sustainability: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slateBody,
                  ),
                ),
                const SizedBox(width: 8),
                _buildEcoFilterPill('All (0+)', 0.0),
                const SizedBox(width: 6),
                _buildEcoFilterPill('🌿 50+ Eco', 50.0),
                const SizedBox(width: 6),
                _buildEcoFilterPill('🌱 80+ Premium Bio', 80.0),
                const SizedBox(width: 6),
                _buildEcoFilterPill('🌟 90+ Circular', 90.0),
                if (selectedCategory != 'All' || minSustainability > 0 || searchController.text.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.filter_alt_off, size: 14, color: Color(0xFFEF4444)),
                    label: const Text(
                      'Reset Filters',
                      style: TextStyle(fontSize: 12, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String key, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onCategorySelected(key),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.bgOffWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.slateBody,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEcoFilterPill(String label, double threshold) {
    final isSelected = minSustainability == threshold;
    return InkWell(
      onTap: () => onSustainabilityChanged(threshold),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1FAE5) : AppTheme.bgOffWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : AppTheme.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF059669) : AppTheme.slateBody,
          ),
        ),
      ),
    );
  }
}
