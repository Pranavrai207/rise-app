from __future__ import annotations

from sqlalchemy.orm import Session

from app.models.entities import User


class UserService:
    def find_by_email(self, db: Session, email: str) -> User | None:
        return db.query(User).filter(User.email == email).first()

    def find_by_id(self, db: Session, user_id: str) -> User | None:
        return db.query(User).filter(User.id == user_id).first()
