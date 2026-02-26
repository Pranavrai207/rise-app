from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class QuestCreate(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    notes: str = Field(default='', max_length=2000)


class QuestUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=160)
    status: Literal["active", "done", "paused"] | None = None
    notes: str | None = Field(default=None, max_length=2000)


class QuestPublic(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: str
    title: str
    status: str
    notes: str
