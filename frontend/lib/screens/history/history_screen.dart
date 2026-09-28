import 'package:flutter/material.dart';
import '../../models/packaging_model.dart';
import '../../services/api_service.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_translations.dart';
import '../analysis/food_analysis_screen.dart';
import 'widgets/historical_record_card.dart';
import 'widgets/audit_detail_modal.dart';
import 'widgets/history_filter_bar.dart';

/// Module 7: Master Recommendation History & Technical Audit Cockpit.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PackagingRecord> _allRecords = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final records = await ApiService.getHistory();
    if (mounted) {
      setState(() {
        _allRecords = records;
        _isLoading = false;
      });
    }
  }

  List<PackagingRecord> get _filteredRecords {
    var list = List<PackagingRecord>.from(_allRecords);

    // Search query filter
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((r) {
        return r.itemName.toLowerCase().contains(query) ||
            r.recommendedBoxType.toLowerCase().contains(query) ||
            (r.notes != null && r.notes!.toLowerCase().contains(query));
      }).toList();
    }

    // Category / Attribute Filter
    if (_selectedFilter == 'eco') {
      list = list.where((r) => r.ecoFriendly || r.sustainabilityScore >= 80).toList();
    } else if (_selectedFilter == 'fragile') {
      list = list.where((r) => r.isFragile).toList();
    } else if (_selectedFilter == 'standard') {
      list = list.where((r) => !r.ecoFriendly && r.sustainabilityScore < 80).toList();
    }

    // Sort order
    if (_sortBy == 'eco_score') {
      list.sort((a, b) => b.sustainabilityScore.compareTo(a.sustainabilityScore));
    } else if (_sortBy == 'cost') {
      list.sort((a, b) => a.estimatedCost.compareTo(b.estimatedCost));
    } else if (_sortBy == 'space_util') {
      list.sort((a, b) => b.spaceUtilizationPct.compareTo(a.spaceUtilizationPct));
    } else if (_sortBy == 'name') {
      list.sort((a, b) => a.itemName.compareTo(b.itemName));
    } else {
      // Default: Newest first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  void _onReRunAnalysis(PackagingRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodAnalysisScreen(
          initialFoodName: record.itemName,
          initialFragile: record.isFragile,
          initialEco: record.ecoFriendly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 960;
    final filtered = _filteredRecords;
    final ecoCount = _allRecords.where((r) => r.ecoFriendly || r.sustainabilityScore >= 80).length;

    return Scaffold(
      backgroundColor: AppTheme.bgOffWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history_edu_outlined, size: 20, color: AppTheme.primaryTeal),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'analysis.history_title'.tr(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.slateDark,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20, color: AppTheme.slateDark),
            tooltip: 'common.retry'.tr(),
            onPressed: _loadHistory,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Banner
                _buildHeroBanner(isDesktop, _allRecords.length, ecoCount),
                const SizedBox(height: 16),

                // Search & Filter Controls
                HistoryFilterBar(
                  searchController: _searchController,
                  selectedFilter: _selectedFilter,
                  sortBy: _sortBy,
                  onSearchChanged: (_) => setState(() {}),
                  onFilterChanged: (val) => setState(() => _selectedFilter = val),
                  onSortChanged: (val) => setState(() => _sortBy = val),
                  onClearFilters: () {
                    setState(() {
                      _searchController.clear();
                      _selectedFilter = 'all';
                      _sortBy = 'newest';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Content List / Grid
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(60),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                    ),
                  )
                else if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  _buildRecordsGrid(filtered, isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildHeroBanner(bool isDesktop, int totalCount, int ecoCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '📋 Packaging Technical Audit System (Module 7)',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Historical AI Packaging Prescriptions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Inspect past AI recommendations, geometric box blueprints, space efficiencies, barrier profiles, and explainable scientific rationales.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildBannerStatPill('📦 Total Audits', '$totalCount Records'),
              _buildBannerStatPill('🌿 Eco-Prescriptions', '$ecoCount Optimized'),
              _buildBannerStatPill('⚡ Engine', 'PostgreSQL & Local Hybrid Cache'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStatPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11.5, color: Colors.white),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsGrid(List<PackagingRecord> records, bool isDesktop) {
    if (!isDesktop) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: records.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final r = records[index];
          return HistoricalRecordCard(
            record: r,
            onInspect: () => AuditDetailModal.show(context, r, onReRun: () => _onReRunAnalysis(r)),
            onReRun: () => _onReRunAnalysis(r),
          );
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 320,
      ),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return HistoricalRecordCard(
          record: r,
          onInspect: () => AuditDetailModal.show(context, r, onReRun: () => _onReRunAnalysis(r)),
          onReRun: () => _onReRunAnalysis(r),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
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
            decoration: const BoxDecoration(
              color: AppTheme.bgOffWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 36, color: AppTheme.slateBody),
          ),
          const SizedBox(height: 14),
          const Text(
            'No matching recommendation audits found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search query or reset active filters to see past records.',
            style: TextStyle(fontSize: 13, color: AppTheme.slateBody),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedFilter = 'all';
                _sortBy = 'newest';
              });
            },
            icon: const Icon(Icons.filter_alt_off, size: 16),
            label: const Text('Reset All Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryTeal,
              side: const BorderSide(color: AppTheme.primaryTeal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
