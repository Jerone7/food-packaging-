import 'package:flutter/material.dart';
import '../../../../models/material_catalog_model.dart';
import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';

/// Modal dialog for manually creating and registering custom packaging materials.
class AddPackagingMaterialDialog extends StatefulWidget {
  final ValueChanged<PackagingMaterialDetail> onMaterialCreated;

  const AddPackagingMaterialDialog({super.key, required this.onMaterialCreated});

  static Future<void> show(BuildContext context, ValueChanged<PackagingMaterialDetail> onCreated) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddPackagingMaterialDialog(onMaterialCreated: onCreated),
    );
  }

  @override
  State<AddPackagingMaterialDialog> createState() => _AddPackagingMaterialDialogState();
}

class _AddPackagingMaterialDialogState extends State<AddPackagingMaterialDialog> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameCtrl = TextEditingController();
  final _structureCtrl = TextEditingController();
  final _polymerFamilyCtrl = TextEditingController(text: 'BIO_POLYMER');
  final _thicknessCtrl = TextEditingController(text: '35.0');
  final _otrCtrl = TextEditingController(text: '2.5');
  final _wvtrCtrl = TextEditingController(text: '1.8');
  final _tensileCtrl = TextEditingController(text: '50.0');
  final _punctureCtrl = TextEditingController(text: '30.0');
  final _tempMinCtrl = TextEditingController(text: '-10.0');
  final _tempMaxCtrl = TextEditingController(text: '90.0');
  final _sustainabilityCtrl = TextEditingController(text: '92.0');
  final _costCtrl = TextEditingController(text: '3.50');
  final _appsCtrl = TextEditingController(text: 'Organic dry fruits, Spices, Teas');
  final _notesCtrl = TextEditingController();

  String _selectedCategory = 'Biodegradable Bio-Polymer';
  bool _isBiodegradable = true;
  bool _isRecyclable = true;
  bool _isRetort = false;
  bool _isCryogenic = false;
  bool _isGasFlush = true;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Biodegradable Bio-Polymer',
    'Conventional Polymer',
    'High-Barrier Laminate',
    'Cellulosic & Fiber Board',
    'Vacuum & Cryogenic',
    'Retort Barrier',
    'Rigid Inert Glass & Metal',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _structureCtrl.dispose();
    _polymerFamilyCtrl.dispose();
    _thicknessCtrl.dispose();
    _otrCtrl.dispose();
    _wvtrCtrl.dispose();
    _tensileCtrl.dispose();
    _punctureCtrl.dispose();
    _tempMinCtrl.dispose();
    _tempMaxCtrl.dispose();
    _sustainabilityCtrl.dispose();
    _costCtrl.dispose();
    _appsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final name = _nameCtrl.text.trim();
      final thickness = double.parse(_thicknessCtrl.text.trim());
      final otr = double.parse(_otrCtrl.text.trim());
      final wvtr = double.parse(_wvtrCtrl.text.trim());
      final tensile = double.parse(_tensileCtrl.text.trim());
      final puncture = double.parse(_punctureCtrl.text.trim());
      final tempMin = double.parse(_tempMinCtrl.text.trim());
      final tempMax = double.parse(_tempMaxCtrl.text.trim());
      final ecoScore = double.parse(_sustainabilityCtrl.text.trim());
      final cost = double.parse(_costCtrl.text.trim());

      final apps = _appsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final matId = 'mat_custom_${DateTime.now().millisecondsSinceEpoch}';

      // Derive initial radar scores
      final barrierScore = (100.0 - (otr * 1.5 + wvtr * 3.0)).clamp(10.0, 99.0);
      final mechScore = ((tensile / 150.0 + puncture / 100.0) * 50.0).clamp(10.0, 99.0);
      final thermalScore = (((tempMax - tempMin) / 160.0) * 100.0).clamp(20.0, 100.0);
      final costEfficiency = (100.0 - (cost * 9.0)).clamp(10.0, 98.0);

      final newMaterial = PackagingMaterialDetail(
        materialId: matId,
        name: name,
        category: _selectedCategory,
        polymerFamily: _polymerFamilyCtrl.text.trim().toUpperCase(),
        structure: _structureCtrl.text.trim().isNotEmpty ? _structureCtrl.text.trim() : '$thickness µm $_selectedCategory',
        formFactor: 'Custom Specification',
        barrierProfile: BarrierProfileDetail(
          otrCcM2Day: otr,
          wvtrGM2Day: wvtr,
          thicknessMicrons: thickness,
          barrierTier: otr <= 1.0 ? 'Ultra-High Barrier' : (otr <= 30.0 ? 'High Barrier' : 'Moderate Barrier'),
          gasFlushCompatible: _isGasFlush,
        ),
        mechanicalProfile: MechanicalProfile(
          tensileStrengthMpa: tensile,
          punctureResistanceN: puncture,
          formFactor: 'Custom Pouch / Film',
          durabilityRating: puncture >= 40.0 ? 'High' : 'Moderate',
        ),
        thermalProfile: ThermalProfile(
          tempMinC: tempMin,
          tempMaxC: tempMax,
          thermalClass: 'Engineered Thermal Range',
          isCryogenicGrade: _isCryogenic,
          isRetortGrade: _isRetort,
        ),
        opticalProfile: const OpticalProfile(
          opticalClarity: 'Translucent',
          lightBarrierRating: 'Moderate',
        ),
        environmentalProfile: EnvironmentalProfile(
          sustainabilityScore: ecoScore,
          recyclabilityScore: _isRecyclable ? 80.0 : 0.0,
          biodegradabilityScore: _isBiodegradable ? 90.0 : 0.0,
          isBiodegradable: _isBiodegradable,
          isRecyclable: _isRecyclable,
          resinCode: _isBiodegradable ? 'BIO_7' : 'OTHER_7',
          compostingStandard: _isBiodegradable ? 'EN 13432 / ASTM D6400' : null,
        ),
        economicProfile: EconomicProfile(
          costCategory: cost <= 2.5 ? 'Budget Economy' : (cost <= 4.5 ? 'Commercial Standard' : 'Premium Barrier'),
          estimatedUnitCostInr: cost,
          marketScalability: 'Commercial Custom',
        ),
        functionalFlags: {
          'is_breathable': false,
          'is_biodegradable': _isBiodegradable,
          'is_recyclable': _isRecyclable,
          'is_retort_grade': _isRetort,
          'is_cryogenic_grade': _isCryogenic,
          'gas_flush_compatible': _isGasFlush,
        },
        recommendedApplications: apps.isNotEmpty ? apps : ['Custom commodity packaging'],
        regulatoryCertifications: ['FSSAI Food Grade', 'FDA Compliant'],
        radarScores: MaterialRadarScores(
          barrierScore: barrierScore,
          mechanicalScore: mechScore,
          sustainabilityScore: ecoScore,
          thermalScore: thermalScore,
          costEfficiencyScore: costEfficiency,
          opticalScore: 65.0,
        ),
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : 'Registered custom packaging material specification.',
      );

      final created = await ApiService.createMaterial(newMaterial);
      widget.onMaterialCreated(created);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully registered "${created.name}" in database!'),
            backgroundColor: AppTheme.primaryTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registering material: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 750;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: isDesktop ? 750 : screenWidth * 0.95,
        height: 680,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modal Header
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
                    child: const Icon(Icons.add_box_outlined, size: 24, color: AppTheme.primaryTeal),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Register New Packaging Material',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.slateDark),
                        ),
                        Text(
                          'Add custom polymers, bio-laminates, and barrier substrates with full 12-property vectors',
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

            // Form Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Section
                      const Text(
                        '1. Material Identification & Layer Structure',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildTextField(_nameCtrl, 'Material Commercial Name', 'e.g. Bio-Nanocellulose Composite Film', required: true),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: _buildDropdown(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildTextField(_polymerFamilyCtrl, 'Polymer Family Code', 'e.g. PLA_PBAT, EVOH, PET', required: true),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 6,
                            child: _buildTextField(_structureCtrl, 'Layer Structure Specification', 'e.g. 15µm NatureFlex / 25µm PBAT'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Quantitative Barrier & Mechanics
                      const Text(
                        '2. Empirical Gas Barrier & Mechanical Strength',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_thicknessCtrl, 'Gauge (µm)', '35.0', isNumeric: true, required: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField(_otrCtrl, 'OTR (cc/m²/d)', '2.5', isNumeric: true, required: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField(_wvtrCtrl, 'WVTR (g/m²/d)', '1.8', isNumeric: true, required: true)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_tensileCtrl, 'Tensile (MPa)', '50.0', isNumeric: true, required: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField(_punctureCtrl, 'Puncture (N)', '30.0', isNumeric: true, required: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField(_tempMinCtrl, 'Min Temp (°C)', '-10.0', isNumeric: true, required: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField(_tempMaxCtrl, 'Max Temp (°C)', '90.0', isNumeric: true, required: true)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sustainability & Economics
                      const Text(
                        '3. Sustainability & Unit Economics',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_sustainabilityCtrl, 'Eco-Score (0-100)', '92.0', isNumeric: true, required: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField(_costCtrl, 'Unit Cost (INR ₹)', '3.50', isNumeric: true, required: true)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Environmental & Functional Toggles
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildCheckbox('🌱 Naturally Biodegradable', _isBiodegradable, (v) => setState(() => _isBiodegradable = v!)),
                          _buildCheckbox('♻️ Curbside Recyclable', _isRecyclable, (v) => setState(() => _isRecyclable = v!)),
                          _buildCheckbox('🔥 Retort Grade (121°C)', _isRetort, (v) => setState(() => _isRetort = v!)),
                          _buildCheckbox('❄️ Cryogenic (-30°C)', _isCryogenic, (v) => setState(() => _isCryogenic = v!)),
                          _buildCheckbox('💨 Gas Flush MAP Ready', _isGasFlush, (v) => setState(() => _isGasFlush = v!)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Applications & Notes
                      const Text(
                        '4. Food Compatibility & Notes',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(_appsCtrl, 'Recommended Food Applications (comma separated)', 'e.g. Dry fruits, Fresh berries, Spices'),
                      const SizedBox(height: 10),
                      _buildTextField(_notesCtrl, 'Engineering & Sealing Notes', 'e.g. Heat seal window 110-130°C; high clarity.'),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Submit Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppTheme.bgOffWhite,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppTheme.slateBody, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(
                      _isSubmitting ? 'Registering...' : 'Save & Register Material',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String hint, {bool isNumeric = false, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateBody)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          validator: required
              ? (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  if (isNumeric && double.tryParse(val.trim()) == null) return 'Must be a number';
                  return null;
                }
              : null,
          style: const TextStyle(fontSize: 13, color: AppTheme.slateDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: AppTheme.slateBody.withValues(alpha: 0.6)),
            filled: true,
            fillColor: AppTheme.bgOffWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Domain Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateBody)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.bgOffWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: AppTheme.primaryTeal,
          onChanged: onChanged,
        ),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.slateDark)),
      ],
    );
  }
}
