# Story: PQ CRUD hardening

## User value
- As a prospect, I want my PQ record protected by real authentication and backed by automated checks so the system is trustworthy.

## Narrative
- Replace the stubbed prospect identity with Auth0 identity, enforce ownership everywhere, and add automated coverage for CRUD and error paths.

## Acceptance criteria
- [ ] PQ routes derive the prospect identity from auth context (no stub constant).
- [ ] Ownership checks are enforced across create/read/update/delete with problem+json errors for unauthorized access.
- [ ] Automated checks cover validation, happy-path CRUD, and unauthorized access attempts.
- [ ] Documentation notes how to run these checks locally and in CI.

## Tasks
- [ ] ../tasks/task-pq-tests-docs.md
- [ ] ../tasks/task-pq-auth-owner.md

## Status
- Status: ready
- Owner: TBD
