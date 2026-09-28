import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Search, filter, and sorting controls for the Recommendation Audit History.
class HistoryFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final String sortBy;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onClearFilters;

  const HistoryFilterBar({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.sortBy,
    required this.onSearchChanged,
    required this.onFilterChanged,
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
          // Top Search & Sort Row
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
                    hintText: 'Search past recommendation by commodity or box type...',
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

              final sortDropdown = Container(
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
                      DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                      DropdownMenuItem(value: 'eco_score', child: Text('Highest Eco-Score')),
                      DropdownMenuItem(value: 'cost', child: Text('Lowest Unit Cost')),
                      DropdownMenuItem(value: 'space_util', child: Text('Highest Space Utilization')),
                      DropdownMenuItem(value: 'name', child: Text('Commodity Name (A-Z)')),
                    ],
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    searchField,
                    const SizedBox(height: 10),
                    sortDropdown,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  SizedBox(width: 240, child: sortDropdown),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Filter Chips Horizontal Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All Audits', selectedFilter == 'all'),
                _buildFilterChip('eco', '🌿 Eco-Optimized', selectedFilter == 'eco'),
                _buildFilterChip('fragile', '⚠️ Fragile Handling', selectedFilter == 'fragile'),
                _buildFilterChip('standard', '⚙️ Standard Industrial', selectedFilter == 'standard'),
                if (selectedFilter != 'all' || searchController.text.isNotEmpty) ...[
                  const SizedBox(width: 12),
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

  Widget _buildFilterChip(String key, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onFilterChanged(key),
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
}
