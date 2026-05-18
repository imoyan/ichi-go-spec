# Matrix v1.18 / Client-Server API / Matrix 2.0 versions advertisement evidence gate

Status: draft
Feature profile: core
Contract type: gate
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / Matrix 2.0 versions advertisement evidence gate
Repository anchor: SPEC-134 Matrix 2.0 Versions Advertisement Evidence Gate
Canonical: yes

## Purpose

Define the fail-closed gate that prevents `GET /_matrix/client/versions`,
release notes, release bundles, and publishable support claims from advertising
Matrix 2.0 until stable-source and same-candidate evidence are complete.

This contract is preparation only. It does not claim Matrix 2.0 support, does
not widen Matrix v1.18 support, and does not change the current
`/_matrix/client/versions` response.

## Scope

The gate covers:

- the Matrix 2.0 stable-source snapshot required by `SPEC-133`;
- the candidate refs that must match across spec, implementation, release
  bundle, release notes, and public support claim evidence;
- domain-lane evidence from #382 through #386;
- refusal behavior for pending, missing, stale, failed, secret-leaking, or
  MSC-only evidence;
- separation between unstable feature flags and stable Matrix version
  advertisement.

The gate does not cover:

- implementation behavior for OAuth/OIDC, Sliding Sync, E2EE, Room Versions, or
  Extensible Profiles / Events;
- Matrix v1.18 release advertisement decisions already covered by `SPEC-064`;
- Product MVP readiness;
- Element, Synapse, MAS, SDK, or deployment-specific product behavior.

## Matrix Reference

Current baseline:

- Matrix specification version: `v1.18`
- Versions endpoint source:
  <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientversions>
- Specification versioning source:
  <https://spec.matrix.org/v1.18/#specification-versions>
- Current stable-spec entrypoint: <https://spec.matrix.org/latest/>
- Checked at: 2026-05-18T15:36:24+09:00
- Timezone: Asia/Tokyo

Matrix 2.0 source status:

- Stable Matrix 2.0 specification source: pending official stable spec release
- Stable Matrix 2.0 release note: pending official stable spec release note
- Source snapshot contract: `SPEC-133`

## Evidence Inputs

Matrix 2.0 version advertisement may be considered only when all inputs below
refer to the same candidate:

- stable Matrix 2.0 specification source and release note from `SPEC-133`;
- candidate `houra-spec`, `houra-server`, and `houra-client` refs;
- release bundle ref;
- release notes ref;
- publishable Matrix support claim ref;
- `SPEC-064` style version advertisement decision;
- release readiness and rollback decision;
- domain-lane decisions for #382 through #386.

The domain-lane decisions must identify whether each item is a stable Matrix
2.0 requirement, MSC-only input, implementation note, or out-of-scope item.
Only stable Matrix requirements with passing same-candidate evidence may
contribute to stable `v2.0` advertisement.

## Blocking Rules

Matrix 2.0 advertisement is blocked when any of the following is true:

- the Matrix 2.0 stable specification source or release note is pending;
- the checked source snapshot is stale relative to the release candidate;
- any claimed domain lane lacks a pass decision;
- implementation refs, release bundle, release notes, and support claim refs do
  not describe the same candidate;
- release notes or bundle evidence claim a domain that `/versions` does not
  advertise, or advertise a version that release notes do not claim;
- unsupported domain lanes lack explicit exclusion text;
- evidence includes secrets, bearer credentials, authorization grant material,
  callback query parameters, identity-provider session identifiers, recovery
  material, raw encrypted media, or private keys;
- the claim depends only on an MSC, source-candidate blog post, experimental
  feature flag, proxy behavior, or implementation-specific behavior.

## Required Outcome

Until this gate passes:

- `GET /_matrix/client/versions` must not include Matrix 2.0;
- release notes must state Matrix 2.0 is unadvertised;
- release bundles must keep `matrix_2_support_claimed=false`;
- `publishable_matrix_support_claim` must not include Matrix 2.0 language;
- unstable feature flags, if any are present in future evidence, must remain
  separate from stable Matrix version advertisement;
- #381 remains blocked or open unless the current evidence explicitly records a
  fail-closed decision and the remaining work is tracked by #377 and #382
  through #386.

## Adoption Decision Checklist

This contract closes #381 only for the current fail-closed readiness gate. It
does not authorize future Matrix 2.0 advertisement by itself.

Future advertisement requires:

- refreshed `SPEC-133` stable-source snapshot;
- pass decisions for every advertised domain lane;
- same-candidate implementation and release evidence;
- release notes and bundle evidence matching the `/versions` response;
- `dart tool/check_spec.dart` passing on the candidate ref;
- no secret-bearing evidence.
