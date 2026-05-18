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

Do not use `SPEC-*` as the reader-facing numbering system for Matrix-aligned
work. Matrix-facing references should lead with official Matrix identifiers:
the Matrix spec version, API domain, endpoint path or section anchor, MSC
number, and room version as applicable. Existing `SPEC-*` names remain only as
file/link anchors for this repository until those anchors can be replaced
without breaking release evidence and implementation adoption records.
Each contract header carries a `Primary reference` field so readers can start
from the Matrix or Houra reference instead of the repository anchor. The H1 of
each contract matches `Primary reference`; the existing `SPEC-*` value is kept
in `Repository anchor`.

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

Matrix に対応する作業では、`SPEC-*` を読者向けの番号体系として使いません。Matrix 側の
参照は、Matrix spec version、API domain、endpoint path または section anchor、MSC 番号、
room version など、公式 Matrix 仕様側の識別子を先に書きます。既存の `SPEC-*` 名は、
release evidence や実装採用記録のリンクを壊さず置き換えられるまで、このリポジトリ内の
ファイル名・リンク用アンカーとしてだけ残します。

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
contract、vector、UI surface を先に更新します。Product MVP vNext の account recovery /
IdP login、media transfer、encrypted media attachment は、それぞれ `Primary reference`
を先に読める contract / vector / UI surface で定義します。ただし現行 Product MVP
release candidate には含めず、対応 capability と実装 evidence が揃うまで fail-closed
です。既存の repository anchor はリンクや release evidence のために残しますが、読者向けの
説明では Product MVP 側の参照名を先に書きます。

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
  `test-vectors/DOMAIN_INDEX.md` groups fixtures by Matrix domain while keeping
  existing feature-profile paths stable.
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
- `docs/adoption-status.md`: cross-repository adoption status board for
  contract, implementation-reference, and claim-impact lookup.
- `docs/shared-implementation-strategy.md`: shared implementation strategy and
  adoption-gate guidance.
- `docs/matrix-compliance.md`: Matrix v1.18 compliance matrix, roadmap, and
  release-evidence notes.
- `docs/releases/TEMPLATE.md`: release record template for pre-1.0 freeze
  candidates, milestone tags, and claim-boundary evidence.
- `tool/check_spec.dart`: local consistency check for contracts, vectors,
  design tokens, and UI surfaces.
- `docs/architecture/`: non-contract architecture guidance, such as the
  Matrix application extension boundary
  ([`docs/architecture/matrix-application-extension-boundary.md`](docs/architecture/matrix-application-extension-boundary.md)).

## Contracts

Use [`CONTRACT_MODULE_MAP.md`](CONTRACT_MODULE_MAP.md) as the reader-facing
contract registry. It leads with each contract's Matrix or Houra primary
reference, then records the repository anchor and file path needed for Git
history, release evidence, and issue links.

Contract file headings match `Primary reference`. `SPEC-*` identifiers remain
only as repository anchors and filenames so existing links and release records
stay stable; new reader-facing prose should prefer the primary reference.

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

The harness output should follow the conformance tooling result schema and emit
a report per feature profile and vector, with enough detail for the
implementation repository to identify the failed contract or fixture. The v1
target profiles are the existing `core`, `auth`, `rooms`, `events`,
`messaging`, `sync`, and `media` slices.

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

Shared-core adoption evidence v1 follows the shared-core adoption evidence
schema. It is narrower than general conformance reporting: a bundle must tie a
lab candidate back to canonical contracts and vectors while also recording
artifact manifest, `abi_version`, facade stability, binary size, startup, p95
`+10%` gate, secret-free diagnostics, adapter-owned boundaries, and rollback to
the local parser or local error mapping.

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
remain implementation concerns unless a contract entry, vector, design token,
or UI surface is added here.

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
Product MVP vNext account recovery and IdP login actions must remain hidden or
disabled unless the selected server advertises matching capabilities and release
evidence includes the `product-mvp-account-recovery-vnext` flow.
Product MVP vNext media transfer actions must remain hidden or disabled unless
media metadata advertises matching capabilities and release evidence includes
the `product-mvp-media-transfer-vnext` flow.
Product MVP vNext encrypted attachment actions must remain hidden or disabled
unless media metadata advertises matching encrypted attachment capabilities and
release evidence includes the `product-mvp-encrypted-media-vnext` flow,
crypto-adapter handoff evidence, and redacted trust copy.
Product MVP vNext WebRTC low-latency connection actions must remain hidden or
disabled unless the selected server or host adapter advertises matching
`SPEC-140` capability metadata and release evidence includes the
`product-mvp-webrtc-low-latency-vnext` flow, runtime-specific candidate-pair
measurement evidence, fastest-tier baseline comparison when claimed, same-LAN
opt-in evidence when used, and redacted connection diagnostics.
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

Feature-addition candidate review for the candidate is tracked by
`imoyan/houra-spec#366`. The current candidate set includes Product MVP vNext
account recovery / IdP login, media transfer, encrypted media attachment,
WebRTC low-latency / fastest-tier connection planning, and the server-owned
role projection, PII redaction handoff, multilingual handoff, and offline queue
replay boundaries. These refs are bundled for RC review, but they do not become
advertised release behavior until the plan names current implementation refs,
command results, redaction checks, and explicit Product MVP claim boundaries.
Missing capability advertisement, missing fastest-tier baseline comparison, or
stale client/server evidence keeps the candidate fail-closed.

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
| `contracts` | yes | Primary references consumed or changed. Include repository anchors only when an implementation evidence join key still needs them. Use `[]` when not contract-specific. |
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
in the compliance matrix and Matrix Client Versions contract first, then record
the refreshed value in that implementation adoption record.

Example JSONL record:

```jsonl
{"repo":"houra-client","branch":"codex/adopt-media-vectors","issue":"https://github.com/imoyan/houra-client/issues/123","pr":null,"spec_ref":"<houra-spec-sha-or-tag>","implementation_commit":"<implementation-sha>","profiles":["media"],"contracts":["Houra public API / Media"],"vectors":["test-vectors/media/upload-basic.json"],"design_inputs":[],"matrix_reference_snapshot":"README#matrix-v118-compliance-matrix and contracts/SPEC-030-matrix-client-versions.md at spec_ref","started_at":"2026-05-08T10:00:00+09:00","ended_at":"2026-05-08T10:42:00+09:00","elapsed_seconds":2520,"timezone":"Asia/Tokyo","model":"gpt-5.3-codex","execution_mode":"local_task","input_tokens":null,"cached_input_tokens":null,"output_tokens":null,"total_tokens":null,"usage_source":"unavailable","accuracy":"unavailable","verification":[{"command":"npm test","result":"pass","head":"<implementation-sha>"}],"outcome":"shipped","clean_room_confirmed":true,"notes":"No Matrix version fields copied; snapshot is cited from houra-spec."}
```

## Server Alignment Smoke Checklist

Server alignment checks must treat this repository as the expected public
client-server behavior. They may exercise server endpoints, but must not use
server code, database schema, storage design, or migration files as
specification sources.

Use [`CONTRACT_MODULE_MAP.md`](CONTRACT_MODULE_MAP.md) to choose the covered
behavior by `Primary reference`, then run the matching vectors from
`test-vectors/`. Server smoke manifests may store the `Repository anchor` only
when they need a stable file-path or release-evidence join key; human-facing
reports should lead with the Matrix or Houra primary reference.

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
environment values. If a release candidate includes Product MVP vNext account
recovery / IdP login, evidence must also cite advertised capabilities,
`product-mvp-account-recovery-vnext` coverage, and redaction of reset tokens,
email verification tokens, authorization codes, callback query values, and IdP
session identifiers. If it includes Product MVP vNext media transfer, evidence
must cite advertised media metadata capabilities,
`product-mvp-media-transfer-vnext` coverage, and redaction of signed URLs,
local filesystem paths, plaintext media bytes, media keys, and cache filenames
exposing user data. If it includes Product MVP vNext encrypted attachment,
evidence must cite advertised encrypted attachment metadata capabilities,
`product-mvp-encrypted-media-vnext` coverage, crypto-adapter handoff evidence,
missing-key / wrong-key / redacted / recoverable-error state coverage, bounded
trust copy, and redaction of media keys, room keys, recovery keys, signed URLs,
local filesystem paths, plaintext media bytes, decrypted thumbnails, and cache
filenames exposing user data.

## Implementation Adoption Reports

Implementation Adoption Reports now live in [`CHANGELOG.md`](CHANGELOG.md). Use the recent entries there for the current baseline, and keep README changes focused on orientation, release boundaries, and links to canonical or supporting surfaces.

## Local Checks

```bash
dart tool/check_spec.dart
```

## License

This specification root is licensed under the Apache License, Version 2.0. See
`LICENSE`.
