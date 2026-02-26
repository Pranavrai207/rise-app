from fastapi.testclient import TestClient

from app.db.session import SessionLocal
from app.main import app
from app.models.entities import User


def test_auth_and_habit_flow() -> None:
    with TestClient(app) as client:
        register_response = client.post(
            "/api/v1/auth/register",
            json={"email": "agent@example.com", "password": "StrongPass123"},
        )
        assert register_response.status_code == 201

        login_response = client.post(
            "/api/v1/auth/login",
            json={"email": "agent@example.com", "password": "StrongPass123"},
        )
        assert login_response.status_code == 200
        tokens = login_response.json()
        assert "access_token" in tokens
        assert "refresh_token" in tokens

        headers = {"Authorization": f"Bearer {tokens['access_token']}"}

        chakra_habit_response = client.post(
            "/api/v1/habits",
            headers=headers,
            json={
                "title": "Deep Meditation",
                "description": "Expand the mind",
                "type": "CHAKRA",
                "schedule": "DAILY",
            },
        )
        assert chakra_habit_response.status_code == 201
        chakra_habit = chakra_habit_response.json()

        vitality_habit_response = client.post(
            "/api/v1/habits",
            headers=headers,
            json={
                "title": "Physical Training",
                "description": "Strengthen the body",
                "type": "VITALITY",
                "schedule": "DAILY",
            },
        )
        assert vitality_habit_response.status_code == 201
        vitality_habit = vitality_habit_response.json()

        completion_response = client.patch(
            f"/api/v1/habits/{chakra_habit['id']}/completion",
            headers=headers,
            json={"completed": True},
        )
        assert completion_response.status_code == 200
        assert completion_response.json()["completed"] is True

        second_completion_response = client.patch(
            f"/api/v1/habits/{vitality_habit['id']}/completion",
            headers=headers,
            json={"completed": True},
        )
        assert second_completion_response.status_code == 200

        progression_response = client.get("/api/v1/progression/me", headers=headers)
        assert progression_response.status_code == 200
        progression = progression_response.json()
        assert progression["stats"]["chakra_xp"] == 120
        assert progression["stats"]["vitality_xp"] == 120
        assert progression["stats"]["focus_xp"] == 0
        assert progression["avatar"]["aura_level"] == 1
        assert progression["avatar"]["aura_label"] == "Stirring"

        me_response = client.get("/api/v1/auth/me", headers=headers)
        assert me_response.status_code == 200

        refresh_response = client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": tokens["refresh_token"]},
        )
        assert refresh_response.status_code == 200
        assert "access_token" in refresh_response.json()


def test_refresh_fails_if_user_deleted() -> None:
    with TestClient(app) as client:
        register_response = client.post(
            "/api/v1/auth/register",
            json={"email": "refresh-delete@example.com", "password": "StrongPass123"},
        )
        assert register_response.status_code == 201

        login_response = client.post(
            "/api/v1/auth/login",
            json={"email": "refresh-delete@example.com", "password": "StrongPass123"},
        )
        assert login_response.status_code == 200
        refresh_token = login_response.json()["refresh_token"]

    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == "refresh-delete@example.com").first()
        assert user is not None
        db.delete(user)
        db.commit()
    finally:
        db.close()

    with TestClient(app) as client:
        refresh_response = client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": refresh_token},
        )
        assert refresh_response.status_code == 401
