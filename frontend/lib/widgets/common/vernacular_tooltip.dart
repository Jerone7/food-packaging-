import 'package:flutter/material.dart';
import '../../services/locale_service.dart';
import '../../theme/app_theme.dart';

/// Represents a bilingual/multilingual technical term definition
/// designed to explain complex food science & packaging concepts
/// to farmers, MSME millers, and local processors.
class VernacularDefinition {
  final String key;
  final String termEn;
  final String termTa;
  final String termHi;
  final String descEn;
  final String descTa;
  final String descHi;
  final String plainSummaryEn;
  final String plainSummaryTa;
  final String plainSummaryHi;

  const VernacularDefinition({
    required this.key,
    required this.termEn,
    required this.termTa,
    required this.termHi,
    required this.descEn,
    required this.descTa,
    required this.descHi,
    required this.plainSummaryEn,
    required this.plainSummaryTa,
    required this.plainSummaryHi,
  });

  /// Retrieve the term title localized for the given language code.
  String getTitle(String langCode) {
    switch (langCode) {
      case 'ta':
        return termTa;
      case 'hi':
        return termHi;
      default:
        return termEn;
    }
  }

  /// Retrieve the technical description localized for the given language code.
  String getDescription(String langCode) {
    switch (langCode) {
      case 'ta':
        return descTa;
      case 'hi':
        return descHi;
      default:
        return descEn;
    }
  }

  /// Retrieve the simplified, farmer-friendly explanation.
  String getPlainSummary(String langCode) {
    switch (langCode) {
      case 'ta':
        return plainSummaryTa;
      case 'hi':
        return plainSummaryHi;
      default:
        return plainSummaryEn;
    }
  }
}

/// Central registry of packaging, barrier science, and shelf-life kinetics terms
/// mapped to English, Tamil, and Hindi vernacular definitions.
class VernacularGlossary {
  static final Map<String, VernacularDefinition> _registry = {
    'aw': const VernacularDefinition(
      key: 'aw',
      termEn: 'Water Activity (aw)',
      termTa: 'நீர் செயல்பாடு (aw)',
      termHi: 'जल गतिविधि (aw)',
      descEn:
          'Thermodynamic measure of free moisture available for microbial proliferation (scale 0.0 - 1.0). Critical for microbial safety.',
      descTa:
          'உணவில் உள்ள இலவச நீரின் அளவு. இது பூஞ்சை, பாக்டீரியா மற்றும் நுண்ணுயிர்கள் வளர்வதற்கு ஏதுவான ஈரப்பதத்தைக் குறிக்கிறது.',
      descHi:
          'खाद्य पदार्थ में बैक्टीरिया और फफूंद के पनपने के लिए उपलब्ध जल की मात्रा (पैमाना 0.0 से 1.0)।',
      plainSummaryEn:
          'Measures how fast moisture causes spoilage. Lower values (below 0.6) prevent fungal and bacterial growth without chemical preservatives.',
      plainSummaryTa:
          'உணவு கெட்டுப்போகாமல் பாதுகாக்க உதவும் ஈரப்பத அளவீடு. 0.6-க்கு கீழ் இருந்தால் பூஞ்சை மற்றும் பாக்டீரியா வளராது.',
      plainSummaryHi:
          'यह बताता है कि खाद्य सामग्री कितनी जल्दी खराब हो सकती है। 0.6 से नीचे होने पर फफूंद नहीं लगती।',
    ),
    'otr': const VernacularDefinition(
      key: 'otr',
      termEn: 'Oxygen Transmission Rate (OTR)',
      termTa: 'ஆக்சிஜன் பரிமாற்ற விகிதம் (OTR)',
      termHi: 'ऑक्सीजन संचरण दर (OTR)',
      descEn:
          'Rate at which oxygen gas permeates through film per unit area and time (cc/m²/day/atm). Primary factor in lipid oxidation and rancidity.',
      descTa:
          'பேக்கேஜிங் பையின் வழியே வெளிக்காற்று (ஆக்சிஜன்) எவ்வளவு வேகமாக ஊடுருவுகிறது என்பதன் அளவீடு (cc/m²/day).',
      descHi:
          'पैकेजिंग परत के पार ऑक्सीजन गैस के गुजरने की गति। यह तेल और वसा के खराब होने का मुख्य कारण है।',
      plainSummaryEn:
          'How easily air leaks into the pouch. Low OTR prevents rancidity, off-odors, and insect growth.',
      plainSummaryTa:
          'பைக்குள் காற்று புகும் அளவு. குறைந்த அளவு இருந்தால் உணவு துர்நாற்றம் அடிக்காமல் காரல் பிடிக்காமல் இருக்கும்.',
      plainSummaryHi:
          'पैकेट में हवा कितनी तेजी से जाती है। कम दर होने से तेल व खाद्य सामग्री खराब नहीं होती।',
    ),
    'wvtr': const VernacularDefinition(
      key: 'wvtr',
      termEn: 'Water Vapor Transmission Rate (WVTR)',
      termTa: 'நீராவி பரிமாற்ற விகிதம் (WVTR)',
      termHi: 'जल वाष्प संचरण दर (WVTR)',
      descEn:
          'Mass of water vapor transmitted through unit area of film in unit time under specified humidity gradients (g/m²/day).',
      descTa:
          'பேக்கேஜிங் பையின் வழியே ஈரப்பதம் அல்லது நீராவி வெளியேறும் அல்லது உள்ளே வரும் வேகம் (g/m²/day).',
      descHi:
          'पैकेट के अंदर या बाहर नमी (भाप) का रिसाव होने की दर (ग्राम/वर्ग मीटर/दिन)।',
      plainSummaryEn:
          'How well the bag stops moisture from entering or escaping. High WVTR causes biscuits to get soggy or powders to clump.',
      plainSummaryTa:
          'ஈரப்பதம் உள்ளே இறங்கி பிஸ்கட் நமுத்துப்போவது அல்லது மசாலா பொடிகள் கட்டிபிடிப்பதை தடுக்கும் திறன்.',
      plainSummaryHi:
          'नमी से सुरक्षा। यह बिस्कुट को नरम होने और मसालों को सीलने से बचाता है।',
    ),
    'emap': const VernacularDefinition(
      key: 'emap',
      termEn: 'Equilibrium Modified Atmosphere Packaging (EMAP)',
      termTa: 'சமநிலை மாற்றப்பட்ட வளிமண்டல பேக்கேஜிங் (EMAP)',
      termHi: 'संतुलित संशोधित वायुमंडलीय पैकेजिंग (EMAP)',
      descEn:
          'Active balancing of crop respiration kinetics with film micro-perforations to maintain optimum O₂ (3-5%) and CO₂ (5-10%) levels.',
      descTa:
          'காய்கறி, பழங்கள் சுவாசிப்பதை பையின் நுண்துளைகளோடு சமநிலைப்படுத்தி, புத்துணர்ச்சியை பல வாரங்கள் நீட்டிக்கும் தொழில்நுட்பம்.',
      descHi:
          'फल और सब्जियों के सांस लेने की दर को नियंत्रित करके उन्हें लंबे समय तक ताजा रखने की वैज्ञानिक तकनीक।',
      plainSummaryEn:
          'A breathable bio-pouch that lets fresh produce "breathe" just enough to slow down decaying without suffocating.',
      plainSummaryTa:
          'காய்கறி, பழங்கள் அழுகாமல் சுவாசிக்க உதவும் சிறப்பு உறை. இது இயற்கை புத்துணர்ச்சியை இரட்டிப்பாக்கும்.',
      plainSummaryHi:
          'सांस लेने योग्य पैकेट जो ताजी उपज को खराब होने से बचाकर प्राकृतिक ताजगी बनाए रखता है।',
    ),
    'astm_d6400': const VernacularDefinition(
      key: 'astm_d6400',
      termEn: 'ASTM D6400 Compostable Standard',
      termTa: 'ASTM D6400 மக்கும் தரநிலை',
      termHi: 'ASTM D6400 कम्पोस्टेबल मानक',
      descEn:
          'International standard specification for plastics designed to compost aerobically in municipal and industrial composting facilities within 180 days.',
      descTa:
          'பேக்கேஜிங் பொருள் மண்ணில் 180 நாட்களுக்குள் இயற்கையாக உரமாக மட்கிவிடும் என்பதற்கான சர்வதேச தரச்சான்றிதழ்.',
      descHi:
          '180 दिनों में खाद में बदल जाने वाली पर्यावरण अनुकूल सामग्री का अंतरराष्ट्रीय मानक प्रमाण पत्र।',
      plainSummaryEn:
          'Certified eco-friendly. The material will naturally dissolve into compost without leaving toxic microplastics.',
      plainSummaryTa:
          'சுற்றுச்சூழலுக்கு பாதுகாப்பானது. இந்த பை மண்ணில் உரமாக மக்கிவிடும், எந்த பிளாஸ்டிக் நஞ்சையும் விடாது.',
      plainSummaryHi:
          'पर्यावरण हितैषी। यह सामग्री मिट्टी में मिलकर प्राकृतिक खाद बन जाती है।',
    ),
    'tensile_strength': const VernacularDefinition(
      key: 'tensile_strength',
      termEn: 'Tensile Strength',
      termTa: 'இழுவிசை வலிமை (Tensile Strength)',
      termHi: 'तन्यता शक्ति (Tensile Strength)',
      descEn:
          'Maximum longitudinal tensile stress a polymer film can withstand before plastic deformation or rupture (measured in MPa).',
      descTa:
          'பேக்கிங் பை சுமை தாங்கும் போது கிழிந்துவிடாமல் அல்லது உடைந்துவிடாமல் தாங்கும் அதிகபட்ச வலிமை.',
      descHi:
          'पैकेट फटने से पहले खिंचाव और भार सहन करने की अधिकतम क्षमता (मेगापास्कल में)।',
      plainSummaryEn:
          'How tough the pouch is against bursting or tearing during transport and rough handling.',
      plainSummaryTa:
          'போக்குவரத்து மற்றும் கையாளுதலின் போது பை கிழியாமல் தாங்கும் பலம்.',
      plainSummaryHi:
          'ढुलाई के दौरान पैकेट के फटने से बचने की मजबूती।',
    ),
    'hermetic_seal': const VernacularDefinition(
      key: 'hermetic_seal',
      termEn: 'Hermetic Seal',
      termTa: 'காற்றுப் புகா சீல் (Hermetic Seal)',
      termHi: 'वायुरोधी सील (Hermetic Seal)',
      descEn:
          'Airtight closure preventing gas, moisture, and microbial ingress across heat-sealed polymer interfaces.',
      descTa:
          'வெளிக்காற்று, வண்டுகள், பூச்சிகள் அல்லது ஈரப்பதம் சிறிதும் உள்ளே புகாத முழுமையான காற்றுப் புகா சீல்.',
      descHi:
          'पूरी तरह से एयरटाइट सील जो हवा, नमी और कीड़ों को अंदर जाने से पूरी तरह रोकती है।',
      plainSummaryEn:
          'Completely airtight seal that keeps food fresh and pest-free for months.',
      plainSummaryTa:
          'காற்று புகாத இறுக்கமான சீலிங். தானியங்கள் மற்றும் மசாலாக்களை வண்டுகள் தாக்காமல் பாதுகாக்கும்.',
      plainSummaryHi:
          'पूरी तरह से बंद सील जो खाद्य सामग्री को महीनों तक कीटों से सुरक्षित रखती है।',
    ),
    'biodegradable': const VernacularDefinition(
      key: 'biodegradable',
      termEn: 'Biodegradable Polymer',
      termTa: 'மக்கும் இயற்கை பிளாஸ்டிக்',
      termHi: 'बायोडिग्रेडेबल सामग्री',
      descEn:
          'Polymeric material capable of undergoing biological degradation into carbon dioxide, water, and biomass under ambient soil conditions.',
      descTa:
          'மண்ணில் உள்ள நுண்ணுயிரிகளால் இயற்கையாக மக்கி உரமாக மாறும் சூழல் நட்பு மக்கும் பொருள்.',
      descHi:
          'सूक्ष्मजीवों द्वारा प्राकृतिक रूप से मिट्टी में घुलनशील होकर खाद में परिवर्तित होने वाली सामग्री।',
      plainSummaryEn:
          'Breaks down naturally like banana leaves without harming farm soil.',
      plainSummaryTa:
          'வாழை இலை போல இயற்கையாக மண்ணோடு மண்ணாக மக்கி மண்ணின் வளத்தைக் காக்கும்.',
      plainSummaryHi:
          'केले के पत्ते की तरह मिट्टी में स्वतः नष्ट हो जाने वाली सामग्री।',
    ),
  };

  /// Lookup a term definition by key (case-insensitive).
  static VernacularDefinition? get(String termKey) {
    return _registry[termKey.toLowerCase().trim()];
  }

  /// Check whether a term exists in the registry.
  static bool hasTerm(String termKey) {
    return _registry.containsKey(termKey.toLowerCase().trim());
  }

  /// Register or override a custom term definition.
  static void register(VernacularDefinition definition) {
    _registry[definition.key.toLowerCase().trim()] = definition;
  }

  /// Return all registered term keys.
  static List<String> get allKeys => _registry.keys.toList();
}

/// A responsive, localized tooltip and info dialog widget that provides
/// simplified vernacular explanations for technical packaging terms in
/// English, Tamil, and Hindi.
class VernacularTooltip extends StatelessWidget {
  final String termKey;
  final Widget? child;
  final bool showIcon;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final String? customTitle;
  final String? customDescription;
  final bool enableDialogOnTap;

  const VernacularTooltip({
    super.key,
    required this.termKey,
    this.child,
    this.showIcon = true,
    this.icon = Icons.info_outline_rounded,
    this.iconSize = 16,
    this.iconColor,
    this.customTitle,
    this.customDescription,
    this.enableDialogOnTap = true,
  });

  /// Convenient helper for wrapping standard food science metrics.
  factory VernacularTooltip.metric({
    Key? key,
    required String termKey,
    required Widget child,
    bool showIcon = true,
  }) {
    return VernacularTooltip(
      key: key,
      termKey: termKey,
      showIcon: showIcon,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = LocaleService().languageCode;
    final def = VernacularGlossary.get(termKey);

    final title = customTitle ?? def?.getTitle(langCode) ?? termKey;
    final plainSummary = def?.getPlainSummary(langCode) ??
        customDescription ??
        'No vernacular explanation available.';
    final tooltipMessage = '$title: $plainSummary';

    final effectiveColor = iconColor ?? AppTheme.primaryTeal;

    final infoWidget = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: ValueKey('vernacular_tap_${termKey.toLowerCase()}'),
        onTap: enableDialogOnTap
            ? () => _showVernacularDialog(context, def, langCode)
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (child != null) child!,
            if (showIcon) ...[
              if (child != null) const SizedBox(width: 4),
              Icon(
                icon,
                size: iconSize,
                color: effectiveColor,
                key: ValueKey('vernacular_icon_${termKey.toLowerCase()}'),
              ),
            ],
          ],
        ),
      ),
    );

    return Tooltip(
      key: ValueKey('vernacular_tooltip_${termKey.toLowerCase()}'),
      message: tooltipMessage,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: AppTheme.getLocalizedTextStyle(
        fontSize: 12,
        color: Colors.white,
        languageCode: langCode,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: infoWidget,
    );
  }

  /// Display a modal bottom sheet / dialog containing rich vernacular definitions.
  void _showVernacularDialog(
    BuildContext context,
    VernacularDefinition? def,
    String langCode,
  ) {
    final title = customTitle ?? def?.getTitle(langCode) ?? termKey;
    final englishTerm = def?.termEn ?? termKey;
    final plainSummary = def?.getPlainSummary(langCode) ??
        customDescription ??
        'Simplified explanation not available.';
    final scientificDesc = def?.getDescription(langCode) ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.borderTeal.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.science_outlined,
                      color: AppTheme.primaryTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          key: const ValueKey('vernacular_dialog_title'),
                          style: AppTheme.getLocalizedTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            languageCode: langCode,
                          ),
                        ),
                        if (englishTerm != title)
                          Text(
                            englishTerm,
                            key: const ValueKey('vernacular_dialog_subtitle'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('vernacular_dialog_close'),
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Farmer & MSME Friendly Explanation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // Emerald green tint
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.emeraldEco.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          size: 18,
                          color: AppTheme.emeraldEco,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          langCode == 'ta'
                              ? 'எளிய விவசாயி / உற்பத்தியாளர் வழிகாட்டி'
                              : langCode == 'hi'
                                  ? 'सरल किसान व उत्पादक गाइड'
                                  : 'Farmer & MSME Practical Guide',
                          style: AppTheme.getLocalizedTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.emeraldEco,
                            languageCode: langCode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plainSummary,
                      key: const ValueKey('vernacular_dialog_plain'),
                      style: AppTheme.getLocalizedTextStyle(
                        fontSize: 14,
                        color: const Color(0xFF166534),
                        languageCode: langCode,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Scientific & Technical Definition
              if (scientificDesc.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.biotech_outlined,
                            size: 18,
                            color: Color(0xFF475569),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            langCode == 'ta'
                                ? 'தொழில்நுட்ப மற்றும் அறிவியல் விவரம்'
                                : langCode == 'hi'
                                    ? 'तकनीकी एवं वैज्ञानिक विवरण'
                                    : 'Scientific & Technical Specification',
                            style: AppTheme.getLocalizedTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                              languageCode: langCode,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scientificDesc,
                        key: const ValueKey('vernacular_dialog_scientific'),
                        style: AppTheme.getLocalizedTextStyle(
                          fontSize: 13,
                          color: const Color(0xFF334155),
                          languageCode: langCode,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
