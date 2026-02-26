# Execution Rules

## Quick Rules
- Follow Secure Vibe Coding Handbook v1.0.
- Operate phase-by-phase only.
- Do not exceed scope.
- Use simple language.
- Reference repository files only.
- Update `docs/operations/STATUS.md` after each task.
- Do not assume missing information. Ask if unclear.

## Purpose
Define non-negotiable execution rules for building and operating this project.

## Rule 1 - Source of Truth
- Product scope comes from `docs/strategy/PRD.md`.
- Security standards come from `docs/Secure_Vibe_Coding_Handbook.md`.
- Delivery mapping comes from `docs/strategy/HANDBOOK_PLAYBOOK.md`.
- Phasing comes from `docs/strategy/IMPLEMENTATION_PLAN.md`.

## Rule 2 - Security Gate
- No feature ships unless handbook security controls are applied.
- If feature requirements conflict with security requirements, security requirements win unless an explicit documented exception is approved.

## Rule 3 - Backend Authority
- Progression logic (Chakra, Vitality, Aura) is server-authoritative.
- Never trust client-calculated stats or completion claims without server validation.

## Rule 4 - Secrets and Config
- No secrets in code, commits, logs, or screenshots.
- Use environment variables and managed secret storage only.
- Production must run with secure config: HTTPS, strict CORS, no debug flags.

## Rule 5 - Data Protection
- Store only necessary data.
- Protect sensitive data in transit and at rest.
- Avoid logging sensitive values (passwords, tokens, personal data).

## Rule 6 - Engineering Quality
- Every change must include tests appropriate to the layer (API/service/UI).
- Migrations are required for schema changes.
- Use code review for all non-trivial changes.

## Rule 7 - Operational Readiness
- Monitoring and alerting must exist for auth abuse, failures, and unusual traffic.
- Backups must be automated and restore-tested.
- Release is blocked if recovery steps are unverified.

## Rule 8 - Change Tracking
- Update `docs/operations/STATUS.md` after each work session.
- Append meaningful updates to `docs/operations/CHANGELOG.md` for adds/changes/fixes.

## Rule 9 - Definition of Done
A phase or feature is done only when:
- PRD acceptance intent is met.
- Security checks pass.
- Tests pass.
- Documentation is updated (status + changelog).

## Rule 10 - Execution Order
Follow this order unless explicitly overridden:
1. Plan against PRD and Implementation Plan
2. Implement backend contracts and validations
3. Implement Flutter integration and UI
4. Run security audit prompts and remediate findings
5. Update operational docs and prepare release
