import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import settings
from utils.database import engine, Base
from routes import (
    categories_router,
    products_router,
    auth_router,
    orders_router,
)

app = FastAPI(
    title="Магазин Одежды API",
    description="REST API для онлайн-магазина одежды",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS (для фронтенда)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Роутеры
app.include_router(auth_router)
app.include_router(categories_router)
app.include_router(products_router)
app.include_router(orders_router)


@app.on_event("startup")
def on_startup() -> None:
    """Создаём таблицы при старте (важно для деплоя и локального запуска)."""
    Base.metadata.create_all(bind=engine)


@app.get("/", tags=["Общее"])
def root():
    """Корневой эндпоинт"""
    return {
        "message": "Добро пожаловать в API Магазина Одежды",
        "docs": "/docs",
        "redoc": "/redoc",
        "health": "/health",
    }


@app.get("/health", tags=["Общее"])
def health_check():
    """Проверка здоровья API"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn

    # Render/Heroku-like platforms provide PORT env var
    port = int(os.getenv("PORT", "8000"))
    uvicorn.run("main:app", host="0.0.0.0", port=port)
