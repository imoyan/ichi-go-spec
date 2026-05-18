# Matrix v1.18 / Client-Server API / public rooms, directory aliases, and invites

Status: draft
Feature profile: rooms
Contract type: endpoint
Matrix domain: Client-Server API
Primary reference: Matrix v1.18 / Client-Server API / public rooms, directory aliases, and invites
Repository anchor: SPEC-048 Matrix Room Directory, Aliases, and Invites
Canonical: yes

## Purpose

Define the Matrix v1.18 Client-Server room directory, local room alias listing,
and room invite endpoint family for Client-Server breadth.

## Scope

This contract is Matrix-defined, not Houra-defined. It adds `/_matrix/**`
public room directory, directory visibility, alias listing, and invite behavior
without changing existing `/_houra/client/**` routes.

This endpoint family builds on `SPEC-035` room lifecycle behavior and
`SPEC-044` alias persistence. It covers public room listing, filtered public
room search, room directory visibility read/write, local alias listing, invite
by Matrix user ID, invite visibility through `/sync`, and representative
authorization errors. It does not define third-party invites, application
service network-specific directories, remote room directory federation,
hierarchy/space traversal, policy-server behavior, or unstable MSC behavior.

## Matrix reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/client-server-api/#room-directory>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3publicrooms>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3publicrooms>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#get_matrixclientv3roomsroomidaliases>
- Source: <https://spec.matrix.org/v1.18/client-server-api/#post_matrixclientv3roomsroomidinvite>
- Checked at: 2026-05-10T18:52:35+09:00
- Timezone: Asia/Tokyo

## Public room directory

Published rooms are listed with:

```text
GET /_matrix/client/v3/publicRooms?limit=10
POST /_matrix/client/v3/publicRooms
```

`GET` does not require authentication and supports `limit`, `server`, and
`since` query parameters. `POST` requires authentication and accepts the same
pagination options plus `filter`, `include_all_networks`, and `third_party_instance_id`.

A successful response returns a JSON object containing:

- `chunk`: a list of published room summaries.
- `next_batch` and `prev_batch` when pagination continues.
- `total_room_count_estimate` when the server can estimate it.

Each `chunk` entry must include `room_id`, `num_joined_members`,
`world_readable`, and `guest_can_join`. The representative vectors also include
`name`, `topic`, `canonical_alias`, `avatar_url`, `join_rule`, and `room_type`.

Rooms with `invite` join rules are not expected in public directory listings.
Rooms with public or knock-like join rules may appear when their directory
visibility is public.

## Directory visibility

Room directory visibility is accessed with:

```text
GET /_matrix/client/v3/directory/list/room/{roomId}
PUT /_matrix/client/v3/directory/list/room/{roomId}
```

`GET` does not require authentication. `PUT` requires authentication and may be
restricted by local authorization policy, such as room creator, power levels, or
server administrator status.

The `visibility` value is `public` or `private`. Successful `PUT` requests
return `200` with `{}`. Successful `GET` requests return `200` with
`{"visibility": "public"}` or `{"visibility": "private"}`.

Directory visibility must control whether a room is returned from the local
public room directory. It does not itself change join rules, membership state,
history visibility, or aliases.

## Room aliases

Alias create, resolve, and delete persistence is already covered by `SPEC-044`.
This contract adds the Client-Server breadth endpoint for listing local aliases:

```text
GET /_matrix/client/v3/rooms/{roomId}/aliases
```

The endpoint requires authentication. It may be called by room members, and
world-readable rooms may permit broader access. External users who are not
allowed to see aliases must receive `403` with `M_FORBIDDEN`.

A successful response returns `200` with:

```json
{
  "aliases": [
    "#project:example.test"
  ]
}
```

Alias list output is not curated and must not be treated as a replacement for
the canonical alias state event.

## Invites

Matrix user ID invites are sent with:

```text
POST /_matrix/client/v3/rooms/{roomId}/invite
Authorization: Bearer token-1
```

The request body must include `user_id`, the Matrix user ID of the invitee. It
may include `reason`, which is carried on the resulting membership event.

Only users currently in the room and authorized by the room's power levels may
invite another user. A successful response returns `200` with `{}` when the
user has been invited or was already invited.

The homeserver must append a `m.room.member` state event with
`content.membership` set to `invite` for the invitee. Later `/sync` responses
for the invitee must expose the room under `rooms.invite` with stripped invite
state sufficient for the client to render and decide whether to join.

Matrix v1.18 invite blocking is controlled by the invitee's
`m.invite_permission_config` account data. When local policy blocks an invite,
the Matrix-facing invite request must fail with `403` and `M_INVITE_BLOCKED`,
and the blocked invite must not appear in the invitee's `/sync` invite section.
This contract records the Client-Server error and sync-visibility boundary only;
policy evaluation, admin controls, federation invite propagation, audit
artifacts, and Server-Server full-breadth behavior remain split into `SPEC-073`
and `SPEC-074` follow-up work.

## Authentication and errors

Missing bearer tokens on endpoints that require authentication must return
`401` with `M_MISSING_TOKEN`. Invalid bearer tokens must return `401` with
`M_UNKNOWN_TOKEN`.

Requests where the access token is not authorized to change directory
visibility, list room aliases, or invite users must return `403` with
`M_FORBIDDEN`.

Unknown rooms, aliases, or invite targets must return a Matrix `M_*` error
envelope, normally `M_NOT_FOUND`, `M_NOT_ALLOWED`, or `M_FORBIDDEN` depending on
the endpoint and whether the server may disclose existence.

Malformed room directory, alias, or invite request bodies must return a Matrix
`M_*` error envelope appropriate to the failure (`M_BAD_JSON`, `M_NOT_JSON`,
`M_MISSING_PARAM`, or `M_INVALID_PARAM`).

Rate-limited endpoints may return `429` with `M_LIMIT_EXCEEDED` and
`retry_after_ms`.

## Compatibility boundaries

- Existing `/_houra/client/**` behavior stays available.
- Matrix room directory, alias listing, and invite endpoints must use Matrix
  `M_*` error envelopes, not Houra `code` envelopes.
- This contract does not advertise third-party invites, application service
  network directories, remote public room federation, spaces hierarchy,
  federation invite signing, admin controls, E2EE, or full Matrix v1.18
  compliance.
- This contract must not by itself widen `GET /_matrix/client/versions`
  advertisement beyond the evidence gate in `SPEC-030` and `SPEC-031`.
- After this spec PR is merged, create adoption issues for `houra-server` and
  `houra-client`. Create an `houra-labs` issue only if a parser-only shared
  helper is intentionally adopted for public room summaries, alias lists, or
  stripped invite state.
