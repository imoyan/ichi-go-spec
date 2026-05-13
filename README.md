# houra-spec

Language: [English](#english) | [日本語](#日本語)

## English

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

## 日本語

`houra-spec` は Houra の公開仕様を管理する正本リポジトリです。

Houra の公開 API、契約、テストベクトル、共通デザイントークン、UI surface はこの
リポジトリを基準にします。英語の contract 本文を正本としつつ、日本語ドキュメントも
重要な reader surface として維持します。

長い日本語説明は README に詰め込まず、読みやすさと保守性のため
[`docs/ja/`](docs/ja/) に分けています。

- 日本語ドキュメント入口: [`docs/ja/README.md`](docs/ja/README.md)
- 実装採用者向けガイド: [`docs/ja/adoption-guide.md`](docs/ja/adoption-guide.md)
- release 前の日英確認: [`docs/ja/release-readiness.md`](docs/ja/release-readiness.md)
- Matrix v1.18 の読み方: [`docs/ja/matrix-v1-18.md`](docs/ja/matrix-v1-18.md)

### GitHub 表示について

GitHub のリポジトリトップではこの README が表示されます。上部の
[English](#english) / [日本語](#日本語) リンクで、英語の概要と日本語の概要を切り替えて
読めるようにしています。GitHub README では動的な言語切り替え UI を使わず、アンカーリンクと
`docs/ja/` への静的リンクで移動する構成にしています。

Product MVP の次段階機能は、実装リポジトリで先に挙動を決めず、このリポジトリの
contract、vector、UI surface を先に更新します。`SPEC-070` は email verification、
password reset、identity provider login を Product MVP 次段として扱う前の
fail-closed 境界であり、現時点では実装やサポート claim を追加しません。
`SPEC-071` は thumbnails、range request、resumable download を Product MVP 次段の
media transfer として扱う前の境界であり、encrypted attachment とは分けて扱います。
`SPEC-072` は encrypted media attachment の metadata、transfer、key handling を
扱う前の境界であり、encrypted-room や complete E2EE の claim と混同しません。

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
- `contracts/SPEC-043-matrix-room-auth-representative-vectors.md`
- `contracts/SPEC-044-matrix-room-alias-upgrade-persistence.md`
- `contracts/SPEC-045-matrix-profile-account-data-tags.md`
- `contracts/SPEC-046-matrix-receipts-typing-read-markers.md`
- `contracts/SPEC-047-matrix-filters-presence-capabilities.md`
- `contracts/SPEC-048-matrix-room-directory-aliases-invites.md`
- `contracts/SPEC-049-matrix-moderation-reporting-admin-controls.md`
- `contracts/SPEC-050-matrix-crypto-adapter-boundary.md`
- `contracts/SPEC-051-matrix-device-one-time-fallback-keys.md`
- `contracts/SPEC-052-matrix-to-device-encrypted-room-gate.md`
- `contracts/SPEC-053-matrix-key-backup-restore-gate.md`
- `contracts/SPEC-054-matrix-verification-cross-signing-gate.md`
- `contracts/SPEC-055-matrix-federation-discovery-signing-keys.md`
- `contracts/SPEC-056-matrix-federation-transaction-join-invite.md`
- `contracts/SPEC-057-matrix-federation-backfill-auth-state.md`
- `contracts/SPEC-058-matrix-application-service-registration-transaction.md`
- `contracts/SPEC-059-matrix-identity-service-boundary.md`
- `contracts/SPEC-060-matrix-push-gateway-boundary.md`
- `contracts/SPEC-061-matrix-federation-interop-smoke.md`
- `contracts/SPEC-062-matrix-domain-coverage-evidence-report.md`
- `contracts/SPEC-063-matrix-complement-ci-lane.md`
- `contracts/SPEC-064-matrix-version-advertisement-release-gate.md`
- `contracts/SPEC-065-matrix-release-notes-evidence-template.md`
- `contracts/SPEC-066-matrix-v1-18-release-readiness-gate.md`
- `contracts/SPEC-068-matrix-oauth-account-management.md`
- `contracts/SPEC-069-matrix-device-key-query.md`
- `contracts/SPEC-070-product-mvp-account-recovery-idp-boundary.md`
- `contracts/SPEC-071-product-mvp-media-transfer-boundary.md`
- `contracts/SPEC-072-product-mvp-encrypted-media-boundary.md`

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

### Shared boundary and risk rule

Shared implementation should start at dangerous or drift-prone protocol
boundaries, not at broad application architecture. The preferred shape is:

1. parse the external payload;
2. normalize only contract-visible values;
3. validate identifiers, payload shape, limits, and feature gates;
4. authorize against adapter-provided context; and
5. execute through host-owned transport, storage, crypto, UI, and lifecycle
   code.

After this boundary, downstream code should receive a structured result and
should not re-parse or re-validate the same payload unless the contract requires
a separate phase. Validators and parsers should be compiled or initialized once
where possible, batch representative vector payloads across FFI, WASM, or
N-API boundaries, and avoid hidden network, disk, storage, logging, or crypto
work inside the pure shared path. Caches must have explicit size, lifetime, and
invalidation policy owned by the adapter.

Security-sensitive handling should be shared only when it reduces ambiguity at
the public protocol boundary. Good candidates include identifier grammar,
content URI grammar, error-envelope mapping, protocol payload validation,
redaction of diagnostic fields, and fail-closed capability or version
advertisement. Token persistence, secure key storage, transport retry,
permission prompts, UI trust state, and deployment policy remain host-owned
unless a public Houra contract says otherwise.

If compatibility, security, or performance evidence is incomplete, the shared
boundary must fail closed: do not advertise support, do not widen feature
profiles, and do not turn a local implementation into a required shared
dependency. Record the area as `spec-only`, `adapter-owned`,
`split-by-language`, or `avoid-shared` until parity, security, packaging, and
performance evidence supports a wider adoption.

Existing implementations should not be migrated into shared code as a broad
cleanup by default. Use a next-touch rule for narrow maintenance: when a change
already modifies protocol parsing, normalization, validation, authorization, or
advertisement behavior, decide whether the touched boundary can move into the
shared path without widening the issue. If the migration would change the
feature scope, hot-path cost, packaging model, or security boundary, leave the
local implementation in place and create a planned adoption gate instead.

日本語メモ: 共通化は「危険な境界を一度だけ通す」ために使います。入力の
parse / normalize / validate / authorize は共通化候補ですが、token 保管、
secure storage、transport、retry、UI state、deployment policy は実装側の責務に
残します。証拠が揃わない機能は advertise せず fail-closed にします。既存実装は
一括移行せず、触った箇所で小さく判断し、大きい移行は adoption gate として分けます。

### Current shared-core status

The current shared-core work is still pre-adoption. `houra-labs` contains the
first Rust protocol-core prototype, a `wasm-bindgen` wrapper prototype, and a
TypeScript WASM facade prototype for parser and validation experiments through
the Matrix Client-Server MVP gate. Those artifacts are implementation
experiments, not public contracts, published packages, or required dependencies
for `houra-client` or `houra-server`.

The next shared-core sequence is:

1. Keep `houra-spec` contracts and vectors as the source of truth.
2. Stabilize the Rust crate manifest and ABI/version gate in `houra-labs`.
3. Add parity and performance evidence for representative vector batches.
4. Prepare publish readiness for the Rust crate and TypeScript WASM facade.
5. Adopt the shared core from implementation repositories only after the
   relevant area reaches `rust-adopted` status with the required evidence.

Until those steps are complete, implementation repositories should keep local
parser or validator code unless a focused adoption issue explicitly wires the
shared artifact into that repository.

日本語メモ: Rust 共通化は `houra-labs` で prototype が進んでいる段階であり、
`houra-spec` 上の現在地は `rust-candidate` です。manifest / ABI/version gate、
parity / performance evidence、公開 package 化、実装 repo への採用が揃うまでは
`rust-adopted` として扱いません。

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

- Checked at: 2026-05-12T09:00:00+09:00
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

### Initial Shared-Core Adoption Gates

The first shared-core work should prove the adoption loop before larger
domains move. Start with small, observable protocol boundaries that can pass the
same vectors in `houra-spec`, `houra-labs`, `houra-server`, and `houra-client`
without turning adapter policy into shared code.

| Candidate | Scope | Spec and vectors | Consumer repos | Shared artifact boundary | Adapter-owned boundary | Timing rule | Evidence before adoption |
|---|---|---|---|---|---|---|---|
| Matrix versions request/response handling | Parse and validate `GET /_matrix/client/versions` request/response shape and release-advertisement result fields | `SPEC-030`, `SPEC-064`, `test-vectors/core/matrix-client-versions-basic.json`, `test-vectors/core/matrix-version-advertisement-*.json` | `houra-labs` first, then separate adoption issues for `houra-server` and `houra-client` | Rust parser / validator plus TypeScript WASM or N-API facade and Dart facade only after artifact evidence exists | Fetching the endpoint, cache policy, runtime feature gating, release decision ownership, and all network behavior | Planned adoption gate; do not migrate existing implementations only because adjacent code was touched | Vector parity, p95 `+10%` or hidden latency evidence, secret-free diagnostics, artifact manifest, `abi_version`, facade stability notes, rollback to local parser |
| Matrix / Houra error parsing and emission | Parse and build public error envelopes and stable Matrix `M_*` vocabulary without owning user-facing messages or retry policy | `SPEC-002`, `SPEC-031`, `test-vectors/core/error-basic.json`, `test-vectors/core/matrix-foundation-error-basic.json`, `test-vectors/auth/auth-error-basic.json`, `test-vectors/media/matrix-media-download-not-found.json` | `houra-labs` first, then separate adoption issues for `houra-server` and `houra-client` | Shared error enum, envelope parser, and serializer with stable host-language result types | HTTP status selection, retry/cancellation, telemetry, localization, UI copy, and product-specific recovery flow | Planned adoption gate, with next-touch only for tiny call-site swaps after the shared facade exists | Cross-repo vector parity, no adapter-specific fields in shared output, redaction review, p95 evidence, packaging notes, rollback to local error mapping |

Deferred candidates:

- Identifier and URI validation should follow once the versions and error
  gates prove the artifact manifest and facade stability flow.
- Transaction ID and idempotency helpers should follow only when retry and
  offline queue policy can stay adapter-owned.
- Event content validation, canonical JSON / signing helpers, room-version
  algorithms, and E2EE bridges stay planned gates until domain-specific parity,
  security, and packaging evidence exists.
- HTTP transport, token storage, secure storage, and UI rendering remain
  non-targets for shared protocol core adoption.

日本語メモ: 初回 adoption は `versions` と error envelope に絞ります。既存実装を
一括移行するのではなく、`houra-labs` で artifact / parity / performance evidence を
揃えた後、`houra-server` と `houra-client` の adoption issue に分けて進めます。

### Security, Privacy, and Abuse-Case Review

This cross-cutting review tracks specification guardrails that prevent Houra
contracts from leaving security-sensitive behavior ambiguous. It does not
collect implementation secrets, production configuration, raw tokens, private
keys, push provider credentials, or unredacted release artifacts.

| Review area | Contract coverage | Current follow-up | Adoption rule |
|---|---|---|---|
| Auth/session lifecycle and owner scope | `SPEC-004`, `SPEC-032`, `SPEC-034`, `SPEC-053` cover bearer-token attachment, Matrix logout invalidation, device APIs, and key-backup surfaces | #180 tracks missing Houra logout invalidation, Matrix device owner scope, and key-backup owner scope vectors | Do not record implementation adoption until stale-token and cross-user negative vectors pass |
| Protected key and verification operations | `SPEC-050`, `SPEC-054`, `SPEC-069` keep crypto operations adapter-owned and define parser-facing device-key / verification surfaces | #179 tracked the original `SPEC-054` auth precondition mismatch; `SPEC-054` now requires auth before signature or query semantics | Protected key operations must fail authentication before semantic signature errors are evaluated |
| Media filename and download metadata | `SPEC-020`, `SPEC-038`, `SPEC-071`, `SPEC-072` cover MVP media, Matrix media, deferred range/thumbnail behavior, and encrypted-media boundaries | #181 tracks `Content-Disposition` filename safety for CR/LF, control characters, separators, and quoting/encoding | Download metadata must not permit header injection or unsafe path-shaped filenames as canonical behavior |
| Federation and push outbound destinations | `SPEC-055`, `SPEC-060`, and `SPEC-061` define federation bootstrap, push gateway, and federation smoke boundaries | #182 tracks SSRF-oriented destination controls for well-known redirects, DNS rebinding, private ranges, and push gateway URLs | Outbound request contracts must fail closed on unsafe internal destinations while preserving legitimate public federation and push gateway paths |
| Error envelopes, diagnostics, and release evidence | `SPEC-002`, `SPEC-031`, `SPEC-064`, `SPEC-065`, `SPEC-070`, `SPEC-071`, and `SPEC-072` define public error shape, fail-closed advertisement, release evidence fields, and redacted deferred-boundary evidence | No new issue from this pass; release evidence implementation refs remain tracked by #200 and must cite redacted artifacts only | Public errors and release evidence must not expose bearer tokens, refresh tokens, reset tokens, private keys, pushkeys, vendor tokens, raw secrets, or internal state beyond the contract vector |
| Shared-core security boundary | `Shared boundary and risk rule` and `Initial Shared-Core Adoption Gates` keep shared parser/validator work separate from host-owned transport, storage, token, crypto, retry, and UI policy | Future adoption issues should inherit #198 evidence requirements instead of moving host-owned secrets into shared code | Shared artifacts require vector parity, p95 evidence, redaction review, artifact manifest, `abi_version`, facade stability notes, and rollback before adoption |

Security and privacy review issue handling:

- #179 closed the highest-priority protected-key auth-precedence gap by adding
  authenticated positive vectors and missing-token negative coverage to
  `SPEC-054`.
- #180, #181, and #182 are independent P2 spec gaps and should stay separate so
  auth owner scope, media header safety, and outbound egress controls do not
  block each other.
- Do not create implementation-repository adoption issues for those gaps until
  the corresponding contract and vector changes land in `houra-spec`.
- If a later review finds only implementation-owned configuration or storage
  policy, record it in the implementation repository; do not turn it into a
  normative `houra-spec` contract unless public behavior is ambiguous.

日本語メモ: security / privacy の横断レビューでは、新規に広い実装監査を増やさず、
仕様が曖昧な箇所だけを issue-sized に分けます。#179 は protected key endpoint の
auth precedence と missing-token coverage で閉じ、残る具体 gap は #180〜#182 で
追跡します。release evidence や shared-core adoption は secret を含まない redacted
artifact / ref / command evidence に限定します。

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
| Client-Server API | `/_matrix/client/*`, media, auth, sync, rooms, user data, devices, reporting, admin capabilities | Product MVP covers a small `/_houra/client/*` subset; `SPEC-030` through `SPEC-038` add Matrix versions, auth/session, registration, devices, room create/join/leave/state, send event/messages, sync, and media upload/download contracts; `SPEC-039` defines the integrated live e2e adoption gate; `SPEC-045` starts Client-Server breadth with profile, account data, and room tags; `SPEC-046` adds receipts, typing, and read markers; `SPEC-047` adds filters, presence, and capabilities; `SPEC-048` adds room directory, aliases, and invites; `SPEC-049` adds moderation, reporting, and admin controls | Matrix-compatible endpoint namespace, response shapes, error codes, representative conformance vectors, and live server/client MVP smoke pass |
| Server-Server API | federation discovery, signed transactions, PDUs/EDUs, event auth, joins/leaves, invites, backfill, key APIs, policy servers | Not implemented; `SPEC-055` adds server discovery, delegated well-known, signing-key publication/query, and destination resolution failure contracts; `SPEC-056` adds transaction send/receive, make/send join, and v2 invite contracts; `SPEC-057` adds backfill, event_auth, state_ids, and representative state-resolution interop gates; `SPEC-061` adds two-Houra and reference-homeserver smoke evidence gates | A second homeserver can federate, exchange signed room events, validate auth, and recover state across restart |
| Application Service API | appservice registration, namespace ownership, transactions, sender localpart, bridge-style event delivery | Not implemented; `SPEC-058` adds registration shape, namespace ownership, homeserver-to-appservice transactions, user queries, and room-alias queries | A registered appservice receives transactions and can puppet/send events within its declared namespaces |
| Identity Service API | third-party identifier validation and lookup | Not implemented; `SPEC-059` adds the separate service boundary, identity token scope, hash lookup, validation session, bind, unbind, and privacy/auth failure gate | Either explicitly out of supported deployment scope or implemented as a separate identity component with conformance evidence |
| Push Gateway API | push notification gateway contracts | Not implemented; `SPEC-060` adds the separate push gateway boundary, notify payload, `event_id_only` privacy shape, pusher/push-rule setup, rejected pushkey, and delivery failure gate | Either explicitly out of supported deployment scope or implemented with privacy-aware notification payload tests |
| Room Versions | room version algorithms, event authorization rules, state resolution, room upgrade behavior | MVP rooms do not implement Matrix room versions or event DAG auth; `SPEC-040` adds the first Matrix event DAG and auth-event reference contract, `SPEC-041` adds state snapshot / representative state-resolution vectors, `SPEC-042` defines the stable room versions 1-12 / default 12 gate, `SPEC-043` adds representative membership, power-level, and redaction auth vectors, and `SPEC-044` adds alias / upgrade / restart persistence gates without full room-version auth completeness | Supported room versions are listed, default room version is declared, and auth/state-resolution tests pass |
| Olm & Megolm | E2EE primitives, one-time keys, device keys, encrypted room messaging, key backup, verification, cross-signing | Not implemented; `SPEC-050` defines the adapter ownership boundary and forbids local Olm/Megolm implementation; `SPEC-069` isolates the first client/parser-facing device-key query contract; `SPEC-051` adds device key, one-time key, and fallback key publication/claim contracts; `SPEC-052` adds to-device and encrypted-room send/receive gates; `SPEC-053` adds server-side key backup and logout/relogin restore gates; `SPEC-054` adds SAS verification, cross-signing, and wrong-device failure gates | Use a mainstream Matrix crypto stack; encrypted rooms, device trust, key backup, restore, verification, and wrong-device failure flows pass |
| Appendices/common rules | identifiers, timestamps, namespacing, error vocabulary, deprecation behavior | Partially aligned only where MVP contracts copied the concept | Shared parser and validation tests enforce Matrix grammar and compatibility claims |

Matrix domain coverage evidence report:

- `SPEC-062` defines the Matrix v1.18 stable-domain coverage report shape for
  contract refs, implementation repos, adoption issue refs, pass/fail evidence,
  artifact paths, and advertisement decisions.
- The report covers Client-Server API, Server-Server API, Application Service
  API, Identity Service API, Push Gateway API, Room Versions, Olm & Megolm, and
  Appendices/common rules.
- Unstable MSCs remain excluded unless a later issue explicitly adopts a
  specific MSC with its own contract, vector, adoption issue, and release note.
- After `SPEC-062` merges, create adoption issues for `houra-server` and
  `houra-client` to emit implementation evidence in the same shape. Create an
  `houra-labs` issue only if shared-core evidence becomes part of a domain gate.

Matrix Complement-compatible CI lane:

- `SPEC-063` defines the Complement-compatible homeserver black-box CI lane
  setup, minimum pass/fail report shape, artifact requirements, and release gate
  candidate rules.
- Passing this gate does not replace the domain-specific vectors in this
  repository and does not by itself allow Matrix version or domain
  advertisement.
- After `SPEC-063` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` or `houra-labs` adoption issues unless a later
  client-facing or shared-core Complement harness is intentionally scoped.

Matrix version advertisement release gate:

- `SPEC-064` defines the fail-closed release gate for
  `GET /_matrix/client/versions` and release notes. Matrix versions, domains,
  and unstable feature flags can be advertised only when the included behavior
  has passing contract and implementation evidence.
- Missing, failed, stale, or secret-leaking evidence keeps advertisement and
  release tags blocked.
- After `SPEC-064` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if shared-core release
  artifacts begin advertising Matrix support.

Matrix release notes evidence template:

- `SPEC-065` defines the release notes sections and evidence link fields
  required for any Houra release that mentions Matrix v1.18 support.
- Supported domains require passing evidence links; excluded domains require a
  reason or known-gap issue; unstable MSCs are excluded by default.
- After `SPEC-065` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if shared-core release
  artifacts begin publishing Matrix support claims.

Matrix v1.18 release readiness gate:

- `SPEC-066` defines the final readiness checklist, tag/release ordering,
  rollback criteria, and non-advertisement decision rules for a release that
  claims Matrix v1.18 stable-domain support.
- Passing this gate does not itself implement or advertise Matrix support; it
  requires `SPEC-062`, `SPEC-063`, `SPEC-064`, and `SPEC-065` evidence for the
  same checked release refs.
- After `SPEC-066` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if shared-core artifacts
  become part of the release candidate.

Canonical release evidence example bundle:

- `test-vectors/core/matrix-v1-18-release-evidence-example-bundle.json` shows
  one implementation-facing example that links the `SPEC-062` coverage report,
  `SPEC-063` Complement report, `SPEC-064` advertisement decision, `SPEC-065`
  release notes evidence, and `SPEC-066` readiness checklist for the same
  release candidate refs.
- The bundle is illustrative evidence wiring only. It does not replace the
  individual contract vectors, add endpoint behavior, or widen Matrix version
  advertisement beyond the listed domains with passing evidence.

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

Matrix profile, account data, and room tags gate:

- `SPEC-045` defines the Matrix v1.18 profile, global account data,
  room-scoped account data, and room tag endpoint family. It also records that
  account data and `m.tag` updates must become visible through later `/sync`
  responses.
- Passing this gate does not claim receipts, typing, read markers, filters,
  presence, capabilities, room directory, invites, admin controls, E2EE,
  federation, or Matrix v1.18 full compliance.
- After `SPEC-045` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for profile keys, account-data event types,
  or `m.tag` content.

Matrix receipts, typing, and read markers gate:

- `SPEC-046` defines the Matrix v1.18 typing notification, receipt, and
  read-marker endpoint family. It records `/sync` visibility for `m.typing`,
  `m.receipt`, and `m.fully_read`, and it prevents direct `m.fully_read` room
  account-data writes.
- Passing this gate does not claim filters, presence, capabilities, push rules,
  federation EDU delivery, unread-marker UI policy, E2EE, or Matrix v1.18 full
  compliance.
- After `SPEC-046` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for receipt, typing, or read-marker event
  content.

Matrix filters, presence, and capabilities gate:

- `SPEC-047` defines the Matrix v1.18 filter create/read, presence set/get, and
  capabilities endpoint family. It records representative `/sync` visibility
  for `m.presence` and capabilities alignment with room version and profile
  field contracts.
- Passing this gate does not claim search, push rules, user directory, room
  directory, invites, admin controls, E2EE, federation, or Matrix v1.18 full
  compliance.
- After `SPEC-047` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for filters, presence, or capabilities.

Matrix room directory, aliases, and invites gate:

- `SPEC-048` defines the Matrix v1.18 public room directory, directory
  visibility, local alias listing, and invite endpoint family. It builds on
  alias persistence from `SPEC-044` and records `/sync` invite visibility for
  invited users.
- Passing this gate does not claim third-party invites, application service
  network directories, remote public room federation, spaces hierarchy,
  federation invite signing, admin controls, E2EE, or Matrix v1.18 full
  compliance.
- After `SPEC-048` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for public room summaries, alias lists, or
  stripped invite state.

Matrix moderation, reporting, and admin controls gate:

- `SPEC-049` defines the Matrix v1.18 kick, ban, unban, redaction, reporting,
  and account moderation admin endpoint family. It records representative
  permission failures and `m.account_moderation` capability evidence for
  server-local account lock/suspend controls.
- Passing this gate does not claim policy server signing, moderation queue UI,
  appeals, federation enforcement, E2EE, or Matrix v1.18 full compliance.
- After `SPEC-049` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for moderation, reporting, or admin response
  shapes.

Matrix crypto adapter boundary gate:

- `SPEC-050` defines the Matrix v1.18 E2EE adapter boundary before endpoint
  family contracts are added. It requires a maintained Matrix crypto stack and
  forbids local Olm, Megolm, SAS, cross-signing crypto, secret-storage crypto,
  and key-backup crypto implementations in Houra repositories.
- Passing this gate does not claim device key, one-time key, fallback key,
  to-device, encrypted room, key backup, verification, cross-signing, or secret
  storage support.
- After `SPEC-050` merges, create an `houra-client` adoption issue for crypto
  stack selection and adapter ownership. Create `houra-server` adoption issues
  only when server-side key-storage or to-device endpoint contracts merge.
  Create an `houra-labs` issue only if a parser-only shared helper is
  intentionally adopted with parity vectors and a performance gate.

Matrix device, one-time, and fallback keys gate:

- `SPEC-051` defines the Matrix v1.18 device key upload/query and one-time /
  fallback key upload/claim endpoint family. It records representative auth and
  malformed key-shape failures while preserving the `SPEC-050` rule that
  Houra does not implement Olm/Megolm locally.
- Passing this gate does not claim to-device messaging, encrypted rooms, key
  backup, verification, cross-signing, secret storage, federation, or Matrix
  v1.18 full compliance.
- After `SPEC-051` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for device key, one-time key, or fallback key
  payload shapes.

Matrix to-device and encrypted room gate:

- `SPEC-052` defines the Matrix v1.18 to-device send/receive surface,
  `m.room.encryption` setup, `m.room.encrypted` send/receive envelope, and a
  multi-device encrypted room smoke gate. It preserves the `SPEC-050` boundary
  that Houra repositories do not implement Olm/Megolm locally.
- Passing this gate does not claim key backup, verification, cross-signing,
  secret storage, encrypted attachments, federation to-device delivery, or
  Matrix v1.18 full compliance.
- After `SPEC-052` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for encrypted event envelope or to-device
  payload shape validation.

Matrix key backup and restore gate:

- `SPEC-053` defines the Matrix v1.18 server-side key backup version lifecycle,
  opaque room-key backup upload/restore, wrong-version failures, missing-session
  failures, and logout/relogin recovery evidence. It preserves the `SPEC-050`
  boundary that Houra repositories do not implement Megolm locally.
- Passing this gate does not claim verification, cross-signing, secret storage,
  backup deletion, federation, or Matrix v1.18 full compliance.
- After `SPEC-053` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for backup version metadata or room key
  backup payload shape validation.

Matrix verification and cross-signing gate:

- `SPEC-054` defines the Matrix v1.18 SAS verification message flow,
  `m.key.verification.cancel` mismatch behavior, public cross-signing key
  upload/query/signature publication, invalid signature failures, and a
  wrong-device/fingerprint mismatch evidence gate. It preserves the `SPEC-050`
  boundary that Houra repositories do not implement SAS or cross-signing crypto
  locally.
- Passing this gate does not claim secret storage, federation key forwarding,
  QR-code verification UX, full account recovery UX, or Matrix v1.18 full
  compliance.
- After `SPEC-054` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for verification event shape or
  cross-signing public key validation.

Matrix federation discovery and signing keys gate:

- `SPEC-055` defines the Matrix v1.18 Server-Server discovery bootstrap:
  delegated `/.well-known/matrix/server`, `/_matrix/key/v2/server`, batch
  `/_matrix/key/v2/query`, destination resolution fallback/failure evidence,
  and signing-key cache boundaries.
- Passing this gate does not claim federation transactions, make/send join,
  invite, backfill, event auth, state resolution, Application Service, Identity
  Service, Push Gateway, or Matrix v1.18 full federation compliance.
- After `SPEC-055` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later client-visible federation
  configuration surface is intentionally added. Create an `houra-labs` issue
  only if parser-only helpers for server names, well-known bodies, or server-key
  objects are intentionally adopted.

Matrix federation transaction, join, and invite gate:

- `SPEC-056` defines the Matrix v1.18 Server-Server transaction envelope,
  `/_matrix/federation/v1/send/{txnId}` PDU/EDU delivery, make_join/send_join
  handshake, and v2 invite signing contract. It uses `SPEC-055` signing-key
  discovery as the request-authentication foundation.
- Passing this gate does not claim backfill, missing-event retrieval, full event
  authorization, state-resolution completeness, leave/knock, third-party
  invites, federation E2EE EDUs, policy-server hooks, or Matrix v1.18 full
  federation compliance.
- After `SPEC-056` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later client-visible federation surface is
  intentionally added. Create an `houra-labs` issue only if parser-only helpers
  for federation request auth, transaction envelopes, or membership event shape
  are intentionally adopted.

Matrix federation backfill, event auth, and state interop gate:

- `SPEC-057` defines the Matrix v1.18 Server-Server backfill, event_auth,
  state_ids, and representative state-resolution interop gate. It uses
  `SPEC-055` for request authentication and `SPEC-056` for the initial
  transaction/join context.
- Passing this gate does not claim get_missing_events, timestamp lookup, full
  room auth/state-resolution completeness, federation E2EE EDU handling,
  reference homeserver interop, or Matrix v1.18 full federation compliance.
- After `SPEC-057` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later client-visible federation surface is
  intentionally added. Create an `houra-labs` issue only if parser-only or
  room-version-helper adoption is intentionally scoped with parity vectors and
  performance gates.

Matrix Application Service registration and transaction gate:

- `SPEC-058` defines the Matrix v1.18 Application Service registration file
  shape, exclusive namespace ownership, homeserver-to-appservice authorization,
  transaction push, user query, room-alias query, and sender localpart boundary.
- Passing this gate does not claim third-party network APIs, appservice ping,
  bridge protocol behavior, identity, push gateway, or Matrix v1.18 full
  ecosystem compliance.
- After `SPEC-058` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later user-facing appservice management
  surface is intentionally added. Create an `houra-labs` issue only if
  parser-only helpers for registration or namespace matching are intentionally
  adopted.

Matrix Identity Service boundary gate:

- `SPEC-059` defines the Matrix v1.18 Identity Service boundary for version and
  status checks, identity-service-scoped tokens, terms gate behavior, public key
  lookup shape, hash details, 3PID lookup, email/MSISDN validation sessions,
  bind, validated-3PID query, unbind, and representative privacy/auth failures.
- Passing this gate does not claim invitation storage, ephemeral invitation
  signing, email/SMS provider infrastructure, user-facing consent UI, push
  gateway behavior, or Matrix v1.18 full ecosystem compliance.
- After `SPEC-059` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only helpers for
  3PID, token redaction, or signed association validation are intentionally
  adopted.

Matrix Push Gateway boundary gate:

- `SPEC-060` defines the Matrix v1.18 Push Gateway boundary for
  `POST /_matrix/push/v1/notify`, unsupported endpoint errors, rejected
  pushkeys, duplicate suppression, `event_id_only`, pusher setup, push rule
  setup, `m.push_rules` sync visibility, delivery retry, and privacy handling.
- Passing this gate does not claim APNS, FCM/GCM, Web Push, vendor credential
  handling, device permission UI, notification rendering, background tasks, or
  Matrix v1.18 full ecosystem compliance.
- After `SPEC-060` merges, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only helpers for
  push notification payloads or pusher data validation are intentionally
  adopted.

Matrix federation interop smoke gate:

- `SPEC-061` defines the Matrix v1.18 federation adoption smoke for two Houra
  homeservers, one Houra plus one reference homeserver, and a Docker Compose or
  Complement-compatible CI lane. It binds `SPEC-055`, `SPEC-056`, and
  `SPEC-057` into runnable evidence.
- Passing this gate does not claim get_missing_events, timestamp lookup, leave,
  knock, third-party invites, federation E2EE EDU handling, policy servers,
  complete Complement coverage, or Matrix v1.18 full federation compliance.
- After `SPEC-061` merges, create an adoption issue for `houra-server`. Do not
  create `houra-client` work unless a later client-visible federation smoke
  surface is intentionally added. Create an `houra-labs` issue only if
  parser-only or room-version-helper adoption is intentionally scoped with
  parity vectors and performance gates.

Matrix room versions gate:

- `SPEC-042` defines the Matrix v1.18 stable room-version allowlist as `1`
  through `12`, requires new rooms to default to room version `12`, and adds
  create-room vectors for default selection and unsupported room-version errors.
- Passing this gate does not claim complete per-version auth/state resolution,
  federation, redaction, or room-upgrade support.
- Room-version support must not be advertised through
  `GET /_matrix/client/versions`. Future capabilities support must advertise
  only versions with implementation evidence.

Matrix room auth representative vectors:

- `SPEC-043` defines representative room version 12 authorization vectors for
  membership joins, power-level validation, creator handling, redaction send
  authorization, and redaction application allow/deny checks.
- Passing this gate does not claim complete Matrix room-version authorization,
  complete state resolution, federation auth-chain validation, or Matrix v1.18
  full compliance.

Matrix room alias, upgrade, and restart persistence gate:

- `SPEC-044` defines representative room alias create/resolve/delete behavior,
  room upgrade records for replacement room and tombstone links, and a restart
  persistence gate covering event graph, state snapshot, room version, alias,
  and upgrade records.
- Passing this gate does not claim full room directory, full room upgrade,
  federation upgrade interop, or Matrix v1.18 full compliance.

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

Implementation metrics recording locations:

- Implementation issue: owns the detailed task record while the work is active,
  including timing, verification, blockers, and clean-room notes.
- Implementation pull request: summarizes the same record for reviewers and
  links to the issue when the full record would make the PR body noisy.
- `houra-spec` adoption report: records only release-facing evidence and links
  to implementation issues, PRs, commits, releases, and verification summaries.
- Matrix release evidence bundle: links to adoption reports and release-gate
  artifacts for the same refs; it does not duplicate per-task timing or Codex
  usage records.
- Optional JSONL artifacts may be stored in an implementation repository when a
  repo-specific workflow needs machine-readable history. They are evidence
  artifacts, not a second specification source.

Required fields:

- Spec input: `houra-spec` commit or tag consumed.
- Implementation target: repository, branch, implementation issue, pull request
  when available, and head commit.
- Scope: feature profiles, contracts, vectors, design token files, and UI
  surface files consumed or changed.
- Matrix reference citation: the Matrix snapshot anchor in this README and
  `contracts/SPEC-030-matrix-client-versions.md` at the consumed `houra-spec`
  ref. Do not copy the version, source URL, or check time into a second
  location.
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

Minimum implementation metrics schema:

| Field | Required | Notes |
|---|---|---|
| `repo` | yes | Implementation repository name, such as `houra-server` or `houra-client`. |
| `branch` | yes | Implementation branch used for the work. |
| `issue` | yes | Implementation issue URL or number. |
| `pr` | no | Pull request URL or number. Before publication, omit the field or set it to `null` when a stable key set is useful. |
| `spec_ref` | yes | Consumed `houra-spec` tag or commit. |
| `implementation_commit` | yes | Head commit verified, or `null` while blocked before commit. |
| `profiles` | yes | Feature profiles affected or adopted. Use `[]` when the work is release/process only. |
| `contracts` | yes | `SPEC-*` ids consumed or changed. Use `[]` when not contract-specific. |
| `vectors` | yes | Vector paths consumed or changed. Use `[]` when not vector-specific. |
| `design_inputs` | yes | Theme or UI surface paths consumed or changed. Use `[]` when not design-specific. |
| `matrix_reference_snapshot` | yes | Citation such as `README#matrix-v118-compliance-matrix` and `contracts/SPEC-030-matrix-client-versions.md` at `spec_ref`, not copied version fields. |
| `started_at` / `ended_at` / `elapsed_seconds` / `timezone` | yes | Timing evidence for implementation work. |
| `model` / `execution_mode` | yes | Agent model and task mode when known. |
| `input_tokens` / `cached_input_tokens` / `output_tokens` / `total_tokens` | yes | Use `null` when unavailable. |
| `usage_source` / `accuracy` | yes | Use `unavailable` / `unavailable` when exact usage is not exposed. |
| `verification` | yes | Array of command/result/head-ref entries. |
| `outcome` | yes | `shipped`, `blocked`, `deferred`, or `superseded`. |
| `clean_room_confirmed` | yes | Boolean clean-room confirmation. |
| `notes` | no | Short blocker, decision, or follow-up issue reference. |

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
{"repo":"houra-client","branch":"codex/adopt-media-vectors","issue":"https://github.com/imoyan/houra-client/issues/123","pr":null,"spec_ref":"<houra-spec-sha-or-tag>","implementation_commit":"<implementation-sha>","profiles":["media"],"contracts":["SPEC-020"],"vectors":["test-vectors/media/upload-basic.json"],"design_inputs":[],"matrix_reference_snapshot":"README#matrix-v118-compliance-matrix and contracts/SPEC-030-matrix-client-versions.md at spec_ref","started_at":"2026-05-08T10:00:00+09:00","ended_at":"2026-05-08T10:42:00+09:00","elapsed_seconds":2520,"timezone":"Asia/Tokyo","model":"gpt-5.3-codex","execution_mode":"local_task","input_tokens":null,"cached_input_tokens":null,"output_tokens":null,"total_tokens":null,"usage_source":"unavailable","accuracy":"unavailable","verification":[{"command":"npm test","result":"pass","head":"<implementation-sha>"}],"outcome":"shipped","clean_room_confirmed":true,"notes":"No Matrix version fields copied; snapshot is cited from houra-spec."}
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
| SPEC-042 | Matrix stable room versions 1-12 and default room version 12 gate | `test-vectors/rooms/matrix-room-version-*.json` and `test-vectors/rooms/matrix-room-versions-*.json` |
| SPEC-043 | Matrix room version 12 representative auth vectors | `test-vectors/events/matrix-auth-*.json` |
| SPEC-044 | Matrix room alias, upgrade, and restart persistence gate | `test-vectors/rooms/matrix-room-*.json` |
| SPEC-045 | Matrix profile, account data, and room tag endpoint family | `test-vectors/sync/matrix-profile-*.json`, `test-vectors/sync/matrix-account-data-*.json`, and `test-vectors/sync/matrix-room-tags-*.json` |
| SPEC-046 | Matrix receipts, typing, and read markers endpoint family | `test-vectors/sync/matrix-typing-*.json`, `test-vectors/sync/matrix-receipt-*.json`, and `test-vectors/sync/matrix-read-marker*.json` |
| SPEC-047 | Matrix filters, presence, and capabilities endpoint family | `test-vectors/sync/matrix-filter-*.json`, `test-vectors/sync/matrix-presence-*.json`, and `test-vectors/sync/matrix-capabilities-*.json` |
| SPEC-048 | Matrix room directory, aliases, and invites endpoint family | `test-vectors/rooms/matrix-public-rooms-*.json`, `test-vectors/rooms/matrix-room-directory-*.json`, `test-vectors/rooms/matrix-room-alias*.json`, and `test-vectors/rooms/matrix-room-invite-*.json` |
| SPEC-049 | Matrix moderation, reporting, and admin controls endpoint family | `test-vectors/rooms/matrix-room-moderation-*.json`, `test-vectors/rooms/matrix-room-redaction-*.json`, `test-vectors/rooms/matrix-room-reporting-*.json`, and `test-vectors/rooms/matrix-admin-account-moderation-*.json` |
| SPEC-050 | Matrix E2EE crypto adapter boundary and adoption checklist | `test-vectors/core/matrix-crypto-*.json` |
| SPEC-051 | Matrix device, one-time, and fallback key endpoint family | `test-vectors/auth/matrix-keys-*.json` |
| SPEC-052 | Matrix to-device and encrypted room send/receive gate | `test-vectors/messaging/matrix-to-device-*.json`, `test-vectors/messaging/matrix-encrypted-room-*.json`, and `test-vectors/messaging/matrix-e2ee-*.json` |
| SPEC-053 | Matrix key backup and logout/relogin restore gate | `test-vectors/messaging/matrix-key-backup-*.json` |
| SPEC-054 | Matrix verification, cross-signing, and wrong-device failure gate | `test-vectors/messaging/matrix-verification-*.json`, `test-vectors/messaging/matrix-cross-signing-*.json`, and `test-vectors/messaging/matrix-wrong-device-*.json` |
| SPEC-055 | Matrix federation discovery and signing keys gate | `test-vectors/core/matrix-federation-*.json` |
| SPEC-056 | Matrix federation transaction, join, and invite gate | `test-vectors/events/matrix-federation-*.json` |
| SPEC-057 | Matrix federation backfill, event auth, and state interop gate | `test-vectors/events/matrix-federation-backfill-*.json`, `test-vectors/events/matrix-federation-event-auth-*.json`, and `test-vectors/events/matrix-federation-state-*.json` |
| SPEC-058 | Matrix Application Service registration and transaction gate | `test-vectors/core/matrix-appservice-*.json` |
| SPEC-059 | Matrix Identity Service boundary and lookup/bind/unbind gate | `test-vectors/core/matrix-identity-*.json` |
| SPEC-060 | Matrix Push Gateway boundary and delivery failure gate | `test-vectors/core/matrix-push-*.json` |
| SPEC-061 | Matrix federation two-homeserver and reference interop smoke gate | `test-vectors/events/matrix-federation-*-smoke.json` and `test-vectors/events/matrix-federation-compose-ci-lane.json` |
| SPEC-062 | Matrix domain coverage and evidence report gate | `test-vectors/core/matrix-domain-coverage-*.json` |
| SPEC-063 | Matrix Complement-compatible homeserver CI lane gate | `test-vectors/core/matrix-complement-ci-*.json` |
| SPEC-064 | Matrix version advertisement release gate | `test-vectors/core/matrix-version-advertisement-*.json` |
| SPEC-065 | Matrix release notes evidence template gate | `test-vectors/core/matrix-release-notes-*.json` |
| SPEC-066 | Matrix v1.18 release readiness, tag procedure, and canonical evidence bundle gate | `test-vectors/core/matrix-v1-18-release-readiness-*.json`, `test-vectors/core/matrix-v1-18-release-tag-*.json`, `test-vectors/core/matrix-v1-18-release-rollback-*.json`, and `test-vectors/core/matrix-v1-18-release-evidence-*.json` |
| SPEC-070 | Product MVP account recovery and IdP login fail-closed boundary | `test-vectors/auth/product-mvp-account-recovery-idp-deferred.json` |
| SPEC-071 | Product MVP thumbnails, range request, and resumable download fail-closed boundary | `test-vectors/media/product-mvp-media-transfer-deferred.json` |
| SPEC-072 | Product MVP encrypted media attachment fail-closed boundary | `test-vectors/media/product-mvp-encrypted-media-deferred.json` |

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
