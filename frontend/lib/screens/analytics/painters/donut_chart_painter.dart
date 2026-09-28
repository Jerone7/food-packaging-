import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/analytics_model.dart';

/// Custom Painter for interactive Donut Chart rendering polymer recommendation distribution.
class DonutChartPainter extends CustomPainter {
  final List<PackagingDistributionItemModel> items;
  final int? selectedIndex;
  final double strokeWidth;
  final double gapAngleRadians;

  DonutChartPainter({
    required this.items,
    this.selectedIndex,
    this.strokeWidth = 22.0,
    this.gapAngleRadians = 0.03,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    if (radius <= 0) return;

    final totalVolume = items.fold<int>(0, (sum, it) => sum + it.recommendationCount);
    if (totalVolume == 0) return;

    final hasMultiple = items.length > 1;
    final totalGaps = hasMultiple ? items.length * gapAngleRadians : 0.0;
    final availableSweep = (2 * math.pi) - totalGaps;

    double startAngle = -math.pi / 2; // Start from 12 o'clock

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isSelected = selectedIndex == i;
      final sweepAngle = (item.recommendationCount / totalVolume) * availableSweep;

      if (sweepAngle > 0) {
        final currentStroke = isSelected ? strokeWidth + 6.0 : strokeWidth;
        final currentRadius = isSelected ? radius + 2.0 : radius;

        final paint = Paint()
          ..color = item.colorToken
          ..style = PaintingStyle.stroke
          ..strokeWidth = currentStroke
          ..strokeCap = StrokeCap.round;

        final rect = Rect.fromCircle(center: center, radius: currentRadius);
        canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      }

      startAngle += sweepAngle + (hasMultiple ? gapAngleRadians : 0.0);
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
