"""
Unit tests for Analytics Aggregation Service (Module 17).
Verifies KPI aggregations, Pareto ranking, Polymer distributions,
Category splits, Time-series calculations, and CSV/JSON exports.
"""

import unittest
import json
import csv
import io

from app.schemas.analytics import AnalyticsDateFilter, ExportFormat
from app.services.analytics_service import AnalyticsService


class TestAnalyticsService(unittest.IsolatedAsyncioTestCase):
    """Asynchronous test suite for AnalyticsService."""

    async def test_get_kpi_summary_default(self):
        """Verify default KPI benchmark values match platform specifications."""
        kpis = await AnalyticsService.get_kpi_summary(db=None, time_filter=AnalyticsDateFilter.ALL_TIME)
        self.assertEqual(kpis.total_analyses, 1245)
        self.assertEqual(kpis.unique_food_commodities, 42)
        self.assertEqual(kpis.packaging_materials_count, 18)
        self.assertEqual(kpis.total_recommendations, 1245)
        self.assertAlmostEqual(kpis.eco_adoption_rate, 41.2, places=1)
        self.assertAlmostEqual(kpis.avg_shelf_life_extension_pct, 168.5, places=1)
        self.assertAlmostEqual(kpis.mom_analysis_growth_pct, 18.4, places=1)

    async def test_get_kpi_summary_time_filters(self):
        """Verify time filter scaling adjusts totals reasonably."""
        kpis_7d = await AnalyticsService.get_kpi_summary(db=None, time_filter=AnalyticsDateFilter.LAST_7_DAYS)
        self.assertLess(kpis_7d.total_analyses, 1245)
        self.assertGreater(kpis_7d.total_analyses, 0)

        kpis_30d = await AnalyticsService.get_kpi_summary(db=None, time_filter=AnalyticsDateFilter.LAST_30_DAYS)
        self.assertGreater(kpis_30d.total_analyses, kpis_7d.total_analyses)

    async def test_get_most_analyzed_foods_pareto(self):
        """Verify top foods calculation, ranking, and cumulative Pareto curve."""
        resp = await AnalyticsService.get_most_analyzed_foods(db=None, limit=10)
        self.assertEqual(len(resp.items), 10)
        self.assertGreater(resp.total_volume, 0)

        # Check descending order
        counts = [item.analysis_count for item in resp.items]
        self.assertEqual(counts, sorted(counts, reverse=True))

        # Check Pareto cumulative share reaches close to 100%
        self.assertAlmostEqual(resp.items[-1].cumulative_pareto_pct, 100.0, places=0)

        # Top item should be Alphonso Mango
        self.assertEqual(resp.items[0].food_name, "Alphonso Mango")

        # 80% cutoff index must be identified
        self.assertIsNotNone(resp.pareto_80_cutoff_index)

    async def test_get_packaging_distribution(self):
        """Verify packaging recommendation breakdown across the 7 polymer classes."""
        resp = await AnalyticsService.get_packaging_distribution(db=None)
        self.assertEqual(len(resp.items), 7)
        self.assertGreater(resp.total_recommendations, 0)

        # Total percentage share should sum to ~100%
        total_share = sum(item.percentage_share for item in resp.items)
        self.assertAlmostEqual(total_share, 100.0, places=0)

        # Check polymer families present
        families = {item.polymer_family for item in resp.items}
        expected = {
            "BREATHABLE_BIO_EMAP",
            "METALLIZED_BARRIER",
            "HIGH_BARRIER_EVOH_VSP",
            "CELLULOSE_KRAFT_LINED",
            "RECYCLABLE_POLYOLEFIN",
            "CRYOGENIC_DEEP_FREEZE",
            "RETORT_ACID_BARRIER",
        }
        self.assertEqual(families, expected)

        # HHI index should be between 0 and 1
        self.assertGreater(resp.hhi_concentration_index, 0.1)
        self.assertLess(resp.hhi_concentration_index, 1.0)
        self.assertGreater(resp.eco_friendly_share_pct, 0.0)

    async def test_get_food_category_distribution(self):
        """Verify food taxonomy distribution."""
        resp = await AnalyticsService.get_food_category_distribution(db=None)
        self.assertEqual(len(resp.items), 6)
        self.assertGreater(resp.total_analyses, 0)

        # Total percentage share should sum to ~100%
        total_share = sum(item.percentage_share for item in resp.items)
        self.assertAlmostEqual(total_share, 100.0, places=0)

        # Primary category is Fruits & Berries
        self.assertEqual(resp.items[0].category_name, "Fruits & Berries")
        self.assertTrue(len(resp.items[0].primary_preservation_challenge) > 0)

    async def test_get_monthly_trends(self):
        """Verify 12-month time series trajectory."""
        resp = await AnalyticsService.get_monthly_trends(db=None, months=12)
        self.assertEqual(len(resp.time_series), 12)
        self.assertGreater(resp.total_period_volume, 0)
        self.assertGreater(resp.avg_monthly_analyses, 0)

        # Verify each month totals equal eco + conventional
        for pt in resp.time_series:
            self.assertEqual(pt.total_analyses, pt.eco_friendly_count + pt.conventional_count)
            self.assertGreaterEqual(pt.eco_share_pct, 0.0)
            self.assertLessEqual(pt.eco_share_pct, 100.0)

    async def test_get_full_dashboard_overview(self):
        """Verify composite overview returns all 4 KPIs and 4 charts."""
        overview = await AnalyticsService.get_full_dashboard_overview(
            db=None,
            time_filter=AnalyticsDateFilter.ALL_TIME,
        )
        self.assertIsNotNone(overview.kpi_metrics)
        self.assertEqual(overview.kpi_metrics.total_analyses, 1245)
        self.assertEqual(overview.kpi_metrics.unique_food_commodities, 42)
        self.assertEqual(overview.kpi_metrics.packaging_materials_count, 18)
        self.assertEqual(overview.kpi_metrics.total_recommendations, 1245)

        self.assertEqual(len(overview.most_analyzed_foods.items), 10)
        self.assertEqual(len(overview.packaging_distribution.items), 7)
        self.assertEqual(len(overview.category_distribution.items), 6)
        self.assertEqual(len(overview.monthly_trends.time_series), 12)

    async def test_generate_export_data_csv(self):
        """Verify CSV export formatting and content sections."""
        overview = await AnalyticsService.get_full_dashboard_overview(db=None)
        csv_text = AnalyticsService.generate_export_data(overview, format=ExportFormat.CSV)
        
        self.assertIn("SMARTPACK AI ANALYTICS DASHBOARD EXPORT", csv_text)
        self.assertIn("KEY PERFORMANCE INDICATORS", csv_text)
        self.assertIn("MOST ANALYZED FOODS", csv_text)
        self.assertIn("Alphonso Mango", csv_text)
        self.assertIn("BREATHABLE_BIO_EMAP", csv_text)
        self.assertIn("12-MONTH ANALYSIS TRAJECTORY", csv_text)

        # Parse CSV to verify valid CSV structure
        reader = csv.reader(io.StringIO(csv_text))
        rows = list(reader)
        self.assertGreater(len(rows), 20)

    async def test_generate_export_data_json(self):
        """Verify JSON export formatting."""
        overview = await AnalyticsService.get_full_dashboard_overview(db=None)
        json_text = AnalyticsService.generate_export_data(overview, format=ExportFormat.JSON)
        
        parsed = json.loads(json_text)
        self.assertIn("kpi_metrics", parsed)
        self.assertEqual(parsed["kpi_metrics"]["total_analyses"], 1245)
        self.assertIn("most_analyzed_foods", parsed)
        self.assertIn("packaging_distribution", parsed)


if __name__ == "__main__":
    unittest.main()
