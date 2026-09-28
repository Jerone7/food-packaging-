"""
Food Data Service & Localized Commodities Matrix (Module 22: Multi-Language Support).
Provides multilingual vernacular commodity retrieval, degradation risk profiles,
and vernacular storage recommendations across English, Tamil, and Hindi.
"""

from typing import Dict, List, Optional, Any
from app.schemas.food_data import FoodCommodityLocalized, LocalizedCategoryResponse


LOCALIZED_COMMODITY_DATA: List[Dict[str, Any]] = [
    # -------------------------------------------------------------------------
    # VEGETABLES
    # -------------------------------------------------------------------------
    {
        "id": "veg_tomato",
        "name_en": "Fresh Tomato",
        "name_ta": "தக்காளி",
        "name_hi": "टमाटर",
        "category": "Vegetables",
        "scientific_name": "Solanum lycopersicum",
        "moisture": 94.5,
        "water_activity": 0.99,
        "respiration": 28.0,
        "spoilage_en": "High moisture loss and vulnerability to Botrytis cinerea rot; excessive moisture condensation induces fungal growth.",
        "spoilage_ta": "அதிக ஈரப்பதம் இழப்பு மற்றும் பூஞ்சை காளான் தாக்குதல் அபாயம்; பைக்குள் நீர்த்துளிகள் படிந்தால் அழுகல் ஏற்படும்.",
        "spoilage_hi": "अत्यधिक नमी की कमी और फफूंद (बोट्राइटिस) का खतरा; पैकेट के अंदर पानी की बूंदें सड़न पैदा करती हैं।",
        "storage_en": "Cool ambient or ventilated cold storage (10-12°C, 85-90% RH). Avoid below 10°C to prevent chilling injury.",
        "storage_ta": "குளிர்ந்த காற்றோட்டமான சூழல் (10-12°C, 85-90% RH). குளிர் காயத்தை தவிர்க்க 10°Cக்கு கீழே வைக்க வேண்டாம்.",
        "storage_hi": "ठंडा व हवादार स्थान (10-12°C, 85-90% RH)। ठंड से होने वाले नुकसान से बचने के लिए 10°C से नीचे न रखें।",
    },
    {
        "id": "veg_spinach",
        "name_en": "Fresh Spinach",
        "name_ta": "பசலைக்கீரை",
        "name_hi": "पालक",
        "category": "Vegetables",
        "scientific_name": "Spinacia oleracea",
        "moisture": 91.4,
        "water_activity": 0.99,
        "respiration": 120.0,
        "spoilage_en": "Extremely high respiration rate causing rapid wilting, chlorosis (leaf yellowing), and bacterial soft rot.",
        "spoilage_ta": "மிக அதிக சுவாசித்தல் வீதம்; இலைகள் விரைவாக வாடுதல், மஞ்சள் நிறமாதல் மற்றும் பாக்டீரியா மென் அழுகல் ஏற்படும்.",
        "spoilage_hi": "अत्यधिक श्वसन दर जिसके कारण पत्तियां जल्दी मुरझाती हैं, पीली पड़ती हैं और सड़ने लगती हैं।",
        "storage_en": "Chilled micro-perforated packaging (0-2°C, 95-100% RH) with controlled anti-fog permeability.",
        "storage_ta": "குளிர்பதன நுண்துளை பை (0-2°C, 95-100% RH) மற்றும் பனி மூட்டம் தடுக்கும் வசதியுடன் வைக்கவும்.",
        "storage_hi": "माइक्रो-छिद्रित पैकेट में प्रशीतित (0-2°C, 95-100% RH) एंटी-फॉग फिल्म के साथ रखें।",
    },
    {
        "id": "veg_potato",
        "name_en": "Potato (Ware)",
        "name_ta": "உருளைக்கிழங்கு",
        "name_hi": "आलू",
        "category": "Vegetables",
        "scientific_name": "Solanum tuberosum",
        "moisture": 79.0,
        "water_activity": 0.98,
        "respiration": 12.0,
        "spoilage_en": "Solanine greening under UV/white light, dormancy loss (sprouting), and soft rot in anaerobic conditions.",
        "spoilage_ta": "வெளிச்சத்தில் சோலனின் நச்சுப்பச்சை உருவாதல், முளை கட்டுதல் மற்றும் காற்று புகா நிலையில் அழுகல்.",
        "spoilage_hi": "प्रकाश में हरापन (सोलेनाइन), अंकुरण और ऑक्सीजन की कमी में सड़न का खतरा।",
        "storage_en": "Dark, well-ventilated ambient environment (8-10°C, 85-90% RH). Never store in direct light or airtight plastics.",
        "storage_ta": "இருண்ட, நல்ல காற்றோட்டமான சூழல் (8-10°C, 85-90% RH). வெளிச்சத்திலோ அல்லது காற்று புகா பிளாஸ்டிக்கிலோ வைக்கக்கூடாது.",
        "storage_hi": "अंधेरे और हवादार स्थान पर रखें (8-10°C, 85-90% RH)। सीधी रोशनी या बंद प्लास्टिक में कभी न रखें।",
    },
    {
        "id": "veg_carrot",
        "name_en": "Carrot",
        "name_ta": "கேரட்",
        "name_hi": "गाजर",
        "category": "Vegetables",
        "scientific_name": "Daucus carota",
        "moisture": 88.0,
        "water_activity": 0.99,
        "respiration": 22.0,
        "spoilage_en": "Surface dehydration (white blush), lignification (loss of crispness), and ethylene-induced bitterness (isocoumarin).",
        "spoilage_ta": "மேற்பரப்பு நீரிழப்பு (வெண் படலம்), நார் தன்மை அதிகரிப்பு மற்றும் எத்திலீனால் கசப்புத் தன்மை அடைதல்.",
        "spoilage_hi": "सतह का सूखना (सफेद परत), कड़ापन और एथिलीन के संपर्क से कड़वाहट आना।",
        "storage_en": "Chilled high-humidity condition (0-2°C, 95-98% RH). Segregate strictly from ethylene generators like apples and bananas.",
        "storage_ta": "குளிர்ந்த அதிக ஈரப்பத சூழல் (0-2°C, 95-98% RH). ஆப்பிள், வாழைப்பழம் போன்ற பழங்களுடன் சேர்த்து வைக்கக்கூடாது.",
        "storage_hi": "ठंडी व उच्च आर्द्रता वाली स्थिति (0-2°C, 95-98% RH)। सेब और केले जैसे एथिलीन उत्पादक फलों से अलग रखें।",
    },
    {
        "id": "veg_onion",
        "name_en": "Onion",
        "name_ta": "வெங்காயம்",
        "name_hi": "प्याज",
        "category": "Vegetables",
        "scientific_name": "Allium cepa",
        "moisture": 86.0,
        "water_activity": 0.97,
        "respiration": 8.0,
        "spoilage_en": "Neck rot (Botrytis allii), black mold (Aspergillus niger), and premature sprouting in high humidity.",
        "spoilage_ta": "அதிக ஈரப்பதத்தில் கழுத்துப்பகுதி அழுகல், கருப்பு பூஞ்சை மற்றும் முன்கூட்டியே முளை கட்டுதல்.",
        "spoilage_hi": "उच्च नमी में गर्दन की सड़न, काली फफूंद और समय से पहले अंकुरण की समस्या।",
        "storage_en": "Dry, well-ventilated mesh containers (0-4°C or ambient 25°C, 65-70% RH). Keep low humidity.",
        "storage_ta": "உலர்ந்த காற்றோட்ட வலைப் பைகள் (0-4°C அல்லது 25°C, 65-70% RH). குறைந்த ஈரப்பதத்தில் பராமரிக்கவும்.",
        "storage_hi": "सूखे और हवादार जालीदार बैग (0-4°C या 25°C, 65-70% RH)। नमी हमेशा कम रखें।",
    },
    {
        "id": "veg_moringa_pod",
        "name_en": "Moringa (Drumstick)",
        "name_ta": "முருங்கைக்காய்",
        "name_hi": "सहजन (ड्रमस्टिक)",
        "category": "Vegetables",
        "scientific_name": "Moringa oleifera pod",
        "moisture": 86.9,
        "water_activity": 0.98,
        "respiration": 35.0,
        "spoilage_en": "Rapid pith desiccation, chlorophyll loss, and fiber hardening within 48 hours under ambient air.",
        "spoilage_ta": "காற்று படுவதால் 48 மணி நேரத்திற்குள் உலர்ந்து போதல், நிறமிழப்பு மற்றும் நார் கடினமாதல்.",
        "spoilage_hi": "खुली हवा में 48 घंटों के भीतर सूखना, रंग उड़ना और रेशे सख्त होना।",
        "storage_en": "MAP perforated polyethylene bags (10-12°C, 90% RH) to preserve chlorophyll and tender texture.",
        "storage_ta": "பசுமை மற்றும் மென்மைத் தன்மையை பாதுகாக்க காற்றோட்ட பாலித்தீன் பைகளில் (10-12°C, 90% RH) சேமிக்கவும்.",
        "storage_hi": "हरेपन और कोमलता को बनाए रखने के लिए छिद्रित पॉलीथीन बैग (10-12°C, 90% RH) में रखें।",
    },
    {
        "id": "veg_moringa_powder",
        "name_en": "Moringa Leaf Powder",
        "name_ta": "முருங்கை இலை பொடி",
        "name_hi": "मोरिंगा पाउडर (सहजन पत्ती चूर्ण)",
        "category": "Vegetables",
        "scientific_name": "Moringa oleifera folium pulvis",
        "moisture": 6.5,
        "water_activity": 0.35,
        "respiration": 0.0,
        "spoilage_en": "Hygroscopic caking, photodegradation of carotenoids and vitamins, and lipid rancidity in the presence of oxygen.",
        "spoilage_ta": "ஈரப்பதம் உறிஞ்சி கட்டியாதல், வைட்டமின்கள் வெளிச்சத்தால் அழிதல் மற்றும் ஆக்சிஜனால் கெட்டுப்போதல்.",
        "spoilage_hi": "नमी सोखकर जमना (केकिंग), धूप से विटामिनों का नष्ट होना और ऑक्सीजन से दुर्गंध आना।",
        "storage_en": "Hermetic high-barrier pouch (Met-PET or Alu-foil) with nitrogen flush or desiccant at ambient temperature.",
        "storage_ta": "அலுமினியம் தாள் அல்லது மெட்டலைஸ் பையில் நைட்ரஜன் நிரப்பி காற்று புகாமல் அறை வெப்பநிலையில் வைக்கவும்.",
        "storage_hi": "मेटलाइज्ड या एल्युमिनियम फॉयल पाउच में नाइट्रोजन फ्लश या सिलिका जेल के साथ रखें।",
    },
    {
        "id": "veg_green_chili",
        "name_en": "Green Chili",
        "name_ta": "பச்சை மிளகாய்",
        "name_hi": "हरी मिर्च",
        "category": "Vegetables",
        "scientific_name": "Capsicum annuum",
        "moisture": 85.7,
        "water_activity": 0.98,
        "respiration": 30.0,
        "spoilage_en": "Moisture loss resulting in calyx shriveling, capsanthin turning red, and Anthracnose fruit rot.",
        "spoilage_ta": "காம்பு காய்ந்து போதல், பழுத்து சிவத்தல் மற்றும் பூஞ்சை அழுகல் நோய் தாக்குதல்.",
        "spoilage_hi": "डंठल का सूखना, समय से पहले लाल होना और फफूंदीय सड़न।",
        "storage_en": "Perforated LDPE packaging at 7-10°C, 90-95% RH to prevent chilling injury and weight loss.",
        "storage_ta": "எடை இழப்பை தடுக்க துளையிட்ட LDPE பைகளில் 7-10°C, 90-95% RH சூழலில் வைக்கவும்.",
        "storage_hi": "वजन घटने से बचाने के लिए छिद्रित LDPE बैग में 7-10°C, 90-95% RH पर रखें।",
    },

    # -------------------------------------------------------------------------
    # FRUITS
    # -------------------------------------------------------------------------
    {
        "id": "fruit_alphonso_mango",
        "name_en": "Alphonso Mango",
        "name_ta": "அல்போன்சா மாம்பழம்",
        "name_hi": "अल्फोंसो आम",
        "category": "Fruits",
        "scientific_name": "Mangifera indica 'Alphonso'",
        "moisture": 83.0,
        "water_activity": 0.98,
        "respiration": 45.0,
        "spoilage_en": "Climacteric peak ripening, stem-end rot (Lasiodiplodia theobromae), and anthracnose decay under high humidity.",
        "spoilage_ta": "விரைவான பழுத்தல், காம்பு அழுகல் மற்றும் அதிக ஈரப்பதத்தால் ஏற்படும் பூஞ்சை புள்ளி நோய்.",
        "spoilage_hi": "तेजी से पकना, तने के सिरे की सड़न और अधिक नमी में एन्थ्रेक्नोज फफूंद का हमला।",
        "storage_en": "Ventilated corrugated cartons with ethylene absorbent (12-14°C, 85-90% RH). Never store below 10°C.",
        "storage_ta": "எத்திலீன் உறிஞ்சும் வசதியுடன் கூடிய பெட்டிகளில் (12-14°C, 85-90% RH) வைக்கவும். 10°Cக்கு கீழ் வைக்கக்கூடாது.",
        "storage_hi": "एथिलीन अवशोषक के साथ हवादार बक्सों में (12-14°C, 85-90% RH)। 10°C से नीचे कभी न रखें।",
    },
    {
        "id": "fruit_apple",
        "name_en": "Fresh Apple",
        "name_ta": "ஆப்பிள்",
        "name_hi": "सेब",
        "category": "Fruits",
        "scientific_name": "Malus domestica",
        "moisture": 85.5,
        "water_activity": 0.98,
        "respiration": 18.0,
        "spoilage_en": "Internal breakdown, superficial scald from alpha-farnesene oxidation, and Penicillium expansum blue mold.",
        "spoilage_ta": "உட்புற திசு அழிவு, தோல் கருகுதல் மற்றும் நீலக்காளான் பூஞ்சை அழுகல்.",
        "spoilage_hi": "अंदरूनी सड़ांध, छिलके का काला पड़ना और नीली फफूंद का संक्रमण।",
        "storage_en": "Cold storage (0-2°C, 90-95% RH) or controlled atmosphere (1-2% O2, 1-2% CO2) with 1-MCP treatment.",
        "storage_ta": "குளிர்பதன கிடங்கு (0-2°C, 90-95% RH) அல்லது கட்டுப்படுத்தப்பட்ட காற்று முறையில் நீண்ட நாள் பாதுகாக்கலாம்.",
        "storage_hi": "कोल्ड स्टोरेज (0-2°C, 90-95% RH) या नियंत्रित वातावरण (CA) में सुरक्षित रखें।",
    },
    {
        "id": "fruit_banana",
        "name_en": "Banana",
        "name_ta": "வாழைப்பழம்",
        "name_hi": "केला",
        "category": "Fruits",
        "scientific_name": "Musa acuminata",
        "moisture": 75.0,
        "water_activity": 0.97,
        "respiration": 55.0,
        "spoilage_en": "Crown rot (Colletotrichum musae), rapid peel browning, and severe chilling injury (sub-epidermal browning) below 13°C.",
        "spoilage_ta": "காம்பு அழுகல், தோல் கருப்பாதல் மற்றும் 13°Cக்கு கீழே வைத்தால் ஏற்படும் கடுமையான குளிர் காயம்.",
        "spoilage_hi": "गुच्छे की सड़न, छिलके का काला पड़ना और 13°C से कम तापमान पर ठंड का गंभीर नुकसान।",
        "storage_en": "Room temperature ambient (13-15°C, 90% RH). Keep well ventilated with ethylene scrubbers during transit.",
        "storage_ta": "அறை வெப்பநிலையில் (13-15°C, 90% RH) வைக்கவும். போக்குவரத்தின் போது எத்திலீன் உறிஞ்சியை பயன்படுத்தவும்.",
        "storage_hi": "सामान्य तापमान पर (13-15°C, 90% RH)। परिवहन के दौरान एथिलीन अवशोषक का प्रयोग करें।",
    },
    {
        "id": "fruit_strawberries",
        "name_en": "Strawberries",
        "name_ta": "ஸ்ட்ராபெரி",
        "name_hi": "स्ट्रॉबेरी",
        "category": "Fruits",
        "scientific_name": "Fragaria × ananassa",
        "moisture": 91.0,
        "water_activity": 0.99,
        "respiration": 90.0,
        "spoilage_en": "Extremely vulnerable to grey mold (Botrytis cinerea), mechanical bruising, and moisture loss.",
        "spoilage_ta": "சாம்பல் நிற பூஞ்சை அழுகல், நசுங்குதல் மற்றும் விரைவான ஈரப்பதம் இழப்புக்கு எளிதில் உள்ளாகும்.",
        "spoilage_hi": "ग्रे मोल्ड फफूंद, चोट लगने और तेजी से नमी घटने का अत्यधिक खतरा।",
        "storage_en": "Immediate forced-air cooling (0-1°C, 90-95% RH) with high CO2 (10-15%) MAP trays to suppress mold.",
        "storage_ta": "உடனடி குளிர்விப்பு (0-1°C, 90-95% RH) மற்றும் பூஞ்சையை கட்டுப்படுத்த அதிக CO2 கொண்ட பைகளில் அடைக்கவும்.",
        "storage_hi": "तुरंत ठंडा करें (0-1°C, 90-95% RH) और फफूंद रोकने के लिए उच्च CO2 युक्त MAP ट्रे में रखें।",
    },
    {
        "id": "fruit_guava",
        "name_en": "Guava",
        "name_ta": "கொய்யா",
        "name_hi": "अमरूद",
        "category": "Fruits",
        "scientific_name": "Psidium guajava",
        "moisture": 84.0,
        "water_activity": 0.98,
        "respiration": 40.0,
        "spoilage_en": "Fruit fly puncture susceptibility, rapid pulp softening, and stylar end rot under warm ambient conditions.",
        "spoilage_ta": "பழ ஈக்கள் தாக்குதல், கூழ் விரைவாக மெலிதாதல் மற்றும் நுனிப்பகுதி அழுகல்.",
        "spoilage_hi": "फल मक्खी का संक्रमण, गूदे का अत्यधिक नरम होना और सिरे की सड़न।",
        "storage_en": "Cool storage (8-10°C, 85-90% RH) with foam net sleeves to protect delicate skin from mechanical abrasion.",
        "storage_ta": "தோல் சேதமடையாமல் இருக்க வலை உறை அணிவித்து குளிர்ந்த இடத்தில் (8-10°C, 85-90% RH) வைக்கவும்.",
        "storage_hi": "छिलके को घर्षण से बचाने के लिए फोम नेट स्लीव में रखकर ठंडी जगह (8-10°C, 85-90% RH) पर रखें।",
    },

    # -------------------------------------------------------------------------
    # GRAINS & MILLETS
    # -------------------------------------------------------------------------
    {
        "id": "grain_basmati_rice",
        "name_en": "Basmati Rice",
        "name_ta": "பாஸ்மதி அரிசி",
        "name_hi": "बासमती चावल",
        "category": "Grains",
        "scientific_name": "Oryza sativa 'Basmati'",
        "moisture": 12.0,
        "water_activity": 0.55,
        "respiration": 1.0,
        "spoilage_en": "Aroma volatile (2-acetyl-1-pyrroline) degradation under heat/oxygen, grain weevil infestation, and moisture absorption.",
        "spoilage_ta": "வெப்பம்/ஆக்சிஜனால் வாசனை இழப்பு, வண்டு தாக்குதல் மற்றும் ஈரப்பதம் உறிஞ்சி பூஞ்சை பிடித்தல்.",
        "spoilage_hi": "गर्मी या ऑक्सीजन से सुगंध का उड़ना, घुन लगना और नमी सोखने से खराब होना।",
        "storage_en": "Hermetic moisture-barrier packaging (BOPP/PE or multiwall paper) at dry ambient (<65% RH).",
        "storage_ta": "ஈரப்பதம் தடுக்கும் BOPP/PE பைகளில் உலர்ந்த சூழலில் (<65% RH) சேமிக்கவும்.",
        "storage_hi": "नमी अवरोधक BOPP/PE बैग में सूखे वातावरण (<65% RH) में सुरक्षित रखें।",
    },
    {
        "id": "grain_wheat_flour",
        "name_en": "Whole Wheat Flour",
        "name_ta": "கோதுமை மாவு",
        "name_hi": "गेहूं का आटा",
        "category": "Grains",
        "scientific_name": "Triticum aestivum flour",
        "moisture": 11.5,
        "water_activity": 0.58,
        "respiration": 1.0,
        "spoilage_en": "Lipase hydrolysis and lipid rancidity in germ fraction, Tribolium castaneum beetle infestation, and caking.",
        "spoilage_ta": "கொழுப்பு அமிலங்களால் மாவு கசப்பாதல், மாவு வண்டு தாக்குதல் மற்றும் ஈரப்பதத்தால் கட்டியாதல்.",
        "spoilage_hi": "अंकुर भाग में दुर्गंध आना (रैनसिडिटी), आटा बीटल का संक्रमण और सीलन से जमना।",
        "storage_en": "Dry, airtight woven PP with inner LDPE liner or laminate pouch away from direct heat.",
        "storage_ta": "உட்புற LDPE அடுக்கு கொண்ட பைகளில் காற்று புகாமல் வெப்பமில்லாத இடத்தில் வைக்கவும்.",
        "storage_hi": "अंदरूनी LDPE लाइनर वाले बैग में बंद करके सीधी धूप और गर्मी से दूर रखें।",
    },
    {
        "id": "grain_finger_millet",
        "name_en": "Finger Millet (Ragi)",
        "name_ta": "ராகி (கேழ்வரகு)",
        "name_hi": "रागी (मंडुआ)",
        "category": "Grains",
        "scientific_name": "Eleusine coracana",
        "moisture": 13.1,
        "water_activity": 0.60,
        "respiration": 1.0,
        "spoilage_en": "Storage insect pest infestation (lesser grain borer) and musty fungal growth if grain moisture exceeds 14%.",
        "spoilage_ta": "தானிய வண்டு தாக்குதல் மற்றும் ஈரப்பதம் 14%க்கு மேல் அதிகரித்தால் பூஞ்சை பிடித்து நாற்றமெடுத்தல்.",
        "spoilage_hi": "भंडारण कीटों का हमला और 14% से अधिक नमी होने पर फफूंद व दुर्गंध पैदा होना।",
        "storage_en": "Hermetic cocoons or laminated poly pouches in dry, cool warehouse conditions.",
        "storage_ta": "உலர்ந்த, குளிர்ந்த கிடங்கில் காற்று புகாத பல அடுக்கு பைகளில் சேமிக்கவும்.",
        "storage_hi": "सूखे और ठंडे गोदाम में वायुरोधी लैमिनेटेड पाउच में सुरक्षित रखें।",
    },
    {
        "id": "grain_chickpeas",
        "name_en": "Chickpeas (Kabuli Chana)",
        "name_ta": "கொண்டைக்கடலை (சுண்டல்)",
        "name_hi": "काबुली चना",
        "category": "Grains",
        "scientific_name": "Cicer arietinum",
        "moisture": 9.8,
        "water_activity": 0.50,
        "respiration": 1.0,
        "spoilage_en": "Pulse beetle (Callosobruchus maculatus) larval damage and hard-to-cook defect during prolonged hot storage.",
        "spoilage_ta": "பருப்பு வண்டு துளையிடுதல் மற்றும் நீண்ட நாள் வெப்பத்தில் வைப்பதால் வேகா கடினத்தன்மை அடைதல்.",
        "spoilage_hi": "दाल के घुन (भृंग) का नुकसान और लंबे समय तक गर्म रखने पर पकने में कठोर होना।",
        "storage_en": "Hermetic grain bags (PICS bags) or vacuum sealed poly pouches in cool dry condition.",
        "storage_ta": "காற்று புகாத PICS பைகள் அல்லது வெற்றிட சீல் செய்யப்பட்ட பைகளில் உலர்ந்த இடத்தில் வைக்கவும்.",
        "storage_hi": "वायुरोधी PICS बैग या वैक्यूम सील बैग में ठंडी और सूखी जगह पर रखें।",
    },

    # -------------------------------------------------------------------------
    # DAIRY
    # -------------------------------------------------------------------------
    {
        "id": "dairy_paneer",
        "name_en": "Fresh Paneer",
        "name_ta": "பனீர் (பால் கட்டி)",
        "name_hi": "ताजा पनीर",
        "category": "Dairy",
        "scientific_name": "Dairy coagulum",
        "moisture": 54.0,
        "water_activity": 0.95,
        "respiration": 0.0,
        "spoilage_en": "Rapid bacterial proliferation (Pseudomonas, psychrotrophs), surface slime, and yeast/mold souring.",
        "spoilage_ta": "பாக்டீரியா மற்றும் பூஞ்சை பெருக்கம், மேற்பரப்பில் வழுவழுப்பு மற்றும் புளித்து கெட்டுப்போதல்.",
        "spoilage_hi": "बैक्टीरिया का तेजी से बढ़ना, सतह पर चिपचिपापन और खट्टा होकर खराब होना।",
        "storage_en": "Vacuum packed multi-layer PA/PE pouches or MAP (CO2/N2) held strictly at 2-4°C.",
        "storage_ta": "வெற்றிட சீல் செய்யப்பட்ட பைகளில் அல்லது MAP முறையில் கண்டிப்பாக 2-4°Cல் வைக்கவும்.",
        "storage_hi": "वैक्यूम पैक या MAP पाउच में अनिवार्य रूप से 2-4°C के तापमान पर प्रशीतित रखें।",
    },
    {
        "id": "dairy_butter",
        "name_en": "Table Butter",
        "name_ta": "வெண்ணெய்",
        "name_hi": "मक्खन",
        "category": "Dairy",
        "scientific_name": "Dairy lipid emulsion",
        "moisture": 15.8,
        "water_activity": 0.75,
        "respiration": 0.0,
        "spoilage_en": "Photo-oxidation and auto-oxidation of unsaturated milk lipids producing metallic off-flavor and yellow surface.",
        "spoilage_ta": "வெளிச்சம் மற்றும் ஆக்சிஜனால் கொழுப்பு கெட்டுப்போதல், மஞ்சள் நிறமாதல் மற்றும் துர்நாற்றம் ஏற்படுதல்.",
        "spoilage_hi": "रोशनी और हवा से वसा का ऑक्सीकरण, पीलापन और दुर्गंध पैदा होना।",
        "storage_en": "Opaque vegetable parchment or aluminium foil laminate wrapper at 2-4°C or frozen.",
        "storage_ta": "ஒளி புகாத காகிதம் அல்லது அலுமினியம் தாளில் சுற்றி 2-4°Cல் குளிர்சாதன பெட்டியில் வைக்கவும்.",
        "storage_hi": "अपारदर्शी पार्चमेंट या एल्युमिनियम फॉयल में लपेटकर 2-4°C पर फ्रिज में रखें।",
    },
    {
        "id": "dairy_milk_powder",
        "name_en": "Full Cream Milk Powder",
        "name_ta": "முழு கொழுப்பு பால் பவுடர்",
        "name_hi": "दूध पाउडर",
        "category": "Dairy",
        "scientific_name": "Dehydrated whole milk",
        "moisture": 3.0,
        "water_activity": 0.20,
        "respiration": 0.0,
        "spoilage_en": "Free radical lipid oxidation causing tallowy off-flavor, Maillard browning, and severe moisture caking.",
        "spoilage_ta": "கொழுப்பு கெட்டு நாற்றமெடுத்தல், மாவு நிறம் மாறுதல் மற்றும் ஈரப்பதத்தை உறிஞ்சி கெட்டியாதல்.",
        "spoilage_hi": "वसा के खराब होने से दुर्गंध, रंग भूरा पड़ना और नमी से कड़े ढेले बनना।",
        "storage_en": "Gas-flushed (Nitrogen/CO2) tin cans or high-barrier foil laminate pouches in dry ambient.",
        "storage_ta": "நைட்ரஜன் வாயு நிரப்பப்பட்ட டின் அல்லது அலுமினியம் பைகளில் உலர்ந்த இடத்தில் வைக்கவும்.",
        "storage_hi": "नाइट्रोजन गैस युक्त टिन डिब्बे या एल्युमिनियम फॉयल पाउच में सूखे स्थान पर रखें।",
    },

    # -------------------------------------------------------------------------
    # MEAT & SEAFOOD
    # -------------------------------------------------------------------------
    {
        "id": "meat_chicken",
        "name_en": "Fresh Chicken Breast",
        "name_ta": "கோழி இறைச்சி",
        "name_hi": "चिकन ब्रेस्ट (ताजा चिकन)",
        "category": "Meat",
        "scientific_name": "Gallus gallus domesticus",
        "moisture": 74.5,
        "water_activity": 0.99,
        "respiration": 0.0,
        "spoilage_en": "Psychrotrophic bacterial growth (Pseudomonas), off-odors (sulfur compounds), and slime formation.",
        "spoilage_ta": "பாக்டீரியா பெருக்கம், துர்நாற்றம் மற்றும் மேற்பரப்பில் வழுவழுப்பு திரவம் உருவாதல்.",
        "spoilage_hi": "बैक्टीरिया की वृद्धि, सल्फर की दुर्गंध और सतह पर चिपचिपापन पैदा होना।",
        "storage_en": "High-barrier vacuum skin packaging (VSP) or MAP (70% O2 / 30% CO2) strictly maintained at 0-2°C.",
        "storage_ta": "வெற்றிட சீல் அல்லது MAP பாதுகாப்புடன் 0-2°Cல் மட்டுமே சேமிக்க வேண்டும்.",
        "storage_hi": "वैक्यूम स्किन या MAP पैकेजिंग में अनिवार्य रूप से 0-2°C पर प्रशीतित रखें।",
    },
    {
        "id": "meat_mutton",
        "name_en": "Mutton Curry Cut",
        "name_ta": "ஆட்டுக்கறி",
        "name_hi": "मटन (बकरे का मांस)",
        "category": "Meat",
        "scientific_name": "Capra hircus",
        "moisture": 71.0,
        "water_activity": 0.99,
        "respiration": 0.0,
        "spoilage_en": "Myoglobin oxidation to brownish metmyoglobin, lipid rancidity, and putrefactive bacterial spoilage.",
        "spoilage_ta": "இறைச்சியின் நிறம் பழுப்பு நிறமாக மாறுதல், கொழுப்பு கெடுதல் மற்றும் அழுகும் பாக்டீரியா தொற்று.",
        "spoilage_hi": "रंग भूरा पड़ना, वसा का खराब होना और सड़ांध पैदा करने वाले बैक्टीरिया।",
        "storage_en": "Chilled at 0-2°C under MAP (80% O2 / 20% CO2 for color retention) or frozen at -18°C.",
        "storage_ta": "சிவப்பு நிறத்தை தக்கவைக்க MAP முறையில் 0-2°Cல் அல்லது -18°Cல் உறைநிலையில் வைக்கவும்.",
        "storage_hi": "ताजा लाल रंग बनाए रखने के लिए MAP में 0-2°C पर या -18°C पर फ्रीज में रखें।",
    },
    {
        "id": "meat_fish",
        "name_en": "Salmon Fish Fillet",
        "name_ta": "சால்மன் மீன்",
        "name_hi": "सैल्मन मछली",
        "category": "Meat",
        "scientific_name": "Salmo salar",
        "moisture": 68.5,
        "water_activity": 0.99,
        "respiration": 0.0,
        "spoilage_en": "Enzymatic autolysis, rapid oxidation of omega-3 PUFA lipids, and TMAO reduction to fishy trimethylamine.",
        "spoilage_ta": "ஒமேகா-3 கொழுப்புகள் காற்றில் கெட்டுப்போதல் மற்றும் மீன் துர்நாற்றம் வீசுதல்.",
        "spoilage_hi": "ओमेगा-3 वसा का तेजी से खराब होना और मछली की तेज दुर्गंध पैदा होना।",
        "storage_en": "Vacuum skin pack on ice slurry (0-1°C) with elevated CO2 atmosphere (60% CO2 / 40% N2).",
        "storage_ta": "பனிக்கட்டியில் 0-1°Cல் வெற்றிட பையில் CO2 வாயு பாதுகாப்புடன் வைக்கவும்.",
        "storage_hi": "बर्फ के बीच 0-1°C पर वैक्यूम स्किन पैक में उच्च CO2 गैस के साथ रखें।",
    },

    # -------------------------------------------------------------------------
    # BAKERY
    # -------------------------------------------------------------------------
    {
        "id": "bakery_bread",
        "name_en": "White Sliced Bread",
        "name_ta": "ரொட்டி (பிரெட்)",
        "name_hi": "ब्रेड (सफेद स्लाइस ब्रेड)",
        "category": "Bakery",
        "scientific_name": "Leavened wheat bread",
        "moisture": 38.0,
        "water_activity": 0.94,
        "respiration": 0.0,
        "spoilage_en": "Retrogradation of amylopectin (crumb staling), crumb firming, and Rhizopus stolonifer mold infestation.",
        "spoilage_ta": "ரொட்டி கடினமாதல் மற்றும் 4-5 நாட்களில் கருப்பு அல்லது பச்சை பூஞ்சை பூத்தல்.",
        "spoilage_hi": "ब्रेड का कड़ा होना (स्टेलिंग) और 4-5 दिनों में काली/हरी फफूंद लगना।",
        "storage_en": "Breathable LDPE bread bags at 20-25°C. Never refrigerate as 4°C dramatically accelerates staling.",
        "storage_ta": "LDPE பையில் அறை வெப்பநிலையில் (20-25°C) வைக்கவும். குளிர்சாதன பெட்டியில் வைத்தால் சீக்கிரம் இறுகிவிடும்.",
        "storage_hi": "LDPE बैग में 20-25°C पर रखें। फ्रिज में कभी न रखें क्योंकि ठंड में ब्रेड जल्दी कड़ी होती है।",
    },
    {
        "id": "bakery_biscuits",
        "name_en": "Digestive Biscuits",
        "name_ta": "பிஸ்கட்",
        "name_hi": "बिस्कुट (डाइजेस्टिव बिस्कुट)",
        "category": "Bakery",
        "scientific_name": "Baked cereal cookie",
        "moisture": 3.5,
        "water_activity": 0.30,
        "respiration": 0.0,
        "spoilage_en": "Atmospheric moisture absorption causing soggy texture, loss of acoustic crispness, and lipid oxidation.",
        "spoilage_ta": "காற்றில் உள்ள ஈரப்பதத்தை உறிஞ்சி மெதுமெதுவென ஆகுதல், மொறுமொறுப்பு இழப்பு மற்றும் நமுத்துப்போதல்.",
        "spoilage_hi": "हवा से नमी सोखकर सीलना, कुरकुरापन खत्म होना और तेल की दुर्गंध आना।",
        "storage_en": "Metallized BOPP flow-wrap pack in dry, airtight container away from humidity.",
        "storage_ta": "மெட்டலைஸ் பையில் காற்று புகாமல் ஈரப்பதமில்லாத உலர்ந்த இடத்தில் வைக்கவும்.",
        "storage_hi": "मेटलाइज्ड BOPP पैक में वायुरोधी डिब्बे में नमी से दूर रखें।",
    },
    {
        "id": "bakery_rusk",
        "name_en": "Dry Toast Rusk",
        "name_ta": "ரஸ்க்",
        "name_hi": "रस्क (टोस्ट)",
        "category": "Bakery",
        "scientific_name": "Twice-baked dry bread",
        "moisture": 4.0,
        "water_activity": 0.32,
        "respiration": 0.0,
        "spoilage_en": "Loss of crispness due to moisture vapor permeation through defective heat seals or thin films.",
        "spoilage_ta": "சீல் வழியே ஈரப்பதம் நுழைவதால் மொறுமொறுப்பு குறைந்து நமுத்துப்போதல்.",
        "spoilage_hi": "नमी अंदर जाने से कुरकुरापन खत्म होना और सील जाना।",
        "storage_en": "Hermetic heat-sealed PP/BOPP pouch kept in ambient moisture-free storage.",
        "storage_ta": "நன்கு ஒட்டப்பட்ட PP/BOPP பைகளில் ஈரமில்லாத சூழலில் வைக்கவும்.",
        "storage_hi": "हीट-सील किए गए PP/BOPP पाउच में नमी-मुक्त स्थान पर रखें।",
    },

    # -------------------------------------------------------------------------
    # OTHER PERISHABLES (SNACKS, CONDIMENTS, RETORT)
    # -------------------------------------------------------------------------
    {
        "id": "snack_potato_chips",
        "name_en": "Fried Potato Chips",
        "name_ta": "உருளைக்கிழங்கு சிப்ஸ்",
        "name_hi": "आलू चिप्स",
        "category": "Other perishables",
        "scientific_name": "Fried potato crisps",
        "moisture": 1.5,
        "water_activity": 0.25,
        "respiration": 0.0,
        "spoilage_en": "Lipid photo-oxidation causing rancid odor/taste, moisture absorption resulting in loss of snap/crispness.",
        "spoilage_ta": "எண்ணெய் வாசனை மாறுதல் மற்றும் காற்று பட்டு மொறுமொறுப்பு போய் நமுத்துப்போதல்.",
        "spoilage_hi": "तेल में दुर्गंध आना और हवा लगने से सीलन व कुरकुरापन खत्म होना।",
        "storage_en": "Nitrogen-flushed Metallized-PET laminate pouch with <1% residual headspace oxygen.",
        "storage_ta": "நைட்ரஜன் நிரப்பப்பட்ட மெட்டலைஸ் பையில் <1% ஆக்சிஜன் அளவில் அடைத்து வைக்கவும்.",
        "storage_hi": "नाइट्रोजन फ्लश किए गए मेटलाइज्ड पाउच में 1% से कम ऑक्सीजन के साथ रखें।",
    },
    {
        "id": "condiment_mango_pickle",
        "name_en": "Mango Pickle (Oil Based)",
        "name_ta": "மாங்காய் ஊறுகாய்",
        "name_hi": "आम का अचार",
        "category": "Other perishables",
        "scientific_name": "Fermented acid condiment",
        "moisture": 42.0,
        "water_activity": 0.78,
        "respiration": 0.0,
        "spoilage_en": "Oxidative discoloration of surface oil layer, pinholing in metal caps due to acetic/lactic acid corrosion.",
        "spoilage_ta": "மேற்பரப்பு எண்ணெய் நிறம் மாறுதல் மற்றும் அமிலத்தன்மையால் உலோக மூடிகள் துருப்பிடித்தல்.",
        "spoilage_hi": "सतह के तेल का ऑक्सीकरण और खटास से धातु के ढक्कन में जंग लगना।",
        "storage_en": "Glass jars or acid-resistant high-barrier multi-layer pouches (PET/Al/CPP) at ambient temperature.",
        "storage_ta": "கண்ணாடி பாட்டில்கள் அல்லது அமிலம் தாங்கும் பல அடுக்கு பைகளில் அறை வெப்பநிலையில் வைக்கவும்.",
        "storage_hi": "कांच के जार या एसिड-रोधी लैमिनेटेड पाउच (PET/Al/CPP) में सामान्य तापमान पर रखें।",
    },
    {
        "id": "condiment_tomato_ketchup",
        "name_en": "Tomato Ketchup",
        "name_ta": "தக்காளி சாஸ் (கெட்ச்அப்)",
        "name_hi": "टमाटर केचप",
        "category": "Other perishables",
        "scientific_name": "Pasteurized tomato condiment",
        "moisture": 68.0,
        "water_activity": 0.92,
        "respiration": 0.0,
        "spoilage_en": "Black neck ring formation from headspace oxygen oxidation and syneresis (water separation).",
        "spoilage_ta": "மூடி பகுதியில் கருப்பு வளையம் உருவாதல் மற்றும் நீர் பிரிந்து போதல்.",
        "spoilage_hi": "हवा के संपर्क से ऊपरी गर्दन पर कालापन आना और पानी अलग होना।",
        "storage_en": "Multi-layer barrier squeeze bottles (PP/EVOH/PP) or glass bottles. Chill after opening.",
        "storage_ta": "EVOH தடுப்பு கொண்ட பிளாஸ்டிக் பாட்டில்கள் அல்லது கண்ணாடி பாட்டில்களில் வைக்கவும்.",
        "storage_hi": "EVOH अवरोधक वाली बोतलों में रखें और खोलने के बाद फ्रिज में रखें।",
    },
    {
        "id": "retort_dal_makhani",
        "name_en": "Ready-to-Eat Dal Makhani",
        "name_ta": "தால் மக்கானி (உணவுப் பொட்டலம்)",
        "name_hi": "दाल मखनी (रेडी-टू-ईट)",
        "category": "Other perishables",
        "scientific_name": "Retort sterilized pulse meal",
        "moisture": 72.0,
        "water_activity": 0.97,
        "respiration": 0.0,
        "spoilage_en": "Seal integrity failure allowing anaerobic Clostridium botulinum germination or micro-leakage souring.",
        "spoilage_ta": "சீல் ஓட்டை விழுந்தால் காற்று புகுந்து கிருமிகள் வளர்ந்து உணவு நஞ்சாதல்.",
        "spoilage_hi": "सील में छेद होने से हवा जाना और हानिकारक बैक्टीरिया से खाना खराब होना।",
        "storage_en": "Autoclaved retort pouch (PET/Al-foil/Cast-PP) shelf-stable for 12-24 months at ambient room temperature.",
        "storage_ta": "வெப்பநிலை தாங்கும் அலுமினிய பையில் அறை வெப்பநிலையில் 12-24 மாதங்கள் வரை பாதுகாக்கலாம்.",
        "storage_hi": "रिटॉर्ट एल्युमिनियम पाउच में सामान्य तापमान पर 12-24 महीने तक सुरक्षित रहता है।",
    },
]


LOCALIZED_CATEGORIES = [
    {
        "category": "Fruits",
        "name_en": "Fruits",
        "name_ta": "பழங்கள்",
        "name_hi": "फल",
        "desc_en": "Fresh, climacteric & non-climacteric fruits requiring respiration and moisture management.",
        "desc_ta": "சுவாசித்தல் மற்றும் ஈரப்பதம் கட்டுப்பாடு தேவைப்படும் புதிய பழ வகைகள்.",
        "desc_hi": "श्वसन और नमी प्रबंधन की आवश्यकता वाले ताजा और पौष्टिक फल।",
        "icon": "apple_rounded",
        "color": "#F97316",
        "sample_items_en": ["Fresh Apple", "Alphonso Mango", "Banana", "Strawberries"],
        "sample_items_ta": ["ஆப்பிள்", "அல்போன்சா மாம்பழம்", "வாழைப்பழம்", "ஸ்ட்ராபெரி"],
        "sample_items_hi": ["सेब", "अल्फोंसो आम", "केला", "स्ट्रॉबेरी"],
    },
    {
        "category": "Vegetables",
        "name_en": "Vegetables",
        "name_ta": "காய்கறிகள்",
        "name_hi": "सब्जियां",
        "desc_en": "Leafy greens, root tubers, and nightshades prone to moisture loss and high respiration.",
        "desc_ta": "விரைவான ஈரப்பத இழப்பு மற்றும் அதிக சுவாசித்தல் கொண்ட காய்கறிகள்.",
        "desc_hi": "नमी की कमी और उच्च श्वसन दर वाली पत्तेदार व जड़ वाली सब्जियां।",
        "icon": "eco_rounded",
        "color": "#059669",
        "sample_items_en": ["Fresh Tomato", "Fresh Spinach", "Potato (Ware)", "Carrot", "Moringa (Drumstick)"],
        "sample_items_ta": ["தக்காளி", "பசலைக்கீரை", "உருளைக்கிழங்கு", "கேரட்", "முருங்கைக்காய்"],
        "sample_items_hi": ["टमाटर", "पालक", "आलू", "गाजर", "सहजन (ड्रमस्टिक)"],
    },
    {
        "category": "Grains",
        "name_en": "Grains & Pulses",
        "name_ta": "தானியங்கள் மற்றும் பருப்புகள்",
        "name_hi": "अनाज और दालें",
        "desc_en": "Cereals, flours, millets, and pulses requiring dry moisture barriers and pest defense.",
        "desc_ta": "பூச்சி தடுப்பு மற்றும் உலர்ந்த ஈரப்பதம் தேவைப்படும் சிறுதானியங்கள் மற்றும் பருப்புகள்.",
        "desc_hi": "कीटों से बचाव और शुष्क नमी अवरोधक की आवश्यकता वाले अनाज व दालें।",
        "icon": "grain_rounded",
        "color": "#D97706",
        "sample_items_en": ["Basmati Rice", "Whole Wheat Flour", "Finger Millet (Ragi)", "Chickpeas"],
        "sample_items_ta": ["பாஸ்மதி அரிசி", "கோதுமை மாவு", "ராகி (கேழ்வரகு)", "கொண்டைக்கடலை"],
        "sample_items_hi": ["बासमती चावल", "गेहूं का आटा", "रागी (मंडुआ)", "काबुली चना"],
    },
    {
        "category": "Dairy",
        "name_en": "Dairy Products",
        "name_ta": "பால் பொருட்கள்",
        "name_hi": "डेयरी उत्पाद",
        "desc_en": "High-fat dairy solids, cheeses, and powders sensitive to lipid oxidation and light.",
        "desc_ta": "கொழுப்பு ஆக்ஸிஜனேற்றம் மற்றும் வெளிச்சத்தால் எளிதில் பாதிக்கப்படும் பால் பொருட்கள்.",
        "desc_hi": "प्रकाश और हवा से वसा खराब होने के प्रति संवेदनशील दूध और पनीर।",
        "icon": "water_drop_rounded",
        "color": "#0284C7",
        "sample_items_en": ["Fresh Paneer", "Table Butter", "Full Cream Milk Powder"],
        "sample_items_ta": ["பனீர் (பால் கட்டி)", "வெண்ணெய்", "பால் பவுடர்"],
        "sample_items_hi": ["ताजा पनीर", "मक्खन", "दूध पाउडर"],
    },
    {
        "category": "Meat",
        "name_en": "Meat & Seafood",
        "name_ta": "இறைச்சி மற்றும் மீன்",
        "name_hi": "मांस और मछली",
        "desc_en": "Fresh poultry, red meats, and seafood vulnerable to rapid microbial and color spoilage.",
        "desc_ta": "விரைவான நுண்ணுயிர் பெருக்கம் மற்றும் நிறமிழப்புக்கு உள்ளாகும் புதிய இறைச்சி.",
        "desc_hi": "बैक्टीरिया और रंग खराब होने के प्रति संवेदनशील ताजा मांस और मछली।",
        "icon": "set_meal_rounded",
        "color": "#E11D48",
        "sample_items_en": ["Fresh Chicken Breast", "Mutton Curry Cut", "Salmon Fish Fillet"],
        "sample_items_ta": ["கோழி இறைச்சி", "ஆட்டுக்கறி", "சால்மன் மீன்"],
        "sample_items_hi": ["चिकन ब्रेस्ट", "मटन", "सैल्मन मछली"],
    },
    {
        "category": "Bakery",
        "name_en": "Bakery & Confectionery",
        "name_ta": "ரொட்டி மற்றும் பிஸ்கட்",
        "name_hi": "बेकरी और बिस्कुट",
        "desc_en": "Leavened breads, cookies, and dry rusks prone to staling and crispness loss.",
        "desc_ta": "மொறுமொறுப்பு இழப்பு மற்றும் நமுத்துப்போதலுக்கு உள்ளாகும் அடுமனை உணவுகள்.",
        "desc_hi": "कुरकुरापन खोने और कड़े होने के प्रति संवेदनशील ब्रेड और बिस्कुट।",
        "icon": "cake_rounded",
        "color": "#9333EA",
        "sample_items_en": ["White Sliced Bread", "Digestive Biscuits", "Dry Toast Rusk"],
        "sample_items_ta": ["ரொட்டி (பிரெட்)", "பிஸ்கட்", "ரஸ்க்"],
        "sample_items_hi": ["ब्रेड", "बिस्कुट", "रस्क"],
    },
    {
        "category": "Other perishables",
        "name_en": "Snacks & Packaged Foods",
        "name_ta": "சிற்றுண்டிகள் மற்றும் பதப்படுத்தப்பட்ட உணவு",
        "name_hi": "स्नैक्स और पैकेज्ड खाद्य पदार्थ",
        "desc_en": "Crisp snacks, pickles, sauces, and retort ready-to-eat meals requiring specialized barriers.",
        "desc_ta": "சிப்ஸ், ஊறுகாய் மற்றும் சிறப்பு பாதுகாப்பு தேவைப்படும் தயார் நிலை உணவுகள்.",
        "desc_hi": "चिप्स, अचार, सॉस और विशेष सुरक्षा की आवश्यकता वाले रेडी-टू-ईट भोजन।",
        "icon": "fastfood_rounded",
        "color": "#0F766E",
        "sample_items_en": ["Fried Potato Chips", "Mango Pickle", "Tomato Ketchup", "Ready-to-Eat Dal Makhani"],
        "sample_items_ta": ["உருளைக்கிழங்கு சிப்ஸ்", "மாங்காய் ஊறுகாய்", "தக்காளி சாஸ்", "தால் மக்கானி"],
        "sample_items_hi": ["आलू चिप्स", "आम का अचार", "टमाटर केचप", "दाल मखनी"],
    },
]


class FoodService:
    """Service class for retrieving localized food commodities and categories."""

    @staticmethod
    def get_localized_commodities(
        locale: str = "en",
        category: Optional[str] = None,
        search: Optional[str] = None,
        limit: int = 50,
    ) -> List[FoodCommodityLocalized]:
        loc = (locale or "en").lower()
        results: List[FoodCommodityLocalized] = []

        for item in LOCALIZED_COMMODITY_DATA:
            # Determine localized display fields
            if loc == "ta" and item.get("name_ta"):
                name = item["name_ta"]
                spoilage = item.get("spoilage_ta", item["spoilage_en"])
                storage = item.get("storage_ta", item["storage_en"])
            elif loc == "hi" and item.get("name_hi"):
                name = item["name_hi"]
                spoilage = item.get("spoilage_hi", item["spoilage_en"])
                storage = item.get("storage_hi", item["storage_en"])
            else:
                name = item["name_en"]
                spoilage = item["spoilage_en"]
                storage = item["storage_en"]

            # Filter by category
            if category:
                cat_lower = category.lower()
                if cat_lower not in item["category"].lower():
                    continue

            # Filter by search string across english, vernacular, scientific names
            if search:
                s = search.lower()
                matched = (
                    s in item["name_en"].lower()
                    or s in (item.get("name_ta") or "").lower()
                    or s in (item.get("name_hi") or "").lower()
                    or s in (item.get("scientific_name") or "").lower()
                    or s in item["category"].lower()
                )
                if not matched:
                    continue

            results.append(
                FoodCommodityLocalized(
                    id=item["id"],
                    name=name,
                    name_en=item["name_en"],
                    name_ta=item.get("name_ta"),
                    name_hi=item.get("name_hi"),
                    category=item["category"],
                    scientific_name=item.get("scientific_name"),
                    moisture_content_percent=item["moisture"],
                    water_activity=item["water_activity"],
                    respiration_rate_mg_co2_kg_h=item.get("respiration"),
                    spoilage_vector=spoilage,
                    storage_recommendation=storage,
                )
            )

        return results[:limit]

    @staticmethod
    def get_localized_commodity_by_name(
        name: str, locale: str = "en"
    ) -> Optional[FoodCommodityLocalized]:
        target = (name or "").strip().lower()
        if not target:
            return None

        all_items = FoodService.get_localized_commodities(locale=locale, limit=200)
        for item in all_items:
            if (
                item.name.lower() == target
                or item.name_en.lower() == target
                or (item.name_ta and item.name_ta.lower() == target)
                or (item.name_hi and item.name_hi.lower() == target)
            ):
                return item

        # Partial matching fallback
        for item in all_items:
            if (
                target in item.name.lower()
                or target in item.name_en.lower()
                or (item.name_ta and target in item.name_ta.lower())
                or (item.name_hi and target in item.name_hi.lower())
            ):
                return item

        return None

    @staticmethod
    def get_localized_categories(locale: str = "en") -> List[LocalizedCategoryResponse]:
        loc = (locale or "en").lower()
        results: List[LocalizedCategoryResponse] = []

        for cat in LOCALIZED_CATEGORIES:
            if loc == "ta":
                name = cat["name_ta"]
                desc = cat["desc_ta"]
                samples = cat.get("sample_items_ta", cat["sample_items_en"])
            elif loc == "hi":
                name = cat["name_hi"]
                desc = cat["desc_hi"]
                samples = cat.get("sample_items_hi", cat["sample_items_en"])
            else:
                name = cat["name_en"]
                desc = cat["desc_en"]
                samples = cat["sample_items_en"]

            results.append(
                LocalizedCategoryResponse(
                    category=cat["category"],
                    name=name,
                    description=desc,
                    icon=cat.get("icon"),
                    color=cat.get("color"),
                    sample_items=samples,
                )
            )

        return results
