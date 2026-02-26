from datetime import UTC, datetime

from pydantic import BaseModel, ConfigDict, Field


class StatsPublic(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    user_id: str
    chakra_xp: int
    vitality_xp: int
    focus_xp: int
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))


class AvatarStatePublic(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    user_id: str
    aura_level: int
    aura_label: str
    avatar_type: str
    updated_at: datetime = Field(default_factory=lambda: datetime.now(UTC))


class ProgressionPublic(BaseModel):
    stats: StatsPublic
    avatar: AvatarStatePublic
