# SPEC-111: Matrix Federation Leave and Knock Runtime

Status: draft
Feature profile: events
Contract type: boundary
Matrix domain: Server-Server API
Canonical: yes

## Purpose

Define the focused server-runtime adoption boundary promoted from the
`SPEC-074` `join-knock-leave-invite-third-party-invite-breadth` lane after
`SPEC-056` established representative transaction, join, and invite behavior.

This contract lets implementation repositories adopt representative runtime
behavior for federation leave and knock handshakes without claiming restricted
join/knock correctness, complete room-version authorization, third-party
invite exchange, remote state lookup, outbound federation, or full
Server-Server API support.

## Scope

This contract covers representative runtime behavior for:

```text
GET /_matrix/federation/v1/make_leave/{roomId}/{userId}
PUT /_matrix/federation/v2/send_leave/{roomId}/{eventId}
GET /_matrix/federation/v1/make_knock/{roomId}/{userId}
PUT /_matrix/federation/v1/send_knock/{roomId}/{eventId}
```

Only these public behaviors are adopted:

- X-Matrix authorization for every federation membership route;
- representative leave and knock event templates;
- signed send_leave and send_knock responses for valid representative events;
- Matrix-compatible failures for invalid identifiers, unsupported rooms, and
  malformed membership events.

This contract does not define complete auth-event selection, stripped-state
correctness, restricted or knock-restricted join behavior, room-version auth
algorithms, membership persistence, outbound federation fanout, third-party
invite exchange, or Matrix version advertisement.

## Matrix Reference

- Matrix specification version: `v1.18`
- Source: <https://spec.matrix.org/v1.18/server-server-api/#leaving-rooms>
- Source: <https://spec.matrix.org/v1.18/server-server-api/#knocking-on-rooms>
- Parent contract: `SPEC-056`
- Gap inventory: `SPEC-074`
- Checked at: 2026-05-16T21:50:00+09:00
- Timezone: Asia/Tokyo

## Runtime Behavior

Servers adopting this contract MUST serve the representative endpoint family
from local server state without making remote network requests.

Leave and knock templates MUST preserve:

- `room_version`;
- membership event `type`, `room_id`, `sender`, `state_key`, and `content`;
- `membership` values of `leave` and `knock` respectively.

send_leave and send_knock responses MUST preserve:

- the submitted `event_id`;
- signed membership event fields;
- local homeserver signature material;
- `knock_room_state` for accepted representative knock responses.

## Resource Bounds

Runtime adoption is bounded:

- maximum knock room state events: 20;
- request authorization required: true;
- membership persistence: false;
- outbound federation execution: false;
- restricted join/knock correctness claimed: false;
- complete auth-event selection claimed: false;
- room-version auth correctness claimed: false;
- third-party invite exchange claimed: false;
- versions advertisement widened: false.

Implementations MUST fail closed when these bounds are missing or weakened.

## Fail-Closed Behavior

Implementations must reject:

- missing or invalid federation request authorization;
- invalid room IDs, user IDs, or event IDs;
- unsupported rooms;
- send_leave bodies that are not leave membership events;
- send_knock bodies that are not knock membership events;
- route methods outside the adopted endpoint family.

## Adoption Decision Checklist

After this contract merges:

- `houra-server#158` may adopt representative runtime behavior using this
  vector.
- `houra-server#140`, `houra-server#168`, and `houra-server#169` remain the
  owners for full room-version auth, event format, and state-resolution
  correctness.
- `houra-server#136` remains open until every included Server-Server lane has
  passing evidence or explicit release exclusion.
- Release evidence must keep `advertisement_allowed=false` for Server-Server
  API until the broader `SPEC-074` lanes are resolved for the release.

## Compatibility Boundaries

- `SPEC-056` remains the representative transaction, join, and invite contract.
- `SPEC-057` remains the federation backfill, event auth, and state interop
  contract.
- `SPEC-074` remains the Server-Server full-breadth gap inventory.
- Passing this contract does not claim restricted join/knock completeness,
  third-party invite exchange, Complement full-breadth, or Matrix v1.18 full
  compliance.
