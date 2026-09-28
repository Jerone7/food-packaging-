import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/packaging_comparison_model.dart';

/// Multi-material comparative 6-axis radar visualization widget.
class ComparativeRadarView extends StatelessWidget {
  final List<MaterialComparisonSlot> slots;
  final double size;

  const ComparativeRadarView({
    super.key,
    required this.slots,
    this.size = 280.0,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.radar_rounded,
                size: 18,
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Comparative Multi-Axis Radar',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartSize = math.min(constraints.maxWidth, size);
              return SizedBox(
                width: chartSize,
                height: chartSize,
                child: CustomPaint(
                  painter: _ComparativeRadarPainter(
                    slots: slots,
                    isDark: isDark,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: slots.map((slot) {
              return Container(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: slot.colorToken,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${slot.slotLabel}: ${slot.name}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ComparativeRadarPainter extends CustomPainter {
  final List<MaterialComparisonSlot> slots;
  final bool isDark;

  static const List<String> axisLabels = [
    'Moisture Barrier',
    'Oxygen Barrier',
    'Gas Exchange',
    'Strength',
    'Recyclability',
    'Cost Efficiency',
  ];

  _ComparativeRadarPainter({
    required this.slots,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.5;
    const numAxes = 6;
    const angleStep = (2 * math.pi) / numAxes;

    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Draw concentric polygons (25%, 50%, 75%, 100%)
    for (int ring = 1; ring <= 4; ring++) {
      final ringRadius = (radius / 4) * ring;
      final path = Path();
      for (int i = 0; i < numAxes; i++) {
        final angle = i * angleStep - (math.pi / 2);
        final x = center.dx + ringRadius * math.cos(angle);
        final y = center.dy + ringRadius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 2. Draw axis spokes and labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < numAxes; i++) {
      final angle = i * angleStep - (math.pi / 2);
      final spokeEnd = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, spokeEnd, axisPaint);

      // Label positioning
      final labelRadius = radius + 18;
      final labelPos = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      textPainter.text = TextSpan(
        text: axisLabels[i],
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        labelPos.dx - (textPainter.width / 2),
        labelPos.dy - (textPainter.height / 2),
      );
      textPainter.paint(canvas, textOffset);
    }

    // 3. Draw Polygons for each slot
    for (final slot in slots) {
      final scores = _computeSlotAxisScores(slot);
      final path = Path();

      for (int i = 0; i < numAxes; i++) {
        final normalizedScore = (scores[i] / 100.0).clamp(0.1, 1.0);
        final angle = i * angleStep - (math.pi / 2);
        final x = center.dx + (radius * normalizedScore) * math.cos(angle);
        final y = center.dy + (radius * normalizedScore) * math.sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      // Fill
      final fillPaint = Paint()
        ..color = slot.colorToken.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      // Stroke
      final strokePaint = Paint()
        ..color = slot.colorToken
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, strokePaint);

      // Dots on vertices
      final dotPaint = Paint()
        ..color = slot.colorToken
        ..style = PaintingStyle.fill;

      for (int i = 0; i < numAxes; i++) {
        final normalizedScore = (scores[i] / 100.0).clamp(0.1, 1.0);
        final angle = i * angleStep - (math.pi / 2);
        final pt = Offset(
          center.dx + (radius * normalizedScore) * math.cos(angle),
          center.dy + (radius * normalizedScore) * math.sin(angle),
        );
        canvas.drawCircle(pt, 3.5, dotPaint);
      }
    }
  }

  List<double> _computeSlotAxisScores(MaterialComparisonSlot slot) {
    // 0: Moisture, 1: Oxygen, 2: Gas Exchange, 3: Strength, 4: Recyclability, 5: Cost Efficiency
    double scoreMoisture = slot.moistureBarrier == 'High' || slot.moistureBarrier == 'Hermetic'
        ? 95.0
        : (slot.moistureBarrier == 'Medium' ? 65.0 : 30.0);

    double scoreOxygen = slot.oxygenBarrier == 'High' || slot.oxygenBarrier == 'Hermetic'
        ? 95.0
        : (slot.oxygenBarrier == 'Medium' ? 65.0 : 30.0);

    double scoreGas = slot.gasExchange == 'High' || slot.gasExchange == 'Controlled'
        ? 90.0
        : (slot.gasExchange == 'Medium' ? 60.0 : 30.0);

    double scoreStrength = slot.strength == 'High' || slot.strength == 'Rigid'
        ? 90.0
        : (slot.strength == 'Medium' ? 65.0 : 35.0);

    double scoreRecyclability = slot.recyclability == 'Biodegradable' || slot.recyclability == 'Home Compostable'
        ? 95.0
        : (slot.recyclability == 'Yes' ? 85.0 : 25.0);

    double scoreCost = slot.costCategory == 'Low'
        ? 95.0
        : (slot.costCategory == 'Medium' ? 70.0 : (slot.costCategory == 'High' ? 45.0 : 30.0));

    return [scoreMoisture, scoreOxygen, scoreGas, scoreStrength, scoreRecyclability, scoreCost];
  }

  @override
  bool shouldRepaint(covariant _ComparativeRadarPainter oldDelegate) {
    return oldDelegate.slots != slots || oldDelegate.isDark != isDark;
  }
}
