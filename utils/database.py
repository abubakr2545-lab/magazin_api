# utils/database.py
# Мостик для совместимости импортов: from utils.database import engine, Base

from database import engine, Base

__all__ = ["engine", "Base"]
