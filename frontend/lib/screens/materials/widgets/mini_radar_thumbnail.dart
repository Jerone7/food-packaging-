import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/material_catalog_model.dart';
import '../../../../theme/app_theme.dart';

/// Compact, elegant 6-axis radar chart thumbnail canvas.
class MiniRadarThumbnail extends StatelessWidget {
  final MaterialRadarScores radarScores;
  final double size;
  final Color? fillColor;
  final Color? strokeColor;

  const MiniRadarThumbnail({
    super.key,
    required this.radarScores,
    this.size = 64.0,
    this.fillColor,
    this.strokeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MiniRadarPainter(
          radarScores: radarScores,
          fillColor: fillColor ?? AppTheme.primaryTeal.withValues(alpha: 0.25),
          strokeColor: strokeColor ?? AppTheme.primaryTeal,
        ),
      ),
    );
  }
}

class _MiniRadarPainter extends CustomPainter {
  final MaterialRadarScores radarScores;
  final Color fillColor;
  final Color strokeColor;

  _MiniRadarPainter({
    required this.radarScores,
    required this.fillColor,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.85;

    final gridPaint = Paint()
      ..color = AppTheme.borderSubtle.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = AppTheme.borderSubtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final values = [
      radarScores.barrierScore / 100.0,
      radarScores.mechanicalScore / 100.0,
      radarScores.sustainabilityScore / 100.0,
      radarScores.thermalScore / 100.0,
      radarScores.costEfficiencyScore / 100.0,
      radarScores.opticalScore / 100.0,
    ];

    const int numAxes = 6;
    const angleStep = (2 * math.pi) / numAxes;

    // Draw background concentric polygon rings (50% and 100%)
    for (final factor in [0.5, 1.0]) {
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

    // Draw radial axes
    for (int i = 0; i < numAxes; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final x = center.dx + (radius * math.cos(angle));
      final y = center.dy + (radius * math.sin(angle));
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }

    // Draw data polygon
    final dataPath = Path();
    for (int i = 0; i < numAxes; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final val = values[i].clamp(0.05, 1.0);
      final x = center.dx + (radius * val * math.cos(angle));
      final y = center.dy + (radius * val * math.sin(angle));
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniRadarPainter oldDelegate) {
    return oldDelegate.radarScores != radarScores ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor;
  }
}
