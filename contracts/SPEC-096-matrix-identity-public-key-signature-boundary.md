# SPEC-096: Matrix Identity Public Key and Signature Boundary

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Identity Service API
Canonical: yes

## Purpose

Define a bounded Identity Service public key, ephemeral key validity, and
association signature boundary for the
`public-key-ephemeral-key-signed-association-breadth` lane in `SPEC-076`.

This contract lets implementation repositories record representative evidence
for key lookup and validity checks without claiming full Identity Service API
support, invitation storage, consent UI, production key rotation, or Matrix
version advertisement.

## Scope

This contract covers representative Matrix v1.18 Identity Service behavior:

- `GET /_matrix/identity/v2/pubkey/{keyId}`;
- `GET /_matrix/identity/v2/pubkey/isvalid`;
- `GET /_matrix/identity/v2/pubkey/ephemeral/isvalid`;
- long-term public key validity and rotation failure;
- ephemeral public key expiry;
- signed association verification failure;
- bounded, redacted key and signature artifacts.

It does not define invitation storage, ephemeral invitation signing payloads,
production key-management operations, user-facing consent UI, provider
delivery, homeserver account-data persistence, or full Identity Service API
advertisement.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#get_matrixidentityv2pubkeykeyid>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#get_matrixidentityv2pubkeyisvalid>
- Source: <https://spec.matrix.org/v1.18/identity-service-api/#get_matrixidentityv2pubkeyephemeralisvalid>
- Parent contract: `SPEC-059`
- Gap inventory: `SPEC-076`
- Checked at: 2026-05-16T10:56:00+09:00
- Timezone: Asia/Tokyo

## Key and signature behavior

`GET /_matrix/identity/v2/pubkey/{keyId}` returns a public key only for an
active identity-service key identifier. Unknown, rotated, or expired key
identifiers MUST fail closed and MUST NOT return stale key material.

`GET /_matrix/identity/v2/pubkey/isvalid` returns whether the supplied
long-term public key is currently valid. `GET
/_matrix/identity/v2/pubkey/ephemeral/isvalid` returns whether the supplied
ephemeral public key is currently valid. Expired or rotated keys MUST return
`valid: false` rather than leaking replacement keys or accepting stale
signatures.

Signed associations returned by bind or lookup evidence MUST be accepted only
when the association signature references a currently valid long-term
identity-service key. Invalid signatures, expired public keys, rotated key IDs,
or mismatched identity-service server names MUST fail closed. The representative
artifact records verification decisions only; it MUST NOT store raw signature
bytes, private keys, raw public-key material, raw Identity Service tokens, raw
lookup peppers, or raw 3PIDs.

## Resource and privacy bounds

Representative artifacts MUST be bounded:

- maximum canonical case bytes: 20480;
- maximum case count: 8;
- maximum active public key count: 2;
- maximum active ephemeral key count: 2;
- maximum signature key count per association: 2;
- key validity clock source: `server`;
- key validity cache scope: `process`;
- key validity cache max entries: 128;
- production key rotation operation: false;
- invitation signing operation: false;
- raw identity token evidence: false;
- raw lookup pepper evidence: false;
- raw public key evidence: false;
- raw private key evidence: false;
- raw ephemeral key evidence: false;
- raw signature evidence: false;
- raw 3PID evidence: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Evidence artifact

Each representative case records:

- `id`;
- `kind`: `public_key_lookup`, `public_key_valid`,
  `public_key_rotated`, `ephemeral_key_valid`, `ephemeral_key_expired`,
  `signed_association_valid`, or `invalid_signature`;
- `request`: method and path;
- `status`;
- `errcode` when the result is a Matrix error;
- `key_state`: `active`, `rotated`, `expired`, or `unknown`;
- `signature_state`: `valid`, `invalid`, or `not_applicable`;
- `association_state`: `verified`, `rejected`, or `not_applicable`;
- `redacted_fields`;
- `result`: `accepted`.

Artifacts MUST NOT store raw Identity Service tokens, lookup peppers, private
keys, raw public keys, raw ephemeral keys, raw signatures, full 3PID addresses,
local paths, database keys, or provider payloads. Redacted fields MAY identify
which categories were removed so downstream evidence can be audited without
exposing secrets or user identifiers.

## Compatibility boundaries

- This contract does not widen `GET /_matrix/client/versions`.
- Identity Service API remains out of the current Matrix v1.18 advertisement
  until the release-evidence gate explicitly allows it.
- `SPEC-059` remains the representative Identity Service boundary. This
  contract narrows one `SPEC-076` lane for implementation adoption evidence; it
  does not complete Identity Service full breadth.
- Invitation storage, ephemeral invitation signing payloads, provider delivery,
  consent UI, account lifecycle, production key rotation, and release
  advertisement lanes stay separate.
