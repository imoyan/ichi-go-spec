# Matrix v1.18 / Client-Server API / Matrix 2.0 extensible profiles events readiness gate

Status: draft
Feature profile: sync
Contract type: gate
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / Matrix 2.0 extensible profiles events readiness gate
Repository anchor: SPEC-139 Matrix 2.0 Extensible Profiles Events Readiness Gate
Canonical: yes

## Purpose

Define the fail-closed readiness gate for future Matrix 2.0 Extensible
Profiles and Events support claims.

This contract does not implement profile endpoints, account-data endpoints,
event send/runtime behavior, custom event rendering, `m.profile_fields`
capability advertisement, or Matrix 2.0, Matrix v1.18, Product MVP, or
`GET /_matrix/client/versions` advertisement.

## Scope

The gate covers:

- stable-source capture for Matrix 2.0 Extensible Profiles and Events
  requirements;
- separation between stable requirements, experimental MSC input,
  parser-validation evidence, implementation notes, and out-of-scope behavior;
- profile field, account-data event type, and event content validation
  boundaries tied to the existing v1.18 contracts;
- redacted evidence rules for profile, account-data, and event-content shapes;
- release-bundle and `/versions` non-advertisement until same-candidate
  evidence passes.

The gate does not cover:

- profile storage, sync fanout, or profile cache runtime behavior;
- generic custom-event runtime support beyond the parser boundaries in existing
  contracts;
- message rendering, rich text, media preview, or client UI presentation;
- room-version event authorization, event hashes, or state resolution;
- federation event interchange;
- unstable MSC behavior or Matrix 2.0 advertisement.

## Matrix Reference

Current baseline:

- Matrix specification version: `v1.18`
- Profile source:
  <https://spec.matrix.org/v1.18/client-server-api/#profiles>
- Client config source:
  <https://spec.matrix.org/v1.18/client-server-api/#client-config>
- Sending events source:
  <https://spec.matrix.org/v1.18/client-server-api/#sending-events-to-a-room>
- Current stable-spec entrypoint: <https://spec.matrix.org/latest/>
- Checked at: 2026-05-18T16:15:29+09:00
- Timezone: Asia/Tokyo

Matrix 2.0 source status:

- Stable Matrix 2.0 Extensible Profiles and Events source: pending official
  stable spec release
- Stable Matrix 2.0 release note: pending official stable spec release note
- Source snapshot contract: `SPEC-133`
- Advertisement gate contract: `SPEC-134`

## Classification Rules

Every Extensible Profiles and Events item must be classified before it can
affect a support claim:

- `stable-requirement`: stable Matrix 2.0 spec source, normative requirement
  summary, profile-or-event surface, content validation boundary, required
  vectors, implementation evidence, and release evidence rule are present.
- `extensible-profile-field`: a profile field or profile capability shape is
  described, but it does not imply runtime storage, sync visibility, or
  capability advertisement without same-candidate evidence.
- `extensible-event-content`: an event type or event-content shape is
  described, but it does not imply send, sync, relation, rendering, or
  room-version support without same-candidate evidence.
- `parser-validation-only`: parser evidence exists and preserves typed or
  unknown JSON shape, but it does not claim runtime support.
- `implementation-note`: useful implementation guidance that must not widen
  `/versions`, release notes, or publishable Matrix support claims.
- `out-of-scope`: explicit exclusion text is present in the release evidence.

Only stable requirements with same-candidate profile/event parser, runtime,
redaction, implementation, release bundle, and release notes evidence may
contribute to a future Matrix 2.0 Extensible Profiles and Events claim.

## Redaction Rules

Evidence for this gate may retain public JSON shape, namespaced identifier
shape, and classification decisions. It must not retain raw user profile
values, raw account-data content, raw event content, message body values,
formatted body values, avatar URL values, or external URL values.

When an implementation records evidence, it must show that content was accepted,
rejected, or excluded through a typed boundary without embedding the raw payload
that caused the decision.

## Fail-Closed Rules

Until this gate passes:

- Matrix 2.0 Extensible Profiles and Events support is not claimed;
- profile extension claims and event extension claims remain blocked;
- `m.profile_fields` or equivalent profile capability advertisement requires
  same-candidate evidence and `SPEC-134`;
- unsupported profile fields or event-content behavior must fail closed for
  support and advertisement decisions;
- unstable MSC input must be recorded as experimental and excluded from stable
  support claims;
- parser-only evidence must carry an explicit no-runtime-support decision;
- client rendering or UI presentation notes must not imply protocol support;
- `GET /_matrix/client/versions` must not include Matrix 2.0 because of this
  lane;
- release bundles and release notes must keep Extensible Profiles and Events
  excluded unless the same candidate passes this gate and `SPEC-134`.

## Adoption Decision Checklist

This contract closes #386 only for the current readiness gate. Future adoption
requires:

- refreshed `SPEC-133` stable-source snapshot;
- updated profile field, account-data event type, event content, and capability
  vectors tied to the stable source;
- same-candidate server and client implementation evidence;
- secret-free and PII-redacted evidence for accepted, rejected, and unsupported
  content shapes;
- release bundle and release notes matching `SPEC-134`;
- explicit exclusions for experimental MSC, parser-only, client-rendering, or
  unsupported runtime behavior;
- `dart tool/check_spec.dart` passing on the candidate ref.
