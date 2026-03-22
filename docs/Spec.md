# Deck Factory OS / Mystery of Meaning — Foundation Spec (Slice 1)

## Scope
The repository now contains two foundational slices:

### Slice 1 — Contract-first foundations
- canonical truth-layer assumptions
- runtime boundaries
- typed payload contracts for ingestion/runtime events
- rollback guidance for contract changes

### Slice 2 — Minimal data foundation
- explicit SQL migration files for core content/runtime tables
- immutable content version markers and ingestion run tracking
- deny-by-default RLS posture for user-sensitive/runtime tables
- migration and policy-oriented tests

This repository still does **not** include payment paths, deployment changes, or external write integrations.

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
