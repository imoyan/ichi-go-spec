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
- `CHANGELOG.md`: archived Implementation Adoption Reports for earlier
  `v0.2.0-pre.X` releases. The current baseline lives in this README.
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
- `contracts/SPEC-030-matrix-client-versions.md`
- `contracts/SPEC-031-matrix-foundation.md`
- `contracts/SPEC-032-matrix-auth-session.md`
- `contracts/SPEC-033-matrix-registration.md`
- `contracts/SPEC-034-matrix-devices-sessions.md`
- `contracts/SPEC-035-matrix-room-membership-state.md`
- `contracts/SPEC-036-matrix-send-event-messages.md`
- `contracts/SPEC-037-matrix-sync-mvp.md`
- `contracts/SPEC-038-matrix-media-mvp.md`
- `contracts/SPEC-039-matrix-client-server-mvp-live-e2e-gate.md`
- `contracts/SPEC-040-matrix-event-dag-auth-events.md`
- `contracts/SPEC-041-matrix-state-snapshot-resolution.md`
- `contracts/SPEC-042-matrix-room-versions-gate.md`

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

## Shared Implementation Strategy

This section is non-normative implementation guidance for readers evaluating
Houra's long-term multi-language direction. It does not define a public Houra
contract, Matrix compliance claim, test vector, design token, or UI surface.

Houra is expected to support multiple implementation ecosystems over time:
TypeScript clients and servers, Dart and Flutter clients, and later native
Swift, Kotlin, or other adapters. The project should avoid making any one
implementation repository canonical. Public behavior remains fixed here, in
`contracts/SPEC-*.md`, `test-vectors/`, and shared design inputs. Shared
implementation artifacts are allowed only as consumers of those inputs.

Rust is the preferred first candidate for a shared protocol core because it can
serve browser, Node.js, Dart native, Flutter native, and other ecosystems
through thin bindings. Rust is not a required implementation language, and it is
not the specification source. Each protocol area may stay implementation-owned,
move into a shared Rust core, or split by language when that is more practical
for performance, packaging, or ecosystem fit.

The goal is to share the protocol logic that most often drifts between client
and server implementations: request and response parsing, validation,
identifier grammar, URI grammar, event content shape, transaction and
idempotency semantics, canonical JSON, signing inputs, and reusable vector
assertions. Sharing those areas can reduce mismatches between a TypeScript
client, a TypeScript server, a Dart client, and later native clients.

The goal is not to centralize application policy. Transport, database storage,
secure storage, auth token persistence, retry scheduling, logging, UI state,
framework lifecycle, packaging, and deployment policy remain adapter-owned
unless a later `SPEC-*` contract defines public behavior. Those parts differ
too much across Vue, Next, Node.js, Expo, Flutter native, Flutter web, and
server runtimes to force into a single core without harming flexibility.

### Coupling and dependency policy

Shared code should be deliberately small, but it should not avoid mainstream
dependencies just to look dependency-free. Well-established libraries that are
central to protocol correctness may be direct dependencies of the pure core.
Dependencies that are heavy, platform-shaped, frequently replaced, or close to
host-application policy should live outside the core.

Dependency policy values:

- `core-hard-dep`: a mainstream, low-risk dependency that is directly useful for
  protocol correctness and acceptable in the pure Rust core.
- `extension-dep`: a heavy or optional dependency, such as crypto, that may be
  shared but should live in an extension crate or optional package.
- `binding-dep`: a dependency needed only to expose Rust to an ecosystem, such
  as `wasm-bindgen`, N-API, or Dart FFI glue.
- `adapter-owned`: an implementation or host-application dependency, such as
  HTTP clients, secure storage, UI frameworks, retry schedulers, or logging.
- `avoid-shared`: a dependency or behavior that should not be shared because it
  would make the common path slower, brittle, or unnatural for one ecosystem.

The shared core should expose coarse-grained APIs so bindings do not pay a large
FFI, WASM, or N-API call cost for every small field. A parser or validator
should accept one protocol payload and return one structured result, rather
than requiring many cross-boundary calls. Public TypeScript and Dart facades
should remain stable even if the Rust implementation changes internally. Rust
ABI compatibility should be tracked with an `abi_version` and artifact manifest
before any implementation repository treats a shared artifact as adopted.

### TypeScript and Dart backend strategy

The TypeScript and Dart ecosystems need different bindings for different
runtimes:

- TypeScript browser, Vue, and Next client code should prefer WebAssembly built
  from the Rust core, using the Rust/WebAssembly ecosystem around
  `wasm-bindgen`.
- TypeScript Node.js and Next server code should prefer N-API bindings for
  native performance and package ergonomics.
- TypeScript edge or restricted serverless runtimes should keep a WebAssembly
  fallback when native add-ons are unavailable.
- Dart CLI, Dart server, and Flutter native code should use a C ABI exposed to
  `dart:ffi`.
- Dart web and Flutter web should call a WebAssembly JavaScript wrapper through
  `dart:js_interop`; they should not depend on `dart:ffi`.

This split follows the current Dart direction where `dart:js_interop` is the
web interop layer and `package:web` is the long-term web API package designed
with Wasm compatibility in mind. The Dart native path and Dart web path should
therefore share the same Dart facade API while using different backends through
conditional imports.

### Build and distribution policy

Rust compile time should not become a tax on every application developer.
Implementation packages should publish prebuilt artifacts for supported
platforms wherever practical:

- npm packages can include WebAssembly artifacts for browsers and N-API
  binaries for Node.js platforms.
- Dart packages can include or download native libraries for supported Flutter
  and Dart native platforms, while using the WebAssembly JavaScript wrapper on
  web.
- CI should rebuild Rust artifacts when the shared core, extension crates, or
  binding crates change, not when an application changes only adapter policy,
  UI, transport, or storage.

Feature flags are useful for stable build variants, but frequently changed
policy should not become a Cargo feature. Changing Cargo features usually means
rebuilding the Rust artifact. Runtime policy and ecosystem-specific behavior
should stay in the TypeScript or Dart facade when that keeps application
iteration faster.

### Performance rule

Sharing is optional. An area should not be moved into shared code if the
cross-language boundary, binary size, startup cost, or packaging cost makes the
result meaningfully worse than a local implementation. The default performance
gate is that shared protocol logic should stay within roughly a p95 `+10%` cost
of the adapter-native implementation for representative vector batches, or be
clearly hidden by network, disk, or UI latency. If that gate fails, record the
area as `adapter-owned`, `language-family`, or `avoid-shared` instead of forcing
common code.

Reference documents for the current binding direction:

- Dart JavaScript interop:
  <https://dart.dev/interop/js-interop>
- Dart `package:web` migration and Wasm-compatible web interop direction:
  <https://dart.dev/interop/js-interop/package-web>
- Dart C interop with `dart:ffi`:
  <https://dart.dev/interop/c-interop>
- Rust/WebAssembly bindings:
  <https://rustwasm.github.io/docs/wasm-bindgen/>
- Rust Node.js bindings:
  <https://napi.rs/>

External reference snapshot:

- Checked at: 2026-05-09T23:37:23+09:00
- Timezone: Asia/Tokyo
- Documentation lookup: Context7
- Dart reference: official Dart docs describe `dart:js_interop` and
  `package:web` as the current web interop direction, including Wasm-compatible
  browser API access, while `dart:ffi` remains the native C interop path.
- Rust/WebAssembly reference: `wasm-bindgen` is the current Rust-focused bridge
  for rich interaction between WebAssembly modules and JavaScript, including
  generated JavaScript and TypeScript binding support.
- Rust/Node reference: NAPI-RS targets Rust-built Node.js native add-ons and
  supports cross-platform prebuilt package distribution to avoid making every
  Node consumer compile Rust locally.

This snapshot is planning evidence for the non-normative shared implementation
strategy. It does not create a public Houra contract, require Rust adoption, or
replace per-implementation verification.

Implementation sharing statuses:

- `spec-only`: only the specification inputs are shared; implementation stays
  per repository or per language.
- `rust-candidate`: suitable for a Rust shared core, but not a required
  dependency until parity evidence exists.
- `rust-adopted`: a Rust shared core has passed parity tests for the area and
  may be used by adapters.
- `adapter-owned`: framework, runtime, or host-application behavior should stay
  in the adapter or application layer.
- `split-by-language`: many languages can share one implementation, but one or
  more languages may reasonably keep a separate implementation.

Implementation reach values:

- `client+server`: the same pure protocol logic can be consumed by client and
  server implementations.
- `client-only`: the logic is reusable across clients but not expected to run
  in servers.
- `server-only`: the logic is reusable across servers but not expected to run
  in clients.
- `adapter-only`: the behavior belongs to framework, runtime, or host
  application adapters.
- `language-family`: the behavior may be shared inside one language ecosystem
  while other languages keep separate implementations.

### Implementation Sharing Matrix

This matrix tracks sharing intent and evidence. It is a planning and adoption
record, not a conformance checklist. Rows should explicitly identify whether an
area is shared across clients, servers, both sides, or only inside adapters so
client/server commonality is not lost during planning.

| Area | Current sharing status | Implementation reach | Dependency policy | TS backend | Dart backend | Shared candidate | Adapter-owned responsibilities | Split trigger | Rebuild impact | Prebuilt artifact | Performance gate |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Matrix versions request/response handling | `rust-candidate` | `client+server` | `core-hard-dep` allowed for JSON parsing | WASM for browser and Next client; N-API for Node and Next server; WASM fallback for edge runtimes | `dart:ffi` for native; `dart:js_interop` to call the WASM JS wrapper on web | Rust protocol parser and validator for `SPEC-030` request and response shape | Fetching `/_matrix/client/versions`, cache policy, and feature gating | A runtime cannot consume the shared artifact without larger packaging cost than local parsing | Low after prebuilt artifacts; changing facade policy should not rebuild core | npm WASM, npm N-API, Dart native library, Dart web WASM wrapper | Server emission and client parsing pass against `test-vectors/core/matrix-client-versions-basic.json`; p95 within `+10%` of local parsing |
| Matrix / Houra error parsing and emission | `rust-candidate` | `client+server` | `core-hard-dep` allowed for stable JSON and enum helpers | WASM / N-API through the TypeScript facade | Dart facade dispatches to FFI or JS interop backend | Shared error envelope and Matrix `M_*` vocabulary parser / builder | HTTP status handling, retry policy, telemetry, and user-facing messages | Platform error models require native exception or result types outside the shared ABI | Low; adding host-specific error text stays outside Rust | Same as protocol core artifacts | Vectors cover client parsing and server emission without adapter-specific fields; no measurable UI-path regression |
| Identifier and URI validation | `rust-candidate` | `client+server` | `core-hard-dep` allowed for regex or parser utilities if they are mainstream and portable | WASM / N-API through the TypeScript facade | FFI on native and JS interop on web | Matrix and Houra identifier, room ID, event ID, user ID, content URI, and namespace validators | Input timing, UI validation display, and normalization before storage | A platform requires native text or URL APIs for correctness, accessibility, or locale behavior | Medium if parser dependencies change; stable grammar updates should be batched | Prebuilt parser artifacts per supported runtime | Positive and negative grammar vectors pass in client and server harnesses; boundary overhead is hidden by validation batch size |
| Event content and message schema validation | `rust-candidate` | `client+server` | `core-hard-dep` allowed for JSON schema-like validation only when it stays protocol-focused | WASM / N-API for canonical validation; TS may keep permissive draft typing | FFI / JS interop for canonical validation; Dart may keep permissive draft models | Shared event type, message content, state key, and redaction shape validators | Rich composer UX, server persistence, timeline indexing, moderation policy, and draft states | A client needs permissive draft validation while servers require stricter acceptance rules | Medium; schema changes rebuild shared validators but not UI composer policy | Protocol validator artifacts plus native/web facade packages | Client compose fixtures and server acceptance/rejection vectors agree on canonical shapes; validation batch p95 stays within `+10%` |
| Transaction ID and idempotency semantics | `rust-candidate` | `client+server` | `core-hard-dep` only for small deterministic helpers | WASM / N-API helper through TS facade | FFI / JS interop helper through Dart facade | Transaction ID grammar, idempotency-key comparison, and replay classification helpers | Retry scheduling, persistence of sent-message state, offline queueing, and conflict UI | Offline clients need language-native queue behavior that cannot share the same runtime | Low; queue policy changes should not rebuild Rust | Small helper artifact bundled with protocol core | Retry and conflict vectors pass with identical transaction classification; local queue performance is not gated on Rust |
| Canonical JSON / signing helpers | `rust-candidate` | `client+server` | `core-hard-dep` for canonicalization and hash primitives; `extension-dep` for heavier signing stacks | WASM for browser-safe canonicalization; N-API for Node signing helpers when native crypto is useful | FFI for native signing helpers; JS interop/WASM for web canonicalization | Canonical JSON, hash, and signing input helper primitives | Key storage, key rotation policy, secure enclave integration, and request transport | Native crypto policy or platform keychain constraints require separate bindings | Medium to high when crypto dependencies change; isolate heavy crypto outside the pure core | Separate core and crypto extension artifacts | Cross-language canonicalization fixtures produce byte-identical output; crypto extension has its own p95 and binary-size gate |
| Room version auth/state resolution | `rust-candidate` | `server-only` | `extension-dep` unless the algorithm is small enough for pure core | N-API for Node servers; WASM only for tooling or tests | Usually not used by Dart clients; Dart server may use FFI if adopted | Room-version-aware auth events, state resolution, and event validation helpers | Persistent event store layout, indexing, sync pagination, conflict recovery UI, and federation policy | Performance, database coupling, or federation deployment needs a server-native path | High; keep database and storage policy outside the Rust algorithm crate | Server-side native artifact only until a client/tooling use case exists | Room-version fixtures and restart-safe server integration tests pass; algorithm cost improves or matches local implementation |
| E2EE bridge | `split-by-language` | `language-family` | `extension-dep`; never hand-roll Olm or Megolm in this repository | Use maintained Matrix crypto bindings where available; TS facade should not own secure storage | Use maintained native or Dart-compatible crypto binding when it fits the target | Wrapper around a maintained Matrix crypto implementation, not hand-rolled Olm or Megolm | Secure storage, device trust UI, backup UX, native keychain access, and background task policy | A target ecosystem already has a maintained native Matrix crypto binding with better support | High; isolate from pure core and publish separately | Separate crypto artifacts per ecosystem and platform | Encrypted-room send, receive, backup, restore, and verification flows pass in each adopted language |
| HTTP transport / retry / cancellation | `adapter-owned` | `adapter-only` | `adapter-owned` or `avoid-shared` | Native `fetch`, framework client, or Node HTTP stack chosen by the host | Dart `http`, platform channel, or framework-owned client chosen by the host | None by default; shared code may expose request descriptors only | Fetch/client selection, retry, timeout, cancellation, proxy, cookies, and platform network policy | A language family shares a transport runtime and can add it without constraining others | None for Rust when policy changes stay in adapters | No Rust artifact required | Adapter tests prove host-owned cancellation and retry behavior; shared descriptors do not add request latency |
| Token storage / secure storage | `adapter-owned` | `adapter-only` | `adapter-owned` | Browser storage, server secret store, or Expo secure storage selected by the host | Flutter secure storage, platform keychain, or server secret store selected by the host | None | Secure storage, token refresh timing, logout cleanup, and process lifecycle | A platform has a common secure-storage abstraction that still keeps host ownership explicit | None for Rust | No Rust artifact required | Logout and restore tests prove tokens are not persisted by the UI-free core |
| UI surface rendering | `adapter-owned` | `adapter-only` | `adapter-owned` | Vue, Next.js, React Native, or other UI layer renders platform-neutral surfaces | Flutter, native Dart UI, or other UI layer renders platform-neutral surfaces | Platform-neutral UI surface JSON only | Component hierarchy, accessibility affordances, navigation, layout, gestures, and framework state | A design-system adapter can be shared within one ecosystem without leaking into protocol behavior | None for Rust | No Rust artifact required | UI surface conformance maps required operation and acceptance-flow IDs without forcing component structure |

## Matrix v1.18 Compliance Matrix

This section is the planning boundary for moving from the Houra Product MVP
subset toward Matrix compliance. It does not by itself change any public
Houra contract, vector, design token, or UI surface.

Matrix reference snapshot:

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/>
- Release note: <https://matrix.org/blog/2026/03/26/matrix-v1.18-release/>
- Checked at: 2026-05-09T15:29:22+09:00
- Timezone: Asia/Tokyo

Matrix compliance must be tracked by API domain, not as a single vague label:

| Matrix domain | v1.18 scope source | Current Houra state | Target gate |
|---|---|---|---|
| Client-Server API | `/_matrix/client/*`, media, auth, sync, rooms, user data, devices, reporting, admin capabilities | Product MVP covers a small `/_houra/client/*` subset; `SPEC-030` through `SPEC-038` add Matrix versions, auth/session, registration, devices, room create/join/leave/state, send event/messages, sync, and media upload/download contracts; `SPEC-039` defines the integrated live e2e adoption gate | Matrix-compatible endpoint namespace, response shapes, error codes, representative conformance vectors, and live server/client MVP smoke pass |
| Server-Server API | federation discovery, signed transactions, PDUs/EDUs, event auth, joins/leaves, invites, backfill, key APIs, policy servers | Not implemented | A second homeserver can federate, exchange signed room events, validate auth, and recover state across restart |
| Application Service API | appservice registration, namespace ownership, transactions, sender localpart, bridge-style event delivery | Not implemented | A registered appservice receives transactions and can puppet/send events within its declared namespaces |
| Identity Service API | third-party identifier validation and lookup | Not implemented | Either explicitly out of supported deployment scope or implemented as a separate identity component with conformance evidence |
| Push Gateway API | push notification gateway contracts | Not implemented | Either explicitly out of supported deployment scope or implemented with privacy-aware notification payload tests |
| Room Versions | room version algorithms, event authorization rules, state resolution, room upgrade behavior | MVP rooms do not implement Matrix room versions or event DAG auth; `SPEC-040` adds the first Matrix event DAG and auth-event reference contract, `SPEC-041` adds state snapshot / representative state-resolution vectors, and `SPEC-042` defines the stable room versions 1-12 / default 12 gate without full room-version auth completeness | Supported room versions are listed, default room version is declared, and auth/state-resolution tests pass |
| Olm & Megolm | E2EE primitives, one-time keys, device keys, encrypted room messaging, key backup, verification, cross-signing | Not implemented | Use a mainstream Matrix crypto stack; encrypted rooms, device trust, key backup, and restore flows pass |
| Appendices/common rules | identifiers, timestamps, namespacing, error vocabulary, deprecation behavior | Partially aligned only where MVP contracts copied the concept | Shared parser and validation tests enforce Matrix grammar and compatibility claims |

Matrix compliance phases:

1. **Audit and contract map**: add Matrix-domain coverage metadata to this
   repository, map current `SPEC-*` files to Matrix v1.18 domains, and create
   issues for each missing domain before implementation.
2. **Client-Server compatibility baseline**: add Matrix v3 endpoint contracts
   and vectors for the MVP-equivalent flow first: `/versions`, login, logout,
   whoami, registration, room create/join/leave, state, send event, timeline,
   sync, and media upload/download, then bind those families with the
   `SPEC-039` live server/client adoption gate.
3. **Matrix data model migration**: introduce Matrix-compatible identifiers,
   event IDs, event DAG storage, state snapshots, auth events, room versions,
   and sync token semantics in `houra-server`.
4. **Client-Server breadth**: add profile, account data, tags, receipts,
   typing, read markers, filters, presence, capabilities, devices, room
   directory, aliases, invites, kicks, bans, power levels, redactions, and
   reporting.
5. **E2EE**: adopt a maintained Matrix crypto implementation instead of
   hand-rolling Olm/Megolm behavior, then implement device keys, one-time keys,
   fallback keys, encrypted room send/receive, key backup, verification, and
   cross-signing.
6. **Federation**: implement server signing keys, well-known discovery,
   federation auth, transactions, make/send join, invites, backfill, event
   validation, state resolution, and policy-server interactions.
7. **Ecosystem APIs**: decide whether Identity Service and Push Gateway are
   in-process, separate services, or explicitly unsupported for the first
   compliance release; Application Service support should be tracked as its own
   implementation lane.
8. **Conformance harness**: wire official Matrix specification inputs and a
   Matrix compatibility test runner into CI, while keeping Houra vectors as
   regression coverage for the compatibility layer.

Matrix compliance advertisement gate:

- Do not claim `Matrix v1.18 compliant` for Houra until each included Matrix
  domain has an explicit pass/fail report and any excluded optional deployment
  domain is named as out of scope.
- Do not return Matrix spec versions from `/versions` as supported until the
  matching endpoint set, deprecated endpoint behavior, and advertised unstable
  features are verified for that release.
- Public behavior changes must land in `houra-spec` first, then be adopted by
  `houra-server` and `houra-client` with implementation metrics and clean-room
  notes.
- Issue and PR scopes should stay domain-sized: for example, Client-Server auth,
  Client-Server room state, Room Version 12 auth rules, Federation join, or
  Megolm key backup. Do not mix federation, E2EE, and client UI in one PR.

Matrix Client-Server MVP live e2e gate:

- `SPEC-039` is the integration gate for `SPEC-030` through `SPEC-038`. It
  requires a live `houra-client` core run against a live `houra-server` target
  for versions, login flows, registration, password login, whoami, devices,
  room create/join/state/leave, send event, messages, sync, media upload and
  download, and logout.
- A pass record must name the `houra-spec` ref, `houra-server` ref,
  `houra-client` ref, commands, per-step pass/fail results, `/versions`
  advertisement result, known exclusions, and clean-room confirmation.
- After `SPEC-039` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only when the gate adopts or
  changes a shared parser, identifier helper, URI helper, or binding facade.
- Passing this gate does not claim Matrix v1.18 full compliance. It only closes
  the Client-Server MVP-equivalent integration milestone.

Matrix event DAG and auth-event reference gate:

- `SPEC-040` defines the first Matrix room data model gate after the
  Client-Server MVP-equivalent milestone. It covers server/storage-facing event
  envelopes, `prev_events` DAG reference integrity, `auth_events` reference
  integrity, and representative valid/invalid vectors.
- Passing this gate does not claim room versions 1 through 12 support, state
  resolution support, federation support, redaction correctness, or Matrix
  v1.18 full compliance.
- After `SPEC-040` merges, create an `houra-server` adoption issue for event
  DAG persistence. Create an `houra-labs` issue only if a shared parser or
  event validation helper is intentionally adopted, and do not create an
  `houra-client` issue unless the UI-free client core starts consuming these
  server/storage-facing envelopes.

Matrix state snapshot and state-resolution vector gate:

- `SPEC-041` defines state snapshot entries keyed by `(event_type, state_key)`,
  state event application, message event no-op behavior, unconflicted state
  classification, conflicted state event classification, and representative
  state resolution vectors.
- Passing this gate does not claim complete Matrix room version 12 state
  resolution, room versions 1 through 12 support, federation support, redaction
  correctness, or Matrix v1.18 full compliance.
- After `SPEC-041` merges, create an `houra-server` adoption issue for
  restart-safe state snapshots and state-set resolution vector coverage. Create
  an `houra-labs` issue only if a shared state map or room-version helper is
  intentionally adopted, and do not create an `houra-client` issue unless the
  UI-free client core starts consuming these storage-facing snapshots.

Matrix room versions gate:

- `SPEC-042` defines the Matrix v1.18 stable room-version allowlist as `1`
  through `12`, requires new rooms to default to room version `12`, and adds
  create-room vectors for default selection and unsupported room-version errors.
- Passing this gate does not claim complete per-version auth/state resolution,
  federation, redaction, or room-upgrade support.
- Room-version support must not be advertised through
  `GET /_matrix/client/versions`. Future capabilities support must advertise
  only versions with implementation evidence.

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

The canonical Matrix reference snapshot lives in the
[Matrix v1.18 Compliance Matrix](#matrix-v118-compliance-matrix) section above
and in `contracts/SPEC-030-matrix-client-versions.md`. Implementation records
must cite that single snapshot rather than copy the version, source URL, and
check time into a second location.

This snapshot is a dated planning reference, not a future-current value. Before
starting a later implementation batch, refresh the Matrix specification version
in the compliance matrix and `SPEC-030` first, then record the refreshed value
in that implementation adoption record.

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
| SPEC-030 | `GET /_matrix/client/versions` | `test-vectors/core/matrix-client-versions-basic.json` |
| SPEC-031 | Matrix identifiers, timestamps, namespacing, and error envelopes | `test-vectors/core/matrix-foundation-*.json` |
| SPEC-032 | Matrix login flows, password login, whoami, and logout | `test-vectors/auth/matrix-login-*.json`, `test-vectors/auth/matrix-password-*.json`, `test-vectors/auth/matrix-whoami-basic.json`, and `test-vectors/auth/matrix-logout-basic.json` |
| SPEC-033 | Matrix registration, username availability, UIA response, and registration-token validity | `test-vectors/auth/matrix-registration-*.json` |
| SPEC-034 | Matrix devices, device metadata updates, device deletion UIA, and token invalidation | `test-vectors/auth/matrix-device*.json` and `test-vectors/auth/matrix-devices*.json` |
| SPEC-035 | Matrix room create, join, leave, and state MVP endpoints | `test-vectors/rooms/matrix-*.json` |
| SPEC-036 | Matrix event send and room messages pagination MVP endpoints | `test-vectors/messaging/matrix-*.json` |
| SPEC-037 | Matrix initial and incremental sync MVP endpoint | `test-vectors/sync/matrix-sync-*.json` |
| SPEC-038 | Matrix media upload and authenticated download MVP endpoints | `test-vectors/media/matrix-media-*.json` |
| SPEC-039 | Integrated Matrix Client-Server MVP live e2e gate | `test-vectors/core/matrix-client-server-mvp-live-e2e-gate.json` |
| SPEC-040 | Matrix event DAG and auth-event reference integrity | `test-vectors/events/matrix-event-dag-auth-events-*.json` |
| SPEC-041 | Matrix state snapshot and representative state-resolution vectors | `test-vectors/events/matrix-state-*.json` |
| SPEC-042 | Matrix stable room versions 1-12 and default room version 12 gate | `test-vectors/rooms/matrix-room-version*.json` |

If a server response differs from this repository, fix the server by default. If
the vectors are insufficient or the contract is ambiguous, update this
specification repository first and then create affected implementation follow-up
work.

## Long-Term Role

This repository is the canonical source to update before implementation behavior
changes. It owns draft contract profiles, canonical vectors, and
platform-neutral theme and UI surface files. Client and server repositories
should add native adapters, server behavior, and package metadata only after
this repository passes its local checks.

## Implementation Adoption Reports

Earlier Implementation Adoption Reports for `v0.2.0-pre.X` releases
(`v0.2.0-pre.3` through `v0.2.0-pre.14`, covering the Flutter lab,
TypeScript server/client MVP, PostgreSQL, Expo React Native, binary
media download, account registration, UI surface, manual UI acceptance,
maintenance, release alignment, deployment hardening, and client UI
robustness adoptions) have been moved to `CHANGELOG.md` to keep this
README focused on the current baseline. The most recent entries remain
below.

### Matrix client versions server adoption

- Spec behavior input inspected: `v0.2.0-pre.17`
- Compatibility classification: implementation adoption evidence update for the
  first Matrix Client-Server compatibility endpoint.
- Public behavior impact: server now implements `GET /_matrix/client/versions`
  from `SPEC-030`; existing `/_houra/client/**` behavior is unchanged.
- Changed contracts: none.
- Changed vector files: none.
- Changed design inputs: none.
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this records one Matrix Client-Server endpoint adoption and is not
  Matrix full compliance.
- Started at: 2026-05-09T15:56:54+09:00
- Ended at: 2026-05-09T15:57:46+09:00
- Elapsed seconds: 52
- Timezone: Asia/Tokyo
- Codex usage: unavailable in the local Codex App session.

Server Matrix client versions evidence:

- Implementation repository: `imoyan/houra-server`
- Implementation issue: `imoyan/houra-server#21`
- Implementation pull request: `imoyan/houra-server#22`
- Implementation commit inspected:
  `c1a13410ba2d8e93d6af6dedfcee93b1675794d9`
- Implementation release: `v0.2.0-pre.14`
- Release URL:
  `https://github.com/imoyan/houra-server/releases/tag/v0.2.0-pre.14`
- Scope: unauthenticated `GET /_matrix/client/versions`, CI vector input update
  to `houra-spec` v0.2.0-pre.17, and implementation record.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `houra-server` local `npm run typecheck` | pass | TypeScript typecheck |
| `houra-server` local `npm run build` | pass | TypeScript build |
| `houra-server` local `HOURA_SPEC_ROOT=../houra-spec npm test` | pass | 46 passed, 1 skipped; includes `SPEC-030` vector |
| `houra-server` local `npm run test:postgres` | skipped | `HOURA_TEST_DATABASE_URL` was not set |
| `houra-server` local `npm run test:ops` | pass | Docker Compose deploy, migration, backup/restore, restart persistence smoke |
| `houra-server` GitHub Actions `CI / test` | pass | PR #22, includes vector and ops smoke |

No implementation repository was used as a behavior source. This record only
confirms that `houra-server` consumes `SPEC-030` as read-only input and adopts
the first Matrix Client-Server compatibility endpoint.

### Matrix client versions server adoption readiness

- Release target: `v0.2.0-pre.18`
- Compatibility classification: workflow/adoption evidence update for
  `houra-server` Matrix client versions adoption.
- Changed public behavior profiles: none in this repository.
- Changed contracts: none.
- Changed vector files: none.
- Changed design inputs: none.
- Implementation evidence added: `houra-server` v0.2.0-pre.14 adoption of
  `SPEC-030`.
- Completion claim: Matrix full compliance is not claimed; only the
  `GET /_matrix/client/versions` server adoption is recorded.

### Matrix client versions client adoption

- Spec behavior input inspected: `v0.2.0-pre.18`
- Compatibility classification: implementation adoption evidence update for the
  first Matrix Client-Server compatibility endpoint.
- Public behavior impact: client core now exposes `HouraClient.matrixVersions()`
  for `GET /_matrix/client/versions`; existing Houra client methods and
  bearer-token persistence are unchanged.
- Changed contracts: none.
- Changed vector files: none.
- Changed design inputs: none.
- Matrix reference: Matrix Specification 1.18 remains a reference snapshot
  only; this records one Matrix Client-Server endpoint adoption and is not
  Matrix full compliance.
- Started at: 2026-05-09T16:06:45+09:00
- Ended at: 2026-05-09T16:07:52+09:00
- Elapsed seconds: 67
- Timezone: Asia/Tokyo
- Codex usage: unavailable in the local Codex App session.

Client Matrix client versions evidence:

- Implementation repository: `imoyan/houra-client`
- Implementation issue: `imoyan/houra-client#33`
- Implementation pull request: `imoyan/houra-client#34`
- Implementation commit inspected:
  `265537e2b1c33c29c977da89215031278bf7fe6a`
- Implementation release: `v0.2.0-pre.16`
- Release URL:
  `https://github.com/imoyan/houra-client/releases/tag/v0.2.0-pre.16`
- Server target commit for live e2e smoke: `houra-server` v0.2.0-pre.14
- Scope: `HouraClient.matrixVersions()`, `MatrixVersionsResponse`, vector
  conformance for `matrix-client-versions-basic`, live e2e Matrix versions
  smoke, and CI input updates to `houra-spec` v0.2.0-pre.18 and
  `houra-server` v0.2.0-pre.14.

Observed checks:

| Check | Result | Notes |
|---|---|---|
| `houra-client` local `npm audit --omit=dev` | pass | 0 vulnerabilities |
| `houra-client` local `npm run typecheck` | pass | Core and Expo app typecheck |
| `houra-client` local `npm run build` | pass | TypeScript build |
| `houra-client` local `HOURA_SPEC_ROOT=../houra-spec npm test` | pass | 52 passed, 1 live e2e skipped by default; includes `SPEC-030` vector |
| `houra-client` local Expo config/export | pass | `npx expo config --type public` and iOS export to `/tmp/houra-client-expo-export` |
| `houra-client` local live e2e | pass | Docker Compose `houra-server` v0.2.0-pre.14 at `http://127.0.0.1:3000` |
| `houra-client` GitHub Actions `CI / test` | pass | PR #34, includes `SPEC-030` vector |
| `houra-client` GitHub Actions `CI / e2e` | pass | PR #34, pinned `houra-server` v0.2.0-pre.14 |

No implementation repository was used as a behavior source. This record only
confirms that `houra-client` consumes `SPEC-030` as read-only input and adopts
the first Matrix Client-Server compatibility endpoint in the UI-free core.

### Matrix client versions client adoption readiness

- Release target: `v0.2.0-pre.19`
- Compatibility classification: workflow/adoption evidence update for
  `houra-client` Matrix client versions adoption.
- Changed public behavior profiles: none in this repository.
- Changed contracts: none.
- Changed vector files: none.
- Changed design inputs: none.
- Implementation evidence added: `houra-client` v0.2.0-pre.16 adoption of
  `SPEC-030`.
- Completion claim: Matrix full compliance is not claimed; only the
  `GET /_matrix/client/versions` client adoption is recorded.

## Local Checks

```bash
dart tool/check_spec.dart
```

## License

This specification root is licensed under the Apache License, Version 2.0. See
`LICENSE`.
