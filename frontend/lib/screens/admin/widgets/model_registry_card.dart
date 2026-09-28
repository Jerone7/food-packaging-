import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';

/// Machine Learning Registry & Model Governance Card (Module 15)
class ModelRegistryCard extends StatelessWidget {
  final ModelRegistryModel modelRegistry;
  final VoidCallback onToggleMl;

  const ModelRegistryCard({
    super.key,
    required this.modelRegistry,
    required this.onToggleMl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Header Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.memory_rounded, color: Color(0xFF4F46E5), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AI Model Registry & Engine',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Production ML ensemble & heuristic fallback controller',
                          style: TextStyle(fontSize: 12, color: AppTheme.slateBody),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: modelRegistry.isMlEnabled ? AppTheme.emeraldLight : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: modelRegistry.isMlEnabled ? AppTheme.emeraldEco : const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      modelRegistry.isMlEnabled ? 'ML Active' : 'Heuristic Mode',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: modelRegistry.isMlEnabled ? AppTheme.emeraldEco : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          // Model Information Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoItem('Active Model', modelRegistry.activeModelName, isHighlight: true),
                        const SizedBox(height: 12),
                        _infoItem('Algorithm', modelRegistry.algorithm),
                        const SizedBox(height: 12),
                        _infoItem('Feature Vector', '${modelRegistry.featureDimension} Dimensions'),
                        const SizedBox(height: 12),
                        _infoItem('Validation Accuracy', '${(modelRegistry.accuracyScore * 100).toStringAsFixed(1)}%'),
                        const SizedBox(height: 12),
                        _infoItem('Release Version', modelRegistry.versionTag),
                      ],
                    )
                  : Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        _infoBox('Active Model', modelRegistry.activeModelName, isHighlight: true),
                        _infoBox('Algorithm', modelRegistry.algorithm),
                        _infoBox('Feature Vector', '${modelRegistry.featureDimension} Dimensions'),
                        _infoBox('Validation Accuracy', '${(modelRegistry.accuracyScore * 100).toStringAsFixed(1)}%'),
                        _infoBox('Release Version', modelRegistry.versionTag),
                      ],
                    );
            },
          ),
          const SizedBox(height: 20),

          // ML Toggle Switch Tile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.bgOffWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Machine Learning Model Inference',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                      ),
                      Text(
                        modelRegistry.isMlEnabled
                            ? 'Serving Random Forest 18-feature model with heuristic fallback guardrails.'
                            : 'ML offline. Recommender is running exclusively on deterministic postharvest scientific rules.',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: modelRegistry.isMlEnabled,
                  activeThumbColor: AppTheme.primaryTeal,
                  onChanged: (_) => onToggleMl(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.slateBody)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppTheme.primaryTeal : AppTheme.slateDark,
          ),
        ),
      ],
    );
  }

  Widget _infoBox(String label, String value, {bool isHighlight = false}) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.slateBody)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppTheme.primaryTeal : AppTheme.slateDark,
            ),
          ),
        ],
      ),
    );
  }
}
