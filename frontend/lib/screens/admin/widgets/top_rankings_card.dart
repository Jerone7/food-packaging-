import 'package:flutter/material.dart';
import '../../../../models/admin_model.dart';
import '../../../../theme/app_theme.dart';

/// Leaderboard widget showing Top Searched Commodities and Top Recommended Packaging Materials
class TopRankingsCard extends StatelessWidget {
  final List<FoodSearchStatModel> topFoods;
  final List<MaterialRecommendStatModel> topMaterials;

  const TopRankingsCard({
    super.key,
    required this.topFoods,
    required this.topMaterials,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 768;

        if (isNarrow) {
          return Column(
            children: [
              _buildTopFoodsCard(),
              const SizedBox(height: 20),
              _buildTopMaterialsCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTopFoodsCard()),
            const SizedBox(width: 20),
            Expanded(child: _buildTopMaterialsCard()),
          ],
        );
      },
    );
  }

  Widget _buildTopFoodsCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant_rounded, color: Color(0xFFD97706), size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most Searched Foods',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                    ),
                    Text(
                      'High-demand commodities in queries',
                      style: TextStyle(fontSize: 12, color: AppTheme.slateBody),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          if (topFoods.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No food query history recorded', style: TextStyle(color: AppTheme.slateBody, fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topFoods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = topFoods[index];
                return _buildFoodRow(index + 1, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFoodRow(int rank, FoodSearchStatModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank <= 3 ? AppTheme.primaryTeal.withValues(alpha: 0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? AppTheme.primaryTeal : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.category,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${item.queryCount} queries (${item.sharePct.toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slateBody),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (item.sharePct / 100).clamp(0.02, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(
              rank == 1 ? AppTheme.primaryTeal : AppTheme.mintAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopMaterialsCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.eco_rounded, color: AppTheme.emeraldEco, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Recommended Materials',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.slateDark),
                    ),
                    Text(
                      'Most matched packaging substrates',
                      style: TextStyle(fontSize: 12, color: AppTheme.slateBody),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          if (topMaterials.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No material recommendations recorded', style: TextStyle(color: AppTheme.slateBody, fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topMaterials.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = topMaterials[index];
                return _buildMaterialRow(index + 1, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(int rank, MaterialRecommendStatModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank <= 3 ? AppTheme.emeraldLight : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? AppTheme.emeraldEco : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.materialName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.polymerFamily,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.emeraldLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${item.averageScore.toStringAsFixed(0)}% Eco',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.emeraldEco,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (item.sharePct / 100).clamp(0.02, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(
              rank == 1 ? AppTheme.emeraldEco : const Color(0xFF10B981),
            ),
          ),
        ),
      ],
    );
  }
}
