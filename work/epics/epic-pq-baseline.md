# Epic: PQ CRUD Baseline

## Intent
- Deliver the first slice of prospect-owned data by enabling consumers to create, update, and delete their pre-qualification (PQ) record with core PII fields.

## Scope
- API persistence, validation, and error handling for PQ (first name, last name, DOB, SSN).
- Storage approach aligned to PII guidance (encryption-ready) with migrations and health checks.
- Web client flows to submit, edit, and delete the PQ record using the API contracts.
- Excludes broader PQ fields, screening integrations, or booking flows.

## Stories
- [x] ../stories/story-consumer-pq-crud.md

## Tasks (optional)
- [x] ../tasks/task-pq-migrations.md
- [x] ../tasks/task-pq-api-crud.md
- [x] ../tasks/task-pq-web-form.md

## Follow-ups
- ../epics/epic-pq-hardening.md

## Status
- Status: done
- Owner: TBD
- Target window: This iteration
