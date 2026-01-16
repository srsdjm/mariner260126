# Task: Build web form for PQ management

## Description
- Create a web client flow for prospects to create, edit, and delete their PQ record using the API.
- Use MUI + React Hook Form + Zod for input and inline validation; integrate the generated API client and show problem+json errors from the server.

## Linked stories
- [ ] ../stories/story-consumer-pq-crud.md

## Definition of done
- [ ] Form captures first_name, last_name, dob, ssn with client-side validation matching server rules.
- [ ] Uses API client for create/update/delete; handles loading/error states and success confirmation.
- [ ] SSN is masked/obscured on display; no sensitive values persist in client state longer than needed.
- [ ] Basic component tests cover validation + submission flows.

## Status
- Status: done
- Owner: TBD
