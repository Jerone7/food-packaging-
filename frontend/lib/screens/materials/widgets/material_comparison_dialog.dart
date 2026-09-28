import 'package:flutter/material.dart';
import '../../../../models/material_catalog_model.dart';
import '../../../../theme/app_theme.dart';
import 'comparative_radar_chart.dart';

/// Full-featured multi-material side-by-side comparative inspection dialog.
class MaterialComparisonDialog extends StatelessWidget {
  final MaterialComparisonResult comparisonResult;

  const MaterialComparisonDialog({super.key, required this.comparisonResult});

  static Future<void> show(BuildContext context, MaterialComparisonResult result) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MaterialComparisonDialog(comparisonResult: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final materials = comparisonResult.materials;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: isDesktop ? 1000 : screenWidth * 0.95,
        height: 700,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modal Top Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.bgOffWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.compare_arrows, size: 24, color: AppTheme.primaryTeal),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multi-Material Side-by-Side Comparison (${materials.length} Materials)',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Comprehensive 6-Axis Radar & 12-Property Quantitative Vector Evaluation',
                          style: TextStyle(fontSize: 12, color: AppTheme.slateBody),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.slateBody),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Main Comparison Scroll Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Radar Chart on left, Best-in-Class Highlights on right
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildRadarCard(materials),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHighlightsSection(),
                                const SizedBox(height: 16),
                                _buildTradeOffSection(),
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildRadarCard(materials),
                      const SizedBox(height: 16),
                      _buildHighlightsSection(),
                      const SizedBox(height: 16),
                      _buildTradeOffSection(),
                    ],

                    const SizedBox(height: 24),
                    const Text(
                      'Quantitative 12-Property Vector Matrix',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                    ),
                    const SizedBox(height: 12),

                    // Property Comparison Matrix Table
                    _buildMatrixTable(materials),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.bgOffWhite,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarCard(List<PackagingMaterialDetail> materials) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgOffWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          const Text(
            'Overlapping Performance Spider Radar',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 14),
          Comparative6AxisRadarChart(
            materials: materials,
            radarDatasets: comparisonResult.radarDatasets,
            size: 260,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection() {
    final highlights = comparisonResult.bestInClassHighlights;
    if (highlights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events_outlined, size: 18, color: Color(0xFF16A34A)),
              SizedBox(width: 8),
              Text(
                'Best-in-Class Highlights',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...highlights.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTradeOffSection() {
    final tradeOffs = comparisonResult.tradeOffAnalysis;
    if (tradeOffs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, size: 18, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Text(
                'Trade-Off & Engineering Insights',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0369A1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tradeOffs.map((t) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      t,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF0C4A6E), height: 1.35),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMatrixTable(List<PackagingMaterialDetail> materials) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.bgOffWhite),
          columnSpacing: 24,
          columns: [
            const DataColumn(label: Text('Property / Vector', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
            ...materials.map((m) => DataColumn(
                  label: Text(
                    m.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.primaryTeal),
                  ),
                )),
          ],
          rows: [
            _buildMatrixRow('Domain Category', materials, (m) => m.category),
            _buildMatrixRow('Structure Specification', materials, (m) => m.structure),
            _buildMatrixRow('Nominal Gauge', materials, (m) => '${m.barrierProfile.thicknessMicrons.toStringAsFixed(0)} µm'),
            _buildMatrixRow('OTR (cc/m²/day @ 23°C)', materials, (m) => m.barrierProfile.otrCcM2Day < 0.1 ? '<0.1' : m.barrierProfile.otrCcM2Day.toStringAsFixed(1)),
            _buildMatrixRow('WVTR (g/m²/day @ 38°C)', materials, (m) => m.barrierProfile.wvtrGM2Day < 0.1 ? '<0.1' : m.barrierProfile.wvtrGM2Day.toStringAsFixed(1)),
            _buildMatrixRow('Tensile Strength (MPa)', materials, (m) => '${m.mechanicalProfile.tensileStrengthMpa.toStringAsFixed(0)} MPa'),
            _buildMatrixRow('Puncture Resistance (N)', materials, (m) => '${m.mechanicalProfile.punctureResistanceN.toStringAsFixed(0)} N'),
            _buildMatrixRow('Thermal Range', materials, (m) => '${m.thermalProfile.tempMinC}° to ${m.thermalProfile.tempMaxC}°C'),
            _buildMatrixRow('Sustainability Eco-Score', materials, (m) => '${m.environmentalProfile.sustainabilityScore.toStringAsFixed(0)} / 100'),
            _buildMatrixRow('Recyclability / RIC', materials, (m) => m.environmentalProfile.isRecyclable ? 'Yes (${m.environmentalProfile.resinCode})' : 'No'),
            _buildMatrixRow('Biodegradable', materials, (m) => m.environmentalProfile.isBiodegradable ? 'Yes (EN 13432)' : 'No'),
            _buildMatrixRow('Retort Ready (121°C)', materials, (m) => m.thermalProfile.isRetortGrade ? 'Yes (Autoclave)' : 'No'),
            _buildMatrixRow('Unit Cost in INR', materials, (m) => '₹${m.economicProfile.estimatedUnitCostInr.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  DataRow _buildMatrixRow(String propertyName, List<PackagingMaterialDetail> materials, String Function(PackagingMaterialDetail) extractor) {
    return DataRow(
      cells: [
        DataCell(Text(propertyName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.slateDark))),
        ...materials.map((m) => DataCell(Text(extractor(m), style: const TextStyle(fontSize: 12, color: AppTheme.slateBody)))),
      ],
    );
  }
}
