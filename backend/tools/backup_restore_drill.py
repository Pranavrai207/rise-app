from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path

from sqlalchemy import create_engine, text


def row_count(db_path: Path, table: str) -> int:
    engine = create_engine(f"sqlite:///{db_path.as_posix()}")
    with engine.connect() as conn:
        value = conn.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar_one()
    return int(value)


def main() -> int:
    work_dir = Path(__file__).resolve().parents[2] / "docs" / "operations" / "evidence"
    work_dir.mkdir(parents=True, exist_ok=True)

    source_db = work_dir / "backup_drill_source.db"
    backup_db = work_dir / "backup_drill_backup.db"
    restored_db = work_dir / "backup_drill_restored.db"

    for path in (source_db, backup_db, restored_db):
        if path.exists():
            path.unlink()

    engine = create_engine(f"sqlite:///{source_db.as_posix()}")
    with engine.begin() as conn:
        conn.execute(text("CREATE TABLE sample_events (id INTEGER PRIMARY KEY AUTOINCREMENT, kind TEXT NOT NULL)"))
        conn.execute(text("INSERT INTO sample_events(kind) VALUES ('alpha'), ('beta'), ('gamma')"))

    source_engine = create_engine(f"sqlite:///{source_db.as_posix()}")
    backup_engine = create_engine(f"sqlite:///{backup_db.as_posix()}")
    with source_engine.connect() as src, backup_engine.connect() as dst:
        src.connection.driver_connection.backup(dst.connection.driver_connection)

    backup_engine2 = create_engine(f"sqlite:///{backup_db.as_posix()}")
    restore_engine = create_engine(f"sqlite:///{restored_db.as_posix()}")
    with backup_engine2.connect() as src, restore_engine.connect() as dst:
        src.connection.driver_connection.backup(dst.connection.driver_connection)

    src_count = row_count(source_db, "sample_events")
    restored_count = row_count(restored_db, "sample_events")

    if src_count != restored_count:
        print("Backup/restore drill failed: row counts differ")
        return 1

    report = work_dir / "backup_restore_drill_result.txt"
    report.write_text(
        f"timestamp_utc={datetime.now(UTC).isoformat()}\n"
        f"source_rows={src_count}\n"
        f"restored_rows={restored_count}\n"
        "result=pass\n",
        encoding="utf-8",
    )

    print(f"Backup/restore drill passed. Evidence: {report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
