import 'package:flutter/material.dart';
import '../../../models/sustainability_model.dart';
import 'sustainability_metric_pill.dart';

/// Card rendering environmental considerations, microplastics warnings, and regulatory certifications.
class EnvironmentalConsiderationsCard extends StatelessWidget {
  final SustainabilityProfile profile;

  const EnvironmentalConsiderationsCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified_user_outlined, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Environmental Considerations & Certifications',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Environmental Considerations Bullet Points
          if (profile.environmentalConsiderations.isNotEmpty) ...[
            Text(
              'Eco & Disposal Guidance',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
              ),
            ),
            const SizedBox(height: 8),
            ...profile.environmentalConsiderations.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
          ],

          // Regulatory Certifications Badges
          if (profile.regulatoryCertifications.isNotEmpty) ...[
            Text(
              'Food Contact & Standards Certifications',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey[300] : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: profile.regulatoryCertifications.map((cert) {
                return SustainabilityMetricPill(
                  label: cert,
                  color: const Color(0xFF0284C7),
                  icon: Icons.check_circle_outline_rounded,
                  fontSize: 11,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
