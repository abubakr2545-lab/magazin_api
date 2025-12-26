from pydantic import BaseModel, ConfigDict
from typing import Optional, List


class CategoryBase(BaseModel):
    """Базовая схема категории"""
    name: str
    description: Optional[str] = None
    parent_id: Optional[int] = None


class CategoryCreate(CategoryBase):
    """Схема для создания категории"""
    pass


class CategoryUpdate(BaseModel):
    """Схема для обновления категории"""
    name: Optional[str] = None
    description: Optional[str] = None
    parent_id: Optional[int] = None


class CategoryResponse(CategoryBase):
    """Схема ответа категории"""
    id: int
    
    model_config = ConfigDict(from_attributes=True)


class CategoryWithSubcategories(CategoryResponse):
    """Категория с подкатегориями"""
    subcategories: List['CategoryResponse'] = []
    
    model_config = ConfigDict(from_attributes=True)
