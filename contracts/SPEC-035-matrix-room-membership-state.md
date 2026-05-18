# Matrix v1.18 / Client-Server API / create, join, leave, and room state endpoints

Status: draft
Feature profile: rooms
Contract type: endpoint
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / create, join, leave, and room state endpoints
Repository anchor: SPEC-035 Matrix Client-Server Room Membership and State MVP
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server room lifecycle surface closest to the
existing Houra Product MVP room flow: create a room, join a room, leave a room,
and read the current room state.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**` room
behavior without changing existing `/_houra/client/**` room routes.

This is an MVP-equivalent room contract. It does not define Matrix room version
auth rules, event DAG persistence, state resolution, room aliases, public room
directory behavior, invites, knocks, kicks, bans, room upgrades, `/joined_rooms`,
or federation joins. Those require later Client-Server, Room Versions, and
Federation contracts before they are advertised as complete.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3createroom>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3joinroomidoralias>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3roomsroomidleave>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3roomsroomidstate>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#mroomguest_access>
- Checked at: 2026-05-18T20:05:00+09:00
- Timezone: Asia/Tokyo

## Matrix room identifiers

Room IDs and room aliases must follow the Matrix identifier grammar in
`SPEC-031`. The MVP vectors use room IDs only. Alias resolution, `server_name`
routing hints, public-room directory lookup, and remote federation discovery are
outside this contract.

## Matrix client event shape

Room state responses use Matrix client events. A state event contains required
`event_id`, `room_id`, `sender`, `origin_server_ts`, `type`, `state_key`, and
`content` fields:

```json
{
  "event_id": "$name:example.test",
  "room_id": "!room:example.test",
  "sender": "@alice:example.test",
  "origin_server_ts": 1710000000000,
  "type": "m.room.name",
  "state_key": "",
  "content": {
    "name": "General"
  }
}
```

`event_id`, `room_id`, `sender`, `type`, and `state_key` must be strings.
`origin_server_ts` must be a non-negative integer timestamp in milliseconds.
`content` must be an object. `unsigned`, when present, is implementation-owned
metadata and must not be required by portable client logic.

## Create room

```text
POST /_matrix/client/v3/createRoom
Authorization: Bearer token-1
```

```json
{
  "name": "General"
}
```

The MVP request body covers `name` only. The server may support additional
Matrix `createRoom` fields, but clients must not rely on `room_alias_name`,
`visibility`, `preset`, `invite`, `invite_3pid`, `initial_state`,
`creation_content`, or `power_level_content_override` until a later contract
adds vectors for them.

Successful responses return the created room ID:

```json
{
  "room_id": "!room:example.test"
}
```

Room-version selection and default room version advertisement are intentionally
left to the Room Versions contract. This contract must not be used as evidence
that room versions 1-12, event authorization, or state resolution are complete.

## Join room

```text
POST /_matrix/client/v3/join/!room:example.test
Authorization: Bearer token-1
```

```json
{}
```

The MVP join path is `/_matrix/client/v3/join/{roomIdOrAlias}` with room IDs.
Successful responses return the joined room ID:

```json
{
  "room_id": "!room:example.test"
}
```

Joining by alias, `server_name` query hints, restricted rooms, knocks, invites,
and remote federation joins are outside this contract.

### Guest join boundary

Guest access is controlled by `m.room.guest_access`. When a request uses a
guest access token and the room does not have a current `m.room.guest_access`
state event whose `content.guest_access` is `can_join`, representative Houra
compatibility must fail closed with `403` and `M_FORBIDDEN`.

This contract adds the representative guest join boundary for `forbidden` and
`can_join` states. The `can_join` path only covers the direct join response for
a room that already has current `m.room.guest_access` state with
`content.guest_access = can_join`.

Guest-to-user upgrade with `guest_access_token` is covered by `SPEC-033`.
This contract does not define full guest-specific API allowlist breadth. It
only records a representative fail-closed boundary: guest tokens can be shown to
be rejected from the non-allowlist state-changing
`POST /_matrix/client/v3/createRoom` path with `403` and
`M_GUEST_ACCESS_FORBIDDEN`. Broader guest-specific API allowlist breadth beyond
that representative createRoom rejection remains out of scope until a later
contract adds endpoint-family coverage.

Room preview event streams and guest-specific rate-limit policy remain outside
this contract.

## Leave room

```text
POST /_matrix/client/v3/rooms/!room:example.test/leave
Authorization: Bearer token-1
```

```json
{}
```

Successful leave responses return an empty JSON object:

```json
{}
```

Forgetting a room, kicking another user, banning, unbanning, and membership list
queries are outside this contract.

## Room state

```text
GET /_matrix/client/v3/rooms/!room:example.test/state
Authorization: Bearer token-1
```

Successful responses return an array of current state events:

```json
[
  {
    "event_id": "$name:example.test",
    "room_id": "!room:example.test",
    "sender": "@alice:example.test",
    "origin_server_ts": 1710000000000,
    "type": "m.room.name",
    "state_key": "",
    "content": {
      "name": "General"
    }
  }
]
```

The response body is the array itself, not an object wrapper. Reading a single
state event by `{eventType}/{stateKey}` is outside this MVP contract.

## Authentication and room errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

If a room cannot be found or the user cannot learn about it, servers must return
a Matrix error envelope such as:

```json
{
  "errcode": "M_NOT_FOUND",
  "error": "Room not found."
}
```

If an authenticated user is not allowed to access the room state or complete a
membership transition, servers must return `403` with `M_FORBIDDEN`.

## Compatibility boundaries

- Existing `/_houra/client/rooms/**` behavior stays available.
- Matrix room endpoints must use Matrix `M_*` error envelopes, not Houra `code`
  envelopes.
- Matrix room create/join/leave/state support is additive and does not by
  itself widen `GET /_matrix/client/versions` advertisement beyond the evidence
  gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only shared-core
  adoption is useful for Matrix room ID, event, or state response parsing.
