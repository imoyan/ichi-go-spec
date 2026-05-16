# SPEC-108: Matrix Federation Directory, Query, and OpenID Runtime

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define the focused server-runtime adoption boundary promoted from the
`SPEC-074` `directory-spaces-query-openid-profile-breadth` lane after
`SPEC-100` established parser-only descriptors.

This contract lets implementation repositories adopt representative runtime
behavior for federation public rooms, hierarchy, directory query, profile
query, unsupported generic queries, and OpenID userinfo without claiming remote
network federation, complete visibility policy, OpenID trust, rate limiting,
cache persistence, Client-Server spaces breadth, or full Server-Server API
support.

## Scope

This contract covers representative runtime behavior for:

```text
GET  /_matrix/federation/v1/publicRooms
POST /_matrix/federation/v1/publicRooms
GET  /_matrix/federation/v1/hierarchy/{roomId}
GET  /_matrix/federation/v1/query/directory
GET  /_matrix/federation/v1/query/profile
GET  /_matrix/federation/v1/query/{queryType}
GET  /_matrix/federation/v1/openid/userinfo
```

Only these public behaviors are adopted:

- bounded public room list responses with pagination metadata;
- bounded spaces hierarchy responses with child state and inaccessible child
  metadata;
- directory query responses for known local aliases;
- profile query responses for known local users and Matrix-compatible not-found
  errors for unknown users;
- unsupported generic query failure envelopes;
- OpenID userinfo responses for a representative valid access token and
  unauthorized failure envelopes for missing or unknown tokens.

This contract does not define remote network fetch, federation cache behavior,
complete room visibility policy, join authorization, Client-Server spaces
hierarchy breadth, profile privacy policy, OpenID token trust, identity
provider verification, rate limiting, or Matrix version advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1publicrooms>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#post_matrixfederationv1publicrooms>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1hierarchyroomid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#querying-for-information>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#openid>
- Parser-helper contract: `SPEC-100`
- Gap inventory: `SPEC-074`
- Checked at: 2026-05-16T16:45:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST serve the representative endpoint family
from local in-memory or persisted server state without making remote network
requests.

Public rooms responses MUST preserve:

- `chunk` room summaries;
- `room_id`, `num_joined_members`, `world_readable`, and `guest_can_join`;
- optional `name`, `topic`, `canonical_alias`, `avatar_url`, `join_rule`, and
  `room_type`;
- `next_batch`, `prev_batch`, and `total_room_count_estimate` metadata when
  applicable.

Hierarchy responses MUST preserve:

- room summary fields shared with public room results;
- `children_state` event descriptors;
- `inaccessible_children`;
- pagination tokens when applicable.

Directory and profile query responses MUST preserve:

- `room_id` and server list for directory query results;
- optional `displayname` and `avatar_url` for profile query results;
- Matrix-compatible failures for unknown aliases, unknown profiles, and
  unsupported generic query types.

OpenID userinfo MUST preserve:

- `sub` as the Matrix user ID subject for the representative valid token;
- `M_UNAUTHORIZED` for missing or unknown access tokens.

## Resource Bounds

Runtime adoption is bounded:

- maximum public room summary count: 50;
- maximum hierarchy room summary count: 50;
- maximum children state event count per room: 20;
- maximum inaccessible child count: 50;
- maximum server list count per directory query: 20;
- remote network fetch: false;
- visibility decision completeness: false;
- profile privacy policy completeness: false;
- OpenID token verification trust: false;
- cache persistence: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- negative or non-integer `limit` values;
- public room POST bodies that are not objects;
- hierarchy requests with invalid room IDs;
- directory queries missing `room_alias`;
- unknown room aliases;
- profile queries missing `user_id`;
- unknown profile users;
- unsupported generic `queryType` values;
- OpenID userinfo requests without a valid representative token.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#232` may adopt representative runtime behavior using this
  vector.
- `houra-server#153` remains the owner for Client-Server spaces and hierarchy
  breadth.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API until the broader `SPEC-074` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-048` remains the Client-Server room directory / aliases / invites
  contract.
- `SPEC-055` remains the Server-Server discovery and signing-key bootstrap
  contract.
- `SPEC-100` remains the parser-helper boundary for directory, hierarchy,
  query, and OpenID descriptors.
- `SPEC-074` remains the Server-Server full-breadth gap inventory.
- Passing this contract does not claim remote visibility correctness, remote
  federation directory support, OpenID trust, rate limiting, cache behavior,
  Complement full-breadth, or Matrix v1.18 full compliance.
