Secure Vibe Coding Handbook - v1.0

## Section 1 - Security Mindset Framework
Your universal safe coding framework.

### Core Rules
- Secrets Rule: Keep credentials outside source code and never expose them publicly.
- Zero Trust Input: Treat every user input as potentially harmful and validate strictly.
- Auth vs Authorization: Verify identity first, then enforce allowed actions.
- Data Protection: Store only necessary data and protect it with encryption and secure storage.
- Least Privilege: Grant only the minimum access required.
- Dependency Hygiene: Use trusted, maintained libraries and scan for vulnerabilities.
- Output Escaping: Handle output safely to prevent injection attacks.
- Logging Safety: Never log passwords, tokens, or personal data.
- Rate Limiting: Restrict repeated access attempts to reduce abuse and brute-force attacks.
- Production Readiness: Disable dev settings and verify secure configuration before deployment.

### Monitoring and Incident Detection Rule
Continuously observe system behavior to detect misuse or unusual activity early.
- Centralized logs
- Failed login tracking
- Unusual traffic pattern detection
- Alerts for suspicious activity
- Error tracking

### Backup and Recovery Rule
Maintain tested backups so data and systems can be restored after failure.
- Automated regular backups
- Verified restore testing
- Safe rollback capability
- Clear recovery plan

### Configuration Hardening Rule
Secure system settings and infrastructure to remove default or unsafe configurations.
- Remove default usernames and passwords
- Close unnecessary open ports
- Use secure server settings
- Enforce HTTPS
- Restrict CORS carefully
- Disable unused services

## Section 2 - Prompt Library

### 1) Master Base Prompt
Build a production-ready Flutter mobile app (iOS/Android) with a FastAPI backend and PostgreSQL database using clean architecture, modular structure, and scalability.

Requirements:
- Follow industry best practices
- Implement PRD features: Chakra and Vitality progression, habit dashboard (daily/recurring/one-off), and dynamic Aura avatar updates
- Define clear domain models: User, Habit, Completion, Stats, Quest, AvatarState
- Use environment variables for all secrets
- Implement authentication and authorization (JWT access + refresh tokens)
- Validate and sanitize all user inputs
- Enforce server-side progression rules to prevent stat manipulation and cheating
- Prevent common vulnerabilities (SQL injection, injection attacks, broken access control, token abuse, replay abuse)
- Use secure password hashing
- Implement rate limiting where appropriate
- Use secure token storage on device (Keychain/Keystore via secure storage)
- Do not hardcode secrets
- Follow OWASP guidelines
- Apply least privilege
- Provide structured folder architecture
- Add migration-ready database schema and indexes for habits, completions, and progression queries
- Implement secure error handling and logging (no sensitive exposure)
- Add monitoring, alerts, backup and recovery readiness

After generating code, perform a security audit.

### 2) Strict Security Enforcement Prompt
Generate this Flutter + FastAPI + PostgreSQL habit-RPG system as if it will handle real production traffic and sensitive user data immediately.

Security requirements:
- No secrets in source code
- Strict input validation
- Parameterized database queries only
- Server-side authorization enforcement
- HTTPS-only communication
- Secure headers implementation
- No sensitive data in logs
- Role-based access control
- Rate limiting and abuse prevention
- Minimal data storage (no unnecessary PII)
- Secure mobile credential/token storage and session handling
- Server-side validation for all progression/stat updates (never trust client-calculated stats)
- Audit trails for progression, quest completion, and privileged actions
- Monitoring and alerting for suspicious activity
- Backup and recovery strategy
- Secure production configuration (no debug flags, restricted ports, strict CORS)

Then perform a full security audit and list risks with recommended improvements.

### 3) Post-Generation Audit Prompt
Act as a senior security engineer conducting a production audit.
Review for:
- Data exposure risks
- Authentication bypass possibilities
- Authorization flaws
- Injection vulnerabilities
- Hardcoded secrets
- Weak encryption practices
- Logging leaks
- Dependency vulnerabilities
- Production misconfiguration

Clearly list issues and remediation steps.

### 4) Pre-Deployment Check Prompt
Assume this application launches tomorrow with 10,000 users.
Identify security risks that could cause:
- Data breaches
- API abuse
- Privilege escalation
- Financial loss
- Account takeover
- Backup and restore failures
- Monitoring and alerting gaps
- Configuration hardening risks
- Incident response gaps

Recommend improvements to make the system production-resilient.

### Bonus Anti-Exposure Prompt
Check this project for:
- Secrets exposure
- Env misconfiguration
- Debug flags left enabled
- Verbose error messages
- Unsafe CORS configuration
- Open admin endpoints
- Missing authentication middleware

## Section 3 - Deployment and Operational Discipline
- Automated Scans: Continuously check code and dependencies for known vulnerabilities.
- Secret Scanning: Detect exposed API keys, passwords, or tokens before release.
- Threat Modeling: Identify attack scenarios before building features.
- Backup Plan: Maintain reliable, tested backups for restoration.
- Monitoring: Observe system behavior for errors, abuse, and suspicious activity.
- Security Loop: Build -> Secure -> Audit -> Scan -> Deploy -> Monitor.

## Why This Is Powerful
You get one document, one system, and one repeatable process.
This becomes your personal engineering playbook.

## Pre-Launch Checklist
Before every deployment confirm:
- No hardcoded secrets
- Env configured correctly
- Inputs validated
- Authentication and authorization verified
- Logs sanitized
- Dependencies scanned
- HTTPS enabled
- Debug disabled
- Backups tested
