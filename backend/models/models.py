from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Table, UniqueConstraint
from sqlalchemy.orm import relationship
from datetime import datetime
from core.database import Base

# Bảng trung gian cho Many-to-Many (User - Game)
user_library = Table(
    'user_library', Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id'), primary_key=True),
    Column('game_id', String, ForeignKey('games.id'), primary_key=True),
    Column('added_at', DateTime, default=datetime.utcnow)
)

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    username = Column(String)
    hashed_password = Column(String)
    avatar_url = Column(String, nullable=True)
    bio = Column(String, nullable=True)
    library = relationship("Game", secondary=user_library, back_populates="owners")

class Game(Base):
    __tablename__ = "games"
    id = Column(String, primary_key=True, index=True)
    name = Column(String)
    slug = Column(String)
    short_description = Column(String)
    genres = Column(String) # Lưu dạng JSON string hoặc comma-separated
    platforms = Column(String)
    thumbnail = Column(String)
    banner = Column(String)
    price_type = Column(String) # free, paid, subscription
    price = Column(Float, nullable=True)
    currency = Column(String, default="VND")
    size_bytes = Column(Integer)
    badge = Column(String, nullable=True) # hot, new, sale
    released_at = Column(DateTime, default=datetime.utcnow)

    owners = relationship("User", secondary=user_library, back_populates="library")
    reviews = relationship("Review", back_populates="game", cascade="all, delete-orphan")


class WishlistItem(Base):
    """Game người dùng quan tâm nhưng chưa sở hữu."""
    __tablename__ = "wishlist_items"
    __table_args__ = (UniqueConstraint('user_id', 'game_id', name='uq_wishlist_user_game'),)

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    game_id = Column(String, ForeignKey('games.id'), index=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    game = relationship("Game")


class Order(Base):
    """Đơn mua một game. Thanh toán được giả lập, không tích hợp cổng thật."""
    __tablename__ = "orders"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    game_id = Column(String, ForeignKey('games.id'), index=True)
    amount = Column(Float, default=0)
    currency = Column(String, default="VND")
    payment_method = Column(String) # momo, vnpay, card
    status = Column(String, default="paid") # paid, refunded
    created_at = Column(DateTime, default=datetime.utcnow)

    game = relationship("Game")


class Review(Base):
    """Đánh giá của người dùng cho một game. Mỗi user chỉ đánh giá 1 lần / game."""
    __tablename__ = "reviews"
    __table_args__ = (UniqueConstraint('user_id', 'game_id', name='uq_review_user_game'),)

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    game_id = Column(String, ForeignKey('games.id'), index=True)
    rating = Column(Integer) # 1..5
    comment = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    game = relationship("Game", back_populates="reviews")
    user = relationship("User")


class Notification(Base):
    """Thông báo gửi tới người dùng (đơn hàng, game mới, khuyến mãi...)."""
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), index=True)
    type = Column(String, default="system") # system, order, promo, game
    title = Column(String)
    body = Column(String)
    deep_link = Column(String, nullable=True) # ví dụ: /game/game_1
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
