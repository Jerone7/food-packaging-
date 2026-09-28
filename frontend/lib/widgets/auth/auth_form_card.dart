import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../gradient_button.dart';
import '../modern_card.dart';

/// Tabbed Authentication Card supporting Login and Signup with rich validation.
class AuthFormCard extends StatefulWidget {
  final VoidCallback? onAuthSuccess;
  final bool initialIsSignUp;

  const AuthFormCard({
    super.key,
    this.onAuthSuccess,
    this.initialIsSignUp = false,
  });

  @override
  State<AuthFormCard> createState() => _AuthFormCardState();
}

class _AuthFormCardState extends State<AuthFormCard> {
  final _formKey = GlobalKey<FormState>();
  late bool _isSignUp;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _orgController = TextEditingController();
  final _roleController = TextEditingController(text: 'Packaging Engineer');
  String _selectedCurrency = 'INR';
  bool _defaultEcoPriority = true;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _orgController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthService();
    bool success = false;

    if (_isSignUp) {
      success = await auth.signup(
        _emailController.text,
        _passwordController.text,
        _fullNameController.text,
        organization: _orgController.text,
        role: _roleController.text,
        defaultCurrency: _selectedCurrency,
        defaultEcoPriority: _defaultEcoPriority,
      );
    } else {
      success = await auth.login(
        _emailController.text,
        _passwordController.text,
      );
    }

    if (success && mounted) {
      widget.onAuthSuccess?.call();
    }
  }

  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = 'sarah.jenkins@smartpack.io';
      _passwordController.text = 'SmartPack#2026!';
      _fullNameController.text = 'Dr. Sarah Jenkins';
      _orgController.text = 'BioPackaging Innovation Lab';
      _roleController.text = 'Chief Packaging Engineer';
    });
  }

  void _activateDemoDirectly() {
    final auth = AuthService();
    auth.activateDemoMode();
    widget.onAuthSuccess?.call();
  }

  void _promptAdminAuth() {
    final passkeyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFFD97706)),
            SizedBox(width: 8),
            Text('Admin Security Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the Master Administrative Passkey or click "Fill Admin Credentials" to sign in as SuperAdmin.',
              style: TextStyle(fontSize: 13, color: AppTheme.slateDark),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passkeyCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Master Admin Passkey',
                hintText: 'Enter Admin@2026',
                prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFD97706)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSignUp = false;
                  _emailController.text = 'admin@smartpack.io';
                  _passwordController.text = 'Admin@1234';
                });
              },
              icon: const Icon(Icons.auto_fix_high_rounded, size: 14, color: Color(0xFFD97706)),
              label: const Text('Fill Admin Login Form', style: TextStyle(fontSize: 12, color: Color(0xFFD97706))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final ok = AuthService().authenticateAdminPasskey(passkeyCtrl.text);
              Navigator.pop(ctx);
              if (ok) {
                widget.onAuthSuccess?.call();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid Admin Passkey. Access denied.'),
                    backgroundColor: Color(0xFFE11D48),
                  ),
                );
              }
            },
            child: const Text('Authorize Admin'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthService(),
      builder: (context, _) {
        final auth = AuthService();
        return ModernCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(28),
          borderColor: AppTheme.borderSubtle,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.bgOffWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          title: 'Sign In',
                          isSelected: !_isSignUp,
                          onTap: () {
                            setState(() => _isSignUp = false);
                            auth.clearError();
                          },
                        ),
                      ),
                      Expanded(
                        child: _TabButton(
                          title: 'Create Account',
                          isSelected: _isSignUp,
                          onTap: () {
                            setState(() => _isSignUp = true);
                            auth.clearError();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title & Subtitle
                Text(
                  _isSignUp ? 'Join SmartPack Workspace' : 'Welcome to SmartPack AI',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slateDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Create an engineering profile to save presets, history & custom export configurations.'
                      : 'Sign in to access your saved analyses, custom materials, and compliance records.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.slateBody,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Error Banner
                if (auth.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Full Name (Signup Only)
                if (_isSignUp) ...[
                  TextFormField(
                    key: const Key('auth_fullname_input'),
                    controller: _fullNameController,
                    decoration: _inputDecoration(
                      label: 'Full Name',
                      hint: 'e.g. Dr. Sarah Jenkins',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 14),
                ],

                // Email
                TextFormField(
                  key: const Key('auth_email_input'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    label: 'Professional Email',
                    hint: 'engineer@company.com',
                    icon: Icons.email_outlined,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(val.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  key: const Key('auth_password_input'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    label: 'Password',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: AppTheme.slateBody,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (_isSignUp && val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Organization & Role (Signup Only)
                if (_isSignUp) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('auth_org_input'),
                          controller: _orgController,
                          decoration: _inputDecoration(
                            label: 'Organization',
                            hint: 'e.g. BioPack Labs',
                            icon: Icons.business_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const Key('auth_role_input'),
                          controller: _roleController,
                          decoration: _inputDecoration(
                            label: 'Role / Title',
                            hint: 'Packaging Engineer',
                            icon: Icons.badge_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Currency & Eco Priority
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCurrency,
                          decoration: _inputDecoration(
                            label: 'Default Currency',
                            hint: 'Select',
                            icon: Icons.currency_exchange_rounded,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
                            DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                            DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCurrency = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.bgOffWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.eco_rounded,
                                  color: AppTheme.emeraldEco, size: 18),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Eco Bias',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.slateDark,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _defaultEcoPriority,
                                activeThumbColor: AppTheme.emeraldEco,
                                onChanged: (val) =>
                                    setState(() => _defaultEcoPriority = val),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                const SizedBox(height: 8),

                // Submit Button
                GradientButton(
                  key: const Key('auth_submit_button'),
                  text: _isSignUp ? 'Create Workspace Account' : 'Sign In to Workspace',
                  icon: _isSignUp ? Icons.person_add_alt_1_rounded : Icons.login_rounded,
                  isLoading: auth.isLoading,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 16),

                // Demo fast fill row
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton.icon(
                      key: const Key('auth_demo_fill_button'),
                      icon: const Icon(Icons.auto_fix_high_rounded,
                          size: 16, color: AppTheme.primaryTeal),
                      label: const Text(
                        'Client Demo Profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      onPressed: _fillDemoCredentials,
                    ),
                    TextButton.icon(
                      key: const Key('auth_admin_access_button'),
                      icon: const Icon(Icons.shield_outlined,
                          size: 16, color: Color(0xFFD97706)),
                      label: const Text(
                        'Admin Key 🛡️',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      onPressed: _promptAdminAuth,
                    ),
                    TextButton(
                      key: const Key('auth_instant_demo_button'),
                      onPressed: _activateDemoDirectly,
                      child: const Text(
                        'Guest Demo →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slateBody,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppTheme.slateBody),
      suffixIcon: suffixIcon,
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

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.primaryTeal : AppTheme.slateBody,
          ),
        ),
      ),
    );
  }
}
