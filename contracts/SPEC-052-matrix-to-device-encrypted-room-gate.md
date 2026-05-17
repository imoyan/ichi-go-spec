# Matrix v1.18 / Client-Server API / to-device messages and encrypted room event envelopes

Status: draft
Feature profile: messaging
Contract type: gate
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / to-device messages and encrypted room event envelopes
Repository anchor: SPEC-052 Matrix To-Device and Encrypted Room Gate
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server to-device message surface and encrypted
room send/receive conformance gate for the first E2EE messaging flow.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
to-device delivery and encrypted room event behavior without changing existing
`/_houra/client/**` routes.

This endpoint family builds on `SPEC-036` event sending, `SPEC-037` sync,
`SPEC-050` crypto adapter ownership, and `SPEC-051` device/one-time/fallback
keys. It covers to-device send, to-device `/sync` delivery, `m.room.encryption`
state setup, `m.room.encrypted` send/receive for Olm and Megolm payload
envelopes, and a multi-device send/receive smoke gate. It does not define local
Olm/Megolm implementation, key backup, verification, cross-signing, secret
storage, federation to-device delivery, or complete encrypted attachment
handling.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#send-to-device-messaging>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3sendtodeviceeventtypetxnid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3sync>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroomencryption>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroomencrypted>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#molmv1curve25519-aes-sha2>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mmegolmv1aes-sha2>
- Checked at: 2026-05-10T20:12:37+09:00
- Timezone: Asia/Tokyo

## To-device messages

Clients send to-device events with:

```text
PUT /_matrix/client/v3/sendToDevice/{eventType}/{txnId}
```

The request requires authentication. `eventType` is a Matrix event type. This
contract's representative vectors use `m.room.encrypted` because encrypted
to-device payloads are the first E2EE adoption path. The request body must
contain `messages`, a map of user IDs to device IDs to event content. A single
transaction may contain at most one message for a given user/device pair.

Successful requests return `200` with `{}`. The `{txnId}` must be idempotent
for the authenticated device and event type.

Pending to-device messages for the syncing device are delivered through
`GET /_matrix/client/v3/sync` under `to_device.events`. Once a sync response is
accepted by the client and the next sync uses the returned `next_batch`, the
server should treat the delivered to-device messages as acknowledged.

## Encrypted room setup and events

Encrypted rooms are enabled with an `m.room.encryption` state event:

```text
PUT /_matrix/client/v3/rooms/{roomId}/state/m.room.encryption/{stateKey}
```

The state key for `m.room.encryption` is the empty string. This contract's
representative vector uses a trailing slash for the empty state key and the
`m.megolm.v1.aes-sha2` algorithm.

Encrypted room messages are sent through the generic event send endpoint from
`SPEC-036`:

```text
PUT /_matrix/client/v3/rooms/{roomId}/send/m.room.encrypted/{txnId}
```

The event content is an encrypted payload envelope produced by the maintained
Matrix crypto adapter from `SPEC-050`. Servers validate only Matrix envelope
shape and room authorization. Servers must not decrypt the ciphertext.

Megolm encrypted room events use `algorithm: "m.megolm.v1.aes-sha2"` and carry
`ciphertext`, `sender_key`, `session_id`, and `device_id`. Olm encrypted
to-device events use `algorithm: "m.olm.v1.curve25519-aes-sha2"` and carry a
recipient-key-indexed `ciphertext` object.

Encrypted room events are returned through `/sync` timeline sections as
`m.room.encrypted` events. Clients decrypt and verify them through the crypto
adapter; the server remains opaque to encrypted content.

## Multi-device smoke gate

A passing implementation must demonstrate:

- device keys and one-time/fallback keys from `SPEC-051` are available for the
  recipient devices;
- an outbound Megolm room session can be distributed to every recipient device
  through encrypted to-device messages;
- an `m.room.encryption` state event exists before encrypted timeline sends are
  accepted as encrypted-room sends;
- an `m.room.encrypted` room event sent by one device is visible through `/sync`
  to at least two recipient devices;
- the smoke records the spec ref, server ref, client ref, crypto stack name and
  version, device IDs, commands, and per-step pass/fail evidence.

## Authentication and errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Malformed request bodies, non-object `messages`, invalid user IDs, invalid
device IDs, invalid encrypted payload envelope shape, unsupported encryption
algorithm values, and invalid state content must return Matrix `M_*` error
envelopes appropriate to the failure (`M_BAD_JSON`, `M_NOT_JSON`,
`M_MISSING_PARAM`, or `M_INVALID_PARAM`).

Room authorization failures must return `403` with `M_FORBIDDEN`.

Rate-limited endpoints may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix to-device and encrypted-room endpoints must use Matrix `M_*` error
  envelopes, not Houra `code` envelopes.
- This contract accepts and returns encrypted payload envelopes but does not
  implement Olm/Megolm locally.
- This contract does not claim key backup, verification, cross-signing, secret
  storage, encrypted attachments, federation to-device delivery, or Matrix
  v1.18 full compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for encrypted event envelope or to-device
  payload shape validation.
