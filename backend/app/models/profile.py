from pydantic import BaseModel


class ProfilePublic(BaseModel):
    user_id: str
    email: str
    total_habits: int
    completed_habits: int
    chakra_xp: int
    vitality_xp: int
    focus_xp: int
    aura_level: int
    aura_label: str
    avatar_type: str
