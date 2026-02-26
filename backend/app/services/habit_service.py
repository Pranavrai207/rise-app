from sqlalchemy.orm import Session

from app.models.entities import Habit


class HabitService:
    def list_habits(self, db: Session, user_id: str) -> list[Habit]:
        return db.query(Habit).filter(Habit.user_id == user_id).order_by(Habit.created_at.desc()).all()
