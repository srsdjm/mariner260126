# API (Kotlin/Ktor)

This module contains the Kotlin/Ktor API service.

Endpoints:
- `GET /health`
- `GET /api/pq` (get current prospect PQ)
- `POST /api/pq` (create PQ)
- `PUT /api/pq` (update PQ)
- `DELETE /api/pq` (delete PQ)

Notes:
- Prospect identity is stubbed to a single prospect until Auth0 wiring lands.
- SSN is encrypted at rest with an AES-256-GCM key provided via `PII_ENCRYPTION_KEY`. Responses only expose `ssnLast4`.

## Local development (Gradle)

Use the Gradle wrapper so local builds are consistent across machines:

- Build: `./gradlew build`
- Run: `./gradlew run`
- Build distribution (used by the container image): `./gradlew installDist`

Environment variables:
- `DATABASE_SERVICE_URL` (e.g., `postgresql://user:password@host:5432/dbname`)
- `PII_ENCRYPTION_KEY` (Base64-encoded 256-bit key for AES-GCM)
- `CORS_ALLOWED_ORIGINS` (optional, comma-separated allowed origins for cross-origin browser calls)
