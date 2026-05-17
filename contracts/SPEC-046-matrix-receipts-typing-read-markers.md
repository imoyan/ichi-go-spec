# Matrix v1.18 / Client-Server API / typing, receipt, and read marker endpoints

Status: draft
Feature profile: sync
Contract type: endpoint
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / typing, receipt, and read marker endpoints
Repository anchor: SPEC-046 Matrix Receipts, Typing, and Read Markers
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server receipts, typing notifications, and read
markers endpoint family for Client-Server breadth.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
typing, receipt, and read marker behavior without changing existing
`/_houra/client/**` routes.

This endpoint family covers typing notification updates, receipt sends,
ephemeral receipt delivery through `/sync`, fully read marker updates,
read-marker receipt co-updates, and representative authorization and validation
errors. It does not define presence, filters, capabilities, push notification
rules, timeline relations, full thread relation traversal, unread-marker UI
policy, federation EDUs, E2EE, or unstable MSC behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#typing-notifications>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#receipts>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#read-and-unread-markers>
- Checked at: 2026-05-10T17:58:32+09:00
- Timezone: Asia/Tokyo

## Typing endpoint

Typing state is updated with:

```text
PUT /_matrix/client/v3/rooms/{roomId}/typing/{userId}
Authorization: Bearer token-1
```

The access token must be authorized for `{userId}`. The request body must
include `typing` as a boolean. When `typing` is `true`, `timeout` should be a
positive integer in milliseconds. When `typing` is `false`, `timeout` may be
omitted.

A successful update returns `200` with `{}`. Later `/sync` responses for other
members of the room should expose typing deltas under the joined room's
`ephemeral.events` as `m.typing` events with `content.user_ids`.

## Receipt endpoint

Receipts are sent with:

```text
POST /_matrix/client/v3/rooms/{roomId}/receipt/{receiptType}/{eventId}
Authorization: Bearer token-1
```

The `{receiptType}` path component must be a Matrix receipt type supported by
this contract: `m.read` or `m.read.private`. The `{eventId}` must identify an
event in `{roomId}` visible to the authenticated user.

The request body is a JSON object. It may include `thread_id`, either `main` or
the event ID of a thread root. A successful receipt update returns `200` with
`{}`.

Receipts delivered through `/sync` use `m.receipt` ephemeral events in the
joined room. The event content maps event IDs to receipt types to user IDs and
receipt metadata:

```json
{
  "$event:example.test": {
    "m.read": {
      "@alice:example.test": {
        "ts": 1710000001000,
        "thread_id": "main"
      }
    }
  }
}
```

`m.read.private` receipts must be visible only to the sending user.

## Read markers endpoint

Read markers are updated with:

```text
POST /_matrix/client/v3/rooms/{roomId}/read_markers
Authorization: Bearer token-1
```

The request body may include:

- `m.fully_read`: the event ID where the user's fully read marker is located.
- `m.read`: an event ID to update the public read receipt at the same time.
- `m.read.private`: an event ID to update the private read receipt at the same
  time.

A successful update returns `200` with `{}`. Updating `m.fully_read` must update
the room account data event with type `m.fully_read` and content:

```json
{
  "event_id": "$event:example.test"
}
```

Servers must prevent clients from directly modifying `m.fully_read` through the
room account data `PUT` endpoint from `SPEC-045`; clients must use
`/read_markers` instead. The `m.read` and `m.read.private` keys in a
`/read_markers` request have the same receipt effect as calling the receipt
endpoint directly.

Unread marker account data (`m.marked_unread`) is acknowledged as part of the
Matrix v1.18 read/unread marker module, but no dedicated UI policy or adapter
behavior is defined in this contract.

## Authentication and errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Requests where the access token is not authorized for `{userId}` or the target
room must return `403` with `M_FORBIDDEN`.

Malformed JSON objects, missing required typing fields, invalid `thread_id`
values, unknown receipt types, event IDs outside the target room, and direct
`m.fully_read` account data writes must return a Matrix `M_*` error envelope
appropriate to the failure (`M_BAD_JSON`, `M_NOT_JSON`, `M_MISSING_PARAM`,
`M_INVALID_PARAM`, or `M_FORBIDDEN`).

Rate-limited endpoints may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix typing, receipt, and read-marker endpoints must use Matrix `M_*` error
  envelopes, not Houra `code` envelopes.
- This contract does not advertise presence, filters, capabilities, push rules,
  unread-marker UI policy, federation EDU delivery, E2EE, or full Matrix v1.18
  compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for `m.receipt`, `m.typing`,
  `m.fully_read`, or receipt metadata validation.
