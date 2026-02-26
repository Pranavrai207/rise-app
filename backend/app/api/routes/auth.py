from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.deps import get_auth_service, get_current_user
from app.db.session import get_db
from app.models.auth import (
    TokenPair,
    TokenRefreshRequest,
    TokenRefreshResponse,
    UserCreate,
    UserLogin,
    UserPublic,
)
from app.models.entities import User
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserPublic, status_code=status.HTTP_201_CREATED)
def register(
    payload: UserCreate,
    db: Session = Depends(get_db),
    auth_service: AuthService = Depends(get_auth_service),
) -> UserPublic:
    user = auth_service.register(db=db, payload=payload)
    return UserPublic.model_validate(user)


@router.post("/login", response_model=TokenPair)
def login(
    payload: UserLogin,
    db: Session = Depends(get_db),
    auth_service: AuthService = Depends(get_auth_service),
) -> TokenPair:
    return auth_service.login(db=db, email=payload.email, password=payload.password)


@router.post("/refresh", response_model=TokenRefreshResponse)
def refresh_token(
    payload: TokenRefreshRequest,
    db: Session = Depends(get_db),
    auth_service: AuthService = Depends(get_auth_service),
) -> TokenRefreshResponse:
    access_token = auth_service.refresh_access_token(db=db, refresh_token=payload.refresh_token)
    return TokenRefreshResponse(access_token=access_token)


@router.get("/me", response_model=UserPublic)
def get_me(current_user: User = Depends(get_current_user)) -> UserPublic:
    return UserPublic.model_validate(current_user)
