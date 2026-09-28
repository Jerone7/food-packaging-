import 'package:flutter/material.dart';
import '../../../models/sustainability_model.dart';
import 'sustainability_metric_pill.dart';

/// Hero Card rendering the 3 core pillars of sustainability:
/// Recyclability, Biodegradability, and Reusability with Material Type & Feedstock.
class SustainabilityProfileHeroCard extends StatelessWidget {
  final SustainabilityProfile profile;

  const SustainabilityProfileHeroCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF022C22)] // Emerald dark gradient
              : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)], // Emerald soft light
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and RIC Code
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final iconWidget = Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Color(0xFF10B981),
                  size: 26,
                ),
              );

              final textInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.materialName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF064E3B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );

              final ricPill = SustainabilityMetricPill(
                label: profile.resinIdentificationCode,
                color: const Color(0xFF0284C7),
                icon: Icons.qr_code_2_rounded,
                fontSize: 11,
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        iconWidget,
                        const SizedBox(width: 12),
                        Expanded(child: textInfo),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ricPill,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconWidget,
                  const SizedBox(width: 12),
                  Expanded(child: textInfo),
                  const SizedBox(width: 8),
                  ricPill,
                ],
              );
            },
          ),

          const SizedBox(height: 18),
          Divider(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 18),

          // 3-Pillars Summary Matrix (Recyclability, Biodegradability, Reusability)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 420;

              final pillar1 = _buildPillarTile(
                context,
                title: 'Recyclability',
                tier: profile.recyclability.label,
                color: profile.recyclability.color,
                icon: profile.recyclability.icon,
                subtitle: profile.recyclabilityNotes,
                emoji: '♻️',
              );

              final pillar2 = _buildPillarTile(
                context,
                title: 'Biodegradability',
                tier: profile.biodegradability.label,
                color: profile.biodegradability.color,
                icon: profile.biodegradability.icon,
                subtitle: profile.biodegradabilityStandard ?? profile.biodegradabilityNotes,
                emoji: '🌱',
              );

              final pillar3 = _buildPillarTile(
                context,
                title: 'Reusability',
                tier: profile.reusability.label,
                color: profile.reusability.color,
                icon: profile.reusability.icon,
                subtitle: '${profile.reusabilityCycles} cycles capacity',
                emoji: '🔄',
              );

              if (isNarrow) {
                return Column(
                  children: [
                    pillar1,
                    const SizedBox(height: 10),
                    pillar2,
                    const SizedBox(height: 10),
                    pillar3,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: pillar1),
                  const SizedBox(width: 10),
                  Expanded(child: pillar2),
                  const SizedBox(width: 10),
                  Expanded(child: pillar3),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Material Feedstock & Type Description Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Material Feedstock & Composition',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.materialTypeDescription,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarTile(
    BuildContext context, {
    required String title,
    required String tier,
    required Color color,
    required IconData icon,
    required String subtitle,
    required String emoji,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SustainabilityMetricPill(
            label: tier,
            color: color,
            icon: icon,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              height: 1.3,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
