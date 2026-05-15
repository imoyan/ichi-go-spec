# SPEC-085: Matrix Client-Server Event Retrieval and Membership History

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the focused Client-Server event retrieval, membership history, and
deprecated compatibility boundary promoted from the `SPEC-073`
`event-retrieval-membership-history-deprecated-compatibility` lane.

This contract lets implementation repositories adopt shared request
descriptors and response parsers for historical event lookup and membership
listing without turning representative parser evidence into a full Matrix
Client-Server API support claim.

## Scope

This contract covers only parser and request-descriptor shape for:

```text
GET /_matrix/client/v3/events
GET /_matrix/client/v3/events/{eventId}
GET /_matrix/client/v3/initialSync
GET /_matrix/client/v3/rooms/{roomId}/initialSync
GET /_matrix/client/v3/rooms/{roomId}/event/{eventId}
GET /_matrix/client/v3/rooms/{roomId}/joined_members
GET /_matrix/client/v3/rooms/{roomId}/members
GET /_matrix/client/v1/rooms/{roomId}/timestamp_to_event
```

Only these public envelopes are adopted:

- `ClientEvent` response parsing for a single room event;
- joined-member maps with `display_name` and `avatar_url`;
- membership-event chunks for historical members;
- timestamp-to-event response parsing;
- explicit unsupported descriptors for deprecated compatibility endpoints.

This contract does not define event persistence, history visibility,
authorization, pagination ordering, lazy-loading semantics, sync behavior,
server route implementation, storage, federation, encryption, or a widened
Matrix `/versions` advertisement.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/>
- Checked at: 2026-05-16T01:10:00+09:00
- Timezone: Asia/Tokyo

## Adopted descriptors

Implementations may expose request descriptors for the adopted lookup and
membership surfaces. Descriptors must keep route expansion typed and bounded:

```json
{
  "method": "GET",
  "path": "/_matrix/client/v3/rooms/{roomId}/event/{eventId}",
  "path_params": {
    "roomId": "!room:example.test",
    "eventId": "$event:example.test"
  },
  "requires_auth": true,
  "adopted_runtime_behavior": true,
  "response_parser": "client_event"
}
```

Deprecated compatibility endpoints may be described only as explicit
unsupported surfaces. They must not be treated as covered by MVP `/sync` or
messages pagination evidence.

## Adopted response envelopes

`GET /_matrix/client/v3/rooms/{roomId}/event/{eventId}` returns a `ClientEvent`
envelope. The parser boundary requires at least:

```json
{
  "content": {
    "body": "Hello",
    "msgtype": "m.text"
  },
  "event_id": "$event:example.test",
  "origin_server_ts": 1715754600000,
  "room_id": "!room:example.test",
  "sender": "@alice:example.test",
  "type": "m.room.message"
}
```

State events may include `state_key`. `unsigned` content may be preserved as
opaque JSON but must not be required for parser success.

`GET /_matrix/client/v3/rooms/{roomId}/joined_members` parses a response with a
top-level `joined` object keyed by Matrix user ID. Each member object may
include `display_name` and `avatar_url`.

`GET /_matrix/client/v3/rooms/{roomId}/members` parses a response with a
top-level `chunk` array of membership `ClientEvent` envelopes. Query descriptor
support is limited to typed `at`, `membership`, and `not_membership`
parameters. Membership values outside the adopted set must fail closed.

`GET /_matrix/client/v1/rooms/{roomId}/timestamp_to_event` parses `event_id`
and `origin_server_ts`. Direction, visibility, and room-version event ordering
semantics are intentionally outside this parser boundary.

## Fail-closed behavior

Implementations must fail closed:

- do not advertise full Client-Server API support from these descriptors or
  parsers;
- do not widen `GET /_matrix/client/versions`;
- do not infer historical visibility or authorization correctness from parser
  shape;
- reject malformed Matrix event envelopes missing required `ClientEvent`
  fields;
- reject malformed joined-member maps and membership chunks;
- keep deprecated `/events` and `/initialSync` compatibility endpoints
  explicitly unsupported unless a later contract adopts runtime behavior.

## Adoption decision checklist

After this contract merges:

- `houra-labs#119` may add parser-only helper coverage for the adopted
  descriptors and response envelopes.
- Server implementation work requires a separate adoption issue before any
  runtime route behavior or history-visibility claim is added.
- Client work is needed only if a public SDK or UI surface intentionally
  exposes these descriptors or parsed envelopes.
- Release evidence must keep `advertisement_allowed=false` for Client-Server
  API until the broader `SPEC-073` lanes are resolved for the release.

## Compatibility boundaries

- `SPEC-036` remains the `/rooms/{roomId}/messages` pagination MVP contract.
- `SPEC-037` remains the `/sync` MVP contract.
- `SPEC-073` remains the Client-Server full-breadth gap inventory.
- Passing this contract does not claim full Client-Server support, historical
  event visibility correctness, membership lazy-loading completeness,
  deprecated endpoint runtime compatibility, or Matrix v1.18 full compliance.
