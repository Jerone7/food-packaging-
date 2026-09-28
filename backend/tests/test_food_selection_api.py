import unittest
import sys
import os

backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from starlette.testclient import TestClient
from app.main import app

class TestFoodSelectionApi(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)

    def test_get_standard_categories(self):
        response = self.client.get("/api/v1/data/categories")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("categories", data)
        self.assertEqual(data["total"], 7)
        
        category_names = [c["category"] for c in data["categories"]]
        expected_categories = [
            "Fruits", "Vegetables", "Grains", "Dairy", "Meat", "Bakery", "Other perishables"
        ]
        for expected in expected_categories:
            self.assertIn(expected, category_names)

    def test_get_foods_search_apple(self):
        response = self.client.get("/api/v1/data/foods?search=apple")
        self.assertEqual(response.status_code, 200)
        foods = response.json()
        self.assertIsInstance(foods, list)
        self.assertGreater(len(foods), 0)
        
        # Check first item contains apple
        first = foods[0]
        self.assertTrue(
            "apple" in first["name"].lower() or "apple" in first.get("scientific_name", "").lower()
        )

    def test_get_foods_category_filtering(self):
        for cat in ["Fruits", "Vegetables", "Grains", "Dairy", "Meat", "Bakery", "Other perishables"]:
            response = self.client.get(f"/api/v1/data/foods?category={cat}")
            self.assertEqual(response.status_code, 200)
            foods = response.json()
            self.assertIsInstance(foods, list)
            self.assertGreater(len(foods), 0, f"No foods found for category {cat}")
            for item in foods:
                self.assertIn(cat.lower(), item["category"].lower())

    def test_get_foods_biochemical_fields_completeness(self):
        response = self.client.get("/api/v1/data/foods?search=paneer")
        self.assertEqual(response.status_code, 200)
        foods = response.json()
        self.assertGreater(len(foods), 0)
        item = foods[0]
        
        required_fields = ["name", "category", "moisture", "ph", "fat", "water_activity", "respiration_class"]
        for field in required_fields:
            self.assertIn(field, item, f"Missing {field} in food item payload")
            self.assertIsNotNone(item[field], f"Field {field} is None")

    def test_get_foods_combined_search_and_category(self):
        response = self.client.get("/api/v1/data/foods?search=chips&category=Other%20perishables")
        self.assertEqual(response.status_code, 200)
        foods = response.json()
        self.assertGreater(len(foods), 0)
        self.assertIn("chips", foods[0]["name"].lower())
        self.assertIn("other perishables", foods[0]["category"].lower())

if __name__ == "__main__":
    unittest.main()
