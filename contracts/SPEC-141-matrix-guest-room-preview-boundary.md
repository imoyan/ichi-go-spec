# Matrix v1.18 / Client-Server API / Guest Access and Room Previews

Status: draft
Feature profile: core
Contract type: boundary
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / Guest Access and Room Previews
Repository anchor: SPEC-141 Matrix Guest Room Preview Boundary
Canonical: yes

## Purpose

Define the focused guest room preview boundary promoted from the `SPEC-073`
Client-Server full-breadth inventory and tracked by #447.

This contract lets implementation repositories adopt the request descriptor and
response envelope for Matrix room previews without treating the preview stream as
full guest API allowlist breadth or full Client-Server runtime support.

## Scope

This contract covers only the representative preview sequence:

```text
GET /_matrix/client/v3/rooms/{roomId}/initialSync
GET /_matrix/client/v3/events?room_id={roomId}
```

The `/events` descriptor here is the room-preview variant with a required
`room_id` query parameter. It is not the normal deprecated `/events` stream
adopted as a runtime endpoint.

The representative response envelope covers the preview `/events` `chunk`,
`start`, and `end` fields, with each event parsed as a Matrix client event.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#guest-access>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#room-previews>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3events>
- Checked at: 2026-05-19T06:38:23+09:00
- Timezone: Asia/Tokyo

## Preview preconditions

Room preview access is separate from guest joining. Representative Houra
compatibility requires:

- a guest access token created through `SPEC-033` `kind=guest` registration;
- a target room ID;
- current room history visibility that permits room preview access, represented
  by `m.room.history_visibility` with `history_visibility = world_readable`;
- no Matrix `/versions` advertisement widening from this preview boundary.

The `m.room.guest_access = can_join` state from `SPEC-035` allows guest joining.
It is not sufficient by itself to claim preview stream behavior. Conversely,
this preview boundary does not grant room membership.

## Request descriptors

The adopted descriptors are intentionally narrow:

```json
{
  "method": "GET",
  "path": "/_matrix/client/v3/events",
  "query_params": {
    "room_id": "!room:example.test",
    "from": "s0_0",
    "timeout": 0
  },
  "requires_auth": true,
  "requires_guest_token": true,
  "room_preview_variant": true,
  "response_parser": "room_preview_events"
}
```

`room_id` is required for the room-preview variant. `from` and `timeout` are
typed query parameters only. This contract does not adopt long-poll timing,
token persistence, backfill, event delivery fanout, or normal `/events` runtime
compatibility.

## Response envelope

Successful preview event responses use:

```json
{
  "chunk": [
    {
      "content": {
        "body": "Preview message",
        "msgtype": "m.text"
      },
      "event_id": "$preview:example.test",
      "origin_server_ts": 1715754600000,
      "room_id": "!room:example.test",
      "sender": "@alice:example.test",
      "type": "m.room.message",
      "unsigned": {
        "membership": "leave"
      }
    }
  ],
  "start": "s0_0",
  "end": "s1_0"
}
```

The `chunk` array may be empty. If an event is present, it must satisfy the
Matrix client event shape already used by `SPEC-035` and `SPEC-085`. `start` and
`end` are opaque pagination tokens and must not be parsed for semantics.

## Fail-closed behavior

Implementations must fail closed:

- do not expose room preview when the room is not `world_readable`;
- do not treat `m.room.guest_access = can_join` as preview permission by itself;
- do not allow preview `/events` without a guest token or room ID;
- do not adopt normal deprecated `/events` runtime behavior from this boundary;
- do not widen guest-specific API allowlist breadth beyond the representative
  room-preview descriptors;
- do not infer history visibility, authorization, pagination ordering, long-poll
  delivery, federation, or storage correctness from the parser shape;
- do not widen `GET /_matrix/client/versions`.

Guest-specific rate-limit policy remains outside this contract. Production
runtime adoption requires a separate server issue before advertising preview
stream support.

## Adoption decision checklist

After this contract merges:

- `houra-server` needs a separate adoption issue before implementing preview
  runtime behavior.
- `houra-client` needs an issue only if a public preview UI or SDK descriptor is
  intentionally exposed.
- `houra-labs` may adopt parser-only helper coverage if shared preview envelope
  parsing is useful.
- Release evidence must keep `advertisement_allowed=false` for Client-Server API
  until the broader `SPEC-073` lanes are resolved for the release.

## Compatibility boundaries

- `SPEC-033` remains the guest registration and guest-to-user upgrade contract.
- `SPEC-035` remains the guest join and representative guest API non-allowlist
  rejection contract.
- `SPEC-085` remains the event retrieval and deprecated compatibility parser
  boundary.
- `SPEC-073` remains the Client-Server full-breadth gap inventory.
- Passing this contract does not claim full guest API allowlist support, room
  preview runtime availability, guest-specific rate-limit behavior, normal
  `/events` runtime support, or Matrix v1.18 full compliance.
