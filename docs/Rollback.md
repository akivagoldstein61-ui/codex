# Rollback Guide

## Scope
Applies to foundational slices that modify schema contracts, SQL migrations, and validation/policy tests.

## Safe rollback steps
1. Revert the commit that introduced/changed contract schema files under `contracts/schemas/`, SQL migrations under `supabase/migrations/`, and tests in `tests/`.
2. If the SQL migration has been applied to a real database, create a compensating rollback migration rather than editing the applied migration in place.
3. Re-run the contract and migration/policy tests to confirm the repository is back to the intended baseline.

## Why rollback is safe
The current repository change set is additive and reviewable. In environments where migrations have not been applied, rollback is source-level only. In environments where migrations have been applied, prefer forward-only compensating SQL for safe reversion.

## Forward-fix preference
If a deployed consumer depends on new fields or tables, prefer patching with backward-compatible schema additions or explicit compensating migrations over force-rewriting history.
