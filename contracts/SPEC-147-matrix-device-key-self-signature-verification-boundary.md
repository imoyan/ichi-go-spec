# Matrix v1.18 / Client-Server API / device key self-signature and one-time/fallback key signature verification boundary

Status: draft
Feature profile: auth
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / device key self-signature and one-time/fallback key signature verification boundary
Repository anchor: SPEC-147 Matrix Device Key Self-Signature Verification Boundary
Canonical: yes

## Purpose

Define the representative server-owned boundary for Matrix v1.18
`POST /_matrix/client/v3/keys/upload` signature verification beyond the
basic happy path: the device key object must be self-signed by the
uploading device's `ed25519` key, and one-time/fallback signed keys must be
signed by the same device's `ed25519` key.

This contract is a child gate of `SPEC-079`
`device-keys-one-time-fallback-device-list-breadth`. It narrows `SPEC-051`
without re-defining the basic upload happy path or malformed-shape
rejection in `SPEC-051` / `SPEC-141`, and it does not implement Olm/Megolm
cryptography, derive trust, or widen `GET /_matrix/client/versions`.

The signature primitive at this boundary is ed25519 over canonical JSON.
ed25519 verification is a general Matrix server primitive (federation
event signatures, server signing keys, key publication) and is not part
of the local Olm/Megolm crypto prohibition in `SPEC-050`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysupload>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#device-keys>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#one-time-and-fallback-keys>
- Source: <https://spec.matrix.org/v1.18/appendices/#signing-json>
- Checked at: 2026-05-18T21:00:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers accept and validate the signature envelope on:

```text
POST /_matrix/client/v3/keys/upload
```

The server validates the public envelope shape and the cryptographic
signature over canonical JSON.

The signature primitive is ed25519 over the canonical JSON encoding of
the signed object with the `signatures` and `unsigned` fields removed
prior to signing. Canonical JSON, key IDs, and signature placement
follow the Matrix appendix on Signing JSON.

## Device Key Self-Signature

A `device_keys` upload must include a `signatures` entry where:

- the outer map key matches the authenticated `user_id`;
- the inner map contains an `ed25519:{deviceId}` key id matching the
  device's published `ed25519:{deviceId}` public key under `keys`;
- the signature is a valid base64 ed25519 signature by that key over the
  canonical JSON encoding of the device key object with `signatures`
  removed.

Rejections:

- missing `signatures` object → `400` with `M_MISSING_PARAM`;
- empty `signatures` object → `400` with `M_MISSING_PARAM`;
- `signatures` keyed by a `user_id` other than the authenticated user →
  `400` with `M_INVALID_PARAM`;
- `signatures` whose only entries are keyed by a `key_id` that does not
  match the device's published `ed25519:{deviceId}` → `400` with
  `M_INVALID_SIGNATURE`;
- `signatures` whose value does not verify cryptographically against
  the published `ed25519:{deviceId}` public key over the canonical JSON
  of the device key object → `400` with `M_INVALID_SIGNATURE`.

## One-Time and Fallback Key Signature

Each `signed_curve25519:{keyId}` entry in `one_time_keys` and
`fallback_keys` must include `signatures` keyed by the authenticated
`user_id` with an `ed25519:{deviceId}` entry that verifies over the
canonical JSON of the signed key object with `signatures` removed.

Rejections:

- missing `signatures` on a `signed_curve25519:{keyId}` entry →
  `400` with `M_MISSING_PARAM`;
- `signatures` keyed by a `user_id` other than the authenticated user →
  `400` with `M_INVALID_PARAM`;
- `signatures` value that does not verify cryptographically against the
  device's `ed25519:{deviceId}` public key → `400` with
  `M_INVALID_SIGNATURE`;
- `fallback_keys` entry missing `fallback: true` → `400` with
  `M_INVALID_PARAM`.

The server must reject the entire upload when any required signature is
invalid. The server must not persist a partially valid upload that
leaves an unsigned device key or unsigned one-time/fallback key in
storage.

## Canonicalisation Carry-Through

The server canonicalises the signed object before verification using the
Matrix appendix canonical JSON rules. Reordering, whitespace addition,
or trailing-fragment append by intermediate proxies must not produce a
false positive: an upload whose `signatures` were produced over a
different canonical form than the received object must still fail to
verify because the server recomputes the canonical form from the
received object.

The server must compute the canonical form from the same body it
verifies. The server must not log the unsigned ed25519 signing key
material or any intermediate canonical-form buffer alongside server
access tokens, refresh tokens, or other request-bound secrets.

## Fail-Closed Behavior

Implementations must reject:

- uploads whose `device_keys.signatures` map is missing, empty, or
  unrelated to the authenticated user;
- uploads whose device key signature does not verify;
- uploads whose `signed_curve25519:{keyId}` entries are missing
  required `signatures`;
- uploads whose one-time-key or fallback-key signature does not verify;
- uploads where the embedded `user_id` or `device_id` mismatches the
  authenticated user/device (this rejection layer is preserved from
  `SPEC-051`);
- attempts to store unsigned device keys, unsigned one-time keys, or
  unsigned fallback keys.

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid
bearer tokens must return `401` with `M_UNKNOWN_TOKEN`. Malformed
non-signature JSON failures continue to use the appropriate Matrix
`M_*` envelope from `SPEC-051`.

## Claim Boundary

Passing this contract does not claim:

- local Olm or Megolm cryptography;
- cross-signing key signature verification beyond `SPEC-054` /
  `SPEC-144`;
- one-time-key depletion, fallback rotation, or unknown-device
  omission beyond `SPEC-141`;
- federation device-key signature evaluation beyond `SPEC-109` /
  `SPEC-145`;
- device-list `changed` / `left` runtime semantics beyond `SPEC-093`;
- key backup `auth_data` signature validation beyond `SPEC-053` /
  `SPEC-143`;
- Matrix v1.18 full E2EE support or `/versions` advertisement
  widening.

## Japanese Guidance

この contract は `houra-server` の `keys/upload` 受理側で device key の
ed25519 自署 (および one-time / fallback signed_curve25519 の署名) 検証を
fail-closed に固定する。canonical JSON over ed25519 という Matrix 一般の
primitive で、SPEC-050 が禁じる local Olm/Megolm crypto には該当しない。
private signing key、access token、refresh token と一緒に署名対象 buffer
を log しない。Matrix `/versions` の E2EE claim は引き続き widen しない。

## Adoption Decision Checklist

After this contract merges:

- create or extend an `houra-server` adoption issue for representative
  signature verification at `keys/upload` against the pinned
  `houra-spec` ref;
- server adoption must include passing evidence for missing
  `signatures`, empty `signatures`, wrong-user `signatures`, wrong-key
  signing key id, cryptographically invalid device key signature,
  missing one-time-key signature, invalid one-time-key signature,
  invalid fallback-key signature, and an accepted happy-path upload;
- README adoption evidence in `houra-server` must cite this contract,
  vector, implementation ref, verification commands, and a clean-room
  note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until
  all child lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support claim.
