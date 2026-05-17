# SPEC-056: Matrix Federation Transaction, Join, and Invite

Status: draft
Feature profile: events
Contract type: endpoint
Matrix domain: Server-Server API
Canonical: yes

## Purpose

Define the Matrix v1.18 Server-Server transaction, make/send join, and invite
contract for Houra federation work.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds
`/_matrix/federation/**` behavior without changing existing `/_houra/client/**`
or `/_matrix/client/**` routes.

This contract builds on `SPEC-055` discovery and signing-key bootstrap. It
covers signed federation request authentication, transaction envelope shape,
PDU/EDU count limits, transaction processing results, make_join templates,
send_join acceptance response shape, and v2 invite signing. It does not define
backfill, missing-event retrieval, full event authorization, state-resolution
algorithm completeness, leave/knock flows, third-party invites, federation E2EE
EDUs, or policy-server hooks.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#transactions>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#put_matrixfederationv1sendtxnid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#joining-rooms>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1make_joinroomiduserid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#put_matrixfederationv2send_joinroomideventid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#put_matrixfederationv2inviteroomideventid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#request-authentication>
- Checked at: 2026-05-10T20:47:31+09:00
- Timezone: Asia/Tokyo

## Request authentication

Federation requests are authenticated with Matrix server signatures. The
requesting server signs a JSON object containing method, target, destination,
origin, and content when a request body exists. The resulting signature is sent
in `Authorization: X-Matrix ...` headers. Implementations use public signing
keys discovered through `SPEC-055` to verify requests.

This contract records the shape and validation gate. Private signing keys must
never appear in vectors, logs, contract text, or adoption evidence.

## Transactions

Live PDU and EDU delivery uses:

```text
PUT /_matrix/federation/v1/send/{txnId}
```

The transaction body contains:

- `origin`;
- `origin_server_ts`;
- `pdus`, required and limited to at most 50 PDUs;
- `edus`, optional and limited to at most 100 EDUs.

The receiver must return `200` with a `pdus` result map even when one or more
PDUs fail processing. A PDU result without an `error` field is considered
accepted. A PDU result with an `error` field records per-event failure while the
transaction response itself remains successful.

## Join handshake

Joining starts with:

```text
GET /_matrix/federation/v1/make_join/{roomId}/{userId}
```

The resident server returns an unsigned membership event template and a
`room_version`. Before signing the template, the joining server verifies that
the template's type, room ID, sender, state key, and membership are the expected
join values. The joining server then signs the event and submits it with:

```text
PUT /_matrix/federation/v2/send_join/{roomId}/{eventId}
```

The resident server validates the signed join event, adds its own signature
when it is the resident server for the room, persists the accepted membership
event, and returns state/auth-chain data sufficient for the joining server to
enter the room.

`M_INCOMPATIBLE_ROOM_VERSION`, `M_FORBIDDEN`, `M_UNABLE_TO_AUTHORISE_JOIN`, and
`M_UNABLE_TO_GRANT_JOIN` are representative join failures. Full auth-rule and
state-resolution completeness remain in `SPEC-057` and later contracts.

## Invites

Room invites use the v2 endpoint:

```text
PUT /_matrix/federation/v2/invite/{roomId}/{eventId}
```

The request includes the room version and an invite membership event. The
receiving server validates the invite event shape, verifies the origin server
signature, adds the target server signature when accepted, and returns the
signed event. This contract covers direct invites only; third-party invite
exchange remains out of scope.

## Compatibility boundaries

- Existing `/_houra/client/**`, `/_matrix/client/**`, `/.well-known/**`, and
  `/_matrix/key/**` behavior stays available.
- This contract introduces federation transaction, join, and invite surfaces
  only. Backfill, event auth completeness, and state resolution are later gates.
- Server signing key discovery and cache behavior come from `SPEC-055`.
- Room-version event validation uses `SPEC-040` through `SPEC-043` where already
  defined, but this contract does not claim full room-version federation auth
  completeness.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create an adoption issue for `houra-server`.
  Do not create `houra-client` work unless a later client-visible federation
  surface is intentionally added. Create an `houra-labs` issue only if
  parser-only helpers for federation request auth, transaction envelopes, or
  membership event shape are intentionally adopted.
