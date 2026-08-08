from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./gamehub.db"
    SECRET_KEY: str = "super_secret_key_for_jwt_change_me_in_production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 # 1 giờ
    REFRESH_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30 # 30 ngày

settings = Settings()