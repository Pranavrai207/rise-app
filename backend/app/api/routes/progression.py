from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.entities import User
from app.models.progression import ProgressionPublic
from app.services.progression_service import ProgressionService

router = APIRouter(prefix="/progression", tags=["progression"])


@router.get("/me", response_model=ProgressionPublic)
def get_my_progression(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ProgressionPublic:
    service = ProgressionService()
    stats, avatar = service.recompute_user_progression(db=db, user_id=current_user.id)
    db.commit()
    db.refresh(stats)
    db.refresh(avatar)
    return ProgressionPublic(stats=stats, avatar=avatar)
