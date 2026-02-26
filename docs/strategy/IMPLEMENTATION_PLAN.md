# Implementation Plan

## Scope
Build a habit-tracking RPG app with Chakra/Vitality progression, habit dashboard, and dynamic Aura avatar.
Stack: Flutter (mobile), FastAPI (backend), PostgreSQL (database).

## Phase 0 - Project Setup
- Finalize PRD and handbook alignment
- Initialize repositories and folder structure
- Configure environments (`dev`, `staging`, `prod`)
- Set coding standards, branch strategy, and CI checks

Deliverables:
- Project skeleton (Flutter + FastAPI)
- `.env.example` templates
- CI pipeline with lint/test/security scan hooks

## Phase 1 - Core Backend Foundation
- Set up FastAPI app structure (routers, services, models, auth)
- Add PostgreSQL schema + migrations
- Implement authentication (JWT access + refresh)
- Add authorization middleware and role checks
- Add base observability (structured logs, error handling)

Deliverables:
- Working auth endpoints
- DB migrations for `User`, `Habit`, `Completion`, `Stats`, `Quest`, `AvatarState`
- Protected API baseline

## Phase 2 - Habit System (MVP)
- Implement habit CRUD
- Support daily, recurring, and one-off habits
- Implement habit completion flow
- Add validation and anti-abuse checks

Deliverables:
- Habit endpoints + tests
- Completion endpoints + tests
- Rate limiting on write-heavy endpoints

## Phase 3 - RPG Progression Engine (MVP)
- Implement Chakra/Vitality rules in backend
- Compute progression from trusted completion events
- Implement Aura state calculation for avatar
- Add audit trail for progression changes

Deliverables:
- Progression service + tests
- Aura state API
- Audit log records for stat changes

## Phase 4 - Flutter App (MVP)
- Implement auth screens and secure session storage
- Build habit dashboard UI (daily/recurring/one-off)
- Add completion actions and progression views
- Render avatar/Aura state from backend data

Deliverables:
- Mobile flows for signup/login/habits/completions
- Profile/progression screen
- Stable API integration layer

## Phase 5 - Security, Hardening, and Launch Readiness
- Run handbook Prompt 3 audit and remediate findings
- Run anti-exposure checks (secrets, debug flags, CORS, logs)
- Verify backup/restore, monitoring, and alerts
- Final pre-deployment checklist

Deliverables:
- Security audit report and fixes
- Production config checklist marked complete
- Release candidate build

## Exit Criteria
- All PRD core features implemented
- No critical/high security findings unresolved
- Monitoring + backup/restore validated
- MVP release approved
