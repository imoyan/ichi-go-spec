# SPEC-059: Matrix Identity Service Boundary

Status: draft
Feature profile: core
Contract type: endpoint
Matrix domain: Identity Service API
Canonical: yes

## Purpose

Define the Matrix v1.18 Identity Service lookup, validation, bind, unbind,
privacy, and service boundary contract for Houra ecosystem API work.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds the independent
identity service boundary used by clients and homeservers when resolving
third-party identifiers to Matrix user IDs. It does not change existing
`/_houra/client/**`, `/_matrix/client/**`, `/_matrix/app/**`,
`/_matrix/federation/**`, or push gateway behavior.

This contract covers Identity Service version/status checks, identity-service
tokens, terms gate behavior, public key lookup shape, hash details, association
lookup, email and MSISDN validation session shape, 3PID bind, validated 3PID
query, unbind, privacy failures, and adoption boundaries. It does not define
invitation storage, ephemeral invitation signing, email/SMS provider delivery
infrastructure, user-facing consent UI, homeserver account-data persistence, or
Push Gateway behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#identity-service-api>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#authentication>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#get_matrixidentityversions>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#get_matrixidentityv2hash_details>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv2lookup>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv2validateemailrequesttoken>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv2validateemailsubmittoken>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv23pidbind>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#post_matrixidentityv23pidunbind>
- Checked at: 2026-05-10T21:34:00+09:00
- Timezone: Asia/Tokyo

## Service boundary

Identity Service support is a separate deployable component. Houra homeserver
and client implementations may call the identity service, but passing this
contract does not make identity storage a hidden homeserver module.

Identity Service access tokens are scoped to Identity Service API calls only.
They must not be accepted as Client-Server API access tokens, and Client-Server
API access tokens must not be accepted as Identity Service tokens. Clients must
prefer `Authorization: Bearer <token>` over query-string access tokens. Query
string access tokens remain a Matrix compatibility requirement for servers but
are deprecated and must not be emitted by Houra clients or stored in evidence.

Terms of service are part of the boundary. Authenticated endpoints may return
`M_TERMS_NOT_SIGNED`; callers must treat that as a recoverable policy gate and
must not retry privacy-sensitive lookup or bind operations in a loop without a
new user decision.

## Lookup

Association lookup uses:

```text
GET /_matrix/identity/v2/hash_details
POST /_matrix/identity/v2/lookup
```

`hash_details` must include `sha256` and a `lookup_pepper`. Lookup requests
must include `addresses`, `algorithm`, and `pepper`. Lookup responses return
only address-to-MXID mappings for matched addresses. They must not expose all
3PIDs for a Matrix user ID or all related identifiers for a 3PID.

Invalid or rotated peppers return `M_INVALID_PEPPER`. Unsupported algorithms
return `M_INVALID_PARAM`.

## Validation and binding

Validation sessions are created through email or MSISDN `requestToken` routes.
`send_attempt` is used for retry idempotency and must be scoped to the address
and `client_secret`.

Submitting a validation token proves control over the 3PID for that session but
does not publish a lookup association. Publication happens only after:

```text
POST /_matrix/identity/v2/3pid/bind
```

The bind response is an association object containing the 3PID, Matrix user ID,
validity timestamps, verification timestamp, and identity-service signatures.
The identity service signs associations with its own long-term identity-service
key. Clients decide whether to trust that identity service.

`GET /_matrix/identity/v2/3pid/getValidated3pid` returns the validated 3PID for
a session without publishing a lookup association.

## Unbind

Unbind uses:

```text
POST /_matrix/identity/v2/3pid/unbind
```

The identity service authenticates unbind either through the homeserver
signature for the controlled `mxid` or through the validated session
(`sid` + `client_secret`) proving control of the 3PID. Future lookup calls must
not return the removed association after a successful unbind.

If unbind is unsupported and the identity service returns a non-Matrix error
body with `400`, `404`, or `501`, the homeserver must treat that as unsupported
unbind behavior. If a Matrix error body is returned, the homeserver should pass
that Matrix error through to the requesting client.

## Compatibility boundaries

- Existing Houra and Matrix client, federation, application service, and push
  behavior stays available.
- Identity Service tokens, validation tokens, `client_secret`, and lookup
  peppers are secrets and must never be logged in full or stored in public
  evidence.
- This contract introduces the Identity Service boundary and representative
  conformance vectors only. It does not claim invitation storage, ephemeral
  invitation signing, email/SMS provider delivery, consent UI, Push Gateway, or
  Matrix v1.18 full ecosystem compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only helpers for
  3PID, token redaction, or signed association validation are intentionally
  adopted.
