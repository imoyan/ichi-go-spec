# Matrix v1.18 / Server-Server API / federation transaction event validation

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Server-Server API
Primary reference: Matrix v1.18 / Server-Server API / federation transaction event validation
Repository anchor: SPEC-107 Matrix Federation Transaction Event Validation Runtime
Canonical: yes

## Purpose

Define the focused server-runtime adoption boundary promoted from the
`SPEC-074` `transaction-pdu-edu-event-validation-breadth` lane after
`SPEC-099` established parser-only descriptors.

This contract lets implementation repositories adopt representative runtime
validation for inbound federation transactions without claiming full Matrix
event authorization, room-version state resolution, cryptographic event hash
verification, cryptographic event signature verification, EDU fanout, storage
mutation, or full Server-Server API support.

## Scope

This contract covers representative runtime behavior for:

```text
PUT /_matrix/federation/v1/send/{txnId}
```

Only these public behaviors are adopted:

- transaction-level bounds for `pdus` and `edus`;
- PDU envelope validation for event ID, type, room ID, sender, timestamp,
  depth, `prev_events`, `auth_events`, content, hashes, and signatures;
- signature key-ID shape validation for `ed25519:*` keys;
- accepted, rejected, and soft-failed per-PDU result descriptors;
- Matrix error envelopes for malformed transaction payloads and invalid
  signature key IDs;
- evidence that hash/signature material is required and normalized without
  exposing private keys or claiming cryptographic verification.

This contract does not define complete event authorization, state resolution,
event persistence, duplicate transaction storage, EDU side effects, outbound
federation, remote key lookup, canonical JSON signing, event hash calculation,
cryptographic signature verification, or Matrix version advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#transactions>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#put_matrixfederationv1sendtxnid>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#authorization-rules>
- Parent contract: `SPEC-056`
- Parser-helper contract: `SPEC-099`
- Gap inventory: `SPEC-074`
- Checked at: 2026-05-16T16:30:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST process a bounded transaction as a runtime
request and return per-PDU results. The transaction may remain HTTP 200 while
individual PDUs are rejected or soft-failed.

PDU validation MUST fail closed for missing public envelope fields. A PDU is
eligible for the accepted result only when:

- `event_id`, `type`, `room_id`, and `sender` parse as Matrix identifiers;
- `sender` belongs to the authenticated federation origin;
- `origin_server_ts` and `depth` are safe non-negative integers;
- `prev_events` and `auth_events` are non-empty event ID lists;
- `content`, `hashes`, and `signatures` are JSON objects;
- `hashes.sha256` is present as a public hash string;
- at least one signature exists for the authenticated origin;
- every signature key ID in the PDU uses the `ed25519:*` shape.

Representative rejected PDUs MUST return a per-event result containing an
`error` field. Representative soft-failed PDUs MUST return a per-event result
containing `error` and `soft_failed=true`. A soft-fail result indicates that
the event was not accepted into the visible timeline/state path by this
representative gate; it does not claim production room-state persistence.

## Resource Bounds

Runtime adoption is bounded:

- maximum PDU count per transaction: 50;
- maximum EDU count per transaction: 100;
- maximum signature servers per PDU: 8;
- maximum signing keys per signature server: 8;
- hash material required: true;
- signature material required: true;
- event hash calculation: false;
- cryptographic signature verification: false;
- full auth-rule execution: false;
- storage mutation: false;
- outbound federation execution: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- empty transaction IDs or transaction IDs containing `/`;
- empty origin server names;
- negative or non-integer timestamps;
- missing `pdus`;
- more than 50 PDUs;
- more than 100 EDUs;
- PDU entries that are not JSON objects;
- PDU entries missing event ID, type, room ID, sender, hashes, or signatures;
- PDU `hashes` objects missing `sha256`;
- signature key IDs that are not `ed25519:*`;
- EDU entries that are not JSON objects;
- canonical JSON descriptors that include private keys or raw signing secrets.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#231` may adopt representative transaction event-validation
  runtime behavior using this vector.
- `houra-server#160` remains the owner for typing, receipt, presence,
  device-list, and to-device EDU side effects.
- `houra-server#168` and `houra-server#169` remain the owners for full
  room-version authorization and state-resolution algorithm correctness.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API until the broader `SPEC-074` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-056` remains the representative federation transaction, join, and
  invite contract.
- `SPEC-057` remains the federation backfill, event auth, and state interop
  contract.
- `SPEC-099` remains the parser-helper boundary for transaction/PDU/EDU
  descriptors.
- `SPEC-078`, `SPEC-083`, `SPEC-084`, `SPEC-101`, `SPEC-103`, and `SPEC-104`
  own room-version-aware event decision, hash/signature helper, auth-rule
  fixture, and state-resolution evidence.
- Passing this contract does not claim full event auth correctness, full event
  hash or signature correctness, storage behavior, outbound federation,
  Complement full-breadth, or Matrix v1.18 full compliance.
