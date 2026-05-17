# SPEC-036: Matrix Client-Server Send Event and Messages MVP

Status: draft
Feature profile: messaging
Contract type: endpoint
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server event send and room messages surface
closest to the existing Houra Product MVP text-message and timeline flow.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
message behavior without changing existing `/_houra/client/**` messaging or
timeline routes.

This is an MVP-equivalent messaging contract. It covers sending
`m.room.message` text events and reading room history through the Matrix
`/messages` pagination response shape. It does not define Matrix event DAG
persistence, event authorization, relation aggregation, redactions, search,
threading, receipts, read markers, typing, encrypted events, or room-version
state resolution.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#put_matrixclientv3roomsroomidsendeventtypetxnid>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3roomsroomidmessages>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroommessage-msgtypes>
- Checked at: 2026-05-10T11:48:59+09:00
- Timezone: Asia/Tokyo

## Matrix event identifiers and transaction identifiers

Room IDs, event IDs, user IDs, event types, and timestamps follow the Matrix
common rules in `SPEC-031`. Client event response fields follow the Matrix
client event shape introduced by `SPEC-035`.

`txnId` is a client-generated transaction identifier scoped to the same access
token. Repeating the same `PUT` with the same `roomId`, `eventType`, and `txnId`
must be idempotent and return the same `event_id` for the same accepted send.
Servers must not require clients to put access tokens in query parameters.

## Send text message event

```text
PUT /_matrix/client/v3/rooms/!room:example.test/send/m.room.message/txn-1
Authorization: Bearer token-1
```

```json
{
  "msgtype": "m.text",
  "body": "Hello Matrix"
}
```

The MVP request body covers `m.room.message` with `msgtype: "m.text"` and a
plain string `body`. The request body is the event content object. Additional
Matrix message content such as formatted HTML, media messages, relations,
mentions, replies, edits, and encrypted message payloads are outside this
contract until later endpoint-family contracts add vectors.

Successful responses return the sent event ID:

```json
{
  "event_id": "$event1:example.test"
}
```

Malformed content must return a Matrix error envelope. This contract uses
`M_BAD_JSON` for representative malformed `m.room.message` content.

## Messages pagination

```text
GET /_matrix/client/v3/rooms/!room:example.test/messages?from=t1&dir=b&limit=10
Authorization: Bearer token-1
```

Successful responses return a Matrix pagination chunk:

```json
{
  "chunk": [
    {
      "event_id": "$event1:example.test",
      "room_id": "!room:example.test",
      "sender": "@alice:example.test",
      "origin_server_ts": 1710000000000,
      "type": "m.room.message",
      "content": {
        "msgtype": "m.text",
        "body": "Hello Matrix"
      }
    }
  ],
  "start": "t1",
  "end": "t0"
}
```

`dir` is required and must be `b` or `f`. `from` is a pagination token obtained
from `/sync` or from a previous `/messages` response. `limit`, when present,
must be a positive integer. `chunk` must be an array of Matrix client events.
`start` must be present. `end` must be present when another page can be
requested from the end of the returned chunk; it may be omitted when no further
events are available in the requested direction.

The MVP vectors cover backward pagination. Forward pagination, filters, lazy
member loading, visibility across leave/ban, event context, and sync room
sections are outside this contract.

## Authentication and room errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

If a room cannot be found or the user cannot learn about it, servers must return
`404` with `M_NOT_FOUND`. If an authenticated user is not allowed to send to a
room or read its messages, servers must return `403` with `M_FORBIDDEN`.

Invalid pagination arguments or malformed event content must return `400` with a
Matrix error envelope.

## Compatibility boundaries

- Existing `/_houra/client/rooms/**/messages` and timeline behavior stays
  available.
- Matrix send and messages endpoints must use Matrix `M_*` error envelopes, not
  Houra `code` envelopes.
- This contract does not advertise room-version auth, event DAG correctness,
  state resolution, relation aggregation, redaction behavior, or encrypted-room
  messaging support.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only shared-core
  adoption is useful for Matrix event ID response, client event, or messages
  pagination response parsing.
