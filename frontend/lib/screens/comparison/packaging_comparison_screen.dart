import 'package:flutter/material.dart';
import '../../models/packaging_comparison_model.dart';
import '../../models/material_catalog_model.dart';
import '../../services/api_service.dart';
import '../../services/locale_service.dart';
import '../../theme/app_translations.dart';
import '../../widgets/navigation/language_selector_widget.dart';
import 'widgets/comparison_parameter_table.dart';
import 'widgets/material_selector_strip.dart';
import 'widgets/quick_material_picker_modal.dart';
import 'widgets/comparative_radar_view.dart';
import 'widgets/best_in_class_summary_card.dart';
import 'widgets/ai_trade_off_banner.dart';

/// Full Interactive Packaging Comparison Screen (Module 9).
class PackagingComparisonScreen extends StatefulWidget {
  final List<String>? initialMaterialIds;
  final int? foodId;
  final String? foodName;

  const PackagingComparisonScreen({
    super.key,
    this.initialMaterialIds,
    this.foodId,
    this.foodName,
  });

  @override
  State<PackagingComparisonScreen> createState() => _PackagingComparisonScreenState();
}

class _PackagingComparisonScreenState extends State<PackagingComparisonScreen> {
  late List<String> _currentMaterialIds;
  int? _currentFoodId;
  String? _currentFoodName;

  PackagingComparisonResultModel? _comparisonResult;
  bool _isLoading = true;
  bool _showQuantitativeMetrics = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentFoodId = widget.foodId;
    _currentFoodName = widget.foodName;

    // Default to at least 2 or 3 standard materials if none provided
    if (widget.initialMaterialIds != null && widget.initialMaterialIds!.isNotEmpty) {
      _currentMaterialIds = List.from(widget.initialMaterialIds!.take(3));
      // Ensure at least 2 materials
      if (_currentMaterialIds.length < 2) {
        final fallback2 = ApiService.defaultMaterials
            .map((m) => m.materialId)
            .firstWhere((id) => !_currentMaterialIds.contains(id), orElse: () => 'mat_conv_hdpe_01');
        _currentMaterialIds.add(fallback2);
      }
    } else {
      _currentMaterialIds = [
        'mat_bio_emap_01',
        'mat_al_foil_lam_13',
        'mat_pp_clamshell_06',
      ];
    }

    _fetchComparison();
  }

  Future<void> _fetchComparison() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.comparePackagingMaterials(
        _currentMaterialIds,
        foodId: _currentFoodId,
        foodName: _currentFoodName,
      );

      if (mounted) {
        setState(() {
          _comparisonResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Fallback to offline synthesis
        final fallback = ApiService.generateOfflinePackagingComparison(
          _currentMaterialIds,
          foodId: _currentFoodId,
          foodName: _currentFoodName,
        );
        setState(() {
          _comparisonResult = fallback;
          _isLoading = false;
        });
      }
    }
  }

  void _onSlotPick(ComparisonSlotId slotId) {
    QuickMaterialPickerModal.show(
      context,
      targetSlot: slotId,
      currentlySelectedMaterialIds: _currentMaterialIds,
      onMaterialSelected: (PackagingMaterialDetail selected) {
        final slotIndex = slotId == ComparisonSlotId.materialA
            ? 0
            : (slotId == ComparisonSlotId.materialB ? 1 : 2);

        setState(() {
          if (slotIndex < _currentMaterialIds.length) {
            _currentMaterialIds[slotIndex] = selected.materialId;
          } else {
            _currentMaterialIds.add(selected.materialId);
          }
        });

        _fetchComparison();
      },
    );
  }

  void _onSlotRemove(ComparisonSlotId slotId) {
    if (_currentMaterialIds.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('comparison.min_materials'.tr()),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final slotIndex = slotId == ComparisonSlotId.materialA
        ? 0
        : (slotId == ComparisonSlotId.materialB ? 1 : 2);

    if (slotIndex < _currentMaterialIds.length) {
      setState(() {
        _currentMaterialIds.removeAt(slotIndex);
      });
      _fetchComparison();
    }
  }

  void _resetToDefault() {
    setState(() {
      _currentMaterialIds = [
        'mat_bio_emap_01',
        'mat_al_foil_lam_13',
        'mat_pp_clamshell_06',
      ];
    });
    _fetchComparison();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            elevation: 0.5,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.balance_rounded,
                    size: 20,
                    color: Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'comparison.title'.tr(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'comparison.subtitle'.tr(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Center(
                  child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
                ),
              ),
              // Quantitative metric toggle
              IconButton(
                icon: Icon(
                  _showQuantitativeMetrics ? Icons.analytics_rounded : Icons.analytics_outlined,
                  size: 20,
                  color: _showQuantitativeMetrics
                      ? const Color(0xFF0D9488)
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
                tooltip: _showQuantitativeMetrics ? 'comparison.hide_metrics'.tr() : 'comparison.show_metrics'.tr(),
                onPressed: () => setState(() => _showQuantitativeMetrics = !_showQuantitativeMetrics),
              ),
              // Reset button
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded, size: 20),
                tooltip: 'comparison.reset_tooltip'.tr(),
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                onPressed: _resetToDefault,
              ),
              const SizedBox(width: 8),
            ],
          ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF0D9488),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'comparison.loading'.tr(),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          : _comparisonResult == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 36, color: Color(0xFFEF4444)),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage ?? 'Failed to generate comparison matrix.',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchComparison,
                        child: Text('common.retry'.tr()),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1380),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Food Context Banner (if applicable)
                          if (_currentFoodName != null) ...[
                            _buildFoodContextPill(isDark),
                            const SizedBox(height: 16),
                          ],

                          // 2. Material Selector Strip (Top Anchor)
                          MaterialSelectorStrip(
                            slots: _comparisonResult!.slots,
                            onSlotPick: _onSlotPick,
                            onSlotRemove: _onSlotRemove,
                          ),

                          const SizedBox(height: 20),

                          // 3. Responsive Main Workspace Layout
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isDesktop = constraints.maxWidth >= 1080;

                              if (isDesktop) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left: Matrix Table
                                    Expanded(
                                      flex: 7,
                                      child: ComparisonParameterTable(
                                        slots: _comparisonResult!.slots,
                                        parameterRows: _comparisonResult!.parameterRows,
                                        showQuantitativeMetrics: _showQuantitativeMetrics,
                                        onSlotHeaderTap: (slotId) {
                                          _onSlotPick(ComparisonSlotId.fromId(slotId));
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    // Right: AI Trade-Off Banner, Best In Class, and Radar
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          AiTradeOffBanner(
                                            aiTradeOffSynthesis: _comparisonResult!.aiTradeOffSynthesis,
                                            keyRecommendationRule: _comparisonResult!.keyRecommendationRule,
                                            foodContextName: _currentFoodName,
                                          ),
                                          const SizedBox(height: 16),
                                          BestInClassSummaryCard(
                                            bestInClassSummary: _comparisonResult!.bestInClassSummary,
                                          ),
                                          const SizedBox(height: 16),
                                          ComparativeRadarView(
                                            slots: _comparisonResult!.slots,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                // Tablet / Mobile Stacked
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ComparisonParameterTable(
                                      slots: _comparisonResult!.slots,
                                      parameterRows: _comparisonResult!.parameterRows,
                                      showQuantitativeMetrics: _showQuantitativeMetrics,
                                      onSlotHeaderTap: (slotId) {
                                        _onSlotPick(ComparisonSlotId.fromId(slotId));
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    AiTradeOffBanner(
                                      aiTradeOffSynthesis: _comparisonResult!.aiTradeOffSynthesis,
                                      keyRecommendationRule: _comparisonResult!.keyRecommendationRule,
                                      foodContextName: _currentFoodName,
                                    ),
                                    const SizedBox(height: 16),
                                    BestInClassSummaryCard(
                                      bestInClassSummary: _comparisonResult!.bestInClassSummary,
                                    ),
                                    const SizedBox(height: 16),
                                    ComparativeRadarView(
                                      slots: _comparisonResult!.slots,
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFoodContextPill(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              size: 14,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Active Food Context: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  TextSpan(
                    text: _currentFoodName!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const TextSpan(
                    text: ' (Showing food-specific preservation ratings)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            tooltip: 'Clear Food Context',
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            onPressed: () {
              setState(() {
                _currentFoodId = null;
                _currentFoodName = null;
              });
              _fetchComparison();
            },
          ),
        ],
      ),
    );
  }
}
