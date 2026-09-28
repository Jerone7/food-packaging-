import re
from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field, field_validator

EMAIL_REGEX = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")

# --- User Preferences & Activity Statistics ---

class UserPreferences(BaseModel):
    default_eco_priority: bool = Field(default=True, description="Default sustainability priority bias")
    default_currency: str = Field(default="INR", description="Default commercial currency (INR, USD, EUR, GBP)")
    default_batch_size: int = Field(default=10000, ge=100, le=10000000, description="Default unit batch volume")
    export_organization_header: Optional[str] = Field(None, max_length=150, description="Custom organization header for PDF exports")


class UserStats(BaseModel):
    total_analyses_count: int = Field(default=0, ge=0, description="Total recommendation analyses generated")
    saved_presets_count: int = Field(default=0, ge=0, description="Total bookmarked analysis presets")
    eco_friendly_count: int = Field(default=0, ge=0, description="Total eco-optimized prescriptions")
    average_sustainability_score: float = Field(default=0.0, ge=0.0, le=100.0, description="Mean circularity score across runs")
    member_since: Optional[datetime] = Field(None, description="Account creation timestamp")


# --- User Identity Schemas ---

class UserBase(BaseModel):
    email: str = Field(..., description="Unique email address for user authentication")
    full_name: str = Field(..., min_length=2, max_length=100, description="User's full display name")
    organization: Optional[str] = Field(None, max_length=150, description="Company, academic institute, or laboratory")
    role: Optional[str] = Field("Packaging Engineer", max_length=100, description="Professional or academic role")

    @field_validator("email")
    @classmethod
    def validate_email_format(cls, v: str) -> str:
        clean_email = v.strip().lower()
        if not EMAIL_REGEX.match(clean_email):
            raise ValueError(f"Invalid email address format: '{v}'")
        return clean_email


class UserCreate(UserBase):
    password: str = Field(..., min_length=8, max_length=128, description="Plaintext password (minimum 8 characters)")
    default_eco_priority: bool = Field(default=True, description="Default sustainability priority")
    default_currency: str = Field(default="INR", description="Default commercial currency")


class UserLogin(BaseModel):
    email: str = Field(..., description="Registered user email address")
    password: str = Field(..., min_length=1, description="Account password")

    @field_validator("email")
    @classmethod
    def validate_email_format(cls, v: str) -> str:
        clean_email = v.strip().lower()
        if not EMAIL_REGEX.match(clean_email):
            raise ValueError(f"Invalid email address format: '{v}'")
        return clean_email


class UserUpdate(BaseModel):
    full_name: Optional[str] = Field(None, min_length=2, max_length=100)
    organization: Optional[str] = Field(None, max_length=150)
    role: Optional[str] = Field(None, max_length=100)
    default_eco_priority: Optional[bool] = None
    default_currency: Optional[str] = None
    default_batch_size: Optional[int] = Field(None, ge=100, le=10000000)
    export_organization_header: Optional[str] = Field(None, max_length=150)


class UserResponse(UserBase):
    id: int
    is_active: bool = True
    is_admin: bool = False
    created_at: datetime
    preferences: UserPreferences = Field(default_factory=UserPreferences)
    stats: Optional[UserStats] = None

    class Config:
        from_attributes = True


# --- Authentication & Token Schemas ---

class TokenResponse(BaseModel):
    access_token: str = Field(..., description="HS256 signed JSON Web Token")
    token_type: str = Field(default="bearer", description="Token authorization type")
    expires_in_seconds: int = Field(..., description="Token lifespan in seconds")
    user: UserResponse = Field(..., description="Authenticated user profile")


class TokenPayload(BaseModel):
    sub: str = Field(..., description="Subject identifier (User ID)")
    exp: int = Field(..., description="Expiration timestamp (epoch seconds)")
    iat: Optional[int] = Field(None, description="Issued at timestamp (epoch seconds)")
    role: str = Field(default="user", description="Authorization role")


# --- Saved Analysis Preset Schemas ---

class SavedAnalysisCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=150, description="User-assigned preset label")
    notes: Optional[str] = Field(None, max_length=1000, description="Engineering or operational annotations")
    commodity_name: str = Field(..., min_length=1, description="Food commodity name")
    recommended_material: Optional[str] = Field(None, description="Primary prescribed material")
    estimated_cost: Optional[float] = Field(None, ge=0.0, description="Unit cost in default currency")
    sustainability_score: Optional[float] = Field(None, ge=0.0, le=100.0, description="Sustainability circularity score")
    input_payload: Dict[str, Any] = Field(default_factory=dict, description="Complete input parameter dictionary")
    recommendation_result: Dict[str, Any] = Field(default_factory=dict, description="Complete recommendation result dictionary")


class SavedAnalysisResponse(BaseModel):
    id: int
    user_id: int
    title: str
    notes: Optional[str] = None
    commodity_name: str
    recommended_material: str
    estimated_cost: float
    sustainability_score: float
    input_payload: Dict[str, Any]
    recommendation_result: Dict[str, Any]
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
