import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/material_catalog_model.dart';
import '../../../../theme/app_theme.dart';

/// Overlapping multi-material 6-axis spider radar canvas.
class Comparative6AxisRadarChart extends StatelessWidget {
  final List<PackagingMaterialDetail> materials;
  final Map<String, MaterialRadarScores> radarDatasets;
  final double size;

  static const List<Color> palette = [
    Color(0xFF0F766E), // Teal
    Color(0xFF0284C7), // Sky Blue
    Color(0xFFD97706), // Amber
    Color(0xFFE11D48), // Rose
  ];

  const Comparative6AxisRadarChart({
    super.key,
    required this.materials,
    required this.radarDatasets,
    this.size = 280.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _ComparativeRadarPainter(
              materials: materials,
              radarDatasets: radarDatasets,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: materials.asMap().entries.map((entry) {
            final idx = entry.key;
            final mat = entry.value;
            final color = palette[idx % palette.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  mat.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ComparativeRadarPainter extends CustomPainter {
  final List<PackagingMaterialDetail> materials;
  final Map<String, MaterialRadarScores> radarDatasets;

  static const List<String> axisLabels = [
    'Barrier (OTR/WVTR)',
    'Mechanical Toughness',
    'Circularity & Eco',
    'Thermal Resilience',
    'Procurement Cost',
    'Optics & Shield',
  ];

  static const List<Color> palette = [
    Color(0xFF0F766E),
    Color(0xFF0284C7),
    Color(0xFFD97706),
    Color(0xFFE11D48),
  ];

  _ComparativeRadarPainter({
    required this.materials,
    required this.radarDatasets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.70;

    final gridPaint = Paint()
      ..color = AppTheme.borderSubtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = AppTheme.borderSubtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const int numAxes = 6;
    const angleStep = (2 * math.pi) / numAxes;

    // 1. Concentric Web Rings (25%, 50%, 75%, 100%)
    for (final factor in [0.25, 0.50, 0.75, 1.0]) {
      final ringPath = Path();
      for (int i = 0; i < numAxes; i++) {
        final angle = (i * angleStep) - (math.pi / 2);
        final x = center.dx + (radius * factor * math.cos(angle));
        final y = center.dy + (radius * factor * math.sin(angle));
        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // 2. Radial Axes & Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < numAxes; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final x = center.dx + (radius * math.cos(angle));
      final y = center.dy + (radius * math.sin(angle));
      canvas.drawLine(center, Offset(x, y), axisPaint);

      // Label positioning
      final labelRadius = radius + 22.0;
      final lx = center.dx + (labelRadius * math.cos(angle));
      final ly = center.dy + (labelRadius * math.sin(angle));

      textPainter.text = TextSpan(
        text: axisLabels[i],
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.slateBody),
      );
      textPainter.layout(maxWidth: 100);
      textPainter.paint(
        canvas,
        Offset(lx - (textPainter.width / 2), ly - (textPainter.height / 2)),
      );
    }

    // 3. Draw Overlapping Material Polygons
    for (int mIdx = 0; mIdx < materials.length; mIdx++) {
      final mat = materials[mIdx];
      final scores = radarDatasets[mat.materialId] ?? mat.radarScores;
      final color = palette[mIdx % palette.length];

      final values = [
        scores.barrierScore / 100.0,
        scores.mechanicalScore / 100.0,
        scores.sustainabilityScore / 100.0,
        scores.thermalScore / 100.0,
        scores.costEfficiencyScore / 100.0,
        scores.opticalScore / 100.0,
      ];

      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.20)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final pointOffsets = <Offset>[];

      for (int i = 0; i < numAxes; i++) {
        final angle = (i * angleStep) - (math.pi / 2);
        final val = values[i].clamp(0.05, 1.0);
        final x = center.dx + (radius * val * math.cos(angle));
        final y = center.dy + (radius * val * math.sin(angle));
        final pt = Offset(x, y);
        pointOffsets.add(pt);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);

      // Vertex dots
      final dotPaint = Paint()..color = color;
      for (final pt in pointOffsets) {
        canvas.drawCircle(pt, 3.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ComparativeRadarPainter oldDelegate) {
    return oldDelegate.materials != materials || oldDelegate.radarDatasets != radarDatasets;
  }
}
