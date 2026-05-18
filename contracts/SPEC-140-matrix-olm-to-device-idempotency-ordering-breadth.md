# Matrix v1.18 / Olm & Megolm / Olm to-device transaction idempotency and out-of-order delivery boundary

Status: draft
Feature profile: messaging
Contract type: boundary
Matrix domain: Olm & Megolm
Primary reference: Matrix v1.18 / Olm & Megolm / Olm to-device transaction idempotency and out-of-order delivery boundary
Repository anchor: SPEC-140 Matrix Olm To-Device Idempotency and Ordering Boundary
Canonical: yes

## Purpose

Define the representative server-owned boundary for Matrix v1.18 Olm to-device
transaction idempotency, drift rejection, multi-sender out-of-order delivery,
and sync acknowledgement behavior on `m.olm.v1.curve25519-aes-sha2`
pre-key and normal payloads.

This contract is a sibling child gate of `SPEC-130` for the
`SPEC-079` `olm-session-to-device-withheld-key-breadth` lane. It does not
implement Olm cryptography, does not derive or trust session keys, does not
widen `GET /_matrix/client/versions`, and does not turn representative
Olm to-device evidence into a full E2EE support claim.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#send-to-device-messaging>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3sendtodeviceeventtypetxnid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3sync>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#molmv1curve25519-aes-sha2>
- Checked at: 2026-05-18T16:40:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers accept and queue Olm to-device payloads through:

```text
PUT /_matrix/client/v3/sendToDevice/m.room.encrypted/{txnId}
GET /_matrix/client/v3/sync
```

The representative payload uses `algorithm: "m.olm.v1.curve25519-aes-sha2"`
with a `ciphertext` map keyed by the recipient device curve25519 key. Each
entry carries a `type` and `body`. `type: 0` is a pre-key message that begins
an Olm session. `type: 1` is a normal Olm message on an established session.

The server validates the public envelope shape, target user/device map,
transaction idempotency on `{txnId}` for the sending device and event type,
and device-scoped queue delivery. The server must not decrypt the
`body` strings, must not derive Olm session state, must not compare ciphertext
across senders, and must not log plaintext, session keys, or device trust
decisions.

## Payload Shape

Olm to-device payloads must include:

- `algorithm: "m.olm.v1.curve25519-aes-sha2"`;
- `sender_key`, the curve25519 identity key of the sending device;
- `ciphertext`, an object keyed by recipient curve25519 key string;
- each recipient entry contains `type` (`0` for pre-key, `1` for normal) and a
  `body` string.

The representative vectors use Matrix identifiers and opaque placeholder key
strings. Those strings are not normative cryptographic material and must not
be retained alongside server access tokens, refresh tokens, callback queries,
or private key material.

## Transaction Idempotency and Drift

Successful sends return `200` with `{}`.

A repeated `{txnId}` for the same authenticated sending device and the same
event type is idempotent when the `messages` body is byte-identical. The
server must not enqueue a second copy for the target devices in that case.

A repeated `{txnId}` with a different `messages` body must fail rather than
silently replacing queued messages or appending an additional message. The
server must respond with `400` and `M_INVALID_PARAM` and must not deliver the
drifted payload.

## Multi-Sender Out-of-Order Delivery

When multiple sending devices target the same recipient device with separate
`{txnId}` values, the server must queue every accepted payload and must
deliver every accepted payload through `/sync` to the recipient device.

The server is not required to impose a particular cross-sender ordering, but
it must not drop, merge, or reorder payloads from a single sender. Payloads
from a single sender that share the same recipient device must be delivered
in the order their requests were accepted.

## Sync Acknowledgement

Pending to-device messages are delivered under `/sync`
`to_device.events` with `sender`, `type`, and opaque `content`. Once the
recipient syncs again using the `next_batch` returned by the previous sync,
previously delivered to-device messages must not reappear in later sync
responses.

A sync request that reuses an older `since` token must not be required to
resurrect already-acknowledged messages. A sync request without `since` is
not normative for replay because no acknowledgement has yet been observed.

## Fail-Closed Behavior

Implementations must reject:

- unknown or malformed target user IDs and device IDs;
- non-object `messages` content;
- Olm payloads missing `algorithm`, `sender_key`, `ciphertext`, recipient
  `type`, or recipient `body`;
- recipient `type` values outside `0` and `1`;
- duplicate `{txnId}` with different `messages` body content;
- attempts to record decrypted plaintext, derived session state, or device
  trust decisions on the server side.

## Claim Boundary

Passing this contract does not claim:

- local Olm or Megolm cryptography;
- Olm session derivation, validity, or trust;
- decryption of pre-key or normal Olm payloads;
- encrypted-room timeline correctness beyond `SPEC-052`;
- withheld-key, room-key-request, forwarded-room-key, or cancellation payload
  shape coverage beyond `SPEC-130`;
- device-list, fallback-key, or one-time-key breadth beyond `SPEC-051`;
- server-side key backup beyond `SPEC-053`;
- verification or cross-signing beyond `SPEC-054`;
- federation to-device delivery, key-share, or room-key relay;
- Matrix v1.18 full E2EE support or `/versions` advertisement widening.

## Japanese Guidance

この contract は `houra-server#252` の Olm session to-device server boundary を
広げ、transaction idempotency / drift rejection / multi-sender out-of-order
delivery / sync acknowledgement の breadth を fail-closed に固定する。
local Olm/Megolm crypto, session key の意味付け, trust decision,
Matrix `/versions` の E2EE claim は引き続き widen しない。

## Adoption Decision Checklist

After this contract merges:

- `houra-server#252` may extend the existing Olm to-device relay adoption with
  the representative idempotency, drift rejection, multi-sender delivery, and
  sync acknowledgement behavior against the pinned `houra-spec` ref;
- server adoption must include passing evidence for idempotent retry,
  duplicate-`{txnId}`-with-different-body rejection, two-sender delivery to a
  single recipient device, sync acknowledgement after `next_batch` advance,
  and malformed Olm envelope rejection;
- README adoption evidence in `houra-server` must cite this contract, vector,
  implementation ref, verification commands, and a clean-room note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until all child
  lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support claim.
