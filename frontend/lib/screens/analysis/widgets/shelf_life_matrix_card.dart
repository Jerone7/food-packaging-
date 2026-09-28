import 'package:flutter/material.dart';
import '../../../models/food_scientific_profile.dart';
import '../../../services/food_analysis_normalizer.dart';
import '../../../widgets/modern_card.dart';

class ShelfLifeMatrixCard extends StatefulWidget {
  final FoodScientificProfile profile;

  const ShelfLifeMatrixCard({
    super.key,
    required this.profile,
  });

  @override
  State<ShelfLifeMatrixCard> createState() => _ShelfLifeMatrixCardState();
}

class _ShelfLifeMatrixCardState extends State<ShelfLifeMatrixCard> {
  double _simulatedTemp = 20.0;
  bool _showSimulator = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final thermal = profile.thermalAndStorage;
    final ambientDays = thermal.ambientShelfLifeDays;
    final refrigDays = thermal.refrigeratedShelfLifeDays ?? (ambientDays * 2.5).round();
    final caDays = thermal.controlledAtmosphereShelfLifeDays ?? (refrigDays * 1.8).round();
    final multiplier = FoodAnalysisNormalizer.computeExtensionMultiplier(ambientDays, caDays);

    final simulatedDays = FoodAnalysisNormalizer.estimateArrheniusShelfLife(
      ambientDays,
      25.0,
      _simulatedTemp,
    );

    final isHighMoistureProduce = profile.physicochemical.moisturePct > 80.0 &&
        (profile.category.toLowerCase() == 'vegetables' || profile.category.toLowerCase() == 'fruits');

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        size: 18,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Preservation & Shelf-Life Horizon',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  '${multiplier}x MAP Horizon',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Comparative durability across temperature and atmosphere regimes:',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          // 4-Tier Regime Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 520 ? 2 : 4;
              final childAspectRatio = width < 380 ? 1.25 : (width < 520 ? 1.45 : 1.15);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildRegimeCard(
                    title: 'Ambient (25°C)',
                    days: '$ambientDays Days',
                    subtitle: 'Baseline Lifespan',
                    badge: '1.0x Baseline',
                    badgeColor: const Color(0xFF64748B),
                    icon: Icons.wb_sunny_outlined,
                  ),
                  _buildRegimeCard(
                    title: 'Refrigerated (4°C)',
                    days: '$refrigDays Days',
                    subtitle: thermal.isChillingSensitive
                        ? 'Caution: Chilling zone'
                        : 'Standard Cold Chain',
                    badge: thermal.isChillingSensitive ? 'Chilling Alert' : 'Cold Chain',
                    badgeColor: thermal.isChillingSensitive
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF0284C7),
                    icon: Icons.ac_unit_rounded,
                  ),
                  _buildRegimeCard(
                    title: 'Frozen (-18°C)',
                    days: isHighMoistureProduce ? 'Not Recommended' : '180-365 Days',
                    subtitle: isHighMoistureProduce
                        ? 'Cell rupture risk'
                        : 'Long-term storage',
                    badge: isHighMoistureProduce ? 'Texture Loss' : 'Deep Freeze',
                    badgeColor: isHighMoistureProduce
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF6366F1),
                    icon: Icons.severe_cold_rounded,
                  ),
                  _buildRegimeCard(
                    title: 'MAP + Cold',
                    days: '$caDays Days',
                    subtitle: 'Equilibrium Gas Barrier',
                    badge: '${multiplier}x Extended',
                    badgeColor: const Color(0xFF059669),
                    icon: Icons.shield_outlined,
                    isHighlighted: true,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          // Interactive Arrhenius Q10 Simulator Toggle
          InkWell(
            onTap: () {
              setState(() {
                _showSimulator = !_showSimulator;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF0F766E)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Arrhenius Temperature Shelf-Life Simulator',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Icon(
                    _showSimulator
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          if (_showSimulator) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCCFBF1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Storage Temperature: ${_simulatedTemp.toStringAsFixed(0)}°C',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Estimated: $simulatedDays Days',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF0F766E),
                      inactiveTrackColor: const Color(0xFFCCFBF1),
                      thumbColor: const Color(0xFF0F766E),
                      overlayColor: const Color(0xFF0F766E).withValues(alpha: 0.12),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _simulatedTemp,
                      min: 0.0,
                      max: 35.0,
                      divisions: 35,
                      onChanged: (val) {
                        setState(() {
                          _simulatedTemp = val;
                        });
                      },
                    ),
                  ),
                  const Text(
                    'Calculated via Arrhenius kinetic shelf-life decay model with Q10 = 2.2 factor.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegimeCard({
    required String title,
    required String days,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlighted ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: badgeColor),
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                days,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isHighlighted ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
