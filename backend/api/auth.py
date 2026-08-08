from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from core.database import get_db
from jose import JWTError
from core.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token,
)
from models.models import User
from schemas.schemas import (
    UserCreate,
    UserLogin,
    RefreshRequest,
    Token,
    APIResponse,
    UserResponse,
)


def _issue_tokens(user: User) -> Token:
    subject = str(user.id)
    return Token(
        accessToken=create_access_token(data={"sub": subject}),
        refreshToken=create_refresh_token(data={"sub": subject}),
    )

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/register", response_model=APIResponse[UserResponse])
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail={"code": "AUTH_005", "message": "Email đã tồn tại."})
    
    hashed_pw = get_password_hash(user.password)
    new_user = User(email=user.email, username=user.username, hashed_password=hashed_pw)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return APIResponse(data=UserResponse(id=new_user.id, email=new_user.email, displayName=new_user.username))

@router.post("/login", response_model=APIResponse[Token])
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user or not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "AUTH_001", "message": "Email hoặc mật khẩu chưa đúng."}
        )
    
    return APIResponse(data=_issue_tokens(db_user))

@router.post("/refresh", response_model=APIResponse[Token])
def refresh(payload: RefreshRequest, db: Session = Depends(get_db)):
    try:
        claims = decode_token(payload.refreshToken, expected_type="refresh")
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "AUTH_002", "message": "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."},
        )

    user = db.query(User).filter(User.id == int(claims["sub"])).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "AUTH_002", "message": "Phiên đăng nhập không hợp lệ."},
        )

    return APIResponse(data=_issue_tokens(user))