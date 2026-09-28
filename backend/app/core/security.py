"""
Security and Cryptographic Token Service (Module 14: User Account).
Provides PBKDF2-HMAC-SHA256 password hashing and JWT (HS256) token issuance/verification.
"""

import base64
import hashlib
import hmac
import json
import secrets
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional, Union
from app.core.config import settings

# --- Base64URL Encoding & Decoding Helpers ---

def _b64url_encode(data: bytes) -> str:
    """Encodes bytes to base64url string without trailing padding."""
    return base64.urlsafe_b64encode(data).decode('utf-8').rstrip('=')


def _b64url_decode(data: str) -> bytes:
    """Decodes base64url string to bytes, adding required padding."""
    padding = '=' * ((4 - len(data) % 4) % 4)
    return base64.urlsafe_b64decode((data + padding).encode('utf-8'))


PROHIBITED_PASSWORDS = {
    "password",
    "password123",
    "admin",
    "admin123",
    "12345678",
    "123456789",
    "smartpack",
    "qwerty",
    "letmein",
    "welcome123",
}


def validate_password_complexity(password: str) -> tuple[bool, str]:
    """
    Validates password complexity against OWASP guidelines.
    Returns (is_valid, error_message).
    """
    if not password:
        return False, "Password cannot be empty."
    
    if password.lower() in PROHIBITED_PASSWORDS:
        return False, "Password is too common and easily guessable. Please choose a stronger password."
    
    if len(password) < 8:
        return False, "Password must be at least 8 characters long."
    
    if len(password) > 128:
        return False, "Password cannot exceed 128 characters."
    
    has_upper = any(c.isupper() for c in password)
    has_lower = any(c.islower() for c in password)
    has_digit_or_special = any(c.isdigit() or not c.isalnum() for c in password)
    
    if not has_upper:
        return False, "Password must contain at least one uppercase letter."
    
    if not has_lower:
        return False, "Password must contain at least one lowercase letter."
    
    if not has_digit_or_special:
        return False, "Password must contain at least one digit or special character."
    
    return True, "Password meets complexity requirements."


# --- Password Hashing & Verification (PBKDF2-HMAC-SHA256) ---

def get_password_hash(password: str, iterations: int = 100000) -> str:
    """
    Generates a secure cryptographic password hash using PBKDF2 with SHA-256 and a random 16-byte salt.
    Format: pbkdf2_sha256$<iterations>$<salt_hex>$<hash_hex>
    """
    if not password:
        raise ValueError("Password cannot be empty")
    salt = secrets.token_hex(16)
    key = hashlib.pbkdf2_hmac(
        'sha256',
        password.encode('utf-8'),
        salt.encode('utf-8'),
        iterations
    )
    return f"pbkdf2_sha256${iterations}${salt}${key.hex()}"


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verifies a plaintext password against a stored PBKDF2 hash using constant-time comparison.
    """
    if not plain_password or not hashed_password:
        return False
    try:
        parts = hashed_password.split('$')
        if len(parts) != 4 or parts[0] != 'pbkdf2_sha256':
            return False
        iterations = int(parts[1])
        salt = parts[2]
        expected_hash = parts[3]
        
        computed_key = hashlib.pbkdf2_hmac(
            'sha256',
            plain_password.encode('utf-8'),
            salt.encode('utf-8'),
            iterations
        )
        return hmac.compare_digest(computed_key.hex(), expected_hash)
    except Exception:
        return False


# --- JSON Web Token (JWT HS256) Generation & Verification ---

def create_access_token(
    subject: Union[str, int],
    expires_delta: Optional[timedelta] = None,
    role: str = "user",
    extra_claims: Optional[Dict[str, Any]] = None,
) -> str:
    """
    Issues an HMAC-SHA256 (HS256) signed JSON Web Token (JWT).
    """
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    header = {"alg": "HS256", "typ": "JWT"}
    payload: Dict[str, Any] = {
        "sub": str(subject),
        "iat": int(now.timestamp()),
        "exp": int(expire.timestamp()),
        "role": role,
    }
    if extra_claims:
        payload.update(extra_claims)
    
    encoded_header = _b64url_encode(json.dumps(header, separators=(',', ':')).encode('utf-8'))
    encoded_payload = _b64url_encode(json.dumps(payload, separators=(',', ':')).encode('utf-8'))
    
    signing_input = f"{encoded_header}.{encoded_payload}".encode('utf-8')
    signature = hmac.new(settings.SECRET_KEY.encode('utf-8'), signing_input, hashlib.sha256).digest()
    encoded_signature = _b64url_encode(signature)
    
    return f"{encoded_header}.{encoded_payload}.{encoded_signature}"


def decode_access_token(token: str) -> Optional[Dict[str, Any]]:
    """
    Decodes and cryptographically validates an HS256 JWT.
    Returns the decoded payload dict if valid, or None if expired/tampered/malformed.
    """
    if not token or not isinstance(token, str):
        return None
    try:
        parts = token.strip().split('.')
        if len(parts) != 3:
            return None
        
        encoded_header, encoded_payload, encoded_signature = parts
        
        # Verify HMAC-SHA256 signature in constant time
        signing_input = f"{encoded_header}.{encoded_payload}".encode('utf-8')
        expected_signature = hmac.new(settings.SECRET_KEY.encode('utf-8'), signing_input, hashlib.sha256).digest()
        provided_signature = _b64url_decode(encoded_signature)
        
        if not hmac.compare_digest(expected_signature, provided_signature):
            return None
        
        # Decode and parse payload
        payload_bytes = _b64url_decode(encoded_payload)
        payload = json.loads(payload_bytes.decode('utf-8'))
        
        # Verify expiration
        exp = payload.get("exp")
        if exp is not None:
            now_ts = int(datetime.now(timezone.utc).timestamp())
            if now_ts > exp:
                return None  # Token expired
        
        return payload
    except Exception:
        return None
