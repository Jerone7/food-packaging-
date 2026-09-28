"""
Unit and Integration Tests for I18N Middleware & Accept-Language Resolution (Task 2.1).
Verifies RFC 7231 Accept-Language header parsing, quality value sorting,
query parameter precedence, fallback to default locale, and Content-Language header emission.
"""

import unittest
from unittest.mock import MagicMock
from fastapi.testclient import TestClient

from app.main import app
from app.core.i18n import (
    SUPPORTED_LOCALES,
    DEFAULT_LOCALE,
    parse_accept_language,
    resolve_locale,
    get_requested_locale,
)


class TestI18nHeaderParsing(unittest.TestCase):
    """Unit tests for Accept-Language header parsing and quality factor sorting."""

    def test_empty_or_none_header(self):
        self.assertEqual(parse_accept_language(None), [])
        self.assertEqual(parse_accept_language(""), [])
        self.assertEqual(parse_accept_language("   "), [])

    def test_single_language(self):
        result = parse_accept_language("ta")
        self.assertEqual(result, [("ta", 1.0)])

    def test_language_with_region(self):
        result = parse_accept_language("ta-IN")
        self.assertEqual(result, [("ta", 1.0)])
        result_hi = parse_accept_language("hi_IN")
        self.assertEqual(result_hi, [("hi", 1.0)])

    def test_q_factor_sorting(self):
        header = "en;q=0.4, ta-IN;q=0.9, hi;q=0.8"
        result = parse_accept_language(header)
        expected = [("ta", 0.9), ("hi", 0.8), ("en", 0.4)]
        self.assertEqual(result, expected)

    def test_default_q_is_one(self):
        header = "ta, hi;q=0.8, en;q=0.5"
        result = parse_accept_language(header)
        self.assertEqual(result[0], ("ta", 1.0))
        self.assertEqual(result[1], ("hi", 0.8))
        self.assertEqual(result[2], ("en", 0.5))

    def test_malformed_q_value_handled_gracefully(self):
        header = "ta;q=invalid, en;q=0.5"
        result = parse_accept_language(header)
        # Invalid q defaults to 0.0, so 'en' (0.5) sorts higher than 'ta' (0.0)
        self.assertEqual(result[0], ("en", 0.5))
        self.assertEqual(result[1], ("ta", 0.0))


class TestLocaleResolution(unittest.TestCase):
    """Unit tests for locale selection and fallback rules."""

    def test_default_fallback_when_no_input(self):
        self.assertEqual(resolve_locale(), DEFAULT_LOCALE)
        self.assertEqual(resolve_locale(None, None), "en")

    def test_unsupported_language_falls_back_to_default(self):
        self.assertEqual(resolve_locale(accept_language="fr,de;q=0.8,es;q=0.5"), "en")

    def test_accept_language_tamil_resolved(self):
        self.assertEqual(resolve_locale(accept_language="ta-IN,ta;q=0.9"), "ta")

    def test_accept_language_hindi_resolved(self):
        self.assertEqual(resolve_locale(accept_language="hi-IN,hi;q=0.9"), "hi")

    def test_accept_language_highest_q_selected(self):
        # Even though en is listed first, ta has higher q
        header = "en;q=0.3, ta;q=0.9, hi;q=0.6"
        self.assertEqual(resolve_locale(accept_language=header), "ta")

    def test_query_param_takes_precedence_over_header(self):
        # Header asks for Tamil, but query param asks for Hindi
        resolved = resolve_locale(lang_param="hi", accept_language="ta-IN,ta;q=0.9")
        self.assertEqual(resolved, "hi")

    def test_query_param_case_insensitive(self):
        self.assertEqual(resolve_locale(lang_param="TA"), "ta")
        self.assertEqual(resolve_locale(lang_param="HI"), "hi")
        self.assertEqual(resolve_locale(lang_param="EN"), "en")

    def test_unsupported_query_param_falls_back_to_header(self):
        # Invalid query param falls back to valid header
        resolved = resolve_locale(lang_param="fr", accept_language="ta-IN,ta;q=0.9")
        self.assertEqual(resolved, "ta")

    def test_unsupported_query_param_and_header_falls_back_to_en(self):
        resolved = resolve_locale(lang_param="fr", accept_language="de;q=0.9")
        self.assertEqual(resolved, "en")


class TestFastApiDependency(unittest.TestCase):
    """Tests for get_requested_locale dependency function."""

    def test_dependency_with_mock_request(self):
        request = MagicMock()
        request.query_params = {"lang": "ta"}
        request.headers = {}
        request.state = MagicMock()

        locale = get_requested_locale(request=request)
        self.assertEqual(locale, "ta")
        self.assertEqual(request.state.locale, "ta")

    def test_dependency_with_direct_arguments(self):
        locale = get_requested_locale(accept_language="hi", lang=None)
        self.assertEqual(locale, "hi")


class TestI18nHttpIntegration(unittest.TestCase):
    """Integration tests with FastAPI TestClient verifying Content-Language and routing."""

    def setUp(self):
        self.client = TestClient(app, raise_server_exceptions=False)

    def test_default_root_emits_en_content_language(self):
        resp = self.client.get("/")
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-language"), "en")

    def test_accept_language_tamil_emits_ta_content_language(self):
        resp = self.client.get("/", headers={"Accept-Language": "ta-IN,ta;q=0.9,en;q=0.8"})
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-language"), "ta")

    def test_accept_language_hindi_emits_hi_content_language(self):
        resp = self.client.get("/", headers={"Accept-Language": "hi-IN,hi;q=0.9"})
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-language"), "hi")

    def test_query_param_overrides_header(self):
        resp = self.client.get("/?lang=ta", headers={"Accept-Language": "en-US,en;q=0.9"})
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-language"), "ta")

    def test_unsupported_language_header_emits_en(self):
        resp = self.client.get("/", headers={"Accept-Language": "fr-FR,fr;q=0.9,de;q=0.8"})
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(resp.headers.get("content-language"), "en")


if __name__ == "__main__":
    unittest.main()
