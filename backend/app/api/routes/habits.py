from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.models.entities import Completion, Habit, HabitSchedule, HabitType, User
from app.models.habit import HabitCompletionUpdate, HabitCreate, HabitPublic, HabitUpdate
from app.services.completion_policy_service import CompletionPolicyService
from app.services.progression_service import ProgressionService

router = APIRouter(prefix="/habits", tags=["habits"])


@router.get("", response_model=list[HabitPublic])
def list_habits(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[Habit]:
    return (
        db.query(Habit)
        .filter(Habit.user_id == current_user.id)
        .order_by(Habit.created_at.desc())
        .all()
    )


@router.post("", response_model=HabitPublic, status_code=status.HTTP_201_CREATED)
def create_habit(
    payload: HabitCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Habit:
    habit = Habit(
        user_id=current_user.id,
        title=payload.title.strip(),
        description=payload.description.strip(),
        type=HabitType(payload.type),
        schedule=HabitSchedule(payload.schedule),
        completed=False,
    )
    db.add(habit)
    db.commit()
    db.refresh(habit)
    return habit


@router.patch("/{habit_id}", response_model=HabitPublic)
def update_habit(
    habit_id: str,
    payload: HabitUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Habit:
    habit = db.query(Habit).filter(Habit.id == habit_id, Habit.user_id == current_user.id).first()
    if habit is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Habit not found")

    if payload.title is not None:
        habit.title = payload.title.strip()
    if payload.description is not None:
        habit.description = payload.description.strip()
    if payload.type is not None:
        habit.type = HabitType(payload.type)
    if payload.schedule is not None:
        habit.schedule = HabitSchedule(payload.schedule)

    db.add(habit)
    db.commit()
    db.refresh(habit)
    return habit


@router.patch("/{habit_id}/completion", response_model=HabitPublic)
def update_completion(
    habit_id: str,
    payload: HabitCompletionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Habit:
    habit = db.query(Habit).filter(Habit.id == habit_id, Habit.user_id == current_user.id).first()
    if habit is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Habit not found")

    if habit.completed == payload.completed:
        return habit

    if payload.completed:
        policy = CompletionPolicyService()
        policy.ensure_can_mark_completed(db=db, habit=habit, user_id=current_user.id)

    habit.completed = payload.completed
    completion = Completion(habit_id=habit.id, user_id=current_user.id, completed=payload.completed)
    progression_service = ProgressionService()

    db.add(habit)
    db.add(completion)
    progression_service.recompute_user_progression(db=db, user_id=current_user.id)
    db.commit()
    db.refresh(habit)

    return habit
