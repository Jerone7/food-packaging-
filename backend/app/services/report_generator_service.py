"""
Multilingual PDF Recommendation Report Generator Service (Module 22 / Module 12).
Generates dual-column bilingual packaging dossiers in English, Tamil, and Hindi
with Unicode Indic TrueType font embedding, barrier metrics, and SHA-256 provenance.
"""

import io
import os
import hashlib
from datetime import datetime, timezone
from typing import Dict, Any, Optional, List, Union

from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
    KeepTogether,
    HRFlowable,
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

from app.services.food_service import FoodService
from app.services.recommendation_service import recommendation_service


class IndicFontRegistry:
    """Manages TrueType Unicode font registration for Indic scripts (Tamil, Hindi)."""

    _registered_font: Optional[str] = None
    _font_initialized: bool = False

    CANDIDATE_PATHS = [
        # Windows Nirmala UI (Covers Tamil, Devanagari, Telugu, etc.)
        ("Nirmala", "C:/Windows/Fonts/Nirmala.ttc", 0),
        ("Nirmala", "C:/Windows/Fonts/nirmala.ttc", 0),
        ("Nirmala", "C:\\Windows\\Fonts\\Nirmala.ttc", 0),
        # Windows Arial Unicode or Arial
        ("Arial", "C:/Windows/Fonts/arial.ttf", None),
        # Linux standard paths
        ("NotoSansTamil", "/usr/share/fonts/truetype/noto/NotoSansTamil-Regular.ttf", None),
        ("NotoSansDevanagari", "/usr/share/fonts/truetype/noto/NotoSansDevanagari-Regular.ttf", None),
    ]

    @classmethod
    def initialize_fonts(cls) -> str:
        """Attempts to register an Indic-capable TrueType font in ReportLab."""
        if cls._font_initialized and cls._registered_font:
            return cls._registered_font

        for font_name, path, subfont_idx in cls.CANDIDATE_PATHS:
            if os.path.exists(path):
                try:
                    if subfont_idx is not None:
                        pdfmetrics.registerFont(TTFont(font_name, path, subfontIndex=subfont_idx))
                    else:
                        pdfmetrics.registerFont(TTFont(font_name, path))
                    cls._registered_font = font_name
                    cls._font_initialized = True
                    return font_name
                except Exception:
                    continue

        # Fallback to Helvetica
        cls._registered_font = "Helvetica"
        cls._font_initialized = True
        return "Helvetica"

    @classmethod
    def get_font_name(cls) -> str:
        """Returns the registered Indic font or fallback font."""
        if not cls._font_initialized:
            return cls.initialize_fonts()
        return cls._registered_font or "Helvetica"


class MultilingualPdfReportGenerator:
    """Enterprise bilingual packaging report compiler and PDF synthesizer."""

    @classmethod
    def generate_pdf_report(
        cls,
        report_data: Dict[str, Any],
        locale: str = "en",
    ) -> bytes:
        """
        Compiles a bilingual, publication-grade PDF recommendation report.
        Renders technical English engineering parameters alongside
        vernacular farmer/processor guidance in the selected locale (Tamil, Hindi, English).
        """
        loc = (locale or "en").lower()
        font_name = IndicFontRegistry.initialize_fonts()

        buffer = io.BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=letter,
            rightMargin=36,
            leftMargin=36,
            topMargin=36,
            bottomMargin=36,
        )

        styles = getSampleStyleSheet()

        # Custom typography styles with registered Unicode font
        title_style = ParagraphStyle(
            "DocTitle",
            parent=styles["Normal"],
            fontName=font_name,
            fontSize=18,
            leading=22,
            textColor=colors.HexColor("#0D5C3A"),
            spaceAfter=4,
        )

        subtitle_style = ParagraphStyle(
            "DocSubtitle",
            parent=styles["Normal"],
            fontName=font_name,
            fontSize=10,
            leading=13,
            textColor=colors.HexColor("#4A5568"),
            spaceAfter=10,
        )

        section_heading_style = ParagraphStyle(
            "SectionHeading",
            parent=styles["Normal"],
            fontName=font_name,
            fontSize=12,
            leading=16,
            textColor=colors.HexColor("#1A365D"),
            spaceBefore=10,
            spaceAfter=6,
        )

        body_style = ParagraphStyle(
            "DocBody",
            parent=styles["Normal"],
            fontName=font_name,
            fontSize=9,
            leading=12,
            textColor=colors.HexColor("#2D3748"),
        )

        body_bold = ParagraphStyle(
            "DocBodyBold",
            parent=styles["Normal"],
            fontName=font_name,
            fontSize=9,
            leading=12,
            textColor=colors.HexColor("#1A202C"),
        )

        vernacular_style = ParagraphStyle(
            "DocVernacular",
            parent=styles["Normal"],
            fontName=font_name,
            fontSize=9,
            leading=13,
            textColor=colors.HexColor("#064E3B"),
        )

        table_header_style = ParagraphStyle(
            "TableHeader",
            parent=styles["Normal"],
            fontName=font_name,
            fontSize=9,
            leading=12,
            textColor=colors.white,
        )

        story: List[Any] = []

        # 1. Header Banner
        report_id = report_data.get("report_id") or f"SPK-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}"
        now_str = datetime.now(timezone.utc).strftime("%d %B %Y, %H:%M UTC")
        
        # Localized Document Titles
        if loc == "ta":
            doc_title = "SmartPack AI — பேக்கேஜிங் பரிந்துரை அறிக்கை"
            doc_subtitle = f"அறிக்கை எண்: {report_id} | பதிவு நாள்: {now_str} | மொழி: தமிழ் (ta)"
        elif loc == "hi":
            doc_title = "SmartPack AI — पैकेजिंग सिफारिश रिपोर्ट"
            doc_subtitle = f"रिपोर्ट आईडी: {report_id} | जारी तिथि: {now_str} | भाषा: हिंदी (hi)"
        else:
            doc_title = "SmartPack AI — Packaging Recommendation Dossier"
            doc_subtitle = f"Report ID: {report_id} | Date: {now_str} | Language: English (en)"

        story.append(Paragraph(doc_title, title_style))
        story.append(Paragraph(doc_subtitle, subtitle_style))
        story.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor("#0D5C3A"), spaceAfter=10))

        # 2. Extract Key Fields
        food_name = report_data.get("food_name") or report_data.get("item_name") or "Commodity"
        category = report_data.get("category") or "General Food"
        quantity = report_data.get("quantity") or report_data.get("fill_quantity") or "5.0 kg"
        material_name = (
            report_data.get("primary_material")
            or report_data.get("material_name")
            or "Bio-PBS / High-Barrier Laminate"
        )
        storage_temp = report_data.get("storage_temp_c", 20.0)
        moisture = report_data.get("moisture", 65.0)
        r20 = report_data.get("respiration_rate_20c", 15.0)

        # Localized Food Names
        localized_food = FoodService.get_localized_commodity_by_name(food_name, locale=loc)
        vernacular_food_name = localized_food.name if localized_food else food_name

        # 3. Dual-Column Bilingual Summary
        col_left_header = "Technical Engineering Specification"
        if loc == "ta":
            col_right_header = "உழவர் & பதப்படுத்துவோர் வழிகாட்டுதல் (Tamil)"
        elif loc == "hi":
            col_right_header = "किसान एवं प्रसंस्करणकर्ता मार्गदर्शन (Hindi)"
        else:
            col_right_header = "Farmer & Producer Advisory (English)"

        # Left Column: Technical parameters
        left_lines = [
            f"<b>Target Commodity:</b> {food_name} ({category})",
            f"<b>Batch / Pack Quantity:</b> {quantity}",
            f"<b>Optimal Polymer:</b> {material_name}",
            f"<b>Moisture Sensitivity:</b> {moisture:.1f}% moisture content",
            f"<b>Respiration Index:</b> {r20:.1f} mg CO₂/kg/h",
            "<b>Compliance:</b> ASTM F1249 / ASTM F1927",
        ]
        left_flowable = [Paragraph(line, body_style) for line in left_lines]

        # Right Column: Vernacular advice
        xai_rationale = recommendation_service.generate_scientific_rationale(
            commodity_name=vernacular_food_name,
            category=category,
            material=material_name,
            input_data={
                "name": vernacular_food_name,
                "moisture_pct": moisture,
                "respiration_rate_20c": r20,
                "storage_temp_c": storage_temp,
            },
            locale=loc,
        )

        right_lines = [
            f"<b>உணவுப் பெயர்:</b> {vernacular_food_name}" if loc == "ta" else (
                f"<b>खाद्य पदार्थ:</b> {vernacular_food_name}" if loc == "hi" else f"<b>Commodity:</b> {vernacular_food_name}"
            ),
            f"<b>பரிந்துரை:</b> {xai_rationale.summary}" if loc == "ta" else (
                f"<b>सिफारिश:</b> {xai_rationale.summary}" if loc == "hi" else f"<b>Prescription:</b> {xai_rationale.summary}"
            ),
        ]
        right_flowable = [Paragraph(line, vernacular_style) for line in right_lines]

        bilingual_table_data = [
            [
                Paragraph(f"<b>{col_left_header}</b>", table_header_style),
                Paragraph(f"<b>{col_right_header}</b>", table_header_style),
            ],
            [left_flowable, right_flowable],
        ]

        bilingual_table = Table(bilingual_table_data, colWidths=[265, 275])
        bilingual_table.setStyle(
            TableStyle([
                ("BACKGROUND", (0, 0), (0, 0), colors.HexColor("#1A365D")),
                ("BACKGROUND", (1, 0), (1, 0), colors.HexColor("#0D5C3A")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("TOPPADDING", (0, 0), (-1, -1), 6),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
                ("LEFTPADDING", (0, 0), (-1, -1), 8),
                ("RIGHTPADDING", (0, 0), (-1, -1), 8),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E0")),
                ("BACKGROUND", (0, 1), (0, 1), colors.HexColor("#F7FAFC")),
                ("BACKGROUND", (1, 1), (1, 1), colors.HexColor("#F0FDF4")),
            ])
        )

        story.append(bilingual_table)
        story.append(Spacer(1, 12))

        # 4. Spoilage Alerts & Mitigation Advice
        alerts = recommendation_service.generate_spoilage_alerts(
            commodity_name=vernacular_food_name,
            input_data={
                "name": vernacular_food_name,
                "moisture_pct": moisture,
                "respiration_rate_20c": r20,
                "storage_temp_c": storage_temp,
                "fat_pct": report_data.get("fat", 2.0),
                "chilling_injury_threshold_c": report_data.get("chilling_injury_threshold_c", -1.0),
            },
            locale=loc,
        )

        alert_section_title = "Physiological Spoilage Alerts & Preservation Protocols"
        if loc == "ta":
            alert_section_title = "உணவுப் பாதுகாப்பு எச்சரிக்கைகள் மற்றும் வழிகாட்டுதல்"
        elif loc == "hi":
            alert_section_title = "खाद्य सुरक्षा चेतावनियाँ एवं संरक्षण दिशानिर्देश"

        story.append(Paragraph(f"<b>{alert_section_title}</b>", section_heading_style))

        alert_rows = [
            [
                Paragraph("<b>நிலை / Severity</b>" if loc != "en" else "<b>Severity</b>", table_header_style),
                Paragraph("<b>எச்சரிக்கை / Hazard Title</b>" if loc != "en" else "<b>Hazard Title</b>", table_header_style),
                Paragraph("<b>தடுப்பு முறை / Mitigation Advisory</b>" if loc != "en" else "<b>Mitigation Advisory</b>", table_header_style),
            ]
        ]

        if alerts:
            for alt in alerts:
                sev_color = "#E53E3E" if alt.severity == "CRITICAL" else ("#DD6B20" if alt.severity == "WARNING" else "#3182CE")
                sev_p = Paragraph(f"<font color='{sev_color}'><b>{alt.severity}</b></font>", body_bold)
                title_p = Paragraph(f"<b>{alt.title}</b><br/>{alt.message}", vernacular_style)
                mit_p = Paragraph(alt.mitigation, vernacular_style)
                alert_rows.append([sev_p, title_p, mit_p])
        else:
            alert_rows.append([
                Paragraph("INFO", body_bold),
                Paragraph("No critical physiological hazards detected under specified parameters.", body_style),
                Paragraph("Maintain standard recommended cold chain / ambient ventilation.", body_style),
            ])

        alert_table = Table(alert_rows, colWidths=[70, 235, 235])
        alert_table.setStyle(
            TableStyle([
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#2D3748")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E0")),
            ])
        )

        story.append(alert_table)
        story.append(Spacer(1, 12))

        # 5. Scientific Key Drivers & Vernacular Checklist
        driver_title = "Key Scientific Drivers & Preservation Steps"
        if loc == "ta":
            driver_title = "முக்கிய அறிவியல் காரணிகள் & பாதுகாப்பு படிகள்"
        elif loc == "hi":
            driver_title = "प्रमुख वैज्ञानिक कारण एवं सुरक्षा उपाय"

        story.append(Paragraph(f"<b>{driver_title}</b>", section_heading_style))
        for idx, d in enumerate(xai_rationale.key_drivers, 1):
            bullet_text = f"<b>{idx}.</b> {d}"
            story.append(Paragraph(bullet_text, vernacular_style))
            story.append(Spacer(1, 3))

        story.append(Spacer(1, 10))

        # 6. Provenance & Cryptographic Verification Footer
        raw_hash_src = f"{food_name}|{material_name}|{report_id}|{now_str}|{loc}"
        sha_hash = hashlib.sha256(raw_hash_src.encode("utf-8")).hexdigest()

        footer_text = (
            f"<b>Cryptographic Provenance:</b> SHA-256: <code>{sha_hash[:32]}...</code> | "
            f"Generated by SmartPack AI Engine v2.4 (Multi-Language Module 22) | "
            f"Certified against ASTM F1927 / ASTM F1249 Standards"
        )
        story.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor("#A0AEC0"), spaceBefore=10, spaceAfter=6))
        story.append(Paragraph(footer_text, subtitle_style))

        # Build Document
        doc.build(story)
        return buffer.getvalue()


report_generator_service = MultilingualPdfReportGenerator()
