"""
Empirical Packaging Material Database with Multi-Language Vernacular Metadata.
(Module 22: Multi-Language Support).
Provides localized material records in English, Tamil, and Hindi.
"""

from typing import Dict, List, Optional, Any
from app.schemas.food_data import PackagingMaterialLocalized


LOCALIZED_PACKAGING_MATERIALS: List[Dict[str, Any]] = [
    {
        "material_id": "mat_ldpe",
        "name_en": "Low-Density Polyethylene (LDPE)",
        "name_ta": "குறைந்த அடர்த்தி பாலிஎதிலீன் (LDPE)",
        "name_hi": "कम घनत्व पॉलीथीन (LDPE)",
        "category": "Conventional Polymer",
        "desc_en": "Flexible, heat-sealable polymer with good moisture barrier but high oxygen transmission rate.",
        "desc_ta": "நெகிழ்வான, வெப்ப ஒட்டுதல் கொண்ட பிளாஸ்டிக். சிறந்த ஈரப்பதம் தடுப்புத்திறன் கொண்டது, ஆனால் ஆக்சிஜன் ஊடுருவல் அதிகம்.",
        "desc_hi": "लचीला, हीट-सीलेबल बहुलक। उत्कृष्ट नमी अवरोधक लेकिन उच्च ऑक्सीजन पारगम्यता।",
        "otr": "7,400 cc/m²/day",
        "wvtr": "12.50 g/m²/day",
        "recommended_applications": ["Fresh vegetables", "Bread bags", "Frozen produce liners"],
        "sustainability_score": 42.0,
        "is_biodegradable": False,
        "is_recyclable": True,
    },
    {
        "material_id": "mat_hdpe",
        "name_en": "High-Density Polyethylene (HDPE)",
        "name_ta": "அதி அடர்த்தி பாலிஎதிலீன் (HDPE)",
        "name_hi": "उच्च घनत्व पॉलीथीन (HDPE)",
        "category": "Conventional Polymer",
        "desc_en": "Rigid, translucent polymer offering superior moisture and water vapor barrier protection.",
        "desc_ta": "விறைப்பான, சிறந்த நீராவி மற்றும் ஈரப்பதம் தடுப்புத்திறன் கொண்ட உறுதியான பிளாஸ்டிக்.",
        "desc_hi": "कठोर, अर्ध-पारदर्शी बहुलक जो बेहतर नमी और जल वाष्प अवरोधक सुरक्षा प्रदान करता है।",
        "otr": "1,600 cc/m²/day",
        "wvtr": "3.70 g/m²/day",
        "recommended_applications": ["Milk pouches", "Dry cereal liners", "Chemical containers"],
        "sustainability_score": 48.0,
        "is_biodegradable": False,
        "is_recyclable": True,
    },
    {
        "material_id": "mat_pet",
        "name_en": "Polyethylene Terephthalate (PET / BoPET)",
        "name_ta": "பாலியெஸ்டர் பிலிம் (PET / BoPET)",
        "name_hi": "पॉलिएस्टर फिल्म (PET / BoPET)",
        "category": "Conventional Polymer",
        "desc_en": "High tensile strength, crystal clarity, and excellent aroma and gas retention properties.",
        "desc_ta": "அதிக வலிமை, படிக ஒளிஊடுருவும் தன்மை, சிறந்த வாசனை மற்றும் வாயு தக்கவைப்புத் திறன்.",
        "desc_hi": "उच्च तन्यता शक्ति, उत्कृष्ट स्पष्टता, और बेहतर सुगंध व गैस अवरोधक गुण।",
        "otr": "55.0 cc/m²/day",
        "wvtr": "20.00 g/m²/day",
        "recommended_applications": ["Bottles", "Stand-up pouches outer layer", "Snack laminates"],
        "sustainability_score": 52.0,
        "is_biodegradable": False,
        "is_recyclable": True,
    },
    {
        "material_id": "mat_met_pet",
        "name_en": "Metallized PET (Met-PET)",
        "name_ta": "மெட்டலைஸ் செய்யப்பட்ட பாலியெஸ்டர் (Met-PET)",
        "name_hi": "मेटलाइज्ड पीईटी (Met-PET)",
        "category": "Metallized High-Barrier Film",
        "desc_en": "Ultra-thin aluminium vapor deposition providing intense oxygen, moisture, and UV light barrier.",
        "desc_ta": "அலுமினியம் பூசப்பட்ட அதிநவீன படலம். தீவிர ஆக்சிஜன், ஈரப்பதம் மற்றும் புற ஊதா ஒளி தடுப்புத் திறன்.",
        "desc_hi": "अति पतली एल्यूमीनियम परत युक्त फिल्म, जो ऑक्सीजन, नमी और पराबैंगनी किरणों से उत्कृष्ट सुरक्षा देती है।",
        "otr": "0.65 cc/m²/day",
        "wvtr": "1.00 g/m²/day",
        "recommended_applications": ["Potato chips", "Crisp snacks", "Roasted nuts", "Coffee pouches"],
        "sustainability_score": 38.0,
        "is_biodegradable": False,
        "is_recyclable": False,
    },
    {
        "material_id": "mat_alu_foil",
        "name_en": "Aluminium Foil Multi-layer Laminate (PET/Al/PE)",
        "name_ta": "அலுமினியம் தாள் பல அடுக்கு லேமினேட் (PET/Al/PE)",
        "name_hi": "एल्यूमिनियम फॉयल मल्टी-लेयर लैमिनेट (PET/Al/PE)",
        "category": "High-Barrier Retort Laminate",
        "desc_en": "Impermeable absolute barrier against oxygen, water vapor, light, and micro-organisms.",
        "desc_ta": "ஆக்சிஜன், நீராவி, சூரிய ஒளி மற்றும் நுண்ணுயிரிகளுக்கு எதிரான முழுமையான ஊடுருவ முடியாத கவசம்.",
        "desc_hi": "ऑक्सीजन, जल वाष्प, प्रकाश और सूक्ष्मजीवों के खिलाफ पूर्ण अभेद्य सुरक्षा अवरोधक।",
        "otr": "<0.05 cc/m²/day",
        "wvtr": "<0.01 g/m²/day",
        "recommended_applications": ["Ready-to-eat meals", "Retort curries", "Pharmaceuticals", "Milk powder"],
        "sustainability_score": 35.0,
        "is_biodegradable": False,
        "is_recyclable": False,
    },
    {
        "material_id": "mat_pla",
        "name_en": "Poly-Lactic Acid (PLA Bio-Polymer)",
        "name_ta": "மக்கும் பாலி லாக்டிக் அமிலம் (PLA மக்கும் பிளாஸ்டிக்)",
        "name_hi": "बायोडिग्रेडेबल पॉली-लैक्टिक एसिड (PLA)",
        "category": "Biodegradable Bio-Polymer",
        "desc_en": "Cornstarch-derived industrially compostable biopolymer with high clarity and moderate moisture transmission.",
        "desc_ta": "மக்காச்சோள மாவில் இருந்து தயாரிக்கப்படும் மக்கும் பிளாஸ்டிக். இயற்கை உரமாக மாறும் தன்மை கொண்டது.",
        "desc_hi": "मक्का स्टार्च से निर्मित औद्योगिक रूप से कंपोस्टेबल बायो-पॉलिमर, पर्यावरण-अनुकूल विकल्प।",
        "otr": "75.0 cc/m²/day",
        "wvtr": "350.00 g/m²/day",
        "recommended_applications": ["Organic fresh produce", "Salad containers", "Dry food display"],
        "sustainability_score": 88.0,
        "is_biodegradable": True,
        "is_recyclable": False,
    },
    {
        "material_id": "mat_kraft",
        "name_en": "Virgin Kraft Paper / Bio-barrier Coating",
        "name_ta": "சுத்தமான கிராஃப்ட் காகிதம் / மக்கும் பூச்சு",
        "name_hi": "वर्जिन क्राफ्ट पेपर / बायो-बैरियर कोटिंग",
        "category": "Cellulosic & Bio-composite",
        "desc_en": "Renewable unbleached wood fiber with bio-wax coating for sustainable dry product packaging.",
        "desc_ta": "மீண்டும் புதுப்பிக்கத்தக்க மரக்கூழ் மற்றும் இயற்கை மெழுகு பூச்சு கொண்ட மக்கும் காகிதப் பை.",
        "desc_hi": "बायो-वैक्स कोटिंग युक्त नवीकरणीय लकड़ी का रेशा, सूखे उत्पादों के लिए टिकाऊ पैकेजिंग।",
        "otr": "120.0 cc/m²/day",
        "wvtr": "45.00 g/m²/day",
        "recommended_applications": ["Flours", "Dry pulses", "Tea bags", "Artisan bakery"],
        "sustainability_score": 92.0,
        "is_biodegradable": True,
        "is_recyclable": True,
    },
]


class MaterialDatabase:
    """Service helper providing localized packaging material specifications."""

    @staticmethod
    def get_all(locale: str = "en") -> List[PackagingMaterialLocalized]:
        loc = (locale or "en").lower()
        results = []
        for mat in LOCALIZED_PACKAGING_MATERIALS:
            if loc == "ta" and mat.get("name_ta"):
                name = mat["name_ta"]
                desc = mat.get("desc_ta", mat["desc_en"])
            elif loc == "hi" and mat.get("name_hi"):
                name = mat["name_hi"]
                desc = mat.get("desc_hi", mat["desc_en"])
            else:
                name = mat["name_en"]
                desc = mat["desc_en"]

            results.append(
                PackagingMaterialLocalized(
                    material_id=mat["material_id"],
                    name=name,
                    name_en=mat["name_en"],
                    name_ta=mat.get("name_ta"),
                    name_hi=mat.get("name_hi"),
                    category=mat["category"],
                    description=desc,
                    otr=mat["otr"],
                    wvtr=mat["wvtr"],
                    recommended_applications=mat.get("recommended_applications", []),
                    sustainability_score=mat.get("sustainability_score"),
                    is_biodegradable=mat.get("is_biodegradable", False),
                    is_recyclable=mat.get("is_recyclable", False),
                )
            )
        return results

    @staticmethod
    def get_by_id(material_id: str, locale: str = "en") -> Optional[PackagingMaterialLocalized]:
        all_mats = MaterialDatabase.get_all(locale=locale)
        for m in all_mats:
            if m.material_id.lower() == material_id.lower():
                return m
        return None
