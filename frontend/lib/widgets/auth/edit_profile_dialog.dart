import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../gradient_button.dart';

/// Modal dialog for updating authenticated user profile and engineering defaults.
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _orgController;
  late final TextEditingController _roleController;
  late final TextEditingController _batchSizeController;
  late final TextEditingController _exportHeaderController;

  late String _currency;
  late bool _ecoPriority;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    final prefs = AuthService().preferences;

    _nameController = TextEditingController(text: user?.fullName ?? '');
    _orgController = TextEditingController(text: user?.organization ?? '');
    _roleController = TextEditingController(text: user?.role ?? 'Packaging Engineer');
    _batchSizeController = TextEditingController(text: prefs.defaultBatchSize.toString());
    _exportHeaderController = TextEditingController(text: prefs.exportOrganizationHeader ?? '');

    _currency = prefs.defaultCurrency;
    _ecoPriority = prefs.defaultEcoPriority;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _roleController.dispose();
    _batchSizeController.dispose();
    _exportHeaderController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final batchSize = int.tryParse(_batchSizeController.text.trim()) ?? 10000;

    final success = await AuthService().updateProfile(
      fullName: _nameController.text.trim(),
      organization: _orgController.text.trim(),
      role: _roleController.text.trim(),
      defaultCurrency: _currency,
      defaultBatchSize: batchSize,
      defaultEcoPriority: _ecoPriority,
      exportOrganizationHeader: _exportHeaderController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.surfaceWhite,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.manage_accounts_rounded,
                                color: AppTheme.primaryTeal, size: 24),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Edit Profile & Preferences',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.slateDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.slateBody),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderSubtle, height: 24),

                  // Full Name
                  TextFormField(
                    key: const Key('edit_profile_name_input'),
                    controller: _nameController,
                    decoration: _inputDecoration('Full Name', Icons.person_outline),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 14),

                  // Organization & Role
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('edit_profile_org_input'),
                          controller: _orgController,
                          decoration:
                              _inputDecoration('Organization', Icons.business_outlined),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const Key('edit_profile_role_input'),
                          controller: _roleController,
                          decoration:
                              _inputDecoration('Role / Title', Icons.badge_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Default Currency & Batch Size
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: const Key('edit_profile_currency_select'),
                          initialValue: _currency,
                          decoration: _inputDecoration(
                              'Default Currency', Icons.currency_exchange_rounded),
                          items: const [
                            DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
                            DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                            DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _currency = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const Key('edit_profile_batch_input'),
                          controller: _batchSizeController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                              'Default Batch Size', Icons.inventory_2_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Export Organization Header
                  TextFormField(
                    key: const Key('edit_profile_header_input'),
                    controller: _exportHeaderController,
                    decoration: _inputDecoration(
                        'Report Organization Header', Icons.description_outlined),
                  ),
                  const SizedBox(height: 14),

                  // Eco Priority Switch
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgOffWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.eco_rounded,
                                  color: AppTheme.emeraldEco, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Prioritize Eco-Friendly Alternatives',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.slateDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _ecoPriority,
                          activeThumbColor: AppTheme.emeraldEco,
                          onChanged: (val) => setState(() => _ecoPriority = val ?? true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save & Cancel Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppTheme.borderSubtle),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(color: AppTheme.slateBody)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          key: const Key('edit_profile_save_button'),
                          text: 'Save Changes',
                          isLoading: _isSaving,
                          onPressed: _handleSave,
                        ),
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: AppTheme.slateBody),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: AppTheme.bgOffWhite,
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
    );
  }
}
