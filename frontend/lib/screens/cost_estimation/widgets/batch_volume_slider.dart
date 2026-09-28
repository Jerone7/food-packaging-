import 'package:flutter/material.dart';
import '../../../services/offline_cost_engine.dart';

/// Interactive logarithmic/stepped slider for batch volume selection with tier badges.
class BatchVolumeSlider extends StatelessWidget {
  final int numberOfPackages;
  final ValueChanged<int> onVolumeChanged;

  const BatchVolumeSlider({
    super.key,
    required this.numberOfPackages,
    required this.onVolumeChanged,
  });

  static const List<int> volumeMilestones = [1000, 5000, 10000, 25000, 50000, 100000];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (discountPct, tierLabel) = OfflineCostEngine.getVolumeDiscountTier(numberOfPackages);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.production_quantity_limits, size: 18, color: Color(0xFF0D9488)),
                const SizedBox(width: 8),
                Text(
                  '5. Batch Run Size',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: discountPct > 0
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: discountPct > 0 ? const Color(0xFF10B981) : Colors.grey,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    discountPct > 0 ? Icons.trending_down : Icons.info_outline,
                    size: 12,
                    color: discountPct > 0 ? const Color(0xFF10B981) : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    discountPct > 0 ? '-${discountPct.toStringAsFixed(0)}% Tier Discount' : 'Base Rate (MOQ Tier)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: discountPct > 0 ? const Color(0xFF10B981) : (isDark ? Colors.grey[300] : Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_formatVolume(numberOfPackages)} Units',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D9488),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tierLabel,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF0D9488),
            inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            thumbColor: const Color(0xFF0D9488),
            overlayColor: const Color(0xFF0D9488).withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: numberOfPackages.toDouble().clamp(100.0, 100000.0),
            min: 100.0,
            max: 100000.0,
            divisions: 100,
            onChanged: (val) {
              onVolumeChanged(val.round());
            },
          ),
        ),
        // Milestone chips
        Wrap(
          spacing: 6,
          children: volumeMilestones.map((m) {
            final isCurrent = numberOfPackages == m;
            return InkWell(
              onTap: () => onVolumeChanged(m),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF0D9488)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${m ~/ 1000}k',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(volume % 1000 == 0 ? 0 : 1)}k';
    }
    return volume.toString();
  }
}
