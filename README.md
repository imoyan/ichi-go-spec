# ichi-go-spec

`ichi-go-spec` is the canonical source of truth for the Okomedev Ichi-Go
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
Compatibility rules for changes after this baseline are defined in
`SOURCE_OF_TRUTH.md`.

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

Stateful vector metadata is allowed under a top-level `given` object when a
vector depends on prior client-visible behavior. The supported MVP shape is:

- `given.previous_request`: a request object using the same method/path/query/body
  conventions as top-level `request`.
- `given.previous_event_id`: a non-empty event id string for message-send retry
  and conflict scenarios.

Conformance runners should execute or model the `given` setup before the vector
request, but their result must still be reported against the vector file's
`name` and `contract`. `given` records only canonical client-visible fixture
state; it must not encode server storage, database rows, or implementation
internals.

Conformance tooling v1 does not define SDK APIs, package layout, storage,
network retry policy, UI behavior, or server behavior. Those remain
implementation concerns unless a `SPEC-*` contract and vector are added here.

`tool/check_spec.dart` validates this specification root itself: top-level
boundary, contract references, profile map coverage, vector shape, and design
token shape. It is not a substitute for a client implementation conformance
harness.

## Ichi-Go MVP 100% Readiness Criteria

`full-client` readiness is scoped only to the Ichi-Go MVP client subset. It is
not a Matrix full-spec coverage claim.

The MVP subset may be called 100% ready when all of these are true:

- Every contract is listed in `CONTRACT_MODULE_MAP.md` with one of the MVP
  profiles: `core`, `auth`, `rooms`, `events`, `messaging`, `sync`, or `media`.
- Every MVP profile has at least one representative vector, and profiles with
  parser or request failure behavior have at least one negative vector.
- Stateful vectors use the documented `given` metadata shape and remain
  implementation-neutral.
- At least one implementation adoption report is recorded from a repository
  consuming this spec as read-only input.
- Conformance and server-alignment guidance names the current vector scope.
- A pre-1.0 release tag and GitHub Release record the changed profiles,
  contracts, vectors, compatibility classification, and implementation
  follow-up.

`tool/check_spec.dart` enforces the local structural parts of this readiness
criteria. Adoption reports, implementation conformance runs, and release
publication remain workflow evidence.

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

## Server Alignment Smoke Checklist

Server alignment checks must treat this repository as the expected client-visible
behavior. They may exercise server endpoints, but must not use server code,
database schema, storage design, or migration files as specification sources.

Use this contract-to-endpoint smoke table:

| Contract | Endpoint smoke | Vector scope |
|---|---|---|
| SPEC-001 | `GET /_ichi-go/client/versions` | `test-vectors/core/versions-basic.json` |
| SPEC-002 | Any non-success response | `test-vectors/core/error-basic.json` |
| SPEC-003 | `GET /_ichi-go/client/login` | `test-vectors/auth/login-flows-basic.json` |
| SPEC-004 | login, whoami, logout | `test-vectors/auth/*.json` |
| SPEC-006 | room create, join, leave, state | `test-vectors/rooms/*.json` |
| SPEC-007 | event parser inputs | `test-vectors/events/*.json` |
| SPEC-008 | send text message | `test-vectors/messaging/*.json` |
| SPEC-009 | room list | `test-vectors/sync/room-list-basic.json` and related room-list vectors |
| SPEC-010 | room timeline | `test-vectors/sync/timeline-*.json` |
| SPEC-011 | incremental sync | `test-vectors/sync/basic-sync.json` and sync error-shape vectors |
| SPEC-020 | media metadata upload/download | `test-vectors/media/*.json` |

If a server response differs from this repository, fix the server by default. If
the vectors are insufficient or the contract is ambiguous, update this
specification repository first and then create affected implementation follow-up
work.

## Long-Term Role

This repository is the first source to update before client implementation
changes. It owns draft contract profiles, canonical vectors, and
platform-neutral theme files. Client repositories should add native adapters and
package metadata only after this repository passes its local checks.

## Implementation Adoption Reports

### okaka-flutter initial adoption

- Implementation repository: `imoyan/okaka-flutter`
- Repository role: Flutter SDK candidate for the Okomedev Ichi-Go client API
  subset.
- Implementation commit inspected: `deb653dfb86d97b1a9e4ba0c1e47ab884a3eba04`
- Spec input inspected: current `main` after SPEC-008 idempotency, SPEC-010
  pagination, and SPEC-020 download metadata updates.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `dart run tool/check_spec_sync.dart` | pass | Reads this spec checkout and validates bundled theme/vector references |
| `flutter analyze` | pass | No analyzer issues |
| `flutter test` | fail | SPEC-008 vector now requires `client_transaction_id`; follow-up is tracked in `imoyan/okaka-flutter#14` |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Existing contract tests passed |
| auth | pass | Existing contract tests passed |
| rooms | pass | Existing contract tests passed |
| events | pass | Existing contract tests passed |
| messaging | follow-up required | SPEC-008 idempotency vector is not implemented yet |
| sync | pass | Existing contract tests passed |
| media | pass | Existing contract tests passed |

No server implementation detail was used as a specification source. The
implementation gap is tracked outside this repository; this repository remains
the canonical behavior source.

## Local Checks

```bash
dart tool/check_spec.dart
```

## License

This specification root is licensed under the Apache License, Version 2.0. See
`LICENSE`.
