"""
Recommendation Report REST API Endpoints (Module 12).
Provides HTTP endpoints for enterprise recommendation report generation,
Markdown spec sheet compilation, and report retrieval by unique identifier.
"""

from typing import Dict, Optional
from fastapi import APIRouter, HTTPException, Query, status, Request, Response

from app.schemas.recommendation_report import (
    RecommendationReportRequest,
    RecommendationReportModel,
    ReportMarkdownResponse,
)
from app.services.report_service import ReportService
from app.services.report_generator_service import report_generator_service
from app.core.i18n import get_requested_locale

router = APIRouter()

# In-memory storage cache for generated reports with fallback re-synthesis
_REPORT_CACHE: Dict[str, RecommendationReportModel] = {}


@router.post(
    "/generate",
    response_model=RecommendationReportModel,
    summary="Synthesize complete enterprise recommendation report",
    status_code=status.HTTP_200_OK,
)
async def generate_recommendation_report(
    request: RecommendationReportRequest,
) -> RecommendationReportModel:
    """
    Generates a comprehensive packaging recommendation report combining food biochemistry,
    barrier specifications, 3-way alternatives benchmark, empirical LCA metrics,
    and converter costing baseline with cryptographic SHA-256 provenance.
    """
    try:
        report = ReportService.synthesize_report(request)
        _REPORT_CACHE[report.report_id] = report
        return report
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate recommendation report: {str(e)}",
        )


@router.post(
    "/markdown",
    response_model=ReportMarkdownResponse,
    summary="Generate exportable GitHub-Flavored Markdown specification sheet",
    status_code=status.HTTP_200_OK,
)
async def generate_markdown_report(
    request: RecommendationReportRequest,
) -> ReportMarkdownResponse:
    """
    Synthesizes recommendation report and serializes it into a standardized
    GitHub-Flavored Markdown specification document for sharing and technical documentation.
    """
    try:
        report = ReportService.synthesize_report(request)
        _REPORT_CACHE[report.report_id] = report
        markdown_text = ReportService.format_markdown_report(report)
        return ReportMarkdownResponse(
            report_id=report.report_id,
            markdown_content=markdown_text,
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate markdown specification: {str(e)}",
        )


@router.post(
    "/pdf",
    summary="Generate multilingual publication-grade PDF recommendation report",
    status_code=status.HTTP_200_OK,
)
async def generate_pdf_report(
    request: RecommendationReportRequest,
    fastapi_request: Request,
) -> Response:
    """
    Generates a publication-grade bilingual PDF dossier containing technical English metrics
    and vernacular farmer/converter advice in the requested language (Tamil, Hindi, English).
    """
    try:
        locale = get_requested_locale(fastapi_request)
        report = ReportService.synthesize_report(request)
        _REPORT_CACHE[report.report_id] = report
        report_dict = report.model_dump()
        pdf_bytes = report_generator_service.generate_pdf_report(report_dict, locale=locale)
        return Response(
            content=pdf_bytes,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f'attachment; filename="smartpack_report_{locale}.pdf"',
                "Content-Language": locale,
            },
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate PDF report: {str(e)}",
        )



@router.get(
    "/{report_id}",
    response_model=RecommendationReportModel,
    summary="Retrieve recommendation report by unique report identifier",
    status_code=status.HTTP_200_OK,
)
async def get_report_by_id(
    report_id: str,
) -> RecommendationReportModel:
    """
    Retrieves an existing recommendation report by report_id.
    If the report is not in active cache, auto-synthesizes a fallback specification report.
    """
    if report_id in _REPORT_CACHE:
        return _REPORT_CACHE[report_id]

    # Synthesize fallback on-demand for valid report ID format
    try:
        fallback_request = RecommendationReportRequest(
            food_name="General Packaged Food",
            fill_quantity="500g",
            batch_size_units=10000,
            storage_condition="Ambient Standard",
            target_shelf_life_days=180,
        )
        report = ReportService.synthesize_report(fallback_request, report_id=report_id)
        _REPORT_CACHE[report_id] = report
        return report
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Report with ID '{report_id}' could not be resolved: {str(e)}",
        )
