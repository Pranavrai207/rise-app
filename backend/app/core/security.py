from __future__ import annotations

import base64
import hashlib
import hmac
import secrets
from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import uuid4

from jose import JWTError, jwt

from .config import get_settings


def _b64_encode(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).decode("ascii")


def _b64_decode(raw: str) -> bytes:
    return base64.urlsafe_b64decode(raw.encode("ascii"))


def hash_password(password: str) -> str:
    salt = secrets.token_bytes(16)
    derived = hashlib.scrypt(password.encode("utf-8"), salt=salt, n=2**14, r=8, p=1, dklen=32)
    return f"scrypt$16384$8$1${_b64_encode(salt)}${_b64_encode(derived)}"


def verify_password(plain_password: str, stored_hash: str) -> bool:
    try:
        algo, n, r, p, salt_b64, hash_b64 = stored_hash.split("$", 5)
        if algo != "scrypt":
            return False
        salt = _b64_decode(salt_b64)
        expected = _b64_decode(hash_b64)
        check = hashlib.scrypt(
            plain_password.encode("utf-8"),
            salt=salt,
            n=int(n),
            r=int(r),
            p=int(p),
            dklen=len(expected),
        )
        return hmac.compare_digest(check, expected)
    except Exception:
        return False


def _build_token(subject: str, expires_delta: timedelta, token_type: str) -> str:
    settings = get_settings()
    now = datetime.now(UTC)
    payload: dict[str, Any] = {
        "sub": subject,
        "type": token_type,
        "iat": int(now.timestamp()),
        "exp": int((now + expires_delta).timestamp()),
        "jti": str(uuid4()),
    }
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def create_access_token(subject: str) -> str:
    settings = get_settings()
    expiry = timedelta(minutes=settings.jwt_access_token_expire_minutes)
    return _build_token(subject=subject, expires_delta=expiry, token_type="access")


def create_refresh_token(subject: str) -> str:
    settings = get_settings()
    expiry = timedelta(minutes=settings.jwt_refresh_token_expire_minutes)
    return _build_token(subject=subject, expires_delta=expiry, token_type="refresh")


def decode_token(token: str) -> dict[str, Any]:
    settings = get_settings()
    try:
        return jwt.decode(token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])
    except JWTError as exc:
        raise ValueError("Invalid or expired token") from exc
