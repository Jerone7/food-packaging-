import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/food_scientific_profile.dart';

enum SensitivityLevel {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case SensitivityLevel.critical:
        return 'CRITICAL';
      case SensitivityLevel.high:
        return 'HIGH';
      case SensitivityLevel.medium:
        return 'MEDIUM';
      case SensitivityLevel.low:
        return 'LOW';
    }
  }

  Color get color {
    switch (this) {
      case SensitivityLevel.critical:
        return const Color(0xFFDC2626); // Strong Red
      case SensitivityLevel.high:
        return const Color(0xFFEF4444); // Red / Orange
      case SensitivityLevel.medium:
        return const Color(0xFFF59E0B); // Amber / Yellow
      case SensitivityLevel.low:
        return const Color(0xFF10B981); // Emerald Green
    }
  }

  Color get backgroundColor {
    switch (this) {
      case SensitivityLevel.critical:
        return const Color(0x29DC2626);
      case SensitivityLevel.high:
        return const Color(0x29EF4444);
      case SensitivityLevel.medium:
        return const Color(0x29F59E0B);
      case SensitivityLevel.low:
        return const Color(0x2910B981);
    }
  }
}

class CriticalVulnerability {
  final String tag;
  final String title;
  final String description;
  final SensitivityLevel severity;
  final IconData icon;

  const CriticalVulnerability({
    required this.tag,
    required this.title,
    required this.description,
    required this.severity,
    required this.icon,
  });
}

class RadarAxisData {
  final String key;
  final String label;
  final double score; // Clamped [0.05, 1.0]
  final String rawValue;
  final IconData icon;
  final SensitivityLevel level;

  const RadarAxisData({
    required this.key,
    required this.label,
    required this.score,
    required this.rawValue,
    required this.icon,
    required this.level,
  });
}

class NormalizedSensitivityItem {
  final String key;
  final String title;
  final double score; // Clamped [0.0, 1.0]
  final SensitivityLevel level;
  final String formattedValue;
  final String consequence;
  final IconData icon;

  const NormalizedSensitivityItem({
    required this.key,
    required this.title,
    required this.score,
    required this.level,
    required this.formattedValue,
    required this.consequence,
    required this.icon,
  });
}

class FoodAnalysisNormalizer {
  /// Normalizes moisture percentage to a 0.05 - 1.0 scale
  static double normalizeMoisture(double moisturePct) {
    if (moisturePct.isNaN || moisturePct.isInfinite) return 0.5;
    return (moisturePct / 100.0).clamp(0.05, 1.0);
  }

  /// Normalizes respiration rate at 20°C (mg CO2/kg/h) to 0.05 - 1.0 scale
  static double normalizeRespiration(double? rate20c, {String? respirationClass}) {
    if (rate20c != null && !rate20c.isNaN && !rate20c.isInfinite && rate20c > 0) {
      return (rate20c / 100.0).clamp(0.05, 1.0);
    }
    
    // Fallback based on respiration class
    final rClass = (respirationClass ?? '').toLowerCase();
    if (rClass.contains('extremely high')) return 0.95;
    if (rClass.contains('very high')) return 0.85;
    if (rClass.contains('high')) return 0.70;
    if (rClass.contains('moderate') || rClass.contains('medium')) return 0.45;
    if (rClass.contains('low')) return 0.20;
    if (rClass.contains('very low')) return 0.10;
    return 0.30;
  }

  /// Normalizes qualitative sensitivity strings to numeric 0.0 - 1.0
  static double normalizeSensitivity(String sensitivity) {
    final s = sensitivity.trim().toLowerCase();
    if (s.contains('critical') || s.contains('extremely high') || s.contains('severe')) {
      return 1.0;
    }
    if (s.contains('very high')) {
      return 0.90;
    }
    if (s.contains('high') || s.contains('chilling sensitive') || s.contains('chilling_sensitive')) {
      return 0.80;
    }
    if (s.contains('moderate') || s.contains('medium')) {
      return 0.50;
    }
    if (s.contains('low') || s.contains('tolerant')) {
      return 0.20;
    }
    if (s.contains('very low') || s.contains('none') || s.contains('negligible')) {
      return 0.10;
    }
    return 0.40;
  }

  /// Categorizes a normalized 0.0 - 1.0 score into SensitivityLevel
  static SensitivityLevel classifySensitivityLevel(double score) {
    if (score >= 0.90) return SensitivityLevel.critical;
    if (score >= 0.70) return SensitivityLevel.high;
    if (score >= 0.40) return SensitivityLevel.medium;
    return SensitivityLevel.low;
  }

  /// Computes the 6 radial dimensions for the Characteristics Radar Chart
  static List<RadarAxisData> computeRadarAxes(FoodScientificProfile profile) {
    // 1. Moisture Axis
    final moistureScore = normalizeMoisture(profile.physicochemical.moisturePct);
    final moistureLevel = classifySensitivityLevel(moistureScore);

    // 2. Respiration Kinetics Axis
    final respScore = normalizeRespiration(
      profile.physiologicalKinetics.respirationRate20c,
      respirationClass: profile.physiologicalKinetics.respirationClass,
    );
    final respLevel = classifySensitivityLevel(respScore);

    // 3. Thermal & Chilling Risk Axis
    final hasChilling = profile.thermalAndStorage.isChillingSensitive ||
        (profile.thermalAndStorage.chillingInjuryThresholdC != null &&
            profile.thermalAndStorage.chillingInjuryThresholdC! > 0.0);
    final thermalScore = hasChilling
        ? 0.92
        : normalizeSensitivity(profile.thermalAndStorage.perishability);
    final thermalLevel = classifySensitivityLevel(thermalScore);

    // 4. Ethylene & Volatiles Axis
    final ethyleneScore = normalizeSensitivity(profile.physiologicalKinetics.ethyleneSensitivity);
    final ethyleneLevel = classifySensitivityLevel(ethyleneScore);

    // 5. Mechanical Fragility Axis
    final mechScore = normalizeSensitivity(profile.spoilageAndVulnerabilities.mechanicalSensitivity);
    final mechLevel = classifySensitivityLevel(mechScore);

    // 6. Gas (O2/CO2) Sensitivity Axis
    final gasScore = normalizeSensitivity(profile.atmosphereSensitivities.oxygenSensitivity);
    final gasLevel = classifySensitivityLevel(gasScore);

    return [
      RadarAxisData(
        key: 'moisture',
        label: 'Moisture',
        score: moistureScore,
        rawValue: '${profile.physicochemical.moisturePct.toStringAsFixed(1)}%',
        icon: Icons.water_drop_rounded,
        level: moistureLevel,
      ),
      RadarAxisData(
        key: 'respiration',
        label: 'Respiration',
        score: respScore,
        rawValue: profile.physiologicalKinetics.respirationRate20c != null
            ? '${profile.physiologicalKinetics.respirationRate20c!.toStringAsFixed(0)} mg/kg/h'
            : profile.physiologicalKinetics.respirationClass,
        icon: Icons.air_rounded,
        level: respLevel,
      ),
      RadarAxisData(
        key: 'thermal',
        label: 'Thermal Risk',
        score: thermalScore,
        rawValue: hasChilling
            ? '< ${profile.thermalAndStorage.chillingInjuryThresholdC!.toStringAsFixed(0)}°C (Chilling)'
            : '${profile.thermalAndStorage.optimumTempMinC.toStringAsFixed(0)}-${profile.thermalAndStorage.optimumTempMaxC.toStringAsFixed(0)}°C',
        icon: Icons.thermostat_rounded,
        level: thermalLevel,
      ),
      RadarAxisData(
        key: 'ethylene',
        label: 'Ethylene',
        score: ethyleneScore,
        rawValue: profile.physiologicalKinetics.ethyleneSensitivity,
        icon: Icons.bubble_chart_rounded,
        level: ethyleneLevel,
      ),
      RadarAxisData(
        key: 'mechanical',
        label: 'Mechanical',
        score: mechScore,
        rawValue: profile.spoilageAndVulnerabilities.mechanicalSensitivity,
        icon: Icons.inventory_2_rounded,
        level: mechLevel,
      ),
      RadarAxisData(
        key: 'gas',
        label: 'Gas Barrier',
        score: gasScore,
        rawValue: profile.atmosphereSensitivities.oxygenSensitivity,
        icon: Icons.cloud_queue_rounded,
        level: gasLevel,
      ),
    ];
  }

  /// Computes the 8 sensitivity bar items for the Bar Matrix
  static List<NormalizedSensitivityItem> computeSensitivityBars(FoodScientificProfile profile) {
    // 1. Moisture Bar
    final moistureScore = normalizeMoisture(profile.physicochemical.moisturePct);
    final moistureLevel = classifySensitivityLevel(moistureScore);

    // 2. Respiration Bar
    final respScore = normalizeRespiration(
      profile.physiologicalKinetics.respirationRate20c,
      respirationClass: profile.physiologicalKinetics.respirationClass,
    );
    final respLevel = classifySensitivityLevel(respScore);

    // 3. Oxygen Sensitivity Bar
    final o2Score = normalizeSensitivity(profile.atmosphereSensitivities.oxygenSensitivity);
    final o2Level = classifySensitivityLevel(o2Score);

    // 4. Perishability Tier Bar
    final perishScore = normalizeSensitivity(profile.thermalAndStorage.perishability);
    final perishLevel = classifySensitivityLevel(perishScore);

    // 5. Temperature / Chilling Bar
    final hasChilling = profile.thermalAndStorage.isChillingSensitive ||
        (profile.thermalAndStorage.chillingInjuryThresholdC != null &&
            profile.thermalAndStorage.chillingInjuryThresholdC! > 0.0);
    final tempScore = hasChilling ? 0.90 : normalizeSensitivity(profile.thermalAndStorage.perishability);
    final tempLevel = classifySensitivityLevel(tempScore);

    // 6. Ethylene Bar
    final ethScore = normalizeSensitivity(profile.physiologicalKinetics.ethyleneSensitivity);
    final ethLevel = classifySensitivityLevel(ethScore);

    // 7. Mechanical Bar
    final mechScore = normalizeSensitivity(profile.spoilageAndVulnerabilities.mechanicalSensitivity);
    final mechLevel = classifySensitivityLevel(mechScore);

    // 8. Light Sensitivity Bar
    final lightScore = normalizeSensitivity(profile.spoilageAndVulnerabilities.lightSensitivity);
    final lightLevel = classifySensitivityLevel(lightScore);

    return [
      NormalizedSensitivityItem(
        key: 'moisture',
        title: 'Moisture Loss / Gain Risk',
        score: moistureScore,
        level: moistureLevel,
        formattedValue: '${profile.physicochemical.moisturePct.toStringAsFixed(1)}%',
        consequence: moistureScore >= 0.75
            ? 'High desiccation & wilting risk; requires high moisture barrier (low WVTR).'
            : (moistureScore <= 0.20
                ? 'Hygroscopic dry matrix; prone to moisture pickup and caking.'
                : 'Balanced water content with moderate barrier requirement.'),
        icon: Icons.water_drop_rounded,
      ),
      NormalizedSensitivityItem(
        key: 'respiration',
        title: 'Respiration Rate (20°C)',
        score: respScore,
        level: respLevel,
        formattedValue: profile.physiologicalKinetics.respirationRate20c != null
            ? '${profile.physiologicalKinetics.respirationRate20c!.toStringAsFixed(0)} mg CO₂/kg/h'
            : profile.physiologicalKinetics.respirationClass,
        consequence: respScore >= 0.70
            ? 'Active metabolism consumes O₂ rapidly; micro-perforated film or high OTR film required.'
            : 'Low respiration; standard hermetic sealing supported without suffocation risk.',
        icon: Icons.air_rounded,
      ),
      NormalizedSensitivityItem(
        key: 'oxygen',
        title: 'Oxygen (O₂) Sensitivity',
        score: o2Score,
        level: o2Level,
        formattedValue: profile.atmosphereSensitivities.oxygenSensitivity,
        consequence: o2Score >= 0.70
            ? 'Vulnerable to lipid oxidation, enzymatic browning, and pigment bleaching; EVOH barrier or O₂ scavenger required.'
            : 'Tolerant to ambient oxygen levels.',
        icon: Icons.cloud_rounded,
      ),
      NormalizedSensitivityItem(
        key: 'perishability',
        title: 'Overall Perishability Tier',
        score: perishScore,
        level: perishLevel,
        formattedValue: profile.thermalAndStorage.perishability,
        consequence: perishScore >= 0.70
            ? 'Short biological lifespan; requires temperature-controlled cold chain logistics.'
            : 'Shelf-stable commodity with high ambient storage resilience.',
        icon: Icons.timer_rounded,
      ),
      NormalizedSensitivityItem(
        key: 'temperature',
        title: 'Thermal & Chilling Risk',
        score: tempScore,
        level: tempLevel,
        formattedValue: hasChilling
            ? 'Chilling (< ${profile.thermalAndStorage.chillingInjuryThresholdC!.toStringAsFixed(0)}°C)'
            : '${profile.thermalAndStorage.optimumTempMinC.toStringAsFixed(0)}-${profile.thermalAndStorage.optimumTempMaxC.toStringAsFixed(0)}°C',
        consequence: hasChilling
            ? 'Prone to chilling injury (pitting, uneven ripening, water-soaking) if stored below ${profile.thermalAndStorage.chillingInjuryThresholdC!.toStringAsFixed(0)}°C.'
            : 'Standard refrigeration (4°C) safe for preservation.',
        icon: Icons.thermostat_rounded,
      ),
      NormalizedSensitivityItem(
        key: 'ethylene',
        title: 'Ethylene Vulnerability',
        score: ethScore,
        level: ethLevel,
        formattedValue: profile.physiologicalKinetics.ethyleneSensitivity,
        consequence: ethScore >= 0.70
            ? 'Accelerated senescence and chlorophyll breakdown from exogenous ethylene; active ethylene scavenger required.'
            : 'Low sensitivity to surrounding ethylene gas.',
        icon: Icons.bubble_chart_rounded,
      ),
      NormalizedSensitivityItem(
        key: 'mechanical',
        title: 'Mechanical Fragility',
        score: mechScore,
        level: mechLevel,
        formattedValue: profile.spoilageAndVulnerabilities.mechanicalSensitivity,
        consequence: mechScore >= 0.70
            ? 'Soft cellular structure prone to bruising, impact crush, and puncture; thermoformed rigid tray or cushioning required.'
            : 'Robust mechanical matrix withstanding standard bulk packing.',
        icon: Icons.inventory_2_rounded,
      ),
      NormalizedSensitivityItem(
        key: 'light',
        title: 'Light / Photo-Oxidation',
        score: lightScore,
        level: lightLevel,
        formattedValue: profile.spoilageAndVulnerabilities.lightSensitivity,
        consequence: lightScore >= 0.70
            ? 'Prone to photo-oxidation, riboflavin degradation, and fat rancidity; UV-blocking or opaque barrier required.'
            : 'Tolerant to ambient retail display lighting.',
        icon: Icons.light_mode_rounded,
      ),
    ];
  }

  /// Evaluates urgent critical alerts for the commodity
  static List<CriticalVulnerability> evaluateCriticalVulnerabilities(FoodScientificProfile profile) {
    final alerts = <CriticalVulnerability>[];

    // 1. Chilling Injury Alert
    if (profile.thermalAndStorage.isChillingSensitive &&
        profile.thermalAndStorage.chillingInjuryThresholdC != null &&
        profile.thermalAndStorage.chillingInjuryThresholdC! > 0.0) {
      final tci = profile.thermalAndStorage.chillingInjuryThresholdC!.toStringAsFixed(0);
      alerts.add(CriticalVulnerability(
        tag: 'CHILLING SENSITIVE (< $tci°C)',
        title: 'Chilling Injury Risk',
        description: 'Tissue pitting and breakdown if stored below $tci°C. Keep in cool cellar (10-15°C), NOT standard 4°C cold room.',
        severity: SensitivityLevel.critical,
        icon: Icons.ac_unit_rounded,
      ));
    }

    // 2. High Respiration Alert
    final rate20c = profile.physiologicalKinetics.respirationRate20c ?? 0.0;
    final rClass = profile.physiologicalKinetics.respirationClass.toLowerCase();
    if (rate20c >= 40.0 || rClass.contains('very high') || rClass.contains('extremely high') || rClass.contains('high')) {
      final rateStr = rate20c > 0 ? '${rate20c.toStringAsFixed(0)} mg CO₂/kg/h' : profile.physiologicalKinetics.respirationClass;
      alerts.add(CriticalVulnerability(
        tag: 'HIGH METABOLIC ACTIVITY',
        title: 'High Respiration Rate ($rateStr)',
        description: 'Rapid O₂ depletion and CO₂ build-up. Micro-perforated film or EMAP equilibrium balance required to avoid anaerobic fermentation.',
        severity: SensitivityLevel.high,
        icon: Icons.air_rounded,
      ));
    }

    // 3. Extreme Moisture Loss / Desiccation
    if (profile.physicochemical.moisturePct >= 85.0 &&
        (profile.physicochemical.moistureSensitivity.toLowerCase().contains('high') ||
            profile.physicochemical.moistureSensitivity.toLowerCase().contains('critical'))) {
      alerts.add(CriticalVulnerability(
        tag: 'HIGH DESICCATION RISK',
        title: 'Moisture Loss Vulnerability (${profile.physicochemical.moisturePct.toStringAsFixed(1)}%)',
        description: 'High water content prone to shriveling and weight loss. High WVTR moisture barrier (< 2.0 g/m²/day) mandated.',
        severity: SensitivityLevel.high,
        icon: Icons.water_drop_rounded,
      ));
    } else if (profile.physicochemical.moisturePct <= 5.0 &&
        (profile.physicochemical.moistureSensitivity.toLowerCase().contains('high') ||
            profile.physicochemical.moistureSensitivity.toLowerCase().contains('critical'))) {
      alerts.add(CriticalVulnerability(
        tag: 'HYGROSCOPIC CAKING RISK',
        title: 'Dry Matrix Moisture Pickup (${profile.physicochemical.moisturePct.toStringAsFixed(1)}%)',
        description: 'Extremely dry commodity prone to atmospheric moisture absorption, crispness loss, and microbial activation. Hermetic foil barrier required.',
        severity: SensitivityLevel.high,
        icon: Icons.grain_rounded,
      ));
    }

    // 4. Ethylene Vulnerability / Cross-Contamination
    if (profile.physiologicalKinetics.ethyleneSensitivity.toLowerCase().contains('high')) {
      alerts.add(const CriticalVulnerability(
        tag: 'ETHYLENE SENSITIVE',
        title: 'Exogenous Ethylene Vulnerability',
        description: 'Segregate from climacteric fruits (Apples, Bananas, Melons, Passion fruit) to prevent accelerated yellowing and premature rotting.',
        severity: SensitivityLevel.high,
        icon: Icons.bubble_chart_rounded,
      ));
    }

    // 5. Oxygen / Lipid Oxidation
    if (profile.atmosphereSensitivities.oxygenSensitivity.toLowerCase().contains('critical') ||
        profile.atmosphereSensitivities.oxygenSensitivity.toLowerCase().contains('high')) {
      alerts.add(const CriticalVulnerability(
        tag: 'HIGH OXYGEN SENSITIVITY',
        title: 'Oxidative Degradation Vulnerability',
        description: 'Prone to rancidity, color loss, or microbial proliferation in ambient air. Low OTR film (< 1.0 cc/m²/day) or active O₂ scavenger recommended.',
        severity: SensitivityLevel.high,
        icon: Icons.cloud_rounded,
      ));
    }

    // 6. Mechanical Fragility
    if (profile.spoilageAndVulnerabilities.mechanicalSensitivity.toLowerCase().contains('high') ||
        profile.spoilageAndVulnerabilities.mechanicalSensitivity.toLowerCase().contains('critical')) {
      alerts.add(const CriticalVulnerability(
        tag: 'FRAGILE COMMODITY',
        title: 'Mechanical Impact Vulnerability',
        description: 'Susceptible to skin puncturing, impact bruising, and vibration settling. Rigid clamshell, cell pack, or corrugated cushioning required.',
        severity: SensitivityLevel.medium,
        icon: Icons.inventory_2_rounded,
      ));
    }

    return alerts;
  }

  /// Calculates the shelf life extension multiplier between ambient and MAP storage
  static double computeExtensionMultiplier(int ambientDays, int? caDays) {
    if (ambientDays <= 0) return 1.0;
    if (caDays == null || caDays <= 0) return 1.0;
    final multiplier = caDays / ambientDays;
    return double.parse(multiplier.toStringAsFixed(1));
  }

  /// Arrhenius Q10 kinetic estimate of shelf life across temperatures
  static double estimateArrheniusShelfLife(
    int baseDays,
    double baseTemp,
    double targetTemp, {
    double q10 = 2.2,
  }) {
    if (baseDays <= 0) return 1.0;
    final deltaT = (baseTemp - targetTemp) / 10.0;
    final estimatedDays = baseDays * math.pow(q10, deltaT);
    return double.parse(estimatedDays.clamp(0.5, 730.0).toStringAsFixed(1));
  }
}
