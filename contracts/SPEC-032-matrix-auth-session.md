# Matrix v1.18 / Client-Server API / login, logout, and whoami endpoints

Status: draft
Feature profile: auth
Contract type: endpoint
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / login, logout, and whoami endpoints
Repository anchor: SPEC-032 Matrix Client-Server Auth Session
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server auth/session endpoint family that is
closest to the existing Houra Product MVP login lifecycle: login flow discovery,
password login, account ownership lookup, and logout.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
behavior without changing existing `/_houra/client/**` routes.

Registration, refresh tokens, application service login, login fallback HTML,
device management, and `logout/all` are intentionally left for later
Client-Server compatibility contracts. OAuth-aware account-management metadata
and redirects are covered by `SPEC-068`.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3login>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3login>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3accountwhoami>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3logout>
- Checked at: 2026-05-10T08:56:54+09:00
- Timezone: Asia/Tokyo

## Login flow discovery

```text
GET /_matrix/client/v3/login
```

The request does not require authentication and has no request body.

Initial Matrix compatibility support advertises only password login:

```json
{
  "flows": [
    {
      "type": "m.login.password"
    }
  ]
}
```

Servers must not advertise `m.login.token`, OAuth, application service login,
or fallback login support until those behaviors have contract and vector
coverage.

## Password login

```text
POST /_matrix/client/v3/login
```

```json
{
  "type": "m.login.password",
  "identifier": {
    "type": "m.id.user",
    "user": "alice"
  },
  "password": "correct horse battery staple",
  "device_id": "DEVICE1",
  "initial_device_display_name": "Alice phone"
}
```

`device_id` and `initial_device_display_name` are optional. If `device_id` is
omitted, the server must return a non-empty generated `device_id`.

Initial support accepts the `m.id.user` identifier type. The `user` value may
be an unqualified localpart or a Matrix user ID. If the server returns a
`user_id`, it must be a Matrix user ID conforming to `SPEC-031`.

## Password login response

```json
{
  "user_id": "@alice:example.test",
  "access_token": "token-1",
  "device_id": "DEVICE1",
  "home_server": "example.test"
}
```

`access_token`, `device_id`, and `user_id` must be non-empty strings.
`home_server`, when present, must identify the local homeserver name.

Clients must return token data to the host and must not persist bearer tokens
inside SDK core.

## Password login failure

Failed password login must use a Matrix error envelope. Invalid credentials
return `403` with `M_FORBIDDEN`.

```json
{
  "errcode": "M_FORBIDDEN",
  "error": "Invalid login credentials."
}
```

Clients must not treat Houra `HOURA_UNAUTHORIZED` as a Matrix auth error.

## Whoami

```text
GET /_matrix/client/v3/account/whoami
Authorization: Bearer token-1
```

Successful responses identify the user that owns the access token:

```json
{
  "user_id": "@alice:example.test",
  "device_id": "DEVICE1",
  "is_guest": false
}
```

`user_id` is required. `device_id` is required when the token is associated with
a device. `is_guest`, when absent, is treated as false.

Invalid or missing bearer tokens must return Matrix `M_UNKNOWN_TOKEN` or
`M_MISSING_TOKEN` errors as defined by `SPEC-031`.

## Logout

```text
POST /_matrix/client/v3/logout
Authorization: Bearer token-1
```

The request has no body. A successful logout invalidates the access token used
for the request and returns:

```json
{}
```

After logout, using the same token for `/_matrix/client/v3/account/whoami` must
fail with a Matrix auth error.

## Compatibility boundaries

- Existing `/_houra/client/login`, `/_houra/client/account/whoami`, and
  `/_houra/client/logout` behavior stays available.
- Matrix `/_matrix/client/v3/*` auth endpoints must use Matrix `M_*` error
  envelopes, not Houra `code` envelopes.
- Matrix route support is additive and does not by itself widen
  `GET /_matrix/client/versions` advertisement beyond the evidence gate in
  `SPEC-030` and `SPEC-031`.
