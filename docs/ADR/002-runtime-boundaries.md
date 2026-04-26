# ADR 002: Runtime Boundaries and Entitlement Gate

## Status
Accepted

## Context
Premium assets and user state require strict access boundaries. Client-side logic alone is insufficient for trusted checks.

## Decision
- Entitlement checks are server-side only.
- Asset URL signing requires explicit positive entitlement decision.
- Contract validation occurs prior to runtime writes.
- Unknown integration behavior must be isolated behind typed adapters with explicit `UNKNOWN` status.

## Consequences
- Client cannot directly fetch premium source artifacts.
- Entitlement path can be audited through deterministic request IDs.
- Validation failures become first-class, testable outputs.
