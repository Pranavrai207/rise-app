from __future__ import annotations

import os
import subprocess
import tempfile
from datetime import UTC, datetime
from pathlib import Path


def main() -> int:
    env = os.environ.copy()
    env.setdefault("ENV", "staging")
    env.setdefault("DEBUG", "false")
    env.setdefault("REQUIRE_HTTPS", "true")
    env.setdefault("JWT_SECRET_KEY", "replace_with_64_plus_char_random_secret_value")
    env.setdefault("CORS_ORIGINS", "https://staging.securevibe.app")
    env.setdefault("DATABASE_URL", "postgresql+psycopg://secure_vibe:replace_me@staging-db:5432/secure_vibe")

    backend_root = Path(__file__).resolve().parents[1]
    alembic_ini = backend_root / "alembic.ini"
    evidence_dir = backend_root.parent / "docs" / "operations" / "evidence"
    evidence_dir.mkdir(parents=True, exist_ok=True)

    with tempfile.NamedTemporaryFile(delete=False, suffix=".sql") as tmp:
        sql_path = Path(tmp.name)

    cmd = [
        "python",
        "-m",
        "alembic",
        "-c",
        str(alembic_ini),
        "upgrade",
        "head",
        "--sql",
    ]

    with sql_path.open("w", encoding="utf-8") as out:
        result = subprocess.run(cmd, cwd=backend_root, env=env, stdout=out, stderr=subprocess.PIPE, text=True)

    if result.returncode != 0:
        print(result.stderr)
        return result.returncode

    sql_text = sql_path.read_text(encoding="utf-8")
    required_tokens = ["CREATE TABLE users", "CREATE TABLE habits", "CREATE TABLE audit_logs"]
    for token in required_tokens:
        if token not in sql_text:
            print(f"Missing expected migration SQL token: {token}")
            return 1

    report = evidence_dir / "postgres_parity_result.txt"
    report.write_text(
        f"timestamp_utc={datetime.now(UTC).isoformat()}\n"
        f"sql_output_path={sql_path}\n"
        f"required_tokens={','.join(required_tokens)}\n"
        "result=pass\n",
        encoding="utf-8",
    )

    print(f"PostgreSQL offline migration SQL generated: {sql_path}")
    print(f"Evidence: {report}")
    print("PostgreSQL parity static check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
