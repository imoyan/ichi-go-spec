# Matrix v1.18 / Identity Service API / bind and unbind lifecycle endpoints

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Identity Service API
Primary reference: Matrix v1.18 / Identity Service API / bind and unbind lifecycle endpoints
Repository anchor: SPEC-092 Matrix Identity Bind and Unbind Lifecycle Boundary
Canonical: yes

## Purpose

Define a bounded Identity Service bind, validated 3PID, and unbind lifecycle
boundary for the `bind-validated-3pid-unbind-association-lifecycle-breadth`
lane in `SPEC-076`.

This contract lets implementation repositories record representative evidence
for publishing, reading, and removing third-party identifier associations
without claiming full Identity Service API support, provider delivery, consent
UI, or Matrix version advertisement.

## Scope

This contract covers representative Matrix v1.18 Identity Service lifecycle
behavior:

- `POST /_matrix/identity/v2/3pid/bind`;
- `GET /_matrix/identity/v2/3pid/getValidated3pid`;
- `POST /_matrix/identity/v2/3pid/unbind`;
- association publication only after bind;
- homeserver-signed unbind;
- session-based unbind through `sid` and `client_secret`;
- stale-session rejection;
- already-unbound idempotent removal evidence;
- lookup removal after successful unbind;
- bounded, redacted lifecycle artifacts.

It does not define validation provider delivery, email or SMS operations,
identity-service account registration, terms UI, invitation storage, ephemeral
invitation signing, long-term identity key rotation, homeserver account-data
persistence, or full Identity Service API advertisement.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv23pidbind>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#get_matrixidentityv23pidgetvalidated3pid>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv23pidunbind>
- Parent contract: `SPEC-059`
- Gap inventory: `SPEC-076`
- Checked at: 2026-05-16T05:58:00+09:00
- Timezone: Asia/Tokyo

## Lifecycle behavior

Validation sessions prove control over a 3PID but do not publish lookup
associations. Publication happens only through:

```text
POST /_matrix/identity/v2/3pid/bind
```

`GET /_matrix/identity/v2/3pid/getValidated3pid` returns the validated 3PID
for a session. It MUST NOT publish an association by itself.

`POST /_matrix/identity/v2/3pid/unbind` removes a published association when
authenticated by either:

- homeserver-signed proof for the controlled `mxid`; or
- the validated session tuple `sid` and `client_secret`.

Successful unbind MUST remove the association from future lookup results. A
second unbind for an already-removed association MAY be treated as an idempotent
success if the artifact records that no mapping remains. Stale or mismatched
sessions MUST fail closed and MUST NOT remove an unrelated association.

Unsupported unbind behavior remains governed by `SPEC-059`; this contract adds
the lifecycle artifact shape required before `houra-server#245` can cite bind
and unbind lifecycle breadth.

## Resource and privacy bounds

Representative artifacts MUST be bounded:

- maximum canonical case bytes: 20480;
- maximum case count: 8;
- maximum association count: 4;
- maximum signature key count per association: 2;
- replay cache scope: `process`;
- replay cache max entries: 128;
- provider delivery request generation: false;
- network lookup: false;
- raw identity token evidence: false;
- raw validation token evidence: false;
- raw client secret evidence: false;
- raw lookup pepper evidence: false;
- raw 3PID evidence: false;
- raw signature evidence: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Evidence artifact

Each representative case records:

- `id`;
- `kind`: `validated_3pid`, `bind_association`,
  `homeserver_signed_unbind`, `session_based_unbind`, `stale_session`,
  `already_unbound`, or `post_unbind_lookup`;
- `request`: method and path;
- `status`;
- `errcode` when the result is a Matrix error;
- `association_state`: `not_published`, `published`, `removed`,
  `unchanged`, or `not_found`;
- `auth_proof`: `identity_token`, `homeserver_signature`,
  `validated_session`, or `none`;
- `redacted_fields`;
- `result`: `accepted`.

Artifacts MUST NOT store raw Identity Service tokens, validation tokens,
client secrets, lookup peppers, full 3PID addresses, provider payloads,
signature bytes, local paths, or database keys. Redacted fields MAY identify
which categories were removed so downstream evidence can be audited without
exposing secrets or user identifiers.

## Compatibility boundaries

- This contract does not widen `GET /_matrix/client/versions`.
- Identity Service API remains out of the current Matrix v1.18 advertisement
  until the release-evidence gate explicitly allows it.
- `SPEC-059` remains the representative Identity Service boundary. This
  contract narrows one `SPEC-076` lane for implementation adoption evidence; it
  does not complete Identity Service full breadth.
- Provider delivery, consent UI, invitation storage, ephemeral signing,
  account lifecycle, and key-rotation lanes stay separate.
