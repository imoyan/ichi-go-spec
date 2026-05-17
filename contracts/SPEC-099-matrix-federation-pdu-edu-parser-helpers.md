# Matrix v1.18 / Server-Server API / federation transaction PDU and EDU parser helpers

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Server-Server API
Primary reference: Matrix v1.18 / Server-Server API / federation transaction PDU and EDU parser helpers
Repository anchor: SPEC-099 Matrix Federation PDU / EDU Parser Helpers
Canonical: yes

## Purpose

Define bounded parser-helper contracts for the `SPEC-074`
`transaction-pdu-edu-event-validation-breadth` lane.

This contract lets implementation repositories adopt parser-only helpers for
federation transaction descriptors, PDU / EDU envelopes, canonical JSON input
shape, and per-PDU result metadata without claiming federation runtime
processing, event authorization, storage mutation, soft-fail policy, or full
Server-Server API support.

## Scope

This contract covers parser and descriptor shape for:

```text
PUT /_matrix/federation/v1/send/{txnId}
```

Only these public parser artifacts are adopted:

- federation transaction request descriptors;
- transaction body metadata with `origin`, `origin_server_ts`, `pdus`, and
  `edus`;
- PDU envelope descriptors for event ID, event type, room ID, sender, depth,
  `prev_events`, `auth_events`, content presence, hashes, and signatures;
- EDU envelope descriptors for known and unknown `edu_type` values;
- canonical JSON input descriptors that identify fields used for hash or
  signature input without calculating hashes or signatures;
- transaction response metadata with per-PDU accepted or failed result entries.

This contract does not define event authorization, state resolution, hash
calculation, signature verification, event persistence, duplicate transaction
storage, retry behavior, EDU side effects, outbound federation, or Matrix
version advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#transactions>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#put_matrixfederationv1sendtxnid>
- Source: <https://spec.matrix.org/v1.18/rooms/v12/#authorization-rules>
- Parent contract: `SPEC-056`
- Gap inventory: `SPEC-074`
- Checked at: 2026-05-16T13:45:00+09:00
- Timezone: Asia/Tokyo

## Parser Behavior

Parser helpers MUST produce normalized descriptors rather than raw JSON
passthrough.

Transaction descriptors MUST preserve:

- `txnId`, method, path, and request-auth requirement;
- `origin` as a Matrix server name;
- non-negative `origin_server_ts`;
- bounded PDU and EDU counts;
- `adopted_runtime_behavior=false`.

PDU descriptors MUST preserve only public envelope shape:

- `event_id`, `type`, `room_id`, `sender`, `origin_server_ts`, and `depth`;
- `prev_events` and `auth_events` ID lists;
- booleans for content, hashes, and signatures presence;
- signature server and key IDs when present;
- canonical JSON input field names.

EDU descriptors MUST preserve:

- `edu_type`;
- content object presence;
- a bounded normalized field list for known EDU shapes.

Transaction response descriptors MUST preserve per-PDU result status. Empty
result objects are accepted. Result objects containing `error` are failed PDU
artifacts while the transaction response itself may remain HTTP 200.

## Resource Bounds

Parser adoption is bounded:

- maximum PDU count per transaction: 50;
- maximum EDU count per transaction: 100;
- maximum canonical input field count per PDU: 32;
- maximum signature servers per PDU: 8;
- maximum signing keys per signature server: 8;
- maximum normalized PDU descriptor bytes: 16384;
- maximum normalized EDU descriptor bytes: 8192;
- hash calculation: false;
- signature verification: false;
- auth-rule execution: false;
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
- signature key IDs that are not `ed25519:*`;
- EDU entries that are not JSON objects;
- canonical JSON descriptors that include private keys or raw signing secrets.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#124` may adopt parser-only helper coverage for transaction,
  PDU, EDU, canonical JSON input, and per-PDU response descriptors.
- Server runtime work requires a separate adoption issue before event
  authorization, hash calculation, signature verification, idempotency storage,
  retry, or EDU side effects are implemented.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API until the broader `SPEC-074` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-056` remains the representative federation transaction, join, and
  invite contract.
- `SPEC-057` remains the federation backfill, event auth, and state interop
  contract.
- `SPEC-078` and `SPEC-084` own room-version-aware federation validation
  boundaries.
- `SPEC-074` remains the Server-Server full-breadth gap inventory.
- Passing this contract does not claim event auth correctness, event hash or
  signature correctness, soft-fail policy, storage behavior, outbound
  federation, Complement full-breadth, or Matrix v1.18 full compliance.
