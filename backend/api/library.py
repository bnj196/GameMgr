from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from api.users import get_current_user
from core.database import get_db
from core.serializers import games_to_schema
from models.models import Game, User, WishlistItem
from schemas.schemas import APIResponse, GameResponse

router = APIRouter(prefix="/library", tags=["Library"])


@router.get("", response_model=APIResponse[List[GameResponse]])
def get_my_library(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return APIResponse(data=games_to_schema(db, list(current_user.library), current_user))


@router.post("/{game_id}", response_model=APIResponse)
def add_to_library(game_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Chỉ nhận game miễn phí; game trả phí phải đi qua /api/orders."""
    game = db.query(Game).filter(Game.id == game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail={"code": "GAME_001", "message": "Game không tồn tại."})

    if game.price_type != "free":
        raise HTTPException(
            status_code=402,
            detail={"code": "LIB_001", "message": "Game này cần được mua trước khi thêm vào thư viện."},
        )

    if game not in current_user.library:
        current_user.library.append(game)
        db.query(WishlistItem).filter(
            WishlistItem.user_id == current_user.id, WishlistItem.game_id == game_id
        ).delete()
        db.commit()

    return APIResponse(message="Đã thêm vào thư viện")


@router.delete("/{game_id}", response_model=APIResponse)
def remove_from_library(game_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    game = db.query(Game).filter(Game.id == game_id).first()
    if game in current_user.library:
        current_user.library.remove(game)
        db.commit()

    return APIResponse(message="Đã xóa khỏi thư viện")
