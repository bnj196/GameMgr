from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from core.database import get_db
from models.models import Game, User
from schemas.schemas import APIResponse, GameResponse
from api.users import get_current_user
from typing import List

router = APIRouter(prefix="/library", tags=["Library"])

@router.get("", response_model=APIResponse[List[GameResponse]])
def get_my_library(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Trả về danh sách game đã add vào thư viện
    from api.catalog import game_to_schema
    items = [game_to_schema(g, True) for g in current_user.library]
    return APIResponse(data=items)

@router.post("/{game_id}", response_model=APIResponse)
def add_to_library(game_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    game = db.query(Game).filter(Game.id == game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail={"code": "GAME_001", "message": "Game không tồn tại."})
    
    if game not in current_user.library:
        current_user.library.append(game)
        db.commit()
        
    return APIResponse(message="Đã thêm vào thư viện")

@router.delete("/{game_id}", response_model=APIResponse)
def remove_from_library(game_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    game = db.query(Game).filter(Game.id == game_id).first()
    if game in current_user.library:
        current_user.library.remove(game)
        db.commit()
        
    return APIResponse(message="Đã xóa khỏi thư viện")