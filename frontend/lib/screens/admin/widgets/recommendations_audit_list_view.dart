import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';

/// System-wide Recommendation Audit Stream & Inspection View (Module 15)
class RecommendationsAuditListView extends StatelessWidget {
  final List<AdminRecommendationAuditModel> auditLogs;
  final VoidCallback onRefresh;

  const RecommendationsAuditListView({
    super.key,
    required this.auditLogs,
    required this.onRefresh,
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
                      color: AppTheme.emeraldLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history_edu_rounded, color: AppTheme.emeraldEco, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'System Recommendation Audit Stream',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Chronological record of generated recommendations',
                          style: TextStyle(fontSize: 12, color: AppTheme.slateBody),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryTeal),
                tooltip: 'Refresh Audit Stream',
              ),
            ],
          ),
          const Divider(height: 28),

          // Audit Stream Content
          if (auditLogs.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.feed_outlined, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text('No recommendations recorded in audit trail', style: TextStyle(fontSize: 14, color: AppTheme.slateBody)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: auditLogs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final log = auditLogs[index];
                return _buildAuditRow(context, log);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAuditRow(BuildContext context, AdminRecommendationAuditModel log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 680;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        log.itemName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      log.formattedDate,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'User: ${log.userEmail ?? "Anonymous"}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.primaryTeal),
                ),
                const SizedBox(height: 6),
                Text(
                  'Solution: ${log.recommendedBoxType}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _badge('₹${log.estimatedCost.toStringAsFixed(2)}'),
                    _ecoBadge('${log.sustainabilityScore.toStringAsFixed(0)}% Eco'),
                    if (log.isFragile)
                      _badge('Fragile', color: const Color(0xFFE11D48)),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              // Commodity & User
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.itemName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                    ),
                    Text(
                      log.userEmail ?? 'Anonymous User',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${log.length}x${log.width}x${log.height} cm • ${log.weight} kg',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              // Recommended Solution
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.recommendedBoxType,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                    ),
                    if (log.cushioningMaterial != null)
                      Text(
                        'Cushion: ${log.cushioningMaterial}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),

              // Metrics & Timestamp
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '₹${log.estimatedCost.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                        ),
                        const SizedBox(width: 8),
                        _ecoBadge('${log.sustainabilityScore.toStringAsFixed(0)}% Eco'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      log.formattedDate,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              // Details Button
              IconButton(
                onPressed: () => _showDetailsDialog(context, log),
                icon: const Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.slateBody),
                tooltip: 'Inspect Details',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _badge(String label, {Color color = AppTheme.slateDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _ecoBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.emeraldLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.emeraldEco),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, AdminRecommendationAuditModel log) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${log.itemName} Recommendation Audit', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogDetail('User:', log.userEmail ?? 'Anonymous'),
            _dialogDetail('Dimensions:', '${log.length} x ${log.width} x ${log.height} cm (${log.weight} kg)'),
            _dialogDetail('Fragile Flag:', log.isFragile ? 'Yes' : 'No'),
            _dialogDetail('Eco Priority:', log.ecoFriendly ? 'High' : 'Standard'),
            const Divider(height: 16),
            _dialogDetail('Recommended Box:', log.recommendedBoxType),
            _dialogDetail('Box Sizing:', log.recommendedDimensions),
            if (log.cushioningMaterial != null) _dialogDetail('Cushioning:', log.cushioningMaterial!),
            _dialogDetail('Estimated Cost:', '₹${log.estimatedCost.toStringAsFixed(2)}'),
            _dialogDetail('Sustainability Score:', '${log.sustainabilityScore.toStringAsFixed(1)} / 100'),
            if (log.notes != null) _dialogDetail('Heuristic Rationale:', log.notes!),
            _dialogDetail('Generated At:', log.formattedDate),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _dialogDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateBody)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slateDark)),
          ),
        ],
      ),
    );
  }
}
