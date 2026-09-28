import 'package:flutter/material.dart';
import '../../../models/analytics_model.dart';
import '../../../theme/app_theme.dart';

/// Custom Painter for dual-spline area and stacked bar chart rendering monthly analysis trends.
class SplineAreaPainter extends CustomPainter {
  final List<MonthlyTrendDataPointModel> timeSeries;
  final int? selectedIndex;
  final double paddingBottom;
  final double paddingTop;
  final double paddingLeft;
  final double paddingRight;

  SplineAreaPainter({
    required this.timeSeries,
    this.selectedIndex,
    this.paddingBottom = 28.0,
    this.paddingTop = 18.0,
    this.paddingLeft = 32.0,
    this.paddingRight = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (timeSeries.isEmpty) return;

    final drawWidth = size.width - paddingLeft - paddingRight;
    final drawHeight = size.height - paddingTop - paddingBottom;
    if (drawWidth <= 0 || drawHeight <= 0) return;

    // Calculate max volume for Y scaling
    final maxVol = timeSeries
        .map((e) => e.totalAnalyses)
        .reduce((a, b) => a > b ? a : b);
    final yMax = (maxVol * 1.25).ceil().clamp(10, 99999);

    final count = timeSeries.length;
    final stepX = count > 1 ? drawWidth / (count - 1) : drawWidth;

    // Draw horizontal grid lines (3 lines)
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int g = 0; g <= 3; g++) {
      final y = paddingTop + (drawHeight * (1.0 - (g / 3.0)));
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );

      // Y-axis label text
      final val = ((yMax / 3.0) * g).round();
      final textSpan = TextSpan(
        text: '$val',
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 6, y - (textPainter.height / 2)),
      );
    }

    // Points coordinates
    final points = <Offset>[];
    for (int i = 0; i < count; i++) {
      final x = paddingLeft + (i * stepX);
      final yRatio = (timeSeries[i].totalAnalyses / yMax).clamp(0.0, 1.0);
      final y = paddingTop + (drawHeight * (1.0 - yRatio));
      points.add(Offset(x, y));
    }

    // 1. Draw Stacked Bars for Eco vs. Conventional
    final barWidth = (stepX * 0.45).clamp(8.0, 24.0);
    for (int i = 0; i < count; i++) {
      final pt = timeSeries[i];
      final x = paddingLeft + (i * stepX);

      final totalY = drawHeight * (pt.totalAnalyses / yMax);
      final ecoY = drawHeight * (pt.ecoFriendlyCount / yMax);
      final convY = drawHeight * (pt.conventionalCount / yMax);

      final baseY = paddingTop + drawHeight;

      // Conventional bottom segment
      if (convY > 0) {
        final convPaint = Paint()
          ..color = const Color(0xFFE2E8F0)
          ..style = PaintingStyle.fill;
        final convRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x - (barWidth / 2), baseY - convY, barWidth, convY),
          bottomLeft: const Radius.circular(3),
          bottomRight: const Radius.circular(3),
        );
        canvas.drawRRect(convRect, convPaint);
      }

      // Eco-friendly top segment
      if (ecoY > 0) {
        final ecoPaint = Paint()
          ..color = AppTheme.emeraldEco.withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        final ecoRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x - (barWidth / 2), baseY - convY - ecoY, barWidth, ecoY),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(ecoRect, ecoPaint);
      }

      // X-axis month label
      final monthLabel = pt.monthLabel.split(' ')[0]; // E.g. 'Jan'
      final labelSpan = TextSpan(
        text: monthLabel,
        style: TextStyle(
          fontSize: 10,
          color: selectedIndex == i ? AppTheme.primaryTeal : const Color(0xFF64748B),
          fontWeight: selectedIndex == i ? FontWeight.w700 : FontWeight.w500,
        ),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(x - (labelPainter.width / 2), size.height - paddingBottom + 8),
      );
    }

    // 2. Draw Smooth Bézier Spline Curve & Area Gradient
    if (points.length >= 2) {
      final path = Path();
      final areaPath = Path();

      path.moveTo(points[0].dx, points[0].dy);
      areaPath.moveTo(points[0].dx, paddingTop + drawHeight);
      areaPath.lineTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlX1 = p0.dx + ((p1.dx - p0.dx) / 2);
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + ((p1.dx - p0.dx) / 2);
        final controlY2 = p1.dy;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
        areaPath.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
      }

      areaPath.lineTo(points.last.dx, paddingTop + drawHeight);
      areaPath.close();

      // Area gradient fill
      final areaPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppTheme.primaryTeal.withValues(alpha: 0.18),
            AppTheme.primaryTeal.withValues(alpha: 0.01),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(paddingLeft, paddingTop, drawWidth, drawHeight))
        ..style = PaintingStyle.fill;
      canvas.drawPath(areaPath, areaPaint);

      // Spline line stroke
      final strokePaint = Paint()
        ..color = AppTheme.primaryTeal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, strokePaint);
    }

    // 3. Draw Point Dots and Active Scrub Line
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isSelected = selectedIndex == i;

      if (isSelected) {
        // Vertical cursor line
        final linePaint = Paint()
          ..color = AppTheme.primaryTeal.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawLine(
          Offset(pt.dx, paddingTop),
          Offset(pt.dx, paddingTop + drawHeight),
          linePaint,
        );

        // Highlight ring
        final ringPaint = Paint()
          ..color = AppTheme.primaryTeal.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 8, ringPaint);
      }

      // Point circle
      final dotPaint = Paint()
        ..color = isSelected ? AppTheme.primaryTeal : Colors.white
        ..style = PaintingStyle.fill;
      final dotBorder = Paint()
        ..color = AppTheme.primaryTeal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(pt, isSelected ? 4.5 : 3.5, dotPaint);
      canvas.drawCircle(pt, isSelected ? 4.5 : 3.5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant SplineAreaPainter oldDelegate) {
    return oldDelegate.timeSeries != timeSeries ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
