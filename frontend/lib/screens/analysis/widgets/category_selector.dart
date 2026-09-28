import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onSelectCategory;

  static String getLocalizedCategory(String name) {
    switch (name.toLowerCase()) {
      case 'fruits':
        return 'category.fruits'.tr();
      case 'vegetables':
        return 'category.vegetables'.tr();
      case 'grains':
        return 'category.grains'.tr();
      case 'dairy':
        return 'category.dairy'.tr();
      case 'meat':
        return 'category.meat'.tr();
      case 'bakery':
        return 'category.bakery'.tr();
      case 'other perishables':
      case 'other':
        return 'category.other'.tr();
      default:
        return name;
    }
  }

  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Fruits',
      'icon': Icons.apple_rounded,
      'color': Color(0xFFF97316),
    },
    {
      'name': 'Vegetables',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF059669),
    },
    {
      'name': 'Grains',
      'icon': Icons.grain_rounded,
      'color': Color(0xFFD97706),
    },
    {
      'name': 'Dairy',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF0284C7),
    },
    {
      'name': 'Meat',
      'icon': Icons.set_meal_rounded,
      'color': Color(0xFFE11D48),
    },
    {
      'name': 'Bakery',
      'icon': Icons.cake_rounded,
      'color': Color(0xFF9333EA),
    },
    {
      'name': 'Other perishables',
      'icon': Icons.fastfood_rounded,
      'color': Color(0xFF0F766E),
    },
  ];

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'category.title'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.slateDark,
              ),
            ),
            if (selectedCategory != null)
              TextButton(
                onPressed: () => onSelectCategory(null),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'category.view_all'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final name = cat['name'] as String;
              final icon = cat['icon'] as IconData;
              final color = cat['color'] as Color;
              final isSelected = selectedCategory?.toLowerCase() == name.toLowerCase();

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
                    if (isSelected) {
                      onSelectCategory(null);
                    } else {
                      onSelectCategory(name);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : color.withValues(alpha: 0.25),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected ? Colors.white : color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          getLocalizedCategory(name),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
