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


def test_daily_habit_blocks_second_completion_same_day() -> None:
    with TestClient(app) as client:
        headers = _auth_headers(client, "daily-policy@example.com")
        create = client.post(
            "/api/v1/habits",
            headers=headers,
            json={
                "title": "Daily Focus",
                "description": "One win a day",
                "type": "FOCUS",
                "schedule": "DAILY",
            },
        )
        assert create.status_code == 201
        habit_id = create.json()["id"]

        first_complete = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": True},
        )
        assert first_complete.status_code == 200

        uncheck = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": False},
        )
        assert uncheck.status_code == 200

        second_complete = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": True},
        )
        assert second_complete.status_code == 409


def test_one_off_habit_blocks_repeat_completion() -> None:
    with TestClient(app) as client:
        headers = _auth_headers(client, "oneoff-policy@example.com")
        create = client.post(
            "/api/v1/habits",
            headers=headers,
            json={
                "title": "Launch Day Ritual",
                "description": "Do once ever",
                "type": "CHAKRA",
                "schedule": "ONE_OFF",
            },
        )
        assert create.status_code == 201
        habit_id = create.json()["id"]

        first_complete = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": True},
        )
        assert first_complete.status_code == 200

        uncheck = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": False},
        )
        assert uncheck.status_code == 200

        second_complete = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": True},
        )
        assert second_complete.status_code == 409


def test_recurring_habit_blocks_completion_during_cooldown() -> None:
    with TestClient(app) as client:
        headers = _auth_headers(client, "recurring-policy@example.com")
        create = client.post(
            "/api/v1/habits",
            headers=headers,
            json={
                "title": "Breath Loop",
                "description": "Repeat in windows",
                "type": "VITALITY",
                "schedule": "RECURRING",
            },
        )
        assert create.status_code == 201
        habit_id = create.json()["id"]

        first_complete = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": True},
        )
        assert first_complete.status_code == 200

        uncheck = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": False},
        )
        assert uncheck.status_code == 200

        second_complete = client.patch(
            f"/api/v1/habits/{habit_id}/completion",
            headers=headers,
            json={"completed": True},
        )
        assert second_complete.status_code == 409
