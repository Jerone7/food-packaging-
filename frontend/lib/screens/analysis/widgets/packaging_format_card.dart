import 'package:flutter/material.dart';
import '../../../models/packaging_model.dart';
import '../../../theme/app_theme.dart';

/// Packaging Format & Geometry Card (Module 5 Main Result Page).
/// Displays the specific structural packaging format (e.g. Micro-Perforated
/// Hinged Clamshell), 3D bounding geometry (L x W x H), space efficiency %,
/// and prescribed cushioning substrate.
class PackagingFormatCard extends StatelessWidget {
  final String packagingFormat;
  final BoxGeometrySpecs geometry;

  const PackagingFormatCard({
    super.key,
    required this.packagingFormat,
    required this.geometry,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PACKAGING FORMAT & GEOMETRY',
                        style: TextStyle(
                          color: AppTheme.slateDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Structural Format & 3D Volumetric Blueprint',
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

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Packaging Format Display Tile
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // Soft Blue
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.view_in_ar_rounded,
                        color: Color(0xFF1D4ED8),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CONTAINER FORMAT',
                              style: TextStyle(
                                color: Color(0xFF1E40AF),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              packagingFormat,
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 3D Dimensions Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDimTile('Length (L)', '${geometry.lengthCm.toStringAsFixed(1)} cm'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDimTile('Width (W)', '${geometry.widthCm.toStringAsFixed(1)} cm'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDimTile('Height (H)', '${geometry.heightCm.toStringAsFixed(1)} cm'),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Space Utilization & Cushioning Substrate
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Volumetric Space Efficiency',
                              style: TextStyle(
                                color: AppTheme.slateBody,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${geometry.spaceUtilizationPct.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppTheme.emeraldEco,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (geometry.spaceUtilizationPct / 100.0).clamp(0.0, 1.0),
                          backgroundColor: AppTheme.borderSubtle,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emeraldEco),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: AppTheme.primaryTeal,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Cushioning: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.slateDark,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              geometry.cushioningMaterial,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.slateBody,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildDimTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.slateBody,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.slateDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
