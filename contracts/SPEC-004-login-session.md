# SPEC-004: Login / Session

Status: draft
Feature profile: auth
Canonical: yes

## Purpose

Define the MVP password login and bearer-token session model.

## Password login request

```text
POST /_chawan/client/login
```

```json
{
  "type": "chawan.login.password",
  "identifier": {
    "type": "chawan.id.user",
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

## Whoami request

```text
GET /_chawan/client/account/whoami
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
POST /_chawan/client/logout
Authorization: Bearer token-1
```

The response body is not significant for clients.

## Client expectations

- Clients must attach tokens with `Authorization: Bearer`.
- Clients must not use `access_token` query parameters.
- Clients must return login/session data to the host.
- Clients must not persist tokens in SDK core.
