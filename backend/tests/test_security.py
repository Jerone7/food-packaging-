"""
Unit Tests for Security and Cryptographic Token Service (Module 14 - Task 1.1).
"""

import time
import unittest
from datetime import timedelta
from app.core.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    decode_access_token,
)

class TestSecurityService(unittest.TestCase):
    def test_password_hashing_and_verification(self):
        password = "SecurePassword123!"
        hashed = get_password_hash(password)
        
        # Format check
        self.assertTrue(hashed.startswith("pbkdf2_sha256$"))
        parts = hashed.split("$")
        self.assertEqual(len(parts), 4)
        self.assertEqual(parts[1], "100000")
        
        # Verification positive
        self.assertTrue(verify_password(password, hashed))
        
        # Verification negative
        self.assertFalse(verify_password("WrongPassword123!", hashed))
        self.assertFalse(verify_password("", hashed))
        self.assertFalse(verify_password(password, ""))
        self.assertFalse(verify_password(password, "malformed_hash_string"))

    def test_salt_randomness(self):
        password = "IdenticalPassword"
        hash1 = get_password_hash(password)
        hash2 = get_password_hash(password)
        
        # Distinct salts must generate distinct hashes
        self.assertNotEqual(hash1, hash2)
        self.assertTrue(verify_password(password, hash1))
        self.assertTrue(verify_password(password, hash2))

    def test_empty_password_raises_error(self):
        with self.assertRaises(ValueError):
            get_password_hash("")

    def test_jwt_token_issuance_and_decoding(self):
        user_id = 42
        token = create_access_token(
            subject=user_id,
            expires_delta=timedelta(hours=1),
            role="engineer",
            extra_claims={"org": "PackTech Labs", "email": "engineer@packtech.io"}
        )
        
        # Structure check
        self.assertIsInstance(token, str)
        parts = token.split(".")
        self.assertEqual(len(parts), 3)
        
        # Decoding
        payload = decode_access_token(token)
        self.assertIsNotNone(payload)
        self.assertEqual(payload.get("sub"), "42")
        self.assertEqual(payload.get("role"), "engineer")
        self.assertEqual(payload.get("org"), "PackTech Labs")
        self.assertEqual(payload.get("email"), "engineer@packtech.io")
        self.assertIn("exp", payload)
        self.assertIn("iat", payload)

    def test_jwt_tampered_signature_rejected(self):
        token = create_access_token(subject="user_100")
        parts = token.split(".")
        
        # Modify signature
        tampered_token = f"{parts[0]}.{parts[1]}.tampered_signature_bytes"
        self.assertIsNone(decode_access_token(tampered_token))
        
        # Modify payload
        tampered_token2 = f"{parts[0]}.eyJzdWIiOiAibWFsaWNpb3VzIn0.{parts[2]}"
        self.assertIsNone(decode_access_token(tampered_token2))

    def test_jwt_expired_token_rejected(self):
        # Create token that expired 10 seconds ago
        expired_token = create_access_token(
            subject="expired_user",
            expires_delta=timedelta(seconds=-10)
        )
        self.assertIsNone(decode_access_token(expired_token))

    def test_jwt_malformed_token_rejected(self):
        self.assertIsNone(decode_access_token(""))
        self.assertIsNone(decode_access_token("not.a.valid.jwt.token"))
        self.assertIsNone(decode_access_token("only_one_part"))
        self.assertIsNone(decode_access_token("header.payload"))

if __name__ == "__main__":
    unittest.main()
