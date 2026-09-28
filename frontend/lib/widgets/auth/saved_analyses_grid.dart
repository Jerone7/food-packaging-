import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import 'saved_analysis_card.dart';

/// Responsive Grid/List of saved analysis presets with search filter and empty states.
class SavedAnalysesGrid extends StatefulWidget {
  final List<SavedAnalysisModel> analyses;
  final ValueChanged<SavedAnalysisModel>? onLoadPreset;
  final ValueChanged<SavedAnalysisModel>? onDeletePreset;
  final ValueChanged<SavedAnalysisModel>? onExportPreset;

  const SavedAnalysesGrid({
    super.key,
    required this.analyses,
    this.onLoadPreset,
    this.onDeletePreset,
    this.onExportPreset,
  });

  @override
  State<SavedAnalysesGrid> createState() => _SavedAnalysesGridState();
}

class _SavedAnalysesGridState extends State<SavedAnalysesGrid> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedAnalysisModel> get _filteredAnalyses {
    if (_searchQuery.isEmpty) return widget.analyses;
    final q = _searchQuery.toLowerCase();
    return widget.analyses.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.commodityName.toLowerCase().contains(q) ||
          item.recommendedMaterial.toLowerCase().contains(q) ||
          (item.notes != null && item.notes!.toLowerCase().contains(q));
    }).toList();
  }

  void _confirmDelete(SavedAnalysisModel preset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Saved Preset?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove "${preset.title}" from your saved vault?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.slateBody)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDeletePreset?.call(preset);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAnalyses;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSingleColumn = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search & Count Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('saved_presets_search_input'),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search presets by title, crop, or material...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 18, color: AppTheme.slateBody),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: AppTheme.bgOffWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.bgOffWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Text(
                '${filtered.length} Presets',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Content: Empty State vs Grid
        if (filtered.isEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            alignment: Alignment.center,
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
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bookmark_border_rounded,
                      size: 36, color: AppTheme.primaryTeal),
                ),
                const SizedBox(height: 14),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No Presets Found for "$_searchQuery"'
                      : 'No Pinned Recommendation Presets Yet',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slateDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bookmark packaging recommendation configurations from the analysis cockpit to quickly reload and compare them anytime.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.slateBody,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else if (isSingleColumn) ...[
          // Single Column list on mobile
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final preset = filtered[index];
              return SavedAnalysisCard(
                analysis: preset,
                onLoad: widget.onLoadPreset,
                onDelete: _confirmDelete,
                onExportReport: widget.onExportPreset,
              );
            },
          ),
        ] else ...[
          // 2-Column Grid on desktop/tablet
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 320,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, index) {
              final preset = filtered[index];
              return SavedAnalysisCard(
                analysis: preset,
                onLoad: widget.onLoadPreset,
                onDelete: _confirmDelete,
                onExportReport: widget.onExportPreset,
              );
            },
          ),
        ],
      ],
    );
  }
}
