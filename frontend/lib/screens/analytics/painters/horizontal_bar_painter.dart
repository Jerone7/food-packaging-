import 'package:flutter/material.dart';

/// Custom Painter for animated horizontal volume bars with rounded caps and gradient fills.
class HorizontalBarPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 relative to maximum volume item
  final Color primaryColor;
  final Color secondaryColor;
  final Color trackColor;
  final double radius;

  HorizontalBarPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    this.trackColor = const Color(0xFFF1F5F9),
    this.radius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;

    final rRectTrack = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    canvas.drawRRect(rRectTrack, trackPaint);

    final fillWidth = (size.width * progress).clamp(0.0, size.width);
    if (fillWidth > 0) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, fillWidth, size.height))
        ..style = PaintingStyle.fill;

      final rRectFill = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        Radius.circular(radius),
      );
      canvas.drawRRect(rRectFill, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.trackColor != trackColor;
  }
}
