# SPEC-054: Matrix Verification and Cross-Signing Gate

Status: draft
Feature profile: messaging
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server verification, cross-signing, and
wrong-device failure gate for Houra E2EE compatibility work.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
verification and cross-signing behavior without changing existing
`/_houra/client/**` routes.

This gate builds on `SPEC-050` crypto adapter ownership, `SPEC-051` device key
publication/query, `SPEC-052` to-device delivery and encrypted-room send/receive,
and `SPEC-053` key backup recovery. It covers SAS verification message shape,
verification cancellation, public cross-signing key upload/query/signature
publication, invalid signature failures, and wrong-device/fingerprint mismatch
acceptance evidence. It does not define local SAS, Ed25519, Olm, Megolm, or
cross-signing cryptographic implementation.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#device-verification>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mkeyverificationrequest>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mkeyverificationcancel>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#cross-signing>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysdevice_signingupload>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keyssignaturesupload>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysquery>
- Checked at: 2026-05-10T19:50:08+09:00
- Timezone: Asia/Tokyo

## Verification messages

Clients may verify devices through to-device messages or in-room messages. This
contract covers the to-device SAS path as the minimum E2EE gate because it
depends on the to-device queue from `SPEC-052` and device identity material from
`SPEC-051`.

A successful SAS verification flow must preserve the same `transaction_id`
across these event types:

- `m.key.verification.request`;
- `m.key.verification.ready`;
- `m.key.verification.start` with `method: m.sas.v1`;
- `m.key.verification.accept`;
- `m.key.verification.key`;
- `m.key.verification.mac`;
- final local trust update evidence from the maintained Matrix crypto adapter.

The server treats verification to-device payloads as opaque Matrix event
content. The client-owned crypto adapter calculates commitments, ephemeral keys,
SAS values, and MACs. Houra code must not implement those algorithms locally.

Either side can cancel a verification by sending `m.key.verification.cancel`.
For this gate, an SAS mismatch must use `code: m.mismatched_sas`; unknown
transactions, unsupported methods, and out-of-sequence messages must not mark
the device as verified.

## Cross-signing

Clients upload public cross-signing keys with:

```text
POST /_matrix/client/v3/keys/device_signing/upload
```

The request may contain `master_key`, `self_signing_key`, and
`user_signing_key`. The self-signing and user-signing keys must be signed by the
user's master signing key. The server validates signatures and stores public key
material; it must never store private signing keys.

Clients publish signatures over device keys or cross-signing keys with:

```text
POST /_matrix/client/v3/keys/signatures/upload
```

The response must include a `failures` map for signatures that could not be
accepted. Invalid signatures must surface `M_INVALID_SIGNATURE`.

Clients query device and cross-signing key material with:

```text
POST /_matrix/client/v3/keys/query
```

The response may include `master_keys`, `self_signing_keys`, and
`user_signing_keys` in addition to device keys. Trust decisions remain
client-owned and adapter-backed.

## Wrong-device failure gate

A passing implementation must demonstrate that a changed or mismatched device
identity cannot silently inherit trust. The gate requires:

- an established trusted cross-signing chain for a user/device;
- a later device key or master-key fingerprint mismatch for the same Matrix
  user/device identity;
- the client refuses to mark the device verified;
- outbound encrypted-room session sharing does not proceed to the mismatched
  device without explicit user recovery/reverification;
- verification is cancelled or failed with an appropriate Matrix verification
  code;
- the evidence records spec ref, server ref, client ref, crypto stack name and
  version, trusted fingerprint, observed fingerprint, commands, and per-step
  pass/fail evidence.

## Authentication and errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Malformed request bodies, invalid Matrix identifiers, malformed verification
events, unsupported verification methods, missing transaction IDs, invalid
cross-signing key shape, missing cross-signing prerequisites, and invalid
signatures must return Matrix `M_*` error envelopes appropriate to the failure
(`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, `M_INVALID_PARAM`,
`M_INVALID_SIGNATURE`, or `M_NOT_FOUND`).

`POST /_matrix/client/v3/keys/device_signing/upload` may require Matrix
interactive authentication when replacing existing signing keys. OAuth-aware
metadata is carried by `SPEC-032`; this contract only requires that the
endpoint's Matrix error and auth shape remain compatible with v1.18.

Rate-limited endpoints may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix verification and cross-signing endpoints must use Matrix `M_*` error
  envelopes, not Houra `code` envelopes.
- Servers store and relay public key/signature/to-device payloads but do not
  implement client trust decisions or private-key operations.
- Clients must use a maintained Matrix crypto stack through the `SPEC-050`
  adapter boundary for SAS, signature verification, cross-signing trust, and
  wrong-device failure decisions.
- This contract does not claim secret storage, federation key forwarding,
  QR-code verification UX, full account recovery UX, or Matrix v1.18 full
  compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only shared
  helpers for verification event shape or cross-signing public key validation
  are intentionally adopted.
