# SPEC-090: Matrix Client-Server Relations, Threads, and Reactions

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the focused Client-Server relations, thread summary, reaction, edit, and
reply parser boundary promoted from the `SPEC-073`
`room-lifecycle-state-relations-user-visible-breadth` lane.

This contract lets implementation repositories adopt shared request descriptors
and public response parsers for user-visible relationship shapes without turning
parser evidence into a full Matrix Client-Server API, timeline ordering, fanout,
or room-version authorization support claim.

## Scope

This contract covers only parser and request-descriptor shape for:

```text
GET /_matrix/client/v1/rooms/{roomId}/relations/{eventId}
GET /_matrix/client/v1/rooms/{roomId}/relations/{eventId}/{relType}
GET /_matrix/client/v1/rooms/{roomId}/relations/{eventId}/{relType}/{eventType}
GET /_matrix/client/v1/rooms/{roomId}/threads
```

Only these public envelopes are adopted:

- relation event chunks containing `ClientEvent` envelopes;
- `m.annotation` reaction content using `m.relates_to`;
- thread summary data under `unsigned.m.relations.m.thread`;
- edit content using `m.replace` and `m.new_content`;
- reply content using `m.in_reply_to`;
- Matrix error envelopes for membership variants that remain unsupported by the
  parser-only surface.

This contract does not define event persistence, server-side aggregation
correctness, duplicate reaction rejection, ordering, recursive traversal depth,
thread fanout, redaction effects, authorization, knocks, restricted joins,
storage, federation, encryption, or a widened Matrix `/versions` advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/>
- Checked at: 2026-05-16T01:10:00+09:00
- Timezone: Asia/Tokyo

## Adopted Descriptors

Implementations may expose request descriptors for adopted relation lookup
surfaces. Descriptors must keep route expansion typed and bounded:

```json
{
  "method": "GET",
  "path": "/_matrix/client/v1/rooms/{roomId}/relations/{eventId}/{relType}/{eventType}",
  "path_params": {
    "roomId": "!room:example.test",
    "eventId": "$parent:example.test",
    "relType": "m.annotation",
    "eventType": "m.reaction"
  },
  "query_params": {
    "limit": 20
  },
  "requires_auth": true,
  "adopted_runtime_behavior": true,
  "response_parser": "relation_chunk"
}
```

Thread listing may be described only as a parser boundary over the response
shape. The descriptor does not claim server ordering or unread-count correctness.

## Adopted Response Envelopes

Relation chunk parsers require a top-level `chunk` array of `ClientEvent`
envelopes. Optional pagination tokens such as `next_batch` and `prev_batch` may
be preserved as strings.

Reaction events are `m.reaction` events whose content contains
`m.relates_to.rel_type = m.annotation`, a target `event_id`, and a string `key`.
The parser may preserve the key as opaque text; emoji normalization and duplicate
reaction policy are outside this boundary.

Thread summaries are parsed from
`unsigned.m.relations.m.thread`. The adopted parser boundary requires:

```json
{
  "count": 2,
  "current_user_participated": true,
  "latest_event": {
    "content": {
      "body": "Thread reply",
      "msgtype": "m.text"
    },
    "event_id": "$thread-reply:example.test",
    "origin_server_ts": 1715754700000,
    "room_id": "!room:example.test",
    "sender": "@bob:example.test",
    "type": "m.room.message"
  }
}
```

Edit relation parsers require `m.relates_to.rel_type = m.replace`, a target
`event_id`, and an object `m.new_content`. Reply relation parsers require
`m.relates_to.m.in_reply_to.event_id`.

Membership variants such as knocks and restricted joins are not adopted as
runtime behavior by this contract. Implementations may parse Matrix error
envelopes for unsupported variants, but must not infer authorization or room
version behavior from this parser evidence.

## Fail-Closed Behavior

Implementations must fail closed:

- do not advertise full Client-Server API support from these descriptors or
  parsers;
- do not widen `GET /_matrix/client/versions`;
- reject malformed relation chunks missing required `ClientEvent` fields;
- reject reaction content missing `m.relates_to.event_id`, `rel_type`, or `key`;
- reject thread summaries with negative counts or malformed `latest_event`;
- reject edit relation content missing `m.new_content`;
- reject reply relation content missing `m.in_reply_to.event_id`;
- keep knock and restricted-join runtime behavior unclaimed unless later
  room-version and authorization contracts adopt it.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#120` may add parser-only helper coverage for the adopted
  descriptors and response envelopes.
- Server implementation work requires a separate adoption issue before runtime
  relation lookup, aggregation, thread ordering, knock, or restricted-join
  behavior is added.
- Client work is needed only if a public SDK or UI surface intentionally exposes
  these descriptors or parsed envelopes.
- Release evidence must keep `advertisement_allowed=false` for Client-Server API
  until the broader `SPEC-073` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-036` remains the send-event and messages pagination MVP contract.
- `SPEC-037` remains the `/sync` MVP contract.
- `SPEC-046` remains the receipts, typing, and read-marker parser contract.
- `SPEC-073` remains the Client-Server full-breadth gap inventory.
- Passing this contract does not claim full Client-Server support, relationship
  traversal correctness, reaction aggregation correctness, thread ordering,
  knock/restricted-join authorization, or Matrix v1.18 full compliance.
