# Deck Factory OS / Mystery of Meaning — Foundation Spec (Slice 1)

## Scope of this slice
This slice defines **contract-first foundations** only:
- canonical truth-layer assumptions
- runtime boundaries
- typed payload contracts for ingestion/runtime events
- rollback guidance for contract changes

No schema migrations, auth-policy changes, payment paths, or deployment changes are included.

## Canonical truth layer
1. Google Sheets is canonical for job/state ledger.
2. Google Drive is canonical for authored artifacts.
3. Runtime stores (DB/cache/object storage) are derivative and must retain pointers to canonical IDs.

## Non-goals
- No direct integration with Google APIs yet.
- No route implementation yet.
- No background workers yet.

## Required contracts in this slice
- EventEnvelope
- DeckSpec
- CardSpec
- JourneySpec
- ContentValidationReport
- AssetManifest
- EntitlementCheckResult

## Contract invariants
All contracts in this slice must include or transitively embed:
- `version`
- stable IDs (`*_id`)
- `content_hash`
- `content_version_id`
- `request_id`
- `idempotency_key`
- timestamps (`created_at`, and optional `updated_at`)
- approval metadata where relevant
