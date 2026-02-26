import os
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config

TEST_DB_PATH = Path(__file__).resolve().parent / "test_secure_vibe.db"
BACKEND_ROOT = Path(__file__).resolve().parents[1]
ALEMBIC_INI_PATH = BACKEND_ROOT / "alembic.ini"

os.environ["DATABASE_URL"] = f"sqlite:///{TEST_DB_PATH.as_posix()}"


@pytest.fixture(scope="session", autouse=True)
def migrated_test_db() -> None:
    if TEST_DB_PATH.exists():
        TEST_DB_PATH.unlink()

    alembic_cfg = Config(str(ALEMBIC_INI_PATH))
    alembic_cfg.set_main_option("script_location", str(BACKEND_ROOT / "alembic"))
    alembic_cfg.set_main_option("sqlalchemy.url", os.environ["DATABASE_URL"])

    command.upgrade(alembic_cfg, "head")
    yield
