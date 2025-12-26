from pydantic import BaseModel, ConfigDict, Field
from typing import List, Optional
from datetime import datetime
from models.order import OrderStatus


class OrderItemCreate(BaseModel):
    """Схема для создания элемента заказа"""
    product_id: int
    quantity: int = Field(gt=0, description="Количество должно быть больше 0")
    size: Optional[str] = None
    color: Optional[str] = None


class OrderItemResponse(BaseModel):
    """Схема ответа элемента заказа"""
    id: int
    product_id: int
    quantity: int
    price: float
    size: Optional[str] = None
    color: Optional[str] = None
    
    model_config = ConfigDict(from_attributes=True)


class OrderCreate(BaseModel):
    """Схема для создания заказа"""
    items: List[OrderItemCreate] = Field(min_length=1, description="Заказ должен содержать хотя бы один товар")


class OrderUpdate(BaseModel):
    """Схема для обновления заказа"""
    status: OrderStatus


class OrderResponse(BaseModel):
    """Схема ответа заказа"""
    id: int
    user_id: int
    status: OrderStatus
    total_price: float
    created_at: datetime
    updated_at: datetime
    items: List[OrderItemResponse] = []
    
    model_config = ConfigDict(from_attributes=True)
