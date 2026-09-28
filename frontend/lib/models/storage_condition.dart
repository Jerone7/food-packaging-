import 'package:flutter/material.dart';

enum StorageMode {
  roomTemperature,
  refrigerated,
  frozen,
  controlledAtmosphere,
}

extension StorageModeExtension on StorageMode {
  String get displayName {
    switch (this) {
      case StorageMode.roomTemperature:
        return 'Room Temperature';
      case StorageMode.refrigerated:
        return 'Refrigerated';
      case StorageMode.frozen:
        return 'Frozen';
      case StorageMode.controlledAtmosphere:
        return 'Controlled Atmosphere';
    }
  }

  String get temperatureRange {
    switch (this) {
      case StorageMode.roomTemperature:
        return '20°C - 25°C (Ambient)';
      case StorageMode.refrigerated:
        return '2°C - 8°C (Chill Chain)';
      case StorageMode.frozen:
        return '≤ -18°C (Cryogenic)';
      case StorageMode.controlledAtmosphere:
        return 'Low O₂ / MAP Gas Flush';
    }
  }

  IconData get icon {
    switch (this) {
      case StorageMode.roomTemperature:
        return Icons.wb_sunny_outlined;
      case StorageMode.refrigerated:
        return Icons.ac_unit_rounded;
      case StorageMode.frozen:
        return Icons.severe_cold_rounded;
      case StorageMode.controlledAtmosphere:
        return Icons.air_rounded;
    }
  }

  String get apiValue {
    switch (this) {
      case StorageMode.roomTemperature:
        return 'room_temperature';
      case StorageMode.refrigerated:
        return 'refrigerated';
      case StorageMode.frozen:
        return 'frozen';
      case StorageMode.controlledAtmosphere:
        return 'controlled_atmosphere';
    }
  }
}

enum QuantityUnit {
  kg,
  g,
  tonnes,
  units,
}

extension QuantityUnitExtension on QuantityUnit {
  String get label {
    switch (this) {
      case QuantityUnit.kg:
        return 'kg';
      case QuantityUnit.g:
        return 'g';
      case QuantityUnit.tonnes:
        return 'tonnes';
      case QuantityUnit.units:
        return 'units';
    }
  }

  String get fullName {
    switch (this) {
      case QuantityUnit.kg:
        return 'Kilograms (kg)';
      case QuantityUnit.g:
        return 'Grams (g)';
      case QuantityUnit.tonnes:
        return 'Metric Tonnes';
      case QuantityUnit.units:
        return 'Discrete Units';
    }
  }

  double toKilograms(double value, {double unitWeightKg = 0.25}) {
    switch (this) {
      case QuantityUnit.kg:
        return value;
      case QuantityUnit.g:
        return value / 1000.0;
      case QuantityUnit.tonnes:
        return value * 1000.0;
      case QuantityUnit.units:
        return value * unitWeightKg;
    }
  }
}

enum DurationUnit {
  days,
  weeks,
  months,
  years,
}

extension DurationUnitExtension on DurationUnit {
  String get label {
    switch (this) {
      case DurationUnit.days:
        return 'Days';
      case DurationUnit.weeks:
        return 'Weeks';
      case DurationUnit.months:
        return 'Months';
      case DurationUnit.years:
        return 'Years';
    }
  }

  int toDays(int value) {
    switch (this) {
      case DurationUnit.days:
        return value;
      case DurationUnit.weeks:
        return value * 7;
      case DurationUnit.months:
        return value * 30;
      case DurationUnit.years:
        return value * 365;
    }
  }
}

enum TransportMode {
  ambientRoad,
  reeferTruck,
  airFreight,
  seaContainer,
}

extension TransportModeExtension on TransportMode {
  String get displayName {
    switch (this) {
      case TransportMode.ambientRoad:
        return 'Ambient Surface Road';
      case TransportMode.reeferTruck:
        return 'Refrigerated Reefer Truck';
      case TransportMode.airFreight:
        return 'Air Freight Express';
      case TransportMode.seaContainer:
        return 'Sea / Intermodal Container';
    }
  }

  IconData get icon {
    switch (this) {
      case TransportMode.ambientRoad:
        return Icons.local_shipping_outlined;
      case TransportMode.reeferTruck:
        return Icons.kitchen_outlined;
      case TransportMode.airFreight:
        return Icons.flight_takeoff_rounded;
      case TransportMode.seaContainer:
        return Icons.directions_boat_outlined;
    }
  }

  String get apiValue {
    switch (this) {
      case TransportMode.ambientRoad:
        return 'ambient_road';
      case TransportMode.reeferTruck:
        return 'reefer_truck';
      case TransportMode.airFreight:
        return 'air_freight';
      case TransportMode.seaContainer:
        return 'sea_container';
    }
  }
}
