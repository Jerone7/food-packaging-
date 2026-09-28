import 'package:flutter/material.dart';
import '../../../../models/material_catalog_model.dart';
import '../../../../theme/app_theme.dart';
import 'mini_radar_thumbnail.dart';

/// Interactive material card with 12-property overview, mini radar chart, and comparison selection.
class PackagingMaterialCard extends StatefulWidget {
  final PackagingMaterialDetail material;
  final bool isSelectedForComparison;
  final VoidCallback onInspect;
  final ValueChanged<bool> onToggleComparison;

  const PackagingMaterialCard({
    super.key,
    required this.material,
    required this.isSelectedForComparison,
    required this.onInspect,
    required this.onToggleComparison,
  });

  @override
  State<PackagingMaterialCard> createState() => _PackagingMaterialCardState();
}

class _PackagingMaterialCardState extends State<PackagingMaterialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final mat = widget.material;
    final ecoScore = mat.environmentalProfile.sustainabilityScore;
    final isSelected = widget.isSelectedForComparison;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryTeal
                : (_isHovered ? AppTheme.mintAccent.withValues(alpha: 0.6) : AppTheme.borderSubtle),
            width: isSelected ? 2.0 : (_isHovered ? 1.5 : 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                  : (_isHovered ? Colors.black.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03)),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onInspect,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Category Pill, Comparison Checkbox, & Eco-Score
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildCategoryBadge(mat.category),
                          _buildPolymerPill(mat.polymerFamily),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Comparison Selection Checkbox
                    InkWell(
                      onTap: () => widget.onToggleComparison(!isSelected),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryTeal.withValues(alpha: 0.12) : AppTheme.bgOffWhite,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                              size: 15,
                              color: isSelected ? AppTheme.primaryTeal : AppTheme.slateBody,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Compare',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppTheme.primaryTeal : AppTheme.slateBody,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Material Name & Structure
                Text(
                  mat.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slateDark,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mat.structure,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.slateBody.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),

                // Center Content: Key Metrics and Mini Radar Canvas
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Quantitative Metrics Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetricRow(
                            icon: Icons.air,
                            label: 'OTR',
                            value: '${mat.barrierProfile.otrCcM2Day < 0.1 ? '<0.1' : mat.barrierProfile.otrCcM2Day.toStringAsFixed(1)} cc',
                            subValue: 'cc/m²/day',
                            color: const Color(0xFF0284C7),
                          ),
                          const SizedBox(height: 6),
                          _buildMetricRow(
                            icon: Icons.water_drop_outlined,
                            label: 'WVTR',
                            value: '${mat.barrierProfile.wvtrGM2Day < 0.1 ? '<0.1' : mat.barrierProfile.wvtrGM2Day.toStringAsFixed(1)} g',
                            subValue: 'g/m²/day',
                            color: const Color(0xFF0D9488),
                          ),
                          const SizedBox(height: 6),
                          _buildMetricRow(
                            icon: Icons.currency_rupee,
                            label: 'Unit Cost',
                            value: '₹${mat.economicProfile.estimatedUnitCostInr.toStringAsFixed(2)}',
                            subValue: '/pack',
                            color: const Color(0xFFD97706),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Mini Radar Canvas & Eco Badge
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MiniRadarThumbnail(
                          radarScores: mat.radarScores,
                          size: 64,
                        ),
                        const SizedBox(height: 4),
                        _buildEcoBadge(ecoScore),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Environmental & Functional Chips
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (mat.environmentalProfile.isBiodegradable)
                      _buildFeatureTag('🌱 Biodegradable', const Color(0xFF059669), const Color(0xFFD1FAE5)),
                    if (mat.environmentalProfile.isRecyclable)
                      _buildFeatureTag('♻️ Recyclable', const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
                    if (mat.thermalProfile.isRetortGrade)
                      _buildFeatureTag('🔥 Retort 121°C', const Color(0xFFE11D48), const Color(0xFFFFE4E6)),
                    if (mat.thermalProfile.isCryogenicGrade)
                      _buildFeatureTag('❄️ Cryo', const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
                    if (mat.barrierProfile.gasFlushCompatible)
                      _buildFeatureTag('💨 MAP Ready', const Color(0xFF0D9488), const Color(0xFFCCFBF1)),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Footer
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppTheme.borderSubtle, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Gauge: ${mat.barrierProfile.thicknessMicrons.toStringAsFixed(0)} µm',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.slateBody,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Inspect Specs',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _isHovered ? AppTheme.mintAccent : AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: _isHovered ? AppTheme.mintAccent : AppTheme.primaryTeal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);

    if (category.toLowerCase().contains('biodegradable')) {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
    } else if (category.toLowerCase().contains('laminate') || category.toLowerCase().contains('barrier')) {
      bg = const Color(0xFFE0F2FE);
      text = const Color(0xFF0369A1);
    } else if (category.toLowerCase().contains('cellulosic') || category.toLowerCase().contains('board')) {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
    } else if (category.toLowerCase().contains('glass') || category.toLowerCase().contains('metal')) {
      bg = const Color(0xFFF3E8FF);
      text = const Color(0xFF7E22CE);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildPolymerPill(String family) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.bgOffWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Text(
        family,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.slateBody,
        ),
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: AppTheme.slateBody,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.slateDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEcoBadge(double score) {
    Color bg = const Color(0xFFD1FAE5);
    Color text = const Color(0xFF059669);
    if (score < 40) {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
    } else if (score < 75) {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌿 ', style: TextStyle(fontSize: 9)),
          Text(
            '${score.toStringAsFixed(0)}/100',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTag(String text, Color fgColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }
}
