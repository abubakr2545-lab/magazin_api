from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from models.user import User
from models.order import Order, OrderStatus
from models.order_item import OrderItem
from models.product import Product
from schemas.order import OrderCreate, OrderUpdate, OrderResponse
from utils.database import get_db
from utils.auth import get_current_user

router = APIRouter(prefix="/orders", tags=["Заказы"])


@router.get("/", response_model=List[OrderResponse])
def get_my_orders(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Получить список заказов текущего пользователя"""
    orders = db.query(Order).filter(
        Order.user_id == current_user.id
    ).offset(skip).limit(limit).all()
    return orders


@router.get("/{order_id}", response_model=OrderResponse)
def get_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Получить заказ по ID"""
    order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id
    ).first()
    
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Заказ не найден"
        )
    return order


@router.post("/", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(
    order: OrderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Создать новый заказ"""
    total_price = 0
    order_items = []
    
    # Обработка каждого элемента заказа
    for item in order.items:
        # Проверка существования товара
        product = db.query(Product).filter(Product.id == item.product_id).first()
        if not product:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Товар с ID {item.product_id} не найден"
            )
        
        # Проверка наличия на складе
        if product.stock < item.quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Недостаточно товара '{product.name}' на складе"
            )
        
        # Проверка размера и цвета
        if item.size and item.size not in product.sizes:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Размер {item.size} недоступен для товара '{product.name}'"
            )
        
        if item.color and item.color not in product.colors:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Цвет {item.color} недоступен для товара '{product.name}'"
            )
        
        # Рассчет цены
        item_price = product.price * item.quantity
        total_price += item_price
        
        # Создание элемента заказа
        order_items.append(OrderItem(
            product_id=item.product_id,
            quantity=item.quantity,
            price=product.price,
            size=item.size,
            color=item.color
        ))
        
        # Уменьшение количества на складе
        product.stock -= item.quantity
    
    # Создание заказа
    db_order = Order(
        user_id=current_user.id,
        total_price=total_price,
        status=OrderStatus.PENDING
    )
    db.add(db_order)
    db.flush()  # Получить ID заказа
    
    # Добавление элементов заказа
    for item in order_items:
        item.order_id = db_order.id
        db.add(item)
    
    db.commit()
    db.refresh(db_order)
    return db_order


@router.put("/{order_id}/status", response_model=OrderResponse)
def update_order_status(
    order_id: int,
    order_update: OrderUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Обновить статус заказа"""
    order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id
    ).first()
    
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Заказ не найден"
        )
    
    # Проверка возможности изменения статуса
    if order.status == OrderStatus.DELIVERED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Невозможно изменить статус доставленного заказа"
        )
    
    if order.status == OrderStatus.CANCELLED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Невозможно изменить статус отмененного заказа"
        )
    
    order.status = order_update.status
    db.commit()
    db.refresh(order)
    return order


@router.delete("/{order_id}", status_code=status.HTTP_204_NO_CONTENT)
def cancel_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Отменить заказ"""
    order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id
    ).first()
    
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Заказ не найден"
        )
    
    # Проверка возможности отмены
    if order.status in [OrderStatus.SHIPPED, OrderStatus.DELIVERED]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Невозможно отменить доставленный или отправленный заказ"
        )
    
    if order.status == OrderStatus.CANCELLED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Заказ уже отменен"
        )
    
    # Возврат товаров на склад
    for item in order.items:
        product = db.query(Product).filter(Product.id == item.product_id).first()
        if product:
            product.stock += item.quantity
    
    order.status = OrderStatus.CANCELLED
    db.commit()
    return None
