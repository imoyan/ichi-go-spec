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

## Documentation Language Policy

English contract text remains the canonical source of truth.

Japanese documentation is still a first-class reader surface. Drift between
English and Japanese prose is acceptable between releases, but it should be
tracked and corrected regularly instead of treated as disposable translation.

For milestone releases, especially `v0.X.0`, `v1.0.0`, and other release tags
that are intended as stable adoption points, do not cut the release until the
matching Japanese documentation surface has been reviewed and updated for the
changed contracts, vectors, design inputs, adoption evidence, and release notes.

When changing documentation:

- Keep canonical normative requirements in English.
- Add or update Japanese guidance in the same file when the change affects
  readers, implementation adopters, release readiness, or public positioning.
- Keep same-file Japanese sections short. Put longer Japanese guidance under
  `docs/ja/` and link to the English canonical source instead of expanding
  top-level README or contract files heavily.
- Keep `docs/ja/` in the same repository so release tags freeze English
  canonical text and Japanese reader guidance together.
- If Japanese text intentionally lags an English change, record the gap in the
  PR body, release checklist, or a follow-up issue before handoff.

## Clean-Room Rule

Do not copy, translate, port, or derive implementation details from existing
client or server implementations. If behavior is unclear, clarify the contract
here before changing an implementation.

## Dependency Selection

When implementation work needs libraries, prefer mainstream, widely maintained
choices for the target ecosystem. Avoid minor or obscure dependencies for core
behavior. If the reasonable choices are niche, implement the needed behavior
locally against the contracts instead of adding a dependency.
