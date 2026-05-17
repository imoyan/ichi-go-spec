# SPEC-084: Matrix Room Version Federation Cross-Domain Validation

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Room Versions
Canonical: yes

## Purpose

Define a bounded federation cross-domain validation boundary for the
`federation-cross-domain-room-version-breadth` lane in `SPEC-078`.

This contract keeps the Room Versions and Server-Server API interaction small
enough for implementation repositories to adopt without turning representative
federation evidence into full Matrix room-version or federation support.

## Scope

This contract covers representative validation artifacts for room version `12`
across these Server-Server surfaces:

- federation transaction PDU receipt;
- make/send join room-version agreement;
- invite room-version agreement;
- backfill, event_auth, and state/state_ids room consistency.

The validation boundary checks local metadata consistency only:

- request `origin`, `destination`, `room_id`, and `room_version`;
- event `room_id`, `type`, `sender`, `prev_events`, and `auth_events` shape;
- expected room version for the room;
- whether the validation result is accepted or rejected.

It does not define complete Matrix federation behavior, event hash validation,
signature validation, remote key fetch, auth-chain verification, state
resolution, get_missing_events behavior, or all join/knock/leave/invite
variants.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/>
- Checked at: 2026-05-16T00:05:00+09:00
- Timezone: Asia/Tokyo

## Validation rule

An implementation may emit a representative federation room-version validation
artifact with this minimal shape:

```json
{
  "room_version": "12",
  "validations": [
    {
      "id": "send-transaction-pdu-room-version",
      "surface": "send_transaction",
      "result": "accepted",
      "reason": "room_version_matches_expected",
      "origin": "hs-b.example.test",
      "destination": "hs-a.example.test",
      "room_id": "!room:hs-a.example.test"
    }
  ]
}
```

Allowed `surface` values are:

- `send_transaction`
- `make_join`
- `send_join`
- `invite`
- `backfill`
- `event_auth`
- `state_ids`

Allowed `result` values are `accepted` and `rejected`.

Implementations must reject representative validation when:

- the request or event room version conflicts with the locally expected room
  version;
- event `room_id` differs from the request room;
- `origin` and `destination` are missing or equal;
- a Server-Server surface attempts to claim unsupported room versions;
- required bounded shape checks fail before deeper room-version or federation
  processing.

## Resource bounds

Implementations must reject work before expensive processing when these bounds
are exceeded:

- maximum canonicalized event payload inspected by this gate: 65536 bytes;
- maximum PDUs in one representative transaction batch: 8;
- maximum `auth_events` count per event: 10;
- maximum `prev_events` count per event: 20;
- maximum state IDs returned by a representative `state_ids` validation: 64;
- maximum auth-chain IDs returned by representative `event_auth` validation:
  64;
- maximum validations emitted for one representative batch: 16;
- no remote key fetch, network lookup, recursive graph expansion, or unbounded
  database scan while generating the artifact.

These bounds are part of the contract. Wider federation or room-version
behavior requires a separate contract with performance and storage evidence.

## Fail-closed behavior

Implementations must fail closed:

- do not advertise full Room Versions support from this artifact;
- do not advertise full Server-Server API support from this artifact;
- do not widen `GET /_matrix/client/versions` or
  `GET /_matrix/client/v3/capabilities`;
- do not infer federation transaction hash/signature support from local
  metadata validation;
- if validation cannot be completed within bounded local inputs, classify it as
  rejected or omit it from release evidence.

## Adoption decision checklist

After this contract merges:

- `houra-server#251` should adopt the artifact and resource-bound rules for a
  representative room version `12` federation validation batch.
- Server implementation evidence must keep Room Versions and Server-Server API
  breadth decisions separate in release evidence.
- `houra-labs` work is needed only if a shared bounded federation validator is
  extracted.
- `houra-client` work is not required.

## Compatibility boundaries

- `SPEC-056` remains the representative federation transaction, join, and
  invite contract.
- `SPEC-057` remains the federation backfill, event_auth, and state_ids
  interop contract.
- `SPEC-074` remains the Server-Server API full-breadth gap inventory.
- `SPEC-078` remains the full Room Versions algorithm gap inventory.
- Passing this contract does not claim complete federation validation,
  complete room-version algorithms, remote signature verification, or Matrix
  v1.18 full compliance.
