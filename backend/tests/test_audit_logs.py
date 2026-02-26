from fastapi.testclient import TestClient

from app.db.session import SessionLocal
from app.main import app
from app.models.entities import AuditLog


def _auth_headers(client: TestClient, email: str) -> dict[str, str]:
    register = client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": "StrongPass123"},
    )
    assert register.status_code == 201

    login = client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "StrongPass123"},
    )
    assert login.status_code == 200
    token = login.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_audit_logs_for_quest_and_progression_events() -> None:
    with TestClient(app) as client:
        register = client.post(
            "/api/v1/auth/register",
            json={"email": "audit-user@example.com", "password": "StrongPass123"},
        )
        assert register.status_code == 201

        login = client.post(
            "/api/v1/auth/login",
            json={"email": "audit-user@example.com", "password": "StrongPass123"},
        )
        assert login.status_code == 200
        tokens = login.json()
        headers = {"Authorization": f"Bearer {tokens['access_token']}"}

        create_quest = client.post(
            "/api/v1/quests",
            headers=headers,
            json={"title": "Audit Quest", "notes": "Track me"},
        )
        assert create_quest.status_code == 201
        quest_id = create_quest.json()["id"]

        update_quest = client.patch(
            f"/api/v1/quests/{quest_id}",
            headers=headers,
            json={"status": "done"},
        )
        assert update_quest.status_code == 200

        create_habit = client.post(
            "/api/v1/habits",
            headers=headers,
            json={
                "title": "Audit Habit",
                "description": "Meditate",
                "type": "CHAKRA",
                "schedule": "ONE_OFF",
            },
        )
        assert create_habit.status_code == 201
        habit_id = create_habit.json()["id"]

        completion = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": True},
        )
        assert completion.status_code == 200

        refresh = client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": tokens["refresh_token"]},
        )
        assert refresh.status_code == 200

    db = SessionLocal()
    try:
        logs = db.query(AuditLog).all()
        event_types = {item.event_type for item in logs}
        assert "auth_register_success" in event_types
        assert "auth_login_success" in event_types
        assert "auth_refresh_success" in event_types
        assert "quest_created" in event_types
        assert "quest_updated" in event_types
        assert "progression_recomputed" in event_types
    finally:
        db.close()


def test_audit_logs_capture_auth_failures() -> None:
    with TestClient(app) as client:
        register = client.post(
            "/api/v1/auth/register",
            json={"email": "audit-fail@example.com", "password": "StrongPass123"},
        )
        assert register.status_code == 201

        bad_login = client.post(
            "/api/v1/auth/login",
            json={"email": "audit-fail@example.com", "password": "WrongPass123"},
        )
        assert bad_login.status_code == 401

        bad_refresh = client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": "invalid.token.value"},
        )
        assert bad_refresh.status_code == 401

    db = SessionLocal()
    try:
        logs = db.query(AuditLog).all()
        event_types = {item.event_type for item in logs}
        assert "auth_login_failed" in event_types
        assert "auth_refresh_failed" in event_types
    finally:
        db.close()
