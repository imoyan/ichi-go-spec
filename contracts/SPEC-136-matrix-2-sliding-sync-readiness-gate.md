# Matrix v1.18 / Client-Server API / Matrix 2.0 Sliding Sync readiness gate

Status: draft
Feature profile: sync
Contract type: gate
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / Matrix 2.0 Sliding Sync readiness gate
Repository anchor: SPEC-136 Matrix 2.0 Sliding Sync Readiness Gate
Canonical: yes

## Purpose

Define the fail-closed readiness gate for future Matrix 2.0 Sliding Sync and
sync extension support claims.

This contract does not implement Sliding Sync, does not change the existing
Matrix `/sync` behavior, and does not widen Matrix 2.0, Matrix v1.18, Product
MVP, or `GET /_matrix/client/versions` advertisement.

## Scope

The gate covers:

- stable-source capture for Matrix 2.0 Sliding Sync requirements;
- separation between stable sync requirements, optional extensions, proxy
  behavior, and implementation notes;
- client and server adoption evidence required before claiming support;
- unsupported endpoint, platform, and deployment refusal behavior;
- release-bundle and `/versions` non-advertisement until same-candidate
  evidence passes.

The gate does not cover:

- runtime Sliding Sync implementation;
- long-poll timing, room-list ordering, fanout, token persistence, or restart
  persistence;
- proxy deployment behavior;
- sync performance claims;
- E2EE sync correctness;
- parser-only `/sync` extension evidence already covered by `SPEC-093`.

## Matrix Reference

Current baseline:

- Matrix specification version: `v1.18`
- `/sync` source:
  <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3sync>
- Sync extensions source:
  <https://spec.matrix.org/v1.18/client-server-api/#extensions-to-sync>
- Current stable-spec entrypoint: <https://spec.matrix.org/latest/>
- Checked at: 2026-05-18T15:51:47+09:00
- Timezone: Asia/Tokyo

Matrix 2.0 source status:

- Stable Matrix 2.0 Sliding Sync source: pending official stable spec release
- Stable Matrix 2.0 release note: pending official stable spec release note
- Source snapshot contract: `SPEC-133`
- Advertisement gate contract: `SPEC-134`
- Planning-only source candidate:
  <https://matrix.org/blog/2024/10/29/matrix-2.0-is-here/>

## Classification Rules

Every Sliding Sync or sync-extension item must be classified before it can
affect a support claim:

- `stable-requirement`: stable Matrix 2.0 spec source, normative requirement
  summary, endpoint or extension surface, request/response vector, client and
  server implementation evidence, and release evidence rule are present.
- `optional-extension`: behavior is optional in the stable spec and must be
  advertised only when the release candidate has matching support evidence.
- `proxy-behavior`: behavior belongs to a compatibility proxy or deployment and
  is not a stable protocol support claim.
- `implementation-note`: useful implementation guidance that must not widen
  `/versions`, release notes, or publishable Matrix support claims.
- `out-of-scope`: explicit exclusion text is present in the release evidence.

Only stable requirements with same-candidate client, server, release bundle,
and release notes evidence may contribute to a future Matrix 2.0 Sliding Sync
claim.

## Fail-Closed Rules

Until this gate passes:

- Matrix 2.0 Sliding Sync support is not claimed;
- unsupported Sliding Sync endpoints must fail closed instead of falling back to
  an unadvertised proxy path;
- sync performance claims are not publishable;
- client-only parser evidence must not imply server support;
- server-only endpoint evidence must not imply client adoption;
- `GET /_matrix/client/versions` must not include Matrix 2.0 because of this
  lane;
- release bundles must keep Sliding Sync Matrix 2.0 evidence blocked;
- release notes must call Sliding Sync Matrix 2.0 support unadvertised.

## Adoption Decision Checklist

This contract closes #383 only for the current readiness gate. Future adoption
requires:

- refreshed `SPEC-133` stable-source snapshot;
- request and response vectors tied to the stable source;
- client and server implementation evidence for the same candidate;
- release bundle and release notes matching `SPEC-134`;
- explicit exclusions for proxy, unsupported endpoint, unsupported platform, or
  optional extension behavior;
- `dart tool/check_spec.dart` passing on the candidate ref.
