# Matrix v1.18 / Client-Server API / device management and session lifecycle endpoints

Status: draft
Feature profile: auth
Contract type: endpoint
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / device management and session lifecycle endpoints
Repository anchor: SPEC-034 Matrix Client-Server Devices and Sessions
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server device management surface needed after
`SPEC-032` auth/session and `SPEC-033` registration: list devices, inspect one
device, update device metadata, delete one device, delete multiple devices, and
prove device deletion invalidates associated access tokens.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
device behavior without changing existing `/_houra/client/**` auth/session
routes.

Application-service device creation through `PUT /devices/{deviceId}`,
cross-signing keys, device list federation, E2EE key upload/query/claim,
refresh tokens, and fallback HTML are intentionally left for later contracts.
OAuth account-management redirects and post-return reconciliation are covered by
`SPEC-068`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3devices>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3devicesdeviceid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3devicesdeviceid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#delete_matrixclientv3devicesdeviceid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3delete_devices>
- Checked at: 2026-05-10T10:32:23+09:00
- Timezone: Asia/Tokyo

## Device model

A Matrix device record contains a required `device_id` and optional device
metadata:

```json
{
  "device_id": "DEVICE1",
  "display_name": "Alice phone",
  "last_seen_ip": "203.0.113.10",
  "last_seen_ts": 1710000000000
}
```

`device_id` must be a non-empty string. `display_name`, when present, must be a
string. `last_seen_ip`, when present, must be a string. `last_seen_ts`, when
present, must be a non-negative integer timestamp in milliseconds.

Servers may omit `last_seen_ip` and `last_seen_ts` when the information is not
available or is intentionally withheld.

Device identifiers are scoped to the authenticated user. A `device_id` that
belongs to another user must be treated the same as a missing device for the
current user; servers must return `404` with `M_NOT_FOUND` and must not read,
update, delete, or invalidate the other user's device or associated access
tokens.

## List devices

```text
GET /_matrix/client/v3/devices
Authorization: Bearer token-1
```

The response lists devices for the authenticated user:

```json
{
  "devices": [
    {
      "device_id": "DEVICE1",
      "display_name": "Alice phone",
      "last_seen_ip": "203.0.113.10",
      "last_seen_ts": 1710000000000
    }
  ]
}
```

`devices` must be present and may be empty. A bearer token identifies the
current user; clients must not pass access tokens in query parameters.

## Get one device

```text
GET /_matrix/client/v3/devices/DEVICE1
Authorization: Bearer token-1
```

Successful responses return a single device object. If the authenticated user
has no matching device, servers must return `404` with a Matrix error envelope:

```json
{
  "errcode": "M_NOT_FOUND",
  "error": "Device not found."
}
```

## Update device metadata

```text
PUT /_matrix/client/v3/devices/DEVICE1
Authorization: Bearer token-1
```

```json
{
  "display_name": "Alice laptop"
}
```

Regular clients may update existing device metadata only. A successful update
returns `200` with an empty JSON object. If the authenticated user has no
matching device, servers must return `404` with `M_NOT_FOUND`.

Although Matrix v1.18 allows application services to create devices with this
endpoint, that behavior is outside this contract until an Application Service
contract covers it. Product clients must not rely on `201` creation behavior.

## Delete one device

```text
DELETE /_matrix/client/v3/devices/DEVICE2
Authorization: Bearer token-1
```

Device deletion uses the Matrix user-interactive authentication API unless a
later contract covers an exempt actor such as an application service. If
additional authentication is required, servers return `401`:

```json
{
  "completed": [],
  "flows": [
    {
      "stages": [
        "m.login.password"
      ]
    }
  ],
  "params": {},
  "session": "device-del-session-1"
}
```

The follow-up request includes `auth` and returns `200` with an empty JSON
object when the device is removed or was already removed:

```json
{
  "auth": {
    "type": "m.login.password",
    "session": "device-del-session-1",
    "identifier": {
      "type": "m.id.user",
      "user": "alice"
    },
    "password": "correct horse battery staple"
  }
}
```

Deleting a device must invalidate any access token associated with that device.
After deletion, using that token must fail with `M_UNKNOWN_TOKEN`.

Deleting a device owned by another user must return `404` with `M_NOT_FOUND`.
Servers must not delete the other user's device and must not invalidate the
other user's access token.

OAuth-aware clients must not use this endpoint when the server supports the
Matrix OAuth 2.0 API; they must use the account-management URL flow defined by
`SPEC-068`.

## Delete multiple devices

```text
POST /_matrix/client/v3/delete_devices
Authorization: Bearer token-1
```

```json
{
  "devices": [
    "DEVICE2",
    "DEVICE3"
  ],
  "auth": {
    "type": "m.login.password",
    "session": "device-del-session-1",
    "identifier": {
      "type": "m.id.user",
      "user": "alice"
    },
    "password": "correct horse battery staple"
  }
}
```

`devices` must be present and contain non-empty device IDs. User-interactive
authentication semantics match single-device deletion. A successful deletion
returns `200` with an empty JSON object.

If any requested device identifier belongs to another user, the server must
fail the request with `404` and `M_NOT_FOUND` for the authenticated user scope.
The other user's device and access token must remain valid.

## Authentication errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid or
deleted bearer tokens must return `401` with `M_UNKNOWN_TOKEN`. Error envelopes
must follow `SPEC-031`.

## Compatibility boundaries

- Existing `/_houra/client/**` auth/session behavior stays available.
- Matrix device endpoints must use Matrix `M_*` error envelopes, not Houra
  `code` envelopes.
- Matrix device support is additive and does not by itself widen
  `GET /_matrix/client/versions` advertisement beyond the evidence gate in
  `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only shared-core
  adoption is useful for device and UIA response envelopes.
