# SPEC-114: Shared-Core Adoption Evidence Schema

Status: draft
Feature profile: core
Contract type: schema
Matrix domain: Appendices/common rules
Canonical: yes

## Purpose

Define the evidence bundle shape used before any Houra implementation
repository treats a lab shared-core artifact as adopted.

This contract lets `houra-labs` experiments report parity, artifact,
performance, redaction, facade-stability, and rollback evidence back to the
canonical `houra-spec` contract and vector set. It does not define a Rust,
WASM, N-API, Dart FFI, TypeScript, or Dart implementation.

## Scope

Shared-core adoption evidence v1 covers small protocol boundaries that are
already identified as initial candidates:

- Matrix versions request and response handling, based on `SPEC-030`,
  `SPEC-064`, and the Matrix version vectors under `test-vectors/core/`;
- Matrix and Houra error envelope parsing and emission, based on `SPEC-002`,
  `SPEC-031`, and endpoint contracts that emit the public error vectors under
  `test-vectors/core/`, `test-vectors/auth/`, and `test-vectors/media/`.

The evidence bundle is an adoption gate. It must not replace production
TypeScript paths, publish a shared artifact, widen Product MVP readiness, widen
Matrix version advertisement, or make a shared-core package a required
dependency by itself.

## Evidence bundle shape

A shared-core adoption evidence bundle is a JSON object with:

- `schema_version`, fixed to `shared-core-adoption-evidence-v1`;
- `generated_at`, an ISO-8601 timestamp with timezone;
- `houra_spec_ref`, a tag, branch, or commit label;
- `houra_spec_commit`, the exact consumed commit SHA;
- `candidate_evidence`, one record per shared-core candidate;
- `claim_boundary`, proving that the bundle alone does not widen release,
  Matrix advertisement, or required-dependency claims;
- `redaction`, proving that diagnostics and artifact metadata are secret-free.

Each candidate evidence record contains:

- `candidate_id` and `candidate_area`;
- `status`, one of `spec-only`, `lab-candidate`, `shared-adopted`,
  `adapter-owned`, `split-by-language`, or `avoid-shared`;
- `source_contracts`, listing known `SPEC-*` ids;
- `source_vectors`, listing canonical vector paths consumed by the experiment;
- `consumer_repos`, listing repositories that may consume the evidence;
- `artifact_manifest`, including artifact name, artifact type, package refs,
  `abi_version`, facade APIs, target runtimes, binary size, startup, build or
  rebuild-cost notes, dependency/license notes, and prebuilt-artifact policy;
- `parity_evidence`, including vector pass/fail status and any
  `SPEC-113` conformance reports cited by the experiment;
- `performance_evidence`, including representative batch name, local p95,
  shared-artifact p95, p95 regression percentage, the p95 `+10%` decision, and
  whether the cost is hidden by network, disk, or UI latency;
- `security_boundary`, including secret-free diagnostics, redaction review,
  hidden I/O/network/disk checks, adapter-owned responsibilities, and forbidden
  shared responsibilities;
- `facade_stability`, including the `abi_version`, TypeScript facade status,
  Dart facade status, adoption stability, and breaking-change policy;
- `rollback`, including a rollback-to-local-parser path, owner, trigger
  conditions, and verification command;
- `claim_boundary`, proving that this candidate does not widen Product MVP,
  Matrix, release, or required-dependency claims unless it is separately
  adopted.

## Status semantics

- `spec-only`: only the canonical contract and vectors are shared.
- `lab-candidate`: a lab artifact may collect parity and performance evidence,
  but it is not a required dependency and is not adopted by implementation
  repositories.
- `shared-adopted`: a focused adoption issue may use the shared artifact after
  parity vectors, redaction review, artifact manifest, `abi_version`, facade
  stability, packaging or rebuild-cost notes, p95 evidence, and rollback are
  complete.
- `adapter-owned`: the behavior stays in the host implementation because
  transport, storage, UI, lifecycle, ecosystem, or policy ownership matters
  more than shared code.
- `split-by-language`: one language family may share an artifact while another
  keeps a local implementation.
- `avoid-shared`: shared-core adoption is rejected because it would add
  unacceptable performance, packaging, security, or maintenance cost.

`shared-adopted` is not the same as required dependency. A repository may use a
shared artifact only through a focused adoption issue and must keep a local
rollback path unless a later contract explicitly changes that rule.

## Initial candidate gates

Matrix versions request/response handling may become `shared-adopted` only when
the evidence cites `SPEC-030`, `SPEC-064`,
`test-vectors/core/matrix-client-versions-basic.json`, and the
`test-vectors/core/matrix-version-advertisement-*.json` vectors. Fetching the
endpoint, caching, runtime feature gates, and release advertisement decisions
remain adapter-owned.

Matrix and Houra error envelope handling may become `shared-adopted` only when
the evidence cites `SPEC-002`, `SPEC-031`, and the endpoint contracts that own
the selected error fixtures, including
`test-vectors/core/error-basic.json`,
`test-vectors/core/matrix-foundation-error-basic.json`,
`test-vectors/auth/auth-error-basic.json`, and
`test-vectors/media/matrix-media-download-not-found.json`. HTTP status
selection, retry/cancellation, telemetry, localization, user-facing copy, and
product-specific recovery flow remain adapter-owned.

## Rejection cases

Consumers must reject or mark the evidence invalid when:

- `houra_spec_commit` does not match the vector set used by the experiment;
- a source vector path or name does not exist in the consumed `houra-spec`
  checkout;
- a source contract is unknown or not listed in `CONTRACT_MODULE_MAP.md`;
- `artifact_manifest.abi_version` is absent;
- `shared-adopted` is claimed without complete parity evidence;
- p95 shared-artifact cost exceeds local implementation p95 by more than
  `+10%` and is not explicitly hidden by network, disk, or UI latency;
- diagnostics include bearer tokens, refresh tokens, database URLs, signed or
  credentialed URLs, private local paths, media keys, room keys, recovery keys,
  pushkeys, vendor tokens, plaintext payload bytes, or other raw secrets;
- rollback to the local parser or local error mapping is absent;
- the shared artifact owns adapter responsibilities such as transport, secure
  storage, token persistence, retry policy, UI rendering, crypto stack
  selection, or production release advertisement;
- the bundle widens Product MVP, Matrix advertisement, release readiness, or
  required-dependency claims without a separate adoption gate.

## Compatibility boundaries

- Existing contract and vector behavior stays available.
- This contract does not require `houra-labs` to publish artifacts.
- This contract does not require implementation repositories to adopt Rust,
  WASM, N-API, Dart FFI, or any shared runtime.
- This contract does not replace `SPEC-113`; shared-core evidence may cite
  conformance reports, but it must add artifact, security, performance,
  facade-stability, and rollback evidence before adoption.
- This contract does not widen `GET /_matrix/client/versions` advertisement or
  Matrix domain support.

## Adoption decision checklist

After this contract merges:

- `houra-labs` may emit `shared-core-adoption-evidence-v1` bundles for focused
  experiments;
- implementation repositories may cite those bundles only as evidence inputs;
- `houra-server` and `houra-client` keep local TypeScript paths until a focused
  adoption issue proves that a shared artifact passes this gate;
- adapter-owned, split-by-language, and avoid-shared decisions are valid
  outcomes and should not be treated as failures.

日本語メモ: この SPEC は shared-core を採用するための証拠の形を定義するだけです。
`shared-adopted` は「採用 issue で使ってよい」状態であり、required dependency や
Matrix advertisement の拡大ではありません。rollback と local parser を残せない候補は、
production path に入れません。
