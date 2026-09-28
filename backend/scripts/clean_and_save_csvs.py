import csv
import io
import os

RAW_TABLE_1 = """Commodity_Name,Sub_Category,Moisture_Content_Min_Percent,Moisture_Content_Max_Percent,Fat_Oil_Content_Min_Percent,Fat_Oil_Content_Max_Percent,pH_Min,pH_Max,Respiration_Rate,Food_Category,Oxygen_Sensitivity,Moisture_Sensitivity,Shelf_Life_Requirement,Source
Potato Chips,Chips & Wafers,0.67,3.78,27.91,40.16,5.96,6.29,2.33 mL CO2/h (closed storage reference),Fried low-moisture snack,High,Very High,4.5-12 months,IPB Journal
Fried Potato Chips,Chips & Wafers,1.1,1.5,30.33,32.36,5.96,6.29,2.33 mL CO2/h,Fried low-moisture snack,High,Very High,4.5-12 months,ScienceDirect
Baked Potato Chips,Chips & Wafers,1.8,2.0,21.29,22.21,5.96,6.29,2.33 mL CO2/h,Baked low-moisture snack,High,Very High,4.5-12 months,IPB Journal
Flat Potato Chips,Chips & Wafers,1.3,1.5,32.36,32.36,5.96,5.96,2.33 mL CO2/h,Fried potato snack,High,Very High,4.5-12 months,ScienceDirect
Ridged Potato Chips,Chips & Wafers,1.3,1.5,30.33,30.33,6.29,6.29,2.33 mL CO2/h,Fried potato snack,High,Very High,4.5-12 months,ScienceDirect
Marie Biscuits,Biscuits & Cookies,3.2,4.7,9.5,13.5,7.29,7.63,0.0 mL CO2/kg/h,Plain dry biscuit,Moderate,Very High,16.5 months,OUP Academic
Petit Beurre Biscuits,Biscuits & Cookies,2.8,4.2,13.3,13.3,7.3,7.3,0.0 mL CO2/kg/h,Semi-sweet dry biscuit,High,Very High,16.5 months,OUP Academic
Digestive Biscuits,Biscuits & Cookies,2.5,4.5,20.3,20.3,7.2,7.2,0.0 mL CO2/kg/h,High-fibre dry biscuit,High,Very High,16.5 months,Not specified in source
Cream Crackers,Biscuits & Cookies,2.0,4.0,13.3,13.3,7.1,7.1,0.0 mL CO2/kg/h,Savoury dry biscuit,High,Very High,16.5 months,Not specified in source
Butter Cookies,Biscuits & Cookies,2.0,4.0,24.0,26.0,6.8,7.2,0.0 mL CO2/kg/h,High-fat cookie,Very High,Very High,12 months,Not specified in source
Wheat Bread,Bread & Bakery Products,33.7,33.7,4.9,4.9,6.0,6.0,0.0 mL CO2/kg/h,High-moisture bakery product,High,High,5-7 days,Not specified in source
Wholemeal Rye Bread,Bread & Bakery Products,40.8,40.8,5.5,5.5,4.9,4.9,0.0 mL CO2/kg/h,Wholegrain bakery product,High,High,7-14 days,Not specified in source
Wholemeal Rye + Bran Bread,Bread & Bakery Products,45.2,45.2,5.1,5.1,5.1,5.1,0.0 mL CO2/kg/h,High-moisture wholegrain bread,High,High,7-14 days,Not specified in source
Refined Rye Bread,Bread & Bakery Products,43.1,43.1,0.7,0.7,4.4,4.4,0.0 mL CO2/kg/h,Rye bakery product,High,High,7-14 days,Not specified in source
Refined Rye Flat Bread,Bread & Bakery Products,31.5,31.5,0.4,0.4,4.7,4.7,0.0 mL CO2/kg/h,Flat bakery product,High,High,5-10 days,Not specified in source
Apricot Jam,Jams,15.78,15.78,0.1,0.1,3.29,3.29,0.0 mL CO2/kg/h,High-sugar acidic fruit preserve,Moderate,Moderate,30 days after opening,PubMed Central (PMC)
Strawberry Jam,Jams,18.00,18.00,0.1,0.1,2.91,2.91,0.0 mL CO2/kg/h,High-sugar acidic fruit preserve,Moderate,Moderate,30 days after opening,PubMed Central (PMC)
Raspberry Jam,Jams,21.82,21.82,0.1,0.1,2.92,2.92,0.0 mL CO2/kg/h,High-sugar acidic fruit preserve,Moderate,Moderate,30 days after opening,PubMed Central (PMC)
Sour Cherry Jam,Jams,18.50,18.50,0.1,0.1,3.47,3.47,0.0 mL CO2/kg/h,High-sugar acidic fruit preserve,Moderate,Moderate,30 days after opening,PubMed Central (PMC)
Tomato Sauce,Sauces,91,91,0.2,0.2,4.0,4.2,0.0 mL CO2/kg/h,High-moisture acidic sauce,High,Low,6-12 months,Not specified in source
Chilli Sauce,Sauces,80,85,0.5,2,3.0,4.0,0.0 mL CO2/kg/h,Acidic condiment,High,Low,6-12 months,Not specified in source
Soy Sauce,Sauces,65,70,0.1,0.5,4.5,5.0,0.0 mL CO2/kg/h,Fermented liquid condiment,Moderate,Low,12-24 months,Not specified in source"""

RAW_TABLE_2 = """Commodity_Name,Food_Category,Moisture_Content_Percent,Fat_Oil_Content_Percent,pH,Respiration_Rate,Oxygen_Sensitivity,Moisture_Sensitivity,Shelf_Life_Requirement_Months,Notes_Source
Potato chips (fried),Snacks (chips/wafers),2.0,33.0,5.8,N/A - non-respiring processed food,High,High,6,"USDA FDC + industry standard; high fat drives rancidity risk, low moisture makes it highly hygroscopic"
Banana chips (fried),Snacks (chips/wafers),3.5,28.0,5.5,N/A - non-respiring processed food,High,High,4,Typical Indian snack food industry data
Corn/tapioca chips (extruded),Snacks (chips/wafers),3.0,18.0,6.0,N/A - non-respiring processed food,Medium,High,6,USDA FDC
Namkeen/savory mixture (fried),Snacks,3.0,25.0,5.5,N/A - non-respiring processed food,High,High,3,"Industry shelf-life data, Indian snack sector"
Sweet biscuits,Biscuits and cookies,3.0,18.0,6.5,N/A - non-respiring processed food,Medium,High,6,USDA FDC + FAO food composition tables
Cream-filled biscuits,Biscuits and cookies,4.0,22.0,6.3,N/A - non-respiring processed food,High,High,6,Higher fat filling increases oxidative risk
Cookies (butter/shortbread),Biscuits and cookies,3.5,24.0,6.4,N/A - non-respiring processed food,High,High,6,USDA FDC
Digestive/whole wheat biscuits,Biscuits and cookies,3.0,15.0,6.2,N/A - non-respiring processed food,Medium,High,6,USDA FDC
White bread,Bread and bakery products,35.0,3.0,5.3,N/A - non-respiring processed food,Low,High,0.2,"USDA FDC; short shelf life ~5-7 days, moisture loss and mold are main risks"
Whole wheat bread,Bread and bakery products,38.0,3.5,5.4,N/A - non-respiring processed food,Low,High,0.2,USDA FDC
Sponge cake,Bread and bakery products,25.0,15.0,6.8,N/A - non-respiring processed food,Medium,High,1,Published bakery shelf-life studies
Mango pickle (oil-based),"Pickles, jams and sauces",55.0,12.0,3.8,N/A - non-respiring processed food,Medium,Medium,12,"FAO food composition data + Indian pickle industry norms; low pH gives strong microbial stability"
Mixed vegetable pickle,"Pickles, jams and sauces",60.0,10.0,3.6,N/A - non-respiring processed food,Medium,Medium,12,"Industry data; acidic pH is primary preservation factor"
Mango jam,"Pickles, jams and sauces",30.0,0.2,3.4,N/A - non-respiring processed food,Low,Medium,12,"USDA FDC; high sugar + low pH controls spoilage"
Mixed fruit jam,"Pickles, jams and sauces",28.0,0.2,3.3,N/A - non-respiring processed food,Low,Medium,12,USDA FDC
Tomato ketchup/sauce,"Pickles, jams and sauces",68.0,0.3,3.9,N/A - non-respiring processed food,Low,Low,12,USDA FDC
Chili sauce,"Pickles, jams and sauces",70.0,0.5,3.7,N/A - non-respiring processed food,Low,Low,9,USDA FDC
Red chili powder,Spice powders,9.0,10.0,5.5,N/A - non-respiring processed food,High,High,12,"FAO/USDA spice composition data; oleoresin content drives oxygen sensitivity, fine powder is very hygroscopic"
Turmeric powder,Spice powders,8.5,5.0,6.0,N/A - non-respiring processed food,Medium,High,12,FAO spice composition data
Garam masala (mixed spice),Spice powders,7.0,8.0,5.8,N/A - non-respiring processed food,High,High,9,Industry technical data for blended spice powders
Cumin powder,Spice powders,8.0,15.0,5.9,N/A - non-respiring processed food,High,High,9,"FAO spice composition data; essential oil content raises oxidative risk"
Coriander powder,Spice powders,9.0,12.0,6.0,N/A - non-respiring processed food,Medium,High,9,FAO spice composition data
Instant noodles seasoning/mix,Instant food mixes,5.0,15.0,6.0,N/A - non-respiring processed food,High,High,8,USDA FDC + industry data
Instant soup mix (powder),Instant food mixes,4.0,8.0,6.2,N/A - non-respiring processed food,Medium,High,12,Industry technical data
Ready-to-cook curry mix (dry),Instant food mixes,6.0,10.0,6.1,N/A - non-respiring processed food,Medium,High,9,Industry technical data
Dosa/idli batter mix (dry),Instant food mixes,7.0,2.0,6.3,N/A - non-respiring processed food,Low,High,6,Industry technical data
Pasteurized whole milk,Dairy products,87.5,3.5,6.6,N/A - non-respiring processed food,Low,Low,0.25,"USDA FDC; refrigerated, short shelf life"
Cheddar cheese,Dairy products,37.0,33.0,5.4,N/A - non-respiring processed food,High,Medium,3,USDA FDC; high fat drives strong oxidative sensitivity
Butter,Dairy products,16.0,81.0,6.3,N/A - non-respiring processed food,High,Low,6,"USDA FDC; very high fat, oxygen exclusion critical"
Plain yogurt/curd,Dairy products,85.0,3.5,4.4,N/A - non-respiring processed food,Low,Low,0.5,USDA FDC
Paneer (fresh cheese),Dairy products,55.0,20.0,5.6,N/A - non-respiring processed food,Medium,Medium,0.25,FAO/Indian dairy composition data
Frozen green peas,Frozen foods,78.0,0.4,6.5,"Low (residual, near-zero at frozen temp)",Low,Low,12,"USDA FDC; respiration effectively halted below -18C"
Frozen paratha (flatbread),Frozen foods,42.0,10.0,6.0,N/A - non-respiring processed food,Medium,Medium,6,Industry technical data
Frozen chicken nuggets,Frozen foods,55.0,15.0,6.2,N/A - non-respiring processed food,Medium,Medium,9,USDA FDC
Ready-to-eat curry (retort pouch),Ready-to-eat foods,75.0,8.0,5.5,"N/A - non-respiring, thermally sterilized",Low,Low,12,"Retort processing gives commercial sterility; barrier packaging mainly for light/physical protection"
Ready-to-eat rice meal (retort),Ready-to-eat foods,70.0,3.0,6.0,"N/A - non-respiring, thermally sterilized",Low,Low,12,Industry retort food technical data
Ragi (finger millet) flour,Millet-based products,11.0,1.5,6.2,N/A - non-respiring processed food,Medium,High,6,"FAO/ICAR millet composition data; fat oxidation and moisture pickup limit shelf life"
Millet cookies,Millet-based products,4.0,16.0,6.3,N/A - non-respiring processed food,High,High,4,Published millet food-product shelf-life studies
Milk-based sweet (barfi type),Sweets,15.0,20.0,6.0,N/A - non-respiring processed food,High,Medium,0.5,"Indian sweets industry data; high fat + moisture, short shelf life without preservatives"
Ladoo (besan/gram flour based),Sweets,8.0,22.0,6.1,N/A - non-respiring processed food,High,Medium,0.5,Indian sweets industry data
"Almonds (raw, shelled)",Dry fruits and nuts,4.5,50.0,6.0,"N/A - non-respiring, dormant seed",High,Medium,12,USDA FDC; high fat content is the dominant oxidative shelf-life driver
Cashew nuts (raw),Dry fruits and nuts,5.0,44.0,6.1,"N/A - non-respiring, dormant seed",High,Medium,9,USDA FDC
Raisins,Dry fruits and nuts,15.0,0.5,3.8,"N/A - non-respiring, dried fruit",Low,High,12,USDA FDC; low pH but high sugar/hygroscopic moisture pickup risk
Roasted peanuts,Dry fruits and nuts,2.0,49.0,6.5,N/A - non-respiring processed food,High,Medium,6,USDA FDC
Wheat flour (refined),Ready-to-cook mixes,12.0,1.5,6.0,N/A - non-respiring processed food,Low,High,6,USDA FDC
Besan (gram flour),Ready-to-cook mixes,10.0,5.5,6.4,N/A - non-respiring processed food,Medium,High,6,FAO/USDA legume flour composition data"""

RAW_TABLE_4 = """Material,Material_Category,Thickness,OTR,OTR_Unit,OTR_Temperature,OTR_RH,WVTR,WVTR_Unit,WVTR_Temperature,WVTR_RH,Gas_Permeability,Tensile_Strength,Elongation,Mechanical_Strength,Scalability,MAP_Suitability,Food_Applications,Source,DOI,Notes
LDPE,Conventional polymer,25 µm reference,7400,cc/m²/day,23°C,0%,12.50,g/m²/day,38°C,90%,High,9.93 MPa,349%,Moderate,High,Conditional,"Food bags, films",Research/packaging reference,10.1016/j.crfs.2021.07.005,Values depend on thickness and test conditions
HDPE,Conventional polymer,25 µm reference,1600,cc/m²/day,23°C,0%,3.70,g/m²/day,38°C,90%,Moderate,27.93 MPa,213.1%,High,High,Conditional,"Milk containers, dry foods, food bags, liners",Research/packaging reference,10.1016/j.crfs.2021.07.005,Values depend on thickness grade and test conditions
PET,Conventional polymer,25 µm reference,55,cc/m²/day,23°C,0%,20.00,g/m²/day,38°C,90%,Low,61.67 MPa,60-85%,High,High,Conditional / Suitable in appropriate structures,"Water, soft drinks, beverages, snacks, biscuits, coffee, multilayer films",Research/packaging reference,10.1016/j.crfs.2021.07.005,Values depend on thickness orientation and test conditions
Metallized PET,Metallized polymer film,25 µm reference,0.65,cc/m²/day,23°C,0%,1.00,g/m²/day,38°C,90%,Very Low,Base-film dependent,Base-film dependent,Structure-dependent,High,Conditional / Product-dependent,"Chips, snacks, coffee, nuts, biscuits, confectionery, dry foods",Food packaging reference,Not specified,Barrier performance depends on base film metal coating and coating integrity
Aluminium Foil Laminate,Multilayer high-barrier laminate,"PET/Al/PE: 14/10/55 µm; PET/Al/PP: 14/9/56 µm",<0.05,mL(STP)/m²/day,23°C,Dry condition,<0.01,g/m²/day,38°C,90%,Extremely Low,Structure-dependent,Structure-dependent,Structure-dependent,High,Suitable for high-barrier applications,"Tomato products, sauces, ketchup, salad dressings, fruit juices",Research paper,10.1002/pen.70193,OTR and WVTR were below the equipment quantification limits
PLA,Biodegradable polymer,Application/formulation dependent,50-100*,cc/m²/day/atm,Source-specific,Source-specific,300-500*,g/m²/day,Source-specific,Source-specific,Moderate / formulation-dependent,20-75 MPa*,2-12%*,"Good strength, relatively brittle",Developing / material-dependent,Conditional,"Fresh produce, bakery, dry foods, biodegradable food packaging",Research paper/review,Source/formulation dependent,"Biodegradable film is a broad category; exact RH must be taken from the specific PLA/starch/PHA/PBAT study used. (Note: this material appeared twice with identical data in the source document; duplicate removed.)"
Breathable Film,Gas-permeable biodegradable polymer film,Study-specific,950-4540,cc/m²/day/atm,Not reported,Not reported,Study-specific,g/m²/day,Study-specific,Study-specific,High / Controlled,Formulation-dependent,Formulation-dependent,Material/structure-dependent,Application-dependent,Suitable for fresh produce,"Fruits, vegetables, fresh-cut produce",Research paper,10.3390/polym13203527,O2TR varies with pore structure and formulation; the paper does not report a single universal RH condition for the O2TR values"""

def clean_and_save():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    data_dir = os.path.join(base_dir, "data")
    os.makedirs(data_dir, exist_ok=True)

    with open(os.path.join(data_dir, "food_commodities_ranges.csv"), "w", encoding="utf-8") as f:
        f.write(RAW_TABLE_1.strip() + "\n")

    with open(os.path.join(data_dir, "food_commodities_profiles.csv"), "w", encoding="utf-8") as f:
        f.write(RAW_TABLE_2.strip() + "\n")

    with open(os.path.join(data_dir, "packaging_materials.csv"), "w", encoding="utf-8") as f:
        f.write(RAW_TABLE_4.strip() + "\n")

    print("Cleaned CSVs saved successfully.")

if __name__ == "__main__":
    clean_and_save()
