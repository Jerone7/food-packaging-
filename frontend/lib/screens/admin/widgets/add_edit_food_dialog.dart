import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/gradient_button.dart';

/// Dialog form modal for Creating and Editing Food Commodities
class AddEditFoodDialog extends StatefulWidget {
  final AdminFoodItemModel? initialFood;
  final Future<void> Function(Map<String, dynamic> payload) onSave;

  const AddEditFoodDialog({
    super.key,
    this.initialFood,
    required this.onSave,
  });

  @override
  State<AddEditFoodDialog> createState() => _AddEditFoodDialogState();
}

class _AddEditFoodDialogState extends State<AddEditFoodDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _scientificNameController;
  late TextEditingController _moistureController;
  late TextEditingController _phController;
  late TextEditingController _fatController;
  late TextEditingController _waterActivityController;

  String _category = 'Produce';
  String _respirationClass = 'Moderate';
  String _oxygenSensitivity = 'Moderate';
  String _moistureSensitivity = 'Moderate';

  bool _isSaving = false;

  final List<String> _categories = [
    'Produce',
    'Dairy & Sweets',
    'Snacks & Wafers',
    'Biscuits & Bakery',
    'Meat & Poultry',
    'Spices & Seasonings',
    'Grains & Pulses',
    'Beverages',
  ];

  final List<String> _respirationClasses = [
    'Non-respiring',
    'Low',
    'Moderate',
    'High',
    'Extremely High',
  ];

  final List<String> _sensitivityLevels = [
    'Low',
    'Moderate',
    'High',
    'Critical',
  ];

  @override
  void initState() {
    super.initState();
    final food = widget.initialFood;
    _nameController = TextEditingController(text: food?.name ?? '');
    _scientificNameController = TextEditingController(text: food?.scientificName ?? '');
    _moistureController = TextEditingController(text: food != null ? food.moisture.toString() : '80.0');
    _phController = TextEditingController(text: food != null ? food.ph.toString() : '5.5');
    _fatController = TextEditingController(text: food != null ? food.fat.toString() : '1.0');
    _waterActivityController = TextEditingController(text: food?.waterActivity?.toString() ?? '0.95');

    if (food != null) {
      if (_categories.contains(food.category)) {
        _category = food.category;
      }
      if (_respirationClasses.contains(food.respirationClass)) {
        _respirationClass = food.respirationClass;
      }
      if (_sensitivityLevels.contains(food.oxygenSensitivity)) {
        _oxygenSensitivity = food.oxygenSensitivity;
      }
      if (_sensitivityLevels.contains(food.moistureSensitivity)) {
        _moistureSensitivity = food.moistureSensitivity;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    _moistureController.dispose();
    _phController.dispose();
    _fatController.dispose();
    _waterActivityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final payload = {
        'name': _nameController.text.trim(),
        'category': _category,
        'scientific_name': _scientificNameController.text.trim().isNotEmpty
            ? _scientificNameController.text.trim()
            : null,
        'moisture': double.tryParse(_moistureController.text) ?? 80.0,
        'ph': double.tryParse(_phController.text) ?? 5.5,
        'fat': double.tryParse(_fatController.text) ?? 1.0,
        'water_activity': double.tryParse(_waterActivityController.text),
        'respiration_class': _respirationClass,
        'oxygen_sensitivity': _oxygenSensitivity,
        'moisture_sensitivity': _moistureSensitivity,
      };

      await widget.onSave(payload);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialFood != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                              color: AppTheme.primaryTeal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEdit ? 'Edit Food Commodity' : 'Add New Commodity',
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
                  const Divider(height: 28),

                  // Name & Category
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildTextField(
                          controller: _nameController,
                          label: 'Commodity Name *',
                          hint: 'e.g. Alphonso Mango',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Name required' : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 5,
                        child: _buildDropdown(
                          label: 'Category *',
                          value: _category,
                          items: _categories,
                          onChanged: (v) {
                            if (v != null) setState(() => _category = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Scientific Name
                  _buildTextField(
                    controller: _scientificNameController,
                    label: 'Scientific / Botanical Name',
                    hint: 'e.g. Mangifera indica L.',
                  ),
                  const SizedBox(height: 16),

                  // Biochemical Metrics Row (Moisture, pH, Fat, Water Activity)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _moistureController,
                          label: 'Moisture (%) *',
                          hint: '84.0',
                          keyboardType: TextInputType.number,
                          validator: (v) => (double.tryParse(v ?? '') == null) ? 'Invalid' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _phController,
                          label: 'pH Level *',
                          hint: '4.5',
                          keyboardType: TextInputType.number,
                          validator: (v) => (double.tryParse(v ?? '') == null) ? 'Invalid' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _fatController,
                          label: 'Fat (%) *',
                          hint: '0.4',
                          keyboardType: TextInputType.number,
                          validator: (v) => (double.tryParse(v ?? '') == null) ? 'Invalid' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _waterActivityController,
                          label: 'Water Act. (aw)',
                          hint: '0.98',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Respiration Class & Sensitivity Matrix
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Respiration Class *',
                          value: _respirationClass,
                          items: _respirationClasses,
                          onChanged: (v) {
                            if (v != null) setState(() => _respirationClass = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Oxygen Sens. *',
                          value: _oxygenSensitivity,
                          items: _sensitivityLevels,
                          onChanged: (v) {
                            if (v != null) setState(() => _oxygenSensitivity = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Moisture Sens. *',
                          value: _moistureSensitivity,
                          items: _sensitivityLevels,
                          onChanged: (v) {
                            if (v != null) setState(() => _moistureSensitivity = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Actions Row
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
                        text: isEdit ? 'Save Changes' : 'Create Commodity',
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppTheme.slateDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            filled: true,
            fillColor: AppTheme.bgOffWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
            ),
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
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
        ),
        const SizedBox(height: 6),
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
                    style: const TextStyle(fontSize: 13, color: AppTheme.slateDark),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.bgOffWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
