# Security Audit Checkpoint (Prompt 3/4)

Date: 2026-02-24
Scope: FastAPI backend + Flutter API integration

## High-Risk Findings Remediated

1. Refresh token could mint access token for deleted user
- Status: Fixed
- Remediation: refresh flow now verifies subject user exists before issuing access token.

2. Inconsistent error payloads across API failures
- Status: Fixed
- Remediation: centralized exception handlers now return consistent `{"code","message"}` schema for HTTP/validation/unexpected errors.

3. Missing response security headers
- Status: Fixed
- Remediation: security headers middleware added (nosniff, frame deny, referrer policy, etc.).

4. Overly permissive quest status updates
- Status: Fixed
- Remediation: quest status now strict allow-list (`active`, `done`, `paused`).

## Medium-Risk Findings Remediated

1. Limited auditability of sensitive transitions
- Status: Improved
- Remediation: structured audit logs added for auth success, quest create/update, progression recompute.

2. Production config safety checks were weak
- Status: Improved
- Remediation: env validator blocks weak/default JWT secret and wildcard CORS in non-dev envs.

## Residual Risks (Open)

1. SQLite default remains for local/dev; staging PostgreSQL parity checks not complete.
2. Auth/session failure audit events (failed login/refresh failures/rate-limit triggers) not fully logged yet.
3. Flutter offline fallback still favors continuity over strict backend consistency under some error cases.

## Evidence
- Backend tests: `python -m pytest -q` => `12 passed`
- Flutter static checks: `flutter analyze` => no issues
