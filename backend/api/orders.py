import uuid

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from api.users import get_current_user
from core.database import get_db
from core.notifications import push_notification
from core.serializers import order_to_schema
from models.models import Game, Order, User, WishlistItem
from schemas.schemas import APIResponse, OrderCreate, OrderListResponse, OrderResponse

router = APIRouter(prefix="/orders", tags=["Orders"])

PAYMENT_METHODS = ["momo", "vnpay", "card"]


def _format_price(amount: float, currency: str) -> str:
    return f"{int(amount):,}".replace(",", ".") + f" {currency}"


@router.get("", response_model=APIResponse[OrderListResponse])
def list_orders(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(Order).filter(Order.user_id == current_user.id)
    total = query.count()
    orders = (
        query.order_by(Order.created_at.desc())
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )
    return APIResponse(
        data=OrderListResponse(
            items=[order_to_schema(o) for o in orders],
            page=page,
            limit=limit,
            total=total,
        )
    )


@router.post("", response_model=APIResponse[OrderResponse])
def create_order(
    payload: OrderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Mua một game. Thanh toán được giả lập và luôn thành công."""
    if payload.paymentMethod not in PAYMENT_METHODS:
        raise HTTPException(
            status_code=400,
            detail={"code": "ORDER_003", "message": "Phương thức thanh toán không được hỗ trợ."},
        )

    game = db.query(Game).filter(Game.id == payload.gameId).first()
    if not game:
        raise HTTPException(status_code=404, detail={"code": "GAME_001", "message": "Game không tồn tại."})

    if game in current_user.library:
        raise HTTPException(
            status_code=409,
            detail={"code": "ORDER_001", "message": "Bạn đã sở hữu game này."},
        )

    if game.price_type == "free":
        raise HTTPException(
            status_code=400,
            detail={"code": "ORDER_002", "message": "Game miễn phí, hãy thêm thẳng vào thư viện."},
        )

    order = Order(
        id=f"order_{uuid.uuid4().hex[:12]}",
        user_id=current_user.id,
        game_id=game.id,
        amount=game.price or 0,
        currency=game.currency or "VND",
        payment_method=payload.paymentMethod,
        status="paid",
    )
    db.add(order)

    current_user.library.append(game)
    db.query(WishlistItem).filter(
        WishlistItem.user_id == current_user.id, WishlistItem.game_id == game.id
    ).delete()

    push_notification(
        db,
        current_user.id,
        type="order",
        title="Thanh toán thành công",
        body=f"Bạn đã mua {game.name} với giá {_format_price(order.amount, order.currency)}.",
        deep_link=f"/game/{game.id}",
    )

    db.commit()
    db.refresh(order)

    return APIResponse(message="Mua game thành công", data=order_to_schema(order))


@router.get("/{order_id}", response_model=APIResponse[OrderResponse])
def get_order(
    order_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    order = (
        db.query(Order)
        .filter(Order.id == order_id, Order.user_id == current_user.id)
        .first()
    )
    if order is None:
        raise HTTPException(
            status_code=404,
            detail={"code": "ORDER_004", "message": "Không tìm thấy đơn hàng."},
        )
    return APIResponse(data=order_to_schema(order))
