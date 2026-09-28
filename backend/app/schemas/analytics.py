"""
Analytics Dashboard Pydantic Schemas (Module 17).
Defines request and response schemas for KPI metrics, Pareto-ranked top analyzed foods,
polymer packaging recommendation distribution, food taxonomy distribution,
12-month time-series trajectories, and data export contracts.
"""

from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field, ConfigDict


# ==========================================
# 1. Enums & Query Filters
# ==========================================

class AnalyticsDateFilter(str, Enum):
    LAST_7_DAYS = "7D"
    LAST_30_DAYS = "30D"
    LAST_90_DAYS = "90D"
    LAST_1_YEAR = "1Y"
    ALL_TIME = "ALL"


class ExportFormat(str, Enum):
    CSV = "csv"
    JSON = "json"


# ==========================================
# 2. Key Performance Indicators (KPIs)
# ==========================================

class KpiSummaryMetrics(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    total_analyses: int = Field(default=1245, description="Total packaging analyses performed")
    unique_food_commodities: int = Field(default=42, description="Total unique active food commodities cataloged")
    packaging_materials_count: int = Field(default=18, description="Total engineered barrier substrates indexed")
    total_recommendations: int = Field(default=1245, description="Total packaging recommendations generated")
    eco_adoption_rate: float = Field(default=41.2, description="Percentage of recommendations utilizing compostable/recycled substrates")
    avg_shelf_life_extension_pct: float = Field(default=168.5, description="Average percentage shelf life extension across recommendations")
    mom_analysis_growth_pct: float = Field(default=18.4, description="Month-over-Month growth percentage in analyses")


# ==========================================
# 3. Chart 1: Most Analyzed Foods (Pareto)
# ==========================================

class MostAnalyzedFoodItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    food_id: int = Field(..., description="Unique food database identifier")
    food_name: str = Field(..., description="Common commodity name (e.g. Alphonso Mango, Fresh Tomato)")
    food_category: str = Field(..., description="Food taxonomy category (e.g. Fruits, Vegetables)")
    analysis_count: int = Field(..., ge=0, description="Total number of times analyzed")
    percentage_share: float = Field(..., ge=0.0, le=100.0, description="Percentage share of total analysis volume")
    cumulative_pareto_pct: float = Field(default=0.0, ge=0.0, le=100.0, description="Cumulative Pareto volume percentage")
    shelf_life_extension_days: float = Field(default=0.0, ge=0.0, description="Average shelf life extension achieved in days")


class MostAnalyzedFoodsResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    total_volume: int = Field(..., description="Sum of analyses across displayed items")
    items: List[MostAnalyzedFoodItem] = Field(default_factory=list, description="Ranked list of analyzed foods")
    pareto_80_cutoff_index: Optional[int] = Field(default=None, description="Index where cumulative volume surpasses 80%")


# ==========================================
# 4. Chart 2: Packaging Recommendation Distribution
# ==========================================

class PackagingDistributionItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    polymer_family: str = Field(..., description="Standardized polymer category code (e.g. BREATHABLE_BIO_EMAP)")
    display_name: str = Field(..., description="Human-readable display name")
    recommendation_count: int = Field(..., ge=0, description="Total recommendations prescribing this polymer")
    percentage_share: float = Field(..., ge=0.0, le=100.0, description="Share percentage of total recommendations")
    is_eco_friendly: bool = Field(default=False, description="Whether the polymer substrate is biodegradable or mono-recyclable")
    dominant_application: str = Field(default="", description="Primary application sector (e.g. Respiring Produce, Protein VSP)")


class PackagingDistributionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    total_recommendations: int = Field(..., description="Total recommendations aggregated")
    items: List[PackagingDistributionItem] = Field(default_factory=list, description="Distribution across polymer families")
    eco_friendly_share_pct: float = Field(default=0.0, description="Total aggregate share of eco-friendly substrates")
    hhi_concentration_index: float = Field(default=0.0, description="Herfindahl-Hirschman diversity index of materials")


# ==========================================
# 5. Chart 3: Food Category Distribution
# ==========================================

class FoodCategoryDistributionItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    category_name: str = Field(..., description="Food category name (e.g. Fruits, Vegetables, Dairy)")
    commodity_count: int = Field(..., ge=0, description="Number of distinct commodities in this category")
    analysis_count: int = Field(..., ge=0, description="Total analysis volume in this category")
    percentage_share: float = Field(..., ge=0.0, le=100.0, description="Share of total platform analyses")
    primary_preservation_challenge: str = Field(default="", description="Key shelf-life degradation driver")
    top_prescribed_polymer: str = Field(default="", description="Most frequently matched polymer family")


class FoodCategoryDistributionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    total_analyses: int = Field(..., description="Total analyses aggregated across categories")
    items: List[FoodCategoryDistributionItem] = Field(default_factory=list, description="Breakdown by food taxonomy category")


# ==========================================
# 6. Chart 4: Monthly Analysis Count & Trends
# ==========================================

class MonthlyTrendDataPoint(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    month_key: str = Field(..., description="Sortable month key in YYYY-MM format (e.g. 2026-03)")
    month_label: str = Field(..., description="Display label (e.g. Mar 2026)")
    year: int = Field(..., description="Calendar year")
    total_analyses: int = Field(..., ge=0, description="Total analyses completed in this month")
    eco_friendly_count: int = Field(..., ge=0, description="Analyses prescribing biodegradable/recyclable packaging")
    conventional_count: int = Field(..., ge=0, description="Analyses prescribing conventional barrier packaging")
    mom_growth_pct: float = Field(default=0.0, description="Month-over-month growth rate percentage")
    eco_share_pct: float = Field(default=0.0, ge=0.0, le=100.0, description="Eco-friendly packaging adoption ratio")


class MonthlyTrendResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    time_series: List[MonthlyTrendDataPoint] = Field(default_factory=list, description="Chronological monthly data points")
    total_period_volume: int = Field(..., description="Total analyses across the time series")
    avg_monthly_analyses: float = Field(..., description="Mean monthly analysis volume")
    overall_growth_pct: float = Field(default=0.0, description="Net growth over the observed time horizon")


# ==========================================
# 7. Composite Dashboard & Export Contracts
# ==========================================

class AnalyticsDashboardOverviewResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    kpi_metrics: KpiSummaryMetrics = Field(..., description="Primary KPI summary metric cards")
    most_analyzed_foods: MostAnalyzedFoodsResponse = Field(..., description="Leaderboard Pareto chart dataset")
    packaging_distribution: PackagingDistributionResponse = Field(..., description="Polymer distribution donut dataset")
    category_distribution: FoodCategoryDistributionResponse = Field(..., description="Category radial dataset")
    monthly_trends: MonthlyTrendResponse = Field(..., description="12-month dual-spline trend dataset")
    applied_filter: AnalyticsDateFilter = Field(default=AnalyticsDateFilter.ALL_TIME, description="Active time-range filter")
    generated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), description="UTC timestamp of aggregation generation")


class AnalyticsExportRequest(BaseModel):
    time_filter: AnalyticsDateFilter = Field(default=AnalyticsDateFilter.ALL_TIME, description="Time filter to apply to export")
    format: ExportFormat = Field(default=ExportFormat.CSV, description="Export file format")
    include_raw_records: bool = Field(default=False, description="Whether to include itemized analysis rows")
