from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from api.users import get_current_user
from core.database import get_db
from core.serializers import games_to_schema
from models.models import Game, User, WishlistItem
from schemas.schemas import APIResponse, GameResponse

router = APIRouter(prefix="/wishlist", tags=["Wishlist"])


@router.get("", response_model=APIResponse[List[GameResponse]])
def get_wishlist(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    items = (
        db.query(WishlistItem)
        .filter(WishlistItem.user_id == current_user.id)
        .order_by(WishlistItem.created_at.desc())
        .all()
    )
    return APIResponse(data=games_to_schema(db, [i.game for i in items if i.game], current_user))


@router.post("/{game_id}", response_model=APIResponse)
def add_to_wishlist(game_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    game = db.query(Game).filter(Game.id == game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail={"code": "GAME_001", "message": "Game không tồn tại."})

    if game in current_user.library:
        raise HTTPException(
            status_code=409,
            detail={"code": "WISH_001", "message": "Game đã có trong thư viện của bạn."},
        )

    exists = (
        db.query(WishlistItem)
        .filter(WishlistItem.user_id == current_user.id, WishlistItem.game_id == game_id)
        .first()
    )
    if exists is None:
        db.add(WishlistItem(user_id=current_user.id, game_id=game_id))
        db.commit()

    return APIResponse(message="Đã thêm vào danh sách yêu thích")


@router.delete("/{game_id}", response_model=APIResponse)
def remove_from_wishlist(game_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db.query(WishlistItem).filter(
        WishlistItem.user_id == current_user.id, WishlistItem.game_id == game_id
    ).delete()
    db.commit()
    return APIResponse(message="Đã xóa khỏi danh sách yêu thích")
