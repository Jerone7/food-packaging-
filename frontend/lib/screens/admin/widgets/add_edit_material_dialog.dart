import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/gradient_button.dart';

/// Modal dialog form for Creating and Editing Packaging Materials
class AddEditMaterialDialog extends StatefulWidget {
  final AdminMaterialItemModel? initialMaterial;
  final Future<void> Function(Map<String, dynamic> payload) onSave;

  const AddEditMaterialDialog({
    super.key,
    this.initialMaterial,
    required this.onSave,
  });

  @override
  State<AddEditMaterialDialog> createState() => _AddEditMaterialDialogState();
}

class _AddEditMaterialDialogState extends State<AddEditMaterialDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _matIdController;
  late TextEditingController _nameController;
  late TextEditingController _structureController;
  late TextEditingController _thicknessController;
  late TextEditingController _otrController;
  late TextEditingController _wvtrController;
  late TextEditingController _co2PermController;
  late TextEditingController _selectivityController;
  late TextEditingController _tensileController;
  late TextEditingController _punctureController;
  late TextEditingController _sustainabilityController;
  late TextEditingController _recyclabilityController;
  late TextEditingController _biodegradabilityController;
  late TextEditingController _costController;

  String _category = 'Biodegradable Bio-Polymer';
  String _polymerFamily = 'BREATHABLE_BIO_EMAP';
  String _formFactor = 'Flexible Pouch';

  bool _isBreathable = false;
  bool _isBiodegradable = false;
  bool _isRecyclable = true;
  bool _gasFlushCompatible = false;
  bool _isActiveEntry = true;
  bool _isSaving = false;

  final List<String> _categories = [
    'Biodegradable Bio-Polymer',
    'Paper & Fiber Board',
    'Metallized Film',
    'Multi-Layer Co-Extrusion',
    'Recyclable Polyolefin',
    'Rigid Bio-Plastic',
  ];

  final List<String> _polymerFamilies = [
    'BREATHABLE_BIO_EMAP',
    'CELLULOSE_KRAFT_LINED',
    'METALLIZED_BARRIER',
    'HIGH_BARRIER_EVOH_VSP',
    'RECYCLABLE_POLYOLEFIN',
    'EXPANDED_BIO_FOAM',
  ];

  final List<String> _formFactors = [
    'Flexible Pouch',
    'Rigid Carton',
    'Pillow Pouch',
    'Thermoformed Skin',
    'Molded Tray',
    'Stand-Up Pouch',
  ];

  @override
  void initState() {
    super.initState();
    final mat = widget.initialMaterial;

    _matIdController = TextEditingController(text: mat?.materialId ?? 'mat_${DateTime.now().millisecondsSinceEpoch % 10000}');
    _nameController = TextEditingController(text: mat?.name ?? '');
    _structureController = TextEditingController(text: mat?.structure ?? '');
    _thicknessController = TextEditingController(text: mat != null ? mat.thicknessMicrons.toString() : '30.0');
    _otrController = TextEditingController(text: mat?.otr?.toString() ?? '1500.0');
    _wvtrController = TextEditingController(text: mat?.wvtr?.toString() ?? '15.0');
    _co2PermController = TextEditingController(text: mat?.co2Permeability?.toString() ?? '6000.0');
    _selectivityController = TextEditingController(text: mat?.selectivityBeta?.toString() ?? '4.0');
    _tensileController = TextEditingController(text: mat?.tensileStrengthMpa?.toString() ?? '35.0');
    _punctureController = TextEditingController(text: mat?.punctureResistanceN?.toString() ?? '18.0');
    _sustainabilityController = TextEditingController(text: mat != null ? mat.sustainabilityScore.toString() : '90.0');
    _recyclabilityController = TextEditingController(text: mat != null ? mat.recyclabilityScore.toString() : '80.0');
    _biodegradabilityController = TextEditingController(text: mat != null ? mat.biodegradabilityScore.toString() : '0.0');
    _costController = TextEditingController(text: mat != null ? mat.estimatedUnitCostInr.toString() : '3.50');

    if (mat != null) {
      if (_categories.contains(mat.category)) _category = mat.category;
      if (_polymerFamilies.contains(mat.polymerFamily)) _polymerFamily = mat.polymerFamily;
      if (_formFactors.contains(mat.formFactor)) _formFactor = mat.formFactor;

      _isBreathable = mat.isBreathable;
      _isBiodegradable = mat.isBiodegradable;
      _isRecyclable = mat.isRecyclable;
      _gasFlushCompatible = mat.gasFlushCompatible;
      _isActiveEntry = mat.isActiveEntry;
    }
  }

  @override
  void dispose() {
    _matIdController.dispose();
    _nameController.dispose();
    _structureController.dispose();
    _thicknessController.dispose();
    _otrController.dispose();
    _wvtrController.dispose();
    _co2PermController.dispose();
    _selectivityController.dispose();
    _tensileController.dispose();
    _punctureController.dispose();
    _sustainabilityController.dispose();
    _recyclabilityController.dispose();
    _biodegradabilityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final payload = {
        'material_id': _matIdController.text.trim(),
        'name': _nameController.text.trim(),
        'category': _category,
        'polymer_family': _polymerFamily,
        'structure': _structureController.text.trim().isNotEmpty ? _structureController.text.trim() : null,
        'form_factor': _formFactor,
        'thickness_microns': double.tryParse(_thicknessController.text) ?? 30.0,
        'otr_cc_m2_day': double.tryParse(_otrController.text),
        'wvtr_g_m2_day': double.tryParse(_wvtrController.text),
        'co2_permeability': double.tryParse(_co2PermController.text),
        'selectivity_beta': double.tryParse(_selectivityController.text),
        'tensile_strength_mpa': double.tryParse(_tensileController.text),
        'puncture_resistance_n': double.tryParse(_punctureController.text),
        'sustainability_score': double.tryParse(_sustainabilityController.text) ?? 90.0,
        'recyclability_score': double.tryParse(_recyclabilityController.text) ?? 80.0,
        'biodegradability_score': double.tryParse(_biodegradabilityController.text) ?? 0.0,
        'estimated_unit_cost_inr': double.tryParse(_costController.text) ?? 3.50,
        'is_breathable': _isBreathable,
        'is_biodegradable': _isBiodegradable,
        'is_recyclable': _isRecyclable,
        'gas_flush_compatible': _gasFlushCompatible,
        'is_active_entry': _isActiveEntry,
      };

      await widget.onSave(payload);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialMaterial != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 840),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              // Dialog Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isEdit ? Icons.tune_rounded : Icons.layers_outlined,
                          color: AppTheme.primaryTeal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEdit ? 'Edit Packaging Material' : 'Add New Packaging Material',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.slateDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.slateBody),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Identification & Classification
                        _buildSectionHeader('Substrate Identification & Category', Icons.inventory_2_rounded),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: _buildTextField(
                                controller: _matIdController,
                                label: 'Material ID *',
                                hint: 'mat_custom_01',
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 8,
                              child: _buildTextField(
                                controller: _nameController,
                                label: 'Material Name *',
                                hint: 'e.g. High-Barrier Bio-PET Pouch',
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: 'Polymer Family *',
                                value: _polymerFamily,
                                items: _polymerFamilies,
                                onChanged: (v) {
                                  if (v != null) setState(() => _polymerFamily = v);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: 'Category *',
                                value: _category,
                                items: _categories,
                                onChanged: (v) {
                                  if (v != null) setState(() => _category = v);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: 'Form Factor *',
                                value: _formFactor,
                                items: _formFactors,
                                onChanged: (v) {
                                  if (v != null) setState(() => _formFactor = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: _buildTextField(
                                controller: _structureController,
                                label: 'Laminate Layer Structure',
                                hint: 'e.g. PET / Alu-Oxide / Bio-PE',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 5,
                              child: _buildNumField(
                                controller: _thicknessController,
                                label: 'Thickness (µm) *',
                                hint: '30.0',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 2: Barrier Permeation Performance
                        _buildSectionHeader('Barrier & Gas Permeability', Icons.air_rounded),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildNumField(controller: _otrController, label: 'OTR (cc/m²·day)', hint: '0.65')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildNumField(controller: _wvtrController, label: 'WVTR (g/m²·day)', hint: '0.85')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildNumField(controller: _co2PermController, label: 'CO2 Permeability', hint: '18000.0')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildNumField(controller: _selectivityController, label: 'Selectivity (β)', hint: '4.0')),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 3: Mechanical Strength & Economics
                        _buildSectionHeader('Mechanical Strength & Unit Pricing', Icons.speed_rounded),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildNumField(controller: _tensileController, label: 'Tensile Strength (MPa)', hint: '35.0')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildNumField(controller: _punctureController, label: 'Puncture Resist. (N)', hint: '18.0')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildNumField(controller: _costController, label: 'Unit Cost (INR ₹) *', hint: '3.50')),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 4: Eco Scores & Circularity
                        _buildSectionHeader('Sustainability & Circular Economy Metrics', Icons.eco_rounded),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildNumField(controller: _sustainabilityController, label: 'Eco Score (0-100)', hint: '90.0')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildNumField(controller: _recyclabilityController, label: 'Recyclability (0-100)', hint: '80.0')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildNumField(controller: _biodegradabilityController, label: 'Biodegradable (0-100)', hint: '0.0')),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 5: Feature Flags & Status
                        _buildSectionHeader('Substrate Capabilities & System State', Icons.toggle_on_rounded),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          children: [
                            _buildCheckbox('Active in Recommender', _isActiveEntry, (v) => setState(() => _isActiveEntry = v ?? true)),
                            _buildCheckbox('Breathable (EMAP)', _isBreathable, (v) => setState(() => _isBreathable = v ?? false)),
                            _buildCheckbox('Biodegradable', _isBiodegradable, (v) => setState(() => _isBiodegradable = v ?? false)),
                            _buildCheckbox('Recyclable', _isRecyclable, (v) => setState(() => _isRecyclable = v ?? false)),
                            _buildCheckbox('Gas-Flush / MAP Compatible', _gasFlushCompatible, (v) => setState(() => _gasFlushCompatible = v ?? false)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    text: isEdit ? 'Save Material' : 'Create Material',
                    icon: isEdit ? Icons.check_circle_outline_rounded : Icons.add_rounded,
                    isLoading: _isSaving,
                    height: 48,
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: AppTheme.slateDark),
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildNumField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13, color: AppTheme.slateDark),
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: items.contains(value) ? value : items.first,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.slateDark),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.bgOffWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
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
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: onChanged,
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.slateDark)),
      ],
    );
  }
}
