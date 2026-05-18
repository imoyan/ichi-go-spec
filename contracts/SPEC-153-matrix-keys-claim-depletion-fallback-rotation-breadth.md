# Matrix v1.18 / Client-Server API / keys claim depletion, fallback rotation, and unknown-user/device omission boundary

Status: draft
Feature profile: auth
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / keys claim depletion, fallback rotation, and unknown-user/device omission boundary
Repository anchor: SPEC-153 Matrix Keys Claim Depletion Fallback Rotation Omission Boundary
Canonical: yes

## Purpose

Define the representative server-owned boundary for Matrix v1.18
`POST /_matrix/client/v3/keys/claim` behavior beyond the basic happy path:
one-time key claimed-at-most-once depletion, fallback key rotation after a
newer fallback upload, unknown user and unknown device omission, and a mixed
multi-device batch claim that exercises all of those at once.

This contract is a child gate of `SPEC-079`
`device-keys-one-time-fallback-device-list-breadth`. It narrows `SPEC-051`
without re-defining the key upload, key query, or basic key claim happy path,
and it does not implement local Olm/Megolm cryptography, derive trust, or
widen `GET /_matrix/client/versions`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysclaim>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysupload>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#one-time-and-fallback-keys>
- Checked at: 2026-05-18T17:05:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers accept and consume one-time and fallback key claims through:

```text
POST /_matrix/client/v3/keys/claim
```

The representative algorithm is `signed_curve25519`. Returned key objects must
preserve the signed key shape uploaded through `POST /_matrix/client/v3/keys/upload`
in `SPEC-051`, including `key`, `signatures`, and, for fallback keys,
`fallback: true`.

The server validates the request envelope shape, target user/device map,
and the algorithm string. The server must not derive Olm session state,
must not return private key material, and must not log claim responses
alongside server access tokens or refresh tokens.

## Claimed-At-Most-Once Depletion

Each uploaded one-time key must be returned by at most one successful
`keys/claim` response. When a device has uploaded multiple one-time keys and
two clients claim against the same device in sequence, the server must
return two distinct key IDs.

When a device has exhausted its uploaded one-time keys, the server must not
synthesize a new one-time key, replay a previously returned key ID, or omit
the device silently. Either a fallback key entry must be returned for the
device, or the device must be omitted from the response.

## Fallback Rotation

When a device has uploaded a fallback key and then uploads a new fallback key
under a different key ID, subsequent claims that fall back must return the
newer fallback key. The older fallback key must not be returned once a
successor has been uploaded for the same device.

A fallback key may be returned by more than one claim. Returning the same
fallback key ID across claims is not a depletion failure.

## Unknown User and Unknown Device Omission

A request that names an unknown user, an unknown device, or an algorithm the
device has not published one-time keys for must return `200` with the
unknown entry omitted from `one_time_keys`. Unknown remote-server failures
may be recorded under `failures`.

A request must not return `404` or `M_NOT_FOUND` for the absence of a
particular user, device, or algorithm.

## Mixed Multi-Device Batch

A single claim request that names multiple `(user_id, device_id, algorithm)`
triples must process every triple independently. The response may include:

- a freshly returned one-time key for one device;
- a fallback key for another device whose one-time keys are exhausted;
- an omitted entry for a third device that is unknown to the server;

and must do so within the same `200` response. The server must not abort the
batch or fail the entire request because one of the triples is unknown.

## Fail-Closed Behavior

Implementations must reject:

- non-object request bodies;
- non-object `one_time_keys` maps;
- non-string algorithm values;
- malformed user IDs and device IDs in the claim request;
- attempts to record private key material, decrypted ciphertext, or session
  trust decisions on the server side.

Malformed shapes must return Matrix `M_*` error envelopes appropriate to the
failure (`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, or
`M_INVALID_PARAM`). Missing bearer tokens must return `401` with
`M_MISSING_TOKEN`. Invalid bearer tokens must return `401` with
`M_UNKNOWN_TOKEN`. Rate-limited requests may return `429` with
`M_LIMIT_EXCEEDED` and `retry_after_ms`.

## Claim Boundary

Passing this contract does not claim:

- local Olm or Megolm cryptography;
- Olm session derivation, validity, or trust;
- signed device key signature verification on uploaded keys beyond payload
  shape;
- device-list `changed` and `left` semantics beyond `SPEC-093`;
- federation key query interaction beyond `SPEC-069`;
- to-device delivery, encrypted-room timeline, key backup, verification, or
  cross-signing breadth;
- Matrix v1.18 full E2EE support or `/versions` advertisement widening.

## Japanese Guidance

この contract は `houra-server` の `keys/claim` server boundary を広げ、
one-time key の claim-at-most-once 消費 / fallback key rotation /
unknown user-device の omission / 複合 batch claim の breadth を
fail-closed に固定する。local Olm/Megolm crypto, session trust,
device key 署名検証, Matrix `/versions` の E2EE claim は引き続き widen しない。

## Adoption Decision Checklist

After this contract merges:

- create or extend an `houra-server` adoption issue for the representative
  depletion, rotation, omission, and batch behavior against the pinned
  `houra-spec` ref;
- server adoption must include passing evidence for two-claim depletion
  returning distinct key IDs, fallback returned after upload-and-exhaust,
  newer fallback returned after rotation upload, unknown-user and
  unknown-device omission with `200`, and a mixed-batch response that
  combines all three states;
- README adoption evidence in `houra-server` must cite this contract, vector,
  implementation ref, verification commands, and a clean-room note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until all child
  lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support claim.
