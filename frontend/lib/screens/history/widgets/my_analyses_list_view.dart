import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/packaging_model.dart';
import 'my_analyses_card.dart';

/// Interactive list/workspace view for "My Analyses".
///
/// Features:
/// - Prominent Header: "My Analyses" with total count badge
/// - Real-time Search by produce/commodity name, box type, and material
/// - Segmented Filter Chips (`All`, `Eco-Friendly`, `Fragile`)
/// - 1-Click interactive re-open on any entry
/// - Graceful empty and zero-search states with "Start New Analysis" CTA
class MyAnalysesListView extends StatefulWidget {
  final List<PackagingRecord> records;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<PackagingRecord>? onOpenAnalysis;
  final ValueChanged<PackagingRecord>? onViewReport;
  final ValueChanged<PackagingRecord>? onDeleteRecord;
  final VoidCallback? onStartNewAnalysis;
  final VoidCallback? onRefresh;

  const MyAnalysesListView({
    super.key,
    required this.records,
    this.isLoading = false,
    this.errorMessage,
    this.onOpenAnalysis,
    this.onViewReport,
    this.onDeleteRecord,
    this.onStartNewAnalysis,
    this.onRefresh,
  });

  @override
  State<MyAnalysesListView> createState() => _MyAnalysesListViewState();
}

class _MyAnalysesListViewState extends State<MyAnalysesListView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Eco-Friendly', 'Fragile'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PackagingRecord> get _filteredRecords {
    final query = _searchController.text.trim().toLowerCase();

    return widget.records.where((r) {
      // Search match
      final matchQuery = query.isEmpty ||
          r.itemName.toLowerCase().contains(query) ||
          r.recommendedBoxType.toLowerCase().contains(query) ||
          r.cushioningMaterial.toLowerCase().contains(query) ||
          r.formattedDisplayDate.toLowerCase().contains(query);

      if (!matchQuery) return false;

      // Filter chip match
      if (_selectedFilter == 'Eco-Friendly') {
        return r.ecoFriendly;
      } else if (_selectedFilter == 'Fragile') {
        return r.isFragile;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppTheme.slateDark),
              ),
              const SizedBox(height: 16),
              if (widget.onRefresh != null)
                ElevatedButton.icon(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredRecords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section: "My Analyses" + Count badge
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'My Analyses',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slateDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.records.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.onStartNewAnalysis != null)
              ElevatedButton.icon(
                onPressed: widget.onStartNewAnalysis,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Search & Filter Bar
        Row(
          children: [
            // Search Input Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search analyses (e.g. Tomato, Kraft Box)...',
                    hintStyle: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', Icons.apps_rounded),
              const SizedBox(width: 8),
              _buildFilterChip('Eco-Friendly', Icons.eco_rounded),
              const SizedBox(width: 8),
              _buildFilterChip('Fragile', Icons.warning_amber_rounded),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Content Area: Empty State OR List of Cards
        if (filtered.isEmpty)
          _buildEmptyState(isSearchEmpty: widget.records.isNotEmpty)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = filtered[index];
              return MyAnalysesCard(
                key: ValueKey('history_item_${record.id}'),
                record: record,
                onOpenAnalysis: widget.onOpenAnalysis,
                onViewReport: widget.onViewReport,
                onDelete: widget.onDeleteRecord,
              );
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppTheme.slateBody,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.slateDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool isSearchEmpty}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.bgOffWhite,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearchEmpty ? Icons.search_off_rounded : Icons.history_edu_rounded,
              size: 38,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearchEmpty ? 'No matching analyses found' : 'No analyses saved yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.slateDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearchEmpty
                ? 'Try searching with a different produce name or filter category.'
                : 'Run packaging optimization to build your personal historical analyses workspace.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.slateBody,
            ),
          ),
          const SizedBox(height: 20),
          if (widget.onStartNewAnalysis != null)
            ElevatedButton.icon(
              onPressed: widget.onStartNewAnalysis,
              icon: const Icon(Icons.bolt, size: 18),
              label: const Text('Start Packaging Analysis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
