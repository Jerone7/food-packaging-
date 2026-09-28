import 'package:flutter/material.dart';
import '../../../models/packaging_model.dart';
import '../../../theme/app_theme.dart';

/// Important Properties Card (Module 5 Main Result Page).
/// Displays quantitative barrier, thermal, and mechanical properties of the
/// recommended packaging substrate (OTR, WVTR, Thickness, Tensile Strength,
/// Puncture Resistance, Thermal Span).
class ImportantPropertiesCard extends StatelessWidget {
  final Map<String, String> importantProperties;
  final BarrierProfile? barrierProfile;

  const ImportantPropertiesCard({
    super.key,
    required this.importantProperties,
    this.barrierProfile,
  });

  @override
  Widget build(BuildContext context) {
    // Harmonize properties from map or barrierProfile fallback
    final properties = Map<String, String>.from(importantProperties);
    if (properties.isEmpty && barrierProfile != null) {
      properties['OTR (Oxygen Barrier)'] = barrierProfile!.otr;
      properties['WVTR (Moisture Barrier)'] = barrierProfile!.wvtr;
      properties['Film Thickness'] = '${barrierProfile!.thicknessMicrons.toStringAsFixed(1)} µm';
      properties['Tensile Strength'] = '${barrierProfile!.tensileStrengthMpa.toStringAsFixed(1)} MPa';
      properties['Puncture Resistance'] = '${barrierProfile!.punctureResistanceN.toStringAsFixed(1)} N';
      properties['Thermal Span'] = '0°C to 45°C';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppTheme.primaryTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IMPORTANT PROPERTIES',
                        style: TextStyle(
                          color: AppTheme.slateDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Barrier, Mechanical & Thermal Performance',
                        style: TextStyle(
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

          const Divider(height: 1, thickness: 1, color: AppTheme.borderSubtle),

          // Properties Grid / List
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTwoColumn = constraints.maxWidth >= 380;
                final items = properties.entries.toList();

                if (isTwoColumn) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: items.map((entry) {
                      return SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: _buildPropertyTile(entry.key, entry.value),
                      );
                    }).toList(),
                  );
                }

                return Column(
                  children: items.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildPropertyTile(entry.key, entry.value),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTile(String title, String value) {
    final meta = _getPropertyMeta(title);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: meta.tintColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: meta.tintColor.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(meta.icon, size: 18, color: meta.tintColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.slateBody,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.slateDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _PropertyMeta _getPropertyMeta(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('otr') || lower.contains('oxygen') || lower.contains('gas')) {
      return const _PropertyMeta(
        icon: Icons.air_rounded,
        tintColor: Color(0xFF0284C7), // Sky Blue
      );
    }
    if (lower.contains('wvtr') || lower.contains('moisture') || lower.contains('water')) {
      return const _PropertyMeta(
        icon: Icons.water_drop_outlined,
        tintColor: Color(0xFF0D9488), // Teal
      );
    }
    if (lower.contains('thickness') || lower.contains('gauge')) {
      return const _PropertyMeta(
        icon: Icons.layers_outlined,
        tintColor: Color(0xFF7C3AED), // Violet
      );
    }
    if (lower.contains('tensile') || lower.contains('strength')) {
      return const _PropertyMeta(
        icon: Icons.fitness_center_rounded,
        tintColor: Color(0xFFD97706), // Amber
      );
    }
    if (lower.contains('puncture') || lower.contains('tear')) {
      return const _PropertyMeta(
        icon: Icons.shield_outlined,
        tintColor: Color(0xFFDC2626), // Red
      );
    }
    if (lower.contains('thermal') || lower.contains('temp')) {
      return const _PropertyMeta(
        icon: Icons.thermostat_outlined,
        tintColor: Color(0xFFEA580C), // Orange
      );
    }

    return const _PropertyMeta(
      icon: Icons.speed_rounded,
      tintColor: AppTheme.primaryTeal,
    );
  }
}

class _PropertyMeta {
  final IconData icon;
  final Color tintColor;

  const _PropertyMeta({
    required this.icon,
    required this.tintColor,
  });
}
