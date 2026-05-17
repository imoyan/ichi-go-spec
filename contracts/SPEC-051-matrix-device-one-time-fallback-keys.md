# SPEC-051: Matrix Device, One-Time, and Fallback Keys

Status: draft
Feature profile: auth
Contract type: endpoint
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server E2EE key publication and claim surface
for device keys, one-time keys, and fallback keys.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**` key
upload, query, and claim behavior without changing existing
`/_houra/client/**` routes.

This endpoint family builds on `SPEC-034` devices and sessions, `SPEC-050`
crypto adapter ownership, and the narrower `SPEC-069` device-key query
contract. It covers device key upload, one-time key upload/claim, fallback key
upload/claim, key-count responses, representative authorization errors, and
malformed key-shape failures. It does not define
to-device message delivery, encrypted room send/receive, room key sharing, key
backup, verification, cross-signing publication, secret storage, federation key
queries, or local Olm/Megolm implementation.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysupload>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysquery>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysclaim>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#one-time-and-fallback-keys>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#device-keys>
- Checked at: 2026-05-10T19:46:18+09:00
- Timezone: Asia/Tokyo

## Key upload

Clients upload device keys, one-time keys, and fallback keys with:

```text
POST /_matrix/client/v3/keys/upload
```

The request requires authentication for the current user and current device.
The body may include:

- `device_keys`: a device key object for the current user/device;
- `one_time_keys`: a map of key IDs to signed one-time key objects;
- `fallback_keys`: a map of key IDs to signed fallback key objects.

Device key objects must include `user_id`, `device_id`, `algorithms`, `keys`,
and `signatures`. The `user_id` and `device_id` must match the authenticated
user and device. `algorithms` must include the algorithms the device supports,
including `m.olm.v1.curve25519-aes-sha2` and `m.megolm.v1.aes-sha2` when the
device claims E2EE support. `keys` must include `curve25519:{deviceId}` and
`ed25519:{deviceId}` entries. `signatures` must include a signature by the
device's Ed25519 key.

One-time and fallback keys use `signed_curve25519:{keyId}` entries. Fallback
key objects must include `fallback: true`.

Successful upload returns `200` with `one_time_key_counts`. Servers may also
return fallback-key status fields when Matrix defines them for the response.
Servers must not return private key material.

## Key query

The first client/parser-facing query boundary is defined in `SPEC-069`:

```text
POST /_matrix/client/v3/keys/query
```

This broader contract may reuse that query behavior when testing upload/query
round trips, but `SPEC-069` remains the canonical source for the standalone
request and response parser shape. Optional cross-signing public key data stays
out of scope until a later cross-signing contract covers it.

## Key claim

Clients claim one-time or fallback keys with:

```text
POST /_matrix/client/v3/keys/claim
```

The request requires authentication and contains `one_time_keys`, a map from
user ID to device ID to requested key algorithm. This contract covers
`signed_curve25519`.

Servers must return each one-time key at most once. If no one-time key is
available for the requested device and a fallback key is available, the server
may return the fallback key. Returned keys must be under `one_time_keys` in the
response and must preserve the key object shape published by the device.

Unknown users or devices must be omitted from the successful response unless a
remote homeserver failure must be recorded in `failures`.

## Authentication and errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Malformed JSON objects, mismatched `user_id` or `device_id`, invalid algorithm
names, invalid key IDs, missing required key fields, non-object key payloads, or
invalid signature envelope shape must return Matrix `M_*` error envelopes
appropriate to the failure (`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, or
`M_INVALID_PARAM`).

Servers must not accept key uploads for a different user/device than the access
token represents. Servers must not leak private key material in success or
error responses.

Rate-limited endpoints may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix key endpoints must use Matrix `M_*` error envelopes, not Houra `code`
  envelopes.
- This contract stores and serves public key material and opaque signed key
  objects. It does not implement Olm/Megolm locally.
- This contract does not advertise to-device messaging, encrypted rooms, key
  backup, verification, cross-signing, secret storage, federation, or full
  Matrix v1.18 compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for device key, one-time key, or fallback key
  payload shapes.
