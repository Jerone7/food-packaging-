"""
Security and Validation Data Contracts & Schemas (Module 19: Security & Validation).
Provides strictly typed Pydantic models for security diagnostics, standardized error envelopes,
password modification, security audit logs, and database backup metadata.
"""

from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, Field


def _current_utc_time() -> datetime:
    return datetime.now(timezone.utc)


class ApiErrorDetail(BaseModel):
    """Structured detail component of an API error."""
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    code: str = Field(..., description="Standardized error code token", min_length=2, max_length=64)
    message: str = Field(..., description="Human-readable safe error message", min_length=1)
    status_code: int = Field(..., description="HTTP status code", ge=100, le=599)
    timestamp: datetime = Field(default_factory=_current_utc_time, description="UTC timestamp of the error")
    request_id: Optional[str] = Field(None, description="Unique correlation ID for tracing", max_length=128)
    details: Optional[List[Dict[str, Any]]] = Field(None, description="Field-specific validation error descriptors")


class ApiErrorEnvelope(BaseModel):
    """Standardized top-level API error envelope wrapping error details."""
    model_config = ConfigDict(extra="forbid")

    error: ApiErrorDetail


class SecurityHealthResponse(BaseModel):
    """System security health posture and cryptographic parameters."""
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    status: str = Field(default="SECURE", description="Overall security system health status")
    jwt_algorithm: str = Field(default="HS256", description="Active JWT signing algorithm")
    password_hashing: str = Field(default="PBKDF2-HMAC-SHA256", description="Active password hashing algorithm")
    pbkdf2_iterations: int = Field(default=100000, description="Hash work factor iteration count", ge=10000)
    rate_limiting_active: bool = Field(default=True, description="Whether API rate limiting is enforced")
    cors_origins_configured: int = Field(default=1, description="Number of authorized CORS origins", ge=1)
    timestamp: datetime = Field(default_factory=_current_utc_time, description="Timestamp of the health check")


class PasswordChangeRequest(BaseModel):
    """Request payload for updating user password with complexity verification."""
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    current_password: str = Field(..., min_length=1, max_length=128, description="Current plaintext password")
    new_password: str = Field(
        ...,
        min_length=8,
        max_length=128,
        description="New strong password (min 8 chars, mixed case, numbers/special)",
    )


class SecurityAuditLogItem(BaseModel):
    """Security audit trail entry tracking administrative operations and auth anomalies."""
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    id: str = Field(..., description="Unique audit event identifier")
    timestamp: datetime = Field(default_factory=_current_utc_time, description="UTC event timestamp")
    action: str = Field(..., description="Action token (e.g. AUTH_LOGIN, ADMIN_FOOD_UPDATE, BACKUP_CREATE)")
    user_id: Optional[int] = Field(None, description="Relational user ID initiating the action", ge=1)
    ip_address: Optional[str] = Field(None, description="Client IP address", max_length=64)
    status: str = Field(default="SUCCESS", description="Event status: SUCCESS, FAILURE, WARNING")
    details: Optional[Dict[str, Any]] = Field(None, description="Supplementary contextual metadata")


class BackupMetadata(BaseModel):
    """Metadata manifest describing a database snapshot archive."""
    model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)

    backup_id: str = Field(..., description="Unique backup identifier / filename slug")
    timestamp: datetime = Field(default_factory=_current_utc_time, description="Backup creation timestamp")
    version: str = Field(default="1.0.0", description="Schema format version")
    total_foods: int = Field(..., description="Count of food records backed up", ge=0)
    total_materials: int = Field(..., description="Count of packaging material records", ge=0)
    total_users: int = Field(..., description="Count of user accounts backed up", ge=0)
    total_recommendations: int = Field(..., description="Count of past recommendation records", ge=0)
    file_size_bytes: int = Field(..., description="Archive file size in bytes", ge=0)
    checksum_sha256: str = Field(..., description="SHA-256 cryptographic checksum of snapshot content", min_length=64, max_length=64)


class BackupListResponse(BaseModel):
    """List response containing existing backup snapshot manifests."""
    model_config = ConfigDict(extra="forbid")

    total_backups: int = Field(..., description="Total count of available backup archives", ge=0)
    backups: List[BackupMetadata] = Field(default_factory=list, description="List of snapshot manifests")
