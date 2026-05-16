# SPEC-100: Matrix Federation Directory / Query / OpenID Parser Helpers

Status: draft
Feature profile: core
Canonical: yes

## Purpose

Define bounded parser-helper contracts for the `SPEC-074`
`directory-spaces-query-openid-profile-breadth` lane.

This contract lets implementation repositories adopt parser-only helpers for
federation public rooms, spaces hierarchy, directory query, profile query,
generic query, and OpenID userinfo response shapes without claiming remote
visibility decisions, network fetch behavior, rate-limit policy, identity
verification, or full Server-Server API support.

## Scope

This contract covers parser and descriptor shape for:

```text
GET  /_matrix/federation/v1/publicRooms
POST /_matrix/federation/v1/publicRooms
GET  /_matrix/federation/v1/hierarchy/{roomId}
GET  /_matrix/federation/v1/query/directory
GET  /_matrix/federation/v1/query/profile
GET  /_matrix/federation/v1/query/{queryType}
GET  /_matrix/federation/v1/openid/userinfo
```

Only these public parser artifacts are adopted:

- public room request descriptors and response summaries;
- pagination token descriptors;
- spaces hierarchy room summaries and inaccessible child descriptors;
- directory query alias results;
- profile query display name and avatar metadata;
- generic query result envelopes;
- OpenID userinfo response metadata.

This contract does not define remote network fetch, room visibility policy,
join authorization, profile privacy policy, OpenID token verification,
identity provider trust, rate limiting, cache persistence, or Matrix version
advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1publicrooms>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#post_matrixfederationv1publicrooms>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1hierarchyroomid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#querying-for-information>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#openid>
- Parent contract: `SPEC-074`
- Gap inventory: `SPEC-074`
- Checked at: 2026-05-16T13:45:00+09:00
- Timezone: Asia/Tokyo

## Parser Behavior

Parser helpers MUST produce normalized descriptors rather than raw JSON
passthrough.

Public room parsers MUST preserve:

- `chunk` room summaries;
- `room_id`, `num_joined_members`, `world_readable`, and `guest_can_join`;
- optional `name`, `topic`, `canonical_alias`, `avatar_url`, `join_rule`, and
  `room_type`;
- `next_batch`, `prev_batch`, and `total_room_count_estimate` metadata.

Hierarchy parsers MUST preserve:

- room summary fields shared with public room results;
- `children_state` event descriptors;
- `inaccessible_children`;
- pagination tokens.

Directory and profile query parsers MUST preserve:

- `room_id` and server list for directory query results;
- optional display name and avatar URL for profile query results;
- generic query type and response object presence.

OpenID userinfo parsers MUST preserve only the response metadata:

- `sub` as the Matrix user ID subject;
- token verification status as parser evidence only;
- `adopted_runtime_behavior=false`.

## Resource Bounds

Parser adoption is bounded:

- maximum public room summary count: 50;
- maximum hierarchy room summary count: 50;
- maximum children state event count per room: 20;
- maximum inaccessible child count: 50;
- maximum server list count per directory query: 20;
- maximum generic query response bytes: 16384;
- remote network fetch: false;
- visibility decision: false;
- OpenID token verification: false;
- cache persistence: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- public room or hierarchy responses missing `chunk`;
- room summaries missing `room_id`, `num_joined_members`, `world_readable`, or
  `guest_can_join`;
- negative room counts;
- non-string pagination tokens;
- directory query responses missing `room_id` or `servers`;
- profile query responses that are not objects;
- OpenID userinfo responses missing `sub`;
- generic query responses that exceed the byte bound.

## Adoption Decision Checklist

After this contract merges:

- `houra-labs#125` may adopt parser-only helper coverage for federation
  public rooms, hierarchy, directory/profile/generic queries, and OpenID
  userinfo response metadata.
- Server runtime work requires a separate adoption issue before remote
  directory federation, network query execution, profile privacy policy,
  OpenID token verification, rate limiting, or cache persistence is
  implemented.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API until the broader `SPEC-074` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-048` remains the Client-Server room directory / aliases / invites
  parser contract.
- `SPEC-055` remains the Server-Server discovery and signing-key bootstrap
  contract.
- `SPEC-074` remains the Server-Server full-breadth gap inventory.
- Passing this contract does not claim remote visibility correctness, network
  federation directory support, OpenID trust, rate limiting, cache behavior,
  Complement full-breadth, or Matrix v1.18 full compliance.
