# AGENTS.md

## Scope

This repository is the canonical behavior and shared design source for
Okomedev Chawan clients and servers.

## Source of Truth

Priority order:

1. `contracts/SPEC-*.md`
2. `test-vectors/`
3. `design/theme.schema.json` and `design/themes/*.json`
4. Supporting docs

Implementation repositories are not canonical.

## Clean-Room Rule

Do not copy, translate, port, or derive implementation details from existing
server implementations. If behavior is unclear, clarify the contract here
before changing an implementation.
