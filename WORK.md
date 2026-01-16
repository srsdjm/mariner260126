# WORK

Lightweight tracking for epics, stories, and tasks (until we split into `work/` artifacts).

## Epics
- E1 (ready): Dev environment + repo scaffold (web + api)
- E2 (ready): Auth (Auth0) integration baseline
- E3 (ready): Bookings (Cal.com) integration baseline
- E4 (proposed): Vertical slice: PII capture + consent + audit trail
- E5 (proposed): Prospect pre-qualification (PQ) MVP
- E6 (proposed): Property manager onboarding + acceptance criteria
- E7 (ready): Platform decisions + core components (maps, notifications, payments, screening, jobs, storage, analytics)
- E8 (proposed): CI/CD baseline (Harness)
- E9 (done): PQ CRUD baseline (consumer-owned PII slice)
- E10 (in-progress): PQ hardening (auth wiring + automated checks)

## Stories
- E1 / S1 (done): As a developer, I can run the React web app locally with hot reload.
- E1 / S2 (done): As a developer, I can run the Ktor API locally and call a health endpoint.
- E1 / S3 (done): As a developer, I can run the full stack locally (web + api + db) with one command.
- E2 / S4 (ready): As a user, I can sign in/out via Auth0 and the app knows who I am.
- E2 / S5 (proposed): As a system, API endpoints enforce authorization by role (prospect vs leasing agent).
- E3 / S6 (proposed): As a prospect, I can request a viewing appointment using Cal.com availability.
- E3 / S7 (proposed): As a leasing agent, I can receive appointment requests with the linked PQ context.
- E7 / S8 (done): As a developer, I can choose the web app framework/runtime (Vite SPA) and routing approach (CSR; simple landing for login routing).
- E7 / S9 (done): As a developer, I can choose a UI/component + forms stack that meets accessibility and velocity needs (MUI + React Hook Form + Zod).
- E7 / S10 (done): As a developer, I can choose the maps/geocoding platform for property discovery and area-of-interest UX (Google Maps).
- E7 / S11 (done): As a developer, I can choose notification channels/providers (email-only via SendGrid for v1) and webhook handling conventions (verified + idempotent; governed dev bypass).
- E7 / S12 (done): As a developer, I can choose the billing/payments platform for property-manager-paid screening products (net terms; monthly invoicing; charge only successful screening results).
- E7 / S13 (done): As a developer, I can choose screening vendors and define integration patterns (SafeRent; mock-first; async + events/webhooks + idempotency).
- E7 / S14 (done): As a developer, I can choose background job/queue primitives for reminders, screening orchestration, and audits (GCP Cloud Tasks + Cloud Scheduler; long-running workflow statuses).
- E7 / S15 (done): As a developer, I can define PII storage, encryption, and key management conventions (US-only; FCRA audit/retention; consent-gated envelope encryption with KMS).
- E7 / S16 (done): As a developer, I can choose analytics + error tracking, and define event and logging conventions (OTel->Grafana Cloud everywhere; Grafana frontend observability; PostHog key journey events).
- E8 / S17 (proposed): As a contributor, PRs are validated by Harness CI (build + checks) before merge to `develop`.
- E8 / S18 (proposed): As a maintainer, merges to `develop` build and publish versioned `api` and `web` container images.
- E8 / S19 (proposed): As an operator, I can deploy `api` and `web` to GCP (Cloud Run) via Harness CD across `dev`/`qat`/`uat`/`ppd`/`prd` with promotion gates.
- E8 / S20 (proposed): As a developer, I can run local build/check commands that mirror CI for fast feedback before pushing to `develop`.
- E9 / S21 (done): As a prospect, I can create, update, and delete my PQ record with core PII (first name, last name, DOB, SSN).
- E10 / S22 (blocked): As a prospect, PQ CRUD is authorized to my identity and covered by automated checks.

## Tasks
- T1 (done): Decide repo layout (single repo with `web/` + `api/`) and conventions (monorepo; Dev Container required).
- T2 (done): Scaffold `web/` React+TypeScript app.
- T48 (proposed): Add `web/` linting (ESLint) and baseline configuration.
- T49 (proposed): Add `web/` unit test setup and baseline tests.
- T3 (done): Scaffold `api/` Kotlin+Ktor app with `GET /health`.
- T50 (done): Add `api/` unit test setup and baseline tests.
- T4 (done): Document local dev prerequisites and run commands in `README.md`.
- T5 (done): Add local DB via `compose.yml` (Postgres) for early vertical slice.
- T6 (proposed): Add CI (Harness) for web/api format + lint + tests.
- T7 (proposed): Add Auth0 integration spike (web login + API JWT validation).
- T8 (proposed): Add Cal.com integration spike (embed or API) with stubbed booking flow.
- T9 (done): Decide client platforms for v1 (web-only) and any SEO requirements (defer marketing/SEO until after v1).
- T10 (done): Decide web app framework/runtime (Vite SPA), routing, and rendering strategy (CSR).
- T11 (done): Decide UI/component library and styling approach (MUI) and accessibility baseline (post-MVP focus).
- T12 (done): Decide form and validation stack (React Hook Form + Zod) and how we handle sensitive PII entry UX.
- T13 (done): Decide maps/geocoding provider (Google Maps: pins, polygons/radius search, autocomplete) and pricing/quotas assumptions.
- T14 (done): Decide notifications scope for v1 (email-only via SendGrid); define webhook verification pattern (verified + idempotent; governed dev bypass for Postman mocks).
- T15 (done): Decide payments/billing platform and billing model (net terms; ledger billed monthly; charge only successful screening results added to PQ).
- T16 (done): Decide screening vendors for foundational and additional qualifications; define integration approach (SafeRent; mock-first; webhooks/events; retries; idempotency).
- T22 (ready): Define Mariner screening internal API contract (requests, events, results) and error model.
- T23 (ready): Implement mock screening adapter + seeded mock data to unblock UI/UX iteration.
- T24 (ready): Implement SafeRent screening adapter (request submission, event ingestion, results queries) behind the internal contract.
- T25 (ready): Implement screening event persistence + idempotent processing and link events/results to PQ records.
- T17 (done): Decide background jobs/queue primitive (GCP Cloud Tasks + Cloud Scheduler) and retry/backoff conventions.
- T26 (proposed): Evaluate workflow engine/business rules needs post-MVP (including exactly-once semantics where idempotency is insufficient).
- T18 (done): Decide document/file storage approach (GCS if needed) and encryption/key management (GCP KMS; consent-gated envelope encryption) conventions.
- T27 (proposed): Define FCRA-oriented audit log and retention policy requirements (events, retention windows, access reporting).
- T28 (proposed): Evaluate “prospect-owned keys” implementation options (per-prospect DEKs, KMS wrapping, rotation, recovery, consent revocation semantics).
- T19 (done): Decide API contract approach (contract-first OpenAPI; generated TS client; structured field errors; `problem+json` error model).
- T20 (done): Decide Kotlin persistence and migrations (Exposed; Flyway).
- T21 (done): Decide analytics + error tracking (PostHog; Grafana Cloud frontend observability) and event naming conventions.
- T29 (done): Add Dev Container scaffolding and enforce it as the canonical Linux development environment.
- T30 (proposed): Define canonical CI build/test commands for `web/` and `api/` (scripts callable locally and in Harness).
- T31 (proposed): Make builds reproducible in CI (lockfiles and pinned toolchain versions; avoid “works on my machine” drift).
- T32 (proposed): Add `.harness/` pipeline-as-code scaffolding (CI + CD) aligned to repo structure.
- T33 (proposed): Implement Harness CI pipeline for `web` and `api` (build + unit checks; optional ephemeral db for integration tests later).
- T34 (proposed): Implement image build+push to GCP Artifact Registry (`us`) with OCI metadata (tagging: commit SHA; immutable by default).
- T35 (proposed): Implement Harness CD to deploy `api` and `web` to GCP Cloud Run (`us-west1`) across `dev`/`qat`/`uat`/`ppd`/`prd` with config/secrets via GCP Secret Manager.
- T36 (proposed): Add stage/prod promotion gates (approvals, rollbacks, and change audit trail).
- T37 (proposed): Document required Harness connectors, secrets, and bootstrap steps (Git connector, registry connector, GCP connector).
- T38 (proposed): Require Harness CI checks for merges to `develop` (branch protections + status checks) and document the workflow.
- T39 (proposed): GCP: create Artifact Registry Docker repo in multi-region `us` (proposed repo name: `mariner`) for monorepo images.
- T40 (proposed): GCP: set up Workload Identity Federation (pool/provider) for Harness and map to per-environment service accounts.
- T41 (proposed): GCP: create per-environment CICD service accounts (`dev`/`qat`/`uat`/`ppd`/`prd`) with least-privilege IAM for AR + Cloud Run + Secret Manager access.
- T42 (proposed): GCP: create Cloud Run services for `api` and `web` per environment in `us-west1` (naming, revision/traffic conventions, rollback expectations).
- T43 (proposed): GCP: define runtime configuration + secrets per environment (Secret Manager, required env vars, rotation expectations) for `dev`/`qat`/`uat`/`ppd`/`prd`.
- T44 (done): Add Gradle wrapper for `api` to standardize local and CI builds.
- T45 (done): Add `web` lockfile (`package-lock.json`) and standardize `npm ci` usage for CI parity.
- T46 (proposed): Add `scripts/ci/` entry points for `api` and `web` build/check commands (callable locally and in Harness).
- T47 (proposed): Document local build/check commands in `README.md` to mirror CI expectations for `develop` PRs.
- T51 (done): Add PQ persistence and migrations for core PII fields with owner linkage.
- T52 (done): Implement PQ CRUD API with validation, auth, and problem+json errors.
- T53 (done): Build web form for PQ create/edit/delete with client/server validation.
- T54 (done): Add PQ CRUD automated tests and documentation for running them.
- T55 (blocked): Wire PQ ownership to real auth identity (depends on E2 / S4).
- T56 (done): Add Codex skill for Playwright MCP web searching and package it for install.

## Status conventions
- proposed, ready, in-progress, blocked, done, parked

## Workflow
- Keep entries concise and outcome-focused.
- Link related items with bullet references.
- Promote items incrementally as they progress.
