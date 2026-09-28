import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/packaging_model.dart';
import '../../reports/recommendation_report_screen.dart';

/// Detailed 3-Section Technical Audit Inspector Modal.
class AuditDetailModal extends StatefulWidget {
  final PackagingRecord record;
  final VoidCallback? onReRun;

  const AuditDetailModal({
    super.key,
    required this.record,
    this.onReRun,
  });

  static Future<void> show(
    BuildContext context,
    PackagingRecord record, {
    VoidCallback? onReRun,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AuditDetailModal(
        record: record,
        onReRun: onReRun,
      ),
    );
  }

  @override
  State<AuditDetailModal> createState() => _AuditDetailModalState();
}

class _AuditDetailModalState extends State<AuditDetailModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyAuditDossier() {
    final r = widget.record;
    final auditJson = {
      'audit_id': r.id,
      'commodity': r.itemName,
      'timestamp': r.createdAt.toIso8601String(),
      'package_spec': {
        'type': r.recommendedBoxType,
        'dimensions': r.recommendedDimensions,
        'box_volume_cm3': r.boxVolumeCm3,
        'item_volume_cm3': r.itemVolumeCm3,
        'space_utilization_pct': r.spaceUtilizationPct,
        'cushioning_material': r.cushioningMaterial,
      },
      'commercial_and_sustainability': {
        'unit_cost_inr': r.estimatedCost,
        'sustainability_score': r.sustainabilityScore,
        'is_fragile': r.isFragile,
        'eco_priority': r.ecoFriendly,
      },
      'scientific_rationale': r.notes ?? 'Optimized preservation prescription.',
    };

    final formatted = const JsonEncoder.withIndent('  ').convert(auditJson);
    Clipboard.setData(ClipboardData(text: formatted));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Technical Audit Dossier copied to clipboard as JSON!'),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;

    return Dialog(
      backgroundColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_outlined, size: 22, color: AppTheme.primaryTeal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.itemName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.slateDark,
                          ),
                        ),
                        Text(
                          'Audit #${r.id} • ${DateFormat.yMMMd().add_jm().format(r.createdAt)}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.slateBody),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18, color: AppTheme.primaryTeal),
                    tooltip: 'Copy JSON Audit Dossier',
                    onPressed: _copyAuditDossier,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppTheme.slateBody),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Navigation Bar
            Container(
              color: AppTheme.bgOffWhite,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryTeal,
                unselectedLabelColor: AppTheme.slateBody,
                indicatorColor: AppTheme.primaryTeal,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(icon: Icon(Icons.inventory_2_outlined, size: 16), text: 'Blueprint & Geometry'),
                  Tab(icon: Icon(Icons.shield_outlined, size: 16), text: 'Preservation & Eco'),
                  Tab(icon: Icon(Icons.psychology_outlined, size: 16), text: 'Scientific Rationale'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeometryTab(r),
                  _buildPreservationTab(r),
                  _buildRationaleTab(r),
                ],
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _copyAuditDossier,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.slateDark,
                          side: const BorderSide(color: AppTheme.borderSubtle),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.copy_all, size: 16),
                        label: const Text('Export JSON', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RecommendationReportScreen(
                                reportId: r.id.toString(),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryTeal,
                          side: const BorderSide(color: AppTheme.primaryTeal),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: const Text('Full Report 📄', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close', style: TextStyle(color: AppTheme.slateBody)),
                      ),
                      const SizedBox(width: 8),
                      if (widget.onReRun != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onReRun!();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Load in Analysis', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeometryTab(PackagingRecord r) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PHYSICAL SPECIFICATION & BOX DESIGN'),
          const SizedBox(height: 12),
          _buildSpecGrid([
            _SpecItem('Recommended Package', r.recommendedBoxType),
            _SpecItem('External Dimensions', r.recommendedDimensions),
            _SpecItem('Unit Weight', '${r.weight.toStringAsFixed(2)} kg'),
            _SpecItem('Box Volume', '${r.boxVolumeCm3.toStringAsFixed(0)} cm³'),
            _SpecItem('Item Volume', '${r.itemVolumeCm3.toStringAsFixed(0)} cm³'),
            _SpecItem('Space Utilization', '${r.spaceUtilizationPct.toStringAsFixed(1)}%'),
          ]),
          const SizedBox(height: 16),
          _buildSectionHeader('CUSHIONING & CARRIER PROTECTION'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgOffWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers_outlined, size: 24, color: AppTheme.primaryTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.cushioningMaterial.isNotEmpty ? r.cushioningMaterial : 'Standard Paper Padding',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.slateDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        r.isFragile
                            ? 'Fragile commodity protocol activated: High-damping secondary protection.'
                            : 'Standard shock absorption rating for general logistics.',
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.slateBody),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreservationTab(PackagingRecord r) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('COMMERCIAL & CIRCULARITY METRICS'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricHighlight(
                  label: 'ESTIMATED UNIT COST',
                  value: '₹${r.estimatedCost.toStringAsFixed(2)}',
                  sub: 'per package unit',
                  color: const Color(0xFFD97706),
                  icon: Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricHighlight(
                  label: 'SUSTAINABILITY SCORE',
                  value: '${r.sustainabilityScore.toStringAsFixed(0)} / 100',
                  sub: r.ecoFriendly ? 'Eco-Optimized' : 'Standard Substrate',
                  color: const Color(0xFF059669),
                  icon: Icons.eco_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('PRESERVATION CRITERIA'),
          const SizedBox(height: 10),
          _buildSpecGrid([
            _SpecItem('Fragility Classification', r.isFragile ? 'Fragile (Bruise Prone)' : 'Standard Rigid'),
            _SpecItem('Environmental Target', r.ecoFriendly ? 'Zero-Plastic / Compostable' : 'Cost-Optimized Industrial'),
            _SpecItem('Handling Directive', r.isFragile ? 'Keep Upright / Anti-Crush' : 'Standard Freight Stacking'),
            _SpecItem('Audit Status', 'Verified Engineering Prescription'),
          ]),
        ],
      ),
    );
  }

  Widget _buildRationaleTab(PackagingRecord r) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('EXPLAINABLE AI SCIENTIFIC RATIONALE (XAI)'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.science_outlined, size: 22, color: Color(0xFF059669)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    r.notes != null && r.notes!.isNotEmpty
                        ? r.notes!
                        : 'Packaging recommendation generated via TOPSIS multi-criteria optimization balancing barrier integrity, mechanical damping, and sustainability.',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF166534),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('KEY BIOCHEMICAL DRIVERS & GOVERNING EQUATIONS'),
          const SizedBox(height: 10),
          _buildRationaleBullet('Barrier Regulation', 'Calculated to maintain equilibrium headspace and prevent transpiration or oxidation.'),
          _buildRationaleBullet('Structural Cushioning', 'Calibrated to exceed deceleration forces during drop, vibration, and multi-tier pallet compression.'),
          _buildRationaleBullet('Circular Life Cycle', 'Optimized for post-consumer recyclability or industrial composting compliance.'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppTheme.slateBody,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildSpecGrid(List<_SpecItem> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgOffWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        children: items.map((item) {
          return SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: const TextStyle(fontSize: 11, color: AppTheme.slateBody)),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricHighlight({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.slateBody)),
        ],
      ),
    );
  }

  Widget _buildRationaleBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.arrow_right, size: 18, color: AppTheme.primaryTeal),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12.5, color: AppTheme.slateDark, height: 1.35),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecItem {
  final String label;
  final String value;
  _SpecItem(this.label, this.value);
}
