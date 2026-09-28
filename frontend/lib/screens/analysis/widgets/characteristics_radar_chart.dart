import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/food_scientific_profile.dart';
import '../../../services/food_analysis_normalizer.dart';
import '../../../widgets/modern_card.dart';

class CharacteristicsRadarChart extends StatefulWidget {
  final FoodScientificProfile profile;
  final bool animate;

  const CharacteristicsRadarChart({
    super.key,
    required this.profile,
    this.animate = true,
  });

  @override
  State<CharacteristicsRadarChart> createState() => _CharacteristicsRadarChartState();
}

class _CharacteristicsRadarChartState extends State<CharacteristicsRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  int? _selectedAxisIndex;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    if (widget.animate) {
      _animController.forward();
    } else {
      _animController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant CharacteristicsRadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.foodId != widget.profile.foodId ||
        oldWidget.profile.commodityName != widget.profile.commodityName) {
      if (widget.animate) {
        _animController.forward(from: 0.0);
      } else {
        _animController.value = 1.0;
      }
      setState(() {
        _selectedAxisIndex = null;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final axes = FoodAnalysisNormalizer.computeRadarAxes(widget.profile);
    final selectedAxis = _selectedAxisIndex != null && _selectedAxisIndex! < axes.length
        ? axes[_selectedAxisIndex!]
        : null;

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.radar_rounded,
                        size: 18,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Characteristics Radar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCCFBF1)),
                ),
                child: const Text(
                  '6-Axis Polygon',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Multi-dimensional biological footprint (0.0 - 1.0 normalized sensitivity):',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          // Radar Canvas Area
          LayoutBuilder(
            builder: (context, constraints) {
              final canvasWidth = math.min(constraints.maxWidth, 320.0);
              const canvasHeight = 260.0;

              return Center(
                child: SizedBox(
                  height: canvasHeight,
                  width: canvasWidth,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, _) {
                      return GestureDetector(
                        onTapDown: (details) {
                          _handleCanvasTap(details.localPosition, Size(canvasWidth, canvasHeight), axes.length);
                        },
                        child: CustomPaint(
                          size: Size(canvasWidth, canvasHeight),
                          painter: RadarChartPainter(
                            axes: axes,
                            progress: _animation.value,
                            selectedIndex: _selectedAxisIndex,
                            primaryColor: const Color(0xFF0F766E),
                            accentColor: const Color(0xFF14B8A6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Interactive HUD details card for selected or top axis
          if (selectedAxis != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selectedAxis.level.backgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selectedAxis.level.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(selectedAxis.icon, size: 20, color: selectedAxis.level.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              selectedAxis.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${selectedAxis.rawValue})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selectedAxis.level.color,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Normalized Score: ${(selectedAxis.score * 100).toStringAsFixed(0)}% • ${selectedAxis.level.label}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    color: const Color(0xFF64748B),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _selectedAxisIndex = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Dimension Chips Grid
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(axes.length, (index) {
              final axis = axes[index];
              final isSelected = _selectedAxisIndex == index;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedAxisIndex = isSelected ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        axis.icon,
                        size: 13,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        axis.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : axis.level.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _handleCanvasTap(Offset position, Size size, int axisCount) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final touchRadius = math.sqrt(dx * dx + dy * dy);

    if (touchRadius < 10) {
      setState(() {
        _selectedAxisIndex = null;
      });
      return;
    }

    // Calculate touch angle in radians normalized to [-pi/2, 3pi/2]
    var touchAngle = math.atan2(dy, dx);
    // Align with radar initial angle -pi/2
    var angleFromTop = touchAngle + math.pi / 2;
    if (angleFromTop < 0) angleFromTop += 2 * math.pi;

    final sectorAngle = 2 * math.pi / axisCount;
    final nearestIndex = ((angleFromTop + sectorAngle / 2) ~/ sectorAngle) % axisCount;

    setState(() {
      _selectedAxisIndex = _selectedAxisIndex == nearestIndex ? null : nearestIndex;
    });
  }
}

class RadarChartPainter extends CustomPainter {
  final List<RadarAxisData> axes;
  final double progress;
  final int? selectedIndex;
  final Color primaryColor;
  final Color accentColor;

  RadarChartPainter({
    required this.axes,
    required this.progress,
    this.selectedIndex,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.36;
    final count = axes.length;
    final angleStep = 2 * math.pi / count;

    // 1. Paint Background Grid Rings (20%, 40%, 60%, 80%, 100%)
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final outerGridPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int ring = 1; ring <= 5; ring++) {
      final ringRadius = maxRadius * (ring / 5.0);
      final ringPath = Path();

      for (int i = 0; i < count; i++) {
        final angle = i * angleStep - math.pi / 2;
        final x = center.dx + ringRadius * math.cos(angle);
        final y = center.dy + ringRadius * math.sin(angle);

        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, ring == 5 ? outerGridPaint : gridPaint);
    }

    // 2. Paint Radial Spokes
    final spokePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < count; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + maxRadius * math.cos(angle);
      final y = center.dy + maxRadius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), spokePaint);
    }

    // 3. Paint Data Polygon
    final dataPath = Path();
    final dataPoints = <Offset>[];

    for (int i = 0; i < count; i++) {
      final angle = i * angleStep - math.pi / 2;
      final score = axes[i].score * progress;
      final r = maxRadius * score.clamp(0.05, 1.0);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      final point = Offset(x, y);
      dataPoints.add(point);

      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // Data Fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: 0.35),
          accentColor.withValues(alpha: 0.18),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(dataPath, fillPaint);

    // Data Stroke Outline
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(dataPath, strokePaint);

    // 4. Paint Vertices & Highlights
    for (int i = 0; i < dataPoints.length; i++) {
      final point = dataPoints[i];
      final isSelected = selectedIndex == i;
      final vertexColor = axes[i].level.color;

      // Glow halo on selected vertex
      if (isSelected) {
        final glowPaint = Paint()
          ..color = vertexColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 10.0, glowPaint);
      }

      // Outer Node Circle
      final nodeOuterPaint = Paint()
        ..color = isSelected ? vertexColor : primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, isSelected ? 5.5 : 4.0, nodeOuterPaint);

      // Inner White Pip
      final nodeInnerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, isSelected ? 2.5 : 1.5, nodeInnerPaint);
    }

    // 5. Paint Radial Text Labels
    for (int i = 0; i < count; i++) {
      final angle = i * angleStep - math.pi / 2;
      final labelRadius = maxRadius + 22.0;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final isSelected = selectedIndex == i;
      final textSpan = TextSpan(
        text: axes[i].label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? primaryColor : const Color(0xFF334155),
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final textOffset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.axes != axes;
  }
}
