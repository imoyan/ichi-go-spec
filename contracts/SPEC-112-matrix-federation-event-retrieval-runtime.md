# Matrix v1.18 / Server-Server API / federation event retrieval runtime

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Server-Server API
Primary reference: Matrix v1.18 / Server-Server API / federation event retrieval runtime
Repository anchor: SPEC-112 Matrix Federation Event Retrieval Runtime
Canonical: yes

## Purpose

Define the focused server-runtime adoption boundary promoted from the
`SPEC-074` `event-retrieval-missing-events-backfill-state-breadth` lane after
`SPEC-057` established representative backfill, event auth, and state ID
behavior.

This contract lets implementation repositories adopt representative runtime
behavior for federation event retrieval, missing-event lookup, state response
body retrieval, and timestamp lookup without claiming complete history
visibility, redaction correctness, full pagination/backfill breadth, complete
state resolution, outbound federation, or full Server-Server API support.

## Scope

This contract covers representative runtime behavior for:

```text
GET  /_matrix/federation/v1/event/{eventId}
POST /_matrix/federation/v1/get_missing_events/{roomId}
GET  /_matrix/federation/v1/state/{roomId}
GET  /_matrix/federation/v1/timestamp_to_event/{roomId}
```

Only these public behaviors are adopted:

- X-Matrix authorization for every adopted federation event-retrieval route;
- representative event retrieval for a known local PDU;
- bounded missing-event lookup from local room history;
- bounded state response body retrieval with `pdus` and `auth_chain`;
- timestamp lookup for forward and backward search directions;
- Matrix-compatible failures for invalid identifiers, malformed payloads,
  unsupported rooms, unknown events, invalid timestamp queries, and denied
  federation origins.

This contract does not define complete history visibility, redaction
correctness, complete pagination or historical backfill breadth, complete
state-resolution correctness, outbound federation fanout, remote fetches,
reference homeserver interop, or Matrix version advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1eventeventid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#post_matrixfederationv1get_missing_eventsroomid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1stateroomid>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#get_matrixfederationv1timestamp_to_eventroomid>
- Parent contract: `SPEC-057`
- Gap inventory: `SPEC-074`
- Checked at: 2026-05-16T22:12:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST serve the representative endpoint family
from local server state without making remote network requests.

Federation event retrieval responses MUST preserve:

- `origin`;
- `origin_server_ts`;
- `pdus`;
- PDU `event_id`, `type`, `room_id`, `sender`, `origin_server_ts`, and `depth`;
- `prev_events` and `auth_events`;
- public `content`;
- `hashes.sha256`;
- server signature material using an `ed25519:*` key ID.

Missing-event responses MUST preserve:

- an `events` array containing bounded local PDUs between the supplied latest
  and earliest references;
- the same hash and signature material requirements as event retrieval;
- response size no larger than the accepted `limit` and implementation bound.

State responses MUST preserve:

- `pdus`, including representative state events for the requested room point;
- `auth_chain`;
- event IDs and room IDs matching the request scope.

Timestamp lookup responses MUST preserve:

- `event_id`;
- `origin_server_ts`;
- deterministic forward and backward lookup behavior for the representative
  room timeline.

## Resource Bounds

Runtime adoption is bounded:

- maximum missing-events limit: 20;
- maximum state response PDUs: 20;
- maximum state response auth-chain events: 20;
- request authorization required: true;
- outbound federation execution: false;
- complete history visibility claimed: false;
- redaction correctness claimed: false;
- complete pagination/backfill breadth claimed: false;
- complete state-resolution correctness claimed: false;
- timestamp index persistence claimed: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- missing or invalid federation request authorization;
- ACL-denied federation origins;
- invalid or unknown event IDs;
- invalid room IDs;
- unsupported rooms;
- missing or invalid `event_id` query values for state retrieval;
- missing-events bodies that are not JSON objects;
- missing-events bodies with invalid `earliest_events`, `latest_events`,
  `limit`, or `min_depth` values;
- timestamp queries with invalid `ts` or `dir` values;
- route methods outside the adopted endpoint family.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#159` may adopt representative runtime behavior using this
  vector.
- `houra-server#140`, `houra-server#168`, and `houra-server#169` remain the
  owners for full room-version auth, event format, and state-resolution
  correctness.
- `houra-server#136` remains open until every included Server-Server lane has
  passing evidence or explicit release exclusion.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API until the broader `SPEC-074` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-057` remains the representative backfill, event auth, and state IDs
  contract.
- `SPEC-074` remains the Server-Server full-breadth gap inventory.
- `SPEC-110` remains the representative ACL/policy/signing contract for the
  protected policy event surface using the same event retrieval route.
- Passing this contract does not claim complete history visibility, redaction
  correctness, complete state resolution, Complement full-breadth, or Matrix
  v1.18 full compliance.
