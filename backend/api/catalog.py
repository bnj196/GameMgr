from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from core.database import get_db
from models.models import Game, User
from schemas.schemas import APIResponse, GameResponse, PricingInfo, OwnershipInfo, MediaInfo
from api.users import get_current_user
import json

router = APIRouter(prefix="/games", tags=["Catalog"])

def game_to_schema(game: Game, owned: bool = False) -> GameResponse:
    return GameResponse(
        id=game.id,
        name=game.name,
        slug=game.slug,
        shortDescription=game.short_description,
        genres=json.loads(game.genres) if isinstance(game.genres, str) else game.genres,
        platforms=json.loads(game.platforms) if isinstance(game.platforms, str) else game.platforms,
        sizeInBytes=game.size_bytes,
        pricing=PricingInfo(type=game.price_type, price=game.price, currency=game.currency),
        ownership=OwnershipInfo(owned=owned),
        media=MediaInfo(thumbnail=game.thumbnail, banner=game.banner),
        badge=game.badge
    )

@router.get("", response_model=APIResponse[dict])
def get_games(
    q: str = Query(None, description="Search query"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = db.query(Game)
    if q:
        query = query.filter(Game.name.ilike(f"%{q}%"))
    
    games = query.all()
    owned_ids = {g.id for g in current_user.library}
    
    items = [game_to_schema(g, g.id in owned_ids) for g in games]
    return APIResponse(data={"items": items})

@router.get("/{game_id}", response_model=APIResponse[GameResponse])
def get_game_detail(
    game_id: str, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    game = db.query(Game).filter(Game.id == game_id).first()
    if not game:
        raise HTTPException(status_code=404, detail={"code": "GAME_001", "message": "Game không tồn tại."})
    
    owned = game in current_user.library
    return APIResponse(data=game_to_schema(game, owned))

@router.get("/{game_id}/download-url", response_model=APIResponse[dict])
def get_download_url(game_id: str, current_user: User = Depends(get_current_user)):
    # SRS-DL-01: Mock CDN URL. Thực tế sẽ ký S3 URL hoặc trả về CDN link
    return APIResponse(data={"url": f"https://cdn.gamehub.mock/packages/{game_id}.pkg"})