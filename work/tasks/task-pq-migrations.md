# Task: Add PQ persistence and migrations

## Description
- Create database schema/migration(s) for the PQ record (first_name, last_name, dob, ssn) with ownership linkage to the prospect identity.
- Implement Exposed/Flyway wiring so the API uses the migrated schema; ensure fields are indexed appropriately and SSN/DOB are stored using the agreed encryption/tokenization approach (no plaintext at rest).

## Linked stories
- [ ] ../stories/story-consumer-pq-crud.md

## Definition of done
- [ ] Migration(s) apply cleanly via Gradle and Compose startup; tables/columns exist as expected.
- [ ] Exposed models/repositories read/write PQ records with owner linkage.
- [ ] SSN/DOB are handled per PII storage guidance (encryption-ready; no plaintext persisted).
- [ ] README or module docs note how to run migrations locally.

## Status
- Status: done
- Owner: TBD
