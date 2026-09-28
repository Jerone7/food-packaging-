import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Advantages and Limitations Card (Module 5 Main Result Page).
/// Displays preservation advantages (green checkmarks) alongside
/// operational and engineering limitations (amber warnings) to provide
/// a balanced, objective, explainable recommendation.
class AdvantagesAndLimitationsCard extends StatelessWidget {
  final List<String> advantages;
  final List<String> limitations;

  const AdvantagesAndLimitationsCard({
    super.key,
    required this.advantages,
    required this.limitations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSideBySide = constraints.maxWidth >= 600;

        if (isSideBySide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSectionCard(
                  title: 'ADVANTAGES',
                  subtitle: 'Preservation & Operational Strengths',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppTheme.emeraldEco,
                  accentBgColor: const Color(0xFFF0FDF4),
                  accentBorderColor: const Color(0xFF86EFAC),
                  items: advantages,
                  emptyText: 'No specific advantages identified.',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildSectionCard(
                  title: 'LIMITATIONS',
                  subtitle: 'Operational & Engineering Boundaries',
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFD97706),
                  accentBgColor: const Color(0xFFFFFBEB),
                  accentBorderColor: const Color(0xFFFDE68A),
                  items: limitations,
                  emptyText: 'No specific operational limitations recorded.',
                ),
              ),
            ],
          );
        }

        // Stacked Layout for narrow/mobile screens
        return Column(
          children: [
            _buildSectionCard(
              title: 'ADVANTAGES',
              subtitle: 'Preservation & Operational Strengths',
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppTheme.emeraldEco,
              accentBgColor: const Color(0xFFF0FDF4),
              accentBorderColor: const Color(0xFF86EFAC),
              items: advantages,
              emptyText: 'No specific advantages identified.',
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              title: 'LIMITATIONS',
              subtitle: 'Operational & Engineering Boundaries',
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFD97706),
              accentBgColor: const Color(0xFFFFFBEB),
              accentBorderColor: const Color(0xFFFDE68A),
              items: limitations,
              emptyText: 'No specific operational limitations recorded.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color accentBgColor,
    required Color accentBorderColor,
    required List<String> items,
    required String emptyText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: accentBgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              border: Border(
                bottom: BorderSide(color: accentBorderColor.withValues(alpha: 0.8), width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppTheme.slateBody,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Item List
          Padding(
            padding: const EdgeInsets.all(16),
            child: items.isEmpty
                ? Text(
                    emptyText,
                    style: const TextStyle(
                      color: AppTheme.slateBody,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Column(
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                icon,
                                size: 16,
                                color: iconColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: AppTheme.slateDark,
                                  fontSize: 13,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
