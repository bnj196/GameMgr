"""Tạo thông báo in-app cho người dùng."""
from typing import Optional

from sqlalchemy.orm import Session

from models.models import Notification


def push_notification(
    db: Session,
    user_id: int,
    *,
    type: str,
    title: str,
    body: str,
    deep_link: Optional[str] = None,
) -> Notification:
    notification = Notification(
        user_id=user_id,
        type=type,
        title=title,
        body=body,
        deep_link=deep_link,
    )
    db.add(notification)
    db.flush()
    return notification
