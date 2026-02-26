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


def test_quest_crud_and_ownership_profile_view() -> None:
    with TestClient(app) as client:
        headers_a = _auth_headers(client, "quest-owner@example.com")
        headers_b = _auth_headers(client, "quest-other@example.com")

        create_quest = client.post(
            "/api/v1/quests",
            headers=headers_a,
            json={"title": "First Quest", "notes": "Start now"},
        )
        assert create_quest.status_code == 201
        quest = create_quest.json()
        assert quest["status"] == "active"

        list_quests = client.get("/api/v1/quests", headers=headers_a)
        assert list_quests.status_code == 200
        assert len(list_quests.json()) == 1

        forbidden_update = client.patch(
            f"/api/v1/quests/{quest['id']}",
            headers=headers_b,
            json={"status": "done"},
        )
        assert forbidden_update.status_code == 404

        owner_update = client.patch(
            f"/api/v1/quests/{quest['id']}",
            headers=headers_a,
            json={"status": "done", "notes": "Completed"},
        )
        assert owner_update.status_code == 200
        assert owner_update.json()["status"] == "done"

        invalid_status = client.patch(
            f"/api/v1/quests/{quest['id']}",
            headers=headers_a,
            json={"status": "hack"},
        )
        assert invalid_status.status_code == 422

        create_habit = client.post(
            "/api/v1/habits",
            headers=headers_a,
            json={
                "title": "Chakra Ritual",
                "description": "Meditate",
                "type": "CHAKRA",
                "schedule": "DAILY",
            },
        )
        assert create_habit.status_code == 201
        habit = create_habit.json()

        complete = client.patch(
            f"/api/v1/habits/{habit['id']}/completion",
            headers=headers_a,
            json={"completed": True},
        )
        assert complete.status_code == 200

        profile = client.get("/api/v1/profile/me", headers=headers_a)
        assert profile.status_code == 200
        payload = profile.json()
        assert payload["email"] == "quest-owner@example.com"
        assert payload["total_habits"] == 1
        assert payload["completed_habits"] == 1
        assert payload["chakra_xp"] == 120
        assert payload["aura_label"] in {"Dormant", "Stirring", "Radiant", "Transcendent"}
