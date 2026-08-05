from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from core.database import engine, Base, SessionLocal
from models.models import Game, User
from api import auth, users, catalog, library
import json

# Tạo tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="GameHub API", version="1.0.0")

# CORS Middleware (Rất quan trọng để Flutter Web/Desktop hoặc Mobile gọi API local)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Trong production nên giới hạn domain cụ thể
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register Routers with /api prefix
app.include_router(auth.router, prefix="/api")
app.include_router(users.router, prefix="/api")
app.include_router(catalog.router, prefix="/api")
app.include_router(library.router, prefix="/api")

@app.on_event("startup")
def seed_database():
    """Tự động nạp dữ liệu mẫu khi khởi động server nếu DB đang trống"""
    db = SessionLocal()
    try:
        if db.query(Game).count() == 0:
            print("🌱 Seeding dummy games...")
            mock_games = [
                {"id": "game_1", "name": "Huyền Thoại Kiếm Khách", "slug": "huyen-thoai-kiem-khach", "desc": "Mô tả ngắn gọn hấp dẫn cho game demo 1.", "genres": ["RPG", "Hành động"], "platforms": ["android", "ios"], "price_type": "paid", "price": 120000, "size": 1300000000, "badge": "hot"},
                {"id": "game_2", "name": "Biệt Đội Không Gian", "slug": "biet-doi-khong-gian", "desc": "Mô tả ngắn gọn hấp dẫn cho game demo 2.", "genres": ["FPS", "Online"], "platforms": ["android", "ios"], "price_type": "free", "price": None, "size": 1800000000, "badge": "new"},
                {"id": "game_3", "name": "Vương Quốc Sụp Đổ", "slug": "vuong-quoc-sup-do", "desc": "Mô tả ngắn gọn hấp dẫn cho game demo 3.", "genres": ["RPG", "Thế giới mở"], "platforms": ["android", "ios"], "price_type": "paid", "price": 210000, "size": 2500000000, "badge": "sale"},
                {"id": "game_4", "name": "Đua Xe Thần Tốc", "slug": "dua-xe-than-toc", "desc": "Mô tả ngắn gọn hấp dẫn cho game demo 4.", "genres": ["Đua xe", "Casual"], "platforms": ["android", "ios"], "price_type": "free", "price": None, "size": 900000000, "badge": None},
                {"id": "game_5", "name": "Nông Trại Vui Vẻ", "slug": "nong-trai-vui-ve", "desc": "Mô tả ngắn gọn hấp dẫn cho game demo 5.", "genres": ["Mô phỏng", "Casual"], "platforms": ["android", "ios"], "price_type": "paid", "price": 50000, "size": 600000000, "badge": None},
                {"id": "game_6", "name": "Chiến Trường Huyền Thoại", "slug": "chien-truong-huyen-thoai", "desc": "Mô tả ngắn gọn hấp dẫn cho game demo 6.", "genres": ["FPS", "Chiến thuật"], "platforms": ["android", "ios"], "price_type": "free", "price": None, "size": 3200000000, "badge": None},
            ]
            
            for g in mock_games:
                db_game = Game(
                    id=g["id"], name=g["name"], slug=g["slug"], short_description=g["desc"],
                    genres=json.dumps(g["genres"]), platforms=json.dumps(g["platforms"]),
                    thumbnail=f"https://picsum.photos/seed/{g['id']}/600/800",
                    banner=f"https://picsum.photos/seed/{g['id']}_b/1200/500",
                    price_type=g["price_type"], price=g["price"], currency="VND",
                    size_bytes=g["size"], badge=g["badge"]
                )
                db.add(db_game)
            db.commit()
            print("✅ Seed data completed.")
    finally:
        db.close()

@app.get("/")
def root():
    return {"message": "Welcome to GameHub API. Visit /docs for Swagger UI."}