import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../models/food_commodity.dart';
import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';
import 'add_food_dialog.dart';

class FoodSearchBar extends StatefulWidget {
  final String? selectedCategory;
  final ValueChanged<FoodCommodity> onSelectFood;
  final ValueChanged<String>? onCustomFoodEntered;

  const FoodSearchBar({
    super.key,
    this.selectedCategory,
    required this.onSelectFood,
    this.onCustomFoodEntered,
  });

  @override
  State<FoodSearchBar> createState() => _FoodSearchBarState();
}

class _FoodSearchBarState extends State<FoodSearchBar> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  List<FoodCommodity> _suggestions = [];
  bool _isLoading = false;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Small delay to allow ListTile.onTap to execute before unmounting
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted && !_focusNode.hasFocus) {
            setState(() {
              _showOverlay = false;
            });
          }
        });
      } else {
        setState(() {
          _showOverlay = _focusNode.hasFocus;
        });
      }
    });
    _fetchSuggestions('');
  }

  @override
  void didUpdateWidget(covariant FoodSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _fetchSuggestions(_searchCtrl.text);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await ApiService.searchFoods(
        query,
        category: widget.selectedCategory,
        limit: 8,
      );
      if (mounted) {
        setState(() {
          _suggestions = results;
          _showOverlay = _focusNode.hasFocus || _searchCtrl.text.isNotEmpty;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectItem(FoodCommodity food) {
    _searchCtrl.text = food.name;
    _focusNode.unfocus();
    setState(() {
      _showOverlay = false;
    });
    widget.onSelectFood(food);
  }

  void _openAddFoodDialog({String? initialName}) {
    _focusNode.unfocus();
    setState(() => _showOverlay = false);
    AddFoodDialog.show(
      context,
      initialName: initialName ?? (_searchCtrl.text.isNotEmpty ? _searchCtrl.text.trim() : null),
      initialCategory: widget.selectedCategory,
      onFoodCreated: (newFood) {
        _searchCtrl.text = newFood.name;
        widget.onSelectFood(newFood);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stored "${newFood.name}" in database and loaded scientific profile.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.emeraldEco,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final queryText = _searchCtrl.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Search Title and "+ Manual Entry" button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'analysis.search_title'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slateDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () => _openAddFoodDialog(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, size: 15, color: AppTheme.primaryTeal),
                    const SizedBox(width: 4),
                    Text(
                      'analysis.manual_entry'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Text Field Input
        TextField(
          controller: _searchCtrl,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          decoration: InputDecoration(
            hintText: widget.selectedCategory != null
                ? 'analysis.search_hint_category'.tr(params: {'category': widget.selectedCategory!})
                : 'analysis.search_hint_default'.tr(),
            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryTeal),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                    ),
                  )
                else if (_searchCtrl.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _searchCtrl.clear();
                      _fetchSuggestions('');
                    },
                  ),
              ],
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
            ),
          ),
        ),

        // Dropdown Overlay (With Suggestions & Manual Entry CTA)
        if (_showOverlay) ...[
          const SizedBox(height: 4),
          Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: _suggestions.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _suggestions.length + 1, // +1 for manual entry footer tile
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index < _suggestions.length) {
                          final food = _suggestions[index];
                          return ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: food.categoryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(food.categoryIcon, color: food.categoryColor, size: 18),
                            ),
                            title: Text(
                              food.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            subtitle: Text(
                              '${food.category} • Moisture: ${food.moisture}% • Fat: ${food.fat}%',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                            onTap: () => _selectItem(food),
                          );
                        } else {
                          // Footer action tile
                          return ListTile(
                            dense: true,
                            tileColor: AppTheme.bgOffWhite,
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldEco.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_box_rounded, color: AppTheme.emeraldEco, size: 18),
                            ),
                            title: Text(
                              'analysis.add_custom_food'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppTheme.emeraldEco,
                              ),
                            ),
                            subtitle: Text(
                              'analysis.add_custom_food_desc'.tr(),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.add_rounded, size: 16, color: AppTheme.emeraldEco),
                            onTap: () => _openAddFoodDialog(),
                          );
                        }
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 36, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            queryText.isNotEmpty
                                ? 'analysis.no_food_found'.tr(params: {'query': queryText})
                                : 'analysis.no_food_category'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'analysis.store_product_manual'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.emeraldEco,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(
                              queryText.isNotEmpty
                                  ? 'analysis.add_as_manual'.tr(params: {'name': queryText})
                                  : 'analysis.add_manual_product'.tr(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _openAddFoodDialog(initialName: queryText.isNotEmpty ? queryText : null),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
