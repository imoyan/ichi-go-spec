# SPEC-049: Matrix Moderation, Reporting, and Admin Controls

Status: draft
Feature profile: rooms
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server kick, ban, unban, redaction, reporting,
and account moderation endpoint family for Client-Server breadth.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
moderation, reporting, and server administration behavior without changing
existing `/_houra/client/**` routes.

This endpoint family builds on `SPEC-035` room membership, `SPEC-043`
representative auth vectors, `SPEC-047` capabilities, and `SPEC-048` invites.
It covers kick, ban, unban, redaction by transaction ID, room/event/user
reporting, account moderation capability advertisement, server-local account
lock/suspend read/write, and representative permission failures. It does not
define policy server signing, redaction algorithm completeness, abuse report
delivery workflow, moderation queue UI, appeal workflows, identity service
moderation, federation enforcement, or unstable MSC behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3roomsroomidkick>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3roomsroomidban>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3roomsroomidunban>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3roomsroomidredacteventidtxnid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#reporting-content>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#server-administration>
- Checked at: 2026-05-10T18:59:32+09:00
- Timezone: Asia/Tokyo

## Room moderation

Room membership moderation uses:

```text
POST /_matrix/client/v3/rooms/{roomId}/kick
POST /_matrix/client/v3/rooms/{roomId}/ban
POST /_matrix/client/v3/rooms/{roomId}/unban
```

All three endpoints require authentication and a JSON object body containing
`user_id`, the target Matrix user ID. `reason` may be included and must be
carried to the resulting membership event where Matrix defines it.

The caller must be in the room and have the required power level. `kick`,
`ban`, and `unban` update the target user's `m.room.member` state with
`leave`, `ban`, and `leave` respectively. Banning a joined user also removes
them from the room. A banned user cannot join or be invited until unbanned.

Successful requests return `200` with `{}`.

## Redactions

Dedicated redactions use:

```text
PUT /_matrix/client/v3/rooms/{roomId}/redact/{eventId}/{txnId}
```

The request body is a JSON object and may include `reason`. The transaction ID
is used for idempotency. Successful requests return `200` with an `event_id`
for the generated redaction event.

Users may redact their own events when authorized by the `m.room.redaction`
event power level. Users may redact other users' events when they also meet the
room's `redact` power level. Server administrators may redact events sent by
users on their server.

Homeservers must also allow `m.room.redaction` events through the generic
`PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}` path from
`SPEC-036`; this contract's representative vector covers only the dedicated
redaction endpoint.

## Reporting

Reporting endpoints:

```text
POST /_matrix/client/v3/rooms/{roomId}/report
POST /_matrix/client/v3/rooms/{roomId}/report/{eventId}
POST /_matrix/client/v3/users/{userId}/report
```

All reporting endpoints require authentication. Room reports require `reason`.
Event and user reports may include `reason`. Matrix v1.18 removed the
historical `score` request parameter from the event report endpoint; this
contract must not require or emit `score` in event report vectors.

Successful reports return `200` with `{}`. Implementations may return `200`
even when a reported room, event, or user does not exist, and may add random
delay to avoid existence enumeration.

## Account moderation and capabilities

The admin endpoints introduced into the stable Client-Server API are:

```text
GET /_matrix/client/v1/admin/lock/{userId}
PUT /_matrix/client/v1/admin/lock/{userId}
GET /_matrix/client/v1/admin/suspend/{userId}
PUT /_matrix/client/v1/admin/suspend/{userId}
```

The calling user must be a server administrator. The target user must be local
to the homeserver. Servers must check caller authorization before target account
lookup to avoid user enumeration.

Lock endpoints use the `locked` boolean. Suspend endpoints use the `suspended`
boolean. Successful `GET` responses return the current boolean state.
Successful `PUT` responses return `200` with `{}`.

Server capabilities from `SPEC-047` must include `m.account_moderation` when
the authenticated user can use account moderation endpoints:

```json
{
  "m.account_moderation": {
    "lock": true,
    "suspend": true
  }
}
```

When an account is locked, general Client-Server APIs must return `401` with
`M_USER_LOCKED` and `soft_logout: true`, except for Matrix-defined logout
exceptions. When an account is suspended, forbidden actions must return `403`
with `M_USER_SUSPENDED`. The representative vectors define endpoint control
and capability advertisement; full locked/suspended runtime policy is an
implementation adoption gate.

## Authentication and errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Room moderation, redaction, reporting, and admin requests that fail
authorization must return a Matrix `M_*` error envelope. Representative
permission failures use `403` with `M_FORBIDDEN`.

Malformed request bodies, invalid user IDs, invalid event IDs, and invalid
admin target users must return Matrix `M_*` error envelopes appropriate to the
failure (`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`, `M_INVALID_PARAM`,
`M_NOT_FOUND`, or `M_BAD_STATE`).

Rate-limited endpoints may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix moderation, reporting, and admin endpoints must use Matrix `M_*` error
  envelopes, not Houra `code` envelopes.
- This contract does not advertise policy server signing, moderation queue UI,
  appeal flows, federation enforcement, E2EE, or full Matrix v1.18 compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for membership moderation bodies, redaction
  responses, report bodies, account moderation capability, or admin status
  responses.
