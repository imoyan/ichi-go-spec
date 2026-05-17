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

## Matrix References Are Primary

For Matrix-aligned work, do not use `SPEC-*` as the reader-facing numbering
system. Use official Matrix identifiers first: dated Matrix spec version
snapshot, API domain, endpoint path or section anchor, MSC number, and room
version as applicable.

Existing `SPEC-*` filenames and anchors are retained only for repository link
stability, release evidence, and implementation adoption records that already
cite them. New Matrix-facing docs, issue titles, PR bodies, release records, and
adoption evidence should name the Matrix reference before the repository anchor.
If a Matrix reference changes, is superseded, or is split, update the Matrix
reference without inventing a replacement local number.

Every contract header must include `Primary reference`. For Matrix-aligned
contracts this field must begin with the Matrix spec version and API domain; for
Houra-only contracts it must use a Product MVP or Houra public API label.
The contract H1 must match `Primary reference`, while the existing `SPEC-*`
value must be kept in `Repository anchor` for file paths and historical refs.

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
- `Status: draft` describes the contract document state only. It does not mean
  the behavior is unadopted, and it must not be used as the source for
  implementation adoption, release readiness, or Matrix advertisement status.
  Adoption and claim state are recorded through release evidence, implementation
  reports, and the relevant gate contracts.
- Public APIs may be added only after a matching contract entry and vector
  exist here.
- Release notes should describe changed feature profiles, not implementation
  internals.

## Pre-1.0 Freeze Checklist

Before freezing a pre-1.0 spec baseline:

- Every covered behavior has a `contracts/SPEC-*.md` entry and at least one
  matching `test-vectors/**/*.json` fixture.
- `CONTRACT_MODULE_MAP.md`, `FEATURE_PROFILES.md`, and `MODULE_DEPENDENCIES.md`
  match the frozen contract set, including feature profile, contract type, and
  Matrix domain metadata.
- `design/theme.schema.json` validates every committed `design/themes/*.json`
  token file, and `design/ui.surface.schema.json` validates every committed
  `design/ui-surfaces/*.json` surface file.
- `dart tool/check_spec.dart` passes on the freeze candidate.
- Release notes or PR text identify changed feature profiles, not client
  implementation internals.

Change handling before freeze:

- Breaking changes must update the relevant contract entry, vectors, and
  profile map in the same spec PR.
- Additive changes must add a new contract entry or contract section plus
  matching vectors before any SDK surface is added.
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
  affected contract entry, vectors, and profile map together, plus implementation
  follow-up issues or PRs when bundled assets or implementation behavior are
  affected.
  During pre-1.0, they are allowed only when the release notes label the change
  as breaking and the affected implementation repositories have an explicit
  follow-up path.
- Additive changes introduce new behavior without changing existing vector
  expectations. They require a new contract section or contract entry plus matching
  vectors before any implementation exposes client-server behavior, or a
  `design/ui-surfaces/*.json` change before any implementation exposes a new
  shared Product MVP UI surface.
- Corrections clarify wording, examples, or metadata without changing expected
  public behavior. They may skip vector changes only when the existing vectors
  already capture the intended behavior.

Every pre-1.0 contract, vector, design token, or UI surface change must classify
itself before handoff:

- `breaking`: changes expected public behavior, removes or narrows a field,
  changes an error, changes an advertised capability, changes an acceptance
  flow, or changes a design input that an implementation has already adopted.
- `additive`: adds a contract, vector, field, endpoint, UI surface element, or
  evidence requirement without changing existing expectations.
- `corrective`: fixes wording, links, examples, metadata, or evidence labels
  without changing expected public behavior.

Breaking and deprecation work must record all of the following before release:

- the deprecated or changed behavior;
- the replacement behavior, or an explicit out-of-scope decision;
- migration guidance for affected implementation repositories;
- affected implementation repository issue or PR references;
- whether Houra Product MVP claims or Matrix compatibility claims are affected;
- release notes evidence that names the compatibility classification.

Deprecated behavior must not be left as an unowned TODO. If a replacement is not
ready, the release notes must keep the behavior explicitly out of scope or keep
the older behavior supported until a follow-up issue lands.

Pre-1.0 release notes must identify:

- Changed feature profiles.
- Changed contracts, vectors, design tokens, or UI surfaces.
- Whether the change is breaking, additive, or corrective.
- Required implementation follow-up, or that none is required.
- Deprecated behavior, replacement or out-of-scope decision, migration note,
  and affected implementation issue or PR when applicable.
- Whether the change affects Houra Product MVP, Matrix compatibility, both, or
  neither. These claims must remain separate.

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

For future freeze candidates, milestone releases, and release tags, copy
`docs/releases/TEMPLATE.md` to `docs/releases/<tag>.md` before cutting the tag.
The release record must name the candidate ref, changed contracts, vectors,
design inputs, compatibility classification, claim impact, verification,
implementation adoption evidence, known exclusions, and the separate Product MVP
and Matrix compatibility claim boundaries.

## MVP Readiness Boundary

`full-client` readiness means the covered Houra MVP public contract is
complete enough for implementation repositories to consume this repository as
read-only conformance input. It does not mean Matrix Client-Server API,
federation, identity service, appservice, E2EE, push, VoIP, or administrative
API coverage.

The structural parts of readiness are checked by `dart tool/check_spec.dart`.
Workflow evidence such as implementation adoption reports and GitHub Releases
must be recorded in repository issues, pull requests, or releases.

## Product MVP Release Candidate Boundary

The Product MVP release candidate plan is
`test-vectors/core/product-mvp-release-candidate-plan.json`. It connects the
canonical `houra-spec` ref with the current `houra-server` and `houra-client`
implementation evidence lanes for Product MVP adoption.

The candidate remains blocked until Product MVP happy path evidence, Product
MVP UI surface adoption evidence, and Docker Compose deploy smoke evidence name
their implementation refs, commands, results, blockers, and claim boundaries.
This boundary does not imply Matrix v1.18 full compliance or widen Matrix
advertisement.

## OSS Publication Boundary

The OSS publication readiness plan is
`test-vectors/core/oss-publication-readiness-plan.json`. It defines public
listing, documentation index, trust-signal, package, and registry ordering
without changing the canonical source-of-truth priority.

GitHub Releases may anchor published specification refs, but Context7, OpenSSF
Scorecard, OpenSSF Best Practices Badge, GitHub topics, package registries, and
container registries are non-normative signals. GitHub private vulnerability
reporting is a public-listing prerequisite and must be enabled before treating
the repository as OSS-ready. None of these signals may supersede contracts,
vectors, design inputs, UI surfaces, or release evidence in this repository.

Implementation packages, app artifacts, and container images are owned by their
implementation repositories and require their own readiness evidence before
publication.

## Spec Health Sweeps

Spec health sweeps are release and roadmap hygiene checks, not behavior-change
requests. They inspect whether contracts, vectors, design inputs, supporting
docs, and `tool/check_spec.dart` still agree with this repository's role as
read-only conformance input.

If a sweep finds a coverage or validation gap, either fix it in the current PR
when it is small and local, or split it to a focused spec issue or implementation
adoption issue. If no gap is found, record the checked ref and the absence of
untracked gaps instead of leaving the sweep implicit.
