# SPEC-047: Matrix Filters, Presence, and Capabilities

Status: draft
Feature profile: sync
Contract type: endpoint
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server filters, presence, and capabilities
endpoint family for Client-Server breadth.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
filter storage, presence status, and capabilities behavior without changing
existing `/_houra/client/**` routes.

This endpoint family covers filter create/read, presence set/get, presence
visibility through `/sync`, capabilities response shape, and representative
authorization errors. It does not define search, push rules, user directory,
room directory, presence privacy policy beyond Matrix-compatible errors,
filter-aware pagination completeness, E2EE, federation, or unstable MSC
behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#filtering>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#presence>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#capabilities-negotiation>
- Checked at: 2026-05-10T18:04:49+09:00
- Timezone: Asia/Tokyo

## Filter endpoints

Filters are stored per user:

```text
POST /_matrix/client/v3/user/{userId}/filter
GET /_matrix/client/v3/user/{userId}/filter/{filterId}
```

The access token must be authorized for `{userId}`. `POST` accepts a Matrix
filter object and returns `200` with a `filter_id`. The returned `filter_id`
must be an opaque string and must not start with `{`.

The representative filter object in this contract covers:

- `event_fields`
- `event_format`
- top-level `presence` event filtering
- `room.timeline` limits and event type filtering
- `room.ephemeral` event type filtering for `m.receipt` and `m.typing`
- `room.account_data` event type filtering

`GET` returns the stored filter object. Unknown filters return `404` with a
Matrix `M_*` error envelope.

This contract does not require complete filter execution semantics for every
endpoint. Implementations must still preserve the stored filter definition and
must not accept a filter response shape that cannot later be applied to `/sync`
or `/messages`.

## Presence endpoints

Presence status is accessed with:

```text
GET /_matrix/client/v3/presence/{userId}/status
PUT /_matrix/client/v3/presence/{userId}/status
```

Both endpoints require authentication. Clients may set only their own presence
state. The `presence` value must be one of `online`, `offline`, or
`unavailable`. `status_msg` may be included when setting presence.

A successful `PUT` returns `200` with `{}`. A successful `GET` returns a JSON
object containing at least `presence`, and may include `last_active_ago`,
`currently_active`, and `status_msg`.

Presence updates should be visible to interested clients through `/sync` under
top-level `presence.events` as `m.presence` events, subject to filters and
visibility policy.

## Capabilities endpoint

Capabilities are read with:

```text
GET /_matrix/client/v3/capabilities
```

The endpoint requires authentication and returns `200` with a top-level
`capabilities` object. Capability keys starting with `m.` are Matrix-defined.
Implementation-defined capabilities must use Java package naming convention.

The representative response in this contract includes:

- `m.room_versions` with default room version `12` and only the advertised
  implementation-evidenced subset from `SPEC-080`. The stable room-version
  registry from `SPEC-042` must not be copied into `available` by default.
- `m.profile_fields` for profile write support from `SPEC-045`.
- deprecated compatibility booleans `m.set_displayname` and
  `m.set_avatar_url` when profile fields allow those keys.
- `m.change_password` and `m.forget_forced_upon_leave` boolean capabilities.

Capabilities must not be used to advertise unstable or experimental features.
Unstable feature advertisement remains the responsibility of
`GET /_matrix/client/versions` and the evidence gate from `SPEC-030` and
`SPEC-031`.

## Authentication and errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Requests where the access token is not authorized for `{userId}` must return
`403` with `M_FORBIDDEN`.

Malformed filter or presence request bodies must return a Matrix `M_*` error
envelope appropriate to the failure (`M_BAD_JSON`, `M_NOT_JSON`,
`M_MISSING_PARAM`, or `M_INVALID_PARAM`).

Unknown filters or presence information that the server cannot disclose must
return `404` or `403` with Matrix `M_*` error envelopes.

Rate-limited endpoints may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix filters, presence, and capabilities endpoints must use Matrix `M_*`
  error envelopes, not Houra `code` envelopes.
- This contract does not advertise search, push rules, user directory, room
  directory, invites, admin controls, E2EE, federation, or full Matrix v1.18
  compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for filter objects, presence events, or
  capabilities response validation.
