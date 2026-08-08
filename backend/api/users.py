from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from core.database import get_db
from models.models import User
from schemas.schemas import APIResponse, PasswordChange, UserResponse, UserUpdate
from core.security import decode_token, get_password_hash, verify_password
from jose import JWTError
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/login")
router = APIRouter(prefix="/users", tags=["Users"])

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    try:
        payload = decode_token(token, expected_type="access")
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail={"code": "AUTH_002", "message": "Token không hợp lệ."})
    except JWTError:
        raise HTTPException(status_code=401, detail={"code": "AUTH_002", "message": "Token hết hạn hoặc không hợp lệ."})
        
    user = db.query(User).filter(User.id == int(user_id)).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

def _to_schema(user: User) -> UserResponse:
    return UserResponse(
        id=user.id,
        email=user.email,
        displayName=user.username,
        avatarUrl=user.avatar_url,
        bio=user.bio,
    )

@router.get("/me", response_model=APIResponse[UserResponse])
def read_users_me(current_user: User = Depends(get_current_user)):
    return APIResponse(data=_to_schema(current_user))

@router.patch("/me", response_model=APIResponse[UserResponse])
def update_users_me(
    payload: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    fields = payload.model_dump(exclude_unset=True)
    if "displayName" in fields and fields["displayName"] is not None:
        current_user.username = fields["displayName"].strip()
    if "avatarUrl" in fields:
        current_user.avatar_url = fields["avatarUrl"]
    if "bio" in fields:
        current_user.bio = fields["bio"]

    db.commit()
    db.refresh(current_user)
    return APIResponse(message="Đã cập nhật hồ sơ", data=_to_schema(current_user))

@router.post("/me/password", response_model=APIResponse)
def change_password(
    payload: PasswordChange,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not verify_password(payload.currentPassword, current_user.hashed_password):
        raise HTTPException(
            status_code=400,
            detail={"code": "AUTH_006", "message": "Mật khẩu hiện tại không đúng."},
        )
    if payload.currentPassword == payload.newPassword:
        raise HTTPException(
            status_code=400,
            detail={"code": "AUTH_007", "message": "Mật khẩu mới phải khác mật khẩu cũ."},
        )

    current_user.hashed_password = get_password_hash(payload.newPassword)
    db.commit()
    return APIResponse(message="Đã đổi mật khẩu")