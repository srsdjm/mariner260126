# Story: Consumer manages PQ record

## User value
- As a prospect, I want to create, update, and delete my PQ record (first name, last name, date of birth, SSN) so that I control my screening data before sharing it.

## Narrative
- A signed-in prospect uses the app to enter their core details and saves them to Mariner. They can edit those details later and delete the PQ entirely. API requests validate input, enforce ownership, and store sensitive fields using the chosen PII storage approach.
- Until Auth0 wiring lands (E2), prospect identity is stubbed (single fixed prospect) so we can iterate on the domain slice and UX.

## Acceptance criteria
- [ ] API supports create, update, get, and delete for a PQ resource with fields: first_name, last_name, dob (ISO date), ssn (normalized), returning stable IDs and problem+json errors for invalid requests.
- [ ] Data is persisted in Postgres with schema migration(s) applied; sensitive fields are protected per PII policy (encryption-ready storage, no plaintext SSN at rest).
- [ ] Requests are authenticated/authorized to the current prospect; until Auth0 wiring lands, a stub prospect identity is used and the API enforces ownership against that stub.
- [ ] Web client presents a form to submit/edit/delete the PQ; validation errors are shown inline using shared schema rules.

## Tasks
- [x] ../tasks/task-pq-migrations.md
- [x] ../tasks/task-pq-api-crud.md
- [x] ../tasks/task-pq-web-form.md

## Follow-ups
- ../stories/story-pq-hardening.md

## Status
- Status: done
- Owner: TBD
