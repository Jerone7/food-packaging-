from fastapi import APIRouter, Depends, Query, HTTPException, status, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func
from typing import List, Optional, Dict, Any

from app.db.session import get_db
from app.models.food_and_packaging import (
    Source,
    Food,
    RespirationData,
    PackagingMaterial,
    GasProperty,
    IFCTFoodComposition,
    FoodScientificProperty
)
from app.schemas.food_scientific_properties import (
    FoodScientificPropertiesResponse,
    FoodCreate,
    FoodResponse
)
from app.schemas.food_data import FoodCommodityLocalized, PackagingMaterialLocalized
from app.core.scientific_catalog import get_scientific_profile_for_food, SCIENTIFIC_COMMODITY_CATALOG
from app.core.i18n import get_requested_locale
from app.services.food_service import FoodService
from app.core.material_database import MaterialDatabase

router = APIRouter()

STATIC_FALLBACK_CATEGORIES = [
    {
        "category": "Snacks & Wafers",
        "description": "High-fat, low-moisture fried & baked snacks requiring strict moisture & oxygen barrier",
        "sample_items": ["Potato Chips", "Banana Chips", "Namkeen", "Tortilla Chips"],
        "count": 30
    },
    {
        "category": "Biscuits & Bakery",
        "description": "Crisp cookies, soft breads, and dry rusks prone to staling and moisture pickup",
        "sample_items": ["Marie Biscuit", "Digestive Biscuit", "White Bread", "Croissant"],
        "count": 25
    },
    {
        "category": "Pickles & Sauces",
        "description": "High-acid, high-moisture condiments requiring chemical & corrosion resistant packaging",
        "sample_items": ["Mango Pickle", "Tomato Ketchup", "Red Chili Sauce", "Mixed Fruit Jam"],
        "count": 25
    },
    {
        "category": "Spice Powders",
        "description": "Hygroscopic powders containing volatile essential oils vulnerable to aroma loss & oxidation",
        "sample_items": ["Red Chili Powder", "Turmeric Powder", "Garam Masala", "Cumin Powder"],
        "count": 22
    },
    {
        "category": "Dairy & Sweets",
        "description": "High-fat, sensitive dairy solids and traditional sweets requiring chilled or MAP barriers",
        "sample_items": ["Paneer", "Butter", "Cheddar Cheese", "Kaju Katli", "Rasgulla"],
        "count": 35
    },
    {
        "category": "Retort & Ready-to-Eat",
        "description": "Thermally sterilized shelf-stable meals requiring multi-layer high-barrier retort pouches",
        "sample_items": ["Dal Makhani", "Paneer Butter Masala", "Veg Biryani", "Rajma Masala"],
        "count": 18
    },
    {
        "category": "Millets & Flours",
        "description": "Nutrient-rich flours and extruded snacks sensitive to rancidity and moisture absorption",
        "sample_items": ["Ragi Flour", "Jowar Chips", "Bajra Khakhra", "Foxtail Millet"],
        "count": 20
    },
    {
        "category": "Dry Fruits & Nuts",
        "description": "High unsaturated fat nuts requiring oxygen exclusion to prevent rancidity",
        "sample_items": ["Almonds", "Cashew Nuts", "Walnuts", "Raisins", "Pistachios"],
        "count": 16
    }
]

STATIC_FALLBACK_MATERIALS = [
    {"name": "LDPE", "polymer": "Conventional polymer", "thickness": "25 µm reference", "otr": "7400 cc/m²/day", "wvtr": "12.50 g/m²/day", "sealability": "Good / Heat Sealable", "mechanical_strength": "9.93 MPa (Moderate)", "map_suitable": "Conditional"},
    {"name": "HDPE", "polymer": "Conventional polymer", "thickness": "25 µm reference", "otr": "1600 cc/m²/day", "wvtr": "3.70 g/m²/day", "sealability": "Good / Heat Sealable", "mechanical_strength": "27.93 MPa (High)", "map_suitable": "Conditional"},
    {"name": "PET", "polymer": "Conventional polymer", "thickness": "25 µm reference", "otr": "55 cc/m²/day", "wvtr": "20.00 g/m²/day", "sealability": "Structure-dependent", "mechanical_strength": "61.67 MPa (High)", "map_suitable": "Suitable in appropriate structures"},
    {"name": "Metallized PET", "polymer": "Metallized polymer film", "thickness": "25 µm reference", "otr": "0.65 cc/m²/day", "wvtr": "1.00 g/m²/day", "sealability": "Structure-dependent", "mechanical_strength": "Structure-dependent", "map_suitable": "Conditional / Product-dependent"},
    {"name": "Aluminium Foil Laminate", "polymer": "Multilayer high-barrier laminate", "thickness": "PET/Al/PE: 14/10/55 µm", "otr": "<0.05 mL(STP)/m²/day", "wvtr": "<0.01 g/m²/day", "sealability": "Good / Heat Sealable", "mechanical_strength": "Structure-dependent", "map_suitable": "Suitable for high-barrier applications"},
    {"name": "PLA", "polymer": "Biodegradable polymer", "thickness": "Application dependent", "otr": "50-100 cc/m²/day/atm", "wvtr": "300-500 g/m²/day", "sealability": "Structure-dependent", "mechanical_strength": "20-75 MPa (Brittle)", "map_suitable": "Conditional"},
    {"name": "Breathable Film", "polymer": "Gas-permeable biodegradable polymer film", "thickness": "Study-specific", "otr": "950-4540 cc/m²/day/atm", "wvtr": "Study-specific", "sealability": "Structure-dependent", "mechanical_strength": "Material-dependent", "map_suitable": "Suitable for fresh produce"}
]

STATIC_FALLBACK_FOODS = [
    # Fruits
    {
        "id": 1,
        "name": "Fresh Apple",
        "category": "Fruits",
        "scientific_name": "Malus domestica",
        "moisture": 85.5,
        "ph": 3.6,
        "water_activity": 0.98,
        "fat": 0.2,
        "respiration_class": "Moderate",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "High",
        "recommended_storage": "Refrigerated (2-4°C, 90-95% RH)"
    },
    {
        "id": 2,
        "name": "Fresh Mango",
        "category": "Fruits",
        "scientific_name": "Mangifera indica",
        "moisture": 83.0,
        "ph": 4.2,
        "water_activity": 0.98,
        "fat": 0.4,
        "respiration_class": "High",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "High",
        "recommended_storage": "Refrigerated (10-13°C, 85-90% RH)"
    },
    {
        "id": 3,
        "name": "Banana",
        "category": "Fruits",
        "scientific_name": "Musa acuminata",
        "moisture": 75.0,
        "ph": 5.0,
        "water_activity": 0.97,
        "fat": 0.3,
        "respiration_class": "High",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "High",
        "recommended_storage": "Room temperature (13-15°C, 90% RH)"
    },
    {
        "id": 4,
        "name": "Strawberries",
        "category": "Fruits",
        "scientific_name": "Fragaria × ananassa",
        "moisture": 91.0,
        "ph": 3.4,
        "water_activity": 0.99,
        "fat": 0.3,
        "respiration_class": "Very High",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "Very High",
        "recommended_storage": "Refrigerated (0-2°C, 95% RH)"
    },

    # Vegetables
    {
        "id": 10,
        "name": "Fresh Tomato",
        "category": "Vegetables",
        "scientific_name": "Solanum lycopersicum",
        "moisture": 94.5,
        "ph": 4.4,
        "water_activity": 0.99,
        "fat": 0.2,
        "respiration_class": "Moderate",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "High",
        "recommended_storage": "Refrigerated (10-12°C, 90% RH)"
    },
    {
        "id": 11,
        "name": "Fresh Spinach",
        "category": "Vegetables",
        "scientific_name": "Spinacia oleracea",
        "moisture": 91.4,
        "ph": 6.2,
        "water_activity": 0.99,
        "fat": 0.4,
        "respiration_class": "Extremely High",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "Very High",
        "recommended_storage": "Refrigerated (0-2°C, 95-100% RH)"
    },
    {
        "id": 12,
        "name": "Potato (Ware)",
        "category": "Vegetables",
        "scientific_name": "Solanum tuberosum",
        "moisture": 79.0,
        "ph": 5.8,
        "water_activity": 0.98,
        "fat": 0.1,
        "respiration_class": "Low",
        "oxygen_sensitivity": "Low",
        "moisture_sensitivity": "Moderate",
        "recommended_storage": "Room temperature (8-10°C, 90% RH)"
    },
    {
        "id": 13,
        "name": "Carrot",
        "category": "Vegetables",
        "scientific_name": "Daucus carota",
        "moisture": 88.0,
        "ph": 5.9,
        "water_activity": 0.99,
        "fat": 0.2,
        "respiration_class": "Moderate",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "High",
        "recommended_storage": "Refrigerated (0-2°C, 95-100% RH)"
    },

    # Grains
    {
        "id": 20,
        "name": "Basmati Rice",
        "category": "Grains",
        "scientific_name": "Oryza sativa",
        "moisture": 12.0,
        "ph": 6.5,
        "water_activity": 0.55,
        "fat": 0.7,
        "respiration_class": "Very Low",
        "oxygen_sensitivity": "Low",
        "moisture_sensitivity": "High",
        "recommended_storage": "Room temperature (15-25°C, <65% RH)"
    },
    {
        "id": 21,
        "name": "Whole Wheat Flour",
        "category": "Grains",
        "scientific_name": "Triticum aestivum",
        "moisture": 11.5,
        "ph": 6.2,
        "water_activity": 0.58,
        "fat": 1.7,
        "respiration_class": "Very Low",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "High",
        "recommended_storage": "Room temperature (15-20°C, dry)"
    },
    {
        "id": 22,
        "name": "Finger Millet (Ragi)",
        "category": "Grains",
        "scientific_name": "Eleusine coracana",
        "moisture": 13.1,
        "ph": 6.4,
        "water_activity": 0.60,
        "fat": 1.3,
        "respiration_class": "Very Low",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "High",
        "recommended_storage": "Room temperature (dry airtight)"
    },
    {
        "id": 23,
        "name": "Chickpeas (Kabuli Chana)",
        "category": "Grains",
        "scientific_name": "Cicer arietinum",
        "moisture": 9.8,
        "ph": 6.3,
        "water_activity": 0.50,
        "fat": 5.3,
        "respiration_class": "Very Low",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "High",
        "recommended_storage": "Room temperature (dry)"
    },

    # Dairy
    {
        "id": 30,
        "name": "Fresh Paneer",
        "category": "Dairy",
        "scientific_name": "Dairy coagulum",
        "moisture": 54.0,
        "ph": 5.8,
        "water_activity": 0.95,
        "fat": 24.0,
        "respiration_class": "Very Low",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "High",
        "recommended_storage": "Refrigerated (2-4°C)"
    },
    {
        "id": 31,
        "name": "Cheddar Cheese",
        "category": "Dairy",
        "scientific_name": "Ripened curd cheese",
        "moisture": 36.5,
        "ph": 5.3,
        "water_activity": 0.88,
        "fat": 33.0,
        "respiration_class": "Very Low",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "Moderate",
        "recommended_storage": "Refrigerated (2-6°C)"
    },
    {
        "id": 32,
        "name": "Table Butter",
        "category": "Dairy",
        "scientific_name": "Dairy fat emulsion",
        "moisture": 15.8,
        "ph": 6.4,
        "water_activity": 0.75,
        "fat": 81.0,
        "respiration_class": "None",
        "oxygen_sensitivity": "Very High",
        "moisture_sensitivity": "Low",
        "recommended_storage": "Refrigerated (2-4°C, light-tight)"
    },
    {
        "id": 33,
        "name": "Full Cream Milk Powder",
        "category": "Dairy",
        "scientific_name": "Spray-dried milk",
        "moisture": 3.0,
        "ph": 6.6,
        "water_activity": 0.20,
        "fat": 26.5,
        "respiration_class": "None",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "Very High",
        "recommended_storage": "Room temperature (airtight, dry)"
    },

    # Meat
    {
        "id": 40,
        "name": "Fresh Chicken Breast",
        "category": "Meat",
        "scientific_name": "Gallus gallus domesticus",
        "moisture": 74.5,
        "ph": 5.9,
        "water_activity": 0.99,
        "fat": 2.6,
        "respiration_class": "Very Low",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "High",
        "recommended_storage": "Refrigerated (0-2°C) or Frozen (≤ -18°C)"
    },
    {
        "id": 41,
        "name": "Mutton Curry Cut",
        "category": "Meat",
        "scientific_name": "Capra hircus",
        "moisture": 71.0,
        "ph": 5.7,
        "water_activity": 0.99,
        "fat": 7.5,
        "respiration_class": "Very Low",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "High",
        "recommended_storage": "Refrigerated (0-2°C) or Frozen (≤ -18°C)"
    },
    {
        "id": 42,
        "name": "Salmon Fish Fillet",
        "category": "Meat",
        "scientific_name": "Salmo salar",
        "moisture": 68.5,
        "ph": 6.3,
        "water_activity": 0.99,
        "fat": 13.4,
        "respiration_class": "Very Low",
        "oxygen_sensitivity": "Very High",
        "moisture_sensitivity": "High",
        "recommended_storage": "Refrigerated (0-2°C, MAP / Vacuum)"
    },

    # Bakery
    {
        "id": 50,
        "name": "White Sliced Bread",
        "category": "Bakery",
        "scientific_name": "Yeast-leavened wheat",
        "moisture": 38.0,
        "ph": 5.4,
        "water_activity": 0.94,
        "fat": 3.2,
        "respiration_class": "Low",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "High",
        "recommended_storage": "Room temperature (20-25°C, sealed)"
    },
    {
        "id": 51,
        "name": "Digestive Biscuits",
        "category": "Bakery",
        "scientific_name": "Baked cereal cookie",
        "moisture": 3.5,
        "ph": 6.5,
        "water_activity": 0.30,
        "fat": 18.5,
        "respiration_class": "None",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "Very High",
        "recommended_storage": "Room temperature (airtight moisture barrier)"
    },
    {
        "id": 52,
        "name": "Dry Toast Rusk",
        "category": "Bakery",
        "scientific_name": "Twice-baked bread",
        "moisture": 4.0,
        "ph": 6.0,
        "water_activity": 0.32,
        "fat": 8.0,
        "respiration_class": "None",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "Very High",
        "recommended_storage": "Room temperature (dry)"
    },

    # Other perishables
    {
        "id": 60,
        "name": "Fried Potato Chips",
        "category": "Other perishables",
        "scientific_name": "Solanum tuberosum snack",
        "moisture": 1.5,
        "ph": 6.0,
        "water_activity": 0.25,
        "fat": 32.4,
        "respiration_class": "None",
        "oxygen_sensitivity": "Very High",
        "moisture_sensitivity": "Very High",
        "recommended_storage": "Room temperature (Nitrogen flushed / Met-PET)"
    },
    {
        "id": 61,
        "name": "Mango Pickle (Oil Based)",
        "category": "Other perishables",
        "scientific_name": "Acidic condiment",
        "moisture": 42.0,
        "ph": 3.2,
        "water_activity": 0.78,
        "fat": 22.0,
        "respiration_class": "None",
        "oxygen_sensitivity": "Moderate",
        "moisture_sensitivity": "Moderate",
        "recommended_storage": "Room temperature (acid-resistant barrier)"
    },
    {
        "id": 62,
        "name": "Tomato Ketchup",
        "category": "Other perishables",
        "scientific_name": "Pasteurized tomato sauce",
        "moisture": 68.0,
        "ph": 3.7,
        "water_activity": 0.92,
        "fat": 0.2,
        "respiration_class": "None",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "Moderate",
        "recommended_storage": "Room temperature / Chilled after opening"
    },
    {
        "id": 63,
        "name": "Ready-to-Eat Dal Makhani",
        "category": "Other perishables",
        "scientific_name": "Retort sterilized meal",
        "moisture": 72.0,
        "ph": 5.6,
        "water_activity": 0.97,
        "fat": 8.5,
        "respiration_class": "None",
        "oxygen_sensitivity": "High",
        "moisture_sensitivity": "High",
        "recommended_storage": "Room temperature (Retort pouch PET/Al/PP)"
    }
]

STANDARD_FOOD_CATEGORIES = [
    {
        "category": "Fruits",
        "icon": "apple_rounded",
        "color": "#F97316",
        "description": "Fresh, climacteric & non-climacteric fruits requiring respiration and moisture management",
        "sample_items": ["Fresh Apple", "Fresh Mango", "Banana", "Strawberries"]
    },
    {
        "category": "Vegetables",
        "icon": "eco_rounded",
        "color": "#059669",
        "description": "Leafy greens, root tubers, and nightshades prone to moisture loss and high respiration",
        "sample_items": ["Fresh Tomato", "Fresh Spinach", "Potato (Ware)", "Carrot"]
    },
    {
        "category": "Grains",
        "icon": "grain_rounded",
        "color": "#D97706",
        "description": "Cereals, flours, millets, and pulses requiring dry moisture barriers and pest defense",
        "sample_items": ["Basmati Rice", "Whole Wheat Flour", "Finger Millet (Ragi)", "Chickpeas"]
    },
    {
        "category": "Dairy",
        "icon": "water_drop_rounded",
        "color": "#0284C7",
        "description": "High-fat dairy solids, cheeses, and powders sensitive to lipid oxidation and light",
        "sample_items": ["Fresh Paneer", "Cheddar Cheese", "Table Butter", "Full Cream Milk Powder"]
    },
    {
        "category": "Meat",
        "icon": "set_meal_rounded",
        "color": "#E11D48",
        "description": "Fresh poultry, red meats, and seafood vulnerable to rapid microbial and color spoilage",
        "sample_items": ["Fresh Chicken Breast", "Mutton Curry Cut", "Salmon Fish Fillet"]
    },
    {
        "category": "Bakery",
        "icon": "cake_rounded",
        "color": "#9333EA",
        "description": "Leavened breads, cookies, and dry rusks prone to staling and crispness loss",
        "sample_items": ["White Sliced Bread", "Digestive Biscuits", "Dry Toast Rusk"]
    },
    {
        "category": "Other perishables",
        "icon": "fastfood_rounded",
        "color": "#0F766E",
        "description": "Crisp snacks, pickles, sauces, and retort ready-to-eat meals requiring specialized barriers",
        "sample_items": ["Fried Potato Chips", "Mango Pickle", "Tomato Ketchup", "Ready-to-Eat Dal Makhani"]
    }
]

@router.get("/foods", summary="Get Foods")
async def get_foods(
    request: Request,
    search: Optional[str] = None,
    category: Optional[str] = None,
    limit: int = 50,
    db: AsyncSession = Depends(get_db)
):
    locale = get_requested_locale(request)
    if locale in ["ta", "hi"]:
        localized = FoodService.get_localized_commodities(
            locale=locale, category=category, search=search, limit=limit
        )
        if localized:
            return [f.model_dump() for f in localized]

    try:
        query = select(Food)
        if search:
            query = query.filter(Food.name.ilike(f"%{search}%"))
        if category:
            query = query.filter(Food.category.ilike(f"%{category}%"))
        query = query.limit(limit)
        res = await db.execute(query)
        foods = res.scalars().all()
        if foods:
            return foods
    except Exception as e:
        print(f"Notice: Database query in /foods fallback ({e})")

    # Static Fallback filtering
    filtered = STATIC_FALLBACK_FOODS
    if category:
        filtered = [f for f in filtered if category.lower() in f.get("category", "").lower()]
    if search:
        s = search.lower()
        filtered = [
            f for f in filtered
            if s in f.get("name", "").lower()
            or s in f.get("scientific_name", "").lower()
            or s in f.get("category", "").lower()
        ]
    return filtered[:limit]


@router.get("/localized-foods", response_model=List[FoodCommodityLocalized], summary="Get Localized Foods with Vernacular Metadata")
async def get_localized_foods(
    request: Request,
    search: Optional[str] = None,
    category: Optional[str] = None,
    limit: int = 50,
):
    """Returns strongly-typed localized commodity models with vernacular descriptions and storage tips."""
    locale = get_requested_locale(request)
    return FoodService.get_localized_commodities(
        locale=locale, category=category, search=search, limit=limit
    )


@router.post("/foods", response_model=FoodResponse, status_code=status.HTTP_201_CREATED, summary="Create and store a manual entry food product")
async def create_food(
    payload: FoodCreate,
    db: AsyncSession = Depends(get_db)
):
    """
    Creates and stores a new food product in the database and fallback catalog.
    Enables manual entry of uncataloged commodities (e.g., Grapes, Dragonfruit, Artisanal Sourdough).
    """
    new_food_dict = {
        "name": payload.name.strip(),
        "category": payload.category.strip(),
        "scientific_name": payload.scientific_name.strip() if payload.scientific_name else None,
        "moisture": float(payload.moisture) if payload.moisture is not None else 80.0,
        "ph": float(payload.ph) if payload.ph is not None else 6.0,
        "water_activity": float(payload.water_activity) if payload.water_activity is not None else 0.95,
        "fat": float(payload.fat) if payload.fat is not None else 0.5,
        "respiration_class": payload.respiration_class or "Moderate",
        "oxygen_sensitivity": payload.oxygen_sensitivity or "Moderate",
        "moisture_sensitivity": payload.moisture_sensitivity or "Moderate",
        "recommended_storage": payload.recommended_storage or f"Standard {payload.category} Storage"
    }

    created_id = None
    try:
        db_food = Food(
            name=new_food_dict["name"],
            category=new_food_dict["category"],
            moisture=new_food_dict["moisture"],
            ph=new_food_dict["ph"],
            water_activity=new_food_dict["water_activity"],
            fat=new_food_dict["fat"],
            respiration_class=new_food_dict["respiration_class"],
            oxygen_sensitivity=new_food_dict["oxygen_sensitivity"],
            moisture_sensitivity=new_food_dict["moisture_sensitivity"]
        )
        db.add(db_food)
        await db.commit()
        await db.refresh(db_food)
        created_id = db_food.id
    except Exception as e:
        print(f"Notice: Database write skipped for new food ({e}). Storing in memory fallback catalog.")
        if created_id is None:
            created_id = len(STATIC_FALLBACK_FOODS) + 500

    new_food_dict["id"] = created_id

    # Check if duplicate in fallback, update or insert at front
    existing_idx = next(
        (i for i, f in enumerate(STATIC_FALLBACK_FOODS) if f.get("name", "").lower() == new_food_dict["name"].lower()),
        None
    )
    if existing_idx is not None:
        STATIC_FALLBACK_FOODS[existing_idx] = new_food_dict
    else:
        STATIC_FALLBACK_FOODS.insert(0, new_food_dict)

    return new_food_dict


@router.get("/categories", summary="Get 7 Standard Food Commodity Categories")
async def get_food_categories(request: Request):
    """Returns the 7 standard food categories with icons, colors, and sample items."""
    locale = get_requested_locale(request)
    if locale in ["ta", "hi"]:
        localized = FoodService.get_localized_categories(locale=locale)
        return {
            "total": len(localized),
            "categories": [c.model_dump() for c in localized]
        }
    return {
        "total": len(STANDARD_FOOD_CATEGORIES),
        "categories": STANDARD_FOOD_CATEGORIES
    }


@router.get("/categories-summary", summary="Get Commodity Categories Summary for Home Page")
async def get_categories_summary(
    db: AsyncSession = Depends(get_db)
):
    """
    Returns grouped category statistics with sample food items for the Home Page
    category preview cards, with dynamic fallback if DB is not populated yet.
    """
    try:
        query = select(Food.category, func.count(Food.id).label("count")).group_by(Food.category)
        res = await db.execute(query)
        rows = res.all()

        if not rows:
            return {
                "source": "fallback",
                "total_foods": sum(c["count"] for c in STATIC_FALLBACK_CATEGORIES),
                "total_materials": 7,
                "categories": STATIC_FALLBACK_CATEGORIES
            }

        category_list = []
        for cat_name, count in rows:
            if not cat_name:
                continue
            sample_query = select(Food.name).filter(Food.category == cat_name).limit(4)
            sample_res = await db.execute(sample_query)
            sample_names = sample_res.scalars().all()

            category_list.append({
                "category": cat_name,
                "count": count,
                "sample_items": sample_names
            })

        mat_count_res = await db.execute(select(func.count(PackagingMaterial.id)))
        total_materials = mat_count_res.scalar_one_or_none() or 7
        total_foods = sum(c["count"] for c in category_list)

        return {
            "source": "database",
            "total_foods": total_foods,
            "total_materials": total_materials,
            "categories": category_list
        }
    except Exception as e:
        print(f"Notice: Database connection offline for /categories-summary ({e}). Returning fallback.")
        return {
            "source": "fallback",
            "total_foods": sum(c["count"] for c in STATIC_FALLBACK_CATEGORIES),
            "total_materials": 7,
            "categories": STATIC_FALLBACK_CATEGORIES
        }


@router.get("/respiration-data", summary="Get Respiration Data")
async def get_respiration_data(
    food_id: Optional[int] = None,
    limit: int = 50,
    db: AsyncSession = Depends(get_db)
):
    try:
        query = select(RespirationData)
        if food_id:
            query = query.filter(RespirationData.food_id == food_id)
        query = query.limit(limit)
        res = await db.execute(query)
        return res.scalars().all()
    except Exception as e:
        print(f"Notice: /respiration-data offline fallback ({e})")
        return []


@router.get("/packaging-materials", summary="Get Packaging Materials")
async def get_packaging_materials(
    request: Request,
    name: Optional[str] = None,
    polymer: Optional[str] = None,
    limit: int = 50,
    db: AsyncSession = Depends(get_db)
):
    locale = get_requested_locale(request)
    if locale in ["ta", "hi"]:
        localized_materials = MaterialDatabase.get_all(locale=locale)
        if name:
            s = name.lower()
            localized_materials = [m for m in localized_materials if s in m.name.lower() or s in m.name_en.lower()]
        if polymer:
            p = polymer.lower()
            localized_materials = [m for m in localized_materials if p in m.category.lower()]
        return [m.model_dump() for m in localized_materials[:limit]]

    try:
        query = select(PackagingMaterial)
        if name:
            query = query.filter(PackagingMaterial.name.ilike(f"%{name}%"))
        if polymer:
            query = query.filter(PackagingMaterial.polymer.ilike(f"%{polymer}%"))
        query = query.limit(limit)
        res = await db.execute(query)
        materials = res.scalars().all()
        return materials if materials else STATIC_FALLBACK_MATERIALS
    except Exception as e:
        print(f"Notice: /packaging-materials offline fallback ({e})")
        return STATIC_FALLBACK_MATERIALS


@router.get("/gas-properties", summary="Get Gas Barrier & Permeability Properties")
async def get_gas_properties(
    material_id: Optional[int] = None,
    gas: Optional[str] = None,
    limit: int = 50,
    db: AsyncSession = Depends(get_db)
):
    try:
        query = select(GasProperty)
        if material_id:
            query = query.filter(GasProperty.material_id == material_id)
        if gas:
            query = query.filter(GasProperty.gas.ilike(f"%{gas}%"))
        query = query.limit(limit)
        res = await db.execute(query)
        return res.scalars().all()
    except Exception as e:
        print(f"Notice: /gas-properties offline fallback ({e})")
        return []


@router.get("/sources", summary="Get Literature & Research Sources")
async def get_sources(
    limit: int = 50,
    db: AsyncSession = Depends(get_db)
):
    try:
        query = select(Source).limit(limit)
        res = await db.execute(query)
        return res.scalars().all()
    except Exception as e:
        print(f"Notice: /sources offline fallback ({e})")
        return []


@router.get("/ifct-foods", summary="Search Indian Food Composition Tables (IFCT 2017)")
async def search_ifct_foods(
    query_str: Optional[str] = Query(None, alias="q", description="Food name query"),
    group: Optional[str] = None,
    limit: int = 50,
    db: AsyncSession = Depends(get_db)
):
    try:
        query = select(IFCTFoodComposition)
        if query_str:
            query = query.filter(IFCTFoodComposition.name.ilike(f"%{query_str}%"))
        if group:
            query = query.filter(IFCTFoodComposition.group_name.ilike(f"%{group}%"))
        query = query.limit(limit)
        res = await db.execute(query)
        return res.scalars().all()
    except Exception as e:
        print(f"Notice: /ifct-foods offline fallback ({e})")
        return []


@router.post("/seed", summary="Trigger Seed Data Ingestion into PostgreSQL")
async def trigger_seed():
    try:
        from scripts.seed_database import seed
        seed()
        return {"status": "success", "message": "PostgreSQL database seeded successfully in requested schema."}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Seeding failed: {str(e)}"
        )


@router.get("/foods/scientific-lookup", response_model=FoodScientificPropertiesResponse, summary="Lookup 14-Property Food Scientific Profile by Name & Category")
async def lookup_food_scientific_profile(
    name: str = Query(..., description="Food commodity name (e.g. Fresh Tomato, Potato Chips)"),
    category: Optional[str] = Query(None, description="Food category"),
    food_id: Optional[int] = Query(None, description="Optional food database ID"),
    db: AsyncSession = Depends(get_db)
):
    try:
        query = select(Food).filter(Food.name.ilike(f"%{name}%"))
        if category:
            query = query.filter(Food.category.ilike(f"%{category}%"))
        res = await db.execute(query)
        food = res.scalars().first()
        if food:
            return get_scientific_profile_for_food(food.id, food.name, food.category)
    except Exception as e:
        print(f"Notice: /foods/scientific-lookup fallback ({e})")

    return get_scientific_profile_for_food(food_id, name, category)


@router.get("/foods/{food_id}/scientific-profile", response_model=FoodScientificPropertiesResponse, summary="Get 14-Property Food Scientific Profile & Prescriptions")
async def get_food_scientific_profile(
    food_id: int,
    db: AsyncSession = Depends(get_db)
):
    try:
        query = select(Food).filter(Food.id == food_id)
        res = await db.execute(query)
        food = res.scalars().first()
        if food:
            return get_scientific_profile_for_food(food.id, food.name, food.category)
    except Exception as e:
        print(f"Notice: /foods/{food_id}/scientific-profile fallback ({e})")

    # Match in fallback foods list
    matching_fallbacks = [f for f in STATIC_FALLBACK_FOODS if f.get("id") == food_id]
    if matching_fallbacks:
        fb = matching_fallbacks[0]
        return get_scientific_profile_for_food(fb.get("id"), fb.get("name", "Unknown"), fb.get("category"))

    # Generic fallback
    return get_scientific_profile_for_food(food_id, f"Food #{food_id}", "General")

