import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../modern_card.dart';

/// Card widget presenting a saved recommendation preset with actions to reload or delete.
class SavedAnalysisCard extends StatelessWidget {
  final SavedAnalysisModel analysis;
  final ValueChanged<SavedAnalysisModel>? onLoad;
  final ValueChanged<SavedAnalysisModel>? onDelete;
  final ValueChanged<SavedAnalysisModel>? onExportReport;

  const SavedAnalysisCard({
    super.key,
    required this.analysis,
    this.onLoad,
    this.onDelete,
    this.onExportReport,
  });

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.borderSubtle,
      enableHover: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Title + Date + Delete Action
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bookmark_rounded,
                    color: AppTheme.primaryTeal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slateDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${analysis.commodityName} • ${_formatDate(analysis.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.slateBody,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  key: Key('saved_preset_delete_${analysis.id}'),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 18),
                  tooltip: 'Delete Preset',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => onDelete?.call(analysis),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Prescribed Material Substrate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.bgOffWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers_outlined, size: 14, color: AppTheme.slateBody),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    analysis.recommendedMaterial,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slateDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Metrics Badges (Cost & Sustainability)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.borderTeal,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  analysis.formattedCost,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco_rounded, size: 12, color: AppTheme.emeraldEco),
                    const SizedBox(width: 4),
                    Text(
                      analysis.formattedScore,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.emeraldEco,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Optional Notes
          if (analysis.notes != null && analysis.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              analysis.notes!,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.slateBody,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: AppTheme.borderSubtle, height: 1),
          const SizedBox(height: 12),

          // Actions: Load into Cockpit & Download Report
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: Key('saved_preset_load_${analysis.id}'),
                  icon: const Icon(Icons.rocket_launch_outlined,
                      size: 14, color: Colors.white),
                  label: const Text(
                    'Load into Cockpit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => onLoad?.call(analysis),
                ),
              ),
              if (onExportReport != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  key: Key('saved_preset_export_${analysis.id}'),
                  icon: const Icon(Icons.download_rounded,
                      size: 16, color: AppTheme.primaryTeal),
                  tooltip: 'Export Report',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.bgOffWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                  ),
                  onPressed: () => onExportReport?.call(analysis),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
