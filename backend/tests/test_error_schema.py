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


def test_error_schema_for_not_found() -> None:
    with TestClient(app) as client:
        headers = _auth_headers(client, "error-schema@example.com")
        response = client.patch(
            "/api/v1/habits/does-not-exist/completion",
            headers=headers,
            json={"completed": True},
        )
        assert response.status_code == 404
        payload = response.json()
        assert payload["code"] == "not_found"
        assert isinstance(payload["message"], str)


def test_error_schema_for_validation_error() -> None:
    with TestClient(app) as client:
        response = client.post(
            "/api/v1/auth/login",
            json={"email": "invalid-email", "password": "short"},
        )
        assert response.status_code == 422
        payload = response.json()
        assert payload["code"] == "validation_error"
        assert payload["message"] == "Invalid request payload."
