from __future__ import annotations

import json
from datetime import UTC, datetime
from typing import Any

from sqlalchemy.orm import Session

from app.models.entities import AuditLog


class AuditService:
    def log_event(
        self,
        db: Session,
        *,
        user_id: str | None,
        event_type: str,
        entity_type: str,
        entity_id: str,
        details: dict[str, Any] | None = None,
    ) -> None:
        entry = AuditLog(
            user_id=user_id,
            event_type=event_type,
            entity_type=entity_type,
            entity_id=entity_id,
            details=json.dumps(details or {}, separators=(",", ":"), sort_keys=True),
            created_at=datetime.now(UTC),
        )
        db.add(entry)
