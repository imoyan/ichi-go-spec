# SPEC-033: Matrix Client-Server Registration

Status: draft
Feature profile: auth
Contract type: endpoint
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server registration endpoint family needed for
MVP-equivalent Matrix account creation: username availability, account
registration, user-interactive authentication responses, registration-token
validity checks, and Matrix registration error envelopes.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
behavior without changing existing `/_houra/client/**` registration routes.

Email and MSISDN validation token submission, guest registration, application
service user creation, refresh-token issuance, OAuth-aware registration
redirects, and fallback HTML are intentionally left for later Client-Server
compatibility contracts.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3register>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3registeravailable>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv1registermloginregistration_tokenvalidity>
- Checked at: 2026-05-10T09:40:00+09:00
- Timezone: Asia/Tokyo

## Username availability

```text
GET /_matrix/client/v3/register/available?username=charlie
```

The request does not require authentication.

Successful responses mean the username is valid and available at the time of
the request:

```json
{
  "available": true
}
```

Clients must not treat this response as a reservation. Servers may later reject
registration for the same username if the username becomes unavailable before
registration completes.

If the username is invalid, already in use, or exclusively claimed by an
application service namespace, servers must return `400` with a Matrix error
envelope using `M_INVALID_USERNAME`, `M_USER_IN_USE`, or `M_EXCLUSIVE`.

## Registration request

```text
POST /_matrix/client/v3/register
```

```json
{
  "username": "charlie",
  "password": "correct horse battery staple",
  "device_id": "DEVICE2",
  "initial_device_display_name": "Charlie phone",
  "auth": {
    "type": "m.login.dummy",
    "session": "reg-session-1"
  }
}
```

`username`, `password`, `device_id`, `initial_device_display_name`, and `auth`
are optional at the wire level. If `username` is omitted, a server may generate
the Matrix user ID localpart. If `device_id` is omitted, the server must return
a generated non-empty `device_id` unless `inhibit_login` is true.

Initial Houra Matrix compatibility covers `kind=user` registration only.
`kind=guest` is not advertised or required by this contract.

The returned `user_id` must be a Matrix user ID conforming to `SPEC-031`.
Clients must not assume that the returned `user_id` localpart exactly matches
the submitted `username`.

## User-interactive authentication response

Registration may require user-interactive authentication. In that case the
server returns `401` and an authentication response:

```json
{
  "completed": [],
  "flows": [
    {
      "stages": [
        "m.login.dummy"
      ]
    }
  ],
  "params": {},
  "session": "reg-session-1"
}
```

`flows` must be a non-empty array. Each flow must include non-empty `stages`.
If `session` is present, clients must send it back in the next `auth` object
for this registration attempt.

This contract permits `m.login.dummy` and `m.login.registration_token` as
registration authentication stages. `m.login.terms`, email identity, MSISDN
identity, SSO, and fallback flows require later contract coverage before they
are advertised as supported behavior.

## Registration response

```json
{
  "user_id": "@charlie:example.test",
  "access_token": "token-register",
  "device_id": "DEVICE2",
  "home_server": "example.test"
}
```

When `inhibit_login` is false or omitted, `access_token`, `device_id`, and
`user_id` must be non-empty strings. `home_server`, when present, is deprecated
by Matrix but may be emitted for compatibility; clients should derive the
server name from `user_id` when possible.

Clients must return token data to the host and must not persist bearer tokens
inside SDK core.

## Registration errors

Registration failures use Matrix error envelopes, not Houra `code` envelopes.

Representative error mappings:

- `400` with `M_INVALID_USERNAME` for invalid requested usernames.
- `400` with `M_USER_IN_USE` for unavailable requested usernames.
- `400` with `M_EXCLUSIVE` for application-service namespace conflicts.
- `403` with `M_FORBIDDEN` when registration is disabled or a requested
  account kind is not permitted.
- `429` with `M_LIMIT_EXCEEDED` and optional `retry_after_ms` when rate
  limited.

Servers must perform username availability checks before requiring
user-interactive authentication where the Matrix specification requires those
checks to happen first.

## Registration token validity

```text
GET /_matrix/client/v1/register/m.login.registration_token/validity?token=fBVFdqVE
```

The request does not require authentication.

Successful responses indicate whether the token is valid at the time of the
request:

```json
{
  "valid": true
}
```

Unrecognized or expired tokens return `200` with `valid: false`. If
registration is disabled, servers may return `403` with `M_FORBIDDEN`.

## Compatibility boundaries

- Existing `/_houra/client/register` behavior stays available.
- Matrix `/_matrix/client/*/register*` endpoints must use Matrix `M_*` error
  envelopes, not Houra `code` envelopes.
- Matrix registration support is additive and does not by itself widen
  `GET /_matrix/client/versions` advertisement beyond the evidence gate in
  `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only shared-core
  adoption is useful for registration response/UIA envelopes.
