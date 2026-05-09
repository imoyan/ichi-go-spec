# houra-spec

`houra-spec` is the canonical repository for the Houra public specification.

Houra is the product and shared specification boundary. The public API namespace
is Houra-owned, and client and server implementation repositories are peers;
neither is canonical.

Implementation repositories must follow this repository's contracts and test
vectors. They must not derive behavior from another implementation repository.

This standalone public specification repository contains canonical contracts,
test vectors, shared design tokens, and platform-neutral UI surface definitions
only;
implementation behavior, package adapters, client-specific details, and
server-specific details belong in implementation repositories.

## Repository Topology

The maintained repository names are:

- `houra-spec`: canonical contracts, test vectors, shared design tokens, and
  platform-neutral UI surfaces.
- `houra-server`: the production TypeScript server implementation.
- `houra-client`: the production React Native client implementation.
- `houra-labs`: experiments, including Flutter client prototypes and alternate
  Go or Dart server prototypes.

## Layout

- `contracts/`: normative API behavior.
- `test-vectors/`: request and response fixtures implementations must pass.
- `design/`: shared platform-neutral theme tokens and UI surface definitions.
- `SOURCE_OF_TRUTH.md`: precedence and change rules.
- `REFERENCE_POLICY.md`: clean-room source policy.
- `FEATURE_PROFILES.md`: feature slices.
- `MODULE_DEPENDENCIES.md`: allowed dependency direction.
- `CONTRACT_MODULE_MAP.md`: contract-to-profile table.
- `tool/check_spec.dart`: local consistency check for contracts, vectors,
  design tokens, and UI surfaces.

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

## Shared Design Inputs

- `design/theme.schema.json`
- `design/themes/smoke.json`
- `design/ui.surface.schema.json`
- `design/ui-surfaces/product-mvp.json`

## Pre-1.0 Baseline

The current pre-1.0 baseline is the committed `core`, `auth`, `rooms`,
`events`, `messaging`, `sync`, and `media` profile set. It includes:

- `contracts/SPEC-*.md`
- `test-vectors/**/*.json`
- `design/theme.schema.json`
- `design/themes/smoke.json`
- `design/ui.surface.schema.json`
- `design/ui-surfaces/product-mvp.json`

This baseline does not freeze implementation behavior, SDK API shape, package
layout, storage policy, framework-specific UI behavior, or server behavior.
Those remain implementation-owned unless this repository adds or changes a
matching contract, vector, design token, or UI surface first.

Release note summary: this baseline publishes the canonical Houra MVP public
contract, representative request/response vectors, shared smoke theme tokens,
and Product MVP UI surface definitions for implementation repositories to
consume as read-only conformance input.
Compatibility rules for changes after this baseline are defined in
`SOURCE_OF_TRUTH.md`.

## Validation

Client implementations should validate request paths, response parsing,
theme-token adapters, and UI surface coverage against the contracts, test
vectors, and design inputs in this repository.
Server implementations should validate request handling and server-provided
responses against the same contracts and vectors.

Change contracts before implementation behavior when expected behavior changes.

Run the local consistency check before publishing or consuming changes:

```bash
dart tool/check_spec.dart
```

## Conformance Tooling v1

Conformance tooling v1 consumes this repository as read-only input. It should
load:

- `contracts/SPEC-*.md` for normative behavior and profile ownership.
- `CONTRACT_MODULE_MAP.md` for feature profile grouping.
- `test-vectors/**/*.json` for request/response and parser fixtures.
- `design/theme.schema.json` and `design/themes/*.json` for token validation.
- `design/ui.surface.schema.json` and `design/ui-surfaces/*.json` for
  platform-neutral UI surface validation.

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
vector depends on prior covered public behavior. The supported MVP shape is:

- `given.previous_request`: a request object using the same method/path/query/body
  conventions as top-level `request`.
- `given.previous_event_id`: a non-empty event id string for message-send retry
  and conflict scenarios.

Conformance runners should execute or model the `given` setup before the vector
request, but their result must still be reported against the vector file's
`name` and `contract`. `given` records only canonical public fixture state; it
must not encode server storage, database rows, or implementation internals.

Conformance tooling v1 does not define SDK APIs, package layout, storage,
network retry policy, framework-specific UI behavior, or server behavior. Those
remain implementation concerns unless a `SPEC-*` contract, vector, design
token, or UI surface is added here.

`tool/check_spec.dart` validates this specification root itself: top-level
boundary, contract references, profile map coverage, vector shape, design token
shape, and UI surface shape. It is not a substitute for implementation
conformance harnesses.

## UI Surface Contract

`design/ui-surfaces/product-mvp.json` defines the platform-neutral Product MVP
operation surface. It records screens, action ids, state ids, text keys,
acceptance flow steps, and current limitations without choosing React Native,
Flutter, Web, native navigation, component hierarchy, animations, or local
session persistence APIs.

Implementation repositories should treat this file as read-only conformance
input. A client may arrange native layouts differently, but it should preserve
the screen semantics, action availability, duplicate-submit prevention,
recoverable error visibility, and `product-mvp-happy-path` acceptance coverage.

Server repositories do not consume UI surfaces directly. Server behavior remains
defined by `contracts/SPEC-*.md` and `test-vectors/**/*.json`.

## Houra MVP 100% Readiness Criteria

`full-client` readiness is scoped only to the covered Houra MVP public
contract. It is not a Matrix full-spec coverage claim.

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
- Product MVP UI readiness names the current UI surface scope.
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
- Record implementation metrics using the fields below, including elapsed time
  and Codex usage when available.
- Run the implementation conformance runner against `contracts/SPEC-*.md`,
  `CONTRACT_MODULE_MAP.md`, and `test-vectors/**/*.json`.
- Report pass/fail by feature profile: `core`, `auth`, `rooms`, `events`,
  `messaging`, `sync`, and `media`.
- Confirm whether bundled `design/themes/*.json` or `design/ui-surfaces/*.json`
  assets changed and whether the implementation needs to refresh copied design
  tokens or UI surface metadata.
- If implementation behavior must change, link the spec PR that changed the
  matching contract, vector, or design token first.
- If behavior is unclear, open a spec issue or PR here before deriving behavior
  from server code, storage design, or implementation internals.

## Implementation Metrics

Implementation repositories should record lightweight delivery metrics in the
implementation issue, pull request, or adoption report. These metrics are
workflow evidence only; they are not part of the public Houra contract.

Required fields:

- Spec input: `houra-spec` commit or tag consumed.
- Implementation target: repository, branch, pull request or issue, and head
  commit.
- Scope: feature profiles, contracts, vectors, design token files, and UI
  surface files consumed or changed.
- Matrix reference: Matrix specification version, source URL, and check time
  used as external protocol context for the implementation work.
- Timing: `started_at`, `ended_at`, `elapsed_seconds`, and `timezone`. Use
  ISO 8601 timestamps with an explicit offset and an IANA timezone name such as
  `Asia/Tokyo`.
- Verification: commands run, pass/fail result, and the head commit verified.
- Outcome: shipped, blocked, deferred, or superseded, with the concrete blocker
  when not shipped.

Codex usage fields:

- Model and execution mode: local task, cloud task, code review, or other.
- Token counts when available: `input_tokens`, `cached_input_tokens`,
  `output_tokens`, and `total_tokens`.
- Credit or message usage when token counts are not exposed but billing or
  usage metadata is available.
- Usage source: `codex_app`, `codex_cli`, `openai_api`, `dashboard`,
  `manual_estimate`, or `unavailable`.
- Accuracy: `exact`, `estimated`, or `unavailable`.

If exact token counts are unavailable, set token count fields to `null`, set
`usage_source` and `accuracy` to `unavailable`, and do not backfill a guessed
numeric value. If an estimate is intentionally useful, mark it as `estimated`,
record the estimation method, and do not compare it directly with exact token
counts.

Recommended additional records:

- Prompt category: spec clarification, implementation, review response,
  conformance fix, release, or monitoring.
- Agent/client context: Codex App, Codex CLI, API script, or GitHub review.
- Decision log: contract ambiguity found, spec-first change made, or
  implementation-only fix made.
- Rework signals: failed verification count, review comments addressed, and
  follow-up issues created.
- Clean-room note: confirmation that no implementation repository was used as a
  behavior source.

Current Matrix reference snapshot:

- Checked at: 2026-05-08 JST.
- Current stable Matrix specification: Matrix 1.18.
- Release date: 2026-03-26.
- Source: `https://spec.matrix.org/v1.18/` and
  `https://matrix.org/blog/2026/03/26/matrix-v1.18-release/`.

This snapshot is a dated planning reference, not a future-current value. Before
starting a later implementation batch, refresh the Matrix specification version
and record the refreshed value in that implementation record.

Example JSONL record:

```jsonl
{"repo":"houra-client","branch":"codex/adopt-media-vectors","pr":null,"spec_commit":"<houra-spec-sha>","implementation_commit":"<implementation-sha>","profiles":["media"],"contracts":["SPEC-020"],"vectors":["test-vectors/media/upload-basic.json"],"matrix_spec_version":"1.18","matrix_spec_source":"https://spec.matrix.org/v1.18/","matrix_spec_checked_at":"2026-05-08T10:00:00+09:00","started_at":"2026-05-08T10:00:00+09:00","ended_at":"2026-05-08T10:42:00+09:00","elapsed_seconds":2520,"timezone":"Asia/Tokyo","model":"gpt-5.3-codex","execution_mode":"local_task","input_tokens":null,"cached_input_tokens":null,"output_tokens":null,"total_tokens":null,"usage_source":"unavailable","accuracy":"unavailable","verification":[{"command":"npm test","result":"pass"}],"outcome":"shipped","clean_room_confirmed":true}
```

## Server Alignment Smoke Checklist

Server alignment checks must treat this repository as the expected public
client-server behavior. They may exercise server endpoints, but must not use
server code, database schema, storage design, or migration files as
specification sources.

Use this contract-to-endpoint smoke table:

| Contract | Endpoint smoke | Vector scope |
|---|---|---|
| SPEC-001 | `GET /_houra/client/versions` | `test-vectors/core/versions-basic.json` |
| SPEC-002 | Any non-success response | `test-vectors/core/error-basic.json` |
| SPEC-003 | `GET /_houra/client/login` | `test-vectors/auth/login-flows-basic.json` |
| SPEC-004 | login, register, whoami, logout | `test-vectors/auth/*.json` |
| SPEC-006 | room create, join, leave, state | `test-vectors/rooms/*.json` |
| SPEC-007 | event parser inputs | `test-vectors/events/*.json` |
| SPEC-008 | send text message | `test-vectors/messaging/*.json` |
| SPEC-009 | room list | `test-vectors/sync/room-list-basic.json` and related room-list vectors |
| SPEC-010 | room timeline | `test-vectors/sync/timeline-*.json` |
| SPEC-011 | incremental sync | `test-vectors/sync/basic-sync.json` and sync error-shape vectors |
| SPEC-020 | media metadata upload/download and content download | `test-vectors/media/*.json` |

If a server response differs from this repository, fix the server by default. If
the vectors are insufficient or the contract is ambiguous, update this
specification repository first and then create affected implementation follow-up
work.

## Long-Term Role

This repository is the first source to update before implementation behavior
changes. It owns draft contract profiles, canonical vectors, and
platform-neutral theme and UI surface files. Client and server repositories
should add native adapters, server behavior, and package metadata only after
this repository passes its local checks.

## Implementation Adoption Reports

### Flutter lab client initial adoption

- Implementation repository: `imoyan/houra-labs`
- Repository role: Flutter lab client candidate for the covered Houra public
  contract.
- Implementation commit inspected: `1e2609beacdb0ed171c721698a86342825f22c79`
- Spec input inspected: current `main` after SPEC-008 idempotency, SPEC-010
  pagination, and SPEC-020 download metadata updates.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `dart run tool/check_spec_sync.dart` | pass | Reads this spec checkout and validates bundled theme/vector references |
| `flutter analyze` | pass | No analyzer issues |
| `flutter test` | pass | SPEC-008 `client_transaction_id` coverage is implemented |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Existing contract tests passed |
| auth | pass | Existing contract tests passed |
| rooms | pass | Existing contract tests passed |
| events | pass | Existing contract tests passed |
| messaging | pass | SPEC-008 idempotency vector is implemented |
| sync | pass | Existing contract tests passed |
| media | pass | Existing contract tests passed |

No server implementation detail was used as a specification source. The
implementation follows this repository as the canonical behavior source.

### TypeScript server MVP adoption

- Implementation repository: `imoyan/houra-server`
- Repository role: production TypeScript server baseline for the covered Houra
  public contract.
- Implementation issue: `imoyan/houra-server#1`
- Implementation pull request: `imoyan/houra-server#2`
- Implementation commit inspected: `4c64718ff1608b99017de1166cd1c74aeebce053`
- Spec behavior input inspected: `5e882e909aaf9a5c7d6af557b0b1d8addb1b50ae`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Production server build |
| `npm test` | pass | 31 tests, including 27 request vectors |
| GitHub Actions `CI / test` | pass | Ran on PR #2 head |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Versions and structured error behavior covered |
| auth | pass | Login, whoami, logout, and token invalidation covered |
| rooms | pass | Create, join, leave, and state endpoints covered |
| events | pass | Event-shaped state, sync, and timeline responses covered |
| messaging | pass | Text send idempotency and conflict behavior covered |
| sync | pass | Room list, timeline, and incremental sync covered |
| media | pass | Base64 upload and metadata download descriptors covered |

No client implementation or lab prototype was used as a specification source.
The server consumes this repository's contracts and request vectors as the
behavior source.

### TypeScript client core MVP adoption

- Implementation repository: `imoyan/houra-client`
- Repository role: UI-free TypeScript client core for the covered Houra public
  contract.
- Implementation issue: `imoyan/houra-client#1`
- Implementation pull request: `imoyan/houra-client#2`
- Implementation commit inspected: `44c23c5868a8a2c62e41b3829ae83dcd1d7a680c`
- Spec behavior input inspected: `5e882e909aaf9a5c7d6af557b0b1d8addb1b50ae`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Client core declaration build |
| `npm test` | pass | 36 tests covering request vectors and parser vectors |
| GitHub Actions `CI / test` | pass | Ran on PR #2 head |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Versions and structured error parsing covered |
| auth | pass | Login, whoami, logout request formation and parsing covered |
| rooms | pass | Room request formation and room parser behavior covered |
| events | pass | Event parser and malformed event rejection covered |
| messaging | pass | Text send request formation and conflict error parsing covered |
| sync | pass | Room list, timeline, and sync parsing covered |
| media | pass | Upload request formation and metadata parser behavior covered |

No server implementation or lab prototype was used as a specification source.
The client consumes this repository's contracts and request/response vectors as
the behavior source.

### Server/client live e2e smoke

- Implementation repository: `imoyan/houra-client`
- Smoke issue: `imoyan/houra-client#3`
- Smoke pull request: `imoyan/houra-client#4`
- Client commit inspected: `e3be2330411ac4952195b5fe17308840bc74ee5b`
- Server target commit: `4c64718ff1608b99017de1166cd1c74aeebce053`
- Spec input inspected: `88053e35195c0b30f77d856f83ad8dd59eebf9ad`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| local live `npm run test:e2e` | pass | Client connected to local `houra-server` over HTTP |
| GitHub Actions `CI / test` | pass | Vector and parser tests |
| GitHub Actions `CI / e2e` | pass | Checked out pinned `houra-server` and ran live HTTP smoke |

E2E smoke covered discovery, login, whoami, room create/join/list/state,
message send and idempotent retry/conflict, sync, timeline pagination, media
upload/metadata, leave, logout, and post-logout unauthorized behavior.

The server is used only as the live HTTP target for connection smoke coverage;
the expected public behavior remains defined by this repository's contracts and
vectors.

### TypeScript server PostgreSQL Product MVP adoption

- Implementation repository: `imoyan/houra-server`
- Repository role: production TypeScript server with PostgreSQL persistence and
  Docker Compose deploy baseline for the covered Houra public contract.
- Implementation issue: `imoyan/houra-server#3`
- Implementation pull request: `imoyan/houra-server#4`
- Implementation commit inspected: `99b614a34b13faba7c84fdd54ee2f31d7960848f`
- Spec behavior input inspected: `v0.2.0-pre.2`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.
- Started at: 2026-05-09T07:17:11+09:00
- Ended at: 2026-05-09T07:33:10+09:00
- Elapsed seconds: 959
- Codex usage: unavailable in the local Codex App session.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Production server build |
| `npm test` | pass | 31 passed, 1 PostgreSQL test skipped by default |
| `DATABASE_URL=... npm run db:migrate` | pass | Applied SQL migration to test PostgreSQL |
| `HOURA_TEST_DATABASE_URL=... npm run test:postgres` | pass | Restart persistence for sessions, rooms, messages, and media metadata |
| `docker compose build` | pass | Server image built with compiled migration runner |
| `docker compose up -d` + live HTTP smoke | pass | login, room create, send text, and sync against PostgreSQL-backed server |
| GitHub Actions `CI / test` | pass | Ran on PR #4 head |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Existing discovery/vector behavior retained |
| auth | pass | DB-backed login, whoami, logout, and hashed access-token session lifecycle |
| rooms | pass | DB-backed create, join, leave, list, and state |
| events | pass | Event rows persist across store restarts |
| messaging | pass | DB-backed send and idempotency key behavior |
| sync | pass | DB-backed room sync and timeline smoke |
| media | pass | Local filesystem storage path with DB-backed media metadata |

Binary media download remains outside this adoption report. Any new binary
download endpoint must be specified here first with contract and vector changes.

No client implementation or lab prototype was used as a specification source.
Server database tables and migrations are implementation evidence only; they do
not define public behavior.

### Expo React Native Product MVP adoption

- Implementation repository: `imoyan/houra-client`
- Repository role: production React Native client with UI-free TypeScript core
  and Expo MVP app layer for the covered Houra public contract.
- Implementation issue: `imoyan/houra-client#6`
- Implementation pull request: `imoyan/houra-client#7`
- Implementation commit inspected: `3a61d505e4ec98e5f8d8d1c10d2279c277f05954`
- Spec behavior input inspected: `v0.2.0-pre.2`
- Server target for live smoke: `houra-server`
  `99b614a34b13faba7c84fdd54ee2f31d7960848f`
- Matrix reference: Matrix Specification 1.18, checked on 2026-05-08 JST.
- Started at: 2026-05-09T07:37:41+09:00
- Ended at: 2026-05-09T08:04:17+09:00
- Elapsed seconds: 1596
- Codex usage: unavailable in the local Codex App session.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | Core and Expo app TypeScript checks |
| `npm run build` | pass | UI-free client core declaration build |
| `npm test` | pass | 38 passed, 1 live e2e skipped by default |
| `npx expo config --type public` | pass | Expo SDK 55 public config resolved |
| `npx expo export --platform ios --output-dir /tmp/houra-client-expo-export --clear` | pass | Metro bundle smoke for app entry and Expo UI imports |
| `HOURA_E2E_BASE_URL=http://localhost:3000 npm run test:e2e` | pass | Live happy path against PostgreSQL-backed Docker Compose server |
| GitHub Actions `CI / test` | pass | Ran on PR #7 head |
| GitHub Actions `CI / e2e` | pass | Live HTTP smoke ran on PR #7 head |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| core | pass | Existing core request/parsing behavior retained |
| auth | pass | Login and logout exposed through Expo UI; session stored by host app adapter |
| rooms | pass | Room list and create flow exposed through Expo UI |
| events | pass | Timeline event parsing reused from UI-free core |
| messaging | pass | Message composer uses core text-send API |
| sync | pass | Live e2e covers sync against PostgreSQL-backed server |
| media | pass | Media upload metadata flow exposed through Expo UI |

Dependency audit note: the client reported a moderate PostCSS advisory through
Expo CLI / Metro config. The available `npm audit fix --force` path would
downgrade Expo to 49, so the implementation recorded it as follow-up evidence
rather than weakening the Expo SDK 55 baseline.

No server implementation or lab prototype was used as a specification source.
The server was used only as the live HTTP target for connection smoke coverage;
the expected public behavior remains defined by this repository's contracts and
vectors.

### Product MVP pre-release readiness

- Release target: `v0.2.0-pre.3`
- Compatibility classification: workflow/adoption evidence update only.
- Changed public behavior profiles: none.
- Changed contracts: none.
- Changed vectors: none.
- Implementation evidence added: PostgreSQL-backed `houra-server` Product MVP
  adoption and Expo React Native `houra-client` Product MVP adoption.
- Completion claim: Houra Product MVP subset is implementation-ready for the
  covered contract/vector scope. This is not a Matrix full-spec compliance
  claim.
- Remaining known gaps: binary media download endpoint, production account
  registration, federation, encrypted media, simulator/manual UI QA, and the
  recorded Expo CLI / PostCSS audit follow-up.

### Binary media download adoption

- Spec release consumed: `v0.2.0-pre.4`
- Changed profile: `media`
- Changed contract: `SPEC-020`
- Changed vectors: `download-content-basic`, `auth-required-content`,
  `auth-required-content-missing-token`, and `missing-media-content`
- Compatibility classification: additive pre-1.0 MVP media behavior.

Server adoption:

- Implementation repository: `imoyan/houra-server`
- Implementation issue: `imoyan/houra-server#7`
- Implementation pull request: `imoyan/houra-server#8`
- Implementation commit inspected: `37e6562f77cf1c6a8886a9838f0fe141c83c9486`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this adoption is not Matrix full compliance.
- Started at: 2026-05-09T08:29:56+09:00
- Ended at: 2026-05-09T08:36:33+09:00
- Elapsed seconds: 397
- Codex usage: unavailable in the local Codex App session.

Server observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Production server build |
| `npm test` | pass | 36 passed, 1 PostgreSQL test skipped by default |
| `HOURA_TEST_DATABASE_URL=... npm run test:postgres` | pass | Restart persistence includes media content download |
| Docker Compose live content smoke | pass | `media1/content` returned `aGVsbG8=` |
| GitHub Actions `CI / test` | pass | Ran on PR #8 head |

Client adoption:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#10`
- Implementation pull request: `imoyan/houra-client#11`
- Implementation commit inspected: `588965c239e4efb6c005ec326031255aca8ecb8e`
- Server target for live smoke: `houra-server`
  `37e6562f77cf1c6a8886a9838f0fe141c83c9486`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this adoption is not Matrix full compliance.
- Started at: 2026-05-09T08:39:36+09:00
- Ended at: 2026-05-09T09:03:19+09:00
- Elapsed seconds: 1423
- Codex usage: unavailable in the local Codex App session.

Client observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | Core and Expo app TypeScript checks |
| `npm run build` | pass | UI-free client core declaration build |
| `npm test` | pass | 42 passed, 1 live e2e skipped by default |
| `npx expo config --type public` | pass | Expo SDK 55 public config resolved |
| `npx expo export --platform ios --output-dir /tmp/houra-client-expo-export --clear` | pass | Metro bundle smoke for app entry and Expo UI imports |
| `HOURA_E2E_BASE_URL=http://localhost:3000 npm run test:e2e` | pass | Live happy path includes media content download |
| GitHub Actions `CI / test` | pass | Ran on PR #11 head |
| GitHub Actions `CI / e2e` | pass | Pinned `houra-spec` v0.2.0-pre.4 and `houra-server` PR #8 merge commit |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| media | pass | Server and client both adopted same-origin binary media content download |

No implementation repository was used as a behavior source. The server remains
only the live HTTP target for connection smoke coverage; the expected public
behavior remains defined by this repository's contracts and vectors.

### Product MVP pre-release readiness after binary media download

- Release target: `v0.2.0-pre.5`
- Compatibility classification: workflow/adoption evidence update for
  `v0.2.0-pre.4` public behavior.
- Changed public behavior profiles: none in this release; `media` behavior
  changed in `v0.2.0-pre.4`.
- Changed contracts: none.
- Changed vectors: none.
- Implementation evidence added: binary media download adoption for
  `houra-server` and `houra-client`.
- Completion claim: Houra Product MVP subset includes binary media content
  download for the covered contract/vector scope. This is not a Matrix
  full-spec compliance claim.
- Remaining known gaps: production account registration, federation, encrypted
  media, range/resumable media download, thumbnails, simulator/manual UI QA, and
  the recorded Expo CLI / PostCSS audit follow-up.

### Account registration adoption

- Spec release consumed: `v0.2.0-pre.6`
- Changed profile: `auth`
- Changed contract: `SPEC-004`
- Changed vectors: `register-basic`, `register-duplicate-user`, and
  `register-invalid`
- Compatibility classification: additive pre-1.0 MVP auth behavior.

Server adoption:

- Implementation repository: `imoyan/houra-server`
- Implementation issue: `imoyan/houra-server#9`
- Implementation pull request: `imoyan/houra-server#10`
- Implementation commit inspected: `d3711878ca35758e9510463b9da6afcd42ada304`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this adoption is not Matrix full compliance.
- Matrix source checked: 2026-05-09T11:00:00+09:00 from
  `https://spec.matrix.org/` and
  `https://matrix.org/blog/2026/03/26/matrix-v1.18-release/`.
- Started at: 2026-05-09T10:39:20+09:00
- Ended at: 2026-05-09T10:44:02+09:00
- Elapsed seconds: 282
- Codex usage: unavailable in the local Codex App session.

Server observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | TypeScript strict check |
| `npm run build` | pass | Production server build |
| `npm test` | pass | 41 passed, 1 PostgreSQL test skipped by default |
| `npm run db:migrate` | pass | PostgreSQL schema applied before restart persistence tests |
| `HOURA_TEST_DATABASE_URL=... npm run test:postgres` | pass | Restart persistence covers registered user sessions and login |
| Docker Compose live registration smoke | pass | Registered a user and verified `whoami` with the returned bearer token |
| GitHub Actions `CI / test` | pass | Ran on PR #10 head |

Client adoption:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#12`
- Implementation pull request: `imoyan/houra-client#13`
- Implementation commit inspected: `0be1a22cf770c6fb8a192f391d25eee06966c54c`
- Server target for live smoke: `houra-server`
  `d3711878ca35758e9510463b9da6afcd42ada304`
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this adoption is not Matrix full compliance.
- Matrix source checked: 2026-05-09T11:00:00+09:00 from
  `https://spec.matrix.org/` and
  `https://matrix.org/blog/2026/03/26/matrix-v1.18-release/`.
- Started at: 2026-05-09T10:47:45+09:00
- Ended at: 2026-05-09T10:50:35+09:00
- Elapsed seconds: 170
- Codex usage: unavailable in the local Codex App session.

Client observed checks:

| Check | Result | Notes |
|---|---|---|
| `npm run typecheck` | pass | Core and Expo app TypeScript checks |
| `npm run build` | pass | UI-free client core declaration build |
| `npm test` | pass | 45 passed, 1 live e2e skipped by default |
| `npx expo config --type public` | pass | Expo SDK 55 public config resolved |
| `npx expo export --platform ios --output-dir /tmp/houra-client-expo-export --clear` | pass | Metro bundle smoke for app entry and Expo UI imports |
| `HOURA_E2E_BASE_URL=http://localhost:3000 npm run test:e2e` | pass | Live happy path includes register, whoami, logout, login, room, message, sync, media, and logout |
| GitHub Actions `CI / test` | pass | Pinned `houra-spec` v0.2.0-pre.6 |
| GitHub Actions `CI / e2e` | pass | Pinned `houra-spec` v0.2.0-pre.6 and `houra-server` PR #10 merge commit |

Profile status:

| Profile | Status | Notes |
|---|---|---|
| auth | pass | Server and client both adopted password account registration |

No implementation repository was used as a behavior source. The server remains
only the live HTTP target for connection smoke coverage; the expected public
behavior remains defined by this repository's contracts and vectors.

### Product MVP pre-release readiness after account registration

- Release target: `v0.2.0-pre.7`
- Compatibility classification: workflow/adoption evidence update for
  `v0.2.0-pre.6` public behavior.
- Changed public behavior profiles: none in this release; `auth` behavior
  changed in `v0.2.0-pre.6`.
- Changed contracts: none.
- Changed vectors: none.
- Implementation evidence added: account registration adoption for
  `houra-server` and `houra-client`.
- Completion claim: Houra Product MVP subset includes password account
  registration for the covered contract/vector scope. This is not a Matrix
  full-spec compliance claim.
- Remaining known gaps outside current MVP: federation, encrypted media,
  range/resumable media download, thumbnails, email verification, password
  reset, IdP integration, simulator/manual UI QA, and the recorded Expo CLI /
  PostCSS audit follow-up.

### Product MVP UI surface contract

- Spec issue: `imoyan/houra-spec#65`
- Changed design inputs: `design/ui.surface.schema.json` and
  `design/ui-surfaces/product-mvp.json`
- Compatibility classification: additive pre-1.0 Product MVP UI surface
  definition.
- Changed public API contracts: none.
- Changed vectors: none.
- Server behavior impact: none.
- Implementation follow-up: client implementations should map their native UI
  affordances to the `product-mvp` screen, action, state, text key, and
  acceptance-flow ids without deriving behavior from another implementation.

The UI surface contract is platform-neutral. It is intentionally not a React,
Expo, Flutter, SwiftUI, Android, or Web component contract. It exists so each
client implementation can prove that it exposes the same Product MVP operation
surface while keeping framework-specific layout, navigation, local session
storage, accessibility affordances, and component structure implementation-owned.

### Product MVP pre-release readiness after UI surface contract

- Release target: `v0.2.0-pre.8`
- Compatibility classification: additive UI surface contract.
- Changed public behavior profiles: none; this release adds platform-neutral UI
  surface conformance input.
- Changed contracts: none.
- Changed vectors: none.
- Changed design inputs: `design/ui.surface.schema.json` and
  `design/ui-surfaces/product-mvp.json`.
- Required implementation follow-up: `houra-client` should record Expo MVP UI
  coverage against `product-mvp` and keep Expo-specific acceptance steps
  separate from the generic UI surface.
- Completion claim: Houra Product MVP now has a reusable UI surface definition
  for client implementations. This is not a Matrix full-spec compliance claim.

## Local Checks

```bash
dart tool/check_spec.dart
```

## License

This specification root is licensed under the Apache License, Version 2.0. See
`LICENSE`.
