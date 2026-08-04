from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from core.database import get_db
from core.security import get_password_hash, verify_password, create_access_token
from models.models import User
from schemas.schemas import UserCreate, UserLogin, Token, APIResponse, UserResponse

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
    
    access_token = create_access_token(data={"sub": str(db_user.id)})
    return APIResponse(data=Token(accessToken=access_token, refreshToken="mock_refresh_token"))