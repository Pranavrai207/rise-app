from fastapi.testclient import TestClient

from app.main import app


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


def test_progression_defaults_to_zero_when_no_completions() -> None:
    with TestClient(app) as client:
        headers = _auth_headers(client, "edge-zero@example.com")
        response = client.get("/api/v1/progression/me", headers=headers)
        assert response.status_code == 200
        payload = response.json()
        assert payload["stats"]["chakra_xp"] == 0
        assert payload["stats"]["vitality_xp"] == 0
        assert payload["stats"]["focus_xp"] == 0
        assert payload["avatar"]["aura_level"] == 0
        assert payload["avatar"]["aura_label"] == "Dormant"


def test_progression_reaches_transcendent_at_high_xp() -> None:
    with TestClient(app) as client:
        headers = _auth_headers(client, "edge-high@example.com")

        for i in range(10):
            create_habit = client.post(
                "/api/v1/habits",
                headers=headers,
                json={
                    "title": f"High XP Habit {i}",
                    "description": "Level up quickly",
                    "type": "CHAKRA",
                    "schedule": "ONE_OFF",
                },
            )
            assert create_habit.status_code == 201
            habit_id = create_habit.json()["id"]

            complete = client.patch(
                f"/api/v1/habits/{habit_id}/completion",
                headers=headers,
                json={"completed": True},
            )
            assert complete.status_code == 200

        progression = client.get("/api/v1/progression/me", headers=headers)
        assert progression.status_code == 200
        payload = progression.json()
        assert payload["stats"]["chakra_xp"] == 1200
        assert payload["avatar"]["aura_level"] == 3
        assert payload["avatar"]["aura_label"] == "Transcendent"
