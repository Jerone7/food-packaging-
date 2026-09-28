"""
Analytics Dashboard Endpoints (Module 17: Analytics Dashboard).
Provides high-performance REST routes for platform KPIs, Pareto leaderboard,
packaging polymer breakdown, food taxonomy distribution, 12-month trends, and data export.
"""

import time
from typing import Optional, Dict, Any
from fastapi import APIRouter, Depends, Query, Response
from fastapi.responses import PlainTextResponse, JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.services.analytics_service import AnalyticsService
from app.schemas.analytics import (
    AnalyticsDateFilter,
    ExportFormat,
    KpiSummaryMetrics,
    MostAnalyzedFoodsResponse,
    PackagingDistributionResponse,
    FoodCategoryDistributionResponse,
    MonthlyTrendResponse,
    AnalyticsDashboardOverviewResponse,
)

router = APIRouter()

# In-memory TTL cache store (Key: filter_type, Value: (timestamp, data))
_ANALYTICS_CACHE: Dict[str, tuple[float, Any]] = {}
_CACHE_TTL_SECONDS = 60.0


def _get_cached_data(cache_key: str) -> Optional[Any]:
    if cache_key in _ANALYTICS_CACHE:
        timestamp, data = _ANALYTICS_CACHE[cache_key]
        if time.time() - timestamp < _CACHE_TTL_SECONDS:
            return data
    return None


def _set_cached_data(cache_key: str, data: Any):
    _ANALYTICS_CACHE[cache_key] = (time.time(), data)


# ==========================================
# 1. Overview & Key Performance Indicators
# ==========================================

@router.get(
    "/overview",
    response_model=AnalyticsDashboardOverviewResponse,
    summary="Get Complete Analytics Dashboard Overview",
    description="Returns composite analytics payload containing all 4 KPI cards and 4 interactive chart datasets.",
)
async def get_dashboard_overview(
    time_filter: AnalyticsDateFilter = Query(
        default=AnalyticsDateFilter.ALL_TIME,
        description="Time-range filter (7D, 30D, 90D, 1Y, ALL)",
    ),
    db: AsyncSession = Depends(get_db),
) -> AnalyticsDashboardOverviewResponse:
    cache_key = f"overview_{time_filter.value}"
    cached = _get_cached_data(cache_key)
    if cached is not None:
        return cached

    overview = await AnalyticsService.get_full_dashboard_overview(db=db, time_filter=time_filter)
    _set_cached_data(cache_key, overview)
    return overview


@router.get(
    "/kpis",
    response_model=KpiSummaryMetrics,
    summary="Get Analytics KPI Summary Metrics",
    description="Returns high-level platform statistics (Total Analyses, Food Commodities, Packaging Materials, Recommendations).",
)
async def get_kpis(
    time_filter: AnalyticsDateFilter = Query(
        default=AnalyticsDateFilter.ALL_TIME,
        description="Time-range filter",
    ),
    db: AsyncSession = Depends(get_db),
) -> KpiSummaryMetrics:
    return await AnalyticsService.get_kpi_summary(db=db, time_filter=time_filter)


# ==========================================
# 2. Individual Chart Datasets
# ==========================================

@router.get(
    "/most-analyzed-foods",
    response_model=MostAnalyzedFoodsResponse,
    summary="Get Top Analyzed Foods (Pareto Leaderboard)",
    description="Returns ranked list of most evaluated foods with cumulative Pareto share and shelf-life extension stats.",
)
async def get_most_analyzed_foods(
    time_filter: AnalyticsDateFilter = Query(
        default=AnalyticsDateFilter.ALL_TIME,
        description="Time-range filter",
    ),
    limit: int = Query(default=10, ge=1, le=50, description="Max number of food items to return"),
    db: AsyncSession = Depends(get_db),
) -> MostAnalyzedFoodsResponse:
    return await AnalyticsService.get_most_analyzed_foods(db=db, time_filter=time_filter, limit=limit)


@router.get(
    "/packaging-distribution",
    response_model=PackagingDistributionResponse,
    summary="Get Packaging Recommendation Distribution",
    description="Returns distribution breakdown across the 7 standardized polymer families with HHI concentration index.",
)
async def get_packaging_distribution(
    time_filter: AnalyticsDateFilter = Query(
        default=AnalyticsDateFilter.ALL_TIME,
        description="Time-range filter",
    ),
    db: AsyncSession = Depends(get_db),
) -> PackagingDistributionResponse:
    return await AnalyticsService.get_packaging_distribution(db=db, time_filter=time_filter)


@router.get(
    "/category-distribution",
    response_model=FoodCategoryDistributionResponse,
    summary="Get Food Taxonomy Category Distribution",
    description="Returns analysis volume and commodity counts across the 6 major food categories.",
)
async def get_category_distribution(
    time_filter: AnalyticsDateFilter = Query(
        default=AnalyticsDateFilter.ALL_TIME,
        description="Time-range filter",
    ),
    db: AsyncSession = Depends(get_db),
) -> FoodCategoryDistributionResponse:
    return await AnalyticsService.get_food_category_distribution(db=db, time_filter=time_filter)


@router.get(
    "/monthly-trends",
    response_model=MonthlyTrendResponse,
    summary="Get 12-Month Analysis Volume & Sustainability Trends",
    description="Returns monthly time series data with eco-friendly vs. conventional packaging adoption.",
)
async def get_monthly_trends(
    months: int = Query(default=12, ge=1, le=36, description="Number of historical months"),
    db: AsyncSession = Depends(get_db),
) -> MonthlyTrendResponse:
    return await AnalyticsService.get_monthly_trends(db=db, months=months)


# ==========================================
# 3. Data Export Endpoint
# ==========================================

@router.get(
    "/export",
    summary="Export Analytics Dataset (CSV or JSON)",
    description="Exports the current aggregated analytics data as a structured CSV file or JSON document.",
)
async def export_analytics(
    time_filter: AnalyticsDateFilter = Query(
        default=AnalyticsDateFilter.ALL_TIME,
        description="Time-range filter",
    ),
    format: ExportFormat = Query(
        default=ExportFormat.CSV,
        description="File format: 'csv' or 'json'",
    ),
    db: AsyncSession = Depends(get_db),
):
    overview = await AnalyticsService.get_full_dashboard_overview(db=db, time_filter=time_filter)
    export_content = AnalyticsService.generate_export_data(overview, format=format)

    timestamp_str = overview.generated_at.strftime("%Y%m%d_%H%M%S")
    if format == ExportFormat.CSV:
        filename = f"smartpack_analytics_{time_filter.value}_{timestamp_str}.csv"
        return PlainTextResponse(
            content=export_content,
            media_type="text/csv",
            headers={"Content-Disposition": f'attachment; filename="{filename}"'},
        )
    else:
        filename = f"smartpack_analytics_{time_filter.value}_{timestamp_str}.json"
        return Response(
            content=export_content,
            media_type="application/json",
            headers={"Content-Disposition": f'attachment; filename="{filename}"'},
        )
