# Render: быстрый деплой

## 1) Build Command
pip install -r requirements.txt

## 2) Start Command
uvicorn main:app --host 0.0.0.0 --port $PORT

## 3) Root Directory
Оставьте пустым (если main.py и requirements.txt в корне репозитория).

## 4) Swagger
После деплоя откройте: /docs
