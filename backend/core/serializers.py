"""Chuyển ORM model sang schema trả về cho client, tránh N+1 query."""
import json
from typing import Iterable, List, Optional

from sqlalchemy import func
from sqlalchemy.orm import Session

from models.models import Game, Notification, Order, Review, User, WishlistItem
from schemas.schemas import (
    GameResponse,
    MediaInfo,
    NotificationResponse,
    OrderResponse,
    OwnershipInfo,
    PricingInfo,
    RatingInfo,
    ReviewResponse,
)


def _as_list(value) -> List[str]:
    if isinstance(value, str):
        return json.loads(value)
    return list(value or [])


def rating_summary(db: Session, game_ids: Iterable[str]) -> dict:
    """{game_id: RatingInfo} cho nhiều game trong một query."""
    ids = list(game_ids)
    if not ids:
        return {}

    rows = (
        db.query(Review.game_id, func.avg(Review.rating), func.count(Review.id))
        .filter(Review.game_id.in_(ids))
        .group_by(Review.game_id)
        .all()
    )
    return {
        game_id: RatingInfo(average=round(float(avg), 1), count=count)
        for game_id, avg, count in rows
    }


def games_to_schema(
    db: Session, games: List[Game], user: Optional[User]
) -> List[GameResponse]:
    game_ids = [g.id for g in games]
    ratings = rating_summary(db, game_ids)

    owned_ids: set = set()
    wishlisted_ids: set = set()
    if user is not None:
        owned_ids = {g.id for g in user.library}
        wishlisted_ids = {
            item.game_id
            for item in db.query(WishlistItem)
            .filter(WishlistItem.user_id == user.id, WishlistItem.game_id.in_(game_ids))
            .all()
        }

    return [
        GameResponse(
            id=game.id,
            name=game.name,
            slug=game.slug,
            shortDescription=game.short_description,
            genres=_as_list(game.genres),
            platforms=_as_list(game.platforms),
            releaseDate=(game.released_at.date().isoformat() if game.released_at else "2026-01-01"),
            sizeInBytes=game.size_bytes,
            pricing=PricingInfo(type=game.price_type, price=game.price, currency=game.currency),
            ownership=OwnershipInfo(
                owned=game.id in owned_ids,
                wishlisted=game.id in wishlisted_ids,
            ),
            media=MediaInfo(thumbnail=game.thumbnail, banner=game.banner),
            rating=ratings.get(game.id, RatingInfo()),
            badge=game.badge,
        )
        for game in games
    ]


def game_to_schema(db: Session, game: Game, user: Optional[User]) -> GameResponse:
    return games_to_schema(db, [game], user)[0]


def review_to_schema(review: Review, current_user_id: Optional[int]) -> ReviewResponse:
    return ReviewResponse(
        id=review.id,
        gameId=review.game_id,
        userId=review.user_id,
        userDisplayName=review.user.username if review.user else "Người dùng",
        rating=review.rating,
        comment=review.comment,
        createdAt=review.created_at,
        mine=review.user_id == current_user_id,
    )


def order_to_schema(order: Order) -> OrderResponse:
    return OrderResponse(
        id=order.id,
        gameId=order.game_id,
        gameName=order.game.name if order.game else order.game_id,
        gameThumbnail=order.game.thumbnail if order.game else None,
        amount=order.amount,
        currency=order.currency,
        paymentMethod=order.payment_method,
        status=order.status,
        createdAt=order.created_at,
    )


def notification_to_schema(notification: Notification) -> NotificationResponse:
    return NotificationResponse(
        id=notification.id,
        type=notification.type,
        title=notification.title,
        body=notification.body,
        deepLink=notification.deep_link,
        isRead=notification.is_read,
        createdAt=notification.created_at,
    )
