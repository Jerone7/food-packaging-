import unittest
import sys
import os

# Add backend directory to path
backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

from starlette.testclient import TestClient
from app.main import app

class TestFoodDataApi(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)

    def test_root_health_check(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data.get("status"), "online")
        self.assertIn("docs_url", data)

    def test_get_foods_endpoint(self):
        response = self.client.get("/api/v1/data/foods?limit=5")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIsInstance(data, list)

    def test_get_categories_summary_endpoint(self):
        response = self.client.get("/api/v1/data/categories-summary")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        
        # Verify required keys for Home Page rendering
        self.assertIn("categories", data)
        self.assertIn("total_foods", data)
        self.assertIn("total_materials", data)
        self.assertIsInstance(data["categories"], list)
        self.assertGreater(len(data["categories"]), 0)

        # Verify category item structure
        first_cat = data["categories"][0]
        self.assertIn("category", first_cat)
        self.assertIn("sample_items", first_cat)
        self.assertIsInstance(first_cat["sample_items"], list)

    def test_get_packaging_materials_endpoint(self):
        response = self.client.get("/api/v1/data/packaging-materials")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIsInstance(data, list)

    def test_create_manual_entry_food_endpoint(self):
        payload = {
            "name": "Fresh Organic Grapes",
            "category": "Fruits",
            "scientific_name": "Vitis vinifera",
            "moisture": 81.5,
            "ph": 3.6,
            "fat": 0.2,
            "water_activity": 0.97,
            "respiration_class": "Low",
            "oxygen_sensitivity": "Moderate",
            "moisture_sensitivity": "High",
            "recommended_storage": "Refrigerated (0-1°C, 90-95% RH)"
        }
        response = self.client.post("/api/v1/data/foods", json=payload)
        self.assertEqual(response.status_code, 201)
        data = response.json()
        self.assertEqual(data["name"], "Fresh Organic Grapes")
        self.assertEqual(data["category"], "Fruits")
        self.assertIsNotNone(data["id"])

        # Verify it now appears in search
        search_res = self.client.get("/api/v1/data/foods?search=Grapes")
        self.assertEqual(search_res.status_code, 200)
        search_data = search_res.json()
        self.assertTrue(any(f["name"] == "Fresh Organic Grapes" for f in search_data))

    def test_recommendation_endpoint(self):
        payload = {
            "food_name": "Eco Ceramic Mug",
            "length": 12.0,
            "width": 10.0,
            "height": 15.0,
            "weight": 0.45,
            "is_fragile": True,
            "eco_friendly": True
        }
        response = self.client.post("/api/v1/packaging/recommend", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("primary_recommendation", data)
        self.assertIn("box_geometry", data)
        self.assertIn("alternatives", data)
        self.assertGreater(data["primary_recommendation"]["sustainability_score"], 50)

if __name__ == "__main__":
    unittest.main()
