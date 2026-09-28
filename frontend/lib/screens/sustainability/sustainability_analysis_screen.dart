import 'package:flutter/material.dart';
import '../../models/sustainability_model.dart';
import '../../services/api_service.dart';
import '../../services/offline_sustainability_engine.dart';
import '../../services/locale_service.dart';
import '../../theme/app_translations.dart';
import '../../widgets/navigation/language_selector_widget.dart';
import 'widgets/sustainability_metric_pill.dart';
import 'widgets/sustainability_profile_hero_card.dart';
import 'widgets/lca_carbon_water_card.dart';
import 'widgets/packaging_waste_potential_card.dart';
import 'widgets/environmental_considerations_card.dart';
import 'widgets/verified_data_citation_banner.dart';
import 'widgets/sustainability_comparison_matrix.dart';

/// Master screen for Module 11: Sustainability Analysis (`11. 🌱 Sustainability Analysis`).
/// Provides real-time parametric LCA evaluation, 3-pillar profiles, and multi-material benchmarks.
class SustainabilityAnalysisScreen extends StatefulWidget {
  final String? initialMaterialId;
  final String? initialMaterialName;
  final String? foodCommodityName;
  final String? initialPackageType;
  final int initialBatchSize;

  const SustainabilityAnalysisScreen({
    super.key,
    this.initialMaterialId,
    this.initialMaterialName,
    this.foodCommodityName,
    this.initialPackageType,
    this.initialBatchSize = 10000,
  });

  @override
  State<SustainabilityAnalysisScreen> createState() => _SustainabilityAnalysisScreenState();
}

class _SustainabilityAnalysisScreenState extends State<SustainabilityAnalysisScreen> {
  late String _selectedMaterialId;
  String _packageType = 'Stand-up Doypack (Bottom Gusset)';
  double _lengthCm = 18.0;
  double _widthCm = 12.0;
  double _depthOrGussetCm = 4.0;
  double _thicknessMicrons = 50.0;
  int _batchSize = 10000;
  double _pcrPercentage = 0.0;

  SustainabilityProfile? _profile;
  SustainabilityCompareResult? _compareResult;
  final bool _isLoading = false;

  final List<Map<String, String>> _availableMaterials = [
    {'id': 'mat_poly_ldpe_01', 'name': 'LDPE Flexible Film (RIC 4)'},
    {'id': 'mat_poly_hdpe_02', 'name': 'HDPE Rigid / Liner (RIC 2)'},
    {'id': 'mat_bopp_film_03', 'name': 'BOPP Monomaterial Film (RIC 5)'},
    {'id': 'mat_pet_bo_04', 'name': 'BOPET Virgin Polyester (RIC 1)'},
    {'id': 'mat_rpet_50_05', 'name': '50% Post-Consumer rPET (RIC 1)'},
    {'id': 'mat_bio_emap_01', 'name': 'PLA / PBAT Bio-Film (EN 13432)'},
    {'id': 'mat_cell_natureflex_02', 'name': 'NatureFlex™ Cellulosic (Home Compost)'},
    {'id': 'mat_lam_foil_06', 'name': 'PET / Al-Foil / PE Laminate'},
    {'id': 'mat_board_fsc_07', 'name': 'FSC Virgin Kraft Paperboard (PAP 21)'},
  ];

  final List<String> _formFactors = [
    'Stand-up Doypack (Bottom Gusset)',
    'Pillow Pouch',
    '3-Side Seal Pouch',
    '4-Side Quad Seal Pouch',
    'Thermoformed Tray / Clamshell',
    'Vacuum Bag',
    'Folding Carton Box',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMaterialId = widget.initialMaterialId ??
        (widget.initialMaterialName != null
            ? _resolveIdFromName(widget.initialMaterialName!)
            : 'mat_poly_ldpe_01');
    if (widget.initialPackageType != null) {
      _packageType = widget.initialPackageType!;
    }
    _batchSize = widget.initialBatchSize;

    _recalculate();
  }

  String _resolveIdFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('natureflex') || lower.contains('cellulose')) return 'mat_cell_natureflex_02';
    if (lower.contains('pla') || lower.contains('bio') || lower.contains('compost')) return 'mat_bio_emap_01';
    if (lower.contains('rpet') || lower.contains('recycled')) return 'mat_rpet_50_05';
    if (lower.contains('hdpe')) return 'mat_poly_hdpe_02';
    if (lower.contains('bopp') || lower.contains('pp')) return 'mat_bopp_film_03';
    if (lower.contains('pet')) return 'mat_pet_bo_04';
    if (lower.contains('foil') || lower.contains('aluminium')) return 'mat_lam_foil_06';
    if (lower.contains('paper') || lower.contains('kraft') || lower.contains('board')) return 'mat_board_fsc_07';
    return 'mat_poly_ldpe_01';
  }

  void _recalculate() {
    // 1. Compute immediately with offline engine for zero UI stutter
    final input = SustainabilityEvaluateInput(
      materialId: _selectedMaterialId,
      packageType: _packageType,
      lengthCm: _lengthCm,
      widthCm: _widthCm,
      depthOrGussetCm: _depthOrGussetCm,
      thicknessMicrons: _thicknessMicrons,
      batchSizeUnits: _batchSize,
      pcrPercentage: _pcrPercentage,
    );

    final localProfile = OfflineSustainabilityEngine.evaluate(input);

    // 3-way comparative benchmark with eco-friendly & circular alternatives
    final compareIds = <String>[
      _selectedMaterialId,
      if (_selectedMaterialId != 'mat_bio_emap_01') 'mat_bio_emap_01',
      if (_selectedMaterialId != 'mat_rpet_50_05') 'mat_rpet_50_05',
      if (_selectedMaterialId != 'mat_cell_natureflex_02' && _selectedMaterialId != 'mat_poly_ldpe_01')
        'mat_poly_ldpe_01'
      else if (_selectedMaterialId != 'mat_board_fsc_07')
        'mat_board_fsc_07',
    ].take(3).toList();

    final localCompare = OfflineSustainabilityEngine.compare(
      materialIds: compareIds,
      packageType: _packageType,
      lengthCm: _lengthCm,
      widthCm: _widthCm,
      depthOrGussetCm: _depthOrGussetCm,
      thicknessMicrons: _thicknessMicrons,
      batchSizeUnits: _batchSize,
    );

    setState(() {
      _profile = localProfile;
      _compareResult = localCompare;
    });

    // 2. Fetch fresh API response asynchronously in background
    ApiService.evaluateSustainability(input).then((remoteProfile) {
      if (mounted) {
        setState(() {
          _profile = remoteProfile;
        });
      }
    }).catchError((_) {
      // Retain offline calculation
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Row(
              children: [
                const Icon(Icons.eco_rounded, color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'sustainability.title'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Center(
                  child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
                ),
              ),
              if (MediaQuery.of(context).size.width >= 600)
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Center(
                    child: SustainabilityMetricPill(
                      label: 'Verified LCI Matrix',
                      color: Color(0xFF10B981),
                      icon: Icons.verified_rounded,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
      body: _profile == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                if (isDesktop) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1320),
                        child: Column(
                          children: [
                            if (widget.foodCommodityName != null) ...[
                              _buildFoodContextBanner(context),
                              const SizedBox(height: 16),
                            ],
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Configuration Panel (420px)
                                SizedBox(
                                  width: 420,
                                  child: _buildInputPanel(context),
                                ),
                                const SizedBox(width: 24),
                                // Right Output Cockpit
                                Expanded(
                                  child: _buildOutputCockpit(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // Mobile / Tablet Stacked Layout
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (widget.foodCommodityName != null) ...[
                        _buildFoodContextBanner(context),
                        const SizedBox(height: 14),
                      ],
                      _buildInputPanel(context),
                      const SizedBox(height: 20),
                      _buildOutputCockpit(context),
                    ],
                  ),
                );
              },
            ),
    );
      },
    );
  }

  Widget _buildFoodContextBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.fastfood_rounded, size: 18, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Analyzing Sustainability for: ${widget.foodCommodityName}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Material Selection
          Row(
            children: [
              const Icon(Icons.layers_rounded, size: 18, color: Color(0xFF10B981)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '1. Packaging Material Substrate',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMaterialId,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: _availableMaterials.map((mat) {
                  return DropdownMenuItem<String>(
                    value: mat['id'],
                    child: Text(
                      mat['name']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMaterialId = val;
                    });
                    _recalculate();
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Section 2: Form Factor & Dimensions
          Row(
            children: [
              const Icon(Icons.straighten_rounded, size: 18, color: Color(0xFF0284C7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '2. Package Geometry & Dimensions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _packageType,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: _formFactors.map((ff) {
                  return DropdownMenuItem<String>(
                    value: ff,
                    child: Text(
                      ff,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _packageType = val;
                    });
                    _recalculate();
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dimension Steppers (L, W, G, Gauge)
          Row(
            children: [
              Expanded(
                child: _buildNumberInput('Length', '${_lengthCm.toStringAsFixed(0)} cm', () {
                  if (_lengthCm > 5) {
                    setState(() => _lengthCm -= 1.0);
                    _recalculate();
                  }
                }, () {
                  setState(() => _lengthCm += 1.0);
                  _recalculate();
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNumberInput('Width', '${_widthCm.toStringAsFixed(0)} cm', () {
                  if (_widthCm > 5) {
                    setState(() => _widthCm -= 1.0);
                    _recalculate();
                  }
                }, () {
                  setState(() => _widthCm += 1.0);
                  _recalculate();
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildNumberInput('Gusset', '${_depthOrGussetCm.toStringAsFixed(0)} cm', () {
                  if (_depthOrGussetCm > 0) {
                    setState(() => _depthOrGussetCm -= 1.0);
                    _recalculate();
                  }
                }, () {
                  setState(() => _depthOrGussetCm += 1.0);
                  _recalculate();
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNumberInput('Gauge', '${_thicknessMicrons.toStringAsFixed(0)} µm', () {
                  if (_thicknessMicrons > 15) {
                    setState(() => _thicknessMicrons -= 5.0);
                    _recalculate();
                  }
                }, () {
                  setState(() => _thicknessMicrons += 5.0);
                  _recalculate();
                }),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Section 3: PCR Content Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.recycling_rounded, size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '3. Post-Consumer Recycled (PCR)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_pcrPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF10B981),
              inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF10B981),
              overlayColor: const Color(0xFF10B981).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _pcrPercentage,
              min: 0.0,
              max: 100.0,
              divisions: 20,
              onChanged: (val) {
                setState(() => _pcrPercentage = val);
                _recalculate();
              },
            ),
          ),

          const SizedBox(height: 12),

          // Section 4: Production Batch Size Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 18, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '4. Production Batch Size',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_batchSize >= 1000 ? "${(_batchSize / 1000).toStringAsFixed(0)}k" : _batchSize} units',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF8B5CF6),
              inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF8B5CF6),
              overlayColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _batchSize.toDouble(),
              min: 500.0,
              max: 100000.0,
              divisions: 99,
              onChanged: (val) {
                setState(() => _batchSize = val.toInt());
                _recalculate();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(String label, String value, VoidCallback onDec, VoidCallback onInc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              InkWell(
                onTap: onDec,
                child: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.grey),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              InkWell(
                onTap: onInc,
                child: const Icon(Icons.add_circle_outline, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputCockpit(BuildContext context) {
    final profile = _profile!;

    return Column(
      children: [
        // 1. Hero 3-Pillars Card
        SustainabilityProfileHeroCard(profile: profile),
        const SizedBox(height: 16),

        // 2. Life Cycle Assessment (LCA) Card
        LcaCarbonWaterCard(profile: profile, batchSize: _batchSize),
        const SizedBox(height: 16),

        // 3. Packaging Solid Waste Potential
        PackagingWastePotentialCard(wasteInfo: profile.wastePotential, batchSize: _batchSize),
        const SizedBox(height: 16),

        // 4. Multi-Material Side-by-Side Benchmark
        if (_compareResult != null) ...[
          SustainabilityComparisonMatrix(compareResult: _compareResult!),
          const SizedBox(height: 16),
        ],

        // 5. Environmental Considerations & Regulatory Certifications
        EnvironmentalConsiderationsCard(profile: profile),
        const SizedBox(height: 16),

        // 6. Scientific Data Citation Banner
        VerifiedDataCitationBanner(profile: profile),
      ],
    );
  }
}
