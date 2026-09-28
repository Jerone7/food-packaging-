import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/packaging_model.dart';

/// Rich historical recommendation audit card.
class HistoricalRecordCard extends StatefulWidget {
  final PackagingRecord record;
  final VoidCallback onInspect;
  final VoidCallback onReRun;

  const HistoricalRecordCard({
    super.key,
    required this.record,
    required this.onInspect,
    required this.onReRun,
  });

  @override
  State<HistoricalRecordCard> createState() => _HistoricalRecordCardState();
}

class _HistoricalRecordCardState extends State<HistoricalRecordCard> {
  bool _isHovered = false;

  String _formatRelativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return DateFormat('MMM d, yyyy').format(dt);
  }

  Color _getEcoScoreColor(double score) {
    if (score >= 85) return const Color(0xFF059669); // Emerald
    if (score >= 70) return const Color(0xFF0284C7); // Sky Blue
    if (score >= 50) return const Color(0xFFD97706); // Amber
    return const Color(0xFFE11D48); // Rose
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final ecoColor = _getEcoScoreColor(r.sustainabilityScore);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppTheme.primaryTeal.withValues(alpha: 0.5) : AppTheme.borderSubtle,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppTheme.primaryTeal.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 14 : 8,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onInspect,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Commodity Name, Eco Pill, and Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: r.ecoFriendly
                            ? const Color(0xFFD1FAE5)
                            : AppTheme.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        r.ecoFriendly ? Icons.eco_rounded : Icons.inventory_2_outlined,
                        size: 20,
                        color: r.ecoFriendly ? const Color(0xFF059669) : AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.itemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.slateDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.recommendedBoxType,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.slateBody.withValues(alpha: 0.85),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.bgOffWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Text(
                        _formatRelativeDate(r.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slateBody,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Metrics Grid: Dims, Mass, Cost, Eco Score
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgOffWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      // Dimensions & Volume
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DIMENSIONS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.slateBody,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              r.recommendedDimensions.isNotEmpty
                                  ? r.recommendedDimensions
                                  : '${r.length} x ${r.width} x ${r.height} cm',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.slateDark,
                              ),
                            ),
                            Text(
                              '${r.weight.toStringAsFixed(1)} kg • ${r.spaceUtilizationPct.toStringAsFixed(0)}% space util',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.slateBody.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppTheme.borderSubtle),
                      const SizedBox(width: 12),
                      // Cost & Sustainability
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${r.estimatedCost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                              const Text(
                                ' / unit',
                                style: TextStyle(fontSize: 11, color: AppTheme.slateBody),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ecoColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '🌱 ${r.sustainabilityScore.toStringAsFixed(0)}/100 Eco',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ecoColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Cushioning & Feature Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (r.cushioningMaterial.isNotEmpty)
                      _buildChip('🛡️ ${r.cushioningMaterial}', const Color(0xFF0284C7)),
                    if (r.isFragile)
                      _buildChip('⚠️ Fragile Commodity', const Color(0xFFE11D48)),
                    if (r.ecoFriendly)
                      _buildChip('🌿 Zero-Plastic / Bio', const Color(0xFF059669)),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Footer
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onInspect,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryTeal,
                          side: const BorderSide(color: AppTheme.primaryTeal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.analytics_outlined, size: 16),
                        label: const Text(
                          'Inspect Audit',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onReRun,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text(
                          'Re-run Analysis',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
