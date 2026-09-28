import 'package:flutter/material.dart';
import '../../../../models/material_catalog_model.dart';
import '../../../../theme/app_theme.dart';
import 'mini_radar_thumbnail.dart';

/// Interactive 4-Tab Material Technical Inspector Dialog.
class MaterialDetailModal extends StatefulWidget {
  final PackagingMaterialDetail material;

  const MaterialDetailModal({super.key, required this.material});

  static Future<void> show(BuildContext context, PackagingMaterialDetail material) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MaterialDetailModal(material: material),
    );
  }

  @override
  State<MaterialDetailModal> createState() => _MaterialDetailModalState();
}

class _MaterialDetailModalState extends State<MaterialDetailModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mat = widget.material;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: isDesktop ? 860 : screenWidth * 0.95,
        height: 640,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modal Top Header
            _buildModalHeader(context, mat),

            // Tab Bar Navigation
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryTeal,
                indicatorWeight: 3,
                labelColor: AppTheme.primaryTeal,
                unselectedLabelColor: AppTheme.slateBody,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline, size: 16), text: 'Structure & Overview'),
                  Tab(icon: Icon(Icons.speed_outlined, size: 16), text: 'Barrier & Mechanics'),
                  Tab(icon: Icon(Icons.eco_outlined, size: 16), text: 'Eco & Compliance'),
                  Tab(icon: Icon(Icons.restaurant_outlined, size: 16), text: 'Food Applications'),
                ],
              ),
            ),

            // Tab Views Content Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(mat),
                  _buildBarrierMechanicalTab(mat),
                  _buildEcoComplianceTab(mat),
                  _buildApplicationsTab(mat),
                ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Material ID: ${mat.materialId}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.slateBody, fontFamily: 'monospace'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Close Inspector', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context, PackagingMaterialDetail mat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.bgOffWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.layers, size: 28, color: AppTheme.primaryTeal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        mat.category,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🌿 Eco-Score: ${mat.environmentalProfile.sustainabilityScore.toStringAsFixed(0)}/100',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mat.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                ),
                Text(
                  mat.structure,
                  style: TextStyle(fontSize: 12, color: AppTheme.slateBody.withValues(alpha: 0.9), fontStyle: FontStyle.italic),
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
    );
  }

  Widget _buildOverviewTab(PackagingMaterialDetail mat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 6-Axis Radar Performance Breakdown
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgOffWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '6-Axis Performance Radar',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.slateDark),
                      ),
                      const SizedBox(height: 12),
                      MiniRadarThumbnail(radarScores: mat.radarScores, size: 130),
                      const SizedBox(height: 12),
                      _buildRadarScoreRow('Gas Barrier', mat.radarScores.barrierScore, const Color(0xFF0284C7)),
                      _buildRadarScoreRow('Mechanical Toughness', mat.radarScores.mechanicalScore, const Color(0xFF6366F1)),
                      _buildRadarScoreRow('Sustainability', mat.radarScores.sustainabilityScore, const Color(0xFF059669)),
                      _buildRadarScoreRow('Thermal Range', mat.radarScores.thermalScore, const Color(0xFFDC2626)),
                      _buildRadarScoreRow('Cost Efficiency', mat.radarScores.costEfficiencyScore, const Color(0xFFD97706)),
                      _buildRadarScoreRow('Optical Clarity/Shield', mat.radarScores.opticalScore, const Color(0xFF8B5CF6)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Overview Spec Fields
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildDataCard('Polymer Family', mat.polymerFamily, Icons.grain),
                    _buildDataCard('Form Factor', mat.formFactor, Icons.crop_free),
                    _buildDataCard('Gauge Thickness', '${mat.barrierProfile.thicknessMicrons} µm', Icons.straighten),
                    _buildDataCard('Optical Clarity', mat.opticalProfile.opticalClarity, Icons.remove_red_eye_outlined),
                    _buildDataCard('Light Barrier Rating', mat.opticalProfile.lightBarrierRating, Icons.wb_sunny_outlined),
                    _buildDataCard('Cost Tier & Unit Price', '${mat.economicProfile.costCategory} • ₹${mat.economicProfile.estimatedUnitCostInr.toStringAsFixed(2)}', Icons.payments_outlined),
                  ],
                ),
              ),
            ],
          ),
          if (mat.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mat.notes,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF166534), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarrierMechanicalTab(PackagingMaterialDetail mat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gas & Moisture Permeation Vectors',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMetricTile('Oxygen Permeation (OTR)', '${mat.barrierProfile.otrCcM2Day} cc/m²/day', 'At 23°C, 0% RH', const Color(0xFF0284C7))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Water Vapor (WVTR)', '${mat.barrierProfile.wvtrGM2Day} g/m²/day', 'At 38°C, 90% RH', const Color(0xFF0D9488))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMetricTile('CO₂ Permeability', mat.barrierProfile.co2Permeability != null ? '${mat.barrierProfile.co2Permeability} cc/m²/day' : 'N/A', 'Carbon Dioxide Permeation', const Color(0xFF6366F1))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Selectivity (β = CO₂/O₂)', mat.barrierProfile.selectivityBeta != null ? mat.barrierProfile.selectivityBeta!.toStringAsFixed(1) : 'Standard ~4.0', 'EMAP Dynamic Respiration', const Color(0xFF8B5CF6))),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Mechanical & Thermal Resilience',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMetricTile('Tensile Strength', '${mat.mechanicalProfile.tensileStrengthMpa} MPa', 'ASTM D882 Yield Strength', const Color(0xFFD97706))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Puncture Resistance', '${mat.mechanicalProfile.punctureResistanceN} N', 'ASTM F1306 Penetration', const Color(0xFFEA580C))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildMetricTile('Elongation at Break', '${mat.mechanicalProfile.elongationPct}%', 'Flexibility / Stretch Index', const Color(0xFF059669))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Operating Temp Span', '${mat.thermalProfile.tempMinC}°C to ${mat.thermalProfile.tempMaxC}°C', mat.thermalProfile.thermalClass, const Color(0xFFDC2626))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEcoComplianceTab(PackagingMaterialDetail mat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricTile('Sustainability Eco-Score', '${mat.environmentalProfile.sustainabilityScore.toStringAsFixed(0)} / 100', 'Empirical Circularity Index', const Color(0xFF059669))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Recyclability Score', '${mat.environmentalProfile.recyclabilityScore.toStringAsFixed(0)} / 100', 'RIC Code: ${mat.environmentalProfile.resinCode}', const Color(0xFF0284C7))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricTile('Biodegradability Score', '${mat.environmentalProfile.biodegradabilityScore.toStringAsFixed(0)} / 100', mat.environmentalProfile.compostingStandard ?? 'Non-compostable', const Color(0xFF10B981))),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Market Scalability', mat.economicProfile.marketScalability, 'Supply Chain Readiness', const Color(0xFFD97706))),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Food Safety & Regulatory Certifications',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 10),
          if (mat.regulatoryCertifications.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mat.regulatoryCertifications.map((cert) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 14, color: Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      Text(cert, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            const Text('FSSAI IS 9845 & FDA 21 CFR Compliant', style: TextStyle(fontSize: 12, color: AppTheme.slateBody)),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab(PackagingMaterialDetail mat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Food Commodities',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 10),
          if (mat.recommendedApplications.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mat.recommendedApplications.map((app) {
                return Chip(
                  avatar: const CircleAvatar(
                    backgroundColor: AppTheme.primaryTeal,
                    child: Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                  label: Text(app, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  backgroundColor: AppTheme.bgOffWhite,
                  side: const BorderSide(color: AppTheme.borderSubtle),
                );
              }).toList(),
            )
          else
            const Text('Suitable for dry grocery and general ambient food commodities.'),
          const SizedBox(height: 20),
          const Text(
            'Atmosphere & Functional Compatibility',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 10),
          _buildFunctionalRow('Nitrogen / MAP Gas Flush Compatible', mat.barrierProfile.gasFlushCompatible),
          _buildFunctionalRow('Autoclave Retort Sterilization Ready (121°C)', mat.thermalProfile.isRetortGrade),
          _buildFunctionalRow('Cryogenic Sub-Zero Resistance (-30°C)', mat.thermalProfile.isCryogenicGrade),
          _buildFunctionalRow('Naturally Biodegradable / Compostable', mat.environmentalProfile.isBiodegradable),
          _buildFunctionalRow('Curbside Mechanically Recyclable', mat.environmentalProfile.isRecyclable),
        ],
      ),
    );
  }

  Widget _buildDataCard(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgOffWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryTeal),
            const SizedBox(width: 8),
            Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.slateBody, fontWeight: FontWeight.w500)),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 12, color: AppTheme.slateDark, fontWeight: FontWeight.w700),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgOffWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11.5, color: AppTheme.slateBody, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 10.5, color: AppTheme.slateBody.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildRadarScoreRow(String name, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 11, color: AppTheme.slateBody)),
          Text(
            '${score.toStringAsFixed(0)}/100',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionalRow(String label, bool isSupported) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isSupported ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: isSupported ? const Color(0xFF059669) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSupported ? FontWeight.w600 : FontWeight.w400,
              color: isSupported ? AppTheme.slateDark : AppTheme.slateBody,
            ),
          ),
        ],
      ),
    );
  }
}
