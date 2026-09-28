import 'package:flutter/material.dart';
import '../../../../models/food_commodity.dart';
import '../../../../services/recent_foods_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_translations.dart';

class RecentFoodsBar extends StatefulWidget {
  final ValueChanged<FoodCommodity> onSelectRecent;

  const RecentFoodsBar({
    super.key,
    required this.onSelectRecent,
  });

  @override
  State<RecentFoodsBar> createState() => _RecentFoodsBarState();
}

class _RecentFoodsBarState extends State<RecentFoodsBar> {
  List<FoodCommodity> _recents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  Future<void> _loadRecents() async {
    final list = await RecentFoodsService.getRecentFoods();
    if (mounted) {
      setState(() {
        _recents = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _recents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_toggle_off_rounded, size: 16, color: AppTheme.slateBody),
            const SizedBox(width: 6),
            Text(
              'analysis.recent_foods'.tr(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.slateBody,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _recents.map((food) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: CircleAvatar(
                    backgroundColor: food.categoryColor.withValues(alpha: 0.15),
                    child: Icon(food.categoryIcon, size: 14, color: food.categoryColor),
                  ),
                  label: Text(
                    food.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: AppTheme.bgOffWhite,
                  side: const BorderSide(color: AppTheme.borderSubtle),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () => widget.onSelectRecent(food),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
