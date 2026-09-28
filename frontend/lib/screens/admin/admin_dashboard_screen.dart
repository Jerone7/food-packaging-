import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import '../../services/admin_api_service.dart';
import '../../services/auth_service.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_translations.dart';
import '../../widgets/navigation/language_selector_widget.dart';
import 'widgets/admin_kpi_card.dart';
import 'widgets/admin_trend_chart.dart';
import 'widgets/top_rankings_card.dart';
import 'widgets/admin_food_table_view.dart';
import 'widgets/add_edit_food_dialog.dart';
import 'widgets/scientific_properties_drawer.dart';
import 'widgets/admin_material_table_view.dart';
import 'widgets/add_edit_material_dialog.dart';
import 'widgets/rule_thresholds_editor.dart';
import 'widgets/model_registry_card.dart';
import 'widgets/recommendations_audit_list_view.dart';

/// Master Admin Dashboard & Scientific System Governance Cockpit (Module 15)
class AdminDashboardScreen extends StatefulWidget {
  final AdminApiService? apiService;

  const AdminDashboardScreen({
    super.key,
    this.apiService,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late final AdminApiService _apiService;
  late final TabController _tabController;
  final _passkeyController = TextEditingController();
  bool _obscurePasskey = true;
  String? _passkeyError;

  bool _isLoading = true;
  String? _errorMessage;

  // State caches
  AdminAnalyticsSummaryModel? _analyticsSummary;
  List<AdminFoodItemModel> _foods = [];
  List<AdminMaterialItemModel> _materials = [];
  RuleThresholdConfigModel _rules = const RuleThresholdConfigModel();
  ModelRegistryModel? _modelRegistry;
  List<AdminRecommendationAuditModel> _auditLogs = [];

  // Filter queries
  String _foodSearchQuery = '';
  String _foodCategoryFilter = 'All';
  String _matSearchQuery = '';
  String _matCategoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? AdminApiService();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _passkeyController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await _apiService.getAnalyticsSummary();
      final foods = await _apiService.listFoods(search: _foodSearchQuery, category: _foodCategoryFilter);
      final materials = await _apiService.listMaterials(search: _matSearchQuery, category: _matCategoryFilter);
      final rules = await _apiService.getRules();
      final modelRegistry = await _apiService.getModelRegistry();
      final auditLogs = await _apiService.getRecommendationsAudit();

      if (mounted) {
        setState(() {
          _analyticsSummary = summary;
          _foods = foods;
          _materials = materials;
          _rules = rules;
          _modelRegistry = modelRegistry;
          _auditLogs = auditLogs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load governance datasets: $e';
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // Food CRUD Handlers
  // ==========================================

  Future<void> _filterFoods() async {
    final foods = await _apiService.listFoods(
      search: _foodSearchQuery,
      category: _foodCategoryFilter,
    );
    if (mounted) setState(() => _foods = foods);
  }

  void _openAddFoodDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddEditFoodDialog(
        onSave: (payload) async {
          await _apiService.createFood(payload);
          await _filterFoods();
          _showToast('New food commodity added successfully.');
        },
      ),
    );
  }

  void _openEditFoodDialog(AdminFoodItemModel food) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditFoodDialog(
        initialFood: food,
        onSave: (payload) async {
          await _apiService.updateFood(food.id, payload);
          await _filterFoods();
          _showToast('Updated commodity "${food.name}".');
        },
      ),
    );
  }

  Future<void> _openScientificPropertiesDialog(AdminFoodItemModel food) async {
    final detail = await _apiService.getFoodById(food.id) ??
        AdminFoodDetailModel(
          id: food.id,
          name: food.name,
          category: food.category,
          scientificName: food.scientificName,
          moisture: food.moisture,
          ph: food.ph,
          fat: food.fat,
          respirationClass: food.respirationClass,
        );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => ScientificPropertiesDrawer(
        food: detail,
        onSave: (props) async {
          await _apiService.updateFoodScientificProperties(food.id, props);
          await _filterFoods();
          _showToast('Updated 14 scientific traits for "${food.name}".');
        },
      ),
    );
  }

  Future<void> _deleteFood(AdminFoodItemModel food) async {
    await _apiService.deleteFood(food.id);
    await _filterFoods();
    _showToast('Deleted commodity "${food.name}".');
  }

  // ==========================================
  // Packaging Material CRUD Handlers
  // ==========================================

  Future<void> _filterMaterials() async {
    final materials = await _apiService.listMaterials(
      search: _matSearchQuery,
      category: _matCategoryFilter,
    );
    if (mounted) setState(() => _materials = materials);
  }

  void _openAddMaterialDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddEditMaterialDialog(
        onSave: (payload) async {
          await _apiService.createMaterial(payload);
          await _filterMaterials();
          _showToast('New packaging substrate configured.');
        },
      ),
    );
  }

  void _openEditMaterialDialog(AdminMaterialItemModel mat) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditMaterialDialog(
        initialMaterial: mat,
        onSave: (payload) async {
          await _apiService.updateMaterial(mat.id, payload);
          await _filterMaterials();
          _showToast('Updated substrate "${mat.name}".');
        },
      ),
    );
  }

  Future<void> _toggleMaterialStatus(AdminMaterialItemModel mat) async {
    final updated = await _apiService.toggleMaterialStatus(mat.id);
    await _filterMaterials();
    if (updated != null) {
      _showToast('${mat.name} is now ${updated.isActiveEntry ? "Active" : "Archived"}.');
    }
  }

  Future<void> _deleteMaterial(AdminMaterialItemModel mat) async {
    await _apiService.deleteMaterial(mat.id);
    await _filterMaterials();
    _showToast('Deleted packaging substrate "${mat.name}".');
  }

  // ==========================================
  // Rules & AI Governance Handlers
  // ==========================================

  Future<void> _saveRules(RuleThresholdConfigModel rules) async {
    final updated = await _apiService.updateRules(rules);
    setState(() => _rules = updated);
    _showToast('Scientific heuristic thresholds updated successfully.');
  }

  Future<void> _toggleMlMode() async {
    final updated = await _apiService.toggleMlMode();
    setState(() => _modelRegistry = updated);
    _showToast(updated.isMlEnabled
        ? 'ML Model inference activated.'
        : 'ML offline. Switched to deterministic rule engine.');
  }

  Future<void> _refreshAuditLogs() async {
    final logs = await _apiService.getRecommendationsAudit();
    setState(() => _auditLogs = logs);
    _showToast('Recommendation audit stream refreshed.');
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.slateDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        return AnimatedBuilder(
          animation: AuthService(),
          builder: (context, _) {
            final auth = AuthService();
            final isAdmin = auth.currentUser?.isAdmin == true;

            if (!isAdmin) {
              return _buildAdminLockScreen();
            }

            return Scaffold(
              backgroundColor: AppTheme.bgOffWhite,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildTopAppBar(),
                    _buildTabBar(),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                          : _errorMessage != null
                              ? _buildErrorView()
                              : TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildAnalyticsTab(),
                                    _buildFoodsTab(),
                                    _buildMaterialsTab(),
                                    _buildGovernanceTab(),
                                  ],
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdminLockScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF334155)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 40,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Administrative Security Gate',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Restricted area. Enter the Master Administrative Passkey to calibrate ML models, rule thresholds, and catalog data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    key: const Key('admin_lock_passkey_input'),
                    controller: _passkeyController,
                    obscureText: _obscurePasskey,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Master Admin Passkey',
                      labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      hintText: 'Enter Admin@2026',
                      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFF59E0B), size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePasskey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscurePasskey = !_obscurePasskey),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _handleUnlock(),
                  ),
                  if (_passkeyError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _passkeyError!,
                      style: const TextStyle(color: Color(0xFFF87171), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    key: const Key('admin_lock_verify_button'),
                    onPressed: _handleUnlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Authenticate & Unlock Console',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.grey),
                    label: const Text('Return to Client App', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleUnlock() {
    final success = AuthService().authenticateAdminPasskey(_passkeyController.text);
    if (success) {
      setState(() {
        _passkeyError = null;
      });
      _loadAllData();
      _showToast('Admin authorization verified. Welcome SuperAdmin!');
    } else {
      setState(() {
        _passkeyError = 'Invalid Security Passkey. Access Denied.';
      });
    }
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 10,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.slateDark),
                  tooltip: 'Exit to Client App',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryTeal, size: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'admin.title'.tr(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'admin.subtitle'.tr(),
                        style: const TextStyle(fontSize: 11, color: AppTheme.slateBody),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (MediaQuery.of(context).size.width >= 500)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFFD97706)),
                    SizedBox(width: 4),
                    Text(
                      'SuperAdmin Role',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _loadAllData,
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryTeal),
                tooltip: 'Refresh System Catalogs',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppTheme.primaryTeal,
        unselectedLabelColor: AppTheme.slateBody,
        indicatorColor: AppTheme.primaryTeal,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(icon: Icon(Icons.analytics_outlined, size: 18), text: 'Analytics & Trends'),
          Tab(icon: Icon(Icons.restaurant_menu_rounded, size: 18), text: 'Food Commodities'),
          Tab(icon: Icon(Icons.layers_outlined, size: 18), text: 'Packaging Materials'),
          Tab(icon: Icon(Icons.psychology_outlined, size: 18), text: 'Rules & AI Governance'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFE11D48)),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: AppTheme.slateDark, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAllData, child: const Text('Retry Connection')),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Tab 1: Analytics & Trends View
  // ==========================================

  Widget _buildAnalyticsTab() {
    final summary = _analyticsSummary ??
        const AdminAnalyticsSummaryModel(
          totalAnalyses: 1420,
          totalUsers: 85,
          totalFoodsCount: 18,
          totalMaterialsCount: 12,
          ecoPreferencePct: 82.5,
          averageSystemScore: 91.4,
          topFoods: [],
          topMaterials: [],
          trends: [],
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 4-Card Responsive KPI Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 900;
                  final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

                  final cards = [
                    AdminKpiCard(
                      title: 'Total Analyses Run',
                      value: summary.totalAnalyses.toString(),
                      subtitle: 'Across all client sessions',
                      icon: Icons.bar_chart_rounded,
                      accentColor: AppTheme.primaryTeal,
                      trendText: '+14.2%',
                      isPositiveTrend: true,
                    ),
                    AdminKpiCard(
                      title: 'Eco Adoption Rate',
                      value: '${summary.ecoPreferencePct.toStringAsFixed(1)}%',
                      subtitle: 'Recyclable & bio-pouch preferences',
                      icon: Icons.eco_rounded,
                      accentColor: AppTheme.emeraldEco,
                      trendText: '+8.5%',
                      isPositiveTrend: true,
                    ),
                    AdminKpiCard(
                      title: 'Active Food Database',
                      value: summary.totalFoodsCount.toString(),
                      subtitle: 'Calibrated biochemical traits',
                      icon: Icons.restaurant_rounded,
                      accentColor: const Color(0xFFD97706),
                      trendText: 'Live',
                    ),
                    AdminKpiCard(
                      title: 'Barrier Material Matrix',
                      value: summary.totalMaterialsCount.toString(),
                      subtitle: 'Substrates with OTR/WVTR curves',
                      icon: Icons.layers_rounded,
                      accentColor: const Color(0xFF4F46E5),
                      trendText: 'Active',
                    ),
                  ];

                  if (isDesktop) {
                    return Row(
                      children: cards
                          .map((c) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: c,
                                ),
                              ))
                          .toList(),
                    );
                  }

                  if (isTablet) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: cards[0]),
                            const SizedBox(width: 12),
                            Expanded(child: cards[1]),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: cards[2]),
                            const SizedBox(width: 12),
                            Expanded(child: cards[3]),
                          ],
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: cards
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: c,
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 30-Day Usage Trend Visualizer
              AdminTrendChart(trends: summary.trends),
              const SizedBox(height: 24),

              // Top Searched Foods & Recommended Materials Leaderboards
              TopRankingsCard(
                topFoods: summary.topFoods,
                topMaterials: summary.topMaterials,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Tab 2: Food Commodities Tab
  // ==========================================

  Widget _buildFoodsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: AdminFoodTableView(
            foods: _foods,
            onSearchChanged: (query) {
              _foodSearchQuery = query;
              _filterFoods();
            },
            onCategoryChanged: (category) {
              _foodCategoryFilter = category;
              _filterFoods();
            },
            onAddFood: _openAddFoodDialog,
            onEditFood: _openEditFoodDialog,
            onEditScientificProperties: _openScientificPropertiesDialog,
            onDeleteFood: _deleteFood,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Tab 3: Packaging Materials Tab
  // ==========================================

  Widget _buildMaterialsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: AdminMaterialTableView(
            materials: _materials,
            onSearchChanged: (query) {
              _matSearchQuery = query;
              _filterMaterials();
            },
            onCategoryChanged: (category) {
              _matCategoryFilter = category;
              _filterMaterials();
            },
            onAddMaterial: _openAddMaterialDialog,
            onEditMaterial: _openEditMaterialDialog,
            onToggleStatus: _toggleMaterialStatus,
            onDeleteMaterial: _deleteMaterial,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Tab 4: Rules & AI Governance Tab
  // ==========================================

  Widget _buildGovernanceTab() {
    final modelRegistry = _modelRegistry ??
        ModelRegistryModel(
          activeModelName: 'RandomForest-v2.3-18D',
          algorithm: 'Random Forest Ensemble (100 Estimators)',
          featureDimension: 18,
          accuracyScore: 0.984,
          isMlEnabled: true,
          isHeuristicFallbackActive: true,
          lastTrainedAt: DateTime.now(),
          versionTag: 'v2.3.0-prod',
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ML Model Registry Card
              ModelRegistryCard(
                modelRegistry: modelRegistry,
                onToggleMl: _toggleMlMode,
              ),
              const SizedBox(height: 24),

              // Scientific Rule Thresholds Editor
              RuleThresholdsEditor(
                initialRules: _rules,
                onSave: _saveRules,
              ),
              const SizedBox(height: 24),

              // Recommendations System Audit Stream
              RecommendationsAuditListView(
                auditLogs: _auditLogs,
                onRefresh: _refreshAuditLogs,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
