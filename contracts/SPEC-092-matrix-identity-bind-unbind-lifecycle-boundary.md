# SPEC-092: Matrix Identity Bind and Unbind Lifecycle Boundary

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define a bounded Identity Service bind, validated 3PID, unbind, and association
lifecycle boundary for the `bind-validated-3pid-unbind-association-lifecycle-
breadth` lane in `SPEC-076`.

This contract lets implementation repositories record representative evidence
for publishing and removing validated 3PID associations without claiming full
Identity Service API support, external provider delivery, invitation storage,
or consent UI behavior.

## Scope

This contract covers representative Matrix v1.18 Identity Service lifecycle
behavior:

- validated 3PID query for an unbound validation session;
- bind publication after validated session proof;
- lookup visibility only after bind publication;
- session-based unbind proof using `sid` and `client_secret`;
- homeserver-signed unbind proof for the controlled `mxid`;
- stale-session and already-unbound failures;
- lookup removal after successful unbind;
- privacy and authentication failures as Matrix errors.

It does not define email or SMS provider delivery, invite storage, ephemeral
invitation signing, identity-server selection UI, consent UI, provider retry
policy, association signature cryptographic verification beyond representative
redacted evidence, or full Identity Service API advertisement.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv23pidbind>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#get_matrixidentityv23pidgetvalidated3pid>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv23pidunbind>
- Parent contract: `SPEC-059`
- Gap inventory: `SPEC-076`
- Checked at: 2026-05-16T05:45:00+09:00
- Timezone: Asia/Tokyo

## Lifecycle behavior

`GET /_matrix/identity/v2/3pid/getValidated3pid` returns a validated 3PID for
a live validation session without publishing that association to lookup.

`POST /_matrix/identity/v2/3pid/bind` publishes a lookup association only when
the caller proves a validated session for the submitted `sid`, `client_secret`,
and `mxid`. The bind response is a signed association object. Evidence may
record that a signed association was returned, but it must not store raw
signatures or private key material.

`POST /_matrix/identity/v2/3pid/unbind` accepts either:

- a live validated session proof for the submitted 3PID and `mxid`; or
- a homeserver-signed proof for the submitted `mxid` and 3PID.

A successful unbind removes future lookup visibility for that 3PID. Repeating
unbind after the association is already absent is a failure case for this
representative boundary and must not recreate or leak an association.

Stale, missing, or mismatched validation sessions fail closed. Missing identity
service authentication, unsigned terms, invalid homeserver signatures, and
rotated lookup pepper failures remain Matrix errors.

## Resource and privacy bounds

Representative artifacts MUST be bounded:

- maximum canonical case bytes: 24576;
- maximum case count: 10;
- maximum lifecycle step count: 12;
- maximum failure count: 6;
- validated session storage: `process`;
- association storage: `process`;
- provider delivery: false;
- raw 3PID evidence: false;
- raw token evidence: false;
- raw signature evidence: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are not present or are
weakened.

## Evidence artifact

Each representative case records:

- `id`;
- `kind`: `validated_3pid_query`, `bind_publication`,
  `session_unbind`, `homeserver_signed_unbind`, `post_unbind_lookup`,
  `stale_session_failure`, `already_unbound_failure`, or `auth_privacy_failure`;
- `request`: method and path;
- `status`;
- `errcode` when the result is a Matrix error;
- `association_visible`;
- `lookup_removed`;
- `result`: `accepted` or `rejected`.

Artifacts MUST NOT store raw 3PIDs, tokens, client secrets, lookup peppers,
homeserver signatures, identity-service signatures, provider payloads, or
local paths.

## Compatibility boundaries

- This contract does not widen `GET /_matrix/client/versions`.
- Identity Service API remains out of the current Matrix v1.18 advertisement
  until the release-evidence gate explicitly allows it.
- `SPEC-059` remains the representative Identity Service boundary. This
  contract records lifecycle breadth for bind/unbind behavior and does not
  weaken `SPEC-059` privacy and authentication failures.
- Validation provider delivery, lookup privacy breadth, public-key lifecycle,
  invitation storage, ephemeral invitation signing, and consent UI stay in
  their own lanes.
