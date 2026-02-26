from __future__ import annotations

from datetime import UTC, datetime, timedelta

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.entities import Completion, Habit, HabitSchedule


class CompletionPolicyService:
    recurring_cooldown_hours = 6

    def ensure_can_mark_completed(self, db: Session, habit: Habit, user_id: str) -> None:
        if habit.schedule == HabitSchedule.one_off:
            self._ensure_one_off_allowed(db=db, habit=habit, user_id=user_id)
            return

        if habit.schedule == HabitSchedule.daily:
            self._ensure_daily_allowed(db=db, habit=habit, user_id=user_id)
            return

        if habit.schedule == HabitSchedule.recurring:
            self._ensure_recurring_allowed(db=db, habit=habit, user_id=user_id)

    def _ensure_one_off_allowed(self, db: Session, habit: Habit, user_id: str) -> None:
        previous_true = (
            db.query(Completion)
            .filter(
                Completion.user_id == user_id,
                Completion.habit_id == habit.id,
                Completion.completed.is_(True),
            )
            .first()
        )
        if previous_true is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="One-off habit already completed and cannot be completed again.",
            )

    def _ensure_daily_allowed(self, db: Session, habit: Habit, user_id: str) -> None:
        now = datetime.now(UTC)
        day_start = now.replace(hour=0, minute=0, second=0, microsecond=0)

        completed_today = (
            db.query(Completion)
            .filter(
                Completion.user_id == user_id,
                Completion.habit_id == habit.id,
                Completion.completed.is_(True),
                Completion.created_at >= day_start,
            )
            .first()
        )
        if completed_today is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Daily habit already completed today.",
            )

    def _ensure_recurring_allowed(self, db: Session, habit: Habit, user_id: str) -> None:
        window_start = datetime.now(UTC) - timedelta(hours=self.recurring_cooldown_hours)

        recent_completion = (
            db.query(Completion)
            .filter(
                Completion.user_id == user_id,
                Completion.habit_id == habit.id,
                Completion.completed.is_(True),
                Completion.created_at >= window_start,
            )
            .first()
        )
        if recent_completion is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Recurring habit is on cooldown. Try again later.",
            )
