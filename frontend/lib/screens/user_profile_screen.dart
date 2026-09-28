import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/packaging_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/locale_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_translations.dart';
import '../widgets/auth/auth_form_card.dart';
import '../widgets/auth/profile_header_card.dart';
import '../widgets/auth/saved_analyses_grid.dart';
import '../widgets/modern_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/navigation/language_selector_widget.dart';
import 'analysis/food_analysis_screen.dart';
import 'reports/recommendation_report_screen.dart';
import 'history/widgets/my_analyses_list_view.dart';
import 'admin/admin_dashboard_screen.dart';

/// Master User Profile & Account Workspace Screen (Module 14: User Account).
class UserProfileScreen extends StatefulWidget {
  final int initialTabIndex;

  const UserProfileScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late int _activeTab;
  bool _isLoadingHistory = false;
  List<PackagingRecord> _historyRecords = [];

  // Preferences form state
  late String _prefCurrency;
  late bool _prefEcoPriority;
  late final TextEditingController _prefBatchController;
  late final TextEditingController _prefHeaderController;
  bool _isSavingPrefs = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTabIndex;

    final prefs = AuthService().preferences;
    _prefCurrency = prefs.defaultCurrency;
    _prefEcoPriority = prefs.defaultEcoPriority;
    _prefBatchController =
        TextEditingController(text: prefs.defaultBatchSize.toString());
    _prefHeaderController =
        TextEditingController(text: prefs.exportOrganizationHeader ?? '');

    _loadUserHistory();
  }

  @override
  void dispose() {
    _prefBatchController.dispose();
    _prefHeaderController.dispose();
    super.dispose();
  }

  Future<void> _loadUserHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final records = await ApiService.getHistory();
      if (mounted) {
        setState(() {
          _historyRecords = records;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  void _handleOpenHistoricalAnalysis(PackagingRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodAnalysisScreen(
          initialFoodName: record.itemName,
          initialFragile: record.isFragile,
          initialEco: record.ecoFriendly,
        ),
      ),
    );
  }

  void _handleExportHistoricalReport(PackagingRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendationReportScreen(
          input: record.toPackagingInput(),
          recommendationResult: record.toRecommendationResult(),
        ),
      ),
    );
  }

  Future<void> _handleDeleteHistoryRecord(PackagingRecord record) async {
    final success = await ApiService.deleteHistoryRecord(record.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${record.itemName} from history'),
          backgroundColor: AppTheme.slateDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadUserHistory();
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSavingPrefs = true);
    final batchSize = int.tryParse(_prefBatchController.text.trim()) ?? 10000;

    final success = await AuthService().updateProfile(
      defaultCurrency: _prefCurrency,
      defaultEcoPriority: _prefEcoPriority,
      defaultBatchSize: batchSize,
      exportOrganizationHeader: _prefHeaderController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSavingPrefs = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workspace preferences updated successfully!'),
            backgroundColor: AppTheme.emeraldEco,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleLoadPreset(SavedAnalysisModel preset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodAnalysisScreen(
          initialCategory: preset.commodityName,
        ),
      ),
    );
  }

  void _handleExportReport(SavedAnalysisModel preset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendationReportScreen(
          input: PackagingInput(
            itemName: preset.commodityName,
            length: 18.0,
            width: 12.0,
            height: 6.0,
            weight: 0.5,
            isFragile: false,
            ecoFriendly: true,
          ),
        ),
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
            final isAuthenticated = auth.isAuthenticated;

        return Scaffold(
          backgroundColor: AppTheme.bgOffWhite,
          appBar: AppBar(
            backgroundColor: AppTheme.surfaceWhite,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_circle_outlined,
                      color: AppTheme.primaryTeal, size: 20),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'profile.title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slateDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              if (isAuthenticated && auth.isOfflineDemo)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.offline_bolt_rounded,
                          size: 14, color: Color(0xFFB45309)),
                      SizedBox(width: 4),
                      Text(
                        'Demo Mode',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: isAuthenticated
                    ? _buildAuthenticatedWorkspace(auth)
                    : _buildUnauthenticatedPrompt(),
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  Widget _buildUnauthenticatedPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Workspace Value Proposition Banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SmartPack Engineering Workspace',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Unlock personalized packaging presets, user-isolated recommendation history streams, multi-format report exports, and custom organizational sustainability benchmarks.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Auth Form Card
        AuthFormCard(
          onAuthSuccess: () {
            _loadUserHistory();
          },
        ),
      ],
    );
  }

  Widget _buildAuthenticatedWorkspace(AuthService auth) {
    final isAdmin = auth.currentUser?.isAdmin == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Profile Header & Metrics
        ProfileHeaderCard(
          onLogout: () {
            auth.logout();
            setState(() {
              _historyRecords.clear();
            });
          },
        ),
        const SizedBox(height: 20),

        // Admin Console Banner (Strictly For Verified Admins)
        if (isAdmin)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFD97706), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Administration Console',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'AI Catalogs, Rules & Governance Cockpit',
                            style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const Key('user_profile_admin_console_button'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Open Admin Console'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield_outlined, size: 18, color: Color(0xFFD97706)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Governance & Model Controls',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                      ),
                      Text(
                        'Requires Master Admin Passkey',
                        style: TextStyle(fontSize: 11, color: AppTheme.slateBody),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  key: const Key('user_profile_admin_unlock_button'),
                  onPressed: () => _promptAdminPasskey(context),
                  icon: const Icon(Icons.key_rounded, size: 14, color: Color(0xFFD97706)),
                  label: const Text(
                    'Admin Unlock',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF3C7),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

        // 2. Workspace Navigation Tabs
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _WorkspaceTab(
                icon: Icons.bookmark_added_rounded,
                label: 'Saved Presets (${auth.savedAnalyses.length})',
                isSelected: _activeTab == 0,
                onTap: () => setState(() => _activeTab = 0),
              ),
              _WorkspaceTab(
                icon: Icons.history_rounded,
                label: 'Analysis History (${_historyRecords.length})',
                isSelected: _activeTab == 1,
                onTap: () => setState(() => _activeTab = 1),
              ),
              _WorkspaceTab(
                icon: Icons.tune_rounded,
                label: 'Preferences',
                isSelected: _activeTab == 2,
                onTap: () => setState(() => _activeTab = 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. Active Tab Content
        if (_activeTab == 0) ...[
          SavedAnalysesGrid(
            analyses: auth.savedAnalyses,
            onLoadPreset: _handleLoadPreset,
            onExportPreset: _handleExportReport,
            onDeletePreset: (preset) => auth.deleteSavedAnalysis(preset.id),
          ),
        ] else if (_activeTab == 1) ...[
          _buildHistoryTab(),
        ] else if (_activeTab == 2) ...[
          _buildPreferencesTab(),
        ],
      ],
    );
  }

  Widget _buildHistoryTab() {
    return MyAnalysesListView(
      records: _historyRecords,
      isLoading: _isLoadingHistory,
      onOpenAnalysis: _handleOpenHistoricalAnalysis,
      onViewReport: _handleExportHistoricalReport,
      onDeleteRecord: _handleDeleteHistoryRecord,
      onStartNewAnalysis: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FoodAnalysisScreen(),
          ),
        );
      },
      onRefresh: _loadUserHistory,
    );
  }

  Widget _buildPreferencesTab() {
    return ModernCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      borderColor: AppTheme.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Engineering Defaults & Workspace Bias',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.slateDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Configure your baseline unit currency, bulk procurement batch volume, and sustainable material bias.',
            style: TextStyle(fontSize: 13, color: AppTheme.slateBody),
          ),
          const SizedBox(height: 20),

          // Currency Dropdown
          DropdownButtonFormField<String>(
            key: const Key('workspace_pref_currency_dropdown'),
            initialValue: _prefCurrency,
            isExpanded: true,
            decoration: _prefInputDecoration(
                'Default Currency', Icons.currency_exchange_rounded),
            items: const [
              DropdownMenuItem(value: 'INR', child: Text('INR (₹) - Indian Rupee')),
              DropdownMenuItem(value: 'USD', child: Text('USD (\$) - US Dollar')),
              DropdownMenuItem(value: 'EUR', child: Text('EUR (€) - Euro')),
              DropdownMenuItem(value: 'GBP', child: Text('GBP (£) - British Pound')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _prefCurrency = val);
            },
          ),
          const SizedBox(height: 14),

          // Batch Size
          TextFormField(
            key: const Key('workspace_pref_batch_input'),
            controller: _prefBatchController,
            keyboardType: TextInputType.number,
            decoration: _prefInputDecoration(
                'Default Production Batch Size (Units)', Icons.inventory_2_outlined),
          ),
          const SizedBox(height: 14),

          // Organization Export Header
          TextFormField(
            key: const Key('workspace_pref_header_input'),
            controller: _prefHeaderController,
            decoration: _prefInputDecoration(
                'Report Header Organization Title', Icons.business_outlined),
          ),
          const SizedBox(height: 14),

          // Eco Priority Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.bgOffWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prioritize Eco-Friendly Alternatives',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slateDark,
                        ),
                      ),
                      Text(
                        'Rank bio-degradable and PCR-enhanced substrates as primary prescriptions.',
                        style: TextStyle(fontSize: 11, color: AppTheme.slateBody),
                      ),
                    ],
                  ),
                ),
                Switch(
                  key: const Key('workspace_pref_eco_switch'),
                  value: _prefEcoPriority,
                  activeThumbColor: AppTheme.emeraldEco,
                  onChanged: (val) => setState(() => _prefEcoPriority = val ?? true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Regional Language Preference Card
          Container(
            key: const Key('profile_language_preference_card'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgOffWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.translate_rounded,
                          color: AppTheme.primaryTeal, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'profile.language_preference_title'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.slateDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'profile.select_language_hint'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.slateBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const LanguageSelectorWidget(mode: LanguageSelectorMode.card),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220,
              child: GradientButton(
                key: const Key('workspace_pref_save_button'),
                text: 'Save Preferences',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isSavingPrefs,
                onPressed: _savePreferences,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _prefInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: AppTheme.slateBody),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: AppTheme.bgOffWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.borderSubtle),
      ),
    );
  }

  void _promptAdminPasskey(BuildContext context) {
    final passkeyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFD97706)),
            SizedBox(width: 8),
            Text('Admin Security Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the Master Administrative Passkey to authorize this session for system governance & catalog management.',
              style: TextStyle(fontSize: 13, color: AppTheme.slateDark),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passkeyCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Admin Security Passkey',
                hintText: 'Enter Admin@2026',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final ok = AuthService().authenticateAdminPasskey(passkeyCtrl.text);
              Navigator.pop(ctx);
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Admin authorization granted. Welcome SuperAdmin!'),
                    backgroundColor: Color(0xFF059669),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid Admin Passkey. Access denied.'),
                    backgroundColor: Color(0xFFE11D48),
                  ),
                );
              }
            },
            child: const Text('Unlock Console'),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkspaceTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryTeal.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primaryTeal : AppTheme.slateBody,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryTeal : AppTheme.slateBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
