# Rollback Guide

## Scope
Applies to contract/documentation slices that modify schema contracts and validation tests.

## Safe rollback steps
1. Revert the commit that introduced/changed contract schema files under `contracts/schemas/`.
2. Revert any accompanying fixtures in `contracts/examples/` and tests in `tests/`.
3. Re-run contract tests to confirm pre-change behavior is restored.

## Why rollback is safe
This slice introduces no runtime migrations or destructive operations. Rollback is source-level and does not require data restoration.

## Forward-fix preference
If a deployed consumer depends on new fields, prefer patching with backward-compatible optional fields over full rollback.
