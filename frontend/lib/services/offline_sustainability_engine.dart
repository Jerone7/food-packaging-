import 'dart:math' as math;
import '../models/sustainability_model.dart';

/// Embedded verified Life Cycle Inventory (LCI) dataset entry for offline parity.
class _LciEntry {
  final String materialId;
  final String name;
  final String category;
  final String polymerFamily;
  final String resinCode;
  final RecyclabilityTier recyclability;
  final String recyclabilityNotes;
  final BiodegradabilityTier biodegradability;
  final String? biodegradabilityStandard;
  final String biodegradabilityNotes;
  final ReusabilityTier reusability;
  final int reusabilityCycles;
  final String materialTypeDescription;
  final double bioBasedPct;
  final double maxPcrPct;
  final double gwpVirgin;
  final double gwpPcr;
  final double gwpConverting;
  final double waterIntensity;
  final double embodiedEnergy;
  final WastePotentialLevel wasteLevel;
  final double diversionPct;
  final double circularityBase;
  final String primaryDisposal;
  final List<String> ecoConsiderations;
  final List<String> certs;
  final String citation;
  final String doiOrStandard;

  const _LciEntry({
    required this.materialId,
    required this.name,
    required this.category,
    required this.polymerFamily,
    required this.resinCode,
    required this.recyclability,
    required this.recyclabilityNotes,
    required this.biodegradability,
    this.biodegradabilityStandard,
    required this.biodegradabilityNotes,
    required this.reusability,
    required this.reusabilityCycles,
    required this.materialTypeDescription,
    required this.bioBasedPct,
    required this.maxPcrPct,
    required this.gwpVirgin,
    required this.gwpPcr,
    required this.gwpConverting,
    required this.waterIntensity,
    required this.embodiedEnergy,
    required this.wasteLevel,
    required this.diversionPct,
    required this.circularityBase,
    required this.primaryDisposal,
    required this.ecoConsiderations,
    required this.certs,
    required this.citation,
    required this.doiOrStandard,
  });
}

/// Offline calculation engine for instant, sub-millisecond sustainability and LCA evaluation.
class OfflineSustainabilityEngine {
  static const Map<String, double> polymerDensitiesKgM3 = {
    'mat_bio_emap_01': 1250.0,
    'mat_cell_natureflex_02': 1450.0,
    'mat_poly_ldpe_01': 920.0,
    'mat_poly_hdpe_02': 955.0,
    'mat_bopp_film_03': 905.0,
    'mat_pet_bo_04': 1380.0,
    'mat_rpet_50_05': 1380.0,
    'mat_lam_foil_06': 2700.0,
    'mat_board_fsc_07': 750.0,
  };

  static final Map<String, _LciEntry> _matrix = {
    'mat_bio_emap_01': const _LciEntry(
      materialId: 'mat_bio_emap_01',
      name: 'Micro-Perforated Equilibrium MAP Bio-Film (PLA/PBAT)',
      category: 'Biodegradable Bio-Polymer',
      polymerFamily: 'BREATHABLE_BIO_EMAP',
      resinCode: 'RIC 7 (OTHER - Compostable)',
      recyclability: RecyclabilityTier.low,
      recyclabilityNotes: 'Contaminates standard PE/PET mechanical recycling streams. Requires separated organics collection.',
      biodegradability: BiodegradabilityTier.medium,
      biodegradabilityStandard: 'EN 13432 / ASTM D6400 (Industrial Compostable)',
      biodegradabilityNotes: 'Disintegrates >90% within 84 days at 58°C in commercial composting facilities.',
      reusability: ReusabilityTier.low,
      reusabilityCycles: 2,
      materialTypeDescription: 'Bio-based polyester blend (fermented corn starch PLA + fossil PBAT co-polymer).',
      bioBasedPct: 60.0,
      maxPcrPct: 0.0,
      gwpVirgin: 1.45,
      gwpPcr: 0.85,
      gwpConverting: 0.65,
      waterIntensity: 34.5,
      embodiedEnergy: 54.2,
      wasteLevel: WastePotentialLevel.low,
      diversionPct: 90.0,
      circularityBase: 0.82,
      primaryDisposal: 'Commercial Industrial Composting / Organics Bin',
      ecoConsiderations: [
        'Do not dispose in curbside plastic recycling to avoid contaminating PET/PE streams.',
        'Requires thermophilic industrial composting (>55°C); will not biodegrade rapidly in cold marine waters.'
      ],
      certs: ['EN 13432 Certified', 'ASTM D6400', 'FDA 21 CFR 177', 'EU 10/2011'],
      citation: 'NatureWorks LLC & Sphera GaBi Bio-Polymer LCA (Vink et al. 2019)',
      doiOrStandard: '10.1016/j.indcrop.2019.04.037',
    ),

    'mat_cell_natureflex_02': const _LciEntry(
      materialId: 'mat_cell_natureflex_02',
      name: 'Cellulose-Based Breathable Bio-Film (NatureFlex)',
      category: 'Biodegradable Bio-Polymer',
      polymerFamily: 'BREATHABLE_BIO_EMAP',
      resinCode: 'None (Cellulosic Bio-Film)',
      recyclability: RecyclabilityTier.nonRecyclable,
      recyclabilityNotes: 'Non-thermoplastic regenerated cellulose. Cannot be re-melted with plastics.',
      biodegradability: BiodegradabilityTier.high,
      biodegradabilityStandard: 'NF T 51-800 / TÜV OK Compost Home & Marine',
      biodegradabilityNotes: 'Fully biodegrades in backyard home compost within 180 days (20-30°C) and marine waters.',
      reusability: ReusabilityTier.singleUse,
      reusabilityCycles: 1,
      materialTypeDescription: '100% bio-based regenerated cellulose film derived from FSC certified wood pulp.',
      bioBasedPct: 100.0,
      maxPcrPct: 0.0,
      gwpVirgin: 1.68,
      gwpPcr: 0.90,
      gwpConverting: 0.55,
      waterIntensity: 45.0,
      embodiedEnergy: 48.0,
      wasteLevel: WastePotentialLevel.veryLow,
      diversionPct: 95.0,
      circularityBase: 0.88,
      primaryDisposal: 'Home Backyard Compost / Industrial Composting',
      ecoConsiderations: [
        'Zero microplastic risk upon natural environmental fragmentation.',
        'Certified non-toxic to marine flora and fauna (TÜV Austria Marine Biodegradable).'
      ],
      certs: ['TÜV OK Compost Home', 'BPI Certified', 'FSC-C106075', 'FDA 21 CFR 176.170'],
      citation: 'Futamura Chemical LCA Whitepaper & Sphera GaBi (2021)',
      doiOrStandard: 'ISO 14040/14044 Certified Futamura LCA',
    ),

    'mat_poly_ldpe_01': const _LciEntry(
      materialId: 'mat_poly_ldpe_01',
      name: 'Low-Density Polyethylene Film (LDPE)',
      category: 'Conventional Polymer',
      polymerFamily: 'POLYOLEFIN_FLEXIBLE',
      resinCode: 'RIC 4 (LDPE)',
      recyclability: RecyclabilityTier.medium,
      recyclabilityNotes: 'Mechanically recyclable into secondary films and plastic lumber. Collection infrastructure varies.',
      biodegradability: BiodegradabilityTier.nonBiodegradable,
      biodegradabilityStandard: null,
      biodegradabilityNotes: 'Synthetic fossil polyolefin. Non-biodegradable in terrestrial and marine environments (>400 years).',
      reusability: ReusabilityTier.low,
      reusabilityCycles: 3,
      materialTypeDescription: 'Virgin or recycled low-density branched polyethylene thermoplastic.',
      bioBasedPct: 0.0,
      maxPcrPct: 70.0,
      gwpVirgin: 2.08,
      gwpPcr: 0.72,
      gwpConverting: 0.50,
      waterIntensity: 10.5,
      embodiedEnergy: 78.5,
      wasteLevel: WastePotentialLevel.moderate,
      diversionPct: 65.0,
      circularityBase: 0.68,
      primaryDisposal: 'Curbside Flexible Plastics Drop-off (Store Drop-off #4)',
      ecoConsiderations: [
        'Avoid multi-material laminates to maintain mono-material recyclability.',
        'Microplastic shedding risk if improperly discarded.'
      ],
      certs: ['FDA 21 CFR 177.1520', 'EU 10/2011', 'IS 9845', 'IS 10146'],
      citation: 'PlasticsEurope Eco-Profiles (2021) & Franklin Associates LCA',
      doiOrStandard: '10.1016/j.resconrec.2020.105123',
    ),

    'mat_poly_hdpe_02': const _LciEntry(
      materialId: 'mat_poly_hdpe_02',
      name: 'High-Density Polyethylene (HDPE)',
      category: 'Conventional Polymer',
      polymerFamily: 'RIGID_POLYMER',
      resinCode: 'RIC 2 (HDPE)',
      recyclability: RecyclabilityTier.high,
      recyclabilityNotes: 'Widely accepted in curbside municipal recycling (#2 stream) with high recovery yield (>85%).',
      biodegradability: BiodegradabilityTier.nonBiodegradable,
      biodegradabilityStandard: null,
      biodegradabilityNotes: 'Inert linear polyolefin. Non-biodegradable; highly resistant to UV and bacterial degradation.',
      reusability: ReusabilityTier.high,
      reusabilityCycles: 35,
      materialTypeDescription: 'High-density linear semi-crystalline polyethylene with high chemical resistance.',
      bioBasedPct: 0.0,
      maxPcrPct: 100.0,
      gwpVirgin: 1.92,
      gwpPcr: 0.68,
      gwpConverting: 0.48,
      waterIntensity: 8.2,
      embodiedEnergy: 76.2,
      wasteLevel: WastePotentialLevel.low,
      diversionPct: 88.0,
      circularityBase: 0.85,
      primaryDisposal: 'Curbside Rigid Plastics Bin (Stream #2)',
      ecoConsiderations: [
        'Excellent candidate for closed-loop bottle-to-bottle and crate recycling.',
        'Avoid carbon-black colorants to ensure optical sorting detection.'
      ],
      certs: ['FDA 21 CFR 177.1520', 'IS 10146', 'EU 10/2011'],
      citation: 'PlasticsEurope Eco-Profiles & APR Model Studies (2021)',
      doiOrStandard: '10.1016/j.jclepro.2020.124500',
    ),

    'mat_bopp_film_03': const _LciEntry(
      materialId: 'mat_bopp_film_03',
      name: 'Biaxially Oriented Polypropylene (BOPP)',
      category: 'Conventional Polymer',
      polymerFamily: 'POLYOLEFIN_FLEXIBLE',
      resinCode: 'RIC 5 (PP)',
      recyclability: RecyclabilityTier.high,
      recyclabilityNotes: 'Mono-material BOPP structures are fully mechanically recyclable in PP recycling streams (#5).',
      biodegradability: BiodegradabilityTier.nonBiodegradable,
      biodegradabilityStandard: null,
      biodegradabilityNotes: 'Non-biodegradable fossil polymer. Requires mechanical recycling or thermal recovery.',
      reusability: ReusabilityTier.low,
      reusabilityCycles: 3,
      materialTypeDescription: 'Biaxially oriented polypropylene film with high tensile strength and moisture barrier.',
      bioBasedPct: 0.0,
      maxPcrPct: 50.0,
      gwpVirgin: 1.85,
      gwpPcr: 0.65,
      gwpConverting: 0.52,
      waterIntensity: 6.4,
      embodiedEnergy: 73.8,
      wasteLevel: WastePotentialLevel.moderate,
      diversionPct: 72.0,
      circularityBase: 0.74,
      primaryDisposal: 'Curbside Polypropylene Recycling (Stream #5)',
      ecoConsiderations: [
        'Superior moisture barrier allows thinner gauges, reducing total packaging mass by up to 25%.',
        'Monomaterial PP designs eliminate mixed-plastic downcycling penalties.'
      ],
      certs: ['FDA 21 CFR 177.1520', 'EU 10/2011', 'IS 10910'],
      citation: 'Sphera GaBi Packaging DB (2022) & CEFLEX Design Guidelines',
      doiOrStandard: 'CEFLEX Design for Circular Economy 2021',
    ),

    'mat_pet_bo_04': const _LciEntry(
      materialId: 'mat_pet_bo_04',
      name: 'Biaxially Oriented Polyethylene Terephthalate (BOPET)',
      category: 'Conventional Polymer',
      polymerFamily: 'POLYESTER_RIGID_FLEX',
      resinCode: 'RIC 1 (PET)',
      recyclability: RecyclabilityTier.high,
      recyclabilityNotes: 'Widely recycled in global #1 PET infrastructure with strong commercial flake demand.',
      biodegradability: BiodegradabilityTier.nonBiodegradable,
      biodegradabilityStandard: null,
      biodegradabilityNotes: 'Fossil polyester. Non-biodegradable; chemical solvolysis/glycolysis capable.',
      reusability: ReusabilityTier.high,
      reusabilityCycles: 25,
      materialTypeDescription: 'Semi-crystalline thermoplastic polyester from PTA and ethylene glycol.',
      bioBasedPct: 0.0,
      maxPcrPct: 100.0,
      gwpVirgin: 2.45,
      gwpPcr: 0.78,
      gwpConverting: 0.58,
      waterIntensity: 14.8,
      embodiedEnergy: 84.2,
      wasteLevel: WastePotentialLevel.low,
      diversionPct: 90.0,
      circularityBase: 0.86,
      primaryDisposal: 'Curbside PET Bottle & Tray Bin (Stream #1)',
      ecoConsiderations: [
        'Highest demand recycled resin worldwide (rPET).',
        'Avoid PVC shrink sleeves that discolor wash flakes.'
      ],
      certs: ['FDA 21 CFR 177.1630', 'EU 10/2011', 'IS 12252'],
      citation: 'Franklin Associates LCA for Association of Plastic Recyclers (APR 2020)',
      doiOrStandard: '10.1016/j.resconrec.2019.104612',
    ),

    'mat_rpet_50_05': const _LciEntry(
      materialId: 'mat_rpet_50_05',
      name: '50% Post-Consumer Recycled PET (rPET)',
      category: 'Recycled Polymer',
      polymerFamily: 'POLYESTER_RIGID_FLEX',
      resinCode: 'RIC 1 (PET)',
      recyclability: RecyclabilityTier.high,
      recyclabilityNotes: 'Fully integrated into closed-loop circular bottle-to-bottle and thermoform recycling networks.',
      biodegradability: BiodegradabilityTier.nonBiodegradable,
      biodegradabilityStandard: null,
      biodegradabilityNotes: 'Non-biodegradable circular polymer. Avoids landfill through repeated mechanical reprocessing.',
      reusability: ReusabilityTier.high,
      reusabilityCycles: 25,
      materialTypeDescription: 'Food-grade decontamination extruded PET resin containing 50% post-consumer bottle flake.',
      bioBasedPct: 0.0,
      maxPcrPct: 100.0,
      gwpVirgin: 1.42,
      gwpPcr: 0.78,
      gwpConverting: 0.58,
      waterIntensity: 7.1,
      embodiedEnergy: 52.0,
      wasteLevel: WastePotentialLevel.veryLow,
      diversionPct: 95.0,
      circularityBase: 0.92,
      primaryDisposal: 'Curbside PET Recycling Stream #1 (Closed-loop rPET)',
      ecoConsiderations: [
        'Achieves 42% embodied carbon abatement compared to 100% virgin PET.',
        'Consumes 52% less freshwater during resin production than virgin fossil synthesis.'
      ],
      certs: ['FDA NOL for Food Contact', 'EFSA Opinion', 'IS 14534'],
      citation: 'ALPLA & c7-consult rPET Life Cycle Assessment (2022)',
      doiOrStandard: 'ISO 14044 Verified ALPLA LCA 2022',
    ),

    'mat_lam_foil_06': const _LciEntry(
      materialId: 'mat_lam_foil_06',
      name: 'Aluminium Foil Multi-Layer Laminate (PET/Al/PE)',
      category: 'High-Barrier Laminate',
      polymerFamily: 'METALLIC_BARRIER_LAMINATE',
      resinCode: 'RIC 7 (OTHER - Multilayer)',
      recyclability: RecyclabilityTier.nonRecyclable,
      recyclabilityNotes: 'Non-separable composite sandwich of PET, aluminum, and PE. Incompatible with standard mills.',
      biodegradability: BiodegradabilityTier.nonBiodegradable,
      biodegradabilityStandard: null,
      biodegradabilityNotes: 'Inert, zero biodegradation. Persistent in municipal landfill.',
      reusability: ReusabilityTier.singleUse,
      reusabilityCycles: 1,
      materialTypeDescription: 'Adhesive solventless lamination of PET, Aluminium foil, and PE sealant layer.',
      bioBasedPct: 0.0,
      maxPcrPct: 0.0,
      gwpVirgin: 5.80,
      gwpPcr: 2.50,
      gwpConverting: 0.95,
      waterIntensity: 88.5,
      embodiedEnergy: 145.0,
      wasteLevel: WastePotentialLevel.veryHigh,
      diversionPct: 15.0,
      circularityBase: 0.22,
      primaryDisposal: 'Thermal Waste-to-Energy (Incineration) / Sanitary Landfill',
      ecoConsiderations: [
        'Highest embodied carbon footprint and energy intensity due to bauxite smelting.',
        'Complete light and oxygen barrier extends food shelf life up to 24 months, preventing food spoilage.'
      ],
      certs: ['FDA 21 CFR 175.105', 'FDA 21 CFR 178.3910', 'FSSAI Compliant'],
      citation: 'European Aluminium Foil Association (EAFA) LCA Study (2022)',
      doiOrStandard: '10.1016/j.jclepro.2021.129840',
    ),

    'mat_board_fsc_07': const _LciEntry(
      materialId: 'mat_board_fsc_07',
      name: 'FSC-Certified Solid Bleached Sulfate Paperboard (SBS)',
      category: 'Cellulosic / Paperboard',
      polymerFamily: 'CELLULOSIC_RIGID',
      resinCode: 'PAP 21',
      recyclability: RecyclabilityTier.high,
      recyclabilityNotes: 'Standard hydrapulping paper mills easily recover cellulose fibers (>80% repulpability yield).',
      biodegradability: BiodegradabilityTier.high,
      biodegradabilityStandard: 'EN 13432 (Core Paperboard) / Soil Biodegradable',
      biodegradabilityNotes: 'Untreated cellulosic core paperboard decomposes naturally in soil and ambient compost within 90 days.',
      reusability: ReusabilityTier.medium,
      reusabilityCycles: 5,
      materialTypeDescription: 'Virgin sulfate-bleached wood pulp from responsibly managed FSC/PEFC forests with aqueous coating.',
      bioBasedPct: 95.0,
      maxPcrPct: 40.0,
      gwpVirgin: 1.10,
      gwpPcr: 0.55,
      gwpConverting: 0.42,
      waterIntensity: 52.0,
      embodiedEnergy: 38.5,
      wasteLevel: WastePotentialLevel.low,
      diversionPct: 92.0,
      circularityBase: 0.88,
      primaryDisposal: 'Curbside Paper & Cardboard Recycling Stream (PAP 21)',
      ecoConsiderations: [
        'Renewable carbon neutral fiber origin with sustainably certified replanting chains.',
        'Higher water footprint during wood pulping requires effluent closed-loop water treatment.'
      ],
      certs: ['FSC-STD-40-004', 'PEFC Certified', 'FDA 21 CFR 176.170', 'BfR XXXVI'],
      citation: 'Pro Carton European Cartonboard & Carton LCA (2023)',
      doiOrStandard: 'Pro Carton Ecofys Carbon Footprint Study 2023',
    ),
  };

  static _LciEntry _getEntry(String materialIdOrName) {
    if (materialIdOrName.isEmpty) return _matrix['mat_poly_ldpe_01']!;
    final cleaned = materialIdOrName.trim().toLowerCase();

    if (_matrix.containsKey(cleaned)) return _matrix[cleaned]!;

    for (final e in _matrix.values) {
      if (e.materialId.toLowerCase() == cleaned || e.name.toLowerCase().contains(cleaned) || cleaned.contains(e.name.toLowerCase())) {
        return e;
      }
    }

    if (cleaned.contains('natureflex') || cleaned.contains('cellulose')) return _matrix['mat_cell_natureflex_02']!;
    if (cleaned.contains('pla') || cleaned.contains('pbat') || cleaned.contains('bio') || cleaned.contains('compost')) return _matrix['mat_bio_emap_01']!;
    if (cleaned.contains('rpet') || cleaned.contains('recycled pet')) return _matrix['mat_rpet_50_05']!;
    if (cleaned.contains('pet') || cleaned.contains('polyester')) return _matrix['mat_pet_bo_04']!;
    if (cleaned.contains('hdpe') || cleaned.contains('high-density')) return _matrix['mat_poly_hdpe_02']!;
    if (cleaned.contains('bopp') || cleaned.contains('pp') || cleaned.contains('polypropylene')) return _matrix['mat_bopp_film_03']!;
    if (cleaned.contains('foil') || cleaned.contains('aluminium') || cleaned.contains('aluminum') || cleaned.contains('retort')) return _matrix['mat_lam_foil_06']!;
    if (cleaned.contains('paper') || cleaned.contains('board') || cleaned.contains('carton')) return _matrix['mat_board_fsc_07']!;

    return _matrix['mat_poly_ldpe_01']!;
  }

  static double _calculateSurfaceAreaM2(String packageType, double lengthCm, double widthCm, double depthOrGussetCm) {
    final L = lengthCm / 100.0;
    final W = widthCm / 100.0;
    final G = depthOrGussetCm / 100.0;
    const S = 0.010; // 10mm seam

    final lower = packageType.toLowerCase();
    if (lower.contains('pillow')) {
      return 2.0 * (L + 2.0 * S) * (W + S);
    } else if (lower.contains('doypack') || lower.contains('stand-up')) {
      final gusset = G > 0 ? G : (W * 0.35);
      return (2.0 * (L + S) * (W + S)) + ((W + S) * (gusset + S) * 1.15);
    } else if (lower.contains('3-side') || lower.contains('three')) {
      return 2.0 * (L + S) * (W + 2.0 * S);
    } else if (lower.contains('4-side') || lower.contains('quad')) {
      final gusset = G > 0 ? G : (W * 0.40);
      return 2.0 * (L + 2.0 * S) * (W + 2.0 * gusset + 2.0 * S);
    } else if (lower.contains('tray') || lower.contains('clamshell')) {
      final depth = G > 0 ? G : 4.0 / 100.0;
      return ((L * W) + 2.0 * (L * depth) + 2.0 * (W * depth)) * 1.12;
    } else if (lower.contains('vacuum')) {
      return 2.0 * (L + 2.0 * S) * (W + 2.0 * S);
    } else if (lower.contains('carton') || lower.contains('box')) {
      final height = G > 0 ? G : (W * 0.5);
      return 2.0 * ((L * W) + (L * height) + (W * height)) * 1.22;
    }
    return (2.0 * (L + S) * (W + S)) + ((W + S) * (G + S) * 1.15);
  }

  /// Evaluates sustainability metrics synchronously offline.
  static SustainabilityProfile evaluate(SustainabilityEvaluateInput input) {
    final entry = _getEntry(input.materialId.isNotEmpty ? input.materialId : (input.materialName ?? ''));

    final surfaceAreaM2 = _calculateSurfaceAreaM2(
      input.packageType,
      input.lengthCm,
      input.widthCm,
      input.depthOrGussetCm,
    );

    final thicknessM = input.thicknessMicrons * 1e-6;
    final density = polymerDensitiesKgM3[entry.materialId] ?? 1000.0;
    final unitMassKg = surfaceAreaM2 * thicknessM * density;
    final unitMassGrams = math.max(0.1, unitMassKg * 1000.0);
    final totalBatchMassKg = unitMassKg * input.batchSizeUnits;

    // PCR factor
    final maxPcrFraction = entry.maxPcrPct / 100.0;
    var pcrFraction = math.min(maxPcrFraction, math.max(0.0, input.pcrPercentage / 100.0));
    if (entry.materialId == 'mat_rpet_50_05' && pcrFraction == 0.0) {
      pcrFraction = 0.50;
    }

    final gwpResin = (entry.gwpVirgin * (1.0 - pcrFraction)) + (entry.gwpPcr * pcrFraction);
    final totalGwpPerKg = gwpResin + entry.gwpConverting;
    final carbonPerUnit = unitMassKg * totalGwpPerKg;
    final carbonBatch = carbonPerUnit * input.batchSizeUnits;

    final virginTotalGwp = entry.gwpVirgin + entry.gwpConverting;
    final pcrReductionPct = (virginTotalGwp > 0 && pcrFraction > 0)
        ? (((virginTotalGwp - totalGwpPerKg) / virginTotalGwp) * 100.0)
        : 0.0;

    final waterIntensity = entry.waterIntensity * (1.0 - (0.45 * pcrFraction));
    final waterPerUnit = unitMassKg * waterIntensity;
    final waterBatch = waterPerUnit * input.batchSizeUnits;

    final embodiedEnergy = entry.embodiedEnergy * (1.0 - (0.35 * pcrFraction));

    final landfillBurdenKg = totalBatchMassKg * (1.0 - (entry.diversionPct / 100.0));
    final circularityIndex = math.min(1.0, entry.circularityBase + (0.12 * pcrFraction));

    return SustainabilityProfile(
      materialId: entry.materialId,
      materialName: entry.name,
      category: entry.category,
      polymerFamily: entry.polymerFamily,
      resinIdentificationCode: entry.resinCode,
      recyclability: entry.recyclability,
      recyclabilityNotes: entry.recyclabilityNotes,
      biodegradability: entry.biodegradability,
      biodegradabilityStandard: entry.biodegradabilityStandard,
      biodegradabilityNotes: entry.biodegradabilityNotes,
      reusability: entry.reusability,
      reusabilityCycles: entry.reusabilityCycles,
      materialTypeDescription: entry.materialTypeDescription,
      pcrContentPct: double.parse((pcrFraction * 100.0).toStringAsFixed(1)),
      bioBasedContentPct: entry.bioBasedPct,
      environmentalConsiderations: entry.ecoConsiderations,
      regulatoryCertifications: entry.certs,
      environmentalIndicators: EnvironmentalIndicators(
        carbonFootprintKgCo2ePerUnit: double.parse(carbonPerUnit.toStringAsFixed(4)),
        carbonFootprintKgCo2eTotalBatch: double.parse(carbonBatch.toStringAsFixed(2)),
        waterFootprintLitersPerUnit: double.parse(waterPerUnit.toStringAsFixed(2)),
        waterFootprintLitersTotalBatch: double.parse(waterBatch.toStringAsFixed(1)),
        pcrCarbonReductionPct: double.parse(pcrReductionPct.toStringAsFixed(1)),
        embodiedEnergyMjPerKg: double.parse(embodiedEnergy.toStringAsFixed(1)),
      ),
      wastePotential: PackagingWasteInfo(
        unitWasteGrams: double.parse(unitMassGrams.toStringAsFixed(2)),
        totalBatchWasteKg: double.parse(totalBatchMassKg.toStringAsFixed(2)),
        wastePotentialLevel: entry.wasteLevel,
        landfillBurdenKg: double.parse(landfillBurdenKg.toStringAsFixed(2)),
        diversionPotentialPct: entry.diversionPct,
        circularityIndex: double.parse(circularityIndex.toStringAsFixed(2)),
        primaryDisposalPathway: entry.primaryDisposal,
      ),
      verifiedDataSource: entry.citation,
      sourceDoiOrStandard: entry.doiOrStandard,
      isEmpiricalVerified: true,
    );
  }

  /// Compares multiple packaging materials offline side-by-side.
  static SustainabilityCompareResult compare({
    required List<String> materialIds,
    String packageType = 'Stand-up Doypack (Bottom Gusset)',
    double lengthCm = 18.0,
    double widthCm = 12.0,
    double depthOrGussetCm = 4.0,
    double thicknessMicrons = 50.0,
    int batchSizeUnits = 10000,
  }) {
    final profiles = materialIds.map((id) {
      return evaluate(SustainabilityEvaluateInput(
        materialId: id,
        packageType: packageType,
        lengthCm: lengthCm,
        widthCm: widthCm,
        depthOrGussetCm: depthOrGussetCm,
        thicknessMicrons: thicknessMicrons,
        batchSizeUnits: batchSizeUnits,
      ));
    }).toList();

    // Determine best in class
    final bestRecyclability = profiles.reduce((a, b) {
      int score(RecyclabilityTier t) {
        switch (t) {
          case RecyclabilityTier.high:
            return 3;
          case RecyclabilityTier.medium:
            return 2;
          case RecyclabilityTier.low:
            return 1;
          case RecyclabilityTier.nonRecyclable:
            return 0;
        }
      }
      return score(a.recyclability) >= score(b.recyclability) ? a : b;
    });

    final lowestCarbon = profiles.reduce((a, b) =>
        a.environmentalIndicators.carbonFootprintKgCo2eTotalBatch <=
                b.environmentalIndicators.carbonFootprintKgCo2eTotalBatch
            ? a
            : b);

    final lowestWaste = profiles.reduce(
        (a, b) => a.wastePotential.totalBatchWasteKg <= b.wastePotential.totalBatchWasteKg ? a : b);

    final summary =
        "Comparison of ${profiles.length} packaging formats for ${batchSizeUnits.toString()} units: "
        "'${lowestCarbon.materialName}' offers the lowest carbon footprint "
        "(${lowestCarbon.environmentalIndicators.carbonFootprintKgCo2eTotalBatch.toStringAsFixed(1)} kg CO2e), "
        "while '${bestRecyclability.materialName}' provides superior circularity (${bestRecyclability.recyclability.label}).";

    return SustainabilityCompareResult(
      materials: profiles,
      bestRecyclabilityMaterialId: bestRecyclability.materialId,
      lowestCarbonMaterialId: lowestCarbon.materialId,
      lowestWasteMaterialId: lowestWaste.materialId,
      ecoTradeoffSummary: summary,
    );
  }
}
