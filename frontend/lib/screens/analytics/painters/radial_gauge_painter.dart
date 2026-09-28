import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/analytics_model.dart';

/// Custom Painter for multi-track radial gauge arcs visualizing category shares.
class RadialGaugePainter extends CustomPainter {
  final List<FoodCategoryDistributionItemModel> items;
  final int? selectedIndex;
  final double strokeWidth;

  RadialGaugePainter({
    required this.items,
    this.selectedIndex,
    this.strokeWidth = 10.0,
  });

  static const List<Color> _categoryPalette = [
    Color(0xFF0F766E), // Deep Teal (Fruits)
    Color(0xFF059669), // Emerald (Vegetables)
    Color(0xFFF59E0B), // Amber (Snacks)
    Color(0xFF6366F1), // Indigo (Dairy/Proteins)
    Color(0xFF8B5CF6), // Purple (Grains/Bakery)
    Color(0xFFEC4899), // Pink (Processed/RTE)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (math.min(size.width, size.height) / 2) - strokeWidth;
    if (maxRadius <= 0) return;

    final ringCount = math.min(items.length, _categoryPalette.length);
    final ringSpacing = (maxRadius - 20) / ringCount;

    for (int i = 0; i < ringCount; i++) {
      final item = items[i];
      final isSelected = selectedIndex == i;
      final radius = maxRadius - (i * ringSpacing);
      final color = _categoryPalette[i % _categoryPalette.length];
      final sweepRatio = (item.percentageShare / 100.0).clamp(0.05, 1.0);
      final sweepAngle = sweepRatio * 1.5 * math.pi; // 270 degree max sweep

      // Background track
      final trackPaint = Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, -math.pi * 1.25, 1.5 * math.pi, false, trackPaint);

      // Active fill arc
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 3.0 : strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, -math.pi * 1.25, sweepAngle, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadialGaugePainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
