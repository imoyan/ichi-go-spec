# SPEC-037: Matrix Client-Server Sync MVP

Status: draft
Feature profile: sync
Contract type: endpoint
Matrix domain: Client-Server API
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server `/sync` surface closest to the existing
Houra Product MVP room list, state, timeline, and incremental sync flow.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**` sync
behavior without changing existing `/_houra/client/**` room list, timeline, or
sync routes.

This is an MVP-equivalent sync contract. It covers initial sync, incremental
sync, sync tokens, joined-room state and timeline sections, global and room
account data envelopes, empty incremental responses, and representative Matrix
auth/pagination errors. It does not define Matrix filter storage, presence
semantics, ephemeral events, invite/knock/leave room details, E2EE device list
tracking, to-device messaging, `use_state_after`, lazy-loaded member behavior,
or full room-version state resolution.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3sync>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#syncing>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#clienteventwithoutroomid>
- Checked at: 2026-05-10T12:32:41+09:00
- Timezone: Asia/Tokyo

## Request

```text
GET /_matrix/client/v3/sync?timeout=0
Authorization: Bearer token-1
```

`since`, when present, must be a sync token previously returned as
`next_batch`. `timeout`, when present, is a non-negative integer in
milliseconds. `full_state`, `filter`, `set_presence`, and `use_state_after` are
recognized as Matrix query names but are outside the MVP vectors unless a later
contract adds endpoint-family coverage.

Servers must not require clients to put access tokens in query parameters.

## Initial sync response

Successful initial sync without `since` returns a Matrix `/sync` response with a
new `next_batch` token and a `rooms.join` map keyed by room ID:

```json
{
  "next_batch": "s1",
  "rooms": {
    "join": {
      "!room:example.test": {
        "state": {
          "events": []
        },
        "timeline": {
          "events": [],
          "limited": false,
          "prev_batch": "t0"
        }
      }
    }
  }
}
```

The MVP response shape must support:

- top-level `account_data.events`
- `rooms.join`
- joined room `state.events`
- joined room `timeline.events`
- joined room `account_data.events`
- joined room `summary`
- joined room `unread_notifications`

Sync room state and timeline events use Matrix `ClientEventWithoutRoomID`
objects because the room ID is already the key of the `rooms.join` map. Room
IDs, event IDs, user IDs, event types, and timestamps follow `SPEC-031`.

## Incremental sync response

Successful incremental sync with `since=s1` returns only changes after the
provided token and a new `next_batch` token. A response with no changes is still
successful and must include `next_batch`.

Joined room `timeline.prev_batch` may be returned as a pagination token that can
be passed to `GET /_matrix/client/v3/rooms/{roomId}/messages` from `SPEC-036`.
`timeline.limited` must be present when the server knows whether the timeline
was limited by a filter. The MVP vectors use `limited: false`.

## Authentication and token errors

Missing bearer tokens must return `401` with `M_MISSING_TOKEN`. Invalid bearer
tokens must return `401` with `M_UNKNOWN_TOKEN`.

Invalid `since` tokens must return `400` with `M_INVALID_PARAM`.

## Compatibility boundaries

- Existing `/_houra/client/sync`, room list, and timeline behavior stays
  available.
- Matrix sync endpoints must use Matrix `M_*` error envelopes, not Houra `code`
  envelopes.
- This contract does not advertise presence, to-device, E2EE device lists,
  invites, knocks, leaves, filters, lazy loading, or `use_state_after` support.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if parser-only shared-core
  adoption is useful for Matrix sync response parsing.
