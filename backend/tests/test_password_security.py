"""
Unit Tests for Password Complexity, Hashing & Input Sanitizer (Module 19: Security & Validation).
Tests password complexity rules, PBKDF2-HMAC-SHA256 verification, XSS sanitization, and physical boundary validation.
"""

import unittest
from app.core.security import (
    validate_password_complexity,
    get_password_hash,
    verify_password,
)
from app.core.sanitizer import (
    sanitize_text,
    validate_physics_bounds,
    sanitize_payload_dict,
)


class TestPasswordSecurityAndSanitization(unittest.TestCase):
    """Test suite verifying cryptographic strength, password complexity, and input sanitization."""

    # --- 1. Password Complexity Tests ---

    def test_valid_strong_passwords(self):
        valid_passwords = [
            "SmartPack@2026",
            "Secure#Biochem99",
            "Polymer!Shield88",
            "PackagingMaster123",
            "E_coFriendly#2026",
        ]
        for pwd in valid_passwords:
            is_valid, msg = validate_password_complexity(pwd)
            self.assertTrue(is_valid, f"Expected '{pwd}' to be valid, got: {msg}")

    def test_password_length_rejection(self):
        # Too short (< 8 chars)
        is_valid, msg = validate_password_complexity("Ab1!")
        self.assertFalse(is_valid)
        self.assertIn("at least 8 characters", msg)

        # Empty
        is_valid, msg = validate_password_complexity("")
        self.assertFalse(is_valid)
        self.assertIn("cannot be empty", msg)

        # Too long (> 128 chars)
        long_pwd = "A1!" + ("a" * 130)
        is_valid, msg = validate_password_complexity(long_pwd)
        self.assertFalse(is_valid)
        self.assertIn("cannot exceed 128 characters", msg)

    def test_password_character_class_rejection(self):
        # Missing uppercase
        is_valid, msg = validate_password_complexity("alllowercase123!")
        self.assertFalse(is_valid)
        self.assertIn("uppercase", msg)

        # Missing lowercase
        is_valid, msg = validate_password_complexity("ALLUPPERCASE123!")
        self.assertFalse(is_valid)
        self.assertIn("lowercase", msg)

        # Missing digit or special char
        is_valid, msg = validate_password_complexity("OnlyLettersNoDigits")
        self.assertFalse(is_valid)
        self.assertIn("digit or special", msg)

    def test_prohibited_dictionary_passwords(self):
        prohibited = [
            "password",
            "Password123",
            "admin",
            "admin123",
            "12345678",
            "smartpack",
            "qwerty",
            "LetMeIn",
        ]
        for bad_pwd in prohibited:
            is_valid, msg = validate_password_complexity(bad_pwd)
            self.assertFalse(is_valid, f"Expected '{bad_pwd}' to be rejected as common password")
            self.assertIn("too common", msg)

    # --- 2. PBKDF2 Hashing & Verification Tests ---

    def test_password_hashing_and_verification(self):
        raw_password = "SecurePackaging#2026"
        hashed = get_password_hash(raw_password, iterations=100000)

        # Verify hash format: pbkdf2_sha256$<iterations>$<salt>$<hash>
        self.assertTrue(hashed.startswith("pbkdf2_sha256$100000$"))
        parts = hashed.split("$")
        self.assertEqual(len(parts), 4)
        self.assertEqual(len(parts[2]), 32)  # 16-byte hex salt = 32 hex chars

        # Verification with correct password
        self.assertTrue(verify_password(raw_password, hashed))

        # Rejection with incorrect password
        self.assertFalse(verify_password("WrongPassword123!", hashed))
        self.assertFalse(verify_password("", hashed))
        self.assertFalse(verify_password(raw_password, ""))

    # --- 3. Input Sanitization Tests ---

    def test_sanitize_xss_script_tags(self):
        malicious_inputs = [
            ("<script>alert('xss')</script>Mango", "Mango"),
            ("<SCRIPT SRC='http://evil.com/xss.js'></SCRIPT>Apples", "Apples"),
            ("<iframe src='javascript:alert(1)'></iframe>Fresh Berries", "Fresh Berries"),
            ("<b onmouseover=alert('XSS')>Strawberries</b>", "Strawberries"),
            ("<img src=x onerror=alert(1)>Tomato", "Tomato"),
            ("Guava<style>body{display:none;}</style>", "Guava"),
        ]
        for raw, expected in malicious_inputs:
            cleaned = sanitize_text(raw)
            self.assertEqual(cleaned, expected, f"Failed for raw input: {raw}")

    def test_sanitize_null_bytes_and_length(self):
        raw = "FoodName\0With\0NullBytes"
        cleaned = sanitize_text(raw)
        self.assertEqual(cleaned, "FoodNameWithNullBytes")

        # Length truncation
        long_str = "A" * 500
        truncated = sanitize_text(long_str, max_length=50)
        self.assertEqual(len(truncated), 50)

    # --- 4. Physics Boundary Validation Tests ---

    def test_validate_physics_bounds(self):
        # Valid parameters
        is_valid, msg = validate_physics_bounds(temp=4.0, rh=90.0, shelf_life=14, mass_kg=1.0)
        self.assertTrue(is_valid)

        # Invalid temperature (below -10°C or above 45°C)
        is_valid, msg = validate_physics_bounds(temp=-15.0, rh=90.0, shelf_life=14)
        self.assertFalse(is_valid)
        self.assertIn("temperature", msg)

        is_valid, msg = validate_physics_bounds(temp=50.0, rh=90.0, shelf_life=14)
        self.assertFalse(is_valid)
        self.assertIn("temperature", msg)

        # Invalid humidity (< 10% or > 100%)
        is_valid, msg = validate_physics_bounds(temp=4.0, rh=5.0, shelf_life=14)
        self.assertFalse(is_valid)
        self.assertIn("humidity", msg)

        is_valid, msg = validate_physics_bounds(temp=4.0, rh=105.0, shelf_life=14)
        self.assertFalse(is_valid)

        # Invalid shelf life (< 1 or > 365 days)
        is_valid, msg = validate_physics_bounds(temp=4.0, rh=90.0, shelf_life=0)
        self.assertFalse(is_valid)
        self.assertIn("shelf-life", msg)

        is_valid, msg = validate_physics_bounds(temp=4.0, rh=90.0, shelf_life=400)
        self.assertFalse(is_valid)

        # Invalid mass (< 0.01 or > 100 kg)
        is_valid, msg = validate_physics_bounds(temp=4.0, rh=90.0, shelf_life=14, mass_kg=0.001)
        self.assertFalse(is_valid)
        self.assertIn("mass", msg)

    # --- 5. Nested Payload Sanitization Tests ---

    def test_sanitize_payload_dict(self):
        dirty_payload = {
            "food_name": "Fresh <script>alert(1)</script>Tomatoes",
            "notes": "Stored in cold chain <iframe src=evil.com></iframe>.",
            "nested": {
                "tag": "<b onclick=alert(2)>Organic</b>",
                "values": ["<svg onload=alert(3)>Safe Item", 123, True],
            },
        }
        clean = sanitize_payload_dict(dirty_payload)
        self.assertEqual(clean["food_name"], "Fresh Tomatoes")
        self.assertEqual(clean["notes"], "Stored in cold chain .")
        self.assertEqual(clean["nested"]["tag"], "Organic")
        self.assertEqual(clean["nested"]["values"][0], "Safe Item")
        self.assertEqual(clean["nested"]["values"][1], 123)
        self.assertEqual(clean["nested"]["values"][2], True)


if __name__ == "__main__":
    unittest.main()
