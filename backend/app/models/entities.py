from __future__ import annotations

from datetime import UTC, datetime
import enum
from uuid import uuid4

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Index, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class HabitType(str, enum.Enum):
    chakra = "CHAKRA"
    vitality = "VITALITY"
    focus = "FOCUS"


class HabitSchedule(str, enum.Enum):
    daily = "DAILY"
    recurring = "RECURRING"
    one_off = "ONE_OFF"


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(512))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(UTC))

    habits: Mapped[list[Habit]] = relationship(back_populates="user", cascade="all, delete-orphan")


class Habit(Base):
    __tablename__ = "habits"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    title: Mapped[str] = mapped_column(String(120))
    description: Mapped[str] = mapped_column(String(240))
    type: Mapped[HabitType] = mapped_column(Enum(HabitType, name="habit_type"), index=True)
    schedule: Mapped[HabitSchedule] = mapped_column(Enum(HabitSchedule, name="habit_schedule"), default=HabitSchedule.daily)
    completed: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(UTC))

    user: Mapped[User] = relationship(back_populates="habits")
    completions: Mapped[list[Completion]] = relationship(back_populates="habit", cascade="all, delete-orphan")


class Completion(Base):
    __tablename__ = "completions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    habit_id: Mapped[str] = mapped_column(ForeignKey("habits.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    completed: Mapped[bool] = mapped_column(Boolean)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(UTC), index=True)

    habit: Mapped[Habit] = relationship(back_populates="completions")


class Stats(Base):
    __tablename__ = "stats"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    chakra_xp: Mapped[int] = mapped_column(Integer, default=0)
    vitality_xp: Mapped[int] = mapped_column(Integer, default=0)
    focus_xp: Mapped[int] = mapped_column(Integer, default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(UTC))


class Quest(Base):
    __tablename__ = "quests"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    title: Mapped[str] = mapped_column(String(160))
    status: Mapped[str] = mapped_column(String(32), default="active")
    notes: Mapped[str] = mapped_column(Text, default="")


class AvatarState(Base):
    __tablename__ = "avatar_states"

    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    aura_level: Mapped[int] = mapped_column(Integer, default=0)
    aura_label: Mapped[str] = mapped_column(String(64), default="Dormant")
    avatar_type: Mapped[str] = mapped_column(String(32), default="neutral")
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(UTC))


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str | None] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=True)
    event_type: Mapped[str] = mapped_column(String(64), index=True)
    entity_type: Mapped[str] = mapped_column(String(64))
    entity_id: Mapped[str] = mapped_column(String(64))
    details: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(UTC), index=True)


Index("ix_habit_user_schedule", Habit.user_id, Habit.schedule)
Index("ix_completion_user_time", Completion.user_id, Completion.created_at)
Index("ix_audit_user_time", AuditLog.user_id, AuditLog.created_at)
