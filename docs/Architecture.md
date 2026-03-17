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

## Implementation status
This repository currently contains contracts and docs only. Runtime enforcement and DB policies are planned for the next slice.
