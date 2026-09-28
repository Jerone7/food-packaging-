import 'package:flutter/material.dart';
import '../../../models/packaging_model.dart';
import '../../../theme/app_theme.dart';
import 'alternative_materials_matrix.dart';
import 'advantages_limitations_card.dart';
import 'explainable_recommendation_banner.dart';
import 'important_properties_card.dart';
import 'packaging_format_card.dart';
import 'recommended_packaging_hero_card.dart';
import 'storage_application_card.dart';
import '../../comparison/packaging_comparison_screen.dart';
import '../../cost_estimation/cost_estimation_screen.dart';
import '../../sustainability/sustainability_analysis_screen.dart';
import '../../reports/recommendation_report_screen.dart';
import '../../history/history_screen.dart';
import '../../../widgets/auth/save_analysis_dialog.dart';

/// Full Interactive Explainable Recommendation Results Cockpit (Module 5).
/// Assembles the hero recommended packaging card, explainable AI narrative banner,
/// 2x2 technical spec grid (important properties, advantages & limitations, storage, format),
/// and alternative materials trade-off matrix.
class RecommendationResultsCockpit extends StatefulWidget {
  final PackagingRecommendationResult result;
  final VoidCallback? onResetAnalysis;

  const RecommendationResultsCockpit({
    super.key,
    required this.result,
    this.onResetAnalysis,
  });

  @override
  State<RecommendationResultsCockpit> createState() => _RecommendationResultsCockpitState();
}

class _RecommendationResultsCockpitState extends State<RecommendationResultsCockpit> {
  String? _selectedMaterialOverride;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final primary = result.primaryRecommendation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Section Header with Title and Reset/Export Button
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 850;
            final titleWidget = Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: AppTheme.primaryTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI PACKAGING PRESCRIPTION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppTheme.primaryTeal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Hybrid Prescription & Explainable Rationale',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slateDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );

            final actionButtons = Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  key: const Key('cockpit_bookmark_preset_button'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => SaveAnalysisDialog(
                        commodityName: primary.materialName,
                        recommendedMaterial: primary.materialName,
                        estimatedCost: primary.estimatedUnitCostInr,
                        sustainabilityScore: primary.sustainabilityScore,
                        inputPayload: {
                          'material_name': primary.materialName,
                          'recommended_box_type': result.recommendedBoxType,
                        },
                        recommendationResult: {
                          'material_name': primary.materialName,
                          'estimated_cost': primary.estimatedUnitCostInr,
                          'sustainability_score': primary.sustainabilityScore,
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark_add_outlined, size: 14),
                  label: const Text('Bookmark Preset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryTeal,
                    side: const BorderSide(color: AppTheme.borderTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => RecommendationReportScreen(
                          recommendationResult: result,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined, size: 14),
                  label: const Text('Export Report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_rounded, size: 14),
                  label: const Text('My Analyses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryTeal,
                    side: const BorderSide(color: AppTheme.borderTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                if (widget.onResetAnalysis != null)
                  OutlinedButton.icon(
                    onPressed: widget.onResetAnalysis,
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text('New Analysis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.slateBody,
                      side: const BorderSide(color: AppTheme.borderSubtle),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget,
                  const SizedBox(height: 10),
                  actionButtons,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: titleWidget),
                const SizedBox(width: 12),
                actionButtons,
              ],
            );
          },
        ),
        const SizedBox(height: 18),

        // 1. Hero Recommended Packaging Card
        RecommendedPackagingHeroCard(
          recommendation: primary,
        ),
        const SizedBox(height: 18),

        // 2. Explainable AI Rationale Banner
        ExplainableRecommendationBanner(
          explanation: primary.recommendationExplanation,
          keyDrivers: result.scientificRationale.keyDrivers,
        ),
        const SizedBox(height: 18),

        // 3. Technical Grid Section
        LayoutBuilder(
          builder: (context, constraints) {
            final isSideBySide = constraints.maxWidth >= 720;

            if (isSideBySide) {
              return Column(
                children: [
                  // Row 1: Important Properties (Left) & Advantages/Limitations (Right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: ImportantPropertiesCard(
                          importantProperties: primary.importantProperties,
                          barrierProfile: primary.barrierProfile,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: AdvantagesAndLimitationsCard(
                          advantages: primary.advantages,
                          limitations: primary.limitations,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Storage & Application (Left) & Format/Geometry (Right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: StorageAndApplicationCard(
                          suitableStorageCondition: primary.suitableStorageCondition,
                          expectedApplication: primary.expectedApplication,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: PackagingFormatCard(
                          packagingFormat: primary.packagingFormat,
                          geometry: result.boxGeometry,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // Stacked Mobile Layout (< 720px)
            return Column(
              children: [
                ImportantPropertiesCard(
                  importantProperties: primary.importantProperties,
                  barrierProfile: primary.barrierProfile,
                ),
                const SizedBox(height: 16),
                AdvantagesAndLimitationsCard(
                  advantages: primary.advantages,
                  limitations: primary.limitations,
                ),
                const SizedBox(height: 16),
                StorageAndApplicationCard(
                  suitableStorageCondition: primary.suitableStorageCondition,
                  expectedApplication: primary.expectedApplication,
                ),
                const SizedBox(height: 16),
                PackagingFormatCard(
                  packagingFormat: primary.packagingFormat,
                  geometry: result.boxGeometry,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),

        // 4. Alternative Materials Comparison Matrix (3 Candidates)
        if (result.alternatives.isNotEmpty) ...[
          AlternativeMaterialsMatrix(
            alternatives: result.alternatives,
            selectedMaterialName: _selectedMaterialOverride,
            onAlternativeSelected: (alt) {
              setState(() {
                _selectedMaterialOverride =
                    _selectedMaterialOverride == alt.materialName ? null : alt.materialName;
              });
            },
          ),
          const SizedBox(height: 22),
        ],

        // 5. Deep 3-Way Comparison CTA Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2A38), Color(0xFF132238)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 550;
              final buttons = [
                ElevatedButton.icon(
                  icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                  label: const Text('Compare ⚖️'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final candidateIds = [
                      primary.materialName.toLowerCase(),
                      ...result.alternatives.take(2).map((a) => a.materialName.toLowerCase()),
                    ];
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => PackagingComparisonScreen(
                          initialMaterialIds: candidateIds,
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.payments_outlined, size: 16),
                  label: const Text('Cost 💰'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => CostEstimationScreen(
                          initialMaterialName: primary.materialName,
                          initialFillQuantity: '500g',
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.eco_rounded, size: 16),
                  label: const Text('Eco Profile 🌱'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => SustainabilityAnalysisScreen(
                          initialMaterialName: primary.materialName,
                          foodCommodityName: primary.packagingTitle,
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('Full Report 📄'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => RecommendationReportScreen(
                          recommendationResult: result,
                        ),
                      ),
                    );
                  },
                ),
              ];

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.balance_rounded, color: Color(0xFF14B8A6), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deep Comparison & Costing',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Compare ${primary.materialName} against alternatives or compute cost baseline.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: buttons,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.balance_rounded, color: Color(0xFF14B8A6), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deep 3-Way Packaging Comparison',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Compare ${primary.materialName} against alternatives with 6-axis spider radar charts and parametric metrics.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  buttons[0],
                  const SizedBox(width: 8),
                  buttons[1],
                  const SizedBox(width: 8),
                  buttons[2],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
