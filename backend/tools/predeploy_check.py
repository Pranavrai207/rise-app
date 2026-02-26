from __future__ import annotations

import os
import sys


def _fail(message: str) -> None:
    print(f"[FAIL] {message}")
    raise SystemExit(1)


def _ok(message: str) -> None:
    print(f"[OK] {message}")


def main() -> None:
    env = os.getenv("ENV", "dev").strip().lower()
    debug = os.getenv("DEBUG", "false").strip().lower() == "true"
    database_url = os.getenv("DATABASE_URL", "").strip()
    jwt_secret = os.getenv("JWT_SECRET_KEY", "")
    cors_origins = os.getenv("CORS_ORIGINS", "")
    require_https = os.getenv("REQUIRE_HTTPS", "false").strip().lower() == "true"

    print(f"Predeploy check for ENV={env}")

    if env not in {"staging", "prod", "production"}:
        _fail("ENV must be staging/prod/production for predeploy checks.")
    _ok("Environment mode is deploy-targeted.")

    if debug:
        _fail("DEBUG must be false.")
    _ok("DEBUG disabled.")

    if not database_url or database_url.startswith("sqlite"):
        _fail("DATABASE_URL must point to PostgreSQL.")
    _ok("Database URL is non-sqlite.")

    if len(jwt_secret) < 32 or jwt_secret in {"replace_me_with_64_plus_char_secret", "unsafe-dev-secret"}:
        _fail("JWT_SECRET_KEY must be at least 32 chars and non-placeholder.")
    _ok("JWT secret strength check passed.")

    if "*" in cors_origins:
        _fail("CORS_ORIGINS cannot contain '*'.")
    _ok("CORS origin wildcard check passed.")

    if not require_https:
        _fail("REQUIRE_HTTPS must be true.")
    _ok("HTTPS requirement enabled.")

    print("Predeploy checks passed.")


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception as exc:  # pragma: no cover
        print(f"[FAIL] Unexpected error: {exc}")
        sys.exit(1)
