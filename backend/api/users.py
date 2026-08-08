from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from core.database import get_db
from models.models import User
from schemas.schemas import APIResponse, UserResponse
from core.security import decode_token
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

@router.get("/me", response_model=APIResponse[UserResponse])
def read_users_me(current_user: User = Depends(get_current_user)):
    return APIResponse(data=UserResponse(
        id=current_user.id, 
        email=current_user.email, 
        displayName=current_user.username
    ))