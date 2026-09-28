"""
Integration tests for Analytics REST API Endpoints (Module 17).
Verifies HTTP response codes, response payload schemas, time filtering,
and CSV/JSON export functionality.
"""

import unittest
from fastapi.testclient import TestClient

from app.main import app


class TestAnalyticsAPI(unittest.TestCase):
    """Integration test suite for /api/v1/analytics endpoints."""

    def setUp(self):
        self.client = TestClient(app)

    def test_get_overview_endpoint(self):
        """Test GET /api/v1/analytics/overview returns 200 with composite payload."""
        response = self.client.get("/api/v1/analytics/overview")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertIn("kpi_metrics", data)
        self.assertEqual(data["kpi_metrics"]["total_analyses"], 1245)
        self.assertEqual(data["kpi_metrics"]["unique_food_commodities"], 42)
        self.assertEqual(data["kpi_metrics"]["packaging_materials_count"], 18)
        self.assertEqual(data["kpi_metrics"]["total_recommendations"], 1245)

        self.assertIn("most_analyzed_foods", data)
        self.assertEqual(len(data["most_analyzed_foods"]["items"]), 10)

        self.assertIn("packaging_distribution", data)
        self.assertEqual(len(data["packaging_distribution"]["items"]), 7)

        self.assertIn("category_distribution", data)
        self.assertEqual(len(data["category_distribution"]["items"]), 6)

        self.assertIn("monthly_trends", data)
        self.assertEqual(len(data["monthly_trends"]["time_series"]), 12)

    def test_get_overview_with_time_filter(self):
        """Test GET /api/v1/analytics/overview?time_filter=30D."""
        response = self.client.get("/api/v1/analytics/overview?time_filter=30D")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["applied_filter"], "30D")

    def test_get_kpis_endpoint(self):
        """Test GET /api/v1/analytics/kpis."""
        response = self.client.get("/api/v1/analytics/kpis")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertEqual(data["total_analyses"], 1245)
        self.assertEqual(data["unique_food_commodities"], 42)
        self.assertEqual(data["packaging_materials_count"], 18)
        self.assertEqual(data["total_recommendations"], 1245)
        self.assertAlmostEqual(data["eco_adoption_rate"], 41.2, places=1)

    def test_get_most_analyzed_foods_endpoint(self):
        """Test GET /api/v1/analytics/most-analyzed-foods with limit parameter."""
        response = self.client.get("/api/v1/analytics/most-analyzed-foods?limit=5")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertEqual(len(data["items"]), 5)
        self.assertEqual(data["items"][0]["food_name"], "Alphonso Mango")
        self.assertIn("percentage_share", data["items"][0])

    def test_get_packaging_distribution_endpoint(self):
        """Test GET /api/v1/analytics/packaging-distribution."""
        response = self.client.get("/api/v1/analytics/packaging-distribution")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertEqual(len(data["items"]), 7)
        self.assertGreater(data["eco_friendly_share_pct"], 0.0)
        self.assertGreater(data["hhi_concentration_index"], 0.0)

    def test_get_category_distribution_endpoint(self):
        """Test GET /api/v1/analytics/category-distribution."""
        response = self.client.get("/api/v1/analytics/category-distribution")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertEqual(len(data["items"]), 6)
        self.assertEqual(data["items"][0]["category_name"], "Fruits & Berries")

    def test_get_monthly_trends_endpoint(self):
        """Test GET /api/v1/analytics/monthly-trends."""
        response = self.client.get("/api/v1/analytics/monthly-trends?months=6")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertEqual(len(data["time_series"]), 6)
        self.assertGreater(data["total_period_volume"], 0)

    def test_export_csv_endpoint(self):
        """Test GET /api/v1/analytics/export?format=csv."""
        response = self.client.get("/api/v1/analytics/export?format=csv")
        self.assertEqual(response.status_code, 200)
        self.assertIn("text/csv", response.headers["content-type"])
        self.assertIn("attachment; filename=", response.headers["content-disposition"])
        self.assertIn("SMARTPACK AI ANALYTICS DASHBOARD EXPORT", response.text)
        self.assertIn("KEY PERFORMANCE INDICATORS", response.text)
        self.assertIn("Alphonso Mango", response.text)

    def test_export_json_endpoint(self):
        """Test GET /api/v1/analytics/export?format=json."""
        response = self.client.get("/api/v1/analytics/export?format=json")
        self.assertEqual(response.status_code, 200)
        self.assertIn("application/json", response.headers["content-type"])
        self.assertIn("attachment; filename=", response.headers["content-disposition"])
        data = response.json()
        self.assertIn("kpi_metrics", data)


if __name__ == "__main__":
    unittest.main()
