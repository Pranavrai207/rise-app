from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.entities import Quest, User
from app.models.quest import QuestCreate, QuestPublic, QuestUpdate
from app.services.audit_service import AuditService

router = APIRouter(prefix="/quests", tags=["quests"])


@router.get("", response_model=list[QuestPublic])
def list_quests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[Quest]:
    return db.query(Quest).filter(Quest.user_id == current_user.id).order_by(Quest.id.desc()).all()


@router.post("", response_model=QuestPublic, status_code=status.HTTP_201_CREATED)
def create_quest(
    payload: QuestCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Quest:
    quest = Quest(
        user_id=current_user.id,
        title=payload.title.strip(),
        status="active",
        notes=payload.notes.strip(),
    )
    db.add(quest)
    db.commit()
    db.refresh(quest)
    AuditService().log_event(
        db,
        user_id=current_user.id,
        event_type="quest_created",
        entity_type="quest",
        entity_id=str(quest.id),
        details={"title": quest.title, "status": quest.status},
    )
    db.commit()
    return quest


@router.patch("/{quest_id}", response_model=QuestPublic)
def update_quest(
    quest_id: int,
    payload: QuestUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Quest:
    quest = db.query(Quest).filter(Quest.id == quest_id, Quest.user_id == current_user.id).first()
    if quest is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quest not found")

    before = {"title": quest.title, "status": quest.status, "notes": quest.notes}
    if payload.title is not None:
        quest.title = payload.title.strip()
    if payload.status is not None:
        quest.status = payload.status.strip().lower()
    if payload.notes is not None:
        quest.notes = payload.notes.strip()

    db.add(quest)
    db.commit()
    db.refresh(quest)
    AuditService().log_event(
        db,
        user_id=current_user.id,
        event_type="quest_updated",
        entity_type="quest",
        entity_id=str(quest.id),
        details={
            "title": quest.title,
            "status": quest.status,
            "notes": quest.notes,
            "previous": before,
        },
    )
    db.commit()
    return quest
