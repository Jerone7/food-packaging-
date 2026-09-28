import 'food_commodity.dart';
import 'storage_condition.dart';

class TransportCondition {
  final TransportMode mode;
  final int transitDays;
  final bool isFragile;

  const TransportCondition({
    this.mode = TransportMode.ambientRoad,
    this.transitDays = 2,
    this.isFragile = false,
  });

  Map<String, dynamic> toJson() => {
        'mode': mode.apiValue,
        'transit_days': transitDays,
        'is_fragile': isFragile,
      };

  factory TransportCondition.fromJson(Map<String, dynamic> json) {
    TransportMode mode = TransportMode.ambientRoad;
    for (final m in TransportMode.values) {
      if (m.apiValue == json['mode']) {
        mode = m;
        break;
      }
    }
    return TransportCondition(
      mode: mode,
      transitDays: (json['transit_days'] as num?)?.toInt() ?? 2,
      isFragile: json['is_fragile'] as bool? ?? false,
    );
  }
}

class FoodAnalysisRequest {
  final int? foodId;
  final String commodityName;
  final String category;
  final BiochemicalProfile biochemicalProfile;
  final double quantity;
  final QuantityUnit unit;
  final double normalizedQuantityKg;
  final StorageMode storageCondition;
  final int storageDurationDays;
  final TransportCondition? transportCondition;
  final bool ecoFriendlyPriority;

  const FoodAnalysisRequest({
    this.foodId,
    required this.commodityName,
    required this.category,
    required this.biochemicalProfile,
    required this.quantity,
    required this.unit,
    required this.normalizedQuantityKg,
    required this.storageCondition,
    required this.storageDurationDays,
    this.transportCondition,
    this.ecoFriendlyPriority = true,
  });

  Map<String, dynamic> toJson() => {
        'food_id': foodId,
        'commodity_name': commodityName,
        'category': category,
        'biochemical_profile': biochemicalProfile.toJson(),
        'quantity': quantity,
        'unit': unit.label,
        'normalized_quantity_kg': normalizedQuantityKg,
        'storage_condition': storageCondition.apiValue,
        'storage_duration_days': storageDurationDays,
        'transport_condition': transportCondition?.toJson(),
        'eco_friendly_priority': ecoFriendlyPriority,
      };
}
