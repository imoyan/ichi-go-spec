# SPEC-069: Matrix Device Key Query

Status: draft
Feature profile: auth
Canonical: yes

## Purpose

Define the first narrow Matrix v1.18 Client-Server device-key surface after
`SPEC-034`: `POST /_matrix/client/v3/keys/query`.

This contract is intentionally smaller than the full key endpoint family. It
lets Dart and other clients parse public device-key responses before Houra
adopts key upload, one-time key claim, fallback key replacement, to-device
delivery, or local encrypted-room behavior.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds only:

- authenticated `POST /_matrix/client/v3/keys/query` requests;
- request shape for selecting all devices or named devices for a user;
- successful response parsing for public device key objects;
- omission behavior for unknown users or devices;
- representative Matrix `M_*` authentication and request-shape errors.

It does not define `/_matrix/client/v3/keys/upload`,
`/_matrix/client/v3/keys/claim`, cross-signing publication, signature upload,
device signing upload, to-device delivery, one-time key consumption, fallback
key replacement, private key storage, Olm/Megolm implementation, encrypted room
send/receive, key backup, verification, federation key queries, or local crypto
adapter APIs.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3keysquery>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#device-keys>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#end-to-end-encryption>
- Checked at: 2026-05-11T13:11:42+09:00
- Timezone: Asia/Tokyo

## Endpoint

```text
POST /_matrix/client/v3/keys/query
Authorization: Bearer token-bob-device1
```

The request body must include `device_keys`, a map from Matrix user ID to an
array of device IDs:

```json
{
  "device_keys": {
    "@alice:example.test": [
      "DEVICE1"
    ]
  },
  "timeout": 10000
}
```

An empty device ID array requests all known devices for that user:

```json
{
  "device_keys": {
    "@alice:example.test": []
  }
}
```

`timeout`, when present, is a non-negative integer in milliseconds for remote
key queries. Product clients should use the Matrix-recommended 10000 ms default
when they need a concrete timeout. `token`, when present after a device-list
update from `/sync`, is a sync token and must be treated as an opaque string.

Clients must not pass access tokens in query parameters.

## Response

Successful responses return `200`:

```json
{
  "failures": {},
  "device_keys": {
    "@alice:example.test": {
      "DEVICE1": {
        "user_id": "@alice:example.test",
        "device_id": "DEVICE1",
        "algorithms": [
          "m.olm.v1.curve25519-aes-sha2",
          "m.megolm.v1.aes-sha2"
        ],
        "keys": {
          "curve25519:DEVICE1": "curve25519-public-device1",
          "ed25519:DEVICE1": "ed25519-public-device1"
        },
        "signatures": {
          "@alice:example.test": {
            "ed25519:DEVICE1": "signature-device1"
          }
        },
        "unsigned": {
          "device_display_name": "Alice phone"
        }
      }
    }
  }
}
```

`failures` must be present and is an object. A local server with no remote
failure evidence returns `{}`. Remote homeserver failures, when supported, are
keyed by homeserver name.

`device_keys` must be present and is a map from user ID to device ID to device
key object. Unknown users or unknown devices are omitted from `device_keys`;
they are not represented by `null`, empty placeholder device objects, or Matrix
error envelopes in an otherwise successful query.

## Device key object

A device key object must include:

- `user_id`: the Matrix user ID the key belongs to;
- `device_id`: the device ID the key belongs to;
- `algorithms`: an array of supported encryption algorithm identifiers;
- `keys`: a map of public identity keys keyed as `<algorithm>:<device_id>`;
- `signatures`: a map of signatures over the device key object.

For the first client parser boundary, vectors cover:

- `curve25519:{deviceId}`;
- `ed25519:{deviceId}`;
- `m.olm.v1.curve25519-aes-sha2`;
- `m.megolm.v1.aes-sha2`;
- `signatures.{userId}.ed25519:{deviceId}`.

Clients must preserve unknown properties such as `unsigned` when their data
model supports round-tripping, but they must not require `unsigned` to be
present.

This contract validates public payload shape only. It does not require clients
or servers to verify cryptographic signatures locally; that belongs to the
maintained crypto adapter boundary in `SPEC-050`.

## Authentication and errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Malformed JSON objects, missing `device_keys`, non-object `device_keys`,
non-array device ID selections, non-string device IDs, non-integer `timeout`,
or non-string `token` must return a Matrix `M_*` error envelope appropriate to
the failure (`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, or
`M_INVALID_PARAM`).

Malformed request vectors cover each of those request-shape failures so
implementations can fail closed before key lookup.

Servers must not return private key material in success or error responses.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix key query responses must use Matrix `M_*` error envelopes, not Houra
  `code` envelopes.
- This contract may be adopted by a Dart client as a parser/request-descriptor
  contract without selecting a crypto stack.
- This contract does not implement or advertise E2EE support by itself.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only shared-core
  adoption is useful for device-key query request/response shapes.
