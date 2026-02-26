from __future__ import annotations

from datetime import UTC, datetime

from pydantic import BaseModel, ConfigDict, Field

from app.models.entities import HabitSchedule, HabitType


class HabitCreate(BaseModel):
    title: str = Field(min_length=1, max_length=120)
    description: str = Field(min_length=1, max_length=240)
    type: HabitType
    schedule: HabitSchedule = HabitSchedule.daily


class HabitUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=120)
    description: str | None = Field(default=None, min_length=1, max_length=240)
    type: HabitType | None = None
    schedule: HabitSchedule | None = None


class HabitCompletionUpdate(BaseModel):
    completed: bool


class HabitPublic(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    description: str
    type: HabitType
    schedule: HabitSchedule
    completed: bool
    created_at: datetime


class CompletionPublic(BaseModel):
    id: int
    habit_id: str
    user_id: str
    completed: bool
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
