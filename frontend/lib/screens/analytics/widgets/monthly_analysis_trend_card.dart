import 'package:flutter/material.dart';
import '../../../models/analytics_model.dart';
import '../../../theme/app_theme.dart';
import '../painters/spline_area_painter.dart';

/// Chart 4: Monthly Analysis Count & Eco-Adoption Card (Module 17).
/// Displays 12-month dual-spline area and stacked bar trajectory.
class MonthlyAnalysisTrendCard extends StatefulWidget {
  final MonthlyTrendResponseModel data;
  final bool isLoading;
  final ValueChanged<MonthlyTrendDataPointModel>? onMonthSelected;

  const MonthlyAnalysisTrendCard({
    super.key,
    required this.data,
    this.isLoading = false,
    this.onMonthSelected,
  });

  @override
  State<MonthlyAnalysisTrendCard> createState() => _MonthlyAnalysisTrendCardState();
}

class _MonthlyAnalysisTrendCardState extends State<MonthlyAnalysisTrendCard> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final series = widget.data.timeSeries;
    final hoveredPoint = (_hoveredIndex != null && _hoveredIndex! < series.length)
        ? series[_hoveredIndex!]
        : (series.isNotEmpty ? series.last : null);

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isWide = headerConstraints.maxWidth > 420;
              final iconAndTitle = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.show_chart_rounded,
                      size: 20,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monthly Analysis Count',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.slateDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '12-Month evaluation velocity & sustainability trajectory',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.slateBody.withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final badge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${widget.data.overallGrowthPct}% Overall Growth',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.emeraldEco,
                  ),
                ),
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: iconAndTitle),
                    const SizedBox(width: 8),
                    badge,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconAndTitle,
                    const SizedBox(height: 10),
                    badge,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppTheme.borderSubtle),
          const SizedBox(height: 14),

          // Active Month Detail Pill
          if (hoveredPoint != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 14, color: AppTheme.primaryTeal),
                      const SizedBox(width: 6),
                      Text(
                        hoveredPoint.monthLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.slateDark,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Total: ${hoveredPoint.totalAnalyses}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
                      ),
                      Text(
                        'Eco: ${hoveredPoint.ecoFriendlyCount} (${hoveredPoint.ecoSharePct}%)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.emeraldEco),
                      ),
                      Text(
                        'MoM: ${hoveredPoint.momGrowthPct >= 0 ? '+' : ''}${hoveredPoint.momGrowthPct}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: hoveredPoint.momGrowthPct >= 0 ? AppTheme.emeraldEco : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Chart Canvas
          if (widget.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (series.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No historical time-series data available',
                  style: TextStyle(fontSize: 13, color: AppTheme.slateBody),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const height = 220.0;

                return GestureDetector(
                  onTapDown: (details) => _handlePointerPosition(details.localPosition.dx, width, series.length),
                  onHorizontalDragUpdate: (details) => _handlePointerPosition(details.localPosition.dx, width, series.length),
                  child: MouseRegion(
                    onHover: (event) => _handlePointerPosition(event.localPosition.dx, width, series.length),
                    onExit: (_) => setState(() => _hoveredIndex = null),
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: CustomPaint(
                        size: Size(width, height),
                        painter: SplineAreaPainter(
                          timeSeries: series,
                          selectedIndex: _hoveredIndex,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.borderSubtle),
          const SizedBox(height: 12),

          // Bottom Legend & KPI Summary Row
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildLegendItem('Total Trend', AppTheme.primaryTeal, isLine: true),
              _buildLegendItem('Eco-Friendly', AppTheme.emeraldEco),
              _buildLegendItem('Conventional', const Color(0xFFCBD5E1)),
              Text(
                'Total Volume: ${widget.data.totalPeriodVolume}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateBody),
              ),
              Text(
                'Avg: ${widget.data.avgMonthlyAnalyses}/mo',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateBody),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePointerPosition(double localX, double totalWidth, int count) {
    if (count <= 1) return;
    const paddingLeft = 32.0;
    const paddingRight = 16.0;
    final drawWidth = totalWidth - paddingLeft - paddingRight;
    if (drawWidth <= 0) return;

    final stepX = drawWidth / (count - 1);
    final relativeX = (localX - paddingLeft).clamp(0.0, drawWidth);
    final index = (relativeX / stepX).round().clamp(0, count - 1);

    if (_hoveredIndex != index) {
      setState(() => _hoveredIndex = index);
      widget.onMonthSelected?.call(widget.data.timeSeries[index]);
    }
  }

  Widget _buildLegendItem(String label, Color color, {bool isLine = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLine)
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.slateBody,
          ),
        ),
      ],
    );
  }
}
