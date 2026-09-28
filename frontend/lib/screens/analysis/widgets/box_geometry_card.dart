import 'package:flutter/material.dart';
import '../../../models/packaging_model.dart';
import '../../../theme/app_theme.dart';

/// Volumetric Box Geometry & Cushioning Card (Module 5).
/// Displays 3D outer package dimensions (L x W x H), total volume,
/// volumetric space utilization %, and tailored eco-friendly cushioning prescriptions.
class BoxGeometryCard extends StatelessWidget {
  final BoxGeometrySpecs geometry;

  const BoxGeometryCard({
    super.key,
    required this.geometry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.mintAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppTheme.primaryTeal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'VOLUMETRIC BOX GEOMETRY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.slateDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dimensions Grid
          Row(
            children: [
              Expanded(
                child: _buildDimensionPill('Length (L)', '${geometry.lengthCm.toStringAsFixed(1)} cm'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDimensionPill('Width (W)', '${geometry.widthCm.toStringAsFixed(1)} cm'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDimensionPill('Height (H)', '${geometry.heightCm.toStringAsFixed(1)} cm'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Volume & Utilization Progress
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
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
                        'Space Utilization Efficiency',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.slateBody,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${geometry.spaceUtilizationPct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (geometry.spaceUtilizationPct / 100.0).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gross Box Volume: ${geometry.totalVolumeCm3.toStringAsFixed(0)} cm³',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.slateBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Cushioning Directive
          const Text(
            'RECOMMENDED CUSHIONING MATRIX',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppTheme.slateBody,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.emeraldLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 15,
                  color: AppTheme.emeraldEco,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    geometry.cushioningMaterial,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.emeraldEco,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.slateBody,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.slateDark,
            ),
          ),
        ],
      ),
    );
  }
}
