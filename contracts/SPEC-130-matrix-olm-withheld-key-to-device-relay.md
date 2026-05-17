# Matrix v1.18 / Olm & Megolm / Olm and Megolm to-device key event relay

Status: draft
Feature profile: messaging
Contract type: boundary
Matrix domain: Olm & Megolm
Primary reference: Matrix v1.18 / Olm & Megolm / Olm and Megolm to-device key event relay
Repository anchor: SPEC-130 Matrix Olm Withheld-Key To-Device Relay Boundary
Canonical: yes

## Purpose

Define the representative server-owned boundary for Matrix v1.18 Olm
to-device relay messages that are not decrypted by the homeserver, including
withheld-key, room-key request, forwarded-room-key, and cancellation payloads.

This contract is a child gate of `SPEC-079`
`olm-session-to-device-withheld-key-breadth`. It narrows `SPEC-052` to the
message families that complete the server relay evidence for `houra-server#252`
without changing the crypto ownership boundary from `SPEC-050`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#send-to-device-messaging>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroomkeywithheld>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroom_key_request>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mforwarded_room_key>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroomkeyrequest-cancellation>
- Checked at: 2026-05-17T19:25:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers accept and relay these representative to-device event types through:

```text
PUT /_matrix/client/v3/sendToDevice/{eventType}/{txnId}
GET /_matrix/client/v3/sync
```

The representative event types are:

- `m.room_key.withheld`;
- `m.room_key_request`;
- `m.forwarded_room_key`;
- `m.room_key_request` with `action: "request_cancellation"`.

The server validates the public envelope shape, target user/device map, event
type, transaction idempotency, and device-scoped queue delivery. The server
must not decrypt, derive, transform, trust, compare, or log session key
material.

## Payload Shape

`m.room_key.withheld` content must include `algorithm`, `room_id`,
`sender_key`, `session_id`, `code`, and `reason`.

`m.room_key_request` content must include `action`, `requesting_device_id`,
and `request_id`. For `action: "request"`, the content must include a
`body` object with `algorithm`, `room_id`, `sender_key`, and `session_id`.
For `action: "request_cancellation"`, the content must not require `body`.

`m.forwarded_room_key` content must include `algorithm`, `room_id`,
`sender_key`, `session_id`, `session_key`, `sender_claimed_ed25519_key`, and
`forwarding_curve25519_key_chain`.

The representative vectors use Matrix identifiers and opaque placeholder key
strings. Those strings are not normative cryptographic material.

## Delivery and Idempotency

Successful sends return `200` with `{}`. A repeated `{txnId}` for the same
sender device and event type is idempotent when the message body is identical.
A repeated transaction id with different payload content must fail rather than
silently replacing queued messages.

Pending messages are delivered to the target device under `/sync`
`to_device.events` with `sender`, `type`, and opaque `content`. Once a client
syncs with the returned `next_batch`, previously delivered to-device messages
may be acknowledged and omitted from later sync responses.

## Fail-Closed Behavior

Implementations must reject:

- unknown or malformed target user IDs and device IDs;
- unsupported representative event types for this contract;
- non-object message content;
- malformed withheld-key, room-key-request, forwarded-room-key, or cancellation
  payload shapes;
- duplicate transaction IDs with different message bodies;
- attempts to expose or record decrypted plaintext or interpreted session
  trust decisions as server-owned behavior.

## Claim Boundary

Passing this contract does not claim:

- local Olm or Megolm cryptography;
- device trust, key verification, or trust-on-first-use decisions;
- session-key validity;
- decryption of to-device payloads;
- encrypted-room timeline correctness beyond `SPEC-052`;
- server-side key backup beyond `SPEC-053`;
- Matrix v1.18 full E2EE support or `/versions` advertisement widening.

## Japanese Guidance

この contract は `houra-server#252` のための server relay 境界であり、
withheld-key / key-request / forwarded-room-key / cancellation を
server が復号せずに保存・配送することだけを固定する。session key の意味付け、
trust decision、local Olm/Megolm crypto、Matrix `/versions` の E2EE claim は
この contract では広げない。

## Adoption Decision Checklist

After this contract merges:

- `houra-server#252` may adopt the representative relay behavior against the
  pinned `houra-spec` ref;
- server adoption must include successful delivery for the four representative
  event families, duplicate transaction-id drift rejection, malformed payload
  rejection, and sync acknowledgement behavior;
- README adoption evidence in `houra-server` must cite this contract, vector,
  implementation ref, verification commands, and a clean-room note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until all child
  lanes provide runtime and release evidence.
