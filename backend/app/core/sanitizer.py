"""
Input Sanitization & Boundary Validation Utilities (Module 19: Security & Validation).
Protects against XSS, script injection, malformed string payloads, and physically invalid biochemical simulation values.
"""

import re
from typing import Any, Dict, List, Optional, Tuple, Union


# Regex pattern to match malicious HTML tags and script elements
_DANGEROUS_TAGS_PATTERN = re.compile(
    r"<\s*(?:script|iframe|style|link|svg|object|embed|applet|meta|form|input|button|body|html|head)[\s\S]*?>[\s\S]*?<\s*/\s*(?:script|iframe|style|link|svg|object|embed|applet|meta|form|input|button|body|html|head)\s*>|"
    r"<\s*(?:script|iframe|style|link|svg|object|embed|applet|meta|form|input|button|body|html|head)[\s\S]*?/?>|"
    r"javascript\s*:[^\"'>\s]*|"
    r"data\s*:\s*text/html[^\"'>\s]*|"
    r"on\w+\s*=\s*(?:\"[^\"]*\"|'[^']*'|[^\s>]+)",
    re.IGNORECASE,
)

# Regex to strip all remaining raw HTML tags
_HTML_TAG_PATTERN = re.compile(r"<[^>]+>")


def sanitize_text(input_str: Optional[str], max_length: int = 255) -> str:
    """
    Sanitizes user input string:
    1. Replaces null bytes.
    2. Strips dangerous HTML tags, event handlers, and script prefixes.
    3. Strips residual HTML tag brackets.
    4. Trims leading/trailing whitespace.
    5. Truncates to max_length.
    """
    if input_str is None:
        return ""
    
    if not isinstance(input_str, str):
        input_str = str(input_str)

    # 1. Strip null bytes
    cleaned = input_str.replace("\0", "").replace("\\0", "")

    # 2. Neutralize dangerous tags & event handlers
    cleaned = _DANGEROUS_TAGS_PATTERN.sub("", cleaned)

    # 3. Strip remaining generic HTML tags
    cleaned = _HTML_TAG_PATTERN.sub("", cleaned)

    # 4. Strip extra whitespace
    cleaned = cleaned.strip()

    # 5. Enforce length limit
    if len(cleaned) > max_length:
        cleaned = cleaned[:max_length]

    return cleaned


def validate_physics_bounds(
    temp: float,
    rh: float,
    shelf_life: int,
    mass_kg: Optional[float] = None,
) -> Tuple[bool, str]:
    """
    Validates physical parameters against biochemical boundaries.
    Returns (is_valid, error_message).
    """
    if temp < -10.0 or temp > 45.0:
        return False, f"Storage temperature ({temp}°C) must be between -10.0°C and 45.0°C."

    if rh < 10.0 or rh > 100.0:
        return False, f"Relative humidity ({rh}%) must be between 10.0% and 100.0%."

    if shelf_life < 1 or shelf_life > 365:
        return False, f"Target shelf-life ({shelf_life} days) must be between 1 and 365 days."

    if mass_kg is not None:
        if mass_kg < 0.01 or mass_kg > 100.0:
            return False, f"Package mass ({mass_kg} kg) must be between 0.01 kg and 100.0 kg."

    return True, "Physical parameters are within valid thermodynamic boundaries."


def sanitize_payload_dict(payload: Dict[str, Any], max_string_length: int = 1000) -> Dict[str, Any]:
    """
    Recursively traverses a dictionary payload and sanitizes all string fields.
    """
    sanitized: Dict[str, Any] = {}
    for key, value in payload.items():
        clean_key = sanitize_text(key, max_length=64)
        if isinstance(value, str):
            sanitized[clean_key] = sanitize_text(value, max_length=max_string_length)
        elif isinstance(value, dict):
            sanitized[clean_key] = sanitize_payload_dict(value, max_string_length=max_string_length)
        elif isinstance(value, list):
            sanitized[clean_key] = [
                sanitize_text(v, max_length=max_string_length) if isinstance(v, str)
                else sanitize_payload_dict(v, max_string_length=max_string_length) if isinstance(v, dict)
                else v
                for v in value
            ]
        else:
            sanitized[clean_key] = value
    return sanitized
