from pydantic import BaseModel, EmailStr, ConfigDict, Field
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    """Базовая схема пользователя"""
    email: EmailStr
    full_name: Optional[str] = None


class UserCreate(UserBase):
    """Схема для регистрации пользователя"""
    password: str = Field(min_length=6, description="Пароль должен быть не менее 6 символов")


class UserLogin(BaseModel):
    """Схема для входа пользователя"""
    email: EmailStr
    password: str


class UserResponse(UserBase):
    """Схема ответа пользователя"""
    id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    """Схема JWT токена"""
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Данные из токена"""
    user_id: Optional[int] = None
