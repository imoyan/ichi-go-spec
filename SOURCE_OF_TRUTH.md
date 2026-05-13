# Source of Truth

Canonical behavior is defined by this repository only.

Codex-facing repository instructions live in `AGENTS.md`. This document is a
supporting human reference for source-of-truth boundaries and must stay aligned
with `AGENTS.md`.

After this root is published as a standalone repository, the contracts, test
vectors, shared design tokens, and platform-neutral UI surface definitions here
remain the only canonical source for the covered Houra public client-server
behavior and Product MVP operation surface.

Priority order:

1. `contracts/SPEC-*.md`
2. `test-vectors/`
3. `design/theme.schema.json`, `design/themes/*.json`,
   `design/ui.surface.schema.json`, and `design/ui-surfaces/*.json`
4. Supporting docs

If an implementation differs from this repository, the implementation should be
updated unless the contract is changed first.

## Contract Changes

- Change or add a contract before changing implementation behavior.
- Add or update a test vector with every behavior change.
- Keep shared theme token and UI surface changes in `design/` first, then copy
  or adapt them into implementation packages that need bundled assets.
- Do not use any client or server implementation as the source for public
  behavior.

## Conformance Boundary

- Specification checks prove this repository is internally consistent.
- Implementation conformance tooling must consume contracts, vectors, design
  tokens, and UI surfaces from this repository without copying implementation
  behavior back into it.
- A conformance failure in an implementation should be fixed in that
  implementation unless the contract or vector is intentionally changed here
  first.

## Versioning

- Contracts are draft profiles until a pre-1.0 release decision is made.
- Public APIs may be added only after a matching `SPEC-*` contract and vector
  exist here.
- Release notes should describe changed feature profiles, not implementation
  internals.

## Pre-1.0 Freeze Checklist

Before freezing a pre-1.0 spec baseline:

- Every covered behavior has a `contracts/SPEC-*.md` entry and at least one
  matching `test-vectors/**/*.json` fixture.
- `CONTRACT_MODULE_MAP.md`, `FEATURE_PROFILES.md`, and `MODULE_DEPENDENCIES.md`
  match the frozen contract set.
- `design/theme.schema.json` validates every committed `design/themes/*.json`
  token file, and `design/ui.surface.schema.json` validates every committed
  `design/ui-surfaces/*.json` surface file.
- `dart tool/check_spec.dart` passes on the freeze candidate.
- Release notes or PR text identify changed feature profiles, not client
  implementation internals.

Change handling before freeze:

- Breaking changes must update the relevant `SPEC-*`, vectors, and profile map
  in the same spec PR.
- Additive changes must add a `SPEC-*` section or new contract plus matching
  vectors before any SDK surface is added.
- Corrections may clarify wording without a vector change only when expected
  public behavior does not change.
- Any contract, vector, or design token change that affects bundled assets or
  expected public behavior requires follow-up changes in affected
  implementation repositories.

## Pre-1.0 Compatibility Policy

Until a stable 1.0 release, contracts remain draft, but published pre-1.0 tags
must remain immutable; any corrections to those releases must be released as a
new tag and handled as follows:

- Breaking changes alter expected public behavior for an existing contract,
  vector, or design token. They require a focused spec PR that updates the
  affected `SPEC-*`, vectors, and profile map together, plus implementation
  follow-up issues or PRs when bundled assets or implementation behavior are
  affected.
  During pre-1.0, they are allowed only when the release notes label the change
  as breaking and the affected implementation repositories have an explicit
  follow-up path.
- Additive changes introduce new behavior without changing existing vector
  expectations. They require a new contract section or `SPEC-*` plus matching
  vectors before any implementation exposes client-server behavior, or a
  `design/ui-surfaces/*.json` change before any implementation exposes a new
  shared Product MVP UI surface.
- Corrections clarify wording, examples, or metadata without changing expected
  public behavior. They may skip vector changes only when the existing vectors
  already capture the intended behavior.

Pre-1.0 release notes must identify:

- Changed feature profiles.
- Changed contracts, vectors, design tokens, or UI surfaces.
- Whether the change is breaking, additive, or corrective.
- Required implementation follow-up, or that none is required.

## Current Pre-1.0 Freeze Candidate

The current freeze candidate is the committed `core`, `auth`, `rooms`,
`events`, `messaging`, `sync`, and `media` profile set described by
`CONTRACT_MODULE_MAP.md`.

The candidate includes the existing `contracts/SPEC-*.md`,
`test-vectors/**/*.json`, `design/theme.schema.json`,
`design/themes/smoke.json`, `design/ui.surface.schema.json`, and
`design/ui-surfaces/product-mvp.json` files. No implementation behavior, SDK API
shape, storage policy, framework-specific UI behavior, or server behavior is
part of this freeze candidate.

Changing a frozen contract, vector, design token, or UI surface after this
candidate requires a focused spec PR first. If the change affects bundled design
assets, UI surface conformance, or expected implementation behavior, create the
matching implementation follow-up issue or PR after the spec PR is merged.

## MVP Readiness Boundary

`full-client` readiness means the covered Houra MVP public contract is
complete enough for implementation repositories to consume this repository as
read-only conformance input. It does not mean Matrix Client-Server API,
federation, identity service, appservice, E2EE, push, VoIP, or administrative
API coverage.

The structural parts of readiness are checked by `dart tool/check_spec.dart`.
Workflow evidence such as implementation adoption reports and GitHub Releases
must be recorded in repository issues, pull requests, or releases.
