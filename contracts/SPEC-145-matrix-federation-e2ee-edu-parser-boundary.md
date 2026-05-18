# Matrix v1.18 / Server-Server API / federation E2EE EDU parser boundary for device list update, signing key update, and direct-to-device

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Server-Server API
Primary reference: Matrix v1.18 / Server-Server API / federation E2EE EDU parser boundary for device list update, signing key update, and direct-to-device
Repository anchor: SPEC-145 Matrix Federation E2EE EDU Parser Boundary
Canonical: yes

## Purpose

Define the representative server-owned parser boundary for the three
Matrix v1.18 Server-Server API EDUs that carry E2EE-related cross-server
state through `PUT /_matrix/federation/v1/send/{txnId}`:
`m.device_list_update`, `m.signing_key_update`, and `m.direct_to_device`.

This contract is a child gate of `SPEC-079`
`federation-room-version-push-interaction-breadth`. It narrows
`SPEC-074` and complements `SPEC-109` runtime adoption by fixing the
federation EDU envelope shape and rejection rules without claiming local
Olm/Megolm cryptography, federation fanout correctness, remote
signature trust, or `GET /_matrix/client/versions` advertisement.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#put_matrixfederationv1sendtxnid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#device-management>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#mdevice_list_update>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#cross-signing>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#msigning_key_update>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#end-to-end-encryption>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#mdirect_to_device>
- Checked at: 2026-05-18T19:00:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers accept federation EDUs through:

```text
PUT /_matrix/federation/v1/send/{txnId}
```

This contract narrows the EDU parser at the federation transaction
boundary to the three E2EE-related EDU types listed below. The server
validates the public envelope shape, the EDU type, and required content
fields. The server must not decrypt to-device payloads, must not derive
device trust, must not log private signatures, must not log Olm/Megolm
session keys, and must not log decrypted plaintext.

The EDU parser boundary is shared with `SPEC-107`
`matrix-federation-transaction-event-validation-runtime`. This contract
adds the three E2EE-related EDU shapes without re-defining transaction
auth, transaction signature verification, or generic typing/receipt EDU
parsing.

## `m.device_list_update` EDU

Content fields:

- `user_id`: required string;
- `device_id`: required string;
- `stream_id`: required integer;
- `prev_id`: optional list of integers;
- `device_display_name`: optional string;
- `keys`: optional object containing public device key material in the
  Matrix `device_keys` shape from `SPEC-051`;
- `device_display_name`, `keys`, and `deleted` may be omitted when the
  update is a prev-id chain-only delivery;
- `deleted`: optional boolean indicating a device deletion.

The server stores the public device-list delta. The server must not
infer cross-server trust from a single EDU and must keep the delta scoped
to the sending homeserver.

## `m.signing_key_update` EDU

Content fields:

- `user_id`: required string;
- `master_key`: optional cross-signing master key object in the
  `SPEC-054` `master_key` shape;
- `self_signing_key`: optional cross-signing self-signing key object in
  the `SPEC-054` `self_signing_key` shape;
- at least one of `master_key` or `self_signing_key` must be present.

The server stores only public cross-signing key material. The server
must not store private signing keys, must not promote a remote cross-signing
key to a local user, and must not interpret signatures whose signing key
is not held locally as a trust decision.

## `m.direct_to_device` EDU

Content fields:

- `sender`: required string Matrix user ID;
- `type`: required string event type;
- `message_id`: required string unique to the sending homeserver and the
  EDU window;
- `messages`: required object keyed by target Matrix user ID with values
  keyed by target device ID; each leaf value is an opaque event content
  object;
- the leaf content object is opaque to the federation parser; it must be
  forwarded to the recipient device without decryption.

The server treats `messages` content as opaque per `SPEC-052` and
`SPEC-152`. The server must not decrypt Olm payloads, must not derive
Olm session state, and must not compare leaf content across `message_id`
boundaries.

## Transaction-Level Behavior

A federation transaction may carry zero or more E2EE-related EDUs in
addition to PDUs and other EDUs. EDUs are parsed independently; a
malformed E2EE EDU must be rejected without dropping unrelated PDUs in
the same transaction. The server may surface per-EDU failures alongside
PDU failures through the transaction response shape from `SPEC-107`.

A duplicate `message_id` for the same `sender` and EDU window must not
duplicate delivery to recipient devices.

## Fail-Closed Behavior

Implementations must reject:

- EDUs with `edu_type` set to one of the three E2EE-related types but
  with `content` missing required fields;
- `m.device_list_update` with non-integer `stream_id`;
- `m.device_list_update` with non-list `prev_id`;
- `m.device_list_update` with non-boolean `deleted`;
- `m.signing_key_update` with neither `master_key` nor
  `self_signing_key`;
- `m.signing_key_update` `master_key` or `self_signing_key` with
  embedded `user_id` mismatching the EDU `user_id`;
- `m.direct_to_device` with missing `sender`, `type`, `message_id`, or
  `messages`;
- `m.direct_to_device` with non-object `messages` map or non-object
  per-user/per-device leaf;
- attempts to record decrypted plaintext, derived Olm session state,
  trust decisions, or private cross-signing material on the server side.

Malformed EDUs must be rejected with a Matrix `M_*` error in the
per-EDU failure surface from `SPEC-107`. Transactions whose body is
not a JSON object must continue to return `400` with `M_BAD_JSON`.

Transactions without valid federation request authentication continue
to follow `SPEC-097` request-auth behavior; this contract does not
re-define request signature verification.

## Claim Boundary

Passing this contract does not claim:

- local Olm or Megolm cryptography;
- federation fanout correctness across multiple destination servers;
- remote signature trust for received `m.device_list_update` or
  `m.signing_key_update` entries beyond shape;
- automatic device-list synchronization to local clients beyond
  `SPEC-093` and existing `/sync` semantics;
- Olm session derivation from forwarded `m.direct_to_device` payloads;
- federation key fetch from a remote server triggered by these EDUs;
- encrypted media attachment behavior;
- Matrix v1.18 full E2EE support or `/versions` advertisement widening.

## Japanese Guidance

この contract は `houra-server` の federation send transaction の
E2EE EDU parser を fail-closed に固定する。`m.device_list_update` /
`m.signing_key_update` / `m.direct_to_device` の公開 envelope shape
と必須 field 検証を server boundary で narrow し、SPEC-109 runtime
adoption と SPEC-107 transaction parser を補完する。local Olm/Megolm
crypto、remote signature の信用評価、fanout の正しさ、Matrix
`/versions` の E2EE claim は引き続き widen しない。

## Adoption Decision Checklist

After this contract merges:

- create or extend an `houra-server` adoption issue for the
  representative E2EE EDU parser behavior at the federation transaction
  boundary against the pinned `houra-spec` ref;
- server adoption must include passing evidence for a happy-path
  three-EDU mix accepted in a single transaction, malformed
  `m.device_list_update` rejection, malformed `m.signing_key_update`
  rejection, malformed `m.direct_to_device` rejection, and an opaque
  `messages` payload forwarded without decryption;
- README adoption evidence in `houra-server` must cite this contract,
  vector, implementation ref, verification commands, and a clean-room
  note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until all
  child lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support claim.
