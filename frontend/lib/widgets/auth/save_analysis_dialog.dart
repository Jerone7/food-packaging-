import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../gradient_button.dart';

/// Modal dialog prompting the engineer to bookmark and name a recommendation configuration.
class SaveAnalysisDialog extends StatefulWidget {
  final String commodityName;
  final String? recommendedMaterial;
  final double? estimatedCost;
  final double? sustainabilityScore;
  final Map<String, dynamic> inputPayload;
  final Map<String, dynamic> recommendationResult;

  const SaveAnalysisDialog({
    super.key,
    required this.commodityName,
    this.recommendedMaterial,
    this.estimatedCost,
    this.sustainabilityScore,
    this.inputPayload = const {},
    this.recommendationResult = const {},
  });

  @override
  State<SaveAnalysisDialog> createState() => _SaveAnalysisDialogState();
}

class _SaveAnalysisDialogState extends State<SaveAnalysisDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: '${widget.commodityName} Packaging Spec',
    );
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final auth = AuthService();

    final savedPreset = await auth.saveAnalysisPreset(
      title: _titleController.text.trim(),
      notes: _notesController.text.trim(),
      commodityName: widget.commodityName,
      recommendedMaterial: widget.recommendedMaterial,
      estimatedCost: widget.estimatedCost,
      sustainabilityScore: widget.sustainabilityScore,
      inputPayload: widget.inputPayload,
      recommendationResult: widget.recommendationResult,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (savedPreset != null) {
        Navigator.of(context).pop(savedPreset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final material = widget.recommendedMaterial ?? 'Optimized Packaging Substrate';
    final cost = widget.estimatedCost != null
        ? '₹${widget.estimatedCost!.toStringAsFixed(2)}'
        : '₹3.50';
    final score = widget.sustainabilityScore != null
        ? '${widget.sustainabilityScore!.toStringAsFixed(0)}/100'
        : '85/100';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.surfaceWhite,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_add_rounded,
                                color: AppTheme.primaryTeal, size: 24),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Bookmark Analysis Preset',
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
                  const Divider(color: AppTheme.borderSubtle, height: 20),

                  // Configuration Summary Pill
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.bgOffWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 16, color: AppTheme.primaryTeal),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${widget.commodityName} • $material',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.slateDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.borderTeal,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cost,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.eco_rounded,
                                      size: 11, color: AppTheme.emeraldEco),
                                  const SizedBox(width: 3),
                                  Text(
                                    score,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.emeraldEco,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Preset Title Input
                  TextFormField(
                    key: const Key('save_preset_title_input'),
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Preset Title',
                      hintText: 'e.g. Tomato Export Summer Spec',
                      prefixIcon: const Icon(Icons.label_outline_rounded,
                          size: 18, color: AppTheme.slateBody),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      filled: true,
                      fillColor: AppTheme.bgOffWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Please provide a preset title'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // Engineering Notes Input
                  TextFormField(
                    key: const Key('save_preset_notes_input'),
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Engineering & Operational Notes (Optional)',
                      hintText: 'e.g. Validated for 14-day supply chain at 4°C with MAP.',
                      prefixIcon: const Icon(Icons.notes_rounded,
                          size: 18, color: AppTheme.slateBody),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      filled: true,
                      fillColor: AppTheme.bgOffWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
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
                          key: const Key('save_preset_submit_button'),
                          text: 'Save to Vault',
                          icon: Icons.bookmark_add_rounded,
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
}
