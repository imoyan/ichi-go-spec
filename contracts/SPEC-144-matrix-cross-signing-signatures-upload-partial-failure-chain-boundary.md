# Matrix v1.18 / Client-Server API / cross-signing signatures upload partial-failure and signing-chain prerequisite boundary

Status: draft
Feature profile: messaging
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / cross-signing signatures upload partial-failure and signing-chain prerequisite boundary
Repository anchor: SPEC-144 Matrix Cross-Signing Signatures Upload Partial-Failure Chain Boundary
Canonical: yes

## Purpose

Define the representative server-owned boundary for Matrix v1.18 cross-signing
behavior beyond `SPEC-054`: `POST /_matrix/client/v3/keys/signatures/upload`
partial-failure mapping when a request mixes valid and invalid signatures, and
`POST /_matrix/client/v3/keys/device_signing/upload` signing-chain prerequisite
enforcement when a self-signing or user-signing key is uploaded without a
master key available.

This contract is a child gate of `SPEC-079`
`verification-cross-signing-trust-wrong-device-breadth`. It narrows
`SPEC-054` without re-defining the basic happy path, SAS verification flow,
or single-invalid-signature failure, and it does not implement local
Olm/Megolm cryptography, derive trust, or widen
`GET /_matrix/client/versions`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysdevice_signingupload>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keyssignaturesupload>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#cross-signing>
- Checked at: 2026-05-18T18:30:00+09:00
- Timezone: Asia/Tokyo

## Scope

Servers accept and validate cross-signing key publication and signature
publication through:

```text
POST /_matrix/client/v3/keys/device_signing/upload
POST /_matrix/client/v3/keys/signatures/upload
```

The server validates the public envelope shape, the authenticated user
identity, the signing-chain prerequisite, and the per-signature signing
relationship. The server stores only public key material and public
signatures. The server must not store, derive, or log private signing
keys, private cross-signing seeds, or recovery key material.

## Signing-Chain Prerequisite

A `keys/device_signing/upload` request that includes `self_signing_key` or
`user_signing_key` must be verifiable against the master key. The master key
is acceptable when either:

- the same request body contains a valid `master_key` signed by an existing
  device of the authenticated user; or
- a `master_key` is already stored on the server for the authenticated
  user.

An upload that contains `self_signing_key` or `user_signing_key` but
neither a same-request `master_key` nor a stored `master_key` must be
rejected with `400` and `M_INVALID_SIGNATURE`. The server must not store
the orphaned child key.

An upload of `self_signing_key` or `user_signing_key` whose signature is
not produced by the available master key must be rejected with `400` and
`M_INVALID_SIGNATURE`, consistent with `SPEC-054`.

When a `master_key` is already stored and the same request body re-uploads
a different master key, the server must require Matrix interactive
authentication. Without acceptable UIA evidence, the server must respond
with `401` and the appropriate UIA `flows` envelope. The server must not
silently replace the existing master key.

## Signatures Upload Partial-Failure

A `keys/signatures/upload` request body has the shape:

```text
{
  "@user:example.test": {
    "DEVICE_OR_KEY_ID": { ...signed object... },
    ...
  },
  ...
}
```

The request may target multiple devices, multiple cross-signing public
keys, or both. Each entry must include `signatures` keyed by the signing
user/key identifier.

The server processes each `(user_id, target_id)` entry independently. Each
entry that has a valid signature from an accepted signing key must be
accepted and reflected in subsequent `keys/query` responses. Each entry
that fails validation must be reported under the response `failures` map
keyed by `(user_id, target_id)` with a Matrix `M_*` error code such as
`M_INVALID_SIGNATURE`.

When at least one entry succeeds and at least one entry fails, the response
status must remain `200`. The response must include the `failures` map
with at least the failing entries; entries that succeeded must not appear
under `failures`.

When every entry fails for the same reason, the response status must
remain `200` and the `failures` map must reflect every failing entry. The
server must not promote a partial-failure into an HTTP error envelope.

## Cross-User Signing Boundary

`keys/signatures/upload` may carry signatures for the authenticated user's
own devices and own cross-signing keys, and may carry user-signing-key
signatures the authenticated user issues over another user's master key.
The server must validate that the signing key in each entry belongs to the
authenticated user, and that the target identity is consistent with the
embedded `user_id` and `device_id` or key identifier.

A target entry whose `user_id` mismatches the authenticated user and is
not a user-signing-key signature over a remote master key must be rejected
into the response `failures` map with `M_FORBIDDEN`. The request itself
must not fail with HTTP `403` solely because one entry mismatches.

## Fail-Closed Behavior

Implementations must reject or fail-close:

- non-object request bodies on `device_signing/upload` and
  `signatures/upload`;
- non-object per-user maps on `signatures/upload`;
- target entries missing `signatures`;
- target entries whose `signatures` map is empty;
- `self_signing_key` or `user_signing_key` upload without an available
  master key;
- master-key replacement without UIA;
- attempts to record private signing keys, cross-signing seeds, or recovery
  material on the server side.

Malformed bodies must return Matrix `M_*` error envelopes
(`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, or `M_INVALID_PARAM`).
Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid
bearer tokens must return `401` with `M_UNKNOWN_TOKEN`. Master-key
replacement without UIA must return `401` with the UIA flow envelope from
`SPEC-032`.

## Claim Boundary

Passing this contract does not claim:

- local Olm or Megolm cryptography;
- device verification UX, SAS, or QR-code flows beyond `SPEC-054`;
- automatic trust propagation across users;
- cross-signing key rotation UX or secret storage backed by the recovery
  key;
- federation key-query interaction beyond `SPEC-069`;
- wrong-device or trust-reset recovery beyond `SPEC-054`;
- Matrix v1.18 full E2EE support or `/versions` advertisement widening.

## Japanese Guidance

この contract は `houra-server` の cross-signing 公開鍵 / 署名 publication
の server boundary を広げ、signatures/upload の partial-failure マップ、
device_signing/upload の signing-chain prerequisite (master 不在で
self_signing / user_signing を拒否)、master 鍵 replacement の UIA 要求を
fail-closed に固定する。private key material、recovery 素材、Matrix
`/versions` の E2EE claim は引き続き widen しない。

## Adoption Decision Checklist

After this contract merges:

- create or extend an `houra-server` adoption issue for the representative
  partial-failure mapping and signing-chain prerequisite enforcement
  against the pinned `houra-spec` ref;
- server adoption must include passing evidence for a mixed valid/invalid
  signatures upload returning `200` with `failures` populated for only the
  invalid entries, an orphaned `self_signing_key` upload returning
  `M_INVALID_SIGNATURE`, a master-key-replacement request returning `401`
  with a UIA flows envelope, and a self-signing-key upload accepted after a
  prior master-key upload;
- README adoption evidence in `houra-server` must cite this contract,
  vector, implementation ref, verification commands, and a clean-room
  note;
- `SPEC-079` remains the full Olm & Megolm E2EE gap inventory until all
  child lanes provide runtime and release evidence;
- representative evidence from this contract must not widen Matrix
  `/versions`, release notes, or the publishable Matrix support claim.
