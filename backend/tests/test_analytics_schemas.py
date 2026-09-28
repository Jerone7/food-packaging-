"""
Unit tests for Analytics Dashboard Pydantic Schemas (Module 17).
Verifies KPI models, Pareto charts, Donut distributions, Category splits,
Monthly trends, and Composite overview schemas.
"""

import unittest
from datetime import datetime
from pydantic import ValidationError

from app.schemas.analytics import (
    AnalyticsDateFilter,
    ExportFormat,
    KpiSummaryMetrics,
    MostAnalyzedFoodItem,
    MostAnalyzedFoodsResponse,
    PackagingDistributionItem,
    PackagingDistributionResponse,
    FoodCategoryDistributionItem,
    FoodCategoryDistributionResponse,
    MonthlyTrendDataPoint,
    MonthlyTrendResponse,
    AnalyticsDashboardOverviewResponse,
    AnalyticsExportRequest,
)


class TestAnalyticsSchemas(unittest.TestCase):
    """Test suite for analytics schema validation and serialization."""

    def test_enums(self):
        """Verify enum string representations."""
        self.assertEqual(AnalyticsDateFilter.LAST_7_DAYS.value, "7D")
        self.assertEqual(AnalyticsDateFilter.LAST_30_DAYS.value, "30D")
        self.assertEqual(AnalyticsDateFilter.LAST_90_DAYS.value, "90D")
        self.assertEqual(AnalyticsDateFilter.LAST_1_YEAR.value, "1Y")
        self.assertEqual(AnalyticsDateFilter.ALL_TIME.value, "ALL")

        self.assertEqual(ExportFormat.CSV.value, "csv")
        self.assertEqual(ExportFormat.JSON.value, "json")

    def test_kpi_summary_metrics_defaults(self):
        """Verify default KPI metrics represent expected platform benchmark."""
        kpis = KpiSummaryMetrics()
        self.assertEqual(kpis.total_analyses, 1245)
        self.assertEqual(kpis.unique_food_commodities, 42)
        self.assertEqual(kpis.packaging_materials_count, 18)
        self.assertEqual(kpis.total_recommendations, 1245)
        self.assertAlmostEqual(kpis.eco_adoption_rate, 41.2, places=1)
        self.assertAlmostEqual(kpis.avg_shelf_life_extension_pct, 168.5, places=1)
        self.assertAlmostEqual(kpis.mom_analysis_growth_pct, 18.4, places=1)

    def test_kpi_summary_metrics_custom(self):
        """Verify custom KPI assignment."""
        kpis = KpiSummaryMetrics(
            total_analyses=2500,
            unique_food_commodities=50,
            packaging_materials_count=22,
            total_recommendations=2500,
            eco_adoption_rate=55.0,
            avg_shelf_life_extension_pct=190.2,
            mom_analysis_growth_pct=22.5,
        )
        self.assertEqual(kpis.total_analyses, 2500)
        self.assertEqual(kpis.unique_food_commodities, 50)
        self.assertEqual(kpis.packaging_materials_count, 22)
        self.assertEqual(kpis.total_recommendations, 2500)
        self.assertEqual(kpis.eco_adoption_rate, 55.0)

    def test_most_analyzed_foods_schema(self):
        """Verify MostAnalyzedFoodItem and response container."""
        item = MostAnalyzedFoodItem(
            food_id=1,
            food_name="Fresh Tomato",
            food_category="Vegetables",
            analysis_count=184,
            percentage_share=14.78,
            cumulative_pareto_pct=14.78,
            shelf_life_extension_days=12.5,
        )
        self.assertEqual(item.food_name, "Fresh Tomato")
        self.assertEqual(item.analysis_count, 184)
        self.assertAlmostEqual(item.percentage_share, 14.78, places=2)

        resp = MostAnalyzedFoodsResponse(
            total_volume=184,
            items=[item],
            pareto_80_cutoff_index=0,
        )
        self.assertEqual(resp.total_volume, 184)
        self.assertEqual(len(resp.items), 1)

    def test_most_analyzed_foods_validation_error(self):
        """Verify boundary checks on food items."""
        # Negative count
        with self.assertRaises(ValidationError):
            MostAnalyzedFoodItem(
                food_id=1,
                food_name="Bad Item",
                food_category="Fruits",
                analysis_count=-5,
                percentage_share=10.0,
            )
        # Percentage > 100
        with self.assertRaises(ValidationError):
            MostAnalyzedFoodItem(
                food_id=1,
                food_name="Bad Item",
                food_category="Fruits",
                analysis_count=50,
                percentage_share=120.0,
            )

    def test_packaging_distribution_schema(self):
        """Verify PackagingDistributionItem and response container."""
        item = PackagingDistributionItem(
            polymer_family="BREATHABLE_BIO_EMAP",
            display_name="Breathable Bio-EMAP Film",
            recommendation_count=342,
            percentage_share=27.47,
            is_eco_friendly=True,
            dominant_application="Respiring Fresh Produce",
        )
        self.assertEqual(item.polymer_family, "BREATHABLE_BIO_EMAP")
        self.assertTrue(item.is_eco_friendly)

        resp = PackagingDistributionResponse(
            total_recommendations=342,
            items=[item],
            eco_friendly_share_pct=27.47,
            hhi_concentration_index=0.185,
        )
        self.assertEqual(resp.total_recommendations, 342)
        self.assertAlmostEqual(resp.eco_friendly_share_pct, 27.47, places=2)

    def test_food_category_distribution_schema(self):
        """Verify FoodCategoryDistributionItem and response."""
        item = FoodCategoryDistributionItem(
            category_name="Fruits & Berries",
            commodity_count=14,
            analysis_count=420,
            percentage_share=33.73,
            primary_preservation_challenge="Ethylene ripening & Moisture Loss",
            top_prescribed_polymer="BREATHABLE_BIO_EMAP",
        )
        self.assertEqual(item.category_name, "Fruits & Berries")
        self.assertEqual(item.commodity_count, 14)

        resp = FoodCategoryDistributionResponse(
            total_analyses=420,
            items=[item],
        )
        self.assertEqual(resp.total_analyses, 420)
        self.assertEqual(len(resp.items), 1)

    def test_monthly_trend_schema(self):
        """Verify MonthlyTrendDataPoint and response."""
        pt = MonthlyTrendDataPoint(
            month_key="2026-03",
            month_label="Mar 2026",
            year=2026,
            total_analyses=128,
            eco_friendly_count=58,
            conventional_count=70,
            mom_growth_pct=14.2,
            eco_share_pct=45.31,
        )
        self.assertEqual(pt.month_key, "2026-03")
        self.assertEqual(pt.total_analyses, 128)
        self.assertEqual(pt.eco_friendly_count, 58)

        resp = MonthlyTrendResponse(
            time_series=[pt],
            total_period_volume=128,
            avg_monthly_analyses=128.0,
            overall_growth_pct=14.2,
        )
        self.assertEqual(resp.total_period_volume, 128)
        self.assertEqual(len(resp.time_series), 1)

    def test_composite_overview_response(self):
        """Verify complete AnalyticsDashboardOverviewResponse construction."""
        kpis = KpiSummaryMetrics()
        foods = MostAnalyzedFoodsResponse(total_volume=100, items=[])
        pkgs = PackagingDistributionResponse(total_recommendations=100, items=[])
        cats = FoodCategoryDistributionResponse(total_analyses=100, items=[])
        trends = MonthlyTrendResponse(time_series=[], total_period_volume=100, avg_monthly_analyses=100.0)

        overview = AnalyticsDashboardOverviewResponse(
            kpi_metrics=kpis,
            most_analyzed_foods=foods,
            packaging_distribution=pkgs,
            category_distribution=cats,
            monthly_trends=trends,
            applied_filter=AnalyticsDateFilter.ALL_TIME,
        )

        self.assertEqual(overview.kpi_metrics.total_analyses, 1245)
        self.assertEqual(overview.applied_filter, AnalyticsDateFilter.ALL_TIME)
        self.assertIsInstance(overview.generated_at, datetime)

    def test_export_request_schema(self):
        """Verify export request parameter parsing."""
        req = AnalyticsExportRequest(
            time_filter=AnalyticsDateFilter.LAST_30_DAYS,
            format=ExportFormat.CSV,
            include_raw_records=True,
        )
        self.assertEqual(req.time_filter, AnalyticsDateFilter.LAST_30_DAYS)
        self.assertEqual(req.format, ExportFormat.CSV)
        self.assertTrue(req.include_raw_records)


if __name__ == "__main__":
    unittest.main()
