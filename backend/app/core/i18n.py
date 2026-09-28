"""
I18N & Locale Negotiation Core Module (Module 22: Multi-Language Support).
Handles Accept-Language HTTP header parsing, query parameter overrides,
RFC 7231 quality-value (q-factor) sorting, and FastAPI request locale resolution.
"""

from typing import List, Optional, Tuple
from fastapi import Header, Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response

SUPPORTED_LOCALES: List[str] = ["en", "ta", "hi"]
DEFAULT_LOCALE: str = "en"

LOCALE_METADATA = {
    "en": {"name": "English", "native": "English", "script": "Latin", "direction": "ltr"},
    "ta": {"name": "Tamil", "native": "தமிழ்", "script": "Tamil", "direction": "ltr"},
    "hi": {"name": "Hindi", "native": "हिन्दी", "script": "Devanagari", "direction": "ltr"},
}


def parse_accept_language(header: Optional[str]) -> List[Tuple[str, float]]:
    """
    Parses an RFC 7231 Accept-Language header into a sorted list of (lang_code, q_value).
    Example: 'ta-IN,ta;q=0.9,hi;q=0.8,en-US;q=0.7,en;q=0.6'
    Returns: [('ta', 1.0), ('ta', 0.9), ('hi', 0.8), ('en', 0.7), ('en', 0.6)]
    """
    if not header or not isinstance(header, str) or not header.strip():
        return []

    entries: List[Tuple[str, float]] = []
    for raw_part in header.split(","):
        part = raw_part.strip()
        if not part:
            continue

        q_val = 1.0
        lang_tag = part

        if ";" in part:
            subparts = part.split(";", 1)
            lang_tag = subparts[0].strip()
            params = subparts[1].strip()
            for param in params.split(";"):
                param = param.strip()
                if param.lower().startswith("q="):
                    try:
                        q_val = float(param[2:].strip())
                    except ValueError:
                        q_val = 0.0

        # Extract primary language subtag (e.g., 'ta-IN' -> 'ta', 'en_US' -> 'en')
        clean_tag = lang_tag.replace("_", "-").split("-")[0].strip().lower()
        if clean_tag and clean_tag != "*":
            entries.append((clean_tag, q_val))

    # Sort stably by quality factor descending
    entries.sort(key=lambda item: item[1], reverse=True)
    return entries


def resolve_locale(
    lang_param: Optional[str] = None,
    accept_language: Optional[str] = None,
) -> str:
    """
    Determines the best matching supported locale.
    1. Explicit query parameter (?lang=ta) takes top priority.
    2. Accept-Language header entries inspected in priority order.
    3. Falls back to DEFAULT_LOCALE ('en').
    """
    # 1. Query parameter override
    if lang_param:
        cleaned_param = lang_param.strip().lower()
        if cleaned_param in SUPPORTED_LOCALES:
            return cleaned_param

    # 2. Accept-Language header
    if accept_language:
        parsed = parse_accept_language(accept_language)
        for code, q in parsed:
            if q > 0.0 and code in SUPPORTED_LOCALES:
                return code

    # 3. Default fallback
    return DEFAULT_LOCALE


def get_requested_locale(
    request: Optional[Request] = None,
    accept_language: Optional[str] = Header(None),
    lang: Optional[str] = None,
) -> str:
    """
    FastAPI dependency and standalone resolver for request locale.
    Inspects query params, headers, and request state.
    """
    # If already resolved by I18nMiddleware on request.state as a string, use it
    state_locale = getattr(request.state, "locale", None) if request and hasattr(request, "state") else None
    if isinstance(state_locale, str) and state_locale:
        return state_locale

    # Check query param directly or via Request
    target_lang = lang if isinstance(lang, str) else None
    if not target_lang and request and hasattr(request, "query_params"):
        target_lang = request.query_params.get("lang")

    # Check header directly or via Request
    target_header = accept_language if isinstance(accept_language, str) else None
    if not target_header and request and hasattr(request, "headers"):
        target_header = request.headers.get("accept-language")

    resolved = resolve_locale(lang_param=target_lang, accept_language=target_header)

    # Attach to request state if available
    if request and hasattr(request, "state"):
        try:
            request.state.locale = resolved
        except Exception:
            pass

    return resolved


class I18nMiddleware(BaseHTTPMiddleware):
    """
    ASGI Middleware that resolves the client's locale on each request,
    stores it in request.state.locale, and emits Content-Language response header.
    """
    async def dispatch(self, request: Request, call_next):
        lang_param = request.query_params.get("lang")
        accept_lang = request.headers.get("accept-language")
        resolved = resolve_locale(lang_param=lang_param, accept_language=accept_lang)

        request.state.locale = resolved
        response: Response = await call_next(request)

        if "content-language" not in response.headers:
            response.headers["Content-Language"] = resolved

        return response
