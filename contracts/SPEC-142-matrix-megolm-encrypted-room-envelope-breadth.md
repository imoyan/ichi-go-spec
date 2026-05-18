# Matrix v1.18 / Olm & Megolm / Megolm encrypted-room state event and timeline envelope parser boundary

Status: draft
Feature profile: messaging
Contract type: boundary
Matrix domain: Olm & Megolm
Primary reference: Matrix v1.18 / Olm & Megolm / Megolm encrypted-room state event and timeline envelope parser boundary
Repository anchor: SPEC-142 Matrix Megolm Encrypted-Room Envelope Parser Boundary
Canonical: yes

## Purpose

Define the representative server-owned parser boundary for Matrix v1.18
`m.room.encryption` state events and `m.room.encrypted` Megolm timeline event
envelopes, including required and optional content fields, the empty state-key
rule, and the rejection of Olm-shaped ciphertext on the room timeline.

This contract is a child gate of `SPEC-079`
`megolm-room-session-encrypted-room-event-breadth`. It narrows `SPEC-052`
without re-defining the basic encrypted-room smoke gate, and it does not
implement local Olm/Megolm cryptography, derive group sessions, validate
ciphertext content, or widen `GET /_matrix/client/versions`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroomencryption>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroomencrypted>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mmegolmv1aes-sha2>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#molmv1curve25519-aes-sha2>
- Checked at: 2026-05-18T17:30:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers accept and validate encrypted-room setup and timeline send through:

```text
PUT /_matrix/client/v3/rooms/{roomId}/state/m.room.encryption/{stateKey}
PUT /_matrix/client/v3/rooms/{roomId}/send/m.room.encrypted/{txnId}
```

The representative algorithm for the room timeline is
`m.megolm.v1.aes-sha2`. The representative state-key for `m.room.encryption`
is the empty string.

The server validates the public envelope shape and the required content
fields. The server must not decrypt the `ciphertext`, must not derive Megolm
session state, must not compare ciphertext across senders, and must not log
plaintext, session keys, or device trust decisions.

## `m.room.encryption` State Event

The state event must use the empty state key and a content object with:

- `algorithm`: a non-empty string identifying the encryption algorithm. The
  representative value is `m.megolm.v1.aes-sha2`.

The content object may include:

- `rotation_period_ms`: an integer hint for outbound group session rotation.
- `rotation_period_msgs`: an integer hint for outbound group session
  rotation.

The server treats `rotation_period_ms` and `rotation_period_msgs` as opaque
informational hints. The server must not enforce session rotation logic.

A state event whose state key is non-empty must be rejected. A state event
whose content omits `algorithm` must be rejected. A state event whose
content sets `algorithm` to a non-string value or an empty string must be
rejected.

A repeated state event whose state key, content algorithm, and rotation
fields match the previously accepted state event is idempotent. A repeated
state event that changes `algorithm` to a different non-empty string must
not be silently accepted as a re-encryption of the room; it is still stored
as a new state event but the server must not interpret it as turning
encryption off.

## `m.room.encrypted` Megolm Timeline Envelope

A Megolm-encrypted timeline event has content with:

- `algorithm: "m.megolm.v1.aes-sha2"`;
- `ciphertext`: a string containing the base64-encoded Megolm message;
- `sender_key`: a string identifying the sender device curve25519 key;
- `session_id`: a string identifying the outbound Megolm session;
- `device_id`: a string identifying the sender device.

The server validates the presence and string type of all five fields. A send
that omits any of the five fields, sets them to a non-string type, or sets
`algorithm` to a value other than `m.megolm.v1.aes-sha2` must be rejected
with `400` and a Matrix `M_*` error envelope appropriate to the failure.

## Olm-shaped Ciphertext on the Room Timeline

A Megolm timeline event must not carry the Olm `ciphertext` shape, which is
an object keyed by recipient curve25519 key with `type` and `body` entries.

A timeline send whose content sets `algorithm` to
`m.olm.v1.curve25519-aes-sha2`, or whose `ciphertext` is an object instead
of a string, must be rejected with `400` and `M_INVALID_PARAM`. The Olm
algorithm and Olm ciphertext shape are reserved for to-device delivery in
`SPEC-052` (and may be further narrowed by future sibling gates of the
`SPEC-079` Olm session lane).

## Fail-Closed Behavior

Implementations must reject:

- non-empty state keys on `m.room.encryption`;
- missing or non-string `algorithm` on `m.room.encryption`;
- non-integer `rotation_period_ms` or `rotation_period_msgs` when present;
- missing required fields on a Megolm timeline event;
- non-string `ciphertext` on a Megolm timeline event;
- Olm `algorithm` or Olm `ciphertext` shape on the room timeline;
- attempts to record decrypted plaintext, derived session state, or device
  trust decisions on the server side.

Malformed bodies must return Matrix `M_*` error envelopes
(`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, or `M_INVALID_PARAM`).
Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid
bearer tokens must return `401` with `M_UNKNOWN_TOKEN`. Authorization
failures must return `403` with `M_FORBIDDEN`. Rate-limited requests may
return `429` with `M_LIMIT_EXCEEDED` and `retry_after_ms`.

## Claim Boundary

Passing this contract does not claim:

- local Olm or Megolm cryptography;
- outbound group session creation, rotation, sharing, or replay detection;
- ciphertext correctness or decryption;
- membership-change-driven session rotation behavior;
- encrypted attachment, key backup, verification, or cross-signing breadth;
- federation encrypted event validation or push privacy beyond existing
  product behavior;
- Matrix v1.18 full E2EE support or `/versions` advertisement widening.

## Japanese Guidance

この contract は `houra-server` の `m.room.encryption` state event と
`m.room.encrypted` Megolm timeline envelope の parser boundary を広げ、
必須/オプション field、空 state key 規則、Olm-shape ciphertext の timeline
拒否を fail-closed に固定する。local Olm/Megolm crypto、Megolm session
派生、ciphertext 内容の解釈、Matrix `/versions` の E2EE claim は引き続き
widen しない。

## Adoption Decision Checklist

After this contract merges:

- create or extend an `houra-server` adoption issue for the representative
  `m.room.encryption` and `m.room.encrypted` Megolm envelope parsing
  behavior against the pinned `houra-spec` ref;
- server adoption must include passing evidence for an empty-state-key
  accept, a non-empty-state-key reject, an `algorithm`-missing state event
  reject, a Megolm timeline accept, per-field missing-field reject vectors,
  and an Olm-shaped ciphertext timeline reject;
- README adoption evidence in `houra-server` must cite this contract, vector,
  implementation ref, verification commands, and a clean-room note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until all child
  lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support claim.
