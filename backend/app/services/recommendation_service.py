"""
Multilingual Explainable AI (XAI) & Spoilage Alert Service (Module 22: Multi-Language Support).
Provides natural language packaging rationale, physiological risk diagnostics,
and vernacular shelf-life preservation warnings in English, Tamil, and Hindi.
"""

from typing import Dict, Any, List, Optional
from dataclasses import dataclass, asdict


@dataclass
class LocalizedScientificRationale:
    summary: str
    key_drivers: List[str]

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class LocalizedSpoilageAlert:
    alert_type: str
    severity: str  # "CRITICAL", "WARNING", "INFO"
    title: str
    message: str
    mitigation: str

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class LocalizedExplainableRecommendation:
    packaging_title: str
    packaging_format: str
    recommendation_explanation: str
    advantages: List[str]
    limitations: List[str]
    suitable_storage_condition: str
    expected_application: str
    important_properties: Dict[str, str]

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


class MultilingualRecommendationService:
    """Core domain service for synthesizing multilingual XAI rationales and spoilage alerts."""

    @classmethod
    def generate_spoilage_alerts(
        cls,
        commodity_name: str,
        input_data: Dict[str, Any],
        locale: str = "en",
    ) -> List[LocalizedSpoilageAlert]:
        """
        Detects physiological risk factors (chilling injury, condensation mold,
        lipid rancidity, anaerobic souring, ethylene senescence) and returns
        vernacular mitigation advice in English, Tamil, or Hindi.
        """
        loc = (locale or "en").lower()
        name = commodity_name or input_data.get("name") or "Commodity"
        moisture = float(input_data.get("moisture_pct") or input_data.get("moisture") or 60.0)
        fat = float(input_data.get("fat_pct") or input_data.get("fat") or 2.0)
        r20 = float(input_data.get("respiration_rate_20c") or 0.0)
        resp_class = str(input_data.get("respiration_class", "")).lower()
        storage_temp = float(input_data.get("storage_temp_c") or input_data.get("storage_temperature_c") or 20.0)
        ci_thresh = float(input_data.get("chilling_injury_threshold_c") or -1.0)
        ethylene = str(input_data.get("ethylene_sensitivity_score") or input_data.get("ethylene_sensitivity") or "low").lower()

        alerts: List[LocalizedSpoilageAlert] = []

        # 1. Chilling Injury Alert
        if ci_thresh > 0.0 and storage_temp < ci_thresh:
            if loc == "ta":
                title = "குளிர் காயம் எச்சரிக்கை (Chilling Injury)"
                msg = f"{name} குளிர் தாங்கும் குறைந்தபட்ச எல்லை {ci_thresh:.1f}°C ஆகும். ஆனால் தற்போதைய வெப்பநிலை {storage_temp:.1f}°C ஆக இருப்பதால் திசு சேதமடைந்து அழுகும் அபாயம் உள்ளது."
                mitigation = f"வெப்பநிலையை உடனடியாக {ci_thresh:.1f}°C முதல் {ci_thresh + 3.0:.1f}°C வரை உயர்த்தவும்."
            elif loc == "hi":
                title = "शीत चोट चेतावनी (Chilling Injury Alert)"
                msg = f"{name} के लिए न्यूनतम सुरक्षित तापमान {ci_thresh:.1f}°C है। वर्तमान तापमान ({storage_temp:.1f}°C) बहुत कम होने से ऊतक नष्ट होने और सड़ने का गंभीर खतरा है।"
                mitigation = f"भंडारण तापमान को तुरंत बढ़ाकर {ci_thresh:.1f}°C से {ci_thresh + 3.0:.1f}°C के बीच करें।"
            else:
                title = "Chilling Injury Hazard"
                msg = f"{name} storage temperature ({storage_temp:.1f}°C) is strictly below its chilling injury floor ({ci_thresh:.1f}°C). Severe surface pitting and internal browning will occur."
                mitigation = f"Elevate holding temperature immediately to {ci_thresh:.1f}°C - {ci_thresh + 3.0:.1f}°C."

            alerts.append(
                LocalizedSpoilageAlert(
                    alert_type="CHILLING_INJURY",
                    severity="CRITICAL",
                    title=title,
                    message=msg,
                    mitigation=mitigation,
                )
            )

        # 2. Moisture Condensation & Mold Risk
        if moisture >= 75.0:
            if loc == "ta":
                title = "பூஞ்சை மற்றும் நீர்த்துளி அபாயம்"
                msg = f"இந்த உணவில் அதிக ஈரப்பதம் ({moisture:.1f}%) உள்ளதால் பைக்குள் நீர்த்துளிகள் படிந்து பூஞ்சை காளான் வளர வாய்ப்புள்ளது."
                mitigation = "பனி மூட்டம் தடுக்கும் (Anti-fog) பூச்சு கொண்ட மைக்ரோ துளையிட்ட பைகளைப் பயன்படுத்தவும்."
            elif loc == "hi":
                title = "नमी और फफूंद का खतरा"
                msg = f"अत्यधिक नमी ({moisture:.1f}%) के कारण पैकेट के अंदर पानी की बूंदें जम सकती हैं, जिससे फफूंद का संक्रमण तेजी से फैलेगा।"
                mitigation = "एंटी-फॉग कोटिंग युक्त व सूक्ष्म छिद्रित (Micro-perforated) फिल्मों का उपयोग करें।"
            else:
                title = "Condensation & Mold Hazard"
                msg = f"High moisture fraction ({moisture:.1f}%) poses severe condensation risk and fungal sporulation inside hermetic packaging."
                mitigation = "Prescribe anti-fog surfactant coating and micro-perforated Equilibrium MAP."

            alerts.append(
                LocalizedSpoilageAlert(
                    alert_type="MOISTURE_CONDENSATION",
                    severity="WARNING",
                    title=title,
                    message=msg,
                    mitigation=mitigation,
                )
            )

        # 3. Lipid Oxidation / Rancidity Alert
        if fat >= 18.0:
            if loc == "ta":
                title = "கொழுப்பு கெட்டுப்போதல் எச்சரிக்கை (Rancidity)"
                msg = f"இதில் அதிக கொழுப்பு ({fat:.1f}%) உள்ளதால் காற்றில் உள்ள ஆக்சிஜன் பட்டு விரைவில் துர்நாற்றமும் சுவை மாற்றமும் ஏற்படும்."
                mitigation = "நைட்ரஜன் வாயு நிரப்பப்பட்ட (N₂ Flush) மெட்டலைஸ் பைகளில் காற்று புகாமல் அடைக்கவும்."
            elif loc == "hi":
                title = "वसा विकृति चेतावनी (Lipid Rancidity)"
                msg = f"उच्च वसा ({fat:.1f}%) होने के कारण हवा की ऑक्सीजन से दुर्गंध और स्वाद में कड़वाहट आने का तीव्र जोखिम है।"
                mitigation = "नाइट्रोजन फ्लश युक्त मेटलाइज्ड या एल्युमिनियम हाई-बैरियर पाउच में पैक करें।"
            else:
                title = "Lipid Rancidity Risk"
                msg = f"Elevated lipid content ({fat:.1f}%) renders food vulnerable to rapid oxidative rancidity and off-flavor synthesis."
                mitigation = "Use ultra-low OTR barrier (< 1.0 cc/m²/day) with 99.5% N₂ inert gas flushing."

            alerts.append(
                LocalizedSpoilageAlert(
                    alert_type="LIPID_OXIDATION",
                    severity="WARNING",
                    title=title,
                    message=msg,
                    mitigation=mitigation,
                )
            )

        # 4. Rapid Respiration Warning
        if r20 >= 20.0 or any(c in resp_class for c in ["high", "very high", "extreme"]):
            if loc == "ta":
                title = "தீவிர சுவாசித்தல் மற்றும் அழுகல் எச்சரிக்கை"
                msg = f"{name} மிக வேகமாக சுவாசிப்பதால் ({r20:.1f} mg CO₂/kg/h) காற்று புகாத பைகளில் ஆக்சிஜன் தீர்ந்து புளித்து கெட்டுவிடும்."
                mitigation = "சரியான காற்றோட்டம் தரும் மக்கும் நுண்துளை பைகளில் அடைக்கவும்."
            elif loc == "hi":
                title = "उच्च श्वसन दर व खट्टापन चेतावनी"
                msg = f"अत्यधिक श्वसन दर ({r20:.1f} mg CO₂/kg/h) के कारण वायुरोधी पैकेट में ऑक्सीजन खत्म होकर उत्पाद खट्टा हो जाएगा।"
                mitigation = "उचित गैस विनिमय वाली छिद्रित बायो-फिल्म (EMAP) का प्रयोग करें।"
            else:
                title = "Anaerobic Fermentation Risk"
                msg = f"Elevated respiration ({r20:.1f} mg CO₂/kg/h) rapidly depletes headspace oxygen in impermeable packs, causing anaerobic fermentation."
                mitigation = "Employ Equilibrium Modified Atmosphere Packaging (EMAP) with controlled OTR permselectivity."

            alerts.append(
                LocalizedSpoilageAlert(
                    alert_type="RESPIRATION_SOURING",
                    severity="WARNING",
                    title=title,
                    message=msg,
                    mitigation=mitigation,
                )
            )

        # 5. Ethylene Sensitivity
        if any(w in ethylene for w in ["high", "crit", "mod"]) or "0.8" in ethylene or "1.0" in ethylene:
            if loc == "ta":
                title = "எத்திலீன் வாயு உணர்திறன் எச்சரிக்கை"
                msg = f"{name} எத்திலீன் வாயுவால் விரைவாக பழுத்து அழுகும் தன்மை கொண்டது."
                mitigation = "பொட்டலத்தினுள் எத்திலீன் உறிஞ்சும் பாக்கெட்டுகளை (KMnO₄ Sachets) வைக்கவும்."
            elif loc == "hi":
                title = "एथिलीन संवेदनशीलता चेतावनी"
                msg = f"{name} एथिलीन गैस के प्रभाव में आकर बहुत जल्दी अधिक पककर खराब हो जाता है।"
                mitigation = "पैकेट में सक्रिय एथिलीन अवशोषक पाउच (KMnO₄) रखें।"
            else:
                title = "Ethylene Accelerated Senescence"
                msg = f"{name} is highly sensitive to endogenous and exogenous ethylene, triggering premature ripening and tissue softening."
                mitigation = "Include active KMnO₄ oxidation sachet to continuously scavenge headspace C₂H₄."

            alerts.append(
                LocalizedSpoilageAlert(
                    alert_type="ETHYLENE_SENESCENCE",
                    severity="INFO",
                    title=title,
                    message=msg,
                    mitigation=mitigation,
                )
            )

        return alerts

    @classmethod
    def generate_scientific_rationale(
        cls,
        commodity_name: str,
        category: str,
        material: Any,
        input_data: Dict[str, Any],
        active_additives: Optional[List[str]] = None,
        locale: str = "en",
    ) -> LocalizedScientificRationale:
        """
        Synthesizes localized scientific rationale and key technical drivers
        in English (technical), Tamil (vernacular guidance), or Hindi.
        """
        loc = (locale or "en").lower()
        name = commodity_name or input_data.get("name") or "Commodity"
        moisture = float(input_data.get("moisture_pct") or input_data.get("moisture") or 60.0)
        fat = float(input_data.get("fat_pct") or input_data.get("fat") or 2.0)
        r20 = float(input_data.get("respiration_rate_20c") or 0.0)
        resp_class = str(input_data.get("respiration_class", "")).lower()
        storage_temp = float(input_data.get("storage_temp_c") or input_data.get("storage_temperature_c") or 20.0)
        ci_thresh = float(input_data.get("chilling_injury_threshold_c") or -1.0)
        mat_name = getattr(material, "name", str(material))

        is_high_resp = r20 >= 15.0 or any(c in resp_class for c in ["high", "very high", "extreme"])

        # Summary Generation
        if loc == "ta":
            if is_high_resp:
                summary = f"{name} அதிக ஈரப்பதம் மற்றும் தீவிர சுவாசித்தல் கொண்டுள்ளதால், பூஞ்சை காளான் வளர்ச்சியை தடுக்கவும் அழுகலைத் தவிர்க்கவும் சீரான காற்றோட்டப் பைகள் (EMAP) பரிந்துரைக்கப்படுகிறது."
            elif fat >= 18.0:
                summary = f"{name} அதிக கொழுப்பு சத்து கொண்டிருப்பதால், ஆக்சிஜனால் கெட்டுப்போகாமல் பாதுகாக்க காற்று புகா நைட்ரஜன் நிரப்பப்பட்ட பைகள் (Met-PET) பரிந்துரைக்கப்படுகிறது."
            elif storage_temp <= -10.0:
                summary = f"{name} உறைநிலை சேமிப்பிற்கு தீவிர குளிர் தாங்கும் உறுதியான பைகள் பரிந்துரைக்கப்படுகிறது."
            elif moisture <= 14.0:
                summary = f"{name} உலர் தானியப் பொருட்கள் ஈரப்பதம் உறிஞ்சி நமுத்துப்போகாமல் பாதுகாக்க நீராவி தடுப்பு கொண்ட கிராஃப்ட் பைகள் பரிந்துரைக்கப்படுகிறது."
            else:
                summary = f"{name} பாதுகாப்பிற்கு சூழலுக்கு உகந்த நீடித்த உறைவிடப் பொருள் {mat_name} பரிந்துரைக்கப்படுகிறது."
        elif loc == "hi":
            if is_high_resp:
                summary = f"{name} में उच्च नमी और तीव्र श्वसन दर है, इसलिए फफूंद व सड़न रोकने हेतु संतुलित वायुमंडलीय पैकेजिंग (EMAP) की सिफारिश की जाती है।"
            elif fat >= 18.0:
                summary = f"{name} में अधिक वसा होने के कारण ऑक्सीकरण से बचाने के लिए नाइट्रोजन गैस युक्त वायुरोधी पैकेजिंग आवश्यक है।"
            elif storage_temp <= -10.0:
                summary = f"{name} के गहरे प्रशीतन के लिए अत्यधिक ठंड प्रतिरोधी पैकेजिंग की सिफारिश की जाती है।"
            elif moisture <= 14.0:
                summary = f"{name} सूखे खाद्य पदार्थों को नमी सोखने और सीलने से बचाने के लिए उच्च नमी-अवरोधक बैग आवश्यक हैं।"
            else:
                summary = f"{name} के संरक्षण के लिए पर्यावरण अनुकूल व टिकाऊ {mat_name} सामग्री की सिफारिश की जाती है।"
        else:
            # English (Technical & Empirical)
            if is_high_resp:
                summary = f"{name} requires Equilibrium Modified Atmosphere Packaging (EMAP) with gas-permeable micro-perforations to maintain physiological equilibrium."
            elif fat >= 18.0:
                summary = f"{name} contains sensitive lipids requiring high-barrier hermetic shielding and inert gas flushing to suppress oxidative rancidity."
            elif storage_temp <= -10.0:
                summary = f"{name} deep-freeze preservation mandates cryogenic-rated polymer with sub-zero puncture resistance."
            elif moisture <= 14.0:
                summary = f"{name} dry bulk storage requires moisture-proof renewable barrier to preserve crispness and prevent caking."
            else:
                summary = f"{name} preservation is optimized with {mat_name} balancing barrier protection and circular sustainability."

        # Key Drivers
        drivers: List[str] = []

        # 1. Respiration driver
        if is_high_resp:
            if loc == "ta":
                drivers.append(f"அதிக சுவாசித்தல் வீதம் ({r20:.1f} mg CO₂/kg/h): ஆக்சிஜன் பற்றாக்குறையால் புளிப்புத்தன்மை ஏற்படுவதை தடுக்க நுண்துளைகள் வழியாக வாயுப் பரிமாற்றம் தேவை.")
            elif loc == "hi":
                drivers.append(f"उच्च श्वसन दर ({r20:.1f} mg CO₂/kg/h): अवायवीय सड़न और खट्टापन रोकने के लिए संतुलित गैस पारगम्यता आवश्यक है।")
            else:
                drivers.append(f"High respiration rate ({r20:.1f} mg CO₂/kg/h) requires gas-permeable micro-perforations to prevent anaerobic fermentation and souring.")

        # 2. Moisture driver
        if moisture >= 75.0:
            if loc == "ta":
                drivers.append(f"அதிக ஈரப்பதம் ({moisture:.1f}%): பைக்குள் நீர் திவலைகள் தங்கி பூஞ்சை பெருகுவதைத் தடுக்க பனிமூட்டம் தடுக்கும் பூச்சு (Anti-fog) அவசியம்.")
            elif loc == "hi":
                drivers.append(f"उच्च नमी सामग्री ({moisture:.1f}%): आंतरिक बूंदों के संघनन और फफूंद को रोकने के लिए एंटी-फॉग कोटिंग की आवश्यकता है।")
            else:
                drivers.append(f"High moisture content ({moisture:.1f}%) requires anti-fog surfactant to prevent internal droplet formation and fungal sporulation.")
        elif moisture <= 8.0:
            if loc == "ta":
                drivers.append(f"குறைந்த ஈரப்பதம் ({moisture:.1f}%): காற்றில் உள்ள ஈரத்தை உறிஞ்சி கட்டியாவதை தடுக்க சிறந்த நீராவி தடுப்பு (WVTR) தேவை.")
            elif loc == "hi":
                drivers.append(f"कम नमी सामग्री ({moisture:.1f}%): सीलन और ढेले बनने से रोकने के लिए उच्च नमी अवरोधक (WVTR) की आवश्यकता है।")
            else:
                drivers.append(f"Low moisture content ({moisture:.1f}%) requires high moisture barrier (WVTR < 2.5 g/m²/day) to prevent hygroscopic water uptake and caking.")

        # 3. Fat driver
        if fat >= 18.0:
            if loc == "ta":
                drivers.append(f"அதிக கொழுப்பு சத்து ({fat:.1f}%): காற்றில் உள்ள ஆக்சிஜனால் எண்ணெய் வாசனை கெடுவதைத் தவிர்க்க மிகக் குறைந்த ஆக்சிஜன் ஊடுருவல் கொண்ட மெட்டலைஸ் பை மற்றும் நைட்ரஜன் நிரப்புதல் தேவை.")
            elif loc == "hi":
                drivers.append(f"अधिक वसा सामग्री ({fat:.1f}%): तेल की दुर्गंध (रैनसिडिटी) को रोकने के लिए अल्ट्रा-लो ऑक्सीजन अवरोधक व नाइट्रोजन गैस अनिवार्य है।")
            else:
                drivers.append(f"Elevated fat content ({fat:.1f}%) mandates ultra-low oxygen transmission rate (< 1.0 cc/m²/day) with inert N₂ headspace flush.")

        # 4. Chilling injury driver
        if ci_thresh > 0.0:
            if storage_temp < ci_thresh:
                if loc == "ta":
                    drivers.append(f"கடுமையான எச்சரிக்கை: சேமிப்பு வெப்பநிலை ({storage_temp:.1f}°C) குளிர் தாங்கும் வரம்பை விட ({ci_thresh:.1f}°C) குறைவாக உள்ளது; தோல் சுருக்கம் மற்றும் அழுகல் ஏற்படும்.")
                elif loc == "hi":
                    drivers.append(f"गंभीर चेतावनी: भंडारण तापमान ({storage_temp:.1f}°C) शीत क्षति सीमा ({ci_thresh:.1f}°C) से कम है; ऊतक सड़न का तीव्र खतरा है।")
                else:
                    drivers.append(f"CRITICAL WARNING: Target storage ({storage_temp:.1f}°C) is below chilling injury floor ({ci_thresh:.1f}°C). Severe pitting risk.")
            else:
                if loc == "ta":
                    drivers.append(f"சேமிப்பு வெப்பநிலை ({storage_temp:.1f}°C) குளிர் காய வரம்புக்கு ({ci_thresh:.1f}°C) மேல் பாதுகாப்பாக உள்ளது.")
                elif loc == "hi":
                    drivers.append(f"भंडारण तापमान ({storage_temp:.1f}°C) शीत क्षति सीमा ({ci_thresh:.1f}°C) से ऊपर सुरक्षित है।")
                else:
                    drivers.append(f"Storage temperature ({storage_temp:.1f}°C) respects the critical chilling injury threshold ({ci_thresh:.1f}°C).")

        # 5. Sustainability driver
        if getattr(material, "sustainability_score", 0.0) >= 80.0:
            if loc == "ta":
                drivers.append("தேர்ந்தெடுக்கப்பட்ட மக்கும் பொருள் 100% இயற்கை உரமாக மாறும் சூழல் பாதுகாப்புத் திறன் கொண்டது.")
            elif loc == "hi":
                drivers.append("चुनी गई बायो-पॉलिमर सामग्री 100% कंपोस्टेबल और पर्यावरण-अनुकूल है।")
            else:
                drivers.append(f"Selected bio-polymer achieves high circular sustainability with industrial/home compostability.")

        if len(drivers) < 2:
            if loc == "ta":
                drivers.append("நீண்ட கால சேமிப்புத் தேவைகளை பூர்த்தி செய்யும் பல அடுக்கு வலிமை.")
                drivers.append("போக்குவரத்தின் போது ஏற்படும் அழுத்தங்களைத் தாங்கும் உறுதித்தன்மை.")
            elif loc == "hi":
                drivers.append("परिवहन के दौरान भौतिक अखंडता और मजबूती सुनिश्चित करता है।")
                drivers.append("भंडारण अवधि के लिए आवश्यक स्थायित्व प्रदान करता है।")
            else:
                drivers.append("Packaging barrier preserves food quality across the specified logistics window.")
                drivers.append("High mechanical tensile strength ensures containment integrity during transit.")

        return LocalizedScientificRationale(
            summary=summary,
            key_drivers=drivers,
        )

    @classmethod
    def generate_explainable_recommendation(
        cls,
        commodity_name: str,
        category: str,
        material: Any,
        input_data: Dict[str, Any],
        is_fragile: bool = False,
        locale: str = "en",
    ) -> LocalizedExplainableRecommendation:
        """
        Generates full explainable recommendation structure localized in English, Tamil, or Hindi.
        """
        loc = (locale or "en").lower()
        name = commodity_name or input_data.get("name") or "Commodity"
        moisture = float(input_data.get("moisture_pct") or input_data.get("moisture") or 60.0)
        fat = float(input_data.get("fat_pct") or input_data.get("fat") or 2.0)
        r20 = float(input_data.get("respiration_rate_20c") or 0.0)
        resp_class = str(input_data.get("respiration_class", "")).lower()
        storage_temp = float(input_data.get("storage_temp_c") or input_data.get("storage_temperature_c") or 20.0)
        ci_thresh = float(input_data.get("chilling_injury_threshold_c") or -1.0)
        mat_name = getattr(material, "name", str(material))

        is_high_resp = r20 >= 15.0 or any(c in resp_class for c in ["high", "very high", "extreme"])

        if loc == "ta":
            if is_high_resp:
                title = "காற்றோட்டமான உணவுப் பாதுகாப்பு பை"
                p_format = "நுண்துளை கொண்ட மக்கும் கிளாம்ஷெல் பெட்டி (Anti-fog Seal)"
                explanation = "இந்த உணவு அதிக சுவாசித்தல் மற்றும் ஈரப்பதம் கொண்டுள்ளதால், பைக்குள் காற்று சுழற்சியும் நீர் மூட்டம் தவிர்ப்பும் தேவைப்படுகிறது."
                advantages = [
                    "சீரான வாயு பரிமாற்றம் மூலம் உணவு புளித்துப்போவது தடுக்கப்படுகிறது",
                    "பனி மூட்டம் தடுக்கும் பூச்சு உள்ளே நீர்த்துளிகள் படிவதை தடுக்கிறது",
                    "100% மக்கும் தன்மை கொண்ட இயற்கை பொருள்",
                ]
                limitations = [
                    "வெற்றிட பேக்கிங் அல்லது அதிக வெப்பநிலைக்கு ஏற்றதல்ல",
                    "குளிர்பதனம் இல்லாவிடில் 14-21 நாட்கள் மட்டுமே பாதுகாக்கும்",
                ]
            elif fat >= 18.0:
                title = "நைட்ரஜன் நிரப்பப்பட்ட உயர் பாதுகாப்பு பை"
                p_format = "மெட்டலைஸ் பில்லோ பை (99.5% N₂ நைட்ரஜன் நிரப்பப்பட்டது)"
                explanation = "இதில் கொழுப்புச் சத்து அதிகம் இருப்பதால், காற்றில் உள்ள ஆக்சிஜனால் கெட்டுப்போகாமல் தடுக்க நைட்ரஜன் நிரப்புதல் அவசியம்."
                advantages = [
                    "அதிநவீன ஆக்சிஜன் தடுப்பு மூலம் எண்ணெய் நாற்றம் ஏற்படுவது தடுக்கப்படுகிறது",
                    "சூரிய ஒளி மற்றும் புற ஊதா கதிர்களை 100% தடுக்கிறது",
                    "நைட்ரஜன் காற்று குஷன் போக்குவரத்தில் நொறுங்காமல் பாதுகாக்கிறது",
                ]
                limitations = [
                    "மக்கும் தன்மை அற்றது; மறுசுழற்சிக்கு அனுப்பப்பட வேண்டும்",
                ]
            else:
                title = f"மேம்படுத்தப்பட்ட {mat_name} பாதுகாப்பு பை"
                p_format = f"உணவுத் தரம் கொண்ட {mat_name} கொள்கலன்"
                explanation = f"{name} பொருட்களின் தரத்தை நீட்டிக்கவும் பாதுகாப்பாக விநியோகிக்கவும் {mat_name} சிறந்த சமநிலையை தருகிறது."
                advantages = [
                    "சிறந்த ஈரப்பதம் மற்றும் தூசி பாதுகாப்பு",
                    "போக்குவரத்தின் போது ஏற்படும் அழுத்தங்களைத் தாங்கும் வலிமை",
                ]
                limitations = [
                    "நேரடி சூரிய ஒளியில் நீண்ட நேரம் வைப்பதைத் தவிர்க்கவும்",
                ]

            storage_cond = f"{storage_temp:.0f}°C குளிர்ந்த காற்றோட்டமான சூழல்"
            expected_app = f"{name} மற்றும் தொடர்புடைய உணவுப் பொருட்கள்"
            props = {
                "ஆக்சிஜன் தடுப்புத் திறன்": "உயர் தடுப்பு",
                "ஈரப்பதம் தடுப்புத்திறன்": "சிறந்தது",
                "சுற்றுச்சூழல் மதிப்பீடு": "உயர் தரம்",
            }
        elif loc == "hi":
            if is_high_resp:
                title = "हवादार खाद्य-ग्रेड पैकेजिंग"
                p_format = "सूक्ष्म छिद्रित बायो-क्लैमशेल (एंटी-फॉग सील के साथ)"
                explanation = "इस खाद्य पदार्थ में उच्च श्वसन व नमी संवेदनशीलता है, जिसके लिए उचित गैस विनिमय और नमी नियंत्रण आवश्यक है।"
                advantages = [
                    "संतुलित वायुमंडल (EMAP) खट्टेपन और सड़ांध को रोकता है",
                    "एंटी-फॉग कोटिंग पैकेट में पानी की बूंदें नहीं जमने देती",
                    "पर्यावरण के अनुकूल 100% कंपोस्टेबल सामग्री",
                ]
                limitations = [
                    "वैक्यूम पैकिंग या उच्च तापमान के लिए उपयुक्त नहीं है",
                    "सामान्य तापमान पर भंडारण अवधि सीमित है",
                ]
            elif fat >= 18.0:
                title = "नाइट्रोजन फ्लश हाई-बैरियर तकिया पाउच"
                p_format = "मेटलाइज्ड लैमिनेट पाउच (99.5% N₂ गैस के साथ)"
                explanation = "इस खाद्य पदार्थ में अधिक वसा होने के कारण ऑक्सीकरण से बचाने के लिए नाइट्रोजन गैस आवश्यक है।"
                advantages = [
                    "अल्ट्रा-लो ऑक्सीजन अवरोधक तेल की दुर्गंध को रोकता है",
                    "प्रकाश और पराबैंगनी किरणों से 100% सुरक्षा",
                    "नाइट्रोजन गैस कुशन परिवहन में टूटने से बचाता है",
                ]
                limitations = [
                    "गैर-बायोडिग्रेडेबल संरचना",
                ]
            else:
                title = f"अनुकूलित {mat_name} पैकेजिंग"
                p_format = f"खाद्य-ग्रेड {mat_name} कंटेनर"
                explanation = f"{name} के संरक्षण के लिए {mat_name} सामग्री उत्कृष्ट सुरक्षा और टिकाऊपन प्रदान करती है।"
                advantages = [
                    "उत्कृष्ट नमी और धूल अवरोधक",
                    "मजबूत तन्यता शक्ति परिवहन में सुरक्षा देती है",
                ]
                limitations = [
                    "सीधी तेज धूप से दूर रखें",
                ]

            storage_cond = f"{storage_temp:.0f}°C ठंडा व हवादार स्थान"
            expected_app = f"{name} और संबंधित खाद्य उत्पाद"
            props = {
                "ऑक्सीजन अवरोधक": "उच्च स्तर",
                "नमी अवरोधक": "उत्कृष्ट",
                "पर्यावरण रेटिंग": "उत्कृष्ट स्कोर",
            }
        else:
            # English
            if is_high_resp:
                title = "Ventilated Food-Grade Packaging"
                p_format = "Micro-Perforated Bio-Clamshell with Anti-Fog Seal"
                explanation = "This option is recommended because the selected food has high respiration and moisture sensitivity, requiring appropriate gas exchange and moisture management."
                advantages = [
                    "Equilibrium modified atmosphere (EMAP) prevents anaerobic souring",
                    "Anti-fog coating suppresses condensation water droplets and mold",
                    "100% compostable bio-polymer with high sustainability index",
                ]
                limitations = [
                    "Not suitable for vacuum packing or high-temperature retort processing",
                    "Storage duration limited to 14-21 days under non-refrigerated ambient conditions",
                ]
            elif fat >= 18.0:
                title = "Nitrogen-Flushed High-Barrier Pillow Pouch"
                p_format = "Metallized Laminate Pillow Pouch with 99.5% N₂ Flush"
                explanation = "This option is recommended because the selected food has elevated lipid content and oxidation sensitivity, requiring hermetic oxygen exclusion and inert nitrogen flush to prevent oxidative rancidity."
                advantages = [
                    "Ultra-low oxygen transmission rate (< 1.0 cc/m²/day) blocks rancidity",
                    "100% light and UV opacity arrests photo-oxidation",
                    "Nitrogen gas cushion provides pneumatic transit protection against crushing",
                ]
                limitations = [
                    "Multi-layer synthetic laminate requires specialized recycling",
                ]
            else:
                title = f"Optimized {mat_name} Packaging"
                p_format = f"Food-Grade {mat_name} Container"
                explanation = f"This option is recommended because {mat_name} delivers balanced barrier protection, mechanical durability, and circular sustainability for {name}."
                advantages = [
                    "Engineered moisture barrier protects texture and freshness",
                    "High tensile strength withstands multi-tier stacking",
                ]
                limitations = [
                    "Avoid prolonged outdoor UV radiation and water submersion",
                ]

            storage_cond = f"Controlled Storage: {storage_temp:.0f}°C, 85-90% RH"
            expected_app = f"Fresh {name} and similar commodities"
            props = {
                "Oxygen Barrier": "High Barrier",
                "Moisture Barrier": "Excellent",
                "Sustainability": "High Circularity",
            }

        return LocalizedExplainableRecommendation(
            packaging_title=title,
            packaging_format=p_format,
            recommendation_explanation=explanation,
            advantages=advantages,
            limitations=limitations,
            suitable_storage_condition=storage_cond,
            expected_application=expected_app,
            important_properties=props,
        )


recommendation_service = MultilingualRecommendationService()
