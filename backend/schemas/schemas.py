from pydantic import BaseModel, EmailStr
from typing import List, Optional, Any, Generic, TypeVar
from datetime import datetime

T = TypeVar('T')

# Standardized API Response (Khớp với SRS & Flutter DioExceptionMapper)
class APIResponse(BaseModel, Generic[T]):
    success: bool = True
    code: str = "SUCCESS"
    message: str = "OK"
    data: Optional[T] = None

# --- Auth Schemas ---
class UserCreate(BaseModel):
    email: str
    password: str
    username: str

class UserLogin(BaseModel):
    email: str
    password: str

class RefreshRequest(BaseModel):
    refreshToken: str

class Token(BaseModel):
    accessToken: str
    refreshToken: str

class UserResponse(BaseModel):
    id: int
    email: str
    displayName: str
    avatarUrl: Optional[str] = None

# --- Game Schemas ---
class PricingInfo(BaseModel):
    type: str
    price: Optional[float] = None
    currency: Optional[str] = None

class OwnershipInfo(BaseModel):
    owned: bool = False

class MediaInfo(BaseModel):
    thumbnail: Optional[str] = None
    banner: Optional[str] = None

class GameResponse(BaseModel):
    id: str
    name: str
    slug: str
    shortDescription: str
    genres: List[str]
    platforms: List[str]
    releaseDate: str = "2026-01-01"
    version: str = "1.0.0"
    sizeInBytes: int
    pricing: PricingInfo
    ownership: OwnershipInfo
    media: MediaInfo
    badge: Optional[str] = None

    class Config:
        from_attributes = True

class GameListResponse(BaseModel):
    items: List[GameResponse]
    page: int
    limit: int
    total: int