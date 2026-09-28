import 'package:flutter/material.dart';
import '../../../../models/food_scientific_profile.dart';
import '../../../../models/storage_condition.dart';
import '../../../../theme/app_theme.dart';

class ThermalStabilityGauge extends StatelessWidget {
  final ThermalAndStorage thermalData;
  final StorageMode? currentStorageMode;

  const ThermalStabilityGauge({
    super.key,
    required this.thermalData,
    this.currentStorageMode,
  });

  bool get _hasChillingConflict {
    if (thermalData.chillingInjuryThresholdC == null) return false;
    final threshold = thermalData.chillingInjuryThresholdC!;
    if (currentStorageMode == StorageMode.refrigerated && threshold > 4.0) {
      return true;
    }
    if (currentStorageMode == StorageMode.frozen) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.thermostat_rounded, size: 16, color: AppTheme.primaryTeal),
                  ),
                  WidgetSpan(child: SizedBox(width: 6)),
                  TextSpan(
                    text: 'Thermal & Storage Boundaries',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.emeraldLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.emeraldEco.withValues(alpha: 0.3)),
              ),
              child: Text(
                thermalData.perishability,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.emeraldEco),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Temperature Range Cards
        Row(
          children: [
            Expanded(
              child: _thermalPill(
                'Optimum Safe Range',
                '${thermalData.optimumTempMinC.toStringAsFixed(0)}°C to ${thermalData.optimumTempMaxC.toStringAsFixed(0)}°C',
                Icons.check_circle_outline_rounded,
                AppTheme.emeraldEco,
              ),
            ),
            const SizedBox(width: 8),
            if (thermalData.isChillingSensitive) ...[
              Expanded(
                child: _thermalPill(
                  'Chilling Injury Limit',
                  '< ${thermalData.chillingInjuryThresholdC!.toStringAsFixed(0)}°C',
                  Icons.warning_amber_rounded,
                  const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: _thermalPill(
                'Freezing Point',
                '${thermalData.freezingPointC.toStringAsFixed(1)}°C',
                Icons.ac_unit_rounded,
                const Color(0xFF0284C7),
              ),
            ),
          ],
        ),

        // Shelf Life Indicators
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.bgOffWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _shelfLifeItem('Ambient Freshness', '${thermalData.ambientShelfLifeDays} Days'),
              if (thermalData.refrigeratedShelfLifeDays != null)
                _shelfLifeItem('Cold Storage Shelf Life', '${thermalData.refrigeratedShelfLifeDays} Days'),
              if (thermalData.controlledAtmosphereShelfLifeDays != null)
                _shelfLifeItem('CA / MAP Max Shelf Life', '${thermalData.controlledAtmosphereShelfLifeDays} Days'),
            ],
          ),
        ),

        // Chilling Conflict Warning Alert
        if (_hasChillingConflict) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2), // Light Red
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PHYSIOLOGICAL CHILLING WARNING: Target storage temperature is below the ${thermalData.chillingInjuryThresholdC!.toStringAsFixed(0)}°C chilling injury limit. Pitting, skin browning, and flavor loss will occur!',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _thermalPill(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _shelfLifeItem(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.slateBody)),
        const SizedBox(height: 1),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slateDark)),
      ],
    );
  }
}
