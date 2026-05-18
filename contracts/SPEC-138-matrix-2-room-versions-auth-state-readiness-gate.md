# Matrix v1.18 / Room Versions / Matrix 2.0 auth state-resolution readiness gate

Status: draft
Feature profile: rooms
Contract type: gate
Matrix domain: Room Versions
Primary reference: Matrix v1.18 / Room Versions / Matrix 2.0 auth state-resolution readiness gate
Repository anchor: SPEC-138 Matrix 2.0 Room Versions Auth State Readiness Gate
Canonical: yes

## Purpose

Define the fail-closed readiness gate for future Matrix 2.0 Room Versions,
event authorization, and state-resolution support claims.

This contract does not implement room-version algorithms, advertise additional
room versions, change `m.room_versions` capabilities, or widen Matrix 2.0,
Matrix v1.18, Product MVP, or `GET /_matrix/client/versions` advertisement.

## Scope

The gate covers:

- stable-source capture for Matrix 2.0 Room Versions requirements;
- separation between stable room-version requirements, representative fixture
  evidence, implementation notes, and out-of-scope behavior;
- default room version and available room version advertisement conditions;
- unsupported room-version, auth-rule, and state-resolution fail-closed
  behavior;
- release-bundle and `/versions` non-advertisement until same-candidate
  evidence passes.

The gate does not cover:

- full event authorization implementation;
- full state-resolution implementation;
- federation auth-chain correctness;
- room upgrade runtime breadth;
- capabilities runtime implementation beyond `SPEC-080`;
- parser or fixture helpers already covered by `SPEC-101`, `SPEC-103`, and
  `SPEC-104`.

## Matrix Reference

Current baseline:

- Matrix specification version: `v1.18`
- Room Versions source: <https://spec.matrix.org/v1.18/rooms/>
- Room version 12 source: <https://spec.matrix.org/v1.18/rooms/v12/>
- Current stable-spec entrypoint: <https://spec.matrix.org/latest/>
- Checked at: 2026-05-18T16:05:50+09:00
- Timezone: Asia/Tokyo

Matrix 2.0 source status:

- Stable Matrix 2.0 Room Versions source: pending official stable spec release
- Stable Matrix 2.0 release note: pending official stable spec release note
- Source snapshot contract: `SPEC-133`
- Advertisement gate contract: `SPEC-134`

## Classification Rules

Every Room Versions item must be classified before it can affect a support
claim:

- `stable-requirement`: stable Matrix 2.0 spec source, normative requirement
  summary, room-version registry impact, auth/state-resolution impact, required
  vectors, implementation evidence, and release evidence rule are present.
- `representative-fixture-only`: fixture or parser evidence exists but does not
  claim complete algorithm correctness.
- `capabilities-advertisement`: `m.room_versions.default` and
  `m.room_versions.available` evidence exists for a release candidate, but it
  does not imply domain-wide Room Versions support.
- `implementation-note`: useful implementation guidance that must not widen
  `/versions`, release notes, or publishable Matrix support claims.
- `out-of-scope`: explicit exclusion text is present in the release evidence.

Only stable requirements with same-candidate room-version algorithm,
capabilities, implementation, release bundle, and release notes evidence may
contribute to a future Matrix 2.0 Room Versions claim.

## Fail-Closed Rules

Until this gate passes:

- Matrix 2.0 Room Versions support is not claimed;
- default room version and available room version advertisement must remain tied
  to passing implementation evidence;
- unsupported room versions must fail closed;
- representative room version 12 auth/state fixtures must not imply complete
  per-version algorithm support;
- parser-only or helper evidence must not imply runtime auth/state support;
- `GET /_matrix/client/versions` must not include Matrix 2.0 because of this
  lane;
- release bundles and release notes must keep Room Versions excluded unless the
  same candidate passes this gate and `SPEC-134`.

## Adoption Decision Checklist

This contract closes #385 only for the current readiness gate. Future adoption
requires:

- refreshed `SPEC-133` stable-source snapshot;
- updated room-version registry, auth-rule, state-resolution, and capabilities
  vectors tied to the stable source;
- same-candidate server implementation evidence;
- release bundle and release notes matching `SPEC-134`;
- explicit exclusions for representative fixture, helper-only, or unsupported
  algorithm behavior;
- `dart tool/check_spec.dart` passing on the candidate ref.
