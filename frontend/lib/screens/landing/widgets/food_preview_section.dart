import 'package:flutter/material.dart';
import '../../../../widgets/modern_card.dart';
import '../../../../widgets/gradient_button.dart';
import '../../../../models/commodity_model.dart';
import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';
import '../../../../services/locale_service.dart';

class FoodPreviewSection extends StatefulWidget {
  final Function(String? category)? onSelectCategory;

  const FoodPreviewSection({
    super.key,
    this.onSelectCategory,
  });

  @override
  State<FoodPreviewSection> createState() => _FoodPreviewSectionState();
}

class _FoodPreviewSectionState extends State<FoodPreviewSection> {
  late Future<CommoditySummaryResult> _futureSummary;

  @override
  void initState() {
    super.initState();
    _futureSummary = ApiService.getFeaturedCommodities();
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('snack') || lower.contains('chip')) return Icons.cookie_outlined;
    if (lower.contains('biscuit') || lower.contains('bakery') || lower.contains('bread')) return Icons.bakery_dining_outlined;
    if (lower.contains('pickle') || lower.contains('sauce') || lower.contains('jam')) return Icons.soup_kitchen_outlined;
    if (lower.contains('spice')) return Icons.local_fire_department_outlined;
    if (lower.contains('dairy') || lower.contains('sweet') || lower.contains('milk')) return Icons.egg_outlined;
    if (lower.contains('retort') || lower.contains('ready')) return Icons.takeout_dining_outlined;
    if (lower.contains('millet') || lower.contains('flour')) return Icons.grass_outlined;
    if (lower.contains('nut') || lower.contains('fruit')) return Icons.nature_outlined;
    return Icons.inventory_2_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 1024;
        final isTablet = screenWidth >= 640 && screenWidth < 1024;
        final theme = Theme.of(context);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 20,
            vertical: 56,
          ),
          color: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  // Section Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.borderTeal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'landing.food_preview_title'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'landing.food_preview_title'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slateDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Text(
                      'landing.food_preview_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.slateBody,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

              // Dynamic Category Cards Grid
              FutureBuilder<CommoditySummaryResult>(
                future: _futureSummary,
                builder: (context, snapshot) {
                  final categories = snapshot.data?.categories ?? ApiService.defaultCategories;

                  final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 220,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      return _buildCategoryCard(item);
                    },
                  );
                },
              ),
              const SizedBox(height: 36),

              // Bottom CTA
              GradientButton(
                text: 'Analyze Custom Food Item',
                icon: Icons.auto_awesome,
                onPressed: () => widget.onSelectCategory?.call(null),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
}

  Widget _buildCategoryCard(CommodityCategorySummary item) {
    final icon = _getCategoryIcon(item.category);

    return ModernCard(
      enableHover: true,
      padding: const EdgeInsets.all(16),
      onTap: () => widget.onSelectCategory?.call(item.category),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryTeal, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.bgOffWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Text(
                  '${item.count}+ items',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.slateDark,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              item.description.isNotEmpty ? item.description : 'Empirical moisture & fat profiles.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.slateBody,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Sample items preview wrap
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: item.sampleItems.take(2).map((name) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  name,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
