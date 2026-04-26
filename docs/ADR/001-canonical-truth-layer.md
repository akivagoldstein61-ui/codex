# ADR 001: Canonical Truth Layer

## Status
Accepted

## Context
The product requires deterministic ingest/publish behavior while supporting fast runtime queries.

## Decision
Google Sheets and Google Drive are treated as canonical truth for ledger state and source artifacts respectively. Runtime data stores are derivative caches/indexes and must keep source pointers (`source_system`, `source_ref`, `content_hash`).

## Consequences
- Ingestion must be idempotent.
- Published content must be linked to immutable `content_version_id`.
- Runtime repair can be performed by replay from canonical source.
