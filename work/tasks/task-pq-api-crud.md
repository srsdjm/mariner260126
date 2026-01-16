# Task: Implement PQ CRUD API

## Description
- Add Ktor routes for create/read/update/delete of a PQ resource bound to the authenticated prospect.
- Include request/response schemas (first_name, last_name, dob, ssn), validation (format, required fields, SSN normalization), problem+json error handling, and structured logging/trace IDs.
- Enforce authorization so a prospect can manage only their own PQ record; integrate with persistence layer from migrations.

## Linked stories
- [ ] ../stories/story-consumer-pq-crud.md

## Definition of done
- [ ] API routes exist with OpenAPI entries and validation for all fields.
- [ ] SSN/DOB handling aligns with PII storage (no plaintext in responses; minimal echoing).
- [ ] Authorization and ownership checks covered; unauthorized/forbidden cases return problem+json.
- [ ] Happy path and validation failures verified via automated tests or request scripts.

## Status
- Status: done
- Owner: TBD
