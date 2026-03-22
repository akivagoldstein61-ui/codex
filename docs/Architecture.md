# Architecture (Foundation Slice 1)

## Boundaries
- **Canonical Sources**: Google Sheets + Google Drive.
- **Runtime Plane**: app/backend database and storage used for serving, querying, and access control.
- **Boundary Rule**: runtime writes should be idempotent and traceable back to canonical source identifiers.

## Core flow (target)
1. Ingestion kickoff receives request.
2. Request wrapped in `EventEnvelope`.
3. Canonical payload transformed into `DeckSpec`/`CardSpec`/`JourneySpec`.
4. `ContentValidationReport` generated.
5. If valid and approved, runtime publish stores snapshot keyed by `content_version_id`.
6. Premium assets resolved through entitlement checks yielding `EntitlementCheckResult`.

## Safety defaults
- Validate before writes.
- Preserve stable IDs across versions.
- Deny privileged access by default when entitlement check is inconclusive.
- Require explicit approval metadata for publish-like transitions.

## Data foundation (slice 2)
- `content_versions` stores immutable publish snapshots and approval metadata.
- `ingestion_runs` tracks idempotent ingest requests with dry-run support.
- Content tables (`decks`, `cards`, `journeys`, `assets`) point to immutable `content_version_id` values.
- User-sensitive tables (`profiles`, `saves`, `entitlements`, `analytics_events`) are protected by deny-by-default RLS with explicit per-use policies.

## Implementation status
This repository now contains contract docs, canonical JSON schemas, and a first-pass SQL data foundation migration with explicit RLS policies. Server functions and executable entitlement signing remain future work.
