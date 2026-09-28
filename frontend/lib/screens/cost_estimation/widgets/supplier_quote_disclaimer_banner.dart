import 'package:flutter/material.dart';

/// Amber persistent disclaimer banner highlighting baseline model status and supplier quote inquiry launcher.
class SupplierQuoteDisclaimerBanner extends StatelessWidget {
  final String disclaimerNotice;
  final VoidCallback onRequestRfq;

  const SupplierQuoteDisclaimerBanner({
    super.key,
    required this.disclaimerNotice,
    required this.onRequestRfq,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;

          final rfqButton = TextButton.icon(
            onPressed: onRequestRfq,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.send_outlined, size: 14, color: Color(0xFFD97706)),
            label: const Text(
              'Supplier RFQ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD97706),
              ),
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        disclaimerNotice,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: rfqButton,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 20, color: Color(0xFFD97706)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  disclaimerNotice,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              rfqButton,
            ],
          );
        },
      ),
    );
  }
}
