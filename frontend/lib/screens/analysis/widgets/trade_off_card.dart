import 'package:flutter/material.dart';

/// Trade-off and Preservation Rationale Card (Module 8).
/// Highlights crisp operational trade-offs, advantages, and limitations.
class TradeOffCard extends StatelessWidget {
  final String tradeOffSummary;
  final List<String> advantages;
  final List<String> limitations;
  final String? shelfLifeDelta;

  const TradeOffCard({
    super.key,
    required this.tradeOffSummary,
    this.advantages = const [],
    this.limitations = const [],
    this.shelfLifeDelta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate 100
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Trade-off Summary Callout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: Color(0xFFD97706), // Amber
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tradeOffSummary,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          // 2. Shelf Life Impact Badge
          if (shelfLifeDelta != null && shelfLifeDelta!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE), // Sky 100
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF0369A1)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Shelf Life Impact: $shelfLifeDelta',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0369A1),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 3. Advantages & Limitations (if present)
          if (advantages.isNotEmpty || limitations.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 8),

            if (advantages.isNotEmpty) ...[
              const Text(
                'Key Advantages:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 4),
              ...advantages.take(2).map((adv) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF059669)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            adv,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF334155),
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            if (limitations.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text(
                'Operational Boundaries:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB45309),
                ),
              ),
              const SizedBox(height: 4),
              ...limitations.take(2).map((lim) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.remove_circle_outline_rounded, size: 12, color: Color(0xFFB45309)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            lim,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF334155),
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ],
      ),
    );
  }
}
