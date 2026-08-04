from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Table
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
    
    owners = relationship("User", secondary=user_library, back_populates="library")