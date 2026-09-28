import 'package:flutter/material.dart';
import '../../../models/food_scientific_profile.dart';
import '../../../widgets/modern_card.dart';

class StorageRequirementsCard extends StatelessWidget {
  final FoodScientificProfile profile;

  const StorageRequirementsCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final thermal = profile.thermalAndStorage;
    final kinetics = profile.physiologicalKinetics;
    final traits = profile.physicochemical;

    final hasChilling = thermal.isChillingSensitive ||
        (thermal.chillingInjuryThresholdC != null && thermal.chillingInjuryThresholdC! > 0.0);

    final rhMin = traits.equilibriumRhTargetPct != null
        ? (traits.equilibriumRhTargetPct! - 5).clamp(40.0, 99.0).toStringAsFixed(0)
        : (traits.moisturePct > 80.0 ? '90' : (traits.moisturePct < 15.0 ? '55' : '70'));
    final rhMax = traits.equilibriumRhTargetPct != null
        ? (traits.equilibriumRhTargetPct! + 5).clamp(45.0, 100.0).toStringAsFixed(0)
        : (traits.moisturePct > 80.0 ? '95' : (traits.moisturePct < 15.0 ? '65' : '80'));

    final isEthyleneSensitive = kinetics.ethyleneSensitivity.toLowerCase().contains('high') ||
        kinetics.ethyleneSensitivity.toLowerCase().contains('moderate');

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
                        Icons.warehouse_rounded,
                        size: 18,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Storage & Environmental Safeguards',
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Postharvest Specs',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Optimum warehouse and transport environmental parameters:',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          // Safeguard Metrics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;

              return GridView.count(
                crossAxisCount: isNarrow ? 1 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isNarrow ? 3.4 : 2.5,
                children: [
                  _buildSafeguardItem(
                    icon: Icons.thermostat_rounded,
                    iconColor: const Color(0xFF0284C7),
                    label: 'Optimum Temperature Band',
                    value: '${thermal.optimumTempMinC.toStringAsFixed(0)}°C - ${thermal.optimumTempMaxC.toStringAsFixed(0)}°C',
                    detail: hasChilling
                        ? 'Chilling injury below ${thermal.chillingInjuryThresholdC!.toStringAsFixed(0)}°C'
                        : 'Freezing point at ${thermal.freezingPointC.toStringAsFixed(1)}°C',
                    isAlert: hasChilling,
                  ),
                  _buildSafeguardItem(
                    icon: Icons.water_drop_rounded,
                    iconColor: const Color(0xFF059669),
                    label: 'Target Relative Humidity (RH)',
                    value: '$rhMin% - $rhMax% RH',
                    detail: traits.moisturePct > 80.0
                        ? 'High RH to prevent weight loss'
                        : 'Low RH to prevent mold & caking',
                    isAlert: false,
                  ),
                  _buildSafeguardItem(
                    icon: Icons.bubble_chart_rounded,
                    iconColor: isEthyleneSensitive ? const Color(0xFFD97706) : const Color(0xFF64748B),
                    label: 'Ethylene Co-Storage Rule',
                    value: isEthyleneSensitive ? 'Segregation Mandated' : 'Co-storage Tolerant',
                    detail: isEthyleneSensitive
                        ? 'Do NOT store with Apple/Banana/Melon'
                        : 'Low sensitivity to surrounding ethylene',
                    isAlert: isEthyleneSensitive,
                  ),
                  _buildSafeguardItem(
                    icon: Icons.air_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    label: 'Air Circulation & Ventilation',
                    value: kinetics.respirationRate20c != null && kinetics.respirationRate20c! > 30.0
                        ? 'Continuous Air Exchange'
                        : 'Standard Ambient Air Flow',
                    detail: 'Maintains uniform thermal and gas gradient',
                    isAlert: false,
                  ),
                ],
              );
            },
          ),
          if (hasChilling) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CRITICAL SAFEGUARD: Do NOT store in standard 4°C refrigeration. Target cool room at ${thermal.optimumTempMinC.toStringAsFixed(0)}°C - ${thermal.optimumTempMaxC.toStringAsFixed(0)}°C.',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF991B1B),
                      ),
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

  Widget _buildSafeguardItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String detail,
    required bool isAlert,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAlert ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
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
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isAlert ? const Color(0xFFB45309) : const Color(0xFF94A3B8),
                    fontWeight: isAlert ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
