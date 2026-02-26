# Handbook Playbook

## Purpose
This playbook maps `PRD.md` requirements to `Secure_Vibe_Coding_Handbook.md` controls and prompts, then defines how to execute delivery safely.

## PRD to Handbook Mapping

| PRD Item | Delivery Intent | Handbook Mapping | Build Notes |
|---|---|---|---|
| Habit-RPG concept | Gamified self-improvement system with reliable progression | Section 2 - Prompt 1 (PRD features + domain models), Prompt 2 (server-side stat validation), Section 1 (Data Protection, Auth vs Authorization) | Keep progression logic authoritative on FastAPI; Flutter only renders state. |
| Metaphysical Progression (Chakra/Vitality) | Deterministic, abuse-resistant stat engine | Prompt 1 (Chakra/Vitality), Prompt 2 (never trust client-calculated stats), Post-Generation Audit (authorization/injection checks) | Store progression updates with audit trails and timestamps. |
| Habit Dashboard (daily/recurring/one-off) | Stable CRUD + completion flows | Prompt 1 (domain models: Habit, Completion), Section 1 (Zero Trust Input, Output Escaping), Prompt 2 (input validation, parameterized queries) | Validate habit schedule rules server-side; sanitize labels/notes. |
| Dynamic Avatar (Aura) | Visual state linked to real completions | Prompt 1 (dynamic Aura avatar), Prompt 2 (server-side progression validation), Section 1 (Logging Safety) | Compute Aura from trusted completion data, not client claims. |
| Flutter frontend | Secure mobile app UX | Prompt 1 (Flutter iOS/Android), Prompt 2 (secure mobile token storage), Section 1 (Production Readiness) | Use secure storage for tokens; disable debug in release builds. |
| FastAPI backend | Secure API and business logic | Prompt 1 (auth + rate limiting + schema/indexes), Prompt 2 (server authz, secure headers, HTTPS), Section 1 (Least Privilege) | Enforce RBAC and endpoint-level authorization checks. |
| PostgreSQL database | Durable relational persistence | Prompt 1 (migration-ready schema/indexes), Prompt 2 (parameterized queries, minimal PII), Section 1 (Data Protection) | Encrypt sensitive fields where needed; avoid unnecessary data retention. |

## Execution Playbook

### Phase 1 - Foundation
- Use Prompt 1 to scaffold Flutter + FastAPI + PostgreSQL with clean architecture.
- Create baseline entities: `User`, `Habit`, `Completion`, `Stats`, `Quest`, `AvatarState`.
- Add migrations and indexes for frequent reads/writes (habits, completions, progression timelines).

### Phase 2 - Security Controls
- Apply Section 1 Core Rules as non-negotiable coding standards.
- Enforce JWT authn + server-side authz on every protected endpoint.
- Add rate limiting, secure headers, strict input validation, and parameterized DB access.
- Implement secure secret handling (env vars only) and redacted structured logging.

### Phase 3 - Product Logic
- Implement Chakra/Vitality progression formulas in backend services.
- Implement habit lifecycle (create/update/archive/complete) for daily, recurring, and one-off habits.
- Drive Avatar/Aura state from validated completion events and progression engine outputs.

### Phase 4 - Verification
- Run Prompt 3 (Post-Generation Audit) and fix all high/critical findings.
- Run Bonus Anti-Exposure Prompt and remove secret/config leaks.
- Execute Prompt 4 (Pre-Deployment Check) to validate launch risks.

### Phase 5 - Release Readiness
- Confirm handbook Pre-Launch Checklist is fully green.
- Ensure backup/restore drill is tested and monitoring alerts are active.
- Freeze production config (no debug flags, strict CORS, HTTPS only).

## Definition of Done
- All PRD core features are implemented and mapped to handbook controls.
- No hardcoded secrets; auth/authz and anti-abuse controls are enforced.
- Security audit issues are remediated or explicitly accepted with rationale.
- Monitoring, backup, and recovery paths are tested before release.

## Operating Rule
If a feature request conflicts with handbook security rules, security rules win unless a documented exception is approved.
