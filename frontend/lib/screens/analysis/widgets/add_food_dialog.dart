import 'package:flutter/material.dart';
import '../../../../models/food_commodity.dart';
import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/gradient_button.dart';

class AddFoodDialog extends StatefulWidget {
  final String? initialName;
  final String? initialCategory;
  final ValueChanged<FoodCommodity> onFoodCreated;

  const AddFoodDialog({
    super.key,
    this.initialName,
    this.initialCategory,
    required this.onFoodCreated,
  });

  static Future<FoodCommodity?> show(
    BuildContext context, {
    String? initialName,
    String? initialCategory,
    required ValueChanged<FoodCommodity> onFoodCreated,
  }) {
    return showDialog<FoodCommodity>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddFoodDialog(
        initialName: initialName,
        initialCategory: initialCategory,
        onFoodCreated: onFoodCreated,
      ),
    );
  }

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _scientificNameCtrl;
  late final TextEditingController _moistureCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _phCtrl;
  late final TextEditingController _awCtrl;
  late final TextEditingController _storageCtrl;

  late String _selectedCategory;
  String _respirationClass = 'Moderate';
  final String _oxygenSensitivity = 'Moderate';
  final String _moistureSensitivity = 'High';
  bool _isSaving = false;
  String? _errorMessage;

  static const List<String> _categories = [
    'Fruits',
    'Vegetables',
    'Grains',
    'Dairy',
    'Meat',
    'Bakery',
    'Other perishables',
  ];

  static const List<String> _respirationClasses = [
    'None',
    'Very Low',
    'Low',
    'Moderate',
    'High',
    'Very High',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Fruits';
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _scientificNameCtrl = TextEditingController();
    _storageCtrl = TextEditingController();

    // Default sensible values based on initial category
    final defaults = _getDefaultsForCategory(_selectedCategory);
    _moistureCtrl = TextEditingController(text: defaults['moisture'].toString());
    _fatCtrl = TextEditingController(text: defaults['fat'].toString());
    _phCtrl = TextEditingController(text: defaults['ph'].toString());
    _awCtrl = TextEditingController(text: defaults['aw'].toString());
    _respirationClass = defaults['respiration'] as String;
    _storageCtrl.text = defaults['storage'] as String;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _scientificNameCtrl.dispose();
    _moistureCtrl.dispose();
    _fatCtrl.dispose();
    _phCtrl.dispose();
    _awCtrl.dispose();
    _storageCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getDefaultsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return {
          'moisture': 84.0,
          'fat': 0.3,
          'ph': 3.8,
          'aw': 0.98,
          'respiration': 'Moderate',
          'storage': 'Refrigerated (2-4°C, 90-95% RH)',
        };
      case 'vegetables':
        return {
          'moisture': 92.0,
          'fat': 0.2,
          'ph': 5.5,
          'aw': 0.99,
          'respiration': 'High',
          'storage': 'Refrigerated (2-4°C, 95% RH)',
        };
      case 'grains':
        return {
          'moisture': 12.0,
          'fat': 1.5,
          'ph': 6.5,
          'aw': 0.45,
          'respiration': 'None',
          'storage': 'Room temperature (dry, sealed moisture barrier)',
        };
      case 'dairy':
        return {
          'moisture': 48.0,
          'fat': 24.0,
          'ph': 5.6,
          'aw': 0.92,
          'respiration': 'Very Low',
          'storage': 'Refrigerated (2-4°C, airtight)',
        };
      case 'meat':
        return {
          'moisture': 74.0,
          'fat': 3.5,
          'ph': 5.8,
          'aw': 0.99,
          'respiration': 'Very Low',
          'storage': 'Refrigerated (0-2°C) or Frozen (≤ -18°C)',
        };
      case 'bakery':
        return {
          'moisture': 15.0,
          'fat': 8.0,
          'ph': 6.2,
          'aw': 0.65,
          'respiration': 'None',
          'storage': 'Room temperature (airtight moisture barrier)',
        };
      case 'other perishables':
      default:
        return {
          'moisture': 40.0,
          'fat': 12.0,
          'ph': 5.0,
          'aw': 0.80,
          'respiration': 'None',
          'storage': 'Room temperature or Chilled as indicated',
        };
    }
  }

  void _onCategoryChanged(String newCat) {
    setState(() {
      _selectedCategory = newCat;
      final defaults = _getDefaultsForCategory(newCat);
      _moistureCtrl.text = defaults['moisture'].toString();
      _fatCtrl.text = defaults['fat'].toString();
      _phCtrl.text = defaults['ph'].toString();
      _awCtrl.text = defaults['aw'].toString();
      _respirationClass = defaults['respiration'] as String;
      _storageCtrl.text = defaults['storage'] as String;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final name = _nameCtrl.text.trim();
      final scientificName = _scientificNameCtrl.text.trim();
      final moisture = double.parse(_moistureCtrl.text.trim());
      final fat = double.parse(_fatCtrl.text.trim());
      final ph = double.parse(_phCtrl.text.trim());
      final aw = double.parse(_awCtrl.text.trim());
      final storage = _storageCtrl.text.trim();

      final newFood = FoodCommodity(
        name: name,
        category: _selectedCategory,
        scientificName: scientificName.isNotEmpty ? scientificName : null,
        moisture: moisture,
        fat: fat,
        ph: ph,
        waterActivity: aw,
        respirationClass: _respirationClass,
        oxygenSensitivity: _oxygenSensitivity,
        moistureSensitivity: _moistureSensitivity,
        recommendedStorage: storage.isNotEmpty ? storage : 'Standard $_selectedCategory Storage',
      );

      final created = await ApiService.createFood(newFood);
      if (mounted) {
        widget.onFoodCreated(created);
        Navigator.of(context).pop(created);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save food commodity: $e';
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.primaryTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_box_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Manual Food Commodity',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Store custom product in database & evaluate packaging',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Form Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE11D48)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Color(0xFFE11D48), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Commodity Name
                        const Text(
                          'Commodity / Product Name *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Fresh Grapes, Dragonfruit, Organic Sourdough',
                            prefixIcon: const Icon(Icons.fastfood_outlined, color: AppTheme.primaryTeal, size: 20),
                            filled: true,
                            fillColor: AppTheme.bgOffWhite,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Product name is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category Selector
                        const Text(
                          'Category *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgOffWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryTeal),
                              items: _categories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) _onCategoryChanged(val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Scientific Name (Optional)
                        const Text(
                          'Scientific / Botanical Name (Optional)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _scientificNameCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Vitis vinifera, Hylocereus undatus',
                            prefixIcon: const Icon(Icons.science_outlined, color: AppTheme.primaryTeal, size: 20),
                            filled: true,
                            fillColor: AppTheme.bgOffWhite,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Biochemical Properties Matrix Header
                        const Row(
                          children: [
                            Icon(Icons.biotech_rounded, size: 18, color: AppTheme.emeraldEco),
                            SizedBox(width: 6),
                            Text(
                              'Biochemical Properties',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.emeraldEco),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Moisture %, Fat %, pH, Aw in 2x2 Grid
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Moisture (%) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _moistureCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      suffixText: '%',
                                      filled: true,
                                      fillColor: AppTheme.bgOffWhite,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                                    ),
                                    validator: (val) {
                                      final v = double.tryParse(val ?? '');
                                      if (v == null || v < 0 || v > 100) return '0-100%';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Fat / Oil (%) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _fatCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      suffixText: '%',
                                      filled: true,
                                      fillColor: AppTheme.bgOffWhite,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                                    ),
                                    validator: (val) {
                                      final v = double.tryParse(val ?? '');
                                      if (v == null || v < 0 || v > 100) return '0-100%';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('pH Level *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _phCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      suffixText: 'pH',
                                      filled: true,
                                      fillColor: AppTheme.bgOffWhite,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                                    ),
                                    validator: (val) {
                                      final v = double.tryParse(val ?? '');
                                      if (v == null || v < 1 || v > 14) return '1-14';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Water Activity (aw) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _awCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      suffixText: 'aw',
                                      filled: true,
                                      fillColor: AppTheme.bgOffWhite,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                                    ),
                                    validator: (val) {
                                      final v = double.tryParse(val ?? '');
                                      if (v == null || v < 0 || v > 1.0) return '0.0-1.0';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Respiration Rate Class
                        const Text(
                          'Respiration Rate Class',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgOffWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _respirationClass,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryTeal),
                              items: _respirationClasses.map((rc) {
                                return DropdownMenuItem<String>(
                                  value: rc,
                                  child: Text(rc, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _respirationClass = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Baseline Storage
                        const Text(
                          'Recommended Storage Condition',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _storageCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Refrigerated (0-1°C, 90-95% RH)',
                            prefixIcon: const Icon(Icons.ac_unit_rounded, color: AppTheme.primaryTeal, size: 20),
                            filled: true,
                            fillColor: AppTheme.bgOffWhite,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    GradientButton(
                      text: _isSaving ? 'Saving Product...' : 'Save & Select Product',
                      icon: _isSaving ? null : Icons.check_circle_rounded,
                      onPressed: _isSaving ? null : _handleSave,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
