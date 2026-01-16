# ANCHOR

This document is the canonical narrative definition of the project. It should evolve over time and remain readable by non-technical stakeholders.

## At a glance
- Prospects pre-qualify once, then choose what to share (and with whom).
- Property managers see qualified prospects and can request additional screening if needed.
- Appointments are requested/offered and booked with clear consent + auditability.

## Product narrative
### What is Mariner?

Mariner connects pre-qualified rental prospects with property managers, reducing waste and uncertainty in the leasing process for both sides.

Mariner helps prospects:
- Complete screening up-front (before contacting properties).
- Control access to their personally identifiable information (PII) and screening results.
- Avoid repeated applications and unnecessary application fees when applying across multiple properties.

Mariner helps property managers:
- Engage with pre-qualified prospects who meet property acceptance criteria.
- Reduce the overhead of managing large volumes of unqualified leads, which are often more than half of applicants.

### Glossary
- Prospect: a consumer/rental applicant looking for housing.
- Property manager / leasing agent: the organization and users managing rental inventory and appointments.
- PII: personally identifiable information.
- Pre-qualification (PQ): a record combining prospect-provided details and screening product results.
- Acceptance criteria: property-specific requirements used to evaluate whether a prospect qualifies.

## User experience

### Primary workflow

#### 1) Property managers opt in

Mariner maintains a database of rental properties (e.g., address and property link) paired with the acceptance criteria for each property.

Property managers can optionally enable a booking feature by configuring a viewing appointment calendar (available time windows). If enabled, the calendar helps organize meetings with prospects.

#### 2) Prospect completes pre-qualification

The prospect completes a pre-qualification workflow by providing personal details to Mariner and running screening products to establish eligibility.

Foundational screening products (e.g., lease score, instant criminal, and instant housing court) are provided free of charge to the prospect.

Optionally, the prospect specifies housing requirements such as:
- Desired move-in date window(s)
- Bedrooms/bathrooms
- Square footage and amenities
- Map pin(s) and radius defining preferred areas

This produces the initial PQ record.

#### 3) Prospect selects a property

After PQ is complete, the prospect is shown a map of properties where they qualify based on their PQ data and each property's acceptance criteria. The map also displays the prospect's stated areas of interest.

Mariner may show both:
- Full matches (criteria fully satisfied): green pins
- Partial matches (criteria partially satisfied): yellow pins (may require additional screening products)

Properties where the prospect does not qualify are not displayed.

The primary call to action is `Request an appointment`, which starts the appointment request workflow.

#### 4) Prospect requests an appointment

The appointment request workflow is a booking experience:
- If the property manager enabled a booking calendar, the prospect selects from available time slots.
- If the property manager did not enable booking, the prospect selects one or more availability windows within the next 7 days.

When completed, Mariner delivers an appointment request to the property manager.
- If booking is enabled, the request provisionally reserves the requested time slot.
- If booking is not enabled, the request includes the prospect's availability window(s).

Leasing agent users can optionally enable notifications (email, text, or push) for appointment-related events.

In addition to the desired time(s), the appointment request includes the prospect's housing requirements and anonymized PQ data (already matched fully or partially to the property's acceptance criteria).

#### 5) Property manager responds to the appointment request

Appointment requests appear to leasing agents in an inbox workflow. Each request includes:
- Desired appointment window(s)
- Housing requirements
- Anonymized screening product results, already matched against the property's acceptance criteria

Leasing agents have two primary calls to action:

##### Add qualifications

`Add Qualifications` starts the additional qualification workflow.

Initial PQ includes foundational screening (e.g., credit and criminal background checks). Some properties require additional qualifications (e.g., income and employment verification).

The additional qualification workflow provides a `shopping cart` experience to add screening products and request the prospect's consent.
- The prospect receives a consent request (email, text, or push).
- If consent is granted, the property manager is charged for the additional screening products and the results are added to the prospect's PQ.

##### Offer appointment

`Offer appointment` starts the offer appointment workflow.

The leasing agent creates an appointment offer that includes unit details for one or more units that match the prospect's housing requirements and qualifications. Unit details may include:
- Links, location, bedrooms/bathrooms, amenities
- Move-in availability dates
- Proposed lease terms (monthly rent, deposit, lease duration) based on the prospect's qualifications

When the offer is completed, the property manager is charged for delivery of the offer and the appointment offer is delivered to the prospect.

#### 6) Prospect accepts the appointment offer and shares details

Appointment offers are presented to the prospect in an inbox workflow. Offers include:
- Offered time slot
- Property/unit details
- Provisional lease terms

The primary call to action is `Share my details and accept appointment`. This begins:
- The accept appointment workflow
- The share screening details workflow

##### Accept appointment

This is a standard booking workflow. The prospect selects the offered slot and the booking is confirmed on both the prospect and property manager calendars. Booking management is handled via standard booking workflows and is managed independently from the PQ and screening data sharing settings.

##### Share screening details

The prospect grants permission for a specific property manager organization to access their PII and screening details within Mariner.

### Ongoing management
Ongoing workflows:
- Appointments: reschedule/cancel and coordinate after booking.
- PQ + sharing: the prospect can adjust sharing and delete their screening data.
- Blacklist: property managers can block individuals from contacting them.

## Architecture definition

### Technology selection criteria

Mariner is consumer-facing and handles sensitive PII. Technology choices should optimize for:
- Mature, reliable frameworks and supply chain
- Strong AI-assisted development ergonomics (clear patterns, strong tooling, predictable code generation)
- Explicit control flow and wiring (minimize hidden runtime behavior that is hard to infer from a limited context window)
- Composability from proven components (avoid custom-built solutions to common problems)
- Continuous delivery readiness (testing, observability, deployment automation)
- Greenfield flexibility (multiple stacks are viable if they meet the criteria)

### Platform decisions (v1)

Product goals for v1:
- Build a development MVP that validates the core product thesis with customers.
- Prioritize core domain data, workflows, and interactions over distribution and growth loops.

Client platforms:
- Web-only for v1.
- Design mobile-first (responsive UX) so the product can evolve into a strong mobile-first experience over time.
- Marketing and SEO are deferred until after v1.

Web app framework/runtime:
- Use a Vite-built React SPA (client-side rendering) for v1.
- Include a minimal unauthenticated landing page primarily to route users into the correct login flow (persona-based entry).
- Prefer simple, explicit client routing (e.g., React Router) and avoid SSR complexity in v1.

Development environment:
- Use a Dev Container as the canonical Linux development environment for both humans and coding assistants.
- Avoid relying on host-installed toolchains to minimize Windows/macOS vs Linux drift.

UI/component system:
- Use MUI for v1 to maximize velocity when building early UX constructs (forms, dialogs, navigation, admin-style surfaces).
- Use MUI theming to keep a consistent design language without investing heavily in custom styling during the MVP.
- Accessibility: select components/patterns that keep an upgrade path to strong accessibility post-MVP, but do not treat full accessibility feature coverage as a v1 gate.

Forms and validation:
- Use React Hook Form for form state management (performance and ergonomics for large multi-step forms).
- Use Zod for schema-driven validation and type inference, with `@hookform/resolvers` to unify schema rules and UI errors.
- Validate on the server as well (authoritative validation) and return a consistent field-error shape for excellent UX.

API contracts and errors:
- Use a contract-first API approach with an OpenAPI 3.1 spec as the source of truth.
- Generate the TypeScript client for the web app from the OpenAPI spec and evolve them together via conventional OpenAPI workflows.
- Enforce structured field-level request validation errors for invalid input.
- Unify frontend and backend contracts via shared schemas where reasonable (align Zod schemas and OpenAPI/JSON Schema).
- Standardize API errors on `application/problem+json` with a stable `type` and `code`, `trace_id`, and optional `field_errors[]`.

Persistence and migrations:
- Prefer a Kotlin-DSL-first persistence layer so the backing implementation can change with minimal refactoring (use ports/repositories at domain boundaries).
- Use Exposed for v1 (Kotlin DSL; strongly typed column definitions and query building; explicit transactions).
- Use Flyway for schema migrations (SQL-first migrations; simple, conventional, and reviewable).
- Reporting: assume complex analytics/reporting is primarily served via Databricks ingestion rather than OLTP query complexity in the primary application DB.

Maps and geocoding:
- Use Google Maps Platform for map rendering, address autocomplete, and geocoding in v1.

Notifications:
- Use email-only notifications for v1.
- Use SendGrid as the email delivery provider.

Webhooks (inbound):
- Webhooks are a first-class integration mechanism in v1 (including SendGrid event ingestion and other provider callbacks).
- Endpoint shape: `POST /webhooks/{provider}/v1` (e.g., `/webhooks/sendgrid/v1`, `/webhooks/cal/v1`).
- Verification: verify provider signatures when available; reject invalid signatures (401/403).
- Replay protection: validate timestamp/nonce when supported; apply a small tolerance window.
- Idempotency: persist and dedupe events by `(provider, external_event_id)` (or a stable hash of the raw payload if no id is provided).
- Processing: acknowledge quickly (2xx) and process asynchronously; persist raw payload + headers + verification result + processing status for audit/debugging.
- Local development/testing: support a governed signature bypass for Postman-driven mocks that is disabled in production (explicit env flag + bypass secret, audited).

Billing and invoicing:
- For v1, assume customers are on net terms and charges accrue to a customer ledger.
- Billing runs monthly via an invoicing process against the ledger.
- Only screening products that successfully complete and whose results are added to the prospect's PQ are billable.

Screening integrations:
- Screening vendors: SafeRent Solutions is the system of record for all screening products.
- Mariner will expose a greenfield internal API/interface for screening operations:
  - Request screening services (create screening requests)
  - Receive and persist events associated with requests (webhooks/callbacks)
  - Query resulting screening product data to populate the prospect's PQ
- Development approach: build UI/UX and initial application workflows against mock screening interfaces and mock data first, then implement the real SafeRent-backed adapters to the same internal interface.

Background jobs and workflows:
- Use GCP Cloud Tasks for v1 background work (HTTP-targeted jobs with managed retries/backoff).
- Use GCP Cloud Scheduler to enqueue Cloud Tasks for scheduled work (e.g., monthly invoicing runs, reminders).
- Assume long-running processes with explicit statuses and notifications (common in screening workflows); UI should not block on most workflows.
- Consistency model: at-least-once execution with idempotency where possible, plus eventual consistency (e.g., optimistic concurrency control) for asynchronous workflows.
- Future: a more robust workflow engine and/or business rules engine may be needed as domain complexity increases, including handling cases where exactly-once semantics are required because idempotency cannot be guaranteed.

PII storage, encryption, and key management:
- Compliance posture: assume US-only data residency and FCRA-driven audit/retention requirements.
- Data storage (v1): store all prospect PII and screening results in Mariner-owned persistence (Postgres), with explicit audit logging for access and changes.
- Encryption model (v1 intent): treat encryption keys as “owned by the prospect” in the sense that access to decrypt PII is gated by the prospect’s consent and authorization rules.
- Implementation approach (v1): use envelope encryption for sensitive fields with per-prospect data-encryption keys (DEKs) that are wrapped via GCP KMS; decryption is performed only when consent/authorization permits.
- Secrets: use GCP Secret Manager in deployed environments; local development can use non-production secrets (e.g., local `.env`) while keeping a clear path to unifying secret management later.
- Deletion and retention: v1 may use soft delete with retention for pre-production, but the data model/workflows should support privacy-compliant hard deletion policies when required.
- Object storage: no user uploads in v1; if artifacts emerge, store them in GCS with the same residency, encryption, and access/audit conventions.

Observability, errors, and analytics:
- Continuous delivery requires continuous technical observability as a core MVP capability.
- Standardize on OpenTelemetry across the system (API, background jobs, and integrations) with OTLP export to Grafana Cloud.
- Frontend observability and error tracking should live in the Grafana Cloud ecosystem (Grafana Frontend Observability).
- Product analytics: use PostHog, focused on key journey events in v1, with a conventional framework to extend coverage over time.
- Event naming taxonomy: use a common event-driven convention (lowercase, dot-delimited, past-tense domain events, versioned when needed), e.g., `prospect.pq.submitted`, `appointment.requested`, `consent.granted`, `screening.completed`.

### Candidate approaches (non-exhaustive)

Frontend (assumed):
- React + TypeScript (mature ecosystem; strong component and testing ecosystem)

Backend API:
- Kotlin + Spring Boot (largest JVM ecosystem; batteries-included; higher implicit behavior via auto-configuration and annotation-driven DI)
- Kotlin + Ktor (lighter weight; Kotlin-first; typically more explicit routing/composition; smaller ecosystem than Spring)
- Kotlin + http4k (functional HTTP toolkit; explicit composition; smaller ecosystem)
- Kotlin + Micronaut (mature; compile-time DI reduces reflection and can feel more explicit than Spring)
- Java + Spring Boot (max ecosystem maturity; slightly less Kotlin ergonomics)
- Go + Gin (explicit, minimal magic; fast builds and simple deployments; requires assembling common components deliberately)
- C# + ASP.NET Core (very mature; strong tooling; good for CI/CD)
- TypeScript + Node (e.g., NestJS) (high velocity; larger dependency surface area)

### Platform dependencies and ecosystem fit

Primary platform dependencies:
- Observability: Grafana Cloud via OpenTelemetry (OTLP export)
- Authn/authz: Auth0 via OIDC/OAuth2 (JWT validation on APIs)
- Cloud: GCP (Cloud Run/GKE/Cloud SQL; native services as needed)
- Persistence: Postgres (plus native GCP services where appropriate)
- Delivery/edge: Cloudflare (CDN/WAF; optionally Workers)
- CI/CD: Harness

### Proposed starting point (current)

Working assumptions (initial):
- Frontend: React + TypeScript (Vite SPA; CSR)
- Backend: Kotlin + Ktor (favor explicit composition)
- Integrations: Auth0 (OIDC/OAuth2), Cal.com (bookings)
- Deploy: GCP Cloud Run + Postgres; Cloudflare edge; OTel -> Grafana Cloud
- CI/CD: Harness

Validation strategy: build a thin vertical slice (PII capture, consent + sharing, audit logging) with CI, tests, and deployment automation, then reassess.

### Third-party integrations (initial assumptions)

Bookings (Cal.com):
- Mariner uses Cal.com for scheduling and calendar availability.
- Mariner must still own the product UX, business rules, and the linkage between appointments and PQ records.

Authentication (Auth0):
- Mariner uses Auth0 for OAuth/OIDC login flows.
- Mariner treats Auth0 as the identity provider and issues a Mariner session/token model appropriate for the client(s).

## Scope and non-goals
- TBD.

## Assumptions and open questions
- Open questions to validate early:
  - What constitutes `foundational screening` vs `additional qualification` for v1?
  - How is `partial match` explained to prospects (and how do they resolve it)?
  - What data is included in `anonymized PQ` before the prospect shares details?
  - What are the expected payment flows (prospect vs property manager) and price points?
  - What is the minimum viable booking experience when calendars are not enabled?
  - Which Auth0 tenant/app configuration and role model do we need (prospect vs leasing agent vs admin)?
  - What PII (if any) is stored in Auth0 vs only in Mariner-owned systems?
  - How does Cal.com integrate in v1: embed UI, deep-linking, or API-driven booking?
  - What is the source of truth for booking state (Cal.com vs Mariner), and how are cancellations/reschedules synchronized?

## Roadmap (narrative)
- TBD.
