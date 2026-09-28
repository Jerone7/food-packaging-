import 'package:flutter/material.dart';
import '../../models/material_catalog_model.dart';
import '../../services/api_service.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_translations.dart';
import '../../widgets/navigation/language_selector_widget.dart';
import 'widgets/packaging_material_card.dart';
import 'widgets/material_filter_bar.dart';
import 'widgets/material_data_table.dart';
import 'widgets/pinned_comparison_bar.dart';
import 'widgets/material_detail_modal.dart';
import 'widgets/add_packaging_material_dialog.dart';
import '../comparison/packaging_comparison_screen.dart';

/// Packaging Material Database & 12-Property Explorer Screen (Module 6).
class PackagingCatalogScreen extends StatefulWidget {
  const PackagingCatalogScreen({super.key});

  @override
  State<PackagingCatalogScreen> createState() => _PackagingCatalogScreenState();
}

class _PackagingCatalogScreenState extends State<PackagingCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PackagingMaterialDetail> _materials = [];
  List<MaterialCategorySummary> _categories = [];
  final Set<String> _selectedMaterialIds = {};

  bool _isLoading = true;
  bool _isGridView = true;
  String _selectedCategory = 'All';
  double _minSustainability = 0.0;
  String _sortBy = 'sustainability_score';
  final String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await ApiService.getMaterialCategories();
      final materials = await ApiService.getMaterials(
        search: _searchController.text.trim(),
        category: _selectedCategory,
        minSustainability: _minSustainability > 0 ? _minSustainability : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      setState(() {
        _categories = categories;
        _materials = materials;
      });
    } catch (_) {
      // Fallback handled in ApiService
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    _loadData();
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _loadData();
  }

  void _onSustainabilityChanged(double threshold) {
    setState(() => _minSustainability = threshold);
    _loadData();
  }

  void _onSortChanged(String sort) {
    setState(() => _sortBy = sort);
    _loadData();
  }

  void _onClearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All';
      _minSustainability = 0.0;
      _sortBy = 'sustainability_score';
    });
    _loadData();
  }

  void _toggleMaterialComparison(String materialId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_selectedMaterialIds.length < 4) {
          _selectedMaterialIds.add(materialId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 4 materials can be compared simultaneously.'),
              backgroundColor: Color(0xFFD97706),
            ),
          );
        }
      } else {
        _selectedMaterialIds.remove(materialId);
      }
    });
  }

  Future<void> _launchComparison() async {
    if (_selectedMaterialIds.length < 2) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PackagingComparisonScreen(
          initialMaterialIds: _selectedMaterialIds.take(3).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    final isTablet = screenWidth >= 650 && screenWidth < 1000;

    final selectedMaterialsList = _materials
        .where((m) => _selectedMaterialIds.contains(m.materialId))
        .toList();

    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
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
                  child: const Icon(Icons.dataset_outlined, size: 20, color: AppTheme.primaryTeal),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'catalog.title'.tr(),
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
              if (MediaQuery.of(context).size.width >= 420)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Center(
                    child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton.icon(
                  onPressed: () => AddPackagingMaterialDialog.show(
                    context,
                    (newMat) {
                      setState(() {
                        _materials.insert(0, newMat);
                      });
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Add Material',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              selectedMaterialsList.isNotEmpty ? 90 : 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cockpit Header Banner
                    _buildHeroBanner(isDesktop),
                    const SizedBox(height: 16),

                    // Filter & Search Controls
                    MaterialFilterBar(
                      searchController: _searchController,
                      selectedCategory: _selectedCategory,
                      categories: _categories,
                      minSustainability: _minSustainability,
                      isGridView: _isGridView,
                      sortBy: _sortBy,
                      onSearchChanged: _onSearchChanged,
                      onCategorySelected: _onCategorySelected,
                      onSustainabilityChanged: _onSustainabilityChanged,
                      onToggleViewMode: (val) => setState(() => _isGridView = val),
                      onSortChanged: _onSortChanged,
                      onClearFilters: _onClearFilters,
                    ),
                    const SizedBox(height: 16),

                    // Content View: Grid or Table
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(60),
                        child: Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                        ),
                      )
                    else if (_materials.isEmpty)
                      _buildEmptyState()
                    else if (_isGridView)
                      _buildMaterialsGrid(isDesktop, isTablet)
                    else
                      MaterialDataTable(
                        materials: _materials,
                        selectedMaterialIds: _selectedMaterialIds,
                        onInspect: (mat) => MaterialDetailModal.show(context, mat),
                        onToggleComparison: _toggleMaterialComparison,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Pinned Floating Bottom Dock for Multi-Material Comparison
          if (selectedMaterialsList.isNotEmpty)
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: PinnedComparisonBar(
                    selectedMaterials: selectedMaterialsList,
                    onRemoveMaterial: (id) => _toggleMaterialComparison(id, false),
                    onClearAll: () => setState(() => _selectedMaterialIds.clear()),
                    onLaunchComparison: _launchComparison,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildHeroBanner(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
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
                    '🔬 SmartPack Technical Library (Module 6)',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Empirical Packaging Substrate Matrix',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Search 32+ physical polymers, bio-films, retort laminates, and cellulosic boards with 12-property vectors and 6-axis performance radar.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsGrid(bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 410,
      ),
      itemCount: _materials.length,
      itemBuilder: (ctx, index) {
        final mat = _materials[index];
        final isSelected = _selectedMaterialIds.contains(mat.materialId);
        return PackagingMaterialCard(
          material: mat,
          isSelectedForComparison: isSelected,
          onInspect: () => MaterialDetailModal.show(context, mat),
          onToggleComparison: (val) => _toggleMaterialComparison(mat.materialId, val),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(50),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(Icons.layers_clear_outlined, size: 52, color: AppTheme.slateBody.withValues(alpha: 0.4)),
          const SizedBox(height: 14),
          const Text(
            'No matching packaging materials found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search terms, domain categories, or eco-score filters.',
            style: TextStyle(fontSize: 13, color: AppTheme.slateBody),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _onClearFilters,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryTeal,
              side: const BorderSide(color: AppTheme.primaryTeal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }
}
