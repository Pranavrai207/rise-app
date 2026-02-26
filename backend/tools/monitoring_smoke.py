from __future__ import annotations

import os
import sys
from datetime import UTC, datetime
from pathlib import Path

# Configure aggressive rate limits for smoke verification before app import.
os.environ.setdefault("RATE_LIMIT_REQUESTS", "2")
os.environ.setdefault("RATE_LIMIT_WINDOW_SECONDS", "60")
os.environ.setdefault("ENV", "dev")
os.environ.setdefault("DEBUG", "false")

backend_root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(backend_root))
evidence_dir = backend_root.parent / "docs" / "operations" / "evidence"
evidence_dir.mkdir(parents=True, exist_ok=True)
smoke_db = evidence_dir / "monitoring_smoke.db"
if smoke_db.exists():
    smoke_db.unlink()
os.environ.setdefault("DATABASE_URL", f"sqlite:///{smoke_db.as_posix()}")

from fastapi.testclient import TestClient

from app.db.base import Base
from app.db.session import SessionLocal
from app.db.session import engine
from app.main import app
from app.models.entities import AuditLog


def main() -> int:
    Base.metadata.create_all(bind=engine)

    with TestClient(app, raise_server_exceptions=False) as client:
        # Trigger login failure event.
        bad_login = client.post(
            "/api/v1/auth/login",
            json={"email": "nobody@example.com", "password": "WrongPass123"},
        )
        if bad_login.status_code != 401:
            print("Expected 401 for bad login")
            return 1

        # Trigger rate-limit block event.
        for _ in range(5):
            client.get("/api/v1/health")

    db = SessionLocal()
    try:
        event_types = {row.event_type for row in db.query(AuditLog).all()}
    finally:
        db.close()

    required = {"auth_login_failed", "rate_limit_blocked"}
    missing = required - event_types
    if missing:
        print(f"Missing monitoring events: {sorted(missing)}")
        return 1

    report = evidence_dir / "monitoring_smoke_result.txt"
    report.write_text(
        f"timestamp_utc={datetime.now(UTC).isoformat()}\n"
        "result=pass\n"
        f"audit_event_types={','.join(sorted(event_types))}\n"
        f"required_events={','.join(sorted(required))}\n",
        encoding="utf-8",
    )

    print("Monitoring smoke passed: required audit events observed.")
    print(f"Evidence: {report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
