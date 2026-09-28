"""
Unit and Integration Tests for Localized Food Commodities Matrix & Materials (Task 2.2).
Tests FoodService, MaterialDatabase, and /api/v1/food-data localization endpoints
with Accept-Language header and ?lang= query overrides in English, Tamil, and Hindi.
"""

import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.services.food_service import FoodService
from app.core.material_database import MaterialDatabase
from app.schemas.food_data import FoodCommodityLocalized, PackagingMaterialLocalized


class TestFoodService(unittest.TestCase):
    """Unit tests for FoodService localization logic."""

    def test_english_default_commodities(self):
        items = FoodService.get_localized_commodities(locale="en")
        self.assertGreaterEqual(len(items), 20)
        first = items[0]
        self.assertEqual(first.name, "Fresh Tomato")
        self.assertIn("moisture loss", first.spoilage_vector.lower())
        self.assertIn("10-12°c", first.storage_recommendation.lower())

    def test_tamil_commodities_localization(self):
        items = FoodService.get_localized_commodities(locale="ta")
        self.assertGreaterEqual(len(items), 20)
        # Find Tomato
        tomato = next((f for f in items if f.id == "veg_tomato"), None)
        self.assertIsNotNone(tomato)
        self.assertEqual(tomato.name, "தக்காளி")
        self.assertEqual(tomato.name_en, "Fresh Tomato")
        self.assertIn("பூஞ்சை", tomato.spoilage_vector)
        self.assertIn("குளிர்ந்த", tomato.storage_recommendation)

        # Find Mango
        mango = next((f for f in items if f.id == "fruit_alphonso_mango"), None)
        self.assertIsNotNone(mango)
        self.assertEqual(mango.name, "அல்போன்சா மாம்பழம்")

        # Find Moringa Powder
        moringa = next((f for f in items if f.id == "veg_moringa_powder"), None)
        self.assertIsNotNone(moringa)
        self.assertEqual(moringa.name, "முருங்கை இலை பொடி")
        self.assertIn("நைட்ரஜன்", moringa.storage_recommendation)

    def test_hindi_commodities_localization(self):
        items = FoodService.get_localized_commodities(locale="hi")
        tomato = next((f for f in items if f.id == "veg_tomato"), None)
        self.assertIsNotNone(tomato)
        self.assertEqual(tomato.name, "टमाटर")
        self.assertIn("फफूंद", tomato.spoilage_vector)

        rice = next((f for f in items if f.id == "grain_basmati_rice"), None)
        self.assertIsNotNone(rice)
        self.assertEqual(rice.name, "बासमती चावल")

    def test_category_filtering(self):
        fruits = FoodService.get_localized_commodities(locale="ta", category="Fruits")
        self.assertTrue(all(f.category == "Fruits" for f in fruits))
        self.assertGreaterEqual(len(fruits), 4)

    def test_search_filtering_in_tamil_and_english(self):
        # Search by English term
        results_en = FoodService.get_localized_commodities(locale="ta", search="moringa")
        self.assertGreaterEqual(len(results_en), 2)

        # Search by Tamil script ("தக்காளி" matches Fresh Tomato and Tomato Ketchup)
        results_ta = FoodService.get_localized_commodities(locale="ta", search="தக்காளி")
        self.assertEqual(len(results_ta), 2)
        self.assertEqual(results_ta[0].id, "veg_tomato")

    def test_get_commodity_by_name(self):
        item_by_en = FoodService.get_localized_commodity_by_name("Fresh Tomato", locale="ta")
        self.assertIsNotNone(item_by_en)
        self.assertEqual(item_by_en.name, "தக்காளி")

        item_by_ta = FoodService.get_localized_commodity_by_name("தக்காளி", locale="en")
        self.assertIsNotNone(item_by_ta)
        self.assertEqual(item_by_ta.name, "Fresh Tomato")

        item_by_hi = FoodService.get_localized_commodity_by_name("टमाटर", locale="hi")
        self.assertIsNotNone(item_by_hi)
        self.assertEqual(item_by_hi.name, "टमाटर")

    def test_localized_categories(self):
        categories_ta = FoodService.get_localized_categories(locale="ta")
        self.assertEqual(len(categories_ta), 7)
        veg_cat = next((c for c in categories_ta if c.category == "Vegetables"), None)
        self.assertIsNotNone(veg_cat)
        self.assertEqual(veg_cat.name, "காய்கறிகள்")
        self.assertIn("தக்காளி", veg_cat.sample_items)

        categories_hi = FoodService.get_localized_categories(locale="hi")
        veg_cat_hi = next((c for c in categories_hi if c.category == "Vegetables"), None)
        self.assertEqual(veg_cat_hi.name, "सब्जियां")
        self.assertIn("टमाटर", veg_cat_hi.sample_items)


class TestMaterialDatabase(unittest.TestCase):
    """Unit tests for MaterialDatabase localization."""

    def test_english_materials(self):
        mats = MaterialDatabase.get_all(locale="en")
        self.assertGreaterEqual(len(mats), 6)
        ldpe = next((m for m in mats if m.material_id == "mat_ldpe"), None)
        self.assertIsNotNone(ldpe)
        self.assertIn("Low-Density Polyethylene", ldpe.name)

    def test_tamil_materials(self):
        mats = MaterialDatabase.get_all(locale="ta")
        ldpe = next((m for m in mats if m.material_id == "mat_ldpe"), None)
        self.assertIsNotNone(ldpe)
        self.assertIn("குறைந்த அடர்த்தி", ldpe.name)
        self.assertIn("ஈரப்பதம்", ldpe.description)

        foil = next((m for m in mats if m.material_id == "mat_alu_foil"), None)
        self.assertIsNotNone(foil)
        self.assertIn("அலுமினியம்", foil.name)

    def test_hindi_materials(self):
        mats = MaterialDatabase.get_all(locale="hi")
        ldpe = next((m for m in mats if m.material_id == "mat_ldpe"), None)
        self.assertIsNotNone(ldpe)
        self.assertIn("पॉलीथीन", ldpe.name)
        self.assertIn("नमी", ldpe.description)

    def test_get_by_id(self):
        mat = MaterialDatabase.get_by_id("mat_pla", locale="ta")
        self.assertIsNotNone(mat)
        self.assertIn("மக்கும்", mat.name)
        self.assertTrue(mat.is_biodegradable)


class TestFoodDataApiLocalization(unittest.TestCase):
    """Integration tests verifying REST endpoints respond with localized data."""

    def setUp(self):
        self.client = TestClient(app, raise_server_exceptions=False)

    def test_get_foods_with_tamil_accept_language(self):
        resp = self.client.get(
            "/api/v1/food-data/foods",
            headers={"Accept-Language": "ta-IN,ta;q=0.9,en;q=0.8"}
        )
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-language"), "ta")
        data = resp.json()
        self.assertGreater(len(data), 0)
        # Tomato in Tamil
        tomato = next((item for item in data if item.get("id") == "veg_tomato"), None)
        self.assertIsNotNone(tomato)
        self.assertEqual(tomato["name"], "தக்காளி")
        self.assertIn("பூஞ்சை", tomato["spoilage_vector"])

    def test_get_foods_with_hindi_query_param(self):
        resp = self.client.get("/api/v1/food-data/foods?lang=hi")
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-language"), "hi")
        data = resp.json()
        tomato = next((item for item in data if item.get("id") == "veg_tomato"), None)
        self.assertIsNotNone(tomato)
        self.assertEqual(tomato["name"], "टमाटर")

    def test_get_localized_foods_endpoint(self):
        resp = self.client.get(
            "/api/v1/food-data/localized-foods",
            headers={"Accept-Language": "ta"}
        )
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertTrue(any(item["name"] == "தக்காளி" for item in data))
        self.assertTrue(any(item["name"] == "அல்போன்சா மாம்பழம்" for item in data))

    def test_get_categories_localized_in_tamil(self):
        resp = self.client.get(
            "/api/v1/food-data/categories",
            headers={"Accept-Language": "ta"}
        )
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        cats = data.get("categories", [])
        self.assertTrue(any(c["name"] == "காய்கறிகள்" for c in cats))
        self.assertTrue(any(c["name"] == "பழங்கள்" for c in cats))

    def test_get_packaging_materials_localized_in_tamil(self):
        resp = self.client.get(
            "/api/v1/food-data/packaging-materials",
            headers={"Accept-Language": "ta"}
        )
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertTrue(any("குறைந்த அடர்த்தி" in m.get("name", "") for m in data))


if __name__ == "__main__":
    unittest.main()
