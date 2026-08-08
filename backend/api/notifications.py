from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from api.users import get_current_user
from core.database import get_db
from core.serializers import notification_to_schema
from models.models import Notification, User
from schemas.schemas import (
    APIResponse,
    NotificationListResponse,
    NotificationResponse,
    UnreadCountResponse,
)

router = APIRouter(prefix="/notifications", tags=["Notifications"])


def _unread_count(db: Session, user_id: int) -> int:
    return (
        db.query(Notification)
        .filter(Notification.user_id == user_id, Notification.is_read.is_(False))
        .count()
    )


@router.get("", response_model=APIResponse[NotificationListResponse])
def list_notifications(
    unreadOnly: bool = Query(False),
    type: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(Notification).filter(Notification.user_id == current_user.id)
    if unreadOnly:
        query = query.filter(Notification.is_read.is_(False))
    if type:
        query = query.filter(Notification.type == type)

    total = query.count()
    items = (
        query.order_by(Notification.created_at.desc(), Notification.id.desc())
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )

    return APIResponse(
        data=NotificationListResponse(
            items=[notification_to_schema(n) for n in items],
            page=page,
            limit=limit,
            total=total,
            unreadCount=_unread_count(db, current_user.id),
        )
    )


@router.get("/unread-count", response_model=APIResponse[UnreadCountResponse])
def unread_count(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return APIResponse(data=UnreadCountResponse(unreadCount=_unread_count(db, current_user.id)))


@router.post("/read-all", response_model=APIResponse[UnreadCountResponse])
def mark_all_read(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db.query(Notification).filter(
        Notification.user_id == current_user.id, Notification.is_read.is_(False)
    ).update({Notification.is_read: True})
    db.commit()
    return APIResponse(message="Đã đánh dấu tất cả là đã đọc", data=UnreadCountResponse(unreadCount=0))


@router.post("/{notification_id}/read", response_model=APIResponse[NotificationResponse])
def mark_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    notification = (
        db.query(Notification)
        .filter(Notification.id == notification_id, Notification.user_id == current_user.id)
        .first()
    )
    if notification is None:
        raise HTTPException(
            status_code=404,
            detail={"code": "NOTI_001", "message": "Không tìm thấy thông báo."},
        )

    notification.is_read = True
    db.commit()
    db.refresh(notification)
    return APIResponse(data=notification_to_schema(notification))


@router.delete("/{notification_id}", response_model=APIResponse)
def delete_notification(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    deleted = (
        db.query(Notification)
        .filter(Notification.id == notification_id, Notification.user_id == current_user.id)
        .delete()
    )
    if not deleted:
        raise HTTPException(
            status_code=404,
            detail={"code": "NOTI_001", "message": "Không tìm thấy thông báo."},
        )
    db.commit()
    return APIResponse(message="Đã xóa thông báo")
