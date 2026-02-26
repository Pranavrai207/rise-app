# Backend Runbook

## Local setup

1. Install dependencies:
```bash
python -m pip install -r requirements.txt
```

2. Create `.env` from `.env.example` and set required values.

## Database migrations (source of truth)

1. Apply latest migrations:
```bash
python -m alembic upgrade head
```

2. Create a new migration revision:
```bash
python -m alembic revision -m "describe change"
```

3. Downgrade one revision:
```bash
python -m alembic downgrade -1
```

## Run API

```bash
python -m uvicorn app.main:app --reload
```

## Run tests

```bash
python -m pytest -q
```

Note: tests create an isolated SQLite DB and apply Alembic migrations before executing.

## Predeploy checks (staging/prod)

```bash
python backend/tools/predeploy_check.py
```

Expected usage:
- Load staging/prod environment variables first.
- Script exits non-zero if critical deploy safety checks fail.
