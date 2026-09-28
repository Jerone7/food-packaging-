from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    PROJECT_NAME: str = "AI Packaging Recommender"
    API_V1_STR: str = "/api/v1"
    
    # PostgreSQL Database URL
    # Format: postgresql+asyncpg://user:password@host:port/dbname
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgrespassword@localhost:5432/packaging_db"
    
    # Security & JWT Configuration
    SECRET_KEY: str = "smartpack-ai-secret-key-quantum-2026-super-secure-key-jwt-auth"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    # CORS Origins (allow Flutter web, mobile, local dev)
    CORS_ORIGINS: List[str] = ["*"]
    
    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
