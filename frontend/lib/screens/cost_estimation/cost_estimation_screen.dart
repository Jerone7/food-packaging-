import 'package:flutter/material.dart';
import '../../models/cost_estimation_model.dart';
import '../../services/offline_cost_engine.dart';
import '../../services/locale_service.dart';
import '../../theme/app_translations.dart';
import '../../widgets/navigation/language_selector_widget.dart';
import 'widgets/packaging_type_selector_grid.dart';
import 'widgets/package_dimension_inputs.dart';
import 'widgets/material_selector_dropdown.dart';
import 'widgets/addon_feature_checklist.dart';
import 'widgets/batch_volume_slider.dart';
import 'widgets/cost_summary_hero_card.dart';
import 'widgets/material_footprint_card.dart';
import 'widgets/cost_breakdown_chart.dart';
import 'widgets/volume_sensitivity_chart.dart';
import 'widgets/supplier_quote_disclaimer_banner.dart';

/// Master Interactive Screen for Packaging Cost & Material Requirement Estimation (Module 10).
class CostEstimationScreen extends StatefulWidget {
  final String? initialMaterialName;
  final String? initialFillQuantity;
  final PackagingFormFactor? initialPackagingType;
  final PackageDimensions? initialDimensions;

  const CostEstimationScreen({
    super.key,
    this.initialMaterialName,
    this.initialFillQuantity,
    this.initialPackagingType,
    this.initialDimensions,
  });

  @override
  State<CostEstimationScreen> createState() => _CostEstimationScreenState();
}

class _CostEstimationScreenState extends State<CostEstimationScreen> {
  late PackagingFormFactor _packagingType;
  late PackageDimensions _dimensions;
  late String _productFillQuantity;
  late String _selectedMaterial;
  double? _customMaterialCostPerKg;
  late List<FunctionalAddOn> _selectedAddons;
  int _numberOfPackages = 10000;
  final bool _includeToolingAmortization = true;
  final double _customScrapRatePercent = 6.0;

  late CostEstimationResponse _currentResponse;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _packagingType = widget.initialPackagingType ?? PackagingFormFactor.standUpDoypack;
    _dimensions = widget.initialDimensions ??
        const PackageDimensions(
          lengthCm: 20.0,
          widthCm: 14.0,
          depthOrGussetCm: 6.0,
          thicknessMicrons: 45.0,
        );
    _productFillQuantity = widget.initialFillQuantity ?? '500g';
    _selectedMaterial = widget.initialMaterialName ?? 'NatureFlex Regenerated Cellulose';
    _selectedAddons = [FunctionalAddOn.resealableZipper];

    _recalculateLocally();
  }

  void _recalculateLocally() {
    final request = CostEstimationRequest(
      materialName: _selectedMaterial,
      packagingType: _packagingType,
      dimensions: _dimensions,
      productFillQuantity: _productFillQuantity,
      numberOfPackages: _numberOfPackages,
      selectedAddons: _selectedAddons,
      customMaterialCostPerKg: _customMaterialCostPerKg,
      customScrapRatePercent: _customScrapRatePercent,
      includeToolingAmortization: _includeToolingAmortization,
    );

    setState(() {
      _currentResponse = OfflineCostEngine.calculateCostEstimate(request);
    });
  }

  void _showRfqModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.request_quote_outlined, color: Color(0xFF0D9488)),
            const SizedBox(width: 8),
            Text('cost.rfq_title'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A customized Request for Quote (RFQ) package has been generated for $_numberOfPackages units of $_selectedMaterial (${_packagingType.label}).',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Target Batch: $_numberOfPackages units ($_productFillQuantity pack)', style: const TextStyle(fontSize: 11)),
                  Text('• Film Required: ${_currentResponse.materialRequirement.grossWeightRequiredKg.toStringAsFixed(1)} kg (${_currentResponse.materialRequirement.grossAreaRequiredSqm.toStringAsFixed(0)} m²)', style: const TextStyle(fontSize: 11)),
                  Text('• Estimated Baseline Cost: ₹${_currentResponse.costPerUnitInr.toStringAsFixed(2)} / unit', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.close'.tr()),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('RFQ inquiry dispatched to verified packaging converters!'),
                  backgroundColor: Color(0xFF0D9488),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.send, size: 14),
            label: Text('cost.rfq_btn'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 900;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.payments_outlined, color: Color(0xFF0D9488), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'cost.title'.tr(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: LanguageSelectorWidget(mode: LanguageSelectorMode.compact),
                ),
              ),
            ],
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Disclaimer Banner
                SupplierQuoteDisclaimerBanner(
                  disclaimerNotice: _currentResponse.disclaimerNotice,
                  onRequestRfq: _showRfqModal,
                ),
                const SizedBox(height: 16),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Inputs (Flex 5)
                      Expanded(
                        flex: 5,
                        child: _buildInputsPanel(context),
                      ),
                      const SizedBox(width: 20),
                      // Right Column: Live Cost Cockpit (Flex 5)
                      Expanded(
                        flex: 5,
                        child: _buildCockpitPanel(context),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildInputsPanel(context),
                      const SizedBox(height: 20),
                      _buildCockpitPanel(context),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildInputsPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PackagingTypeSelectorGrid(
            selectedType: _packagingType,
            onTypeSelected: (type) {
              setState(() => _packagingType = type);
              _recalculateLocally();
            },
          ),
          const Divider(height: 24),
          PackageDimensionInputs(
            dimensions: _dimensions,
            productFillQuantity: _productFillQuantity,
            packagingType: _packagingType,
            onDimensionsChanged: (dims) {
              setState(() => _dimensions = dims);
              _recalculateLocally();
            },
            onFillQuantityChanged: (fill) {
              setState(() => _productFillQuantity = fill);
            },
          ),
          const Divider(height: 24),
          MaterialSelectorDropdown(
            selectedMaterial: _selectedMaterial,
            customPricePerKg: _customMaterialCostPerKg,
            onMaterialChanged: (mat) {
              setState(() => _selectedMaterial = mat);
              _recalculateLocally();
            },
            onCustomPriceChanged: (p) {
              setState(() => _customMaterialCostPerKg = p);
              _recalculateLocally();
            },
          ),
          const Divider(height: 24),
          AddOnFeatureChecklist(
            selectedAddons: _selectedAddons,
            onAddonsChanged: (addons) {
              setState(() => _selectedAddons = addons);
              _recalculateLocally();
            },
          ),
          const Divider(height: 24),
          BatchVolumeSlider(
            numberOfPackages: _numberOfPackages,
            onVolumeChanged: (vol) {
              setState(() => _numberOfPackages = vol);
              _recalculateLocally();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCockpitPanel(BuildContext context) {
    return Column(
      children: [
        CostSummaryHeroCard(response: _currentResponse),
        const SizedBox(height: 16),
        MaterialFootprintCard(
          materialRequirement: _currentResponse.materialRequirement,
          materialName: _selectedMaterial,
        ),
        const SizedBox(height: 16),
        CostBreakdownChart(
          costBreakdown: _currentResponse.costBreakdown,
          totalEstimatedCostInr: _currentResponse.totalEstimatedCostInr,
        ),
        const SizedBox(height: 16),
        VolumeSensitivityChart(
          volumeTierSensitivity: _currentResponse.volumeTierSensitivity,
          currentOrderVolume: _numberOfPackages,
          onSelectVolume: (vol) {
            setState(() => _numberOfPackages = vol);
            _recalculateLocally();
          },
        ),
      ],
    );
  }
}
