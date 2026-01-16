# Task: Wire PQ owner to real auth identity

## Description
- Replace the stub prospect identity used by the PQ API with the authenticated user identity once Auth0 integration lands.
- Ensure the PQ owner linkage is stable (e.g., Auth0 subject) and that ownership enforcement is consistent across CRUD routes.

## Notes
- This task depends on E2 / S4 (Auth0 sign-in/out baseline) and any chosen role model.

## Linked stories
- [ ] ../stories/story-pq-hardening.md

## Definition of done
- [ ] PQ routes derive `prospectId` from the auth context (no stub constant).
- [ ] Ownership checks are enforced for all PQ CRUD operations.
- [ ] Unauthorized/forbidden cases return problem+json consistently.
- [ ] Documentation notes required env/config for local auth testing.

## Status
- Status: blocked
- Owner: TBD
