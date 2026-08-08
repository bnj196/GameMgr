import json
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import asc, desc, func
from sqlalchemy.orm import Session

from api.users import get_current_user
from core.database import get_db
from core.serializers import game_to_schema, games_to_schema, review_to_schema
from models.models import Game, Review, User
from schemas.schemas import (
    APIResponse,
    CatalogFacets,
    GameListResponse,
    GameResponse,
    RatingInfo,
    ReviewCreate,
    ReviewListResponse,
    ReviewResponse,
)

router = APIRouter(prefix="/games", tags=["Catalog"])

PRICE_TYPES = ["free", "paid", "subscription"]
SORTS = ["relevance", "newest", "name_asc", "price_asc", "price_desc", "rating_desc"]


@router.get("", response_model=APIResponse[GameListResponse])
def get_games(
    q: Optional[str] = Query(None, description="Từ khóa tìm kiếm theo tên"),
    genre: Optional[List[str]] = Query(None, description="Lọc theo thể loại, lặp lại để chọn nhiều"),
    platform: Optional[str] = Query(None, description="Lọc theo nền tảng"),
    priceType: Optional[str] = Query(None, description="free | paid | subscription"),
    minPrice: Optional[float] = Query(None, ge=0),
    maxPrice: Optional[float] = Query(None, ge=0),
    sort: str = Query("relevance", description=" | ".join(SORTS)),
    page: int = Query(1, ge=1, description="Trang, bắt đầu từ 1"),
    limit: int = Query(20, ge=1, le=100, description="Số game mỗi trang"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if priceType is not None and priceType not in PRICE_TYPES:
        raise HTTPException(
            status_code=400,
            detail={"code": "CATALOG_001", "message": "Loại giá không hợp lệ."},
        )
    if sort not in SORTS:
        raise HTTPException(
            status_code=400,
            detail={"code": "CATALOG_002", "message": "Kiểu sắp xếp không hợp lệ."},
        )

    query = db.query(Game)
    if q:
        query = query.filter(Game.name.ilike(f"%{q}%"))
    if priceType:
        query = query.filter(Game.price_type == priceType)
    if minPrice is not None:
        query = query.filter(func.coalesce(Game.price, 0) >= minPrice)
    if maxPrice is not None:
        query = query.filter(func.coalesce(Game.price, 0) <= maxPrice)
    if platform:
        query = query.filter(Game.platforms.ilike(f'%"{platform}"%'))
    for g in genre or []:
        query = query.filter(Game.genres.ilike(f'%"{g}"%'))

    if sort == "newest":
        query = query.order_by(desc(Game.released_at), asc(Game.id))
    elif sort == "name_asc":
        query = query.order_by(asc(Game.name))
    elif sort == "price_asc":
        query = query.order_by(asc(func.coalesce(Game.price, 0)), asc(Game.name))
    elif sort == "price_desc":
        query = query.order_by(desc(func.coalesce(Game.price, 0)), asc(Game.name))
    elif sort == "rating_desc":
        avg_rating = (
            db.query(Review.game_id.label("game_id"), func.avg(Review.rating).label("avg"))
            .group_by(Review.game_id)
            .subquery()
        )
        query = query.outerjoin(avg_rating, avg_rating.c.game_id == Game.id).order_by(
            desc(func.coalesce(avg_rating.c.avg, 0)), asc(Game.name)
        )
    else:
        query = query.order_by(asc(Game.id))

    total = query.count()
    games = query.offset((page - 1) * limit).limit(limit).all()

    return APIResponse(
        data=GameListResponse(
            items=games_to_schema(db, games, current_user),
            page=page,
            limit=limit,
            total=total,
        )
    )


@router.get("/facets", response_model=APIResponse[CatalogFacets])
def get_facets(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Danh sách thể loại/nền tảng có thật trong catalog để client dựng bộ lọc."""
    genres, platforms = set(), set()
    for row in db.query(Game.genres, Game.platforms).all():
        genres.update(json.loads(row[0] or "[]"))
        platforms.update(json.loads(row[1] or "[]"))

    return APIResponse(
        data=CatalogFacets(
            genres=sorted(genres),
            platforms=sorted(platforms),
            priceTypes=PRICE_TYPES,
            sorts=SORTS,
        )
    )


def _get_game_or_404(db: Session, game_id: str) -> Game:
    game = db.query(Game).filter(Game.id == game_id).first()
    if not game:
        raise HTTPException(
            status_code=404,
            detail={"code": "GAME_001", "message": "Game không tồn tại."},
        )
    return game


@router.get("/{game_id}", response_model=APIResponse[GameResponse])
def get_game_detail(
    game_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    game = _get_game_or_404(db, game_id)
    return APIResponse(data=game_to_schema(db, game, current_user))


@router.get("/{game_id}/download-url", response_model=APIResponse[dict])
def get_download_url(
    game_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    game = _get_game_or_404(db, game_id)
    if game not in current_user.library:
        raise HTTPException(
            status_code=403,
            detail={"code": "DL_001", "message": "Bạn cần sở hữu game này trước khi tải."},
        )
    # SRS-DL-01: Mock CDN URL. Thực tế sẽ ký S3 URL hoặc trả về CDN link
    return APIResponse(data={"url": f"https://cdn.gamehub.mock/packages/{game_id}.pkg"})


# --- Reviews ---

@router.get("/{game_id}/reviews", response_model=APIResponse[ReviewListResponse])
def list_reviews(
    game_id: str,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _get_game_or_404(db, game_id)
    query = db.query(Review).filter(Review.game_id == game_id)
    total = query.count()
    reviews = (
        query.order_by(desc(Review.created_at))
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )

    avg, count = (
        db.query(func.avg(Review.rating), func.count(Review.id))
        .filter(Review.game_id == game_id)
        .one()
    )

    return APIResponse(
        data=ReviewListResponse(
            items=[review_to_schema(r, current_user.id) for r in reviews],
            page=page,
            limit=limit,
            total=total,
            summary=RatingInfo(average=round(float(avg or 0), 1), count=count or 0),
        )
    )


@router.post("/{game_id}/reviews", response_model=APIResponse[ReviewResponse])
def upsert_review(
    game_id: str,
    payload: ReviewCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Tạo mới hoặc cập nhật đánh giá của người dùng hiện tại cho game."""
    game = _get_game_or_404(db, game_id)
    if game not in current_user.library:
        raise HTTPException(
            status_code=403,
            detail={
                "code": "REVIEW_001",
                "message": "Bạn cần có game trong thư viện trước khi đánh giá.",
            },
        )

    review = (
        db.query(Review)
        .filter(Review.game_id == game_id, Review.user_id == current_user.id)
        .first()
    )
    if review is None:
        review = Review(game_id=game_id, user_id=current_user.id)
        db.add(review)

    review.rating = payload.rating
    review.comment = payload.comment
    db.commit()
    db.refresh(review)

    return APIResponse(
        message="Đã lưu đánh giá",
        data=review_to_schema(review, current_user.id),
    )


@router.delete("/{game_id}/reviews/me", response_model=APIResponse)
def delete_my_review(
    game_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    review = (
        db.query(Review)
        .filter(Review.game_id == game_id, Review.user_id == current_user.id)
        .first()
    )
    if review is None:
        raise HTTPException(
            status_code=404,
            detail={"code": "REVIEW_002", "message": "Bạn chưa đánh giá game này."},
        )
    db.delete(review)
    db.commit()
    return APIResponse(message="Đã xóa đánh giá")
