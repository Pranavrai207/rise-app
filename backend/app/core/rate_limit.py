import time
from collections import defaultdict, deque
from typing import Callable

from fastapi import HTTPException, Request
from starlette.middleware.base import BaseHTTPMiddleware

from app.db.session import SessionLocal
from app.services.audit_service import AuditService

from .config import get_settings


class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        self._bucket: dict[str, deque[float]] = defaultdict(deque)
        self._settings = get_settings()

    async def dispatch(self, request: Request, call_next: Callable):
        client_host = request.client.host if request.client else "unknown"
        now = time.time()
        window = self._settings.rate_limit_window_seconds
        allowed = self._settings.rate_limit_requests

        bucket = self._bucket[client_host]
        while bucket and now - bucket[0] > window:
            bucket.popleft()

        if len(bucket) >= allowed:
            # Best-effort audit capture for abuse visibility.
            db = SessionLocal()
            try:
                AuditService().log_event(
                    db,
                    user_id=None,
                    event_type="rate_limit_blocked",
                    entity_type="request",
                    entity_id=client_host,
                    details={"path": request.url.path, "method": request.method},
                )
                db.commit()
            except Exception:
                db.rollback()
            finally:
                db.close()
            raise HTTPException(status_code=429, detail="Too many requests")

        bucket.append(now)
        return await call_next(request)
