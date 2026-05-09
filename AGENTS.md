# AGENTS.md

## Scope

This repository is the canonical behavior and shared design source for
Houra clients and servers.

## Source of Truth

Priority order:

1. `contracts/SPEC-*.md`
2. `test-vectors/`
3. `design/theme.schema.json`, `design/themes/*.json`,
   `design/ui.surface.schema.json`, and `design/ui-surfaces/*.json`
4. Supporting docs

Implementation repositories are not canonical.

## Clean-Room Rule

Do not copy, translate, port, or derive implementation details from existing
client or server implementations. If behavior is unclear, clarify the contract
here before changing an implementation.

## Dependency Selection

When implementation work needs libraries, prefer mainstream, widely maintained
choices for the target ecosystem. Avoid minor or obscure dependencies for core
behavior. If the reasonable choices are niche, implement the needed behavior
locally against the contracts instead of adding a dependency.
