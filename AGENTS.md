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

Codex-facing repo instructions live in this file. `README.md`,
`SOURCE_OF_TRUTH.md`, `REFERENCE_POLICY.md`, `FEATURE_PROFILES.md`,
`MODULE_DEPENDENCIES.md`, and `CONTRACT_MODULE_MAP.md` are supporting docs and
must not supersede this file.

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

## Change Workflow

- For implementation-facing behavior changes, open or use a focused GitHub
  issue before editing contracts or vectors.
- Start from the relevant `contracts/SPEC-*.md`, then update matching
  `test-vectors/` and design schema or UI surface files when the contract
  change affects them.
- Keep broad Matrix work split into issue-sized gates. Do not mix unrelated
  Matrix domains, Product MVP work, and release-readiness work in one change.
- If the goal could mean either Houra Product MVP or broad Matrix compliance,
  make the target explicit before widening scope.
- Record implementation adoption evidence in `README.md` when another Houra
  repository adopts a spec change; implementation repositories remain
  non-canonical.

## Contract Update Rules

- A contract change should identify the affected feature profile, module map
  entry, vectors, schemas, and adoption evidence before handoff.
- External protocol facts, including Matrix version references, must be dated
  snapshots with source and `checked_at` semantics. Do not write them as
  timeless current facts.
- Do not encode server storage design, client internals, or SDK convenience
  behavior as contract behavior unless the public Houra contract requires it.
- When compatibility evidence is incomplete, prefer a fail-closed contract
  or advertisement gate over claiming support without evidence.

## Verification

- Run `dart tool/check_spec.dart` after changing repository instructions,
  contracts, vectors, design files, or supporting docs.
- Run `git diff --check` before handoff.
- For adoption work in implementation repositories, verify against this
  repository by using a pinned `houra-spec` ref or `HOURA_SPEC_ROOT`.
- If a verification failure is unrelated to the current change, record the
  failing command and evidence instead of weakening the gate.

## MCP

- Use Context7 first when current external library, framework, SDK, CLI, or
  SaaS API documentation is needed.
- Use the OpenAI developer documentation MCP server for OpenAI API, ChatGPT
  Apps SDK, Codex, or other OpenAI product guidance.
- Use spec-workflow MCP for medium or large multi-file spec design, API
  surface changes, schema changes, or state-machine work. Skip it for typo
  fixes, one-file mechanical edits, and read-only reviews.
- MCP output is supporting context only. Contracts, test vectors, design
  schemas, and adoption evidence in this repository remain the source of truth.

## Dependency Selection

When implementation work needs libraries, prefer mainstream, widely maintained
choices for the target ecosystem. Avoid minor or obscure dependencies for core
behavior. If the reasonable choices are niche, implement the needed behavior
locally against the contracts instead of adding a dependency.
