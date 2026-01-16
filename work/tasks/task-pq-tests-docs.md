# Task: Add PQ tests and docs

## Description
- Add automated checks for PQ CRUD across API and web layers, and document the flows and commands to run them locally/CI.
- Include API tests for happy paths, validation failures, and auth/ownership errors; add web component or e2e-lite coverage for the form.
- Prefer tests that do not require Docker inside the Dev Container. If we need Postgres-backed integration coverage, document how to run it from the host Compose stack.

## Linked stories
- [ ] ../stories/story-pq-hardening.md

## Definition of done
- [ ] API test suite covers create/read/update/delete and failure cases with fixtures for PII handling.
- [ ] Web tests cover form validation and API error surfacing.
- [ ] README/WORK notes how to run these checks via module commands (and `scripts/ci/` if added).
- [ ] Tests are green in local dev container.

## Status
- Status: in-progress
- Owner: TBD
