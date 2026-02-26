from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.entities import AvatarState, Habit, Stats, User
from app.models.profile import ProfilePublic
from app.services.progression_service import ProgressionService

router = APIRouter(prefix="/profile", tags=["profile"])


@router.get("/me", response_model=ProfilePublic)
def get_profile_me(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ProfilePublic:
    progression = ProgressionService()
    stats, avatar = progression.recompute_user_progression(db=db, user_id=current_user.id)
    db.commit()

    stats_row = db.query(Stats).filter(Stats.user_id == current_user.id).first() or stats
    avatar_row = db.query(AvatarState).filter(AvatarState.user_id == current_user.id).first() or avatar

    total_habits = db.query(Habit).filter(Habit.user_id == current_user.id).count()
    completed_habits = db.query(Habit).filter(Habit.user_id == current_user.id, Habit.completed.is_(True)).count()

    return ProfilePublic(
        user_id=current_user.id,
        email=current_user.email,
        total_habits=total_habits,
        completed_habits=completed_habits,
        chakra_xp=stats_row.chakra_xp,
        vitality_xp=stats_row.vitality_xp,
        focus_xp=stats_row.focus_xp,
        aura_level=avatar_row.aura_level,
        aura_label=avatar_row.aura_label,
        avatar_type=avatar_row.avatar_type,
    )


@router.patch("/avatar", response_model=ProfilePublic)
def update_avatar(
    avatar_type: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ProfilePublic:
    avatar = db.query(AvatarState).filter(AvatarState.user_id == current_user.id).first()
    if not avatar:
        avatar = AvatarState(user_id=current_user.id)
        db.add(avatar)

    avatar.avatar_type = avatar_type
    db.commit()
    return get_profile_me(db=db, current_user=current_user)
