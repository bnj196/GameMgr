from pydantic import BaseModel, Field
from typing import List, Optional, Generic, TypeVar
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
    bio: Optional[str] = None

class UserUpdate(BaseModel):
    displayName: Optional[str] = Field(default=None, min_length=1, max_length=50)
    avatarUrl: Optional[str] = None
    bio: Optional[str] = Field(default=None, max_length=280)

class PasswordChange(BaseModel):
    currentPassword: str
    newPassword: str = Field(min_length=6, max_length=72)

# --- Game Schemas ---
class PricingInfo(BaseModel):
    type: str
    price: Optional[float] = None
    currency: Optional[str] = None

class OwnershipInfo(BaseModel):
    owned: bool = False
    wishlisted: bool = False

class RatingInfo(BaseModel):
    average: float = 0
    count: int = 0

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
    rating: RatingInfo = RatingInfo()
    badge: Optional[str] = None

    class Config:
        from_attributes = True

class GameListResponse(BaseModel):
    items: List[GameResponse]
    page: int
    limit: int
    total: int

class CatalogFacets(BaseModel):
    """Giá trị hợp lệ để client dựng UI bộ lọc mà không hardcode."""
    genres: List[str]
    platforms: List[str]
    priceTypes: List[str]
    sorts: List[str]

# --- Review Schemas ---
class ReviewCreate(BaseModel):
    rating: int = Field(ge=1, le=5)
    comment: Optional[str] = Field(default=None, max_length=1000)

class ReviewResponse(BaseModel):
    id: int
    gameId: str
    userId: int
    userDisplayName: str
    rating: int
    comment: Optional[str] = None
    createdAt: datetime
    mine: bool = False

class ReviewListResponse(BaseModel):
    items: List[ReviewResponse]
    page: int
    limit: int
    total: int
    summary: RatingInfo

# --- Order Schemas ---
class OrderCreate(BaseModel):
    gameId: str
    paymentMethod: str = "momo"

class OrderResponse(BaseModel):
    id: str
    gameId: str
    gameName: str
    gameThumbnail: Optional[str] = None
    amount: float
    currency: str
    paymentMethod: str
    status: str
    createdAt: datetime

class OrderListResponse(BaseModel):
    items: List[OrderResponse]
    page: int
    limit: int
    total: int

# --- Notification Schemas ---
class NotificationResponse(BaseModel):
    id: int
    type: str
    title: str
    body: str
    deepLink: Optional[str] = None
    isRead: bool
    createdAt: datetime

class NotificationListResponse(BaseModel):
    items: List[NotificationResponse]
    page: int
    limit: int
    total: int
    unreadCount: int

class UnreadCountResponse(BaseModel):
    unreadCount: int