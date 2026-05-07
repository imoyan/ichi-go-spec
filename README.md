# chawan-product-spec

`chawan-product-spec` is the canonical source of truth for the Okomedev Chawan
client API subset.

Implementation repositories must follow this repository's contracts and test
vectors. They must not derive behavior from a server implementation.

This standalone public specification repository contains canonical contracts,
test vectors, and shared design tokens only;
implementation behavior, package adapters, and server-specific details belong
in implementation repositories.

## Layout

- `contracts/`: normative API behavior.
- `test-vectors/`: request and response fixtures implementations must pass.
- `design/`: shared platform-neutral theme tokens.
- `SOURCE_OF_TRUTH.md`: precedence and change rules.
- `REFERENCE_POLICY.md`: clean-room source policy.
- `FEATURE_PROFILES.md`: feature slices.
- `MODULE_DEPENDENCIES.md`: allowed dependency direction.
- `CONTRACT_MODULE_MAP.md`: contract-to-profile table.
- `tool/check_spec.dart`: local consistency check for contracts, vectors, and
  design tokens.

## Contracts

- `contracts/SPEC-001-discovery-versions.md`
- `contracts/SPEC-002-error-model.md`
- `contracts/SPEC-003-login-flow-discovery.md`
- `contracts/SPEC-004-login-session.md`
- `contracts/SPEC-006-room-model.md`
- `contracts/SPEC-007-event-model.md`
- `contracts/SPEC-008-send-message.md`
- `contracts/SPEC-009-room-list.md`
- `contracts/SPEC-010-timeline.md`
- `contracts/SPEC-011-basic-sync.md`
- `contracts/SPEC-020-media.md`

## Shared Design Tokens

- `design/theme.schema.json`
- `design/themes/smoke.json`

## Pre-1.0 Baseline

The current pre-1.0 baseline is the committed `core`, `auth`, `rooms`,
`events`, `messaging`, `sync`, and `media` profile set. It includes:

- `contracts/SPEC-*.md`
- `test-vectors/**/*.json`
- `design/theme.schema.json`
- `design/themes/smoke.json`

This baseline does not freeze implementation behavior, SDK API shape, package
layout, storage policy, UI behavior, or server behavior. Those remain
implementation-owned unless this repository adds or changes a matching contract,
vector, or design token first.

Release note summary: this baseline publishes the canonical MVP client API
subset, representative request/response vectors, and shared smoke theme tokens
for implementation repositories to consume as read-only conformance input.

## Validation

Client implementations should validate request paths, response parsing, and
theme-token adapters against the contracts and test vectors in this repository.

Change contracts before implementation behavior when expected behavior changes.

Run the local consistency check before publishing or consuming changes:

```bash
dart tool/check_spec.dart
```

## Conformance Tooling v1

Conformance tooling v1 is a client-side harness that consumes this repository as
read-only input. It should load:

- `contracts/SPEC-*.md` for normative behavior and profile ownership.
- `CONTRACT_MODULE_MAP.md` for feature profile grouping.
- `test-vectors/**/*.json` for request/response and parser fixtures.
- `design/theme.schema.json` and `design/themes/*.json` for token validation.

The harness output should be a pass/fail report per feature profile and vector,
with enough detail for the implementation repository to identify the failed
contract or fixture. The v1 target profiles are the existing `core`, `auth`,
`rooms`, `events`, `messaging`, `sync`, and `media` slices.

At minimum, a v1 runner should expose one result per vector with:

- Feature profile from `CONTRACT_MODULE_MAP.md`.
- Vector name from the vector file's `name` field.
- Contract id from the vector file's `contract` field.
- `pass` or `fail` status.
- Failure detail that identifies the failed contract expectation, fixture field,
  or parser category without requiring server implementation context.

The runner may adapt each vector to an implementation-specific test harness, but
the reported result must remain traceable to the canonical vector file. A single
failed vector should not prevent the runner from reporting the remaining vector
results.

Conformance tooling v1 does not define SDK APIs, package layout, storage,
network retry policy, UI behavior, or server behavior. Those remain
implementation concerns unless a `SPEC-*` contract and vector are added here.

`tool/check_spec.dart` validates this specification root itself: top-level
boundary, contract references, profile map coverage, vector shape, and design
token shape. It is not a substitute for a client implementation conformance
harness.

## Implementation Follow-Up Checklist

When an implementation repository adopts this baseline, copy this checklist into
the implementation issue or pull request and fill in implementation-specific
links there:

- Record the consumed spec version, tag, or commit.
- Run the implementation conformance runner against `contracts/SPEC-*.md`,
  `CONTRACT_MODULE_MAP.md`, and `test-vectors/**/*.json`.
- Report pass/fail by feature profile: `core`, `auth`, `rooms`, `events`,
  `messaging`, `sync`, and `media`.
- Confirm whether bundled `design/themes/*.json` assets changed and whether the
  implementation needs to refresh copied design tokens.
- If SDK behavior must change, link the spec PR that changed the matching
  contract, vector, or design token first.
- If behavior is unclear, open a spec issue or PR here before deriving behavior
  from server code, storage design, or implementation internals.

## Long-Term Role

This repository is the first source to update before client implementation
changes. It owns draft contract profiles, canonical vectors, and
platform-neutral theme files. Client repositories should add native adapters and
package metadata only after this repository passes its local checks.

## Local Checks

```bash
dart tool/check_spec.dart
```

## License

This specification root is licensed under the Apache License, Version 2.0. See
`LICENSE`.
