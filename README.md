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
- Matrix アプリ拡張境界: [`docs/ja/matrix-application-extension-boundary.md`](docs/ja/matrix-application-extension-boundary.md)

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

## Pre-1.0 Compatibility

Published pre-1.0 tags are immutable. Contract, vector, design token, and UI
surface changes must be classified as `breaking`, `additive`, or `corrective`
before handoff. Breaking and deprecation changes must include the deprecated or
changed behavior, replacement or out-of-scope decision, migration guidance,
affected implementation issue or PR refs, release notes evidence, and whether
the change affects Houra Product MVP, Matrix compatibility, both, or neither.

Product MVP claims and Matrix compatibility claims stay separate. Product MVP
evidence must not widen Matrix `/_matrix/**` support, and Matrix compatibility
evidence must not imply `/_houra/client/**` Product MVP behavior unless the
matching Product MVP contract/vector/design input also changed.

## Layout

- `contracts/`: normative API behavior.
- `test-vectors/`: request and response fixtures implementations must pass.
- `design/`: shared platform-neutral theme tokens and UI surface definitions.
- `SOURCE_OF_TRUTH.md`: precedence and change rules.
- `REFERENCE_POLICY.md`: clean-room source policy.
- `SECURITY.md`: vulnerability reporting scope and redaction policy.
- `FEATURE_PROFILES.md`: feature slices.
- `MODULE_DEPENDENCIES.md`: allowed dependency direction.
- `CONTRACT_MODULE_MAP.md`: contract-to-profile table.
- `CHANGELOG.md`: archived Implementation Adoption Reports for earlier
  `v0.2.0-pre.X` releases. The current baseline lives in this README.
- `tool/check_spec.dart`: local consistency check for contracts, vectors,
  design tokens, and UI surfaces.
- `docs/architecture/`: non-contract architecture guidance, such as the
  Matrix application extension boundary
  ([`docs/architecture/matrix-application-extension-boundary.md`](docs/architecture/matrix-application-extension-boundary.md)).

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
- `contracts/SPEC-073-matrix-client-server-full-breadth-gap-inventory.md`
- `contracts/SPEC-074-matrix-server-server-full-breadth-gap-inventory.md`
- `contracts/SPEC-075-matrix-application-service-full-breadth-gap-inventory.md`
- `contracts/SPEC-076-matrix-identity-service-full-breadth-gap-inventory.md`
- `contracts/SPEC-077-matrix-push-gateway-full-breadth-gap-inventory.md`
- `contracts/SPEC-078-matrix-room-versions-full-algorithm-gap-inventory.md`
- `contracts/SPEC-079-matrix-olm-megolm-full-e2ee-gap-inventory.md`
- `contracts/SPEC-080-matrix-room-versions-capabilities-advertisement-boundary.md`
- `contracts/SPEC-081-matrix-maintained-crypto-storage-ownership-boundary.md`
- `contracts/SPEC-082-matrix-client-well-known-discovery-support-policy.md`
- `contracts/SPEC-083-matrix-room-version-event-decision-artifacts.md`
- `contracts/SPEC-084-matrix-room-version-federation-cross-domain-validation.md`
- `contracts/SPEC-085-matrix-client-server-event-retrieval-membership-history.md`
- `contracts/SPEC-086-matrix-push-payload-minimization-boundary.md`
- `contracts/SPEC-090-matrix-client-server-relations-threads-reactions.md`
- `contracts/SPEC-091-matrix-push-notify-payload-gateway-endpoint-boundary.md`
- `contracts/SPEC-092-matrix-identity-bind-unbind-lifecycle-boundary.md`
- `contracts/SPEC-093-matrix-sync-breadth-extensions.md`
- `contracts/SPEC-094-matrix-identity-validation-provider-delivery-boundary.md`
- `contracts/SPEC-095-matrix-media-repository-breadth.md`
- `contracts/SPEC-096-matrix-identity-public-key-signature-boundary.md`
- `contracts/SPEC-097-matrix-federation-version-key-lifecycle-request-auth.md`
- `contracts/SPEC-098-matrix-push-parser-helper-breadth.md`
- `contracts/SPEC-099-matrix-federation-pdu-edu-parser-helpers.md`
- `contracts/SPEC-100-matrix-federation-directory-query-openid-parser-helpers.md`
- `contracts/SPEC-101-matrix-room-version-auth-rule-fixture-runner.md`
- `contracts/SPEC-102-matrix-e2ee-parser-artifact-breadth.md`
- `contracts/SPEC-103-matrix-room-version-event-format-hash-signature.md`
- `contracts/SPEC-104-matrix-room-version-state-resolution-fixture-runner.md`
- `contracts/SPEC-105-matrix-application-service-parser-artifact-breadth.md`
- `contracts/SPEC-106-matrix-identity-service-parser-artifact-breadth.md`
- `contracts/SPEC-107-matrix-federation-transaction-event-validation-runtime.md`
- `contracts/SPEC-108-matrix-federation-directory-query-openid-runtime.md`
- `contracts/SPEC-109-matrix-federation-e2ee-device-media-runtime.md`
- `contracts/SPEC-110-matrix-federation-acl-policy-signing-runtime.md`
- `contracts/SPEC-111-matrix-federation-leave-knock-runtime.md`
- `contracts/SPEC-112-matrix-federation-event-retrieval-runtime.md`

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
For the next Product MVP release candidate, UI readiness evidence must also
record the consumed `houra-spec` ref, consumer repo/app ref, screen/action
mapping, duplicate-submit prevention, recoverable error display, accessibility
result or blocker, and manual or automated acceptance coverage. The current
client follow-up is tracked by `imoyan/houra-client#122`.

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
- Product MVP UI readiness names the current UI surface scope, target release
  candidate, consumer repo ref, acceptance evidence, accessibility result or
  blocker, and redaction policy.
- A pre-1.0 release tag and GitHub Release record the changed profiles,
  contracts, vectors, compatibility classification, and implementation
  follow-up.

`tool/check_spec.dart` enforces the local structural parts of this readiness
criteria. Adoption reports, implementation conformance runs, and release
publication remain workflow evidence.

## Product MVP Release Candidate Plan

The next Product MVP release candidate is tracked by
`test-vectors/core/product-mvp-release-candidate-plan.json` and
`imoyan/houra-spec#190`. It is a Product MVP adoption and release evidence
checkpoint, not a Matrix full-compliance release candidate.

The release candidate must name the exact refs consumed from:

- `imoyan/houra-spec`: canonical contracts, vectors, design inputs, UI surface,
  and this release-candidate plan.
- `imoyan/houra-server`: PostgreSQL-backed server behavior and Docker Compose
  deploy smoke evidence.
- `imoyan/houra-client`: Expo React Native app layer, Product MVP happy path
  evidence, and Product MVP UI surface adoption evidence.

Blocking evidence lanes for the candidate:

- Product MVP happy path evidence is tracked by `imoyan/houra-client#121`.
- Product MVP UI surface adoption evidence is tracked by
  `imoyan/houra-client#122`.
- Docker Compose deploy smoke evidence is tracked by `imoyan/houra-server#227`.

The implementation metrics and adoption report schema follow-up
`imoyan/houra-spec#204` is complete for the current schema. The Matrix release
evidence bundle follow-up `imoyan/houra-spec#200` is also complete, but Matrix
roadmap work remains separate under `imoyan/houra-spec#95`.

Do not cut a Product MVP release-candidate tag until the blocking evidence
lanes record the consumed refs, commands, pass/fail results, known blockers,
redaction policy, and claim boundary. Passing the Product MVP evidence lanes
does not widen `/versions`, Matrix v1.18 support, federation, E2EE, push,
identity service, application service, or room-version compliance claims.

## OSS Publication Readiness

OSS publication readiness is tracked by
`test-vectors/core/oss-publication-readiness-plan.json` and
`imoyan/houra-spec#191`. This repository can be listed publicly only as the
canonical specification root for contracts, vectors, design inputs, and Product
MVP UI surfaces. Public listing does not make implementation repositories,
packages, containers, or app artifacts canonical.

Required repository surfaces before public listing:

- `LICENSE` is present and applies to this specification root.
- `SECURITY.md` defines reporting scope, private-report guidance, and redaction
  policy.
- GitHub Releases are used as release anchors and name changed contracts,
  vectors, design inputs, implementation evidence refs, claim boundaries, and
  verification commands.
- GitHub topics are maintained as repository metadata for discoverability.

Publication and index order:

1. Complete repository surfaces: license, security policy, README release
   boundary, GitHub topics, and release-note content.
2. Create a GitHub Release anchor for the chosen pre-release or stable ref.
3. Register documentation indexes such as Context7 only after the public docs
   URL and library claim are stable. `context7.json` remains deferred until
   that URL and desired parsing behavior are known.
4. Enable trust signals such as OpenSSF Scorecard and OpenSSF Best Practices
   Badge after repository security and release-process surfaces exist.
5. Publish implementation packages, app artifacts, or container images only from
   their owning repositories after artifact-specific readiness issues close.

Artifact-specific publication tracking is split by owner:

- `imoyan/houra-server#256` tracks server container registry readiness.
- `imoyan/houra-client#150` tracks client package and app artifact readiness.
- npm, pub.dev, crates.io, docs.rs, or other ecosystem package publication is
  deferred until the owning SDK, crate, or package surface is stable, licensed,
  documented, and backed by release evidence.

Context7, OpenSSF Scorecard, OpenSSF Best Practices Badge, badges, GitHub
topics, package registry metadata, and container registry metadata are
non-normative discoverability or trust signals. They must not override this
repository's contracts, vectors, design schemas, UI surfaces, release evidence,
or claim boundaries.

OSS listing, package publication, or index registration does not widen Product
MVP readiness, Matrix compatibility, `/versions` advertisement, or Matrix
full-compliance claims.

## Spec Health

Spec health sweeps keep this repository usable as read-only conformance input.
Run them before milestone releases, after broad Matrix roadmap changes, after
Product MVP release-candidate evidence changes, after design schema or UI
surface changes, and after any implementation conformance failure that might
indicate spec ambiguity.

Each sweep should record the checked `houra-spec` ref and inspect
`contracts/SPEC-*.md`, `CONTRACT_MODULE_MAP.md`, `FEATURE_PROFILES.md`,
`MODULE_DEPENDENCIES.md`, README profile/domain coverage, `test-vectors/**/*.json`,
design schemas and inputs, `tool/check_spec.dart`, and `docs/ja/**`.
The current health checklist is
`test-vectors/core/spec-health-conformance-health-checklist.json`.

Health gaps should be handled in one of four ways: fix a small local issue in
the current PR, split behavior or release-scope changes to a focused spec issue,
split missing adoption evidence to an implementation issue, or record that the
sweep found no untracked coverage or validation gap. The current follow-up refs
from the first sweep, `imoyan/houra-spec#198`, `imoyan/houra-spec#202`, and
`imoyan/houra-spec#204`, are closed; no untracked spec-health gap is recorded at
this ref.

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

Houra's production default is TypeScript for both `houra-client` and
`houra-server`. Rust, WASM, N-API, Dart FFI, and other shared-core experiments
belong in `houra-labs` as benchmark and future-commonization candidates, not as
the default implementation path. Each protocol area may stay implementation-owned
in TypeScript, move into a shared artifact later, or split by language when that
is more practical for performance, packaging, or ecosystem fit.

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

The current shared-core work is still pre-adoption. `houra-client` and
`houra-server` remain TypeScript implementations. `houra-labs` contains the Rust
protocol-core prototype, a `wasm-bindgen` wrapper prototype, and a TypeScript
WASM facade prototype for parser, validation, compatibility, and benchmark
experiments. Those artifacts are implementation experiments, not public
contracts, published packages, or required dependencies for `houra-client` or
`houra-server`.

The next shared-core sequence is:

1. Keep `houra-spec` contracts and vectors as the source of truth.
2. Keep production client and server work on the TypeScript path unless a
   focused adoption issue says otherwise.
3. Use `houra-labs` to collect parity, packaging, binary-size, startup, and p95
   benchmark evidence for representative vector batches.
4. Keep Rust/WASM/N-API/Dart FFI artifacts private or unpublished until a
   focused release decision exists.
5. Adopt a shared artifact from implementation repositories only after the
   relevant area reaches `shared-adopted` status with the required evidence.

Until those steps are complete, implementation repositories should keep local
parser or validator code unless a focused adoption issue explicitly wires the
shared artifact into that repository.

日本語メモ: Houra の production 方針は `houra-client` / `houra-server` の
TypeScript 実装を正道にします。`houra-labs` の Rust/WASM/N-API/Dart FFI は
benchmark と将来の共通化候補であり、parity / performance evidence、package 方針、
rollback 方針、実装 repo への明示 adoption issue が揃うまでは required dependency
として扱いません。

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

The production TypeScript path is native TypeScript unless a focused shared-core
adoption issue proves that a lab artifact is smaller, faster enough, or safer
enough to justify the extra runtime boundary. If a shared artifact is adopted
later, the TypeScript and Dart ecosystems need different bindings for different
runtimes:

- TypeScript browser, Vue, and Next client code may use WebAssembly built from a
  lab shared core only after artifact, bundler, startup, and p95 evidence exists.
- TypeScript Node.js and Next server code may use N-API bindings only after
  native packaging, prebuild, fallback, and p95 evidence beats or matches local
  TypeScript for the target boundary.
- TypeScript edge or restricted serverless runtimes should keep local
  TypeScript unless a WebAssembly fallback has explicit startup and binary-size
  evidence.
- Dart CLI, Dart server, and Flutter native code should use a C ABI exposed to
  `dart:ffi` only for adopted shared artifacts.
- Dart web and Flutter web should call a WebAssembly JavaScript wrapper through
  `dart:js_interop` only for adopted shared artifacts; they should not depend on
  `dart:ffi`.

This split follows the current Dart direction where `dart:js_interop` is the
web interop layer and `package:web` is the long-term web API package designed
with Wasm compatibility in mind. The Dart native path and Dart web path should
therefore share the same Dart facade API while using different backends through
conditional imports.

### Build and distribution policy

Rust compile time should not become a tax on every application developer. If a
shared Rust artifact is adopted later, implementation packages should publish
prebuilt artifacts for supported platforms wherever practical:

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

Sharing is optional. Local TypeScript is the production baseline for the current
Houra client and server. An area should not be moved into shared code if the
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
- `lab-candidate`: suitable for a lab shared-core experiment, but not a required
  dependency until parity, packaging, rollback, and performance evidence exists.
- `shared-adopted`: a shared artifact has passed parity and performance gates
  for the area and may be used by adapters through a focused adoption issue.
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
| Matrix versions request/response handling | `lab-candidate` | `client+server` | `core-hard-dep` allowed for JSON parsing only inside the lab artifact | Local TypeScript by default; WASM/N-API only after adoption evidence | `dart:ffi` or `dart:js_interop` only after adoption evidence | Lab parser and validator for `SPEC-030` request and response shape | Fetching `/_matrix/client/versions`, cache policy, and feature gating | A runtime cannot consume the shared artifact without larger packaging cost than local parsing | Low after prebuilt artifacts; changing facade policy should not rebuild core | Optional npm WASM, npm N-API, Dart native library, or Dart web WASM wrapper | Server emission and client parsing pass against `test-vectors/core/matrix-client-versions-basic.json`; p95 within `+10%` of local TypeScript parsing |
| Matrix / Houra error parsing and emission | `lab-candidate` | `client+server` | `core-hard-dep` allowed for stable JSON and enum helpers only inside the lab artifact | Local TypeScript by default; WASM/N-API only after adoption evidence | Dart facade dispatches to FFI or JS interop backend only after adoption evidence | Shared error envelope and Matrix `M_*` vocabulary parser / builder | HTTP status handling, retry policy, telemetry, and user-facing messages | Platform error models require native exception or result types outside the shared ABI | Low; adding host-specific error text stays outside the lab artifact | Optional protocol-core artifacts | Vectors cover client parsing and server emission without adapter-specific fields; no measurable UI-path regression |
| Identifier and URI validation | `lab-candidate` | `client+server` | `core-hard-dep` allowed for regex or parser utilities if they are mainstream and portable | Local TypeScript by default; WASM/N-API only after adoption evidence | FFI on native and JS interop on web only after adoption evidence | Matrix and Houra identifier, room ID, event ID, user ID, content URI, and namespace validators | Input timing, UI validation display, and normalization before storage | A platform requires native text or URL APIs for correctness, accessibility, or locale behavior | Medium if parser dependencies change; stable grammar updates should be batched | Optional prebuilt parser artifacts per supported runtime | Positive and negative grammar vectors pass in client and server harnesses; boundary overhead is hidden by validation batch size |
| Event content and message schema validation | `lab-candidate` | `client+server` | `core-hard-dep` allowed for JSON schema-like validation only when it stays protocol-focused | Local TypeScript by default; TS may keep permissive draft typing | FFI / JS interop for canonical validation only after adoption evidence; Dart may keep permissive draft models | Shared event type, message content, state key, and redaction shape validators | Rich composer UX, server persistence, timeline indexing, moderation policy, and draft states | A client needs permissive draft validation while servers require stricter acceptance rules | Medium; schema changes rebuild shared validators but not UI composer policy | Optional protocol validator artifacts plus native/web facade packages | Client compose fixtures and server acceptance/rejection vectors agree on canonical shapes; validation batch p95 stays within `+10%` |
| Transaction ID and idempotency semantics | `lab-candidate` | `client+server` | `core-hard-dep` only for small deterministic helpers | Local TypeScript by default; WASM/N-API helper only after adoption evidence | FFI / JS interop helper only after adoption evidence | Transaction ID grammar, idempotency-key comparison, and replay classification helpers | Retry scheduling, persistence of sent-message state, offline queueing, and conflict UI | Offline clients need language-native queue behavior that cannot share the same runtime | Low; queue policy changes should not rebuild the lab artifact | Optional small helper artifact bundled with protocol core | Retry and conflict vectors pass with identical transaction classification; local queue performance is not gated on shared-core calls |
| Canonical JSON / signing helpers | `lab-candidate` | `client+server` | `core-hard-dep` for canonicalization and hash primitives; `extension-dep` for heavier signing stacks | Local TypeScript by default; WASM/N-API only when canonicalization evidence justifies it | FFI for native signing helpers; JS interop/WASM for web canonicalization only after adoption evidence | Canonical JSON, hash, and signing input helper primitives | Key storage, key rotation policy, secure enclave integration, and request transport | Native crypto policy or platform keychain constraints require separate bindings | Medium to high when crypto dependencies change; isolate heavy crypto outside the pure core | Optional separate core and crypto extension artifacts | Cross-language canonicalization fixtures produce byte-identical output; crypto extension has its own p95 and binary-size gate |
| Room version auth/state resolution | `lab-candidate` | `server-only` | `extension-dep` unless the algorithm is small enough for pure core | Local TypeScript by default; N-API only when server-side evidence justifies it | Usually not used by Dart clients; Dart server may use FFI if adopted | Room-version-aware auth events, state resolution, and event validation helpers | Persistent event store layout, indexing, sync pagination, conflict recovery UI, and federation policy | Performance, database coupling, or federation deployment needs a server-native path | High; keep database and storage policy outside the lab artifact | Optional server-side native artifact only until a client/tooling use case exists | Room-version fixtures and restart-safe server integration tests pass; algorithm cost improves or matches local implementation |
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
| Matrix versions request/response handling | Parse and validate `GET /_matrix/client/versions` request/response shape and release-advertisement result fields | `SPEC-030`, `SPEC-064`, `test-vectors/core/matrix-client-versions-basic.json`, `test-vectors/core/matrix-version-advertisement-*.json` | `houra-labs` first for evidence; `houra-server` and `houra-client` stay TypeScript unless a later adoption issue is opened | Optional lab parser / validator plus TypeScript WASM or N-API facade and Dart facade only after artifact evidence exists | Fetching the endpoint, cache policy, runtime feature gating, release decision ownership, and all network behavior | Benchmark gate; do not migrate existing implementations only because adjacent code was touched | Vector parity, p95 `+10%` or hidden latency evidence, secret-free diagnostics, artifact manifest, `abi_version`, facade stability notes, rollback to local parser |
| Matrix / Houra error parsing and emission | Parse and build public error envelopes and stable Matrix `M_*` vocabulary without owning user-facing messages or retry policy | `SPEC-002`, `SPEC-031`, `test-vectors/core/error-basic.json`, `test-vectors/core/matrix-foundation-error-basic.json`, `test-vectors/auth/auth-error-basic.json`, `test-vectors/media/matrix-media-download-not-found.json` | `houra-labs` first for evidence; `houra-server` and `houra-client` stay TypeScript unless a later adoption issue is opened | Optional shared error enum, envelope parser, and serializer with stable host-language result types | HTTP status selection, retry/cancellation, telemetry, localization, UI copy, and product-specific recovery flow | Benchmark gate; next-touch swaps require an explicit adoption decision | Cross-repo vector parity, no adapter-specific fields in shared output, redaction review, p95 evidence, packaging notes, rollback to local error mapping |

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

日本語メモ: production は TypeScript 実装を正道にし、`versions` と error envelope も
まず `houra-labs` で artifact / parity / performance evidence を見るだけにします。
`houra-server` と `houra-client` へ入れるのは、TS 実装より小さい・速い・安全などの
理由が揃い、明示の adoption issue を切った場合に限ります。

### Security, Privacy, and Abuse-Case Review

This cross-cutting review tracks specification guardrails that prevent Houra
contracts from leaving security-sensitive behavior ambiguous. It does not
collect implementation secrets, production configuration, raw tokens, private
keys, push provider credentials, or unredacted release artifacts.

| Review area | Contract coverage | Current follow-up | Adoption rule |
|---|---|---|---|
| Auth/session lifecycle and owner scope | `SPEC-004`, `SPEC-032`, `SPEC-034`, `SPEC-053` cover bearer-token attachment, logout invalidation, device APIs, and key-backup surfaces | #180 closes the missing Houra stale-token logout vector plus Matrix device and key-backup owner-scope negative vectors | Do not record implementation adoption unless stale-token and cross-user negative vectors pass |
| Protected key and verification operations | `SPEC-050`, `SPEC-054`, `SPEC-069` keep crypto operations adapter-owned and define parser-facing device-key / verification surfaces | #179 tracked the original `SPEC-054` auth precondition mismatch; `SPEC-054` now requires auth before signature or query semantics | Protected key operations must fail authentication before semantic signature errors are evaluated |
| Media filename and download metadata | `SPEC-020`, `SPEC-038`, `SPEC-071`, `SPEC-072` cover MVP media, Matrix media, deferred range/thumbnail behavior, and encrypted-media boundaries | #181 closes `Content-Disposition` filename safety for CR/LF, control characters, separators, traversal-like names, and MVP quoting policy | Download metadata must not permit header injection or unsafe path-shaped filenames as canonical behavior |
| Federation and push outbound destinations | `SPEC-055`, `SPEC-060`, and `SPEC-061` define federation bootstrap, push gateway, and federation smoke boundaries | #182 closes SSRF-oriented destination controls for well-known redirects, DNS rebinding, private ranges, and push gateway URLs | Outbound request contracts must fail closed on unsafe internal destinations while preserving legitimate public federation and push gateway paths |
| Error envelopes, diagnostics, and release evidence | `SPEC-002`, `SPEC-031`, `SPEC-064`, `SPEC-065`, `SPEC-070`, `SPEC-071`, and `SPEC-072` define public error shape, fail-closed advertisement, release evidence fields, and redacted deferred-boundary evidence | No new issue from this pass; release evidence implementation refs remain tracked by #200 and must cite redacted artifacts only | Public errors and release evidence must not expose bearer tokens, refresh tokens, reset tokens, private keys, pushkeys, vendor tokens, raw secrets, or internal state beyond the contract vector |
| Shared-core security boundary | `Shared boundary and risk rule` and `Initial Shared-Core Adoption Gates` keep shared parser/validator work separate from host-owned transport, storage, token, crypto, retry, and UI policy | Future adoption issues should inherit #198 evidence requirements instead of moving host-owned secrets into shared code | Shared artifacts require vector parity, p95 evidence, redaction review, artifact manifest, `abi_version`, facade stability notes, and rollback before adoption |

Security and privacy review issue handling:

- #179 closed the highest-priority protected-key auth-precedence gap by adding
  authenticated positive vectors and missing-token negative coverage to
  `SPEC-054`.
- #180 closes the auth owner-scope gap by adding Houra logout-token
  invalidation and Matrix cross-user device / key-backup negative vectors.
- #181 closes the media header-safety gap by requiring unsafe filename download
  variants to fail before `Content-Disposition` is emitted.
- #182 closes the outbound egress gap by requiring federation discovery and push
  gateway destinations to reject unsafe internal ranges, redirect-to-private,
  and DNS rebinding before sending traffic.
- Do not create implementation-repository adoption issues for future security
  review gaps until the corresponding contract and vector changes land in
  `houra-spec`.
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
| Application Service API | appservice registration, namespace ownership, transactions, sender localpart, bridge-style event delivery | Not implemented; `SPEC-058` adds registration shape, namespace ownership, homeserver-to-appservice transactions, user queries, and room-alias queries; `SPEC-075` keeps the full-breadth Application Service API, third-party network, ping, Client-Server extension, and bridge behavior gaps explicit and non-advertised for the current release candidate | A registered appservice receives transactions and can puppet/send events within its declared namespaces |
| Identity Service API | third-party identifier validation and lookup | Not implemented; `SPEC-059` adds the separate service boundary, identity token scope, hash lookup, validation session, bind, unbind, and privacy/auth failure gate; `SPEC-076` keeps invitation storage, ephemeral invitation signing, provider delivery, consent UI, and full Identity Service API gaps explicit and non-advertised for the current release candidate | Either explicitly out of supported deployment scope or implemented as a separate identity component with conformance evidence |
| Push Gateway API | push notification gateway contracts | Not implemented; `SPEC-060` adds the separate push gateway boundary, notify payload, `event_id_only` privacy shape, pusher/push-rule setup, rejected pushkey, and delivery failure gate; `SPEC-077` keeps vendor provider credentials, device permission UI, notification rendering, background scheduling, and full Push Gateway API gaps explicit and non-advertised for the current release candidate | Either explicitly out of supported deployment scope or implemented with privacy-aware notification payload tests |
| Room Versions | room version algorithms, event authorization rules, state resolution, room upgrade behavior | MVP rooms do not implement Matrix room versions or event DAG auth; `SPEC-040` adds the first Matrix event DAG and auth-event reference contract, `SPEC-041` adds state snapshot / representative state-resolution vectors, `SPEC-042` defines the stable room versions 1-12 / default 12 gate, `SPEC-043` adds representative membership, power-level, and redaction auth vectors, `SPEC-044` adds alias / upgrade / restart persistence gates without full room-version auth completeness, and `SPEC-078` keeps full room-version algorithm and domain-wide advertisement gaps explicit and non-advertised for the current release candidate | Supported room versions are listed, default room version is declared, and auth/state-resolution tests pass |
| Olm & Megolm | E2EE primitives, one-time keys, device keys, encrypted room messaging, key backup, verification, cross-signing | Not implemented; `SPEC-050` defines the adapter ownership boundary and forbids local Olm/Megolm implementation; `SPEC-069` isolates the first client/parser-facing device-key query contract; `SPEC-051` adds device key, one-time key, and fallback key publication/claim contracts; `SPEC-052` adds to-device and encrypted-room send/receive gates; `SPEC-053` adds server-side key backup and logout/relogin restore gates; `SPEC-054` adds SAS verification, cross-signing, and wrong-device failure gates; `SPEC-079` keeps full Olm & Megolm E2EE breadth explicit and non-advertised for the current release candidate | Use a mainstream Matrix crypto stack; encrypted rooms, device trust, key backup, restore, verification, and wrong-device failure flows pass |
| Appendices/common rules | identifiers, timestamps, namespacing, error vocabulary, deprecation behavior | Partially aligned only where MVP contracts copied the concept | Shared parser and validation tests enforce Matrix grammar and compatibility claims |

Matrix domain coverage evidence report:

- `SPEC-062` defines the Matrix v1.18 stable-domain coverage report shape for
  contract refs, implementation repos, adoption issue refs, pass/fail evidence,
  known stable-domain gaps, artifact paths, and advertisement decisions.
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
- `test-vectors/core/matrix-v1-18-release-evidence-current-blocked-bundle.json`
  is the current #200 blocked bundle. It records real implementation refs from
  the latest `houra-server` and `houra-client` evidence, keeps the example
  bundle separate, and intentionally sets
  `stale_or_mismatched_refs_block_release: false`,
  `versions_advertisement_allowed: false`, and `ready_to_publish: false` until
  a publishable Matrix support claim is allowed.

Matrix v1.18 roadmap close-out snapshot:

- Snapshot checked at: 2026-05-16T21:30:04+09:00.
- #95 remains the parent Matrix v1.18 roadmap. #189 is the historical close-out
  snapshot lane; current issue sync is maintained here and in #95 so domain
  issues, implementation adoption refs, and release evidence do not drift.
- The `houra-spec` domain issue checklists for #97 through #101 have completed
  their contract/vector/gate children. That is contract coverage, not a release
  support claim.
- `houra-server` adoption refs named by #189 are closed:
  imoyan/houra-server#59 through imoyan/houra-server#69 and
  imoyan/houra-server#106 through imoyan/houra-server#108. imoyan/houra-server#145
  records the current-candidate release-scope exclusion decisions that closed
  imoyan/houra-server#133 as an active Complement/full-breadth blocker.
- Current open `houra-server` Matrix implementation gap trackers are 31 issues:
  in `imoyan/houra-server`, Client-Server #135, #153, #195, and #197; Room
  Versions #140 and #168 through #170; E2EE #141, #173, #174, and #252 through
  #255; Server-Server #136, #158 through #160, and #234;
  Application Service #137, #162, #163, and #235 through #240; and Identity
  Service #138 and #164. Server-Server #232 and #233, Push Gateway #139, and
  Appendices/common #142 are closed at this snapshot.
- `houra-client` adoption refs named by #189 are closed:
  imoyan/houra-client#55 through imoyan/houra-client#66 and
  imoyan/houra-client#95 through imoyan/houra-client#97. No open
  `houra-client` issue remained in the checked issue list.
- `houra-labs` remains an optional shared-core/parser exploration lane, but no
  open `houra-labs` issue remained in the checked issue list. The prior
  parser/shared-core issues imoyan/houra-labs#56 through #77 are closed at this
  snapshot and do not block Matrix version advertisement unless a release
  candidate includes shared-core artifacts as evidence.
- #200 records the current blocked release evidence bundle with real
  implementation refs and keeps Matrix version advertisement fail-closed.
  #201 records the `SPEC-068` OAuth account-management adoption boundary and
  keeps full Matrix OAuth 2.0 support out of scope. #202 records the `SPEC-069`
  device-key query-only adoption boundary and keeps full E2EE / Olm-Megolm
  support out of scope. #95 must still not be presented as release-ready until
  #97 through #101 link current pass/fail evidence and #95 records a
  publishable Matrix support claim or explicit blocked / out-of-scope decisions
  for the release candidate.
- The current blocked bundle was refreshed at 2026-05-16T21:51:53+09:00 and
  records the same candidate set from `houra-spec`
  f040692d8f27dbde31c16bb93b197eb58ea49811, `houra-server`
  eed3581e21061e660fae7c8d7ff8f3c68891d217, and `houra-client`
  03ef045fd31d5a2dfca7046b2b336d353aff7847. It links every excluded stable
  domain to an explicit current-candidate release-scope decision:
  imoyan/houra-server#135 through imoyan/houra-server#142. Later child issues
  under the same domains track implementation breadth without changing that
  blocked candidate set. Client-Server API still references both #97 and #99
  because the MVP-equivalent slice and breadth slice share the same Matrix
  domain. Release readiness remains blocked by fail-closed Matrix version
  advertisement; `GET /_matrix/client/versions` still returns no Matrix
  versions and no publishable Matrix support claim is allowed.
- `SPEC-073` decomposes `houra-server#135` Client-Server full-breadth gaps into
  discovery/support, auth refresh, event history, room breadth, sync extension,
  media breadth, and E2EE Client-Server lanes. It is a fail-closed gap
  inventory only; it does not widen Matrix version advertisement. It also
  orders the closed `houra-server#178` through `houra-server#184` release
  exclusions into contract/vector/server-gate promotion lanes so runtime
  compatibility is not inferred from closed exclusion trackers.
- `SPEC-074` decomposes `houra-server#136` Server-Server full-breadth gaps into
  discovery/key/auth, transaction/PDU/EDU, event retrieval, join/knock/leave,
  directory/query, federation E2EE/media, policy/ACL/signing, and Complement
  breadth lanes. It is a fail-closed gap inventory only; it does not claim full
  federation or Complement pass.
- `SPEC-075` decomposes `houra-server#137` Application Service full-breadth gaps
  into registration/token lifecycle, transaction delivery, user/room queries,
  third-party network directories, ping/liveness, Client-Server extension, and
  bridge evidence lanes. It is a fail-closed gap inventory only; it does not
  claim full Application Service API or bridge protocol support.
- `SPEC-076` decomposes `houra-server#138` Identity Service full-breadth gaps
  into service/account/terms, key/signature, lookup/privacy, validation/provider
  delivery, bind/unbind lifecycle, invitation storage, ephemeral signing,
  consent UI, and release-evidence lanes. It is a fail-closed gap inventory
  only; it does not claim full Identity Service API or external provider
  operation.
- `SPEC-077` decomposes `houra-server#139` Push Gateway full-breadth gaps into
  notify payload, pusher configuration, push rule evaluation, delivery retry,
  privacy payload minimization, vendor provider credentials, client permission
  and rendering, security/redaction, and release-evidence lanes. It is a
  fail-closed gap inventory only; it does not claim production push provider or
  client notification support.
- `SPEC-078` decomposes `houra-server#140` Room Versions full-algorithm gaps
  into stable-version metadata, event format, auth rules, state resolution,
  event acceptance/rejection, room upgrades, federation, shared helpers, and
  release-evidence lanes. It is a fail-closed gap inventory only; it does not
  claim full room-version algorithms or domain-wide room-version advertisement.
- `SPEC-079` decomposes `houra-server#141` Olm & Megolm full E2EE gaps into
  maintained crypto stack/local state ownership, device keys/device lists, Olm
  to-device, Megolm room sessions, key backup/secret storage, verification and
  cross-signing, encrypted media, cross-domain interaction, and release-evidence
  lanes. It is a fail-closed gap inventory only; it does not claim full E2EE or
  local Olm/Megolm support.
- `SPEC-080` splits the `m.room_versions.default` /
  `m.room_versions.available` capabilities advertisement boundary out of
  `SPEC-078`. It keeps `available` as an implementation-evidence list, not a
  copy of the Matrix v1.18 stable room-version registry, so the representative
  room version 12 subset does not become a full Room Versions claim.
- `SPEC-081` is the first `SPEC-079` child contract. It records the maintained
  Matrix crypto stack evidence gate and keeps secure storage, recovery keys,
  backup secrets, local deletion, and recovery UX host-owned. It does not select
  a crypto package, add endpoints, or widen Matrix version advertisement.
- `SPEC-085` splits the event retrieval, joined-members, historical-membership,
  timestamp-to-event, and deprecated compatibility descriptor/parser boundary
  out of `SPEC-073`. It gives `houra-labs` a parser-only adoption target while
  keeping runtime route behavior, history visibility, authorization, deprecated
  endpoint support, and Client-Server advertisement excluded.
- `SPEC-093` splits the `/sync` query descriptor and response-section parser
  boundary out of the `SPEC-073` `sync-breadth-extensions` lane. It gives
  `houra-labs` a parser-only adoption target for `full_state`, `filter`,
  `set_presence`, `use_state_after`, lazy-loading filter flags, presence,
  to-device, device-list, one-time-key-count, invite, leave, and knock sync
  envelopes while keeping long-poll timing, token persistence, fanout
  correctness, E2EE readiness, lazy-loading correctness, and Matrix
  Client-Server advertisement fail-closed.
- `SPEC-095` splits the media repository descriptor and metadata parser
  boundary out of the `SPEC-073` `media-repository-breadth` lane. It gives
  `houra-labs` a parser-only adoption target for media config, URL preview,
  thumbnail, create-upload, resumable-upload metadata, safe filename, and
  `mxc://` URI helpers while keeping binary transfer, thumbnail generation,
  preview crawling, remote fetch, range requests, encrypted attachment behavior,
  and Matrix Client-Server advertisement fail-closed.
- #97 through #101 should not be closed merely because their spec-side
  checklists are complete or because the current release candidate excludes the
  domain from advertisement. Close them only when #95 links current pass/fail
  evidence and records the intended release outcome for that domain.

Matrix readiness map:

- Readiness map checked at: 2026-05-16T21:33:52+09:00.
- The first publishable Matrix scope defaults to a Client-Server subset only.
  This still requires current pass/fail evidence, release notes, and
  `/versions` advertisement that name the included endpoint families exactly.
  Until that evidence is refreshed, `/versions` remains empty and no Matrix
  support claim is allowed.
- `houra-server#135` is the release-blocker tracker for deciding whether the
  Client-Server subset can be advertised. Its open child gaps #153, #195, and
  #197 are known non-advertised Client-Server breadth gaps for the first subset
  unless a later release candidate explicitly includes them with passing
  evidence.
- Room Versions are explicitly out of scope for the first subset:
  `houra-server#140` remains the known non-advertised domain gap, and #168
  through #170 are post-release breadth issues unless the advertised scope is
  widened.
- E2EE is explicitly out of scope for the first subset: `houra-server#141`
  remains the known non-advertised Olm/Megolm domain gap, and #173, #174, and
  #252 through #255 are post-release breadth issues.
- Federation and ecosystem APIs are explicitly out of scope for the first
  subset: Server-Server `houra-server#136`, Application Service
  `houra-server#137`, and Identity Service `houra-server#138` remain known
  non-advertised domain gaps. Their open child issues #158 through #160, #162,
  #163, #164, #234, and #235 through #240 are post-release breadth issues.
- `houra-client` and `houra-labs` have no open Matrix adoption issue in the
  checked issue lists. Create new adoption issues only when the selected
  release scope requires current client evidence or shared-core/parser
  artifacts.
- Performance work starts after the claim boundary is stable. Prioritize
  verification speed and stability first: vector batch runtime, server smoke
  runtime, release evidence generation runtime, and Complement-compatible lane
  stability. Record p95 runtime evidence only when a shared parser/core
  adoption or other hot-path change is introduced.
- 日本語メモ: 初回の広告可能範囲は Client-Server subset に限定し、Room Versions、
  E2EE、Federation、Application Service、Identity Service は明示的な対象外として
  fail-closed のまま扱う。速度改善は、claim 境界と evidence が揃った後に、まず
  検証時間と安定性から着手する。

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
- Product MVP happy path evidence and Docker Compose deploy smoke evidence are
  separate evidence classes. Happy path evidence covers contract/vector/UI
  behavior and server-client interaction; deploy smoke evidence covers startup,
  migration, health, connectivity, persistence/auth smoke, and redaction.
- Follow-up adoption tracking is split as `imoyan/houra-server#227` for Docker
  Compose deploy smoke evidence and `imoyan/houra-client#121` for Product MVP
  happy path evidence.
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
- `SPEC-075` records those excluded Application Service API lanes as the
  `houra-server#137` full-breadth gap inventory for the current blocked release
  candidate. It preserves the non-advertisement decision until each lane has
  passing evidence or an explicit release exclusion.
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
- `SPEC-076` records those excluded Identity Service API lanes as the
  `houra-server#138` full-breadth gap inventory for the current blocked release
  candidate. It preserves the non-advertisement decision until each lane has
  passing evidence or an explicit release exclusion.
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
- `SPEC-077` records those excluded Push Gateway API lanes as the
  `houra-server#139` full-breadth gap inventory for the current blocked release
  candidate. It preserves the non-advertisement decision until each lane has
  passing evidence or an explicit release exclusion.
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
- `SPEC-078` records the remaining full-algorithm Room Versions lanes as the
  `houra-server#140` gap inventory for the current blocked release candidate.
  It keeps full auth/state-resolution algorithms and room-version advertisement
  out of the support claim until passing evidence or explicit release exclusion
  exists.
- `SPEC-080` records the independent capabilities advertisement boundary for
  `m.room_versions.default` and `m.room_versions.available`. The current
  representative subset may advertise only room version `12`; stable room
  versions `1` through `11` stay non-advertised until each version has current
  passing implementation evidence.
- `SPEC-079` records the remaining full E2EE Olm & Megolm lanes as the
  `houra-server#141` gap inventory for the current blocked release candidate.
  It keeps full encrypted-room, local crypto, verification, cross-signing,
  secret-storage, key-backup, and device-trust support out of the support claim
  until passing evidence or explicit release exclusion exists.

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
| SPEC-073 | Matrix Client-Server full-breadth gap inventory | `test-vectors/core/matrix-client-server-full-breadth-gap-inventory.json` |
| SPEC-074 | Matrix Server-Server full-breadth gap inventory | `test-vectors/core/matrix-server-server-full-breadth-gap-inventory.json` |
| SPEC-075 | Matrix Application Service full-breadth gap inventory | `test-vectors/core/matrix-application-service-full-breadth-gap-inventory.json` |
| SPEC-076 | Matrix Identity Service full-breadth gap inventory | `test-vectors/core/matrix-identity-service-full-breadth-gap-inventory.json` |
| SPEC-077 | Matrix Push Gateway full-breadth gap inventory | `test-vectors/core/matrix-push-gateway-full-breadth-gap-inventory.json` |
| SPEC-078 | Matrix Room Versions full-algorithm gap inventory | `test-vectors/rooms/matrix-room-versions-full-algorithm-gap-inventory.json` |
| SPEC-079 | Matrix Olm & Megolm full E2EE gap inventory | `test-vectors/messaging/matrix-olm-megolm-full-e2ee-gap-inventory.json` |
| SPEC-080 | Matrix room versions capabilities advertisement boundary | `test-vectors/rooms/matrix-room-versions-capabilities-advertisement-boundary.json` |
| SPEC-081 | Matrix maintained crypto stack and storage ownership boundary | `test-vectors/messaging/matrix-maintained-crypto-storage-ownership-boundary.json` |
| SPEC-082 | Matrix client well-known discovery, support, and policy boundary | `test-vectors/core/matrix-client-well-known-discovery-support-policy.json` |
| SPEC-083 | Matrix room-version event decision artifacts | `test-vectors/events/matrix-room-version-event-decision-artifacts.json` |
| SPEC-084 | Matrix room-version federation cross-domain validation | `test-vectors/events/matrix-room-version-federation-cross-domain-validation.json` |
| SPEC-085 | Matrix Client-Server event retrieval and membership history | `test-vectors/core/matrix-client-server-event-retrieval-membership-history.json` |
| SPEC-086 | Matrix Push Gateway payload minimization boundary | `test-vectors/core/matrix-push-payload-minimization-boundary.json` |
| SPEC-090 | Matrix Client-Server relations, threads, and reactions parser descriptors | `test-vectors/core/matrix-client-server-relations-threads-reactions.json` |
| SPEC-091 | Matrix Push Gateway notify payload and endpoint boundary | `test-vectors/core/matrix-push-notify-payload-gateway-endpoint-boundary.json` |
| SPEC-092 | Matrix Identity Service bind and unbind lifecycle boundary | `test-vectors/core/matrix-identity-bind-unbind-lifecycle-boundary.json` |
| SPEC-093 | Matrix sync breadth extension parser descriptors and response sections | `test-vectors/sync/matrix-sync-breadth-extensions.json` |
| SPEC-094 | Matrix Identity Service validation provider delivery boundary | `test-vectors/core/matrix-identity-validation-provider-delivery-boundary.json` |
| SPEC-095 | Matrix media repository breadth parser descriptors, metadata, filenames, and `mxc://` validation | `test-vectors/media/matrix-media-repository-breadth.json` |
| SPEC-096 | Matrix Identity Service public key and signature boundary | `test-vectors/core/matrix-identity-public-key-signature-boundary.json` |
| SPEC-097 | Matrix federation version, key lifecycle, and request-auth parser descriptors | `test-vectors/core/matrix-federation-version-key-lifecycle-request-auth.json` |
| SPEC-098 | Matrix Push Gateway parser-helper breadth for pusher, push-rule, and redaction descriptors | `test-vectors/core/matrix-push-parser-helper-breadth.json` |
| SPEC-099 | Matrix federation transaction, PDU, EDU, canonical JSON input, and per-PDU response parser descriptors | `test-vectors/events/matrix-federation-pdu-edu-parser-helpers.json` |
| SPEC-100 | Matrix federation public rooms, hierarchy, directory/profile/generic query, and OpenID userinfo parser descriptors | `test-vectors/core/matrix-federation-directory-query-openid-parser-helpers.json` |
| SPEC-101 | Matrix room-version auth-rule fixture runner descriptors | `test-vectors/events/matrix-room-version-auth-rule-fixture-runner.json` |
| SPEC-102 | Matrix E2EE parser-only artifact breadth descriptors | `test-vectors/messaging/matrix-e2ee-parser-artifact-breadth.json` |
| SPEC-103 | Matrix room-version event format, canonical JSON, hash, and signature helper descriptors | `test-vectors/events/matrix-room-version-event-format-hash-signature.json` |
| SPEC-104 | Matrix room-version state-resolution fixture runner descriptors | `test-vectors/events/matrix-room-version-state-resolution-fixture-runner.json` |
| SPEC-105 | Matrix Application Service parser-only artifact breadth descriptors | `test-vectors/core/matrix-application-service-parser-artifact-breadth.json` |
| SPEC-106 | Matrix Identity Service parser-only artifact breadth descriptors | `test-vectors/core/matrix-identity-service-parser-artifact-breadth.json` |
| SPEC-107 | Matrix federation transaction event-validation representative runtime behavior | `test-vectors/events/matrix-federation-transaction-event-validation-runtime.json` |
| SPEC-108 | Matrix federation directory, hierarchy, query, and OpenID representative runtime behavior | `test-vectors/core/matrix-federation-directory-query-openid-runtime.json` |
| SPEC-109 | Matrix federation E2EE device, to-device, and media representative runtime behavior | `test-vectors/core/matrix-federation-e2ee-device-media-runtime.json` |
| SPEC-110 | Matrix federation Server ACL, policy signing, and event hash/signature representative runtime behavior | `test-vectors/core/matrix-federation-acl-policy-signing-runtime.json` |
| SPEC-111 | Matrix federation leave and knock representative runtime behavior | `test-vectors/events/matrix-federation-leave-knock-runtime.json` |
| SPEC-112 | Matrix federation event retrieval, missing-events, state response, and timestamp lookup representative runtime behavior | `test-vectors/events/matrix-federation-event-retrieval-runtime.json` |

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

Product MVP UI surface adoption evidence for the next release candidate is
tracked separately from Docker Compose deploy smoke. The canonical surface is
`design/ui-surfaces/product-mvp.json`; the current client adoption follow-up is
`imoyan/houra-client#122`. Evidence should cite the spec ref, consumer repo ref,
screen/action mapping, duplicate-submit prevention, recoverable error display,
accessibility result or blocker, `product-mvp-happy-path` coverage, and
redaction of tokens, database URLs, private local paths, and machine-specific
environment values.

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
| `houra-server` local `npm run test:ops` | pass | Deploy smoke only: Docker Compose startup, migration, backup/restore, and restart persistence smoke; this row is not Product MVP happy path evidence |
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
| `houra-client` local live e2e | pass | Product MVP behavior evidence against Docker Compose `houra-server` v0.2.0-pre.14; Compose startup itself is deploy smoke evidence |
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
