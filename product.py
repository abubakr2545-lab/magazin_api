from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List


class ProductBase(BaseModel):
    """Базовая схема товара"""
    name: str
    description: Optional[str] = None
    price: float = Field(gt=0, description="Цена должна быть больше 0")
    category_id: int
    image_url: Optional[str] = None
    stock: int = Field(ge=0, default=0, description="Количество на складе")
    sizes: List[str] = Field(default_factory=list)
    colors: List[str] = Field(default_factory=list)


class ProductCreate(ProductBase):
    """Схема для создания товара"""
    pass


class ProductUpdate(BaseModel):
    """Схема для обновления товара"""
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = Field(None, gt=0)
    category_id: Optional[int] = None
    image_url: Optional[str] = None
    stock: Optional[int] = Field(None, ge=0)
    sizes: Optional[List[str]] = None
    colors: Optional[List[str]] = None


class ProductResponse(ProductBase):
    """Схема ответа товара"""
    id: int
    
    model_config = ConfigDict(from_attributes=True)
