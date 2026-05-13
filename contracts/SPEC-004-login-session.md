# SPEC-004: Login / Session

Status: draft
Feature profile: auth
Canonical: yes

## Purpose

Define the MVP password login and bearer-token session model.

## Password login request

```text
POST /_houra/client/login
```

```json
{
  "type": "houra.login.password",
  "identifier": {
    "type": "houra.id.user",
    "user": "alice"
  },
  "password": "correct horse battery staple",
  "device_id": "DEVICE1",
  "initial_device_display_name": "Alice phone"
}
```

`device_id` and `initial_device_display_name` are optional.

## Password login response

```json
{
  "user_id": "@alice:example.test",
  "access_token": "token-1",
  "device_id": "DEVICE1"
}
```

`device_id` is optional.

## Account registration request

```text
POST /_houra/client/register
```

```json
{
  "username": "charlie",
  "password": "correct horse battery staple",
  "device_id": "DEVICE2",
  "initial_device_display_name": "Charlie phone"
}
```

`device_id` and `initial_device_display_name` are optional.

`username` is the unqualified localpart for the new user. The MVP localpart
shape is 1 to 64 characters from `a-z`, `0-9`, `.`, `_`, `=`, and `-`.
`password` must be a non-empty string.

If registration succeeds, the server creates the user, creates or records the
device, and returns a login session response with the same shape as password
login.

## Account registration response

```json
{
  "user_id": "@charlie:example.test",
  "access_token": "token-register",
  "device_id": "DEVICE2"
}
```

If the localpart is already registered, servers must return `409` with
`HOURA_CONFLICT`. If the localpart or password is invalid, servers must return
`400` with `HOURA_BAD_REQUEST`.

## Whoami request

```text
GET /_houra/client/account/whoami
Authorization: Bearer token-1
```

## Whoami response

```json
{
  "user_id": "@alice:example.test",
  "device_id": "DEVICE1"
}
```

`device_id` is optional.

## Logout request

```text
POST /_houra/client/logout
Authorization: Bearer token-1
```

The response body is not significant for clients. A successful logout
invalidates the bearer token presented on that logout request. After logout,
using the same token for `/_houra/client/account/whoami` or any other
authenticated `/_houra/client/**` request must fail with `401` and
`HOURA_UNAUTHORIZED`.

## Client expectations

- Clients must attach tokens with `Authorization: Bearer`.
- Clients must not use `access_token` query parameters.
- Clients must return login/session data to the host.
- Clients must not persist tokens in SDK core.
- Clients may call registration before login when the host wants to create a
  new local account.
