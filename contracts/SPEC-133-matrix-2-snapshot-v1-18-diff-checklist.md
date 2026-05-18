# Matrix v1.18 / Appendices/common rules / Matrix 2.0 snapshot / v1.18 diff checklist

Status: draft
Feature profile: core
Contract type: gap-inventory
Matrix domain: Appendices/common rules
Primary reference: Matrix v1.18 / Appendices/common rules / Matrix 2.0 snapshot / v1.18 diff checklist
Repository anchor: SPEC-133 Matrix 2.0 Snapshot and v1.18 Diff Checklist
Canonical: yes

## Purpose

Define the fail-closed checklist Houra must use before treating a future Matrix
2.0 stable specification release as a support target.

This contract is preparation only. It records the snapshot and classification
shape for comparing a future Matrix 2.0 stable release with the current Matrix
v1.18 baseline. It does not claim Matrix 2.0 support and does not widen
`GET /_matrix/client/versions`, release notes, Product MVP readiness, or any
implementation support surface.

## Scope

The checklist covers:

- dated official-source capture for a Matrix 2.0 stable specification release;
- domain-by-domain diff classification against the Matrix v1.18 baseline;
- separation between stable Matrix requirements and not-yet-stable MSCs;
- issue-sized follow-up lanes for `/versions` advertisement, OAuth/OIDC,
  Sliding Sync, E2EE, Room Versions, and Extensible Profiles / Events;
- explicit non-advertisement while stable sources, contracts, vectors,
  implementation evidence, and release evidence are incomplete.

The checklist does not cover:

- implementation behavior for any Matrix 2.0 feature;
- `/versions` advertisement for Matrix 2.0;
- Matrix v1.18 full-compliance closure;
- Element, Synapse, MAS, SDK, or deployment-specific product behavior;
- MSC adoption before the requirement appears in a stable Matrix specification
  release.

## Matrix Reference

Current baseline:

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/>
- Release note: <https://matrix.org/blog/2026/03/26/matrix-v1.18-release/>

Matrix 2.0 source status:

- Stable Matrix 2.0 specification source: pending official stable spec release
- Stable Matrix 2.0 release note: pending official stable spec release note
- Source candidate: <https://matrix.org/blog/2024/10/29/matrix-2.0-is-here/>
- Source candidate: <https://matrix.org/blog/2023/12/25/the-matrix-holiday-update-2023/>
- Current stable-spec entrypoint: <https://spec.matrix.org/latest/>
- Checked at: 2026-05-18T15:27:07+09:00
- Timezone: Asia/Tokyo

The source-candidate links above are useful planning inputs, but they are not
enough to claim a stable Matrix 2.0 specification target. A future refresh must
replace the pending fields with the stable specification URL, stable release
note URL, checked timestamp, timezone, and the exact source status used by the
release-candidate evidence bundle.

## Diff Classification

Every future Matrix 2.0 diff item must be classified before implementation or
advertisement work starts:

| Lane | Follow-up issue | Required classification |
|---|---|---|
| `/versions` advertisement and release evidence | imoyan/houra-spec#381 | stable support claim gate, same-candidate evidence required |
| OAuth/OIDC and account management | imoyan/houra-spec#382 | stable Client-Server requirement vs MSC/provider-specific behavior |
| Sliding Sync and sync extensions | imoyan/houra-spec#383 | stable sync requirement vs experimental extension or proxy behavior |
| E2EE, key backup, and verification | imoyan/houra-spec#384 | stable crypto/client-server requirement vs SDK-owned implementation detail |
| Room Versions, auth, and state resolution | imoyan/houra-spec#385 | stable room-version algorithm requirement vs representative fixture coverage |
| Extensible Profiles and Events | imoyan/houra-spec#386 | stable event/profile requirement vs client-rendering or UI-specific behavior |

For each lane, record:

- the Matrix 2.0 stable spec section URL or `pending-stable-source`;
- the v1.18 baseline section or `new-in-matrix-2`;
- whether the item is `stable-requirement`, `msc-only`, `implementation-note`,
  or `out-of-scope`;
- owning Houra contracts and missing contracts;
- required vectors and implementation repositories;
- release-bundle evidence needed before advertisement;
- explicit exclusion text if the current release candidate remains fail-closed.

## Stable Requirement vs MSC Separation

Stable requirement entries must include:

- a stable Matrix specification URL;
- a stable release note or changelog source;
- a normative requirement summary;
- affected Matrix domain and Houra contract boundary;
- required vector and implementation evidence;
- a release-evidence rule stating whether advertisement may change.

MSC-only entries must include:

- the MSC identifier and status;
- the Matrix domain it is expected to affect;
- why it is not a stable Houra support claim yet;
- the issue that will revisit the item after stable adoption;
- `advertisement_allowed=false`.

MSC-only or implementation-note entries must not be used to widen Matrix 2.0,
Matrix v1.18, Product MVP, or `/versions` claims.

## Fail-Closed Advertisement Rules

Until the Matrix 2.0 stable-source snapshot is refreshed and every claimed lane
has same-candidate evidence:

- `GET /_matrix/client/versions` must not advertise Matrix 2.0 support;
- release notes must state Matrix 2.0 is unadvertised;
- release bundles must keep `matrix_2_support_claimed=false`;
- `publishable_matrix_support_claim` must not include Matrix 2.0 language;
- Matrix v1.18 and Matrix 2.0 evidence must remain separate;
- implementation evidence from one lane must not imply another lane.

## Adoption Decision Checklist

After this contract merges:

- #377 remains the parent readiness gate.
- #380 may close when this contract, vector, docs, and `tool/check_spec.dart`
  validation land.
- #381 through #386 remain open until each lane has a stable-source diff,
  vectors, implementation evidence, and release-bundle decision.
- No implementation repository should advertise Matrix 2.0 until #381 records a
  pass decision tied to the same candidate refs as release notes and bundle
  evidence.
