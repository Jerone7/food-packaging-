"""
Unit Tests for Sliding-Window Rate Limiter (Module 19: Security & Validation).
Tests sliding window mechanics, tiered route rules, 429 response structure, and client isolation.
"""

import unittest
from unittest.mock import MagicMock
from app.core.rate_limiter import InMemoryRateLimiter


class TestRateLimiter(unittest.IsolatedAsyncioTestCase):
    """Test suite verifying rate limiting, sliding window expiration, and header emission."""

    def setUp(self):
        self.limiter = InMemoryRateLimiter(enabled=True)
        self.limiter.reset()

    def test_under_limit_requests_pass(self):
        # 5 requests with limit of 10 in 60s
        for i in range(5):
            is_limited, remaining, retry_after = self.limiter.is_rate_limited(
                key="192.168.1.10",
                category="/api/v1/auth/login",
                max_requests=10,
                window_seconds=60,
                current_time=1000.0 + i,
            )
            self.assertFalse(is_limited)
            self.assertEqual(remaining, 10 - (i + 1))
            self.assertEqual(retry_after, 0)

    def test_exceeding_limit_triggers_throttling(self):
        # Fire 10 requests to reach max capacity
        for i in range(10):
            self.limiter.is_rate_limited(
                key="192.168.1.10",
                category="/api/v1/auth/login",
                max_requests=10,
                window_seconds=60,
                current_time=1000.0 + i,
            )

        # 11th request must be throttled
        is_limited, remaining, retry_after = self.limiter.is_rate_limited(
            key="192.168.1.10",
            category="/api/v1/auth/login",
            max_requests=10,
            window_seconds=60,
            current_time=1010.0,
        )
        self.assertTrue(is_limited)
        self.assertEqual(remaining, 0)
        self.assertGreaterEqual(retry_after, 50)  # 1000 + 60 - 1010 = 50s

    def test_sliding_window_expiration(self):
        # 3 requests at t=1000
        for _ in range(3):
            self.limiter.is_rate_limited(
                key="client_a",
                category="test",
                max_requests=3,
                window_seconds=10,
                current_time=1000.0,
            )

        # Immediate 4th request at t=1001 is limited
        is_limited, _, retry_after = self.limiter.is_rate_limited(
            key="client_a",
            category="test",
            max_requests=3,
            window_seconds=10,
            current_time=1001.0,
        )
        self.assertTrue(is_limited)
        self.assertEqual(retry_after, 9)

        # Request at t=1011 (after 10s window) passes because old timestamps expired
        is_limited, remaining, retry_after = self.limiter.is_rate_limited(
            key="client_a",
            category="test",
            max_requests=3,
            window_seconds=10,
            current_time=1011.0,
        )
        self.assertFalse(is_limited)
        self.assertEqual(remaining, 2)
        self.assertEqual(retry_after, 0)

    def test_client_ip_isolation(self):
        # Exhaust limit for Client A
        for _ in range(5):
            self.limiter.is_rate_limited(
                key="10.0.0.1",
                category="test",
                max_requests=5,
                window_seconds=60,
                current_time=1000.0,
            )

        # Client A is limited
        is_limited_a, _, _ = self.limiter.is_rate_limited(
            key="10.0.0.1",
            category="test",
            max_requests=5,
            window_seconds=60,
            current_time=1001.0,
        )
        self.assertTrue(is_limited_a)

        # Client B is NOT limited
        is_limited_b, remaining_b, _ = self.limiter.is_rate_limited(
            key="10.0.0.2",
            category="test",
            max_requests=5,
            window_seconds=60,
            current_time=1001.0,
        )
        self.assertFalse(is_limited_b)
        self.assertEqual(remaining_b, 4)

    def test_route_rule_resolution(self):
        # Auth route
        cat, max_req, win = self.limiter._resolve_rule("/api/v1/auth/login")
        self.assertEqual(max_req, 10)
        self.assertEqual(win, 60)

        # Simulation route
        cat, max_req, win = self.limiter._resolve_rule("/api/v1/recommendations/generate")
        self.assertEqual(max_req, 60)
        self.assertEqual(win, 60)

        # Default route
        cat, max_req, win = self.limiter._resolve_rule("/api/v1/foods")
        self.assertEqual(max_req, 240)
        self.assertEqual(win, 60)

    async def test_check_rate_limit_emits_429_response(self):
        # Create mock request
        request = MagicMock()
        request.url.path = "/api/v1/auth/login"
        request.headers = {}
        request.client.host = "192.168.1.50"

        # Fire 10 allowed requests
        for _ in range(10):
            resp = await self.limiter.check_rate_limit(request)
            self.assertIsNone(resp)

        # 11th request triggers 429 response
        resp = await self.limiter.check_rate_limit(request)
        self.assertIsNotNone(resp)
        self.assertEqual(resp.status_code, 429)
        self.assertIn("Retry-After", resp.headers)
        self.assertEqual(resp.headers["X-RateLimit-Remaining"], "0")
        self.assertEqual(resp.headers["X-RateLimit-Limit"], "10")


if __name__ == "__main__":
    unittest.main()
