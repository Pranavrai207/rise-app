from __future__ import annotations

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.models.auth import TokenPair, UserCreate
from app.models.entities import User
from app.services.audit_service import AuditService


class AuthService:
    def register(self, db: Session, payload: UserCreate) -> User:
        email = payload.email.lower().strip()
        existing = db.query(User).filter(User.email == email).first()
        if existing is not None:
            AuditService().log_event(
                db,
                user_id=existing.id,
                event_type="auth_register_failed",
                entity_type="user",
                entity_id=existing.id,
                details={"reason": "email_already_registered", "email": email},
            )
            db.commit()
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

        user = User(email=email, hashed_password=hash_password(payload.password))
        db.add(user)
        db.commit()
        db.refresh(user)
        AuditService().log_event(
            db,
            user_id=user.id,
            event_type="auth_register_success",
            entity_type="user",
            entity_id=user.id,
            details={"email": user.email},
        )
        db.commit()
        return user

    def login(self, db: Session, email: str, password: str) -> TokenPair:
        user = db.query(User).filter(User.email == email.lower().strip()).first()
        if user is None:
            AuditService().log_event(
                db,
                user_id=None,
                event_type="auth_login_failed",
                entity_type="user",
                entity_id=email.lower().strip(),
                details={"reason": "user_not_found"},
            )
            db.commit()
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

        if not verify_password(password, user.hashed_password):
            AuditService().log_event(
                db,
                user_id=user.id,
                event_type="auth_login_failed",
                entity_type="user",
                entity_id=user.id,
                details={"reason": "invalid_password", "email": user.email},
            )
            db.commit()
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

        AuditService().log_event(
            db,
            user_id=user.id,
            event_type="auth_login_success",
            entity_type="user",
            entity_id=user.id,
            details={"email": user.email},
        )
        db.commit()
        return TokenPair(
            access_token=create_access_token(subject=user.id),
            refresh_token=create_refresh_token(subject=user.id),
        )

    def refresh_access_token(self, db: Session, refresh_token: str) -> str:
        try:
            payload = decode_token(refresh_token)
        except ValueError as exc:
            AuditService().log_event(
                db,
                user_id=None,
                event_type="auth_refresh_failed",
                entity_type="token",
                entity_id="unknown",
                details={"reason": "decode_failed"},
            )
            db.commit()
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token") from exc

        if payload.get("type") != "refresh":
            AuditService().log_event(
                db,
                user_id=None,
                event_type="auth_refresh_failed",
                entity_type="token",
                entity_id="unknown",
                details={"reason": "invalid_token_type"},
            )
            db.commit()
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token type")

        subject = payload.get("sub")
        if not isinstance(subject, str) or not subject:
            AuditService().log_event(
                db,
                user_id=None,
                event_type="auth_refresh_failed",
                entity_type="token",
                entity_id="unknown",
                details={"reason": "invalid_subject"},
            )
            db.commit()
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token subject")

        user = db.query(User).filter(User.id == subject).first()
        if user is None:
            AuditService().log_event(
                db,
                user_id=None,
                event_type="auth_refresh_failed",
                entity_type="user",
                entity_id=subject,
                details={"reason": "user_not_found"},
            )
            db.commit()
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token subject")

        AuditService().log_event(
            db,
            user_id=user.id,
            event_type="auth_refresh_success",
            entity_type="user",
            entity_id=user.id,
            details={},
        )
        db.commit()
        return create_access_token(subject=subject)

    def get_by_id(self, db: Session, user_id: str) -> User | None:
        return db.query(User).filter(User.id == user_id).first()
