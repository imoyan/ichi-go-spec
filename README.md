# houra-spec

Language: [English](#english) | [日本語](#日本語)

## English

`houra-spec` is the canonical repository for the Houra public specification.
The current GitHub owner/repository spelling is `imoyan/houra-spec`; sibling
implementation repositories use the same `imoyan/houra-*` owner prefix unless a
later migration note says otherwise.

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
password reset、identity provider login の Product MVP vNext 用 contract / vector /
UI surface を定義します。ただし現行 Product MVP release candidate には含めず、
server が capability を advertise し、実装 evidence が揃うまで fail-closed です。
`SPEC-071` は thumbnails、range request、resumable download を Product MVP 次段の
media transfer として扱うための Product MVP vNext contract / vector / UI surface を定義します。
ただし現行 Product MVP release candidate には含めず、media metadata が capability を
advertise し、実装 evidence が揃うまで fail-closed です。
`SPEC-072` は encrypted media attachment の metadata validation、ciphertext download /
decrypt handoff、missing / wrong key、redaction、recoverable error を Product MVP 次段の
optional flow として扱うための Product MVP vNext contract / vector / UI surface を定義します。
ただし現行 Product MVP release candidate には含めず、encrypted-room や complete E2EE の
claim と混同しません。

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
- `CONTRACT_MODULE_MAP.md`: contract registry with feature profile, contract
  type, Matrix domain, and reserved number notes.
- `CHANGELOG.md`: Implementation Adoption Reports and pre-release readiness
  summaries.
- `docs/shared-implementation-strategy.md`: shared implementation strategy and
  adoption-gate guidance.
- `docs/matrix-compliance.md`: Matrix v1.18 compliance matrix, roadmap, and
  release-evidence notes.
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
- `contracts/SPEC-113-conformance-tooling-result-schema.md`
- `contracts/SPEC-114-shared-core-adoption-evidence-schema.md`
- `contracts/SPEC-115-matrix-application-service-masquerade-timestamp-runtime.md`
- `contracts/SPEC-116-matrix-application-service-virtual-user-directory-device-runtime.md`
- `contracts/SPEC-117-matrix-application-service-third-party-network-directory-breadth.md`
- `contracts/SPEC-118-matrix-application-service-ping-liveness-breadth.md`
- `contracts/SPEC-120-matrix-application-service-cs-extension-sync-device-breadth.md`
- `contracts/SPEC-121-matrix-application-service-bridge-security-observability-breadth.md`
- `contracts/SPEC-122-matrix-client-server-auth-refresh-fallback-account-lifecycle.md`
- `contracts/SPEC-123-matrix-application-service-registration-namespace-lifecycle-runtime.md`
- `contracts/SPEC-124-matrix-application-service-transaction-event-delivery-runtime.md`
- `contracts/SPEC-125-matrix-application-service-query-user-room-namespace-runtime.md`

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

The harness output should follow `SPEC-113` and emit a report per feature
profile and vector, with enough detail for the implementation repository to
identify the failed contract or fixture. The v1 target profiles are the
existing `core`, `auth`, `rooms`, `events`, `messaging`, `sync`, and `media`
slices.

At minimum, a v1 runner should expose one result per vector with:

- Feature profile from `CONTRACT_MODULE_MAP.md`.
- Vector name and path from the vector file's `name` field and location.
- Contract id from the vector file's `contract` field.
- `pass`, `fail`, `skipped`, `blocked`, or `out_of_scope` status.
- Failure detail that identifies the failed contract expectation, fixture field,
  or parser category without requiring server implementation context.
- Consumed `houra-spec` ref and exact commit SHA.
- Claim boundary fields proving that the report alone does not widen Product
  MVP, Matrix advertisement, shared-core, or release-readiness claims.

The canonical sample artifact is
`test-vectors/core/conformance-tooling-result-schema-v1.json`. Negative cases
for stale spec refs, unknown vectors, unknown contract ids, profile mismatch,
and unredacted failure details are tracked by
`test-vectors/core/conformance-tooling-result-negative-cases-v1.json`.

The runner may adapt each vector to an implementation-specific test harness, but
the reported result must remain traceable to the canonical vector file. A single
failed vector should not prevent the runner from reporting the remaining vector
results.

`skipped`, `blocked`, and `out_of_scope` are not pass evidence. Product MVP and
Matrix release gates may cite these reports only when their separate adoption
or release-readiness evidence explains the excluded behavior and keeps
unsupported claims fail-closed.

## Shared-Core Adoption Evidence v1

Shared-core adoption evidence v1 follows `SPEC-114`. It is narrower than
general conformance reporting: a bundle must tie a lab candidate back to
canonical contracts and vectors while also recording artifact manifest,
`abi_version`, facade stability, binary size, startup, p95 `+10%` gate,
secret-free diagnostics, adapter-owned boundaries, and rollback to the local
parser or local error mapping.

The canonical sample artifact is
`test-vectors/core/shared-core-adoption-evidence-schema-v1.json`. Negative
cases for stale spec refs, missing parity vectors, absent `abi_version`, p95
regression, unredacted diagnostics, missing rollback, adapter-owned behavior in
the shared artifact, and claim-boundary widening are tracked by
`test-vectors/core/shared-core-adoption-evidence-negative-cases-v1.json`.

This evidence is an input to focused adoption issues. `shared-adopted` does not
mean a required dependency, and it does not widen Product MVP readiness, Matrix
advertisement, release readiness, or production TypeScript replacement by
itself.

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
Optional `SPEC-070` account recovery and IdP login actions are Product MVP vNext
coverage; they must remain hidden or disabled unless the selected server
advertises matching capabilities and release evidence includes the
`product-mvp-account-recovery-vnext` flow.
Optional `SPEC-071` media transfer actions are also Product MVP vNext coverage;
they must remain hidden or disabled unless media metadata advertises matching
capabilities and release evidence includes the `product-mvp-media-transfer-vnext`
flow.
Optional `SPEC-072` encrypted attachment actions are also Product MVP vNext
coverage; they must remain hidden or disabled unless media metadata advertises
matching encrypted attachment capabilities and release evidence includes the
`product-mvp-encrypted-media-vnext` flow, crypto-adapter handoff evidence, and
redacted trust copy.
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
- GitHub private vulnerability reporting is enabled before public listing. If
  it is not available yet, public listing remains blocked until the reporting
  channel is enabled or an equivalent private channel is documented.
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

Detailed shared implementation guidance now lives in [`docs/shared-implementation-strategy.md`](docs/shared-implementation-strategy.md). It remains supporting context; canonical behavior stays in `contracts/SPEC-*.md`, `test-vectors/`, and `design/`.

## Matrix v1.18 Compliance Matrix

Detailed Matrix v1.18 coverage, roadmap, and release-evidence notes now live in [`docs/matrix-compliance.md`](docs/matrix-compliance.md). Matrix support remains fail-closed unless the relevant contract, vector, adoption evidence, and release gate explicitly allow advertisement.

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
| SPEC-070 | Product MVP account recovery and IdP login vNext capability, request, response, and fail-closed boundary | `test-vectors/auth/product-mvp-account-recovery-*.json`, `test-vectors/auth/product-mvp-email-verification-*.json`, `test-vectors/auth/product-mvp-password-reset-*.json`, and `test-vectors/auth/product-mvp-idp-login-*.json` |
| SPEC-071 | Product MVP thumbnails, range request, resumable download, metadata capability, and fail-closed boundary | `test-vectors/media/product-mvp-media-transfer-*.json`, `test-vectors/media/product-mvp-thumbnail-*.json`, `test-vectors/media/product-mvp-range-download-*.json`, and `test-vectors/media/product-mvp-resumable-download-*.json` |
| SPEC-072 | Product MVP encrypted media attachment capability metadata, validation, ciphertext download/decrypt handoff, state/retry UI, and fail-closed boundary | `test-vectors/media/product-mvp-encrypted-media-*.json` |
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
| SPEC-115 | Matrix Application Service `as_token` masquerading and timestamp massaging representative runtime behavior | `test-vectors/core/matrix-application-service-masquerade-timestamp-runtime.json` |
| SPEC-116 | Matrix Application Service virtual-user sync, appservice directory visibility, and device metadata representative runtime behavior | `test-vectors/core/matrix-application-service-virtual-user-directory-device-runtime.json` |
| SPEC-126 | Product MVP role/audience projection boundary with allowlist, fail-closed, and redacted evidence checks | `test-vectors/core/product-mvp-role-projection-boundary.json` |
| SPEC-127 | Product MVP PII redaction handoff boundary with classification, redaction, human approval, approved handoff, and fail-closed redaction evidence checks | `test-vectors/core/product-mvp-pii-redaction-handoff-boundary.json` |
| SPEC-128 | Product MVP multilingual handoff boundary with source/target locale, review actor, confirmed translation export, and fail-closed provider draft redaction checks | `test-vectors/core/product-mvp-multilingual-handoff-boundary.json` |
| SPEC-129 | Product MVP offline queue replay boundary with idempotency, deduplication, payload drift rejection, raw device data exclusion, and redacted evidence checks | `test-vectors/core/product-mvp-offline-queue-replay-boundary.json` |
| SPEC-130 | Matrix Olm withheld-key to-device relay boundary with opaque withheld-key, room-key request, forwarded-room-key, cancellation, and fail-closed E2EE advertisement checks | `test-vectors/messaging/matrix-olm-withheld-key-to-device-relay.json` |

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
environment values. If a release candidate includes `SPEC-070`, evidence must
also cite advertised capabilities, `product-mvp-account-recovery-vnext`
coverage, and redaction of reset tokens, email verification tokens,
authorization codes, callback query values, and IdP session identifiers.
If it includes `SPEC-071`, evidence must cite advertised media metadata
capabilities, `product-mvp-media-transfer-vnext` coverage, and redaction of
signed URLs, local filesystem paths, plaintext media bytes, media keys, and
cache filenames exposing user data.
If it includes `SPEC-072`, evidence must cite advertised encrypted attachment
metadata capabilities, `product-mvp-encrypted-media-vnext` coverage,
crypto-adapter handoff evidence, missing-key / wrong-key / redacted /
recoverable-error state coverage, bounded trust copy, and redaction of media
keys, room keys, recovery keys, signed URLs, local filesystem paths, plaintext
media bytes, decrypted thumbnails, and cache filenames exposing user data.

## Implementation Adoption Reports

Implementation Adoption Reports now live in [`CHANGELOG.md`](CHANGELOG.md). Use the recent entries there for the current baseline, and keep README changes focused on orientation, release boundaries, and links to canonical or supporting surfaces.

## Local Checks

```bash
dart tool/check_spec.dart
```

## License

This specification root is licensed under the Apache License, Version 2.0. See
`LICENSE`.
